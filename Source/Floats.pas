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

    operator Implicit(aValue: UInt64): DelphiExtended80;
    begin
      {$IFDEF EXTENDEDHAS10BYTES}
      result := default(DelphiExtended80);

      if aValue = 0 then
        exit;

      var lBitCount := 0;
      var lTemp := aValue;
      while lTemp <> 0 do begin
        inc(lBitCount);
        lTemp := lTemp shr 1;
      end;

      var lExponent := 16382 + lBitCount;
      var lFraction := aValue shl (64 - lBitCount);

      memcpy(@result.fBytes[0], @lFraction, 8);
      result.fBytes[8] := Byte((lExponent shr 8) and $7F);
      result.fBytes[9] := Byte(lExponent and $FF);
      {$ELSE}
      result := aValue as Delphi.System.Extended;
      {$ENDIF}
    end;

    operator Implicit(aValue: Int64): DelphiExtended80;
    begin
      {$IFDEF EXTENDEDHAS10BYTES}
      var lSign: Boolean := aValue < 0;
      var lAbsValue: UInt64 := if lSign then UInt64(-aValue) else UInt64(aValue);
      var lExponent: Integer := 16383;
      var lFraction: UInt64 := 0;

      if lAbsValue <> 0 then begin
        var lBitCount: Integer := 0;
        var lTemp: UInt64 := lAbsValue;
        while lTemp <> 0 do begin
          inc(lBitCount);
          lTemp := lTemp shr 1;
        end;

        lExponent := 16382 + lBitCount;
        if lBitCount > 1 then
          lFraction := lAbsValue shl (64 - lBitCount)
        else
          lFraction := lAbsValue shl 63;
      end;

      result := default(DelphiExtended80);
      result.fBytes[0] := Byte(lFraction and $FF);
      result.fBytes[1] := Byte((lFraction shr 8) and $FF);
      result.fBytes[2] := Byte((lFraction shr 16) and $FF);
      result.fBytes[3] := Byte((lFraction shr 24) and $FF);
      result.fBytes[4] := Byte((lFraction shr 32) and $FF);
      result.fBytes[5] := Byte((lFraction shr 40) and $FF);
      result.fBytes[6] := Byte((lFraction shr 48) and $FF);
      result.fBytes[7] := Byte((lFraction shr 56) and $FF);
      result.fBytes[8] := Byte((lExponent shr 8) and $7F);
      result.fBytes[9] := Byte(lExponent and $FF);
      if lSign then
        result.fBytes[8] := result.fBytes[8] or $80;
      {$ELSE}
      var lValue: Double := aValue;
      memcpy(@result, @lValue, SizeOf(result));
      {$ENDIF}
    end;

    operator Implicit(aValue: Double): DelphiExtended80;
    begin
      {$IFDEF EXTENDEDHAS10BYTES}
      var lBits: UInt64 := ^UInt64(@aValue)^;
      var lSign: Boolean := (lBits and $8000000000000000) <> 0;
      var lExponent: Integer := Integer((lBits shr 52) and $7FF);
      var lMantissa: UInt64 := lBits and $000FFFFFFFFFFFFF;

      result := default(DelphiExtended80);

      if lExponent = 0 then begin
        if lMantissa = 0 then begin
          // zero
          if lSign then
            result.fBytes[9] := $80;
          exit;
        end
        else begin
          // subnormal double -> normalize
          while (lMantissa and $0010000000000000) = 0 do begin
            lMantissa := lMantissa shl 1;
            dec(lExponent);
          end;
          inc(lExponent);
        end;
      end
      else if lExponent = $7FF then begin
        // Inf/NaN
        result.fBytes[8] := $7F;
        result.fBytes[9] := $FF;
        if lSign then
          result.fBytes[8] := result.fBytes[8] or $80;
        lMantissa := lMantissa shl 11;
        memcpy(@result.fBytes[0], @lMantissa, 8);
        exit;
      end;

      lExponent := lExponent - 1023 + 16383;
      lMantissa := lMantissa or $0010000000000000; // hidden bit

      // shift double mantissa into 64-bit extended fraction
      lMantissa := lMantissa shl 11;

      memcpy(@result.fBytes[0], @lMantissa, 8);
      result.fBytes[8] := Byte((lExponent shr 8) and $7F);
      result.fBytes[9] := Byte(lExponent and $FF);
      if lSign then
        result.fBytes[8] := result.fBytes[8] or $80;
      {$ELSE}
      memcpy(@result, @aValue, SizeOf(result));
      {$ENDIF}
    end;

    // smaller types

    operator Implicit(aValue: Int32): DelphiExtended80;
    begin
      result := aValue as Int64;
    end;

    operator Implicit(aValue: UInt32): DelphiExtended80;
    begin
      result := aValue as UInt64;
    end;

    operator Implicit(aValue: Int16): DelphiExtended80;
    begin
      result := aValue as Int64;
    end;

    operator Implicit(aValue: UInt16): DelphiExtended80;
    begin
      result := aValue as UInt64;
    end;

    operator Implicit(aValue: Byte): DelphiExtended80;
    begin
      result := aValue as UInt64;
    end;

    operator Implicit(aValue: SByte): DelphiExtended80;
    begin
      result := aValue as Int64;
    end;

    operator Implicit(aValue: Single): DelphiExtended80;
    begin
      result := (aValue as Double) as DelphiExtended80;
    end;

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