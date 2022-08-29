namespace RemObjects.Elements.System;

type
  {$HIDE H6}
  {$HIDE H7}
  [Packed]
  DelphiLongStringRecord = assembly record
    CodePage: UInt16;
    ElementSize: UInt16;
    ReferenceCount: UInt32;
    Length: UInt32;
  end;

  [Packed]
  DelphiWideStringRecord = assembly record
    Length: UInt32;
  end;

  DelphiStringHelpers = public static class
  public

    method DelphiUnicodeStringWithChars(aChars: ^Char; aLength: UInt32): DelphiUnicodeString;
    begin
      if aLength = 0 then
        exit new DelphiUnicodeString;
      var lSize := aLength*sizeOf(Char);
      var lResult := DelphiMemoryHelpers.GetMem(lSize+sizeOf(DelphiLongStringRecord)+sizeOf(Char));
      ^DelphiLongStringRecord(lResult).CodePage := 0; // ToDo
      ^DelphiLongStringRecord(lResult).ElementSize := sizeOf(Char);
      ^DelphiLongStringRecord(lResult).ReferenceCount := 0;//1;
      ^DelphiLongStringRecord(lResult).Length := aLength;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aChars, lSize);
      ^Char(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
      result := new DelphiUnicodeString(lResult+sizeOf(DelphiLongStringRecord));
    end;

    method DelphiAnsiStringWithChars(aChars: ^AnsiChar; aLength: UInt32): DelphiAnsiString;
    begin
      if aLength = 0 then
        exit new DelphiAnsiString;
      var lSize := aLength*sizeOf(AnsiChar);
      var lResult := DelphiMemoryHelpers.GetMem(lSize+sizeOf(DelphiLongStringRecord)+sizeOf(AnsiChar));
      ^DelphiLongStringRecord(lResult).CodePage := 0; // ToDo
      ^DelphiLongStringRecord(lResult).ElementSize := sizeOf(AnsiChar);
      ^DelphiLongStringRecord(lResult).ReferenceCount := 0;//1;
      ^DelphiLongStringRecord(lResult).Length := aLength;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aChars, lSize);
      ^AnsiChar(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
      result := new DelphiAnsiString(lResult+sizeOf(DelphiLongStringRecord));
    end;

    method DelphiWideStringWithChars(aChars: ^Char; aLength: UInt32): DelphiWideString;
    begin
      if aLength = 0 then
        exit new DelphiWideString;
      var lSize := aLength*sizeOf(Char);
      var lResult := DelphiMemoryHelpers.GetMem(aLength+sizeOf(UInt32)+sizeOf(Char));
      memcpy(lResult+sizeOf(UInt32), aChars, lSize);
      ^UInt32(lResult)^ := aLength;
      ^Char(lResult+sizeOf(UInt32)+lSize)^ := #0;
      result := new DelphiWideString(lResult+sizeOf(DelphiWideStringRecord));
    end;

    method DelphiShortStringWithChars(aChars: ^AnsiChar; aLength: UInt32): Delphi.System.ShortString;
    begin
      if aLength > 255 then
        raise new ArgumentException("Cannot represent string longer than 255 characters as DelphiShortString");
      result[0] := AnsiChar(Byte(aLength and $ff));
      if aLength > 0 then
        memcpy(@(result[1]), aChars, aLength);
    end;

    //

    method DelphiStringLength(aString: ^Void): Integer;
    begin
      if assigned(aString) then
        result := ^UInt32(aString-sizeOf(UInt32))^;
    end;

    method DelphiStringLength(aString: DelphiShortString): Integer;
    begin
      result := ord(aString[0]);
    end;

    //

    method CopyDelphiUnicodeString(aString: DelphiUnicodeString): DelphiUnicodeString; inline;
    begin
      result := new DelphiUnicodeString(CopyDelphiLongString(aString.fStringData));
    end;

    method CopyDelphiAnsiString(aString: DelphiAnsiString): DelphiAnsiString; inline;
    begin
      result := new DelphiAnsiString(CopyDelphiLongString(aString.fStringData));
    end;

    method CopyDelphiLongString(aString: ^Void): ^Void;
    begin
      if not assigned(aString) then
        exit nil;
      var lOriginal: ^DelphiLongStringRecord := aString-sizeOf(DelphiLongStringRecord);
      var lSize := lOriginal.Length*lOriginal.ElementSize;
      var lResult := DelphiMemoryHelpers.GetMem(lOriginal.Length*lOriginal.ElementSize + sizeOf(DelphiLongStringRecord) + sizeOf(Char));
      ^DelphiLongStringRecord(lResult).CodePage := lOriginal.CodePage;
      ^DelphiLongStringRecord(lResult).ElementSize := lOriginal.ElementSize;
      ^DelphiLongStringRecord(lResult).ReferenceCount := 0;//1
      ^DelphiLongStringRecord(lResult).Length := lOriginal.Length;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aString, lSize);
      ^Char(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
      result := lResult+sizeOf(DelphiLongStringRecord);
    end;

    //

    method CopyOnWriteDelphiUnicodeString(var aString: DelphiUnicodeString): Boolean;// inline;
    begin
      var p: ^Void := aString.fStringData;
      result := CopyOnWriteDelphiString(var p);
      aString.fStringData := p;
    end;

    method CopyOnWriteDelphiAnsiString(var aString: DelphiAnsiString): Boolean; inline;
    begin
      var p: ^Void := aString.fStringData;
      result := CopyOnWriteDelphiString(var p);
      aString.fStringData := p;
    end;

    method CopyOnWriteDelphiString(var aString: ^Void): Boolean;
    begin
      if not assigned(aString) then
        exit false;
      var lOriginal: ^DelphiLongStringRecord := aString-sizeOf(DelphiLongStringRecord);
      if lOriginal.ReferenceCount < 2 then
        exit false;
      aString := CopyDelphiLongString(aString);
      //dec(lOriginal.ReferenceCount);
      lOriginal.ReferenceCount := lOriginal.ReferenceCount-1;
      result := true;
    end;

    //

    method DelphiStringCodePage(aString: ^Void): UInt16;
    begin
      if not assigned(aString) then
        exit 0;
      var lOriginal: ^DelphiLongStringRecord := aString-sizeOf(DelphiLongStringRecord);
      result := lOriginal.CodePage;
    end;

    //

    method DelphiStringReferenceCount(aString: ^Void): Integer;
    begin
      if not assigned(aString) then
        exit 0;
      var lOriginal: ^DelphiLongStringRecord := aString-sizeOf(DelphiLongStringRecord);
      result := lOriginal.ReferenceCount;
    end;

    method AdjustDelphiUnicodeStringReferenceCount(aString: DelphiUnicodeString; aBy: Integer): Integer; inline;
    begin
      result := AdjustLongStringReferenceCount(aString.fStringData, aBy);
    end;

    method AdjustDelphiAnsiStringReferenceCount(aString: DelphiAnsiString; aBy: Integer): Integer; inline;
    begin
      result := AdjustLongStringReferenceCount(aString.fStringData, aBy);
    end;

    method AdjustLongStringReferenceCount(aString: ^Void; aBy: Integer): Integer;
    begin
      if not assigned(aString) then
        exit;
      var lOriginal: ^DelphiLongStringRecord := aString-sizeOf(DelphiLongStringRecord);
      if lOriginal.ReferenceCount = -1 then
        exit -1;
      //inc(lOriginal.ReferenceCount, aBy);
      lOriginal.ReferenceCount := lOriginal.ReferenceCount+aBy;
      result := lOriginal.ReferenceCount;
    end;

    method RetainDelphiLongString(aString: ^Void): Integer;
    begin
      result := AdjustLongStringReferenceCount(aString, 1);
    end;

    method ReleaseDelphiLongString(aString: ^Void): Integer;
    begin
      result := AdjustLongStringReferenceCount(aString, -1);
      if result = 0 then
        FreeDelphiLongString(aString);
    end;

    //

    method FreeDelphiLongString(aString: ^Void);
    begin
      if not assigned(aString) then
        exit;
      var lOriginal := aString-sizeOf(DelphiLongStringRecord);
      DelphiMemoryHelpers.FreeMem(lOriginal);
    end;

    method FreeDelphiWideString(aString: ^Void);
    begin
      if not assigned(aString) then
        exit;
      var lOriginal := aString-sizeOf(DelphiWideStringRecord);
      DelphiMemoryHelpers.FreeMem(lOriginal);
    end;

  end;

end.