namespace RemObjects.Elements.System;

uses
  Delphi.System;

type
  TGUID_Extensions = public extension class(TGUID)
  public

    operator Implicit(aGuid: TGUID): System.Guid;
    begin
      memcpy(@result, @aGuid, sizeOf(Guid));
    end;

    operator Implicit(aGuid: System.Guid): TGUID;
    begin
      memcpy(@result, @aGuid, sizeOf(Guid));
    end;

  end;

end.