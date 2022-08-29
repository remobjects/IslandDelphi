namespace RemObjects.Elements.System;

type
  DelphiLongStringRC<T> = public lifetimestrategy (DelphiLongStringRC) T;
  DelphiLongStringRC = public record(ILifetimeStrategy<DelphiLongStringRC>)
  private

    fValue: IntPtr;

  public

    class method &New(aTTY: ^Void; aSize: IntPtr): ^Void;
    begin
      writeLn("DelphiLongStringRC: New");
      // ??
    end;

    class method Init(var aDestination: DelphiLongStringRC); //empty; // zero value
    begin
    writeLn("DelphiLongStringRC: Init");
    end;

    class method &Copy(var aDestination, aSource: DelphiLongStringRC);
    begin
      writeLn("DelphiLongStringRC: Copy");
      if (@aDestination) = (@aSource) then
        exit;
      if aDestination.fValue = aSource.fValue then
        exit;
      if aDestination.fValue ≠ 0 then
        Release(var aDestination); // just like assign, but this one releases old
      aDestination.fValue := aSource.fValue;
      DelphiStringHelpers.AdjustLongStringReferenceCount(^Void(aSource.fValue), 1);
    end;

    constructor &Copy(var aSource: DelphiLongStringRC);
    begin
      writeLn("DelphiLongStringRC: Copy ctor");
      if aSource.fValue = 0 then
        exit;
      fValue := aSource.fValue;
      DelphiStringHelpers.AdjustLongStringReferenceCount(^Void(aSource.fValue), 1);
    end;

    class operator Assign(var aDestination: DelphiLongStringRC; var aSource: DelphiLongStringRC);
    begin
      writeLn($"DelphiLongStringRC: Assign operator {IntPtr(aSource.fValue)} => {IntPtr(aDestination.fValue)}");
      if (@aDestination) = (@aSource) then
        exit;
      if aDestination.fValue = aSource.fValue then
        exit;
      aDestination.fValue := aSource.fValue;
      DelphiStringHelpers.AdjustLongStringReferenceCount(^Void(aSource.fValue), 1);
    end;

    class method Assign(var aDestination, aSource: DelphiLongStringRC);
    begin
      writeLn($"DelphiLongStringRC: Assign {IntPtr(aSource.fValue)} => {IntPtr(aDestination.fValue)}");
      if (@aDestination) = (@aSource) then
        exit;
      if aDestination.fValue = aSource.fValue then
        exit;
      aDestination.fValue := aSource.fValue;
      DelphiStringHelpers.AdjustLongStringReferenceCount(^Void(aSource.fValue), 1);
    end;

    class method Release(var aDestination: DelphiLongStringRC);
    begin
      writeLn($"DelphiLongStringRC: Release {IntPtr(aDestination.fValue)} {DelphiStringHelpers.DelphiStringReferenceCount(^Void(aDestination.fValue))}");
      if aDestination.fValue = 0 then
        exit;
      DelphiStringHelpers.ReleaseDelphiLongString(^Void(aDestination.fValue))
    end;

    finalizer;
    begin
      writeLn("DelphiLongStringRC: Finalizer");
      //Release(var self);
    end;

  end;

end.