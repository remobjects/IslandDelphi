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
        DelphiStringHelpers.CopyOnWriteDelphiUnicodeString(var self);
        (fStringData+aIndex-1)^ := value;
      end; default;

    //
    // Operators
    //

    operator Explicit(aString: DelphiUnicodeString): IslandString;
    begin
      result := IslandString:FromPChar(aString.fStringData);
    end;

    operator Explicit(aString: IslandString): DelphiUnicodeString;
    begin
      result := aString:ToDelphiUnicodeString;
    end;

    operator Explicit(aString: DelphiUnicodeString): DelphiWideString;
    begin
      result := DelphiStringHelpers.DelphiWideStringWithChars(aString.fStringData, aString.Length);
    end;

    operator Explicit(aString: DelphiWideString): DelphiUnicodeString;
    begin
      result := DelphiStringHelpers.DelphiUnicodeStringWithChars(aString.fStringData, aString.Length);
    end;

    {$IF DARWIN}
    operator Explicit(aString: DelphiUnicodeString): CocoaString;
    begin
      result := new CocoaString withBytes(aString.fStringData) length(DelphiStringHelpers.DelphiStringLength(aString.fStringData)) encoding(Foundation.NSStringEncoding.UTF16LittleEndianStringEncoding);
    end;

    operator Explicit(aString: CocoaString): DelphiUnicodeString;
    begin
      result := aString:ToDelphiUnicodeString;
    end;
    {$ENDIF}

    //

    operator Add(aLeft: DelphiUnicodeString; aRight: DelphiUnicodeString): DelphiUnicodeString;
    begin
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    operator Add(aLeft: DelphiUnicodeString; aRight: DelphiWideString): DelphiUnicodeString;
    begin
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    operator Add(aLeft: DelphiWideString; aRight: DelphiWideString): DelphiUnicodeString;
    begin
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    operator Add(aLeft: DelphiObject; aRight: DelphiUnicodeString): DelphiUnicodeString;
    begin
      result := aLeft.ToString + aRight;
    end;

    operator Add(aLeft: IslandObject; aRight: DelphiUnicodeString): DelphiUnicodeString;
    begin
      result := (aLeft.ToString as DelphiString) + aRight;
    end;

    operator Add(aLeft: DelphiUnicodeString; aRight: DelphiObject): DelphiUnicodeString;
    begin
      result := aLeft + aRight.ToString;
    end;

    operator Add(aLeft: DelphiUnicodeString; aRight: IslandObject): DelphiUnicodeString;
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
end.