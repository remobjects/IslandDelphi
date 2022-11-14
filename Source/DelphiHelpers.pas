namespace RemObjects.Elements.System;

type
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

  DelphiExceptions = public static class
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