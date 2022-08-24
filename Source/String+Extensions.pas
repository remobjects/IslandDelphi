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

  {$IF DARWIN}
  CocoaString_Extension = public extension class(CocoaString)

    operator Explicit(aString: CocoaString): DelphiUnicodeString;
    begin
      aString:ToDelphiUnicodeString;
    end;

    operator Explicit(aString: CocoaString): DelphiWideString;
    begin
      aString:ToDelphiAnsiString;
    end;

    operator Explicit(aString: CocoaString): DelphiAnsiString;
    begin
      result := aString:ToDelphiWideString;
    end;

    operator Explicit(aString: CocoaString): DelphiShortString;
    begin
      result := aString:ToDelphiShortString;
    end;

    //operator Explicit(aString: DelphiUnicodeString): CocoaString;
    //begin
      //result := new CocoaString withBytes(aString) length(DelphiStringHelpers.DelphiStringLength(aString)) encoding(Foundation.NSStringEncoding.UTF16LittleEndianStringEncoding);
    //end;

    operator Explicit(aString: DelphiWideString): CocoaString;
    begin
      result := new CocoaString withBytes(aString) length(DelphiStringHelpers.DelphiStringLength(aString)) encoding(Foundation.NSStringEncoding.UTF16LittleEndianStringEncoding);
    end;

    operator Explicit(aString: DelphiAnsiString): CocoaString;
    begin
      result := new CocoaString withBytes(aString) length(DelphiStringHelpers.DelphiStringLength(aString)) encoding(Foundation.NSStringEncoding.UTF8StringEncoding);
    end;

    operator Explicit(aString: DelphiShortString): CocoaString;
    begin
      if aString[0] > #0 then
        result := new CocoaString withBytes(@(aString[1])) length(DelphiStringHelpers.DelphiStringLength(aString)) encoding(Foundation.NSStringEncoding.UTF8StringEncoding);
    end;

  end;
  {$ENDIF}

end.