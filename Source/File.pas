namespace RemObjects.Elements.System;

type
  [Error("Delphi APIs using typed 'file of' are not available from Elements (yet)")]
  DelghiFile<T> = public class
    where T is record;

  public
  end;

end.