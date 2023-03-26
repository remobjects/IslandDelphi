namespace RemObjects.Elements.System;

type
  [Internal]
  DelphiHelpers = public static class
  public

    {$IF ANSI_STRING}
    method CreateInstance(aType: class of TObject): TObject;
    begin
      result :=:Delphi.System.«@ClassCreate»(aType, true);
    end;
    {$ELSE}
    method CreateInstance(aType: ^Void): ^Void;
    begin
      result :=:Delphi.System.«@ClassCreate»(aType, 1);
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

    method IsInstanceInterface(aInstance: ^Void; aType: ^Void): ^Void;
    begin
      raise new NotImplementedException("DelphiHelpers.IsInstanceInterface is not implemented yet.");

      writeLn($"aType {IntPtr(aType)}");
      for i := -100 to 100 do
        writeLn($"^AnsiChar(aType+{i})^ ({^Byte(aType+i)^}) {^AnsiChar(aType+i)^}");

      var lVMT := ^^Void(aInstance)^;
      var lInterfaceTable := (^^Void(lVMT+:Delphi.System.vmtIntfTable))^ as Delphi.System.PInterfaceTable;
      if assigned(lInterfaceTable) then begin

        for i := 0 to lInterfaceTable.EntryCount-1 do begin
          writeLn($"lInterfaceTable.Entries[i].VTable {IntPtr(lInterfaceTable.Entries[i].VTable)}");
          writeLn($"lInterfaceTable.Entries[i].IID {lInterfaceTable.Entries[i].IID as Guid}");
          writeLn($"lInterfaceTable.Entries[i].ImplGetter {IntPtr(lInterfaceTable.Entries[i].ImplGetter)}");
          writeLn($"lInterfaceTable.Entries[i].IOffset {IntPtr(lInterfaceTable.Entries[i].IOffset)}");
          if lInterfaceTable.Entries[i].VTable = aType then // AVs "read of 8"
            exit aInstance;

        end;
      end;
    end;

    //

    method ConvertStringArrayToDelphiStringArray(aArray: array of IslandString): array of DelphiString;
    begin
      result := new DelphiString[length(aArray)];
      for i := 0 to length(aArray)-1 do
        result[i] := aArray[i] as DelphiString;
    end;

  end;

  DelphiDebuggerHelpers = public static class
  public

    [SymbolName('DelphiObjectToString'), Used , DllExport]
    class method DelphiObjectToString(aObject: TObject): ^WideChar;
    begin
      if not assigned(aObject) then
        exit nil;
      var s := (aObject.ToString as IslandString).ToCharArray(true);
      result := @s[0];
    end;

  end;

  TObject_Extension = public extension class(TObject)
  public

    {$IF NOT EXISTS(Delphi.System.TObject.ToString)}
    method ToString: DelphiString;
    begin
      result := $"{^Void(self)}";
    end;
    {$ENDIF}

    {$IF NOT EXISTS(Delphi.System.TObject.GetHashCode)}
    method GetHashCode: IntPtr;
    begin
      result := IntPtr(^Void(self));
    end;
    {$ENDIF}

  end;

  [Internal]
  DelphiExceptionHandler = public static class
  public
    [RemObjects.Elements.System.GlobalConstructor(0)]
    class method Initialize;
    begin
    end;

    class constructor;
    begin
      ForeignExceptionImplementation.Register(new ForeignExceptionImplementation(
      {$IFDEF WINDOWS}
      $EEDFADE
      {$ELSE}
      $454D4254444C5048
      {$ENDIF}, @Handler, @FreeRec));
    end;

    method Handler(aData: ^Void): Exception;
    begin
      {$IFDEF WINDOWS}
      var aRec := ^rtl.EXCEPTION_RECORD(aData);
      var b := InternalCalls.Cast<DelphiException>(^Void(aRec^.ExceptionInformation[1]));
      exit new IslandWrappedDelphiException(b);
      {$ELSE}
      var lObj := ^DelphiException(@^CocoaExceptionRecord(aData)^.Object)^;
      ^DelphiException(@^CocoaExceptionRecord(aData)^.Object)^ := nil;
      exit new IslandWrappedDelphiException(lObj);
      {$ENDIF}
    end;

    method FreeRec(aData: ^Void);
    begin
      {$IFDEF WINDOWS}
      // Nothing to do
      {$ELSE}
      // Nothing to do; delphi cleans this up
      {$ENDIF}
    end;
  end;
end.