namespace RemObjects.Elements.System;

{$IF (DARWIN AND i386) OR (LINUX AND X86_64)} // DARWIN AND i386 won't happen for us, but FTR
  {$DEFINE EXTENDEDHAS16BYTES}
{$ELSE}
  {$DEFINE EXTENDEDHAS10BYTES}
{$ENDIF}

{$IF ARM OR (WINDOWS AND X86_64)}
  {$DEFINE EXTENDEDISDOUBLE}
{$ENDIF}

type
  // https://docwiki.embarcadero.com/Libraries/Sydney/en/System.Real48
  [Obsolete("Use Double"), Packed]
  DelphiReal48 = public record
  private

    fBytes: array [0..5] of Byte;

  public

    property Bytes[aIndex: Integer]: Byte read fBytes[aIndex];
    property Words[aIndex: Integer]: Word read fBytes[aIndex/2] + (fBytes[aIndex/2+1] shl 8);

    property Exponent: UInt64 read fBytes[0];
    property Fraction: UInt64 read (fBytes[1]) + (fBytes[2] shl 8) + (fBytes[3] shl 16) + (fBytes[4] shl 24) + ((fBytes[5] and $7f) as UInt64) shl 32;
    property Sign: Boolean read fBytes[5] >= $80;
  end;

  DelphiComp = public type Int64;

  // https://docwiki.embarcadero.com/RADStudio/Sydney/en/Internal_Data_Formats_(Delphi)#The_Extended_type
  // https://docwiki.embarcadero.com/Libraries/Sydney/en/System.Extended

  // System.Extended offers greater precision than other real types, but is less portable.
  // Be careful using System.Extended if you are creating data files to share across platforms. Be aware that:

  // On Intel 32-bit Windows systems, the size of System.Extended is 10 bytes.
  // On Intel 32-bit macOS or iOS-Simulator systems, the size of System.Extended is 16 bytes in order to be compatible with BCCOSX.
  // On Intel Linux systems, the size of System.Extended is 16 bytes.
  // On Intel 64-bit Windows systems, however, the System.Extended type is an alias for System.Double, which is only 8 bytes.
  // On ARM system include iOS and Android, however, the System.Extended type is an alias for System.Double, which is only 8 bytes.

  // Extended80 (opposed to Extended) is still 10/16 bytes, on platforms where Extended aliases Double!

  [Packed]
  DelphiExtended80 = public record
  private

    {$IF EXTENDEDHAS10BYTES}
    var fBytes: array [0..9] of Byte;
    {$ELSE}
    var fBytes: array [0..15] of Byte;
    {$ENDIF}

  public

    property Bytes[aIndex: Integer]: Byte read fBytes[aIndex];
    property Words[aIndex: Integer]: Word read fBytes[aIndex/2] + (fBytes[aIndex/2+1] shl 8);

    method ToString: String; override;
    begin
      result := #"<DelphiExtended80 {(Fraction / 2.0**52) * (2.0**(Exponent-1023))} (Exponent: {Exponent}, Fraction: {Fraction})>";
    end;

    {$IFDEF EXTENDEDHAS10BYTES}
    property Exponent: UInt64 read Words[4] and $7FFF;
    property Fraction: UInt64 read ^UInt64(@Self)^;
    property Sign: Boolean read fBytes[9] >= $80;
    {$ELSE}
    property Exponent: UInt64 read (Words[3] shr 4) and $7FF;
    property Fraction: UInt64 read ^UInt64(@Self)^ and $000FFFFFFFFFFFFF;
    property Sign: Boolean read fBytes[7] >= $80;
    {$ENDIF}

    //operator Explicit(aValue: DelphiExtended80): Double;
    //begin
      //{$IF EXTENDEDHAS10BYTES}
      //{$ELSE}
      //result := :Delphi.System.«@Ext80ToDouble»(@aValue.fBytes);
      //{$ENDIF}
    //end;

    //operator Explicit(aValue: Double): DelphiExtended80;
    //begin
      //{$IF EXTENDEDHAS10BYTES}
      //{$ELSE}
      //:Delphi.System.«@DoubleToExt80»(@result.fBytes, aValue);
      //{$ENDIF}
    //end;

  end;

end.