namespace RemObjects.Elements.System;

type
  DelphiUnicodeString = public type ^Char;
  DelphiWideString = public type ^Char;
  DelphiAnsiString = public type ^AnsiChar;
  DelphiShortString = public Delphi.System.ShortString;

  {$HIDE H6}
  {$HIDE H7}
  [Packed]
  DelphiLongStringRecord = record
    CodePage: UInt16;
    ElementSize: UInt16;
    ReferenceCount: UInt32;
    Length: UInt32;
    StringData: array[0..0] of Byte;
  end;

  [Packed]
  DelphiWideStringRecord = record
    Length: UInt32;
    StringData: array[0..0] of Byte;
  end;

  DelphiStringHelpers = public class
  public

    class method DelphiUnicodeStringWithChars(aChars: ^Char; aLength: UInt32): DelphiUnicodeString;
    begin
      if aLength = 0 then
        exit nil;
      var lResult: ^DelphiLongStringRecord := malloc(aLength+sizeOf(DelphiLongStringRecord)+sizeOf(Char));
      lResult.CodePage := 0; // ToDo
      lResult.ElementSize := sizeOf(Char);
      lResult.ReferenceCount := 1;
      lResult.Length := aLength;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aChars, aLength);
      ^Char(lResult+sizeOf(DelphiLongStringRecord)+aLength)^ := #0;
    end;

    class method DelphiAnsiStringWithChars(aChars: ^AnsiChar; aLength: UInt32): DelphiAnsiString;
    begin
      if aLength = 0 then
        exit nil;
      var lResult: ^DelphiLongStringRecord := malloc(aLength+sizeOf(DelphiLongStringRecord)+sizeOf(AnsiChar));
      lResult.CodePage := 0; // ToDo
      lResult.ElementSize := sizeOf(AnsiChar);
      lResult.ReferenceCount := 1;
      lResult.Length := aLength;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aChars, aLength);
      ^AnsiChar(lResult+sizeOf(DelphiLongStringRecord)+aLength)^ := #0;
    end;

    class method ToDelphiWideStringWithChars(aChars: ^Char; aLength: UInt32): DelphiUnicodeString;
    begin
      if aLength = 0 then
        exit nil;
      var lResult := malloc(aLength+sizeOf(UInt32)+sizeOf(Char));
      memcpy(lResult+sizeOf(UInt32), aChars, aLength);
      ^UInt32(lResult)^ := aLength;
      ^Char(lResult+sizeOf(UInt32)+aLength)^ := #0;
    end;

    class method DelphiShortStringWithChars(aChars: ^AnsiChar; aLength: UInt32): Delphi.System.ShortString;
    begin
      if aLength > 255 then
        raise new ArgumentException("Cannot represent string longer than 255 characters as DelphiShortString");
      result[0] := AnsiChar(Byte(aLength and $ff));
      if aLength > 0 then
        memcpy(@(result[1]), aChars, aLength);
    end;

  end;

end.