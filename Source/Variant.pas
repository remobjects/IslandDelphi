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
    //fBytes: {$IF CPU32}array [0..15] of Byte{$ELSEIF CPU64}array [0..23] of Byte{$ENDIF};
  end;

end.