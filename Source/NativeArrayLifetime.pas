namespace RemObjects.Elements.System;

type
  // The compiler specializes T with the complete native Delphi array type.
  // Storage is one data pointer; allocation and ownership stay with Delphi's RTL.
  DelphiArrayLifetime<T> = public record
  private
    fData: ^Void;

    class method ArrayTypeInfo: ^Void;
    begin
      // Native array typeOf emits Delphi RTTI, including the element cleanup table.
      exit typeOf(T).RTTI;
    end;

  public
    class method &New(aTypeInfo: ^Void; aSize: NativeInt): ^Void;
    begin
      raise new NotSupportedException('Native Delphi arrays are allocated by SetLength');
    end;

    class method Init(var aDest: DelphiArrayLifetime<T>);
    begin
      aDest.fData := nil;
    end;

    class method Copy(var aDest, aSource: DelphiArrayLifetime<T>);
    begin
      aDest.fData := nil;
      :Delphi.System.DynArrayAssign(var aDest.fData, aSource.fData, ArrayTypeInfo);
    end;

    class method Assign(var aDest, aSource: DelphiArrayLifetime<T>);
    begin
      :Delphi.System.DynArrayAssign(var aDest.fData, aSource.fData, ArrayTypeInfo);
    end;

    class method Release(var aDest: DelphiArrayLifetime<T>);
    begin
      :Delphi.System.DynArrayClear(var aDest.fData, ArrayTypeInfo);
    end;

    constructor Copy(var aSource: DelphiArrayLifetime<T>);
    begin
      Copy(var self, var aSource);
    end;

    class operator Assign(var aDest, aSource: DelphiArrayLifetime<T>);
    begin
      Assign(var aDest, var aSource);
    end;

    finalizer;
    begin
      Release(var self);
    end;
  end;
end.
