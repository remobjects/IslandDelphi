namespace RemObjects.Elements.System;

type
  TObject = public Delphi.System.TObject;

  DelphiObject = public Delphi.System.TObject;
  DelphiChar = public {$IF ANSI_STRING}Delphi.System.AnsiChar{$ELSE}Delphi.System.WideChar{$ENDIF};
  DelphiString = public {$IF ANSI_STRING}Delphi.System.AnsiString{$ELSE}Delphi.System.UnicodeString{$ENDIF};
  DelphiException = public Delphi.System.SysUtils.Exception;
  DelphiInterface = public Delphi.System.IUnknown;

  RemObjects.Elements.System.Delphi.Object = public DelphiObject;
  RemObjects.Elements.System.Delphi.String = public DelphiString;
  RemObjects.Elements.System.Delphi.Exception = public DelphiException;

  [Island]
  IIslandGetDelphiWrapper = public interface
    method «$__CreateDelphiWrapper»: DelphiObject;
  end;

  //[Delphi]
  //IDelphiGetIslandWrapper = public interface(DelphiInterface) // E671 Type "IDelphiGetIslandWrapper" has a different class model than "Object" (Delphi vs Island)

                                                              //// why doesnt this work? class mocel seems right?

    //method «$__CreateIslandWrapper»: RemObjects.Elements.System.Object;
  //end;

  [Delphi]
  DelphiWrappedIslandObject = public class(DelphiObject, Delphi.System.IComparable)
  public
    constructor(aValue: IslandObject);
    begin
      Value := aValue;
    end;

    property Value: IslandObject; readonly;

    class method FromValue(aValue: IslandObject): DelphiObject;
    begin
      if aValue = nil then exit nil;
      if aValue is IIslandGetDelphiWrapper then exit IIslandGetDelphiWrapper(aValue).«$__CreateDelphiWrapper»();
      if aValue is IslandWrappedDelphiObject then exit IslandWrappedDelphiObject(aValue).Value;
      if aValue is IslandWrappedDelphiException then exit IslandWrappedDelphiException(aValue).InnerException;
      //if aValue is String then exit DelphiString(String(aValue)); // Delphi strings aren't objects
      exit new DelphiWrappedIslandObject(aValue);
    end;

    method ToString: DelphiString; override;
    begin
      result := Value.ToString() as DelphiString;
    end;

    method GetHashCode: Integer; override;
    begin
      exit Value.GetHashCode;
    end;

    method Equals(aOther: DelphiObject): Boolean; override;
    begin
      if aOther is DelphiWrappedIslandObject then
        result := Value.Equals(DelphiWrappedIslandObject(aOther):Value);
    end;

    {$HINT wrong sig!}
    method CompareTo(xSelf: Delphi.System.IComparable; aOther: DelphiObject): Integer;
    begin
      if Value is not Delphi.System.IComparable then
        raise new Exception("Island Object does not implement IComparable");
      case aOther type of
        DelphiWrappedIslandObject: result := (Value as IComparable).CompareTo(DelphiWrappedIslandObject(aOther).Value);
      end;
    end;
  end;

  IslandWrappedDelphiObject = public class(WrappedObject, IComparable, IEquatable)
  public

    constructor(aValue: DelphiObject);
    begin
      Value := aValue;
    end;

    property Value: DelphiObject; readonly;

    class method FromValue(aValue: DelphiObject): IslandObject;
    begin
      if aValue = nil then exit nil;
      //if aValue is IDelphiGetIslandWrapper then exit IDelphiGetIslandWrapper(aValue).«$__CreateIslandWrapper»();
      //if aValue is DelphiString then exit String(DelphiString(aValue)); // Delphi strings aren't objects
      if aValue is DelphiWrappedIslandObject then exit DelphiWrappedIslandObject(aValue).Value;
      if aValue is DelphiException then exit new IslandWrappedDelphiException(DelphiException(aValue));
      result := new IslandWrappedDelphiObject(aValue);
    end;

    method ToString: IslandString; override;
    begin
      result := Value.ToString as IslandString;
    end;

    method GetHashCode: Integer; override;
    begin
      result := Value.GetHashCode;
    end;

    method &Equals(aOther: IslandObject): Boolean; override;
    begin
      if aOther is IslandWrappedDelphiObject then
        result := Value.Equals(IslandWrappedDelphiObject(aOther):Value);
    end;

    method CompareTo(aOther: IslandObject): Integer;
    begin
      if Value is not Delphi.System.IComparable then
        raise new Exception("Delphi Object does not implement IComparable");
      case aOther type of
        IslandWrappedDelphiObject: result := (Value as Delphi.System.IComparable).CompareTo(nil, IslandWrappedDelphiObject(aOther).Value); {$HINT wrong sig!}
      end;
    end;

  end;

  IslandWrappedDelphiException = public class(IslandException)
  public

    constructor (aException: DelphiException);
    begin
      //inherited constructor(aException.Message);
      InnerException := aException;
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := "(Wrapped) "/*+typeOf(InnerException).Name+': '*/+Message;
    end;

    property InnerException: DelphiException read private write; reintroduce;

  end;

  [Delphi]
  DelphiWrappedIslandException = public class(DelphiException)
  public

    constructor (aException: IslandException);
    begin
      inherited constructor(DelphiString(aException.Message));
      InnerException := aException;
    end;

    //[ToString] // E26099: Island/Delphi: allow [ToString] onm Delphi-model objects
    method ToString: DelphiString; override;
    begin
      //result := "(Wrapped) "+typeOf(InnerException).Name+': '+Message;
    end;

    property InnerException: IslandException read private write; reintroduce;

  end;

end.