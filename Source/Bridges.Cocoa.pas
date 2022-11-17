namespace RemObjects.Elements.System;

{$IF DARWIN}
type
  [Cocoa]
  ICocoaGetDelphiWrapper = public interface
    method «$__CreateDelphiWrapper»: DelphiObject;
  end;

  //[Delphi]
  //IDelphiGetCocoaWrapper = public interface(DelphiInterface) // E671 Type "IDelphiGetCocoaWrapper" has a different class model than "Object" (Delphi vs Cocoa)

                                                              //// why doesnt this work? class mocel seems right?

    //method «$__CreateCocoaWrapper»: RemObjects.Elements.System.Object;
  //end;

  [Delphi]
  DelphiWrappedCocoaObject = public class(DelphiObject, Delphi.System.IComparable)
  public
    constructor(aValue: CocoaObject);
    begin
      Value := aValue;
    end;

    property Value: CocoaObject; readonly;

    class method FromValue(aValue: CocoaObject): DelphiObject;
    begin
      if aValue = nil then exit nil;
      if aValue is ICocoaGetDelphiWrapper then exit ICocoaGetDelphiWrapper(aValue).«$__CreateDelphiWrapper»();
      if aValue is CocoaWrappedDelphiObject then exit CocoaWrappedDelphiObject(aValue).Value;
      if aValue is CocoaWrappedDelphiException then exit CocoaWrappedDelphiException(aValue).InnerException;
      //if aValue is String then exit DelphiString(String(aValue)); // Delphi strings aren't objects
      exit new DelphiWrappedCocoaObject(aValue);
    end;

    method ToString: DelphiString; override;
    begin
      result := Value.description as DelphiString;
    end;

    method GetHashCode: Integer; override;
    begin
      exit Value.hash;
    end;

    method &Equals(aOther: DelphiObject): Boolean; override;
    begin
      if aOther is DelphiWrappedCocoaObject then
        result := Value.isEqual(DelphiWrappedCocoaObject(aOther):Value);
    end;

    method CompareTo(aOther: DelphiObject): Integer;
    begin
      if not Value.respondsToSelector(selector(compareTo:)) then
        raise new Exception("The wrapped Cocoa Object does not implement compareTo:");
      case aOther type of
        DelphiWrappedCocoaObject: result := (Value as IComparable).CompareTo(DelphiWrappedCocoaObject(aOther).Value);
      end;
    end;
  end;

  CocoaWrappedDelphiObject = public class(CocoaObject)
  public

    constructor(aValue: DelphiObject);
    begin
      Value := aValue;
    end;

    property Value: DelphiObject; readonly;

    class method FromValue(aValue: DelphiObject): CocoaObject;
    begin
      if aValue = nil then exit nil;
      //if aValue is IDelphiGetCocoaWrapper then exit IDelphiGetCocoaWrapper(aValue).«$__CreateCocoaWrapper»();
      //if aValue is DelphiString then exit String(DelphiString(aValue)); // Delphi strings aren't objects
      if aValue is DelphiWrappedCocoaObject then exit DelphiWrappedCocoaObject(aValue).Value;
      if aValue is DelphiException then exit new CocoaWrappedDelphiException(DelphiException(aValue));
      result := new CocoaWrappedDelphiObject(aValue);
    end;

    [ToString]
    method description: CocoaString; override;
    begin
      result := Value.ToString as CocoaString;
    end;

    method hash: Foundation.NSUInteger; override;
    begin
      result := Value.GetHashCode;
    end;

    method isEqual(aOther: id): Boolean; override;
    begin
      if aOther is CocoaWrappedDelphiObject then
        result := Value.Equals(CocoaWrappedDelphiObject(aOther):Value);
    end;

    method compareTo(aOther: id): Foundation.NSComparisonResult;
    begin
      if Value is not Delphi.System.IComparable then
        raise new Exception("The wrapped Delphi Object does not implement Delphi.System.IComparable");
      case aOther type of
        CocoaWrappedDelphiObject: result := (Value as Delphi.System.IComparable).CompareTo(CocoaWrappedDelphiObject(aOther).Value) as Foundation.NSComparisonResult;
      end;
    end;

  end;

  CocoaWrappedDelphiException = public class(CocoaException)
  public

    constructor (aException: DelphiException);
    begin
      //inherited constructor(aException.Message);
      InnerException := aException;
    end;

    [ToString]
    method description: String; override;
    begin
      result := "(Wrapped) "/*+typeOf(InnerException).Name+': '*/+Message;
    end;

    property InnerException: DelphiException read private write; reintroduce;

  end;

  DelphiWrappedCocoaException = public class(DelphiException)
  public

    constructor (aException: CocoaException);
    begin
      inherited constructor(DelphiString(aException.Message));
      InnerException := aException;
    end;

    //[ToString] // E26099: Cocoa/Delphi: allow [ToString] on Delphi-model objects
    method ToString: DelphiString; override;
    begin
      result := ("(Wrapped) "+InnerException.class.description+': '+InnerException.Message) as DelphiString;
    end;

    property InnerException: CocoaException read private write; reintroduce;

  end;

{$ENDIF}

end.