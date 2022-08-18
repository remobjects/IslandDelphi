namespace RemObjects.Elements.System;

type
  // https://docwiki.embarcadero.com/Libraries/Sydney/en/System.Real48
  [/*Obsolete("Use Double"),*/ Packed]
  DelphiReal48 = public record
  public
    fBytes: array [0..5] of Byte;
  end;

  // https://docwiki.embarcadero.com/Libraries/Sydney/en/System.Extended
  {$IF ARM OR (WINDOWS AND X86_64)}
  DelphiExtended80 = public Double; {$HINT Need to check if Extended80 (opposed to Extended) is still 10/16 bytes, on platforms where Extended aliases Double...}
  {$ELSE}
  [Packed]
  DelphiExtended80 = public record
  public
    {$IF (DARWIN AND i386) OR (LINUX AND X86_64)} // DARWIN AND i386 won't happen for us, but FTR
    fBytes: array [0..15] of Byte;
    {$ELSE}
    fBytes: array [0..9] of Byte;
    {$ENDIF}
  end;
  {$ENDIF}

  DelphiComp = public type Int64;

end.