namespace RemObjects.Elements.System;

type
  [Packed]
  DelphiAnsiString = public record
  assembly
    fStringData: ^AnsiChar;

  public

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
        DelphiStringHelpers.CopyOnWriteDelphiAnsiString(var self);
        (fStringData+aIndex-1)^ := value;
      end; default;

    //
    // Operators
    //

    operator Explicit(aString: DelphiAnsiString): IslandString;
    begin
      result := IslandString:FromPAnsiChar(aString.fStringData);
    end;

    operator Explicit(aString: IslandString): DelphiAnsiString;
    begin
      result := aString:ToDelphiAnsiString;
    end;

    operator Explicit(aString: DelphiShortString): DelphiAnsiString;
    begin
      result := DelphiStringHelpers.DelphiAnsiStringWithChars(@aString[1], aString.Length);
    end;

    operator Explicit(aString: DelphiAnsiString): DelphiShortString;
    begin
      if aString.Length > 255 then
        raise new InvalidCastException("Cannot represent string longer than 255 characters as DelphiShortString");
      result := DelphiStringHelpers.DelphiShortStringWithChars(aString.fStringData, aString.Length);
    end;

    {$IF DARWIN}
    operator Explicit(aString: DelphiAnsiString): CocoaString;
    begin
      result := new CocoaString withBytes(aString.fStringData) length(DelphiStringHelpers.DelphiStringLength(aString.fStringData)) encoding(Foundation.NSStringEncoding.UTF16LittleEndianStringEncoding);
    end;

    operator Explicit(aString: CocoaString): DelphiAnsiString;
    begin
      result := aString:ToDelphiAnsiString;
    end;
    {$ENDIF}

    //

    operator &Add(aLeft: DelphiAnsiString; aRight: DelphiAnsiString): DelphiAnsiString;
    begin
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    operator &Add(aLeft: DelphiObject; aRight: DelphiAnsiString): DelphiAnsiString;
    begin
      //result := aLeft.ToString + aRight;
    end;

    operator &Add(aLeft: IslandObject; aRight: DelphiAnsiString): DelphiAnsiString;
    begin
      //result := (aLeft.ToString as DelphiString) + aRight;
    end;

    operator &Add(aLeft: DelphiAnsiString; aRight: DelphiObject): DelphiAnsiString;
    begin
      result := aLeft + aRight.ToString;
    end;

    operator &Add(aLeft: DelphiAnsiString; aRight: IslandObject): DelphiAnsiString;
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