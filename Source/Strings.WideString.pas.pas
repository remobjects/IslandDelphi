namespace RemObjects.Elements.System;

type
  [Packed]
  DelphiWideString = public record
  assembly
    fStringData: ^Char;

  public

    property Length: Integer read DelphiStringHelpers.DelphiStringLength(fStringData);
    property ReferenceCount: Integer read DelphiStringHelpers.DelphiStringReferenceCount(fStringData);

    property Chars[aIndex: Integer]: Char
      read begin
        CheckIndex(aIndex);
        result := (fStringData+aIndex)^;
      end
      write begin
        CheckIndex(aIndex);
        //if DelphiStringHelpers.CopyOnWriteDelphiUnicodeString(var self) then
          //DelphiStringHelpers.AdjustDelphiUnicodeStringReferenceCount(self, 1); // seems hacky top do this here?
        (fStringData+aIndex-1)^ := value;
      end; default;

    //
    // Operators
    //

    operator Explicit(aString: InstanceType): IslandString;
    begin
      result := IslandString:FromPChar(aString.fStringData, aString.Length);
    end;

    operator Implicit(aString: IslandString): DelphiWideString;
    begin
      result := aString:ToDelphiWideString;
    end;

    {$IF DARWIN}
    operator Explicit(aString: InstanceType): CocoaString;
    begin
      result := new CocoaString withBytes(aString.fStringData) length(DelphiStringHelpers.DelphiStringLength(aString.fStringData)) encoding(Foundation.NSStringEncoding.UTF16LittleEndianStringEncoding);
    end;

    operator Implicit(aString: ^Char): DelphiWideString;
    begin
      if assigned(aString) then
        result := DelphiStringHelpers.DelphiWideStringWithChars(aString, PCharLen(aString));
    end;

  operator Explicit(aString: CocoaString): DelphiWideString;
    begin
      result := aString:ToDelphiWideString;
    end;
    {$ENDIF}

    //

    operator &Add(aLeft: InstanceType; aRight: InstanceType): InstanceType;
    begin
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    operator &Add(aLeft: DelphiObject; aRight: InstanceType): InstanceType;
    begin
      result := aLeft.ToString as DelphiWideString + aRight;
    end;

    operator &Add(aLeft: IslandObject; aRight: InstanceType): InstanceType;
    begin
      result := (aLeft.ToString as DelphiWideString) + aRight;
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

method Length(aString: DelphiWideString): Integer;
begin
  result := aString.Length;
end;

end.