namespace RemObjects.Elements.System;

type
  [Packed]
  DelphiAnsiString = public record(sequence of AnsiChar)
  assembly
    fStringData: ^AnsiChar;

  public

    property Count: Integer read DelphiStringHelpers.DelphiStringLength(fStringData);
    property Length: Integer read DelphiStringHelpers.DelphiStringLength(fStringData);
    property ReferenceCount: Integer read DelphiStringHelpers.DelphiStringReferenceCount(fStringData);
    property CodePage: UInt16 read DelphiStringHelpers.DelphiStringCodePage(fStringData);

    property Chars[aIndex: Integer]: AnsiChar
      read begin
        CheckIndex(aIndex);
        result := (fStringData+aIndex-1)^;
      end
      write begin
        CheckIndex(aIndex);
        if (fStringData+aIndex-1)^ ≠ value then begin
          DelphiStringHelpers.CopyOnWriteDelphiAnsiString(var self);
          (fStringData+aIndex-1)^ := value;
        end;
      end; default;

    property Chars[aIndex: &Index]: AnsiChar read Chars[aIndex.GetOffset(Length)] write Chars[aIndex.GetOffset(Length)];

    [&Sequence]
    method GetSequence: sequence of AnsiChar; iterator;
    begin
      for i := 0 to DelphiStringHelpers.DelphiStringLength(fStringData)-1 do
        yield (fStringData+i)^;
    end;

    //
    // Operators
    //

    operator Implicit(aString: InstanceType): IslandString;
    begin
      result := IslandString:FromPAnsiChar(aString.fStringData, aString.Length); {$HINT Should use code page?}
    end;

    operator Implicit(aString: InstanceType): IslandObject;
    begin
      result := IslandString:FromPAnsiChar(aString.fStringData, aString.Length); {$HINT Should use code page?}
    end;

    operator Explicit(aString: IslandString): InstanceType;
    begin
      var lChars := aString.ToAnsiChars(); {$HINT Review, this is lossy} {$HINT Can be Optimized with a ToPAnsiChar on String?}
      result := DelphiStringHelpers.DelphiAnsiStringWithChars(@lChars[0], aString.Length);
    end;

    operator Implicit(aChar: AnsiChar): InstanceType;
    begin
      result := DelphiStringHelpers.DelphiAnsiStringWithChars(@aChar, 1);
    end;

    // PChar

    operator Implicit(aString: ^AnsiChar): InstanceType;
    begin
      if assigned(aString) then
        result := DelphiStringHelpers.DelphiAnsiStringWithChars(aString, PAnsiCharLen(aString));
    end;

    operator Explicit(aString: InstanceType): ^AnsiChar;
    begin
      result := aString.fStringData;
    end;

    operator Explicit(aString: InstanceType): ^Void;
    begin
      result := aString.fStringData;
    end;

    // UnicodeString

    operator Explicit(aString: InstanceType): DelphiUnicodeString;
    begin
      result := IslandString:FromPAnsiChar(aString.fStringData, aString.Length) as DelphiUnicodeString; {$HINT Can be Optimized}
    end;

    operator Explicit(aString: DelphiUnicodeString): InstanceType;
    begin
      var lChars := (aString as IslandString).ToAnsiChars(); {$HINT Can be Optimized}{$HINT Review, this is lossy}
      result := DelphiStringHelpers.DelphiAnsiStringWithChars(@lChars[0], aString.Length);
    end;

    // WideString

    operator Explicit(aString: InstanceType): DelphiWideString;
    begin
      result := IslandString:FromPAnsiChar(aString.fStringData, aString.Length) as DelphiWideString; {$HINT Can be Optimized}
    end;

    operator Explicit(aString: DelphiWideString): InstanceType;
    begin
      var lChars := (aString as IslandString).ToAnsiChars(); {$HINT Can be Optimized}{$HINT Review, this is lossy}
      result := DelphiStringHelpers.DelphiAnsiStringWithChars(@lChars[0], aString.Length);
    end;

     // ShortString

    operator Implicit(aString: DelphiShortString): InstanceType;
    begin
      if aString[0] > #0 then
        result := DelphiStringHelpers.DelphiAnsiStringWithChars(@aString[1], ord(aString[0]));
    end;

    operator Explicit(aString: InstanceType): DelphiShortString;
    begin
      if aString.Length > 255 then
        raise new InvalidCastException("Cannot represent string longer than 255 characters as DelphiShortString");
      result := DelphiStringHelpers.DelphiShortStringWithChars(aString.fStringData, aString.Length);
    end;

    // NSString

    {$IF DARWIN}
    operator Implicit(aString: InstanceType): CocoaString;
    begin
      result := new CocoaString withBytes(aString.fStringData) length(DelphiStringHelpers.DelphiStringLength(aString.fStringData)) encoding(Foundation.NSStringEncoding.UTF16LittleEndianStringEncoding);
    end;

    //operator Explicit(aString: CocoaString): InstanceType;
    //begin
      // {$HINT Review, this is lossy}
    //end;

    operator Implicit(aString: InstanceType): CocoaObject;
    begin
      result := aString as CocoaString;
    end;
    {$ENDIF}

    // Concat

    operator &Add(aLeft: InstanceType; aRight: InstanceType): InstanceType;
    begin
      result := DelphiStringHelpers.EmptyDelphiAnsiStringWithCapacity(aLeft.Length+aRight.Length);
      memcpy(result.fStringData,              aLeft.fStringData,  aLeft.Length*sizeOf(AnsiChar));
      memcpy(result.fStringData+aLeft.Length, aRight.fStringData, aRight.Length*sizeOf(AnsiChar));
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    // DelphiObject

    operator &Add(aLeft: DelphiObject; aRight: InstanceType): InstanceType;
    begin
      result := (aLeft.ToString as DelphiAnsiString) + aRight; {$HINT Review, this is lossy}
    end;

    operator &Add(aLeft: InstanceType; aRight: DelphiObject): InstanceType;
    begin
      result := aLeft + (aRight.ToString as DelphiAnsiString); {$HINT Review, this is lossy}
    end;

    // IslandObject

    operator &Add(aLeft: IslandObject; aRight: InstanceType): InstanceType;
    begin
      result := (aLeft.ToString as DelphiAnsiString) + aRight; {$HINT Review, this is lossy}
    end;

    operator &Add(aLeft: InstanceType; aRight: IslandObject): InstanceType;
    begin
      result := aLeft + (aRight.ToString as DelphiAnsiString); {$HINT Review, this is lossy}
    end;

    // CocoaObject

    {$IF DARWIN}
    operator &Add(aLeft: CocoaObject; aRight: InstanceType): InstanceType;
    begin
      result := (aLeft.description as DelphiAnsiString) + aRight; {$HINT Review, this is lossy}
    end;

    operator &Add(aLeft: InstanceType; aRight: CocoaObject): InstanceType;
    begin
      result := aLeft + (aRight.description as DelphiAnsiString); {$HINT Review, this is lossy}
    end;
    {$ENDIF}

    [ToString]
    method ToString: IslandString;
    begin
      result := self as IslandString;
    end;

  assembly

    constructor; empty;

    constructor(aStringData: ^Void);
    begin
      fStringData := aStringData;
    end;

  private

    method CheckIndex(aIndex: Integer);
    begin
      if (aIndex < 1) or (aIndex > Length) then
        raise new IndexOutOfRangeException($"Index {aIndex} is out of valid bounds (1..{Length}).");
    end;

  public

    // life-time management

    constructor &Copy(var aSource: DelphiAnsiString);
    begin
      if defined("DELPHI_DEBUG_STRING_ARC") then
        writeLn("DelphiAnsiString: Copy ctor");
      if not assigned(aSource.fStringData) then
        exit;
      fStringData := aSource.fStringData;
      DelphiStringHelpers.RetainDelphiLongString(aSource.fStringData);
    end;

    class operator Assign(var aDestination: DelphiAnsiString; var aSource: DelphiAnsiString);
    begin
      if defined("DELPHI_DEBUG_STRING_ARC") then
        writeLn($"DelphiAnsiString: Assign operator {IntPtr(aSource.fStringData)} => {IntPtr(aDestination.fStringData)}");
      if (@aDestination) = (@aSource) then
        exit;
      if aDestination.fStringData = aSource.fStringData then
        exit;
      if assigned(aDestination.fStringData) then
        DelphiStringHelpers.ReleaseDelphiAnsiString(var aDestination);
      aDestination.fStringData := aSource.fStringData;
      DelphiStringHelpers.RetainDelphiLongString(aSource.fStringData);
    end;

    finalizer;
    begin
      if defined("DELPHI_DEBUG_STRING_ARC") then
        writeLn($"DelphiAnsiString: Finalizer {IntPtr(self.fStringData)} '{self}'");
      DelphiStringHelpers.ReleaseDelphiAnsiString(var self);
    end;

  end;

method SetLength(var aString: DelphiAnsiString; aNewLength: Int32); public; inline;
begin
  :Delphi.System.«@LStrSetLength»(var aString, aNewLength, aString.CodePage);
end;

method PAnsiCharLen(aChars: ^AnsiChar): Integer;
begin
  if not assigned(aChars) then
    exit 0;
  result := 0;
  var c := aChars;
  while c^ ≠ #0 do
    inc(c);
  result := c-aChars;
end;

end.