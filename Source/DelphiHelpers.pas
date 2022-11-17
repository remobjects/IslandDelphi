namespace RemObjects.Elements.System;

type
  [Internal]
  DelphiHelpers = public static class
  public

    method CreateInstance(aType: ^Void): ^Void;
    begin
      raise new NotImplementedException("DelphiHelpers.CreateInstance is not implemented yet.");
    end;

    method IsInstanceClass(aInstance: ^Void; aType: ^Void): ^Void;
    begin
      raise new NotImplementedException("DelphiHelpers.IsInstanceClass is not implemented yet.");
    end;

    method IsInstanceInterface(aInstance: ^Void; aType: ^Void): ^Void;
    begin
      raise new NotImplementedException("DelphiHelpers.IsInstanceInterface is not implemented yet.");
    end;

  end;

  [Internal]
  DelphiExceptionHandler = public static class
  public
    [RemObjects.Elements.System.GlobalConstructor(0)]
    class method Initialize;
    begin
      ForeignExceptionImplementation.Register(new ForeignExceptionImplementation($EEDFADE, @Handler, @Free));
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

    method Free(aData: ^Void);
    begin
      {$IFDEF WINDOWS}
      // Nothing to do
      {$ELSE}
      var lRec := ^CXXException(aData);
      lRec := ^CXXException(@^Byte(lRec)[-Int32((^Byte(@lRec^.Unwind) - ^Byte(lRec))) - (sizeOf(IntPtr) * 2)]);
      Free(lRec)
      {$ENDIF}
    end;
  end;
end.