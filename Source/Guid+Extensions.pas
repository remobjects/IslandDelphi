namespace RemObjects.Elements.System;

uses
  Delphi.System;

type
  TGUID_Extensions = public extension class(TGUID)
  public

    //operator Implicit(aGuid: TGUID): Guid;
    //begin
      //memcpy(@result, @aGuid, sizeOf(Guid));
    //end;

    //operator Implicit(aGuid: Guid): TGUID;
    //begin
      //memcpy(@result, @aGuid, sizeOf(Guid));
    //end;

    // E26255: Implicit cast operator does not allow explicit cast?
    operator Explicit(aGuid: TGUID): Guid;
    begin
      memcpy(@result, @aGuid, sizeOf(Guid));
    end;

    operator Explicit(aGuid: Guid): TGUID;
    begin
      memcpy(@result, @aGuid, sizeOf(Guid));
    end;

  end;

end.