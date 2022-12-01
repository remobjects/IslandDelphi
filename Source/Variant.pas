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
    fData: TVarData;

  public

    property &Type: DelphiVariantType read DelphiVariantType(fData.VType and varTypeMask);
    property IsArray: Boolean read fData.VType and varArray ≠ 0;
    property IsByRef: Boolean read fData.VType and varByRef ≠ 0;

    property Value: Object read
    begin
      case &Type of
        varSmallint: result := fData.VSmallInt;
        varInteger: result := fData.VInteger;
        varSingle: result := fData.VSingle;
        varDouble: result := fData.VDouble;
        varCurrency: result := fData.VCurrency;
        varDate: result := fData.VDate;
        varOleStr: result := IslandString.FromPChar(fData.VOleStr);
        varDispatch: result := nil;
        varError: result := fData.VError;
        varBoolean: result := fData.VBoolean;
        varVariant: result := nil;
        varUnknown: result := nil;
        varShortInt: result := fData.VShortInt;
        varByte: result := fData.VByte;
        varWord: result := fData.VWord;
        //varLongWord: result := fData.VLongWord;
        {$IF EXISTS("Delphi.System.varUInt32")}
        varUInt32: result := fData.VUInt64;
        {$ENDIF}
        varInt64: result := fData.VInt64;
        varUInt64: result := fData.VUInt64;
        varRecord: result := nil;
        varStrArg: result := nil;
        //varObject: result := DelphiObject(fData.VPointer);
        varUStrArg: result := nil;
        varString: result := new DelphiAnsiString(fData.VString) as IslandString;
        varAny: result := nil;
        varUString: result := new DelphiUnicodeString(fData.VString) as IslandString;
      end;
    end;
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
    varLongWord = 19,
    varUInt32 = 19,
    varInt64 = 20,
    varUInt64 = 21,
    varRecord = 36,
    varStrArg = 72,
    varObject = 73,
    varUStrArg = 74,
    varString = $100,
    varAny = $101,
    varUString = $102,

    varTypeMask = $0fff,
    varArray    = $2000,
    varByRef    = $4000,
  );

end.