namespace RemObjects.Elements.System;

type

  //
  // TGuid
  //

  TGUID_Extensions = public extension class(Delphi.System.TGUID)
  public

    operator Implicit(aGuid: Delphi.System.TGUID): RemObjects.Elements.System.Guid;
    begin
      memcpy(@result, @aGuid, sizeOf(RemObjects.Elements.System.Guid));
    end;

    operator Implicit(aGuid: RemObjects.Elements.System.Guid): Delphi.System.TGUID;
    begin
      memcpy(@result, @aGuid, sizeOf(RemObjects.Elements.System.Guid));
    end;

  end;

  //
  // TProc
  //

  TProc_Extensions = public extension class(Delphi.System.SysUtils.TProc)
  public

    operator Implicit(aBlock: block): Delphi.System.SysUtils.TProc;
    begin
      result := new interface TProc(Invoke := () -> aBlock);
    end;

  end

end.