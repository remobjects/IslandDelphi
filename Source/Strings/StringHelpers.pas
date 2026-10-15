namespace RemObjects.Elements.System;

type
  {$IF CLASSIC}
  VoidFunction = assembly procedure;
  LStrSetLengthFunction = assembly procedure(var aString: DelphiAnsiString; aNewLength: Integer; CodePage: UInt16);
  LStrCopyFunction = assembly method(S: RemObjects.Elements.System.DelphiAnsiString; &Index: Integer; Count: Integer): RemObjects.Elements.System.DelphiAnsiString;
  CopyFunction = assembly method(S: array[0..255] of AnsiChar; &Index: Integer; Count: Integer): array[0..255] of AnsiChar;
  {$ENDIF}

  {$HIDE H6}
  {$HIDE H7}
  [Packed]
  DelphiLongStringRecord = assembly record
    // Delphi System.StrRec has a 12-byte header on 32-bit targets; the
    // CPU64BITS padding makes it 16 bytes on 64-bit targets.
    {$IF CPU64}
    Padding: UInt32;
    {$ENDIF}
    CodePage: UInt16;
    ElementSize: UInt16;
    ReferenceCount: Int32;
    Length: UInt32;
  end;

  DelphiStringHelpers = assembly static class
  public

    // Share this allocator: POSIX WideString uses UnicodeString storage.
    // Delphi 12/13 System._NewWideString calls _NewUnicodeString there,
    // so both need the full UTF-16 header and a two-byte zero terminator.
    method AllocateDelphiUnicodeCharacters(aLength: UInt32): ^Char;
    begin
      if aLength = 0 then
        exit nil;
      var lSize := aLength*sizeOf(Char);
      var lResult := DelphiMemoryHelpers.GetMem(lSize+sizeOf(DelphiLongStringRecord)+sizeOf(Char));
      ^DelphiLongStringRecord(lResult).CodePage := 1200;
      ^DelphiLongStringRecord(lResult).ElementSize := sizeOf(Char);
      ^DelphiLongStringRecord(lResult).ReferenceCount := 1;
      ^DelphiLongStringRecord(lResult).Length := aLength;
      ^Char(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
      result := lResult+sizeOf(DelphiLongStringRecord);
    end;

    {$IF NOT ANSI_STRING}
    method DelphiUnicodeStringWithChars(aChars: ^Char; aLength: UInt32): DelphiUnicodeString;
    begin
      if aLength = 0 then
        exit new DelphiUnicodeString;
      var lResult := AllocateDelphiUnicodeCharacters(aLength);
      memcpy(lResult, aChars, aLength*sizeOf(Char));
      result := new DelphiUnicodeString(lResult);
    end;
    {$ENDIF}

    method DelphiAnsiStringWithChars(aChars: ^AnsiChar; aLength: UInt32): DelphiAnsiString;
    begin
      if aLength = 0 then
        exit new DelphiAnsiString;
      var lSize := aLength*sizeOf(AnsiChar);
      var lResult := DelphiMemoryHelpers.GetMem(lSize+sizeOf(DelphiLongStringRecord)+sizeOf(AnsiChar));
      ^DelphiLongStringRecord(lResult).CodePage := 0/*:Delphi.System.DefaultSystemCodePage*/;
      ^DelphiLongStringRecord(lResult).ElementSize := sizeOf(AnsiChar);
      ^DelphiLongStringRecord(lResult).ReferenceCount := 1;
      ^DelphiLongStringRecord(lResult).Length := aLength;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aChars, lSize);
      ^AnsiChar(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
      result := new DelphiAnsiString(lResult+sizeOf(DelphiLongStringRecord));
    end;

    method DelphiWideStringWithChars(aChars: ^Char; aLength: UInt32): DelphiWideString;
    begin
      if aLength = 0 then
        exit new DelphiWideString;
      {$IF WINDOWS}
      exit new DelphiWideString(rtl.SysAllocStringLen(aChars, aLength));
      {$ELSE}
      var lResult := AllocateDelphiUnicodeCharacters(aLength);
      memcpy(lResult, aChars, aLength*sizeOf(Char));
      result := new DelphiWideString(lResult);
      {$ENDIF}
    end;

    method DelphiShortStringWithChars(aChars: ^AnsiChar; aLength: UInt32): DelphiShortString;
    begin
      if aLength > 255 then
        raise new ArgumentException("Cannot represent string longer than 255 characters as DelphiShortString");
      result[0] := AnsiChar(Byte(aLength and $ff));
      if aLength > 0 then
        memcpy(@(result[1]), aChars, aLength);
    end;

    //

    {$IF NOT ANSI_STRING}
    method EmptyDelphiUnicodeStringWithCapacity(aLength: UInt32): DelphiUnicodeString;
    begin
      result := new DelphiUnicodeString(AllocateDelphiUnicodeCharacters(aLength));
    end;
    {$ENDIF}

    method EmptyDelphiAnsiStringWithCapacity(aLength: UInt32): DelphiAnsiString;
    begin
      if aLength = 0 then
        exit new DelphiAnsiString;
      var lSize := aLength*sizeOf(AnsiChar);
      var lResult := DelphiMemoryHelpers.GetMem(lSize+sizeOf(DelphiLongStringRecord)+sizeOf(AnsiChar));
      ^DelphiLongStringRecord(lResult).CodePage := 0/*:Delphi.System.DefaultSystemCodePage*/;
      ^DelphiLongStringRecord(lResult).ElementSize := sizeOf(AnsiChar);
      ^DelphiLongStringRecord(lResult).ReferenceCount := 1;
      ^DelphiLongStringRecord(lResult).Length := aLength;
      ^AnsiChar(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
      result := new DelphiAnsiString(lResult+sizeOf(DelphiLongStringRecord));
    end;

    method EmptyDelphiWideStringWithCapacity(aLength: UInt32): DelphiWideString;
    begin
      if aLength = 0 then
        exit new DelphiWideString;
      {$IF WINDOWS}
      exit new DelphiWideString(rtl.SysAllocStringLen(nil, aLength));
      {$ELSE}
      result := new DelphiWideString(AllocateDelphiUnicodeCharacters(aLength));
      {$ENDIF}
    end;

    //

    method DelphiStringLength(aString: ^Void): Integer;
    begin
      if assigned(aString) then
        result := ^UInt32(aString-sizeOf(UInt32))^;
    end;

    method DelphiWideStringLength(aString: ^Void): Integer;
    begin
      if assigned(aString) then begin
        {$IF WINDOWS}
        result := rtl.SysStringLen(^Char(aString));
        {$ELSE}
        result := DelphiStringLength(aString);
        {$ENDIF}
      end;
    end;

    method DelphiWideStringReferenceCount(aString: ^Void): Integer;
    begin
      {$IF WINDOWS}
      // BSTR values are copied rather than reference counted.
      result := if assigned(aString) then 1 else 0;
      {$ELSE}
      result := DelphiStringReferenceCount(aString);
      {$ENDIF}
    end;

    method DelphiStringLength(aString: DelphiShortString): Integer;
    begin
      result := ord(aString[0]);
    end;

    //

    {$IF NOT ANSI_STRING}
    method CopyDelphiUnicodeString(aString: DelphiUnicodeString): DelphiUnicodeString; inline;
    begin
      result := new DelphiUnicodeString(CopyDelphiLongString(aString.fStringData));
    end;
    {$ENDIF}

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
      var lResult := DelphiMemoryHelpers.GetMem(lOriginal.Length*lOriginal.ElementSize + sizeOf(DelphiLongStringRecord) + lOriginal.ElementSize);
      ^DelphiLongStringRecord(lResult).CodePage := lOriginal.CodePage;
      ^DelphiLongStringRecord(lResult).ElementSize := lOriginal.ElementSize;
      ^DelphiLongStringRecord(lResult).ReferenceCount := 1;
      ^DelphiLongStringRecord(lResult).Length := lOriginal.Length;
      memcpy(lResult+sizeOf(DelphiLongStringRecord), aString, lSize);
      case lOriginal.ElementSize of
        1: ^AnsiChar(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
        2: ^Char(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := #0;
        4: ^UInt32(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := 0;
        8: ^UInt32(lResult+sizeOf(DelphiLongStringRecord)+lSize)^ := 0;
        else raise new ArgumentException($"Unexpected Elements size {lOriginal.ElementSize} in DelphiLongString");
      end;
      result := lResult+sizeOf(DelphiLongStringRecord);
    end;

    method CopyDelphiWideString(aString: ^Void): ^Void;
    begin
      if not assigned(aString) then
        exit nil;
      {$IF WINDOWS}
      exit rtl.SysAllocStringLen(^Char(aString), rtl.SysStringLen(^Char(aString)));
      {$ELSE}
      // Delphi System._WStrAddRef uses _UStrAddRef on POSIX: retain the
      // shared UTF-16 data; a later write must first make it unique.
      RetainDelphiLongString(aString);
      result := aString;
      {$ENDIF}
    end;

    //

    {$IF NOT ANSI_STRING}
    method CopyOnWriteDelphiUnicodeString(var aString: DelphiUnicodeString): Boolean; inline;
    begin
      var p: ^Void := aString.fStringData;
      result := CopyOnWriteDelphiString(var p);
      aString.fStringData := p;
    end;
    {$ENDIF}

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
      if lOriginal.ReferenceCount = 1 then
        exit false;
      // Literal headers have refcount -1 and point at read-only data.
      // Copy them on write too, but never change their constant refcount.
      aString := CopyDelphiLongString(aString);
      if lOriginal.ReferenceCount > 0 then
        interlockedDec(var lOriginal.ReferenceCount);
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

    {$IF NOT ANSI_STRING}
    method AdjustDelphiUnicodeStringReferenceCount(aString: DelphiUnicodeString; aBy: Integer): Integer; inline;
    begin
      result := AdjustLongStringReferenceCount(aString.fStringData, aBy);
    end;
    {$ENDIF}

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
      // interlockedInc/interlockedDec lower to atomicrmw and return the previous value,
      // so adjust by the delta here to report the resulting Delphi refcount.
      result := interlockedInc(var lOriginal.ReferenceCount, aBy)+aBy;
    end;

    //

    {$IF NOT ANSI_STRING}
    method RetainDelphiUnicodeString(var aString: DelphiUnicodeString): Integer; inline;
    begin
      result := RetainDelphiLongString(aString.fStringData);
    end;
    {$ENDIF}

    method RetainDelphiAnsiString(var aString: DelphiAnsiString): Integer; inline;
    begin
      result := RetainDelphiLongString(aString.fStringData);
    end;

    method RetainDelphiLongString(aString: ^Void): Integer; inline;
    begin
      result := AdjustLongStringReferenceCount(aString, 1);
    end;

    //

    {$IF NOT ANSI_STRING}
    method ReleaseDelphiUnicodeString(var aString: DelphiUnicodeString): Integer; inline;
    begin
      result := ReleaseDelphiLongString(var aString.fStringData);
    end;
    {$ENDIF}

    method ReleaseDelphiAnsiString(var aString: DelphiAnsiString): Integer; inline;
    begin
      result := ReleaseDelphiLongString(var aString.fStringData);
    end;

    method ReleaseDelphiLongString(var aString: ^Void): Integer;
    begin
      var lString := aString;
      // Release this slot even when another owner or an immortal string remains.
      // Repeated finalization of the cleared slot must not release that owner.
      aString := nil;
      result := AdjustLongStringReferenceCount(lString, -1);
      if result = 0 then
        FreeDelphiLongString(var lString);
    end;

    //

    method FreeDelphiLongString(var aString: ^Void);
    begin
      if not assigned(aString) then
        exit;
      var lOriginal := aString-sizeOf(DelphiLongStringRecord);
      DelphiMemoryHelpers.FreeMem(lOriginal);
      if defined("DELPHI_DEBUG_STRING_ARC") then
        writeLn($"| was freed {IntPtr(aString)}");
      aString := nil;
    end;

    method FreeDelphiWideString(var aString: ^Void);
    begin
      if not assigned(aString) then
        exit;
      {$IF WINDOWS}
      rtl.SysFreeString(^Char(aString));
      {$ELSE}
      // Delphi System._WStrClr uses _UStrClr on POSIX. Other values may
      // still share this data, so only free the last owned reference.
      ReleaseDelphiLongString(var aString);
      {$ENDIF}
      if defined("DELPHI_DEBUG_STRING_ARC") then
        writeLn($"| was freed {IntPtr(aString)}");
      aString := nil;
    end;

  end;

end.