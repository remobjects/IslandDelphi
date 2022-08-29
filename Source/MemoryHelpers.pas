namespace RemObjects.Elements.System;

type
  DelphiMemoryHelpers = public static class
  public

    method GetMem(aSize: IntPtr): ^Void;
    begin
      {$IF USE_DELPHI_MM}
      result := :Delphi.System.«@GetMem»(aSize);
      {$ELSE}
      result := malloc(aSize);
      {$ENDIF}
    end;

    method FreeMem(aMemory: ^Void);
    begin
      {$IF USE_DELPHI_MM}
      :Delphi.System.«@FreeMem»(aMemory);
      {$ELSE}
      free(aMemory);
      {$ENDIF}
    end;

  end;

end.