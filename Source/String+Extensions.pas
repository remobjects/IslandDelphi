namespace RemObjects.Elements.System;

type
  IslandString_Extensions = public extension class(IslandString)
  public

    operator Explicit(aString: IslandString): DelphiUnicodeString;
    begin

    end;

    operator Explicit(aString: DelphiUnicodeString): IslandString;
    begin

    end;

  end;

end.