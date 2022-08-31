namespace RemObjects.Elements.System;

type
  [Error("Delphi APIs using typed 'file of' are not available from Elements (yet)")]
  DelphiFile<T> = public record
    where T is record;

  public
  end;

end.