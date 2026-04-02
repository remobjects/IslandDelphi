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
      if (Exponent = 0) and (Fraction = 0) then
        exit if Sign then "-0" else "0";
      result := #"<DelphiExtended80 {(self as Double)}>";
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
      result := InternalFromUInt64(aValue, false);
    end;

    operator Implicit(aValue: Int64): DelphiExtended80;
    begin
      var lSign := aValue < 0;
      var lAbsValue: UInt64;
      if lSign then
        lAbsValue := UInt64(-(aValue + 1)) + 1
      else
        lAbsValue := UInt64(aValue);
      result := InternalFromUInt64(lAbsValue, lSign);
    end;

    operator Implicit(aValue: Double): DelphiExtended80;
    begin
      result := default(DelphiExtended80);

      var lBits := ^UInt64(@aValue)^;
      var lSign := (lBits and $8000000000000000) ≠ 0;
      var lExponent := Integer((lBits shr 52) and $7FF);
      var lMantissa := lBits and $000FFFFFFFFFFFFF;

      if (lExponent = 0) and (lMantissa = 0) then begin
        if lSign then begin
          {$IFDEF EXTENDEDHAS10BYTES}
          result.fBytes[9] := $80;
          {$ELSE}
          result.fBytes[7] := $80;
          {$ENDIF}
        end;
        exit;
      end;

      if lExponent = $7FF then begin
        lMantissa := lMantissa shl 11;
        result := InternalPack80(lSign, $7FFF, lMantissa);
        exit;
      end;

      if lExponent = 0 then begin
        var lShift := 0;
        while (lMantissa and $0008000000000000) = 0 do begin
          lMantissa := lMantissa shl 1;
          inc(lShift);
        end;
        lExponent := 1 - 1023 - lShift;
      end
      else begin
        lMantissa := lMantissa or $0010000000000000;
        lExponent := lExponent - 1023;
      end;

      lExponent := lExponent + 16383;
      lMantissa := lMantissa shl 11;
      result := InternalPack80(lSign, lExponent, lMantissa);
    end;

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

    //

    operator Explicit(aValue: DelphiExtended80): Double;
    begin
      var lSign: Boolean;
      var lExponent: Integer;
      var lMantissa: UInt64;

      {$IFDEF EXTENDEDHAS10BYTES}
      lSign := (aValue.fBytes[9] and $80) <> 0;
      lExponent := Integer(aValue.Words[4] and $7FFF);
      lMantissa := ^UInt64(@aValue.fBytes[0])^;
      {$ELSE}
      lSign := (aValue.fBytes[7] and $80) <> 0;
      lExponent := Integer((aValue.Words[3] shr 4) and $7FF);
      lMantissa := ^UInt64(@aValue.fBytes[0])^;
      {$ENDIF}

      if (lExponent = 0) and (lMantissa = 0) then begin
        if lSign then
          result := -0.0
        else
          result := 0.0;
        exit;
      end;

      if lExponent = $7FFF then begin
        if lMantissa = 0 then begin
          if lSign then
            result := Double.NegativeInfinity
          else
            result := Double.PositiveInfinity;
        end
        else begin
          result := Double.NaN;
        end;
        exit;
      end;

      if lExponent = 0 then begin
        var lShift := 0;
        while (lMantissa and $8000000000000000) = 0 do begin
          lMantissa := lMantissa shl 1;
          inc(lShift);
        end;
        lExponent := 1 - 16383 - lShift;
      end
      else begin
        lExponent := lExponent - 16383;
      end;

      var lValue := (lMantissa / 2.0**63) * (2.0**lExponent);
      if lSign then
        lValue := -lValue;
      result := lValue;
    end;

    operator Explicit(aValue: DelphiExtended80): Single;
    begin
      result := (aValue as Double) as Single;
    end;

  private

    class method InternalPack80(aSign: Boolean; aExponent: Integer; aMantissa: UInt64): DelphiExtended80;
    begin
      result := default(DelphiExtended80);
      memcpy(@result.fBytes[0], @aMantissa, 8);
      {$IFDEF EXTENDEDHAS10BYTES}
      result.fBytes[8] := Byte((aExponent shr 8) and $7F);
      result.fBytes[9] := Byte(aExponent and $FF);
      if aSign then
        result.fBytes[8] := result.fBytes[8] or $80;
      {$ELSE}
      result.fBytes[8] := byte((aExponent shr 8) and $7F);
      result.fBytes[9] := byte(aExponent and $FF);
      if aSign then
        result.fBytes[7] := result.fBytes[7] or $80;
      {$ENDIF}
    end;

    class method InternalFromUInt64(aValue: UInt64; aSign: Boolean): DelphiExtended80;
    begin
      result := default(DelphiExtended80);
      if aValue = 0 then begin
        if aSign then begin
          {$IFDEF EXTENDEDHAS10BYTES}
          result.fBytes[9] := $80;
          {$ELSE}
          result.fBytes[7] := $80;
          {$ENDIF}
        end;
        exit;
      end;

      var lBitCount := 0;
      var lTemp := aValue;
      while lTemp ≠ 0 do begin
        inc(lBitCount);
        lTemp := lTemp shr 1;
      end;

      var lExponent := 16382 + lBitCount;
      var lFraction := aValue shl (64 - lBitCount);
      result := InternalPack80(aSign, lExponent, lFraction);
    end;

  end;

end.