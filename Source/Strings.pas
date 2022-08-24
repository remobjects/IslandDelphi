namespace RemObjects.Elements.System;

type
  DelphiUnicodeString = public type ^Char;
  DelphiWideString = public type ^Char;
  DelphiAnsiString = public type ^AnsiChar;
  DelphiShortString = public Delphi.System.ShortString;

  //{$IF ANSI_STRING}
  //[assembly:DefaultTypeOverride("String", "Delphi", typeOf(RemObjects.Elements.System.DelphiAnsiString))]
  //{$ELSE}
  //[assembly:DefaultTypeOverride("String", "Delphi", typeOf(RemObjects.Elements.System.DelphiUnicodeString))]
  //{$ENDIF}

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
      var lSize := aLength*sizeOf(Char);
      var lResult: ^DelphiLongStringRecord := malloc(lSize+sizeOf(DelphiLongStringRecord)+sizeOf(Char));
      lResult.CodePage := 0; // ToDo
      lResult.ElementSize := sizeOf(Char);
      lResult.ReferenceCount := 1;
      lResult.Length := aLength;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aChars, lSize);
      ^Char(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
    end;

    class method DelphiAnsiStringWithChars(aChars: ^AnsiChar; aLength: UInt32): DelphiAnsiString;
    begin
      if aLength = 0 then
        exit nil;
      var lSize := aLength*sizeOf(AnsiChar);
      var lResult: ^DelphiLongStringRecord := malloc(lSize+sizeOf(DelphiLongStringRecord)+sizeOf(AnsiChar));
      lResult.CodePage := 0; // ToDo
      lResult.ElementSize := sizeOf(AnsiChar);
      lResult.ReferenceCount := 1;
      lResult.Length := aLength;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aChars, lSize);
      ^AnsiChar(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
    end;

    class method ToDelphiWideStringWithChars(aChars: ^Char; aLength: UInt32): DelphiUnicodeString;
    begin
      if aLength = 0 then
        exit nil;
      var lSize := aLength*sizeOf(Char);
      var lResult := malloc(aLength+sizeOf(UInt32)+sizeOf(Char));
      memcpy(lResult+sizeOf(UInt32), aChars, lSize);
      ^UInt32(lResult)^ := aLength;
      ^Char(lResult+sizeOf(UInt32)+lSize)^ := #0;
    end;

    class method DelphiShortStringWithChars(aChars: ^AnsiChar; aLength: UInt32): Delphi.System.ShortString;
    begin
      if aLength > 255 then
        raise new ArgumentException("Cannot represent string longer than 255 characters as DelphiShortString");
      result[0] := AnsiChar(Byte(aLength and $ff));
      if aLength > 0 then
        memcpy(@(result[1]), aChars, aLength);
    end;

    //

    class method DelphiStringLength(aString: DelphiUnicodeString): Integer;
    begin
      if assigned(aString) then
        result := ^UInt32(aString-sizeOf(UInt32))^;
    end;

    class method DelphiStringLength(aString: DelphiAnsiString): Integer;
    begin
      if assigned(aString) then
        result := ^UInt32(aString-sizeOf(UInt32))^;
    end;

    class method DelphiStringLength(aString: DelphiWideString): Integer;
    begin
      if assigned(aString) then
        result := ^UInt32(aString-sizeOf(UInt32))^;
    end;

    class method DelphiStringLength(aString: DelphiShortString): Integer;
    begin
      result := ord(aString[0]);
    end;

    //

    class method CopyDelphiUnicodeString(aString: DelphiUnicodeString): DelphiUnicodeString; inline;
    begin
      result := DoCopyDelphiLongString(aString);
    end;

    class method CopyDelphiAnsiString(aString: DelphiAnsiString): DelphiAnsiString; inline;
    begin
      result := DoCopyDelphiLongString(aString);
    end;

    class method DoCopyDelphiLongString(aString: ^Void): ^Void; private;
    begin
      if not assigned(aString) then
        exit nil;
      var lOriginal: ^DelphiLongStringRecord := aString-sizeOf(DelphiLongStringRecord);
      var lSize := lOriginal.Length+lOriginal.ElementSize;
      var lResult: ^DelphiLongStringRecord := malloc(lOriginal.Length*lOriginal.ElementSize + sizeOf(DelphiLongStringRecord) + sizeOf(Char));
      lResult.CodePage := lOriginal.CodePage;
      lResult.ElementSize := lOriginal.ElementSize;
      lResult.ReferenceCount := 1;
      lResult.Length := lOriginal.Length;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aString, lSize);
      ^Char(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
    end;

    //

    class method CopyOnWriteDelphiUnicodeString(var aString: DelphiUnicodeString): Boolean; inline;
    begin
      var p: ^Void := aString;
      result := DoCopyOnWriteDelphiString(var p);
      aString := p;
    end;

    class method CopyOnWriteDelphiAnsiString(var aString: DelphiAnsiString): Boolean; inline;
    begin
      var p: ^Void := aString;
      result := DoCopyOnWriteDelphiString(var p);
      aString := p;
    end;

    class method DoCopyOnWriteDelphiString(var aString: ^Void): ^Void; private;
    begin
      if not assigned(aString) then
        exit false;
      var lOriginal: ^DelphiLongStringRecord := aString-sizeOf(DelphiLongStringRecord);
      if lOriginal.ReferenceCount < 2 then
        exit false;
      aString := DoCopyDelphiLongString(aString);
      dec(lOriginal.ReferenceCount);
    end;

    //

    class method AdjustDelphiUnicodeStringReferenceCount(aString: DelphiUnicodeString; aBy: Integer); inline;
    begin
      DoAdjustReferenceCount(aString, aBy);
    end;

    class method AdjustDelphiAnsiStringReferenceCount(aString: DelphiAnsiString; aBy: Integer); inline;
    begin
      DoAdjustReferenceCount(aString, aBy);
    end;

    class method DoAdjustReferenceCount(aString: ^Void; aBy: Integer); private;
    begin
      if not assigned(aString) then
        exit;
      var lOriginal: ^DelphiLongStringRecord := aString-sizeOf(DelphiLongStringRecord);
      inc(lOriginal.ReferenceCount, aBy);
    end;

  end;

end.