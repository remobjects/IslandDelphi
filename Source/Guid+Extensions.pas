namespace RemObjects.Elements.System;

type
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

end.