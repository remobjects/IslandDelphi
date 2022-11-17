namespace RemObjects.Elements.System;

type
  DelphiShortString = public Delphi.System.ShortString;
  //DelphiOpenString = public Delphi.System.Openstring;

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

    operator Implicit(aString: DelphiShortString): IslandString;
    begin
      if aString[0] > #0 then {$HINT Should use code page?}
        result := IslandString:FromPAnsiChar(@(aString/*.fStringData*/[1]), ord(aString[0]))
      else
        result := ""; // short strings are always assigned, so we won't return nil
    end;

    operator Explicit(aString: IslandString): DelphiShortString;
    begin
      if aString.Length > 255 then
        raise new InvalidCastException("Cannot represent string longer than 255 characters as DelphiShortString");
      var lChars := aString.ToAnsiChars(); {$HINT Review, this is lossy}
      result := DelphiStringHelpers.DelphiShortStringWithChars(@lChars[0], aString.Length);
    end;

    {$IF DARWIN}
    operator Explicit(aString: DelphiShortString): CocoaString;
    begin
      if aString[0] > #0 then {$HINT Should use code page?}
        result := new CocoaString withBytes(@(aString[1])) length(DelphiStringHelpers.DelphiStringLength(aString)) encoding(Foundation.NSStringEncoding.UTF8StringEncoding)
      else
        result := ""; // short strings are always assigned, so we won't return nil
    end;

    //operator Explicit(aString: CocoaString): DelphiShortString;
    //begin
      //if aString:length > 255 then
        //raise new InvalidCastException("Cannot represent string longer than 255 characters as DelphiShortString");
      //{$HINT Review, this is lossy}
    //end;

    operator Implicit(aString: DelphiShortString): CocoaObject;
    begin
      result := aString as CocoaString;
    end;
    {$ENDIF}

    operator Implicit(aString: ^AnsiChar): DelphiShortString;
    begin
      if not assigned(aString) then
        exit;
      var lLength := PAnsiCharLen(aString);
      if lLength > 255 then
        raise new InvalidCastException("Cannot represent string longer than 255 characters as DelphiShortString");
      if lLength > 0 then
        result := DelphiStringHelpers.DelphiShortStringWithChars(aString, lLength);
    end;

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