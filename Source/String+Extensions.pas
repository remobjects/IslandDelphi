namespace RemObjects.Elements.System;

type
  IslandString_Extensions = public extension class(IslandString)
  public

    operator Explicit(aString: IslandString): DelphiUnicodeString;
    begin
      aString:ToDelphiUnicodeString;
    end;

    operator Explicit(aString: IslandString): DelphiWideString;
    begin
      aString:ToDelphiAnsiString;
    end;

    operator Explicit(aString: IslandString): DelphiAnsiString;
    begin
      result := aString:ToDelphiWideString;
    end;

    operator Explicit(aString: IslandString): DelphiShortString;
    begin
      result := aString:ToDelphiShortString;
    end;

    //

    operator Explicit(aString: DelphiUnicodeString): IslandString;
    begin
      result := IslandString:FromPChar(aString);
    end;

    operator Explicit(aString: DelphiWideString): IslandString;
    begin
      result := IslandString:FromPChar(aString);
    end;

    operator Explicit(aString: DelphiAnsiString): IslandString;
    begin
      result := IslandString:FromPAnsiChars(aString);
    end;

    operator Explicit(aString: DelphiShortString): IslandString;
    begin
      if aString[0] > #0 then
        result := IslandString:FromPAnsiChars(@(aString[1]));
    end;

    //

    method ToDelphiUnicodeString: DelphiUnicodeString; inline;
    begin
      result := DelphiStringHelpers.DelphiUnicodeStringWithChars(FirstChar, Length);
    end;

    method ToDelphiWideString: DelphiUnicodeString; inline;
    begin
      result := DelphiStringHelpers.ToDelphiWideStringWithChars(FirstChar, Length);
    end;

    method ToDelphiAnsiString: DelphiAnsiString; inline;
    begin
      var lChars := ToAnsiChars(); // ToDo: this extra copy could be optimized with a TPAnsiChar on String?
      result := DelphiStringHelpers.DelphiAnsiStringWithChars(@lChars[0], Length);
    end;

    method ToDelphiShortString: DelphiShortString; inline;
    begin
      var lChars := ToAnsiChars(); // ToDo: this extra copy could be optimized with a TPAnsiChar on String?
      result := DelphiStringHelpers.DelphiShortStringWithChars(@lChars[0], Length);
    end;


  end;

end.