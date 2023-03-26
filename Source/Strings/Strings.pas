namespace Delphi.System;

//type
  //{$IF ANSI_STRING}
  //[assembly:DefaultTypeOverride("String", "Delphi", typeOf(RemObjects.Elements.System.DelphiAnsiString))]
  //{$ELSE}
  //[assembly:DefaultTypeOverride("String", "Delphi", typeOf(RemObjects.Elements.System.DelphiUnicodeString))]
  //{$ENDIF}

//
// SetString
//

{$IF NOT ANSI_STRING}
method SetString(var aString: DelphiUnicodeString; aBuffer: :Delphi.System.PChar; aLength: Integer); public;
begin
  if assigned(aBuffer) then
    aString := DelphiStringHelpers.DelphiUnicodeStringWithChars(aBuffer, aLength)
  else
    aString := DelphiStringHelpers.EmptyDelphiUnicodeStringWithCapacity(aLength);
end;
{$ENDIF}

method SetString(var aString: DelphiAnsiString; aBuffer: :Delphi.System.PAnsiChar; aLength: Integer); public;
begin
  if assigned(aBuffer) then
    aString := DelphiStringHelpers.DelphiAnsiStringWithChars(aBuffer, aLength)
  else
    aString := DelphiStringHelpers.EmptyDelphiAnsiStringWithCapacity(aLength);
end;

method SetString(var aString: DelphiWideString; aBuffer: ^RemObjects.Elements.System.Char; aLength: Integer); public;
begin
  if assigned(aBuffer) then
    aString := DelphiStringHelpers.DelphiWideStringWithChars(aBuffer, aLength)
  else
    aString := DelphiStringHelpers.EmptyDelphiWideStringWithCapacity(aLength);
end;

method SetString(var aString: DelphiShortString; aBuffer: :Delphi.System.PAnsiChar; aLength: Integer); public;
begin
  :Delphi.System.«@SetString»(var aString, aBuffer, aLength);
end;

method SetString(var aString: IslandString; aBuffer: ^RemObjects.Elements.System.Char; aLength: Integer); public;
begin
  if assigned(aBuffer) then
    aString := IslandString.FromPChar(aBuffer, aLength)
  else
    aString := IslandString.FromRepeatedChar(#0, aLength);
end;

//
// Copy
//

{$IF NOT ANSI_STRING}
method &Copy(const aString: DelphiUnicodeString; aIndex, aCount: Integer): DelphiUnicodeString; public; inline;
begin
  result := :Delphi.System.«@UStrCopy»(aString, aIndex, aCount);
end;
{$ENDIF}

method &Copy(const aString: DelphiAnsiString; aIndex, aCount: Integer): DelphiAnsiString; public; inline;
begin
  result := :Delphi.System.«@LStrCopy»(aString, aIndex, aCount);
end;

method &Copy(const aString: DelphiWideString; aIndex, aCount: Integer): DelphiWideString; public; inline;
begin
  result := :Delphi.System.«@WStrCopy»(aString, aIndex, aCount);
end;

method &Copy(const aString: DelphiShortString; aIndex, aCount: Integer): DelphiShortString; public; inline;
begin
  result := :Delphi.System.«@Copy»(aString, aIndex, aCount);
end;

end.