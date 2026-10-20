namespace RemObjects.Elements.System;

type
  // Pass raw ABI addresses; the helper explicitly transfers the owned result.
  {$IF WINDOWS}
  [CallingConvention(CallingConvention.Register)]
  DelphiInterfaceGetter = procedure(aInstance: UIntPtr; aValue: UIntPtr);
  {$ELSE}
  [CallingConvention(CallingConvention.Register)]
  DelphiInterfaceGetter = function(aInstance: UIntPtr): :Delphi.System.IInterface;
  {$ENDIF}

  [Internal]
  DelphiHelpers = public static class
  public

    {$IF CLASSIC}
    { workarond for E26821 }
    {method CreateInstance(aType: class of TObject): TObject;
    begin
      result :=:Delphi.System.«@ClassCreate»(aType, true);
    end;}
    method CreateInstance(aType: ^Void): TObject;
    begin
      var lClass: class of :Delphi.System.TObject;
      lClass := :Delphi.System.TClass(aType);
      result :=:Delphi.System.«@ClassCreate»(lClass, true);
    end;
    {$ELSEIF DELPHIXE2}
    method CreateInstance(aType: ^Void): TObject;
    begin
      result :=:Delphi.System.«@ClassCreate»(aType, 1);
    end;
    {$ELSE}
    method CreateInstance(aType: ^Void): ^Void;
    begin
      {$IF WINDOWS AND CPU32}
      // Win32 @ClassCreate requires a caller-owned exception frame and cannot
      // be called as an ordinary function. NewInstance performs allocation and
      // initialization through the public virtual class entry instead.
      result := ^Void(:Delphi.System.TClass(aType).NewInstance);
      {$ELSE}
      result := :Delphi.System.«@ClassCreate»(aType, 1);
      {$ENDIF}
    end;
    {$ENDIF}

    method IsInstanceClass(aInstance: ^Void; aType: ^Void): ^Void;
    begin
      var lVMT := ^^Void(aInstance)^;
      loop begin
        if lVMT = aType then
          exit aInstance; // true;
        var lParent := (^^Void(lVMT+:Delphi.System.vmtParent))^;
        if not assigned(lParent) then
          exit nil; // false
        lVMT := ^^Void(lParent)^;
        if not assigned(lVMT) then
          exit nil; // false
      end;
    end;

    method IsInstanceInterface(aInstance: ^Void; aGuid: ^Void): ^Void;
    begin
      if not assigned(aGuid) then
        exit;

      var lGuid: :Delphi.System.TGUID;
      memcpy(@lGuid, aGuid, 16);
      TObject(aInstance).GetInterface(lGuid, out result);
    end;

    method IsInstanceInterfaceType(aInstance: ^Void; aTypeInfo: ^Void): ^Void;
    begin
      if not assigned(aInstance) or not assigned(aTypeInfo) then
        exit nil;

      {$IF NOT NO_TYPEINFO_APIS}
      // Delphi's interface table ends with one PPTypeInfo per entry. Unlike
      // an empty GUID, this identifies a particular GUID-less interface.
      var lVMT := ^^Void(aInstance)^;
      while assigned(lVMT) do begin
        var lTable := :Delphi.System.PInterfaceTable(^^Void(lVMT + :Delphi.System.vmtIntfTable)^);
        if assigned(lTable) then begin
          var lTypes := ^^^Void(@lTable^.Entries[lTable^.EntryCount]);
          for i := 0 to lTable^.EntryCount - 1 do begin
            if not assigned(lTypes[i]) or (lTypes[i]^ <> aTypeInfo) then
              continue;
            var lEntry := @lTable^.Entries[i];
            if lEntry^.IOffset <> 0 then
              exit RetainInterface(aInstance + lEntry^.IOffset);

            // An implements property can store the interface in a field or
            // return it from a static/virtual getter. GetInterface's GUID
            // lookup cannot select this entry when more than one has no GUID.
            var lToken := UIntPtr(lEntry^.ImplGetter);
            var lMask := UIntPtr($FF) shl ((sizeOf(^Void) - 1) * 8);
            if (lToken and lMask) = lMask then
              exit RetainInterface(^^Void(aInstance + (lToken and not lMask))^);
            var lGetter := ^Void(lToken);
            if (lToken and lMask) = (UIntPtr($FE) shl ((sizeOf(^Void) - 1) * 8)) then
              lGetter := ^^Void(^^Void(aInstance)^ + Int16(lToken))^;
            var lValue: :Delphi.System.IInterface;
            {$IF WINDOWS}
            DelphiInterfaceGetter(lGetter)(UIntPtr(aInstance), UIntPtr(@lValue));
            {$ELSE}
            lValue := DelphiInterfaceGetter(lGetter)(UIntPtr(aInstance));
            {$ENDIF}
            // Move the getter's owned result out without another retain.
            result := ^Void(lValue);
            ^^Void(@lValue)^ := nil;
            exit;
          end;
        end;
        var lParent := ^^Void(lVMT + :Delphi.System.vmtParent)^;
        if not assigned(lParent) then
          exit nil;
        lVMT := ^^Void(lParent)^;
      end;
      {$ENDIF}
    end;

    method RetainInterface(aInstance: ^Void): ^Void;
    begin
      if not assigned(aInstance) then
        exit nil;

      // A direct slot lookup returns a borrowed interface pointer.
      // Give the resulting temporary an owned reference before COMRC moves it.
      ^:Delphi.System.IInterface(@aInstance)^._AddRef;
      exit aInstance;
    end;

    method GetInterfaceInterface(aInstance: ^Void; aGuid: ^Void): ^Void;
    begin
      if not assigned(aInstance) or not assigned(aGuid) then
        exit nil;

      // An interface value points at its vtable slot, not at the object VMT.
      // QueryInterface converts it to another owned Delphi interface value.
      var lGuid: :Delphi.System.TGUID;
      memcpy(@lGuid, aGuid, 16);
      var lOutput: ^Void := nil;
      if ^:Delphi.System.IInterface(@aInstance)^.QueryInterface(lGuid, out ^^Void(@lOutput)^) = 0 then
        result := lOutput;
    end;

    method GetInterfaceClass(aInstance: ^Void; aType: ^Void): ^Void;
    begin
      if not assigned(aInstance) or not assigned(aType) then
        exit nil;

      // Delphi's RTL recovers the object from an interface pointer, including
      // interfaces stored at different offsets in the same object.
      result := :Delphi.System.«@SafeIntfAsClass»(
        ^:Delphi.System.IInterface(@aInstance)^, :Delphi.System.TClass(aType));
    end;

    //

    method ConvertStringArrayToDelphiStringArray(aArray: array of IslandString): array of DelphiString;
    begin
      result := new DelphiString[length(aArray)];
      for i := 0 to length(aArray)-1 do
        result[i] := aArray[i] as DelphiString;
    end;

    method NormalizeIncomingUnicodeStringInPlace(var aValue: DelphiUnicodeString);
    begin
      // Win32 Delphi UnicodeString results are returned through a hidden caller-owned
      // out slot. Treat that slot as the final value and avoid an extra copy/clear
      // dance here, which can corrupt Island-defined Delphi overrides.
    end;

    method NormalizeIncomingAnsiStringInPlace(var aValue: DelphiAnsiString);
    begin
      // Win32 Delphi AnsiString results use the same hidden caller-owned out slot
      // model as UnicodeString. Leave the returned slot intact.
    end;

    method NormalizeIncomingWideStringInPlace(var aValue: DelphiWideString);
    begin
      // Win32 Delphi WideString results are also returned through a hidden
      // caller-owned out slot, so do not rewrite the slot after the call.
    end;

  end;

  [Internal]
  DelphiDebuggerHelpers = public static class
  public

    [SymbolName('DelphiObjectToString'), Used , DllExport]
    class method DelphiObjectToString(aObject: TObject): ^WideChar;
    begin
      if not assigned(aObject) then
        exit nil;
      {$IF ARM64}
      exit "[Cannot evaluate TObject on arm64 yet, E26753. We're workign on it]";
      {$ENDIF}
      {$IF NO_TOSTRING}
      exit "[Cannot evaluate TObject Delphi 2006 and below]";
      {$ELSE}
      var s := (aObject.ToString as IslandString).ToCharArray(true);
      result := @s[0];
      {$ENDIF}
    end;

  end;

  //TObject_Extension = public extension class(TObject)
  //public

    //{$IF NOT EXISTS(Delphi.System.TObject.ToString)}
    //method ToString: DelphiString;
    //begin
      //result := $"{^Void(self)}";
    //end;
    //{$ENDIF}

    //{$IF NOT EXISTS(Delphi.System.TObject.GetHashCode)}
    //method GetHashCode: IntPtr;
    //begin
      //result := IntPtr(^Void(self));
    //end;
    //{$ENDIF}

  //end;

  [Internal]
  DelphiExceptionHandler = public static class
  public
    {$IF WINDOWS}
    // Retain the registration initializer when linking this static library.
    [RemObjects.Elements.System.Used]
    {$ENDIF}
    [RemObjects.Elements.System.GlobalConstructor(0)]
    class method Initialize;
    begin
    end;

    class constructor;
    begin
      {$IF WINDOWS AND ARM64EC}
      var lHandler := new ForeignExceptionImplementation($454D4254444C5048, @Handler, @FreeRec);
      lHandler.Acquire := @Acquire;
      ForeignExceptionImplementation.Register(lHandler);
      {$ELSE}
      ForeignExceptionImplementation.Register(new ForeignExceptionImplementation(
      {$IFDEF WINDOWS}
      $EEDFADE
      {$ELSE}
      $454D4254444C5048
      {$ENDIF}, @Handler, @FreeRec));
      {$ENDIF}
    end;

    method Handler(aData: ^Void): Exception;
    begin
      {$IF WINDOWS AND ARM64EC}
      // Delphi's Windows LLVM raise frame places ExceptObject 72 bytes before
      // its embedded _Unwind_Exception. Borrow it during the handler search;
      // Acquire transfers ownership only after the foreign frames are unwound.
      var lObj := InternalCalls.Cast<DelphiException>(^^Void(NativeInt(aData) - 72)^);
      exit new IslandWrappedDelphiException(lObj);
      {$ELSEIF WINDOWS}
      var aRec := ^rtl.EXCEPTION_RECORD(aData);
      var b := ^DelphiException(@aRec^.ExceptionInformation[1])^;
      exit new IslandWrappedDelphiException(b);
      {$ELSE}
      var lObj := ^DelphiException(@^CocoaExceptionRecord(aData)^.Object)^;
      ^DelphiException(@^CocoaExceptionRecord(aData)^.Object)^ := nil;
      exit new IslandWrappedDelphiException(lObj);
      {$ENDIF}
    end;

    {$IF WINDOWS AND ARM64EC}
    method Acquire(aData: ^Void; aException: Exception);
    begin
      IslandWrappedDelphiException(aException).AcquireInnerException;
    end;
    {$ENDIF}

    method FreeRec(aData: ^Void);
    begin
      {$IF WINDOWS AND ARM64EC}
      // Release the TLS raise-frame slot after Acquire has retained the object.
      :Delphi.System.«@DoneExcept»(var ^:Delphi.System.«@Unwind_Exception»(aData)^);
      {$ELSEIF WINDOWS}
      // Nothing to do
      {$ELSE}
      // Nothing to do; delphi cleans this up
      {$ENDIF}
    end;
  end;
end.