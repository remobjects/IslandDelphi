namespace RemObjects.Elements.System;

type
  DelphiMemoryHelpers = public static class
  public

    method GetMem(aSize: IntPtr): ^Void;
    begin
      result := :Delphi.System.«@GetMem»(aSize);
    end;

    method FreeMem(aMemory: ^Void);
    begin
      :Delphi.System.«@FreeMem»(aMemory);
    end;

  end;

end.