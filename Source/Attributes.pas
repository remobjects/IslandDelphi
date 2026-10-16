namespace RemObjects.Elements.System;

type
  // Native Delphi managed strings use a pointer value at Delphi ABI boundaries.
  [AttributeUsage(AttributeTargets.Struct)]
  DelphiStringAttribute = public class(Attribute)
  public
    constructor; empty;
  end;

  // BSTR storage has a byte-count prefix and COM allocation/copy ownership.
  [AttributeUsage(AttributeTargets.Struct)]
  DelphiBStrAttribute = public class(Attribute)
  public
    constructor; empty;
  end;

end.