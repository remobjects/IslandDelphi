namespace RemObjects.Elements.System;

type
  DelphiUnicodeString = public type ^Char;
  DelphiWideString = public type ^Char;
  DelphiAnsiString = public type ^AnsiChar;
  DelphiShortString = public Delphi.System.ShortString;

  //{$IF ANSI_STRING}
  //[assembly:DefaultTypeOverride("String", "Delphi", typeOf(RemObjects.Elements.System.DelphiAnsiString))]
  //{$ELSE}
  //[assembly:DefaultTypeOverride("String", "Delphi", typeOf(RemObjects.Elements.System.DelphiUnicodeString))]
  //{$ENDIF}

end.