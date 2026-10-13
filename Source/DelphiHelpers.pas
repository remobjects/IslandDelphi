namespace RemObjects.Elements.System;

type
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
      result := :Delphi.System.«@ClassCreate»(aType, 1);
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

    //

    method ConvertStringArrayToDelphiStringArray(aArray: array of IslandString): array of DelphiString;
    begin
      result := new DelphiString[length(aArray)];
      for i := 0 to length(aArray)-1 do
        result[i] := aArray[i] as DelphiString;
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
    {$IF WINDOWS AND ARM64EC}
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
      var b := InternalCalls.Cast<DelphiException>(^Void(aRec^.ExceptionInformation[1]));
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