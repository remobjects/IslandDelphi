﻿namespace RemObjects.Elements.System;

[assembly: RemObjects.Elements.System.LifetimeStrategyOverrideAttribute(typeOf(DelphiAnsiString), typeOf(DelphiLongStringRC))]

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
        if DelphiStringHelpers.CopyOnWriteDelphiAnsiString(var self) then
          DelphiStringHelpers.AdjustDelphiAnsiStringReferenceCount(self, 1); // seems hacky top do this here?
        (fStringData+aIndex-1)^ := value;
      end; default;

    //
    // Operators
    //

    operator Explicit(aString: InstanceType): IslandString;
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

    operator Explicit(aString: InstanceType): DelphiShortString;
    begin
      if aString.Length > 255 then
        raise new InvalidCastException("Cannot represent string longer than 255 characters as DelphiShortString");
      result := DelphiStringHelpers.DelphiShortStringWithChars(aString.fStringData, aString.Length);
    end;

    operator Implicit(aString: ^AnsiChar): DelphiAnsiString;
    begin
      if assigned(aString) then
        result := DelphiStringHelpers.DelphiAnsiStringWithChars(aString, PAnsiCharLen(aString));
    end;

    {$IF DARWIN}
    operator Explicit(aString: InstanceType): CocoaString;
    begin
      result := new CocoaString withBytes(aString.fStringData) length(DelphiStringHelpers.DelphiStringLength(aString.fStringData)) encoding(Foundation.NSStringEncoding.UTF16LittleEndianStringEncoding);
    end;

    operator Explicit(aString: CocoaString): DelphiAnsiString;
    begin
      result := aString:ToDelphiAnsiString;
    end;
    {$ENDIF}

    //

    operator &Add(aLeft: InstanceType; aRight: InstanceType): InstanceType;
    begin
      //result := :Delphi.System.Concat(aLeft, aRight);
    end;

    operator &Add(aLeft: DelphiObject; aRight: InstanceType): InstanceType;
    begin
      //result := aLeft.ToString + aRight;
    end;

    operator &Add(aLeft: IslandObject; aRight: InstanceType): InstanceType;
    begin
      //result := (aLeft.ToString as DelphiString) + aRight;
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

method Length(aString: DelphiAnsiString): Integer;
begin
  result := aString.Length;
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