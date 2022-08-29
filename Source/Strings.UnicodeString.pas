namespace RemObjects.Elements.System;

[assembly: RemObjects.Elements.System.LifetimeStrategyOverrideAttribute(typeOf(DelphiUnicodeString), typeOf(DelphiLongStringRC))]

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
      result := aString:ToDelphiUnicodeString;
    end;

    operator Explicit(aString: InstanceType): DelphiWideString;
    begin
      result := DelphiStringHelpers.DelphiWideStringWithChars(aString.fStringData, aString.Length);
    end;

    operator Explicit(aString: DelphiWideString): InstanceType;
    begin
      result := DelphiStringHelpers.DelphiUnicodeStringWithChars(aString.fStringData, aString.Length);
    end;

    operator Implicit(aString: ^Char): InstanceType;
    begin
      if assigned(aString) then
        result := DelphiStringHelpers.DelphiUnicodeStringWithChars(aString, PCharLen(aString));
    end;

    {$IF DARWIN}
    operator Explicit(aString: InstanceType): CocoaString;
    begin
      result := new CocoaString withBytes(aString.fStringData) length(DelphiStringHelpers.DelphiStringLength(aString.fStringData)) encoding(Foundation.NSStringEncoding.UTF16LittleEndianStringEncoding);
    end;

    operator Explicit(aString: CocoaString): InstanceType;
    begin
      result := aString:ToDelphiUnicodeString;
    end;
    {$ENDIF}

    //

    operator &Add(aLeft: InstanceType; aRight: InstanceType): InstanceType;
    begin
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    operator &Add(aLeft: InstanceType; aRight: DelphiWideString): InstanceType;
    begin
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    operator &Add(aLeft: DelphiWideString; aRight: DelphiWideString): InstanceType;
    begin
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    operator &Add(aLeft: DelphiObject; aRight: InstanceType): InstanceType;
    begin
      //result := aLeft.ToString + aRight;
    end;

    operator &Add(aLeft: IslandObject; aRight: InstanceType): InstanceType;
    begin
      result := (aLeft.ToString as DelphiString) + aRight;
    end;

    operator &Add(aLeft: InstanceType; aRight: DelphiObject): InstanceType;
    begin
      result := aLeft + aRight.ToString;
    end;

    operator &Add(aLeft: InstanceType; aRight: IslandObject): InstanceType;
    begin
      result := aLeft + (aRight.ToString as DelphiString);
    end;

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