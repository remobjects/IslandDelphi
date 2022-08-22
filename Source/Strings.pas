namespace RemObjects.Elements.System;

type
  [Packed]
  DelphiUnicodeString = public record
    fStringData: ^Char;
  end;

  [Packed]
  DelphiWideString = public record
    fStringData: ^Char;
  end;

  [Packed]
  DelphiAnsiString = public record
    fStringData: ^AnsiChar;
  end;

end.