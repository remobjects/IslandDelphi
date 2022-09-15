namespace RemObjects.Elements.System;

{$DEFINE USE_DELPHI_MM}

type
  DelphiMemoryHelpers = public static class
  public

    method GetMem(aSize: IntPtr): ^Void;
    begin
      {$IF USE_DELPHI_MM}
      result := :Delphi.System.SysGetMem(aSize);
      {$ELSE}
      result := malloc(aSize);
      {$ENDIF}
    end;

    method FreeMem(aMemory: ^Void);
    begin
      {$IF USE_DELPHI_MM}
      :Delphi.System.SysFreeMem(aMemory);
      {$ELSE}
      free(aMemory);
      {$ENDIF}
    end;

  end;

end.