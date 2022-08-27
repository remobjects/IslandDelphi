namespace RemObjects.Elements.System;

type
  IslandString_Extensions = public extension class(IslandString)
  public

    method ToDelphiUnicodeString: DelphiUnicodeString; inline;
    begin
      result := DelphiStringHelpers.DelphiUnicodeStringWithChars(FirstChar, length);
    end;

    method ToDelphiWideString: DelphiWideString; inline;
    begin
      result := DelphiStringHelpers.DelphiWideStringWithChars(FirstChar, length);
    end;

    method ToDelphiAnsiString: DelphiAnsiString; inline;
    begin
      var lChars := ToAnsiChars(); // ToDo: this extra copy could be optimized with a TPAnsiChar on String?
      result := DelphiStringHelpers.DelphiAnsiStringWithChars(@lChars[0], length);
    end;

    method ToDelphiShortString: DelphiShortString; inline;
    begin
      var lChars := ToAnsiChars(); // ToDo: this extra copy could be optimized with a TPAnsiChar on String?
      result := DelphiStringHelpers.DelphiShortStringWithChars(@lChars[0], length);
    end;

  end;

end.