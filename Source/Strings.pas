namespace RemObjects.Elements.System;

type
  //{$IF ANSI_STRING}
  //[assembly:DefaultTypeOverride("String", "Delphi", typeOf(RemObjects.Elements.System.DelphiAnsiString))]
  //{$ELSE}
  //[assembly:DefaultTypeOverride("String", "Delphi", typeOf(RemObjects.Elements.System.DelphiUnicodeString))]
  //{$ENDIF}

  DelphiShortString = public Delphi.System.ShortString;

  DelphiShortString_Extension = public extension class(DelphiShortString)
  public

    property Length: Integer read DelphiStringHelpers.DelphiStringLength(self);

    property Chars[aIndex: Integer]: AnsiChar
      read begin
        CheckIndex(aIndex);
        result := self[aIndex];
      end
      write begin
        CheckIndex(aIndex);
        //DelphiStringHelpers.CopyOnWriteDelphiAnsiString(var self);
        self[aIndex] := value;
      end; default;

    //
    // Operators
    //

    operator Explicit(aString: DelphiShortString): IslandString;
    begin
      if aString[0] > #0 then
        result := IslandString:FromPAnsiChar(@(aString[1]))
      else
        result := ""; // short strings are always assigned, so we won't return nil
    end;

    operator Explicit(aString: IslandString): DelphiShortString;
    begin
      if aString.Length > 255 then
        raise new InvalidCastException("Cannot represent string longer than 255 characters as DelphiShortString");
      result := aString:ToDelphiShortString;
    end;

    {$IF DARWIN}
    operator Explicit(aString: DelphiShortString): CocoaString;
    begin
      if aString[0] > #0 then
        result := new CocoaString withBytes(@(aString[1])) length(DelphiStringHelpers.DelphiStringLength(aString)) encoding(Foundation.NSStringEncoding.UTF8StringEncoding)
      else
        result := ""; // short strings are always assigned, so we won't return nil
    end;

    operator Explicit(aString: CocoaString): DelphiShortString;
    begin
      if aString:length > 255 then
        raise new InvalidCastException("Cannot represent string longer than 255 characters as DelphiShortString");
      result := aString:ToDelphiShortString;
    end;
    {$ENDIF}

    //[ToString]
    //method ToString: IslandString; override;
    //begin
      //result := self as IslandString;
    //end;

  private

    method CheckIndex(aIndex: Integer);
    begin
      if (aIndex < 0) or (aIndex > Length) then
        raise new IndexOutOfRangeException($"Index {aIndex} is out of valid bounds (0..{Length}).");
    end;

  end;

end.