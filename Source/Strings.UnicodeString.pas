namespace RemObjects.Elements.System;

type
  [Packed]
  DelphiUnicodeString = public record
  assembly
    fStringData: ^Char;

  public

    property Length: Integer read DelphiStringHelpers.DelphiStringLength(fStringData);
    property ReferenceCount: Integer read DelphiStringHelpers.DelphiStringReferenceCount(fStringData);

    property Chars[aIndex: Integer]: Char
      read begin
        CheckIndex(aIndex);
        result := (fStringData+aIndex-1)^;
      end
      write begin
        CheckIndex(aIndex);
        if DelphiStringHelpers.CopyOnWriteDelphiUnicodeString(var self) then
          DelphiStringHelpers.AdjustDelphiUnicodeStringReferenceCount(self, 1); // seems hacky top do this here?
        (fStringData+aIndex-1)^ := value;
      end; default;

    //
    // Operators
    //

    operator Explicit(aString: InstanceType): IslandString;
    begin
      result := IslandString:FromPChar(aString.fStringData, aString.Length);
    end;

    operator Implicit(aString: IslandString): InstanceType;
    begin
      result := DelphiStringHelpers.DelphiUnicodeStringWithChars(aString.FirstChar, aString.Length);
    end;

    // PChar

    operator Implicit(aString: ^Char): InstanceType;
    begin
      if assigned(aString) then
        result := DelphiStringHelpers.DelphiUnicodeStringWithChars(aString, PCharLen(aString));
    end;

    // WideString

    operator Explicit(aString: InstanceType): DelphiWideString;
    begin
      result := DelphiStringHelpers.DelphiWideStringWithChars(aString.fStringData, aString.Length);
    end;

    operator Explicit(aString: DelphiWideString): InstanceType;
    begin
      result := DelphiStringHelpers.DelphiUnicodeStringWithChars(aString.fStringData, aString.Length);
    end;

    // NSString

    {$IF DARWIN}
    operator Explicit(aString: InstanceType): CocoaString;
    begin
      result := new CocoaString withBytes(aString.fStringData) length(DelphiStringHelpers.DelphiStringLength(aString.fStringData)) encoding(Foundation.NSStringEncoding.UTF16LittleEndianStringEncoding);
    end;

    operator Explicit(aString: CocoaString): InstanceType;
    begin
      var lLength := aString.length;
      var lBytes := new Char[lLength];
      aString.getCharacters(lBytes);
      result := DelphiStringHelpers.DelphiUnicodeStringWithChars(@(lBytes[0]), lLength);
    end;
    {$ENDIF}

    // Concat

    operator &Add(aLeft: InstanceType; aRight: InstanceType): InstanceType;
    begin
      result := DelphiStringHelpers.EmptyDelphiUnicodeStringWithCapacity(aLeft.Length+aRight.Length);
      memcpy(result.fStringData,              aLeft.fStringData,  aLeft.Length*sizeOf(Char));
      memcpy(result.fStringData+aLeft.Length, aRight.fStringData, aRight.Length*sizeOf(Char));
    end;

    operator &Add(aLeft: InstanceType; aRight: DelphiWideString): InstanceType;
    begin
      result := DelphiStringHelpers.EmptyDelphiUnicodeStringWithCapacity(aLeft.Length+aRight.Length);
      memcpy(result.fStringData,              aLeft.fStringData,  aLeft.Length*sizeOf(Char));
      memcpy(result.fStringData+aLeft.Length, aRight.fStringData, aRight.Length*sizeOf(Char));
    end;

    operator &Add(aLeft: DelphiWideString; aRight: InstanceType): InstanceType;
    begin
      result := DelphiStringHelpers.EmptyDelphiUnicodeStringWithCapacity(aLeft.Length+aRight.Length);
      memcpy(result.fStringData,              aLeft.fStringData,  aLeft.Length*sizeOf(Char));
      memcpy(result.fStringData+aLeft.Length, aRight.fStringData, aRight.Length*sizeOf(Char));
    end;

    // DelphiObject

    operator &Add(aLeft: DelphiObject; aRight: InstanceType): InstanceType;
    begin
      result := (aLeft.ToString as DelphiUnicodeString) + aRight;
    end;

    operator &Add(aLeft: InstanceType; aRight: DelphiObject): InstanceType;
    begin
      result := aLeft + (aRight.ToString as DelphiUnicodeString);
    end;

    // IslandObject

    operator &Add(aLeft: IslandObject; aRight: InstanceType): InstanceType;
    begin
      result := (aLeft.ToString as DelphiUnicodeString) + aRight;
    end;

    operator &Add(aLeft: InstanceType; aRight: IslandObject): InstanceType;
    begin
      result := aLeft + (aRight.ToString as DelphiUnicodeString);
    end;

    // CocoaObject

    {$IF DARWIN}
    operator &Add(aLeft: CocoaObject; aRight: InstanceType): InstanceType;
    begin
      var lLeft := aLeft.description;
      var lLength := lLeft.length;
      var lBytes := new Char[lLength];
      lLeft.getCharacters(lBytes);
      result := DelphiStringHelpers.EmptyDelphiUnicodeStringWithCapacity(lLength+aRight.Length);
      memcpy(result.fStringData,         @(lBytes[0]),       lLength*sizeOf(Char));
      memcpy(result.fStringData+lLength, aRight.fStringData, aRight.Length*sizeOf(Char));
    end;

    operator &Add(aLeft: InstanceType; aRight: CocoaObject): InstanceType;
    begin
      var lRight := aRight.description;
      var lLength := lRight.length;
      var lBytes := new Char[lLength];
      lRight.getCharacters(lBytes);
      result := DelphiStringHelpers.EmptyDelphiUnicodeStringWithCapacity(aLeft.Length+lLength);
      memcpy(result.fStringData,              aLeft.fStringData, aLeft.Length*sizeOf(Char));
      memcpy(result.fStringData+aLeft.Length, @(lBytes[0]),      lLength*sizeOf(Char));
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

    // live-time management

    class method &New(aTTY: ^Void; aSize: IntPtr): ^Void;
    begin
      writeLn("DelphiUnicodeString: New");
      // ??
    end;

    class method Init(var aDestination: DelphiUnicodeString); //empty; // zero value
    begin
      writeLn("DelphiUnicodeString: Init");
    end;

    class method &Copy(var aDestination, aSource: DelphiUnicodeString);
    begin
      writeLn("DelphiUnicodeString: Copy");
      if (@aDestination) = (@aSource) then
        exit;
      if aDestination.fStringData = aSource.fStringData then
        exit;
      if assigned(aDestination.fStringData) then
        Release(var aDestination); // just like assign, but this one releases old
      aDestination.fStringData := aSource.fStringData;
      DelphiStringHelpers.AdjustLongStringReferenceCount(^Void(aSource.fStringData), 1);
    end;

    constructor &Copy(var aSource: DelphiUnicodeString);
    begin
      writeLn("DelphiUnicodeString: Copy ctor");
      if not assigned(aSource.fStringData) then
        exit;
      fStringData := aSource.fStringData;
      DelphiStringHelpers.AdjustLongStringReferenceCount(^Void(aSource.fStringData), 1);
    end;

    class operator Assign(var aDestination: DelphiUnicodeString; var aSource: DelphiUnicodeString);
    begin
      writeLn($"DelphiUnicodeString: Assign operator {IntPtr(aSource.fStringData)} => {IntPtr(aDestination.fStringData)}");
      if (@aDestination) = (@aSource) then
        exit;
      if aDestination.fStringData = aSource.fStringData then
        exit;
      aDestination.fStringData := aSource.fStringData;
      DelphiStringHelpers.AdjustLongStringReferenceCount(^Void(aSource.fStringData), 1);
    end;

    //class method Assign(var aDestination, aSource: DelphiUnicodeString);
    //begin
      //writeLn($"DelphiUnicodeString: Assign {IntPtr(aSource.fStringData)} => {IntPtr(aDestination.fStringData)}");
      //if (@aDestination) = (@aSource) then
        //exit;
      //if aDestination.fStringData = aSource.fStringData then
        //exit;
      //aDestination.fStringData := aSource.fStringData;
      //DelphiStringHelpers.AdjustLongStringReferenceCount(^Void(aSource.fStringData), 1);
    //end;

    class method Release(var aDestination: DelphiUnicodeString);
    begin
      writeLn($"DelphiUnicodeString: Release {IntPtr(aDestination.fStringData)} {DelphiStringHelpers.DelphiStringReferenceCount(^Void(aDestination.fStringData))}");
      if not assigned(aDestination.fStringData) then
        exit;
      DelphiStringHelpers.ReleaseDelphiLongString(^Void(aDestination.fStringData))
    end;

    finalizer;
    begin
      writeLn("DelphiUnicodeString: Finalizer");
      //Release(var self);
    end;

  end;

method Length(aString: DelphiUnicodeString): Integer;
begin
  result := aString.Length;
end;

method PCharLen(aChars: ^Char): Integer;
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