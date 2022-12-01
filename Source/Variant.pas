namespace RemObjects.Elements.System;

uses
  Delphi.System;

//
// https://docwiki.embarcadero.com/RADStudio/Sydney/en/Internal_Data_Formats_(Delphi)#Variant_Types
//

type
  [Packed]
  [Error("Delphi APIs using 'variant' are not available from Elements (yet")]
  DelphiVariant = public record
  private
    fData: VarDataUnion;
    //fBytes: {$IF CPU32}array [0..15] of Byte{$ELSEIF CPU64}array [0..23] of Byte{$ENDIF};

  public

    property &Type: DelphiVariantType read DelphiVariantType(fData.VType and varTypeMask);
    property IsArray: Boolean read fData.VType and varArray ≠ 0;
    property IsByRef: Boolean read fData.VType and varByRef ≠ 0;

    property Value: Object read
    begin
      case &Type of
        varSmallint: result := fData.VData.VData.VData.VData.VData.VSmallInt;
        varInteger: result := fData.VData.VData.VData.VData.VData.VInteger;
        varSingle: result := fData.VData.VData.VData.VData.VData.VSingle;
        varDouble: result := fData.VData.VData.VData.VData.VData.VDouble;
        varCurrency: result := fData.VData.VData.VData.VData.VData.VCurrency;
        varDate: result := fData.VData.VData.VData.VData.VData.VDate;
        varOleStr: result := IslandString.FromPChar(fData.VData.VData.VData.VData.VData.VOleStr);
        varDispatch: result := nil;
        varError: result := fData.VData.VData.VData.VData.VData.VError;
        varBoolean: result := fData.VData.VData.VData.VData.VData.VBoolean;
        varVariant: result := nil;
        varUnknown: result := nil;
        varShortInt: result := fData.VData.VData.VData.VData.VData.VShortInt;
        varByte: result := fData.VData.VData.VData.VData.VData.VByte;
        varWord: result := fData.VData.VData.VData.VData.VData.VWord;
        //varLongWord: result := fData.VData.VData.VData.VData.VData.VLongWord;
        {$IF EXISTS("Delphi.System.varUInt32")}
        varUInt32: result := fData.VData.VData.VData.VData.VData.VUInt64;
        {$ENDIF}
        varInt64: result := fData.VData.VData.VData.VData.VData.VInt64;
        varUInt64: result := fData.VData.VData.VData.VData.VData.VUInt64;
        varRecord: result := nil;
        varStrArg: result := nil;
        varObject: result := nil;//DelphiObject(fData.VData.VData.VData.VData.VData.VPointer);
        varUStrArg: result := nil;
        varString: result := new DelphiAnsiString(fData.VData.VData.VData.VData.VData.VString) as IslandString;
        varAny: result := nil;
        varUString: result := new DelphiUnicodeString(fData.VData.VData.VData.VData.VData.VString) as IslandString;
      end;
    end;
  end;

  [Packed]
  VarDataUnion = public packed record
    VType: TVarType;
    VData: VarDataUnion0;
  end;

  [Union, Packed]
  VarDataUnion0 = public record
    VData: VarDataUnion00;
    VWords: array [0..{$IFDEF CPU64}10{$ELSE}6{$ENDIF}] of Word;
    VBytes: array [0..{$IFDEF CPU64BITS}21{$ELSE}13{$ENDIF}] of Byte;
  end;

  [Union, Packed]
  VarDataUnion00 = public record
    Reserved1: Word;
    VData: VarDataUnion000;
  end;

  [Union, Packed]
  VarDataUnion000 = public record
    VData: VarDataUnion0000;
    VLongs: array [0..{$IFDEF CPU64}4{$ELSE}2{$ENDIF}] of Integer;
  end;

  [Union, Packed]
  VarDataUnion0000 = public record
    Reserved2, Reserved3: Word;
    VData: VarDataUnionFields;
  end;

  //[Union, Packed]
  //VarDataUnion00 = public record
    //Reserved2, Reserved3: Word;
    //VData: VarDataUnion1B;
  //end;

  //[Packed]
  //VarDataUnion2 = public record
    //VData: VarDataUnion1B;
  //end;

  [Union, Packed]
  VarDataUnionFields = public record
    VSmallInt: SmallInt;
    VInteger: Integer;
    VSingle: Single;
    VDouble: Double;
    VCurrency: Currency;
    VDate: TDateTime;
    VOleStr: PWideChar;
    VDispatch: Pointer;
    VError: HRESULT;
    VBoolean: WordBool;
    VUnknown: Pointer;
    VShortInt: ShortInt;
    VByte: Byte;
    VWord: Word;
    //VLongWord: Cardinal {deprecated 'use VUInt32'};
    VUInt32: UInt32;
    VInt64: Int64;
    VUInt64: UInt64;
    VString: Pointer;
    VAny: Pointer;
    VArray: PVarArray;
    VPointer: Pointer;
    VUString: Pointer;
    VRecord: TVarRecord;
  end;

  DelphiVariantType = public enum(
    varEmpty = 0,
    varNull = 1,
    varSmallint = 2,
    varInteger = 3,
    varSingle = 4,
    varDouble = 5,
    varCurrency = 6,
    varDate = 7,
    varOleStr = 8,
    varDispatch = 9,
    varError = 10,
    varBoolean = 11,
    varVariant = 12,
    varUnknown = 13,
    varShortInt = 16,
    varByte = 17,
    varWord = 18,
    //varLongWord = 19,
    varUInt32 = 19,
    varInt64 = 20,
    varUInt64 = 21,
    varRecord = 36,
    varStrArg = 72,
    varObject = 73,
    varUStrArg = 74,
    varString = 256,
    varAny = 257,
    varUString = 258,

    varTypeMask = $0fff,
    varArray    = $2000,
    varByRef    = $4000,
  );

end.