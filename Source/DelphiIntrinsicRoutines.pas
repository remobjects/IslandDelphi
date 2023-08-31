namespace Delphi.System;

function Abs(X: Real): Real; inline; public;
begin
  result := RemObjects.Elements.System.Math.Abs(X);
end;

function Abs(X: Int64): Int64; inline; public;
begin
  result := RemObjects.Elements.System.Math.Abs(X);
end;

function Abs(X: Integer): Integer; inline; public;
begin
  result := RemObjects.Elements.System.Math.Abs(X);
end;

function Addr(var X): Pointer; inline; public;
begin
  result := @X;
end;

// assert
// assigned

function AtomicCmpExchange(var Target: Integer; NewValue: Integer; Comparand: Integer; out Succeeded: Boolean): Integer; inline; public;
begin
  result := interlockedCompareExchange(var Target, Comparand, NewValue)
end;

function AtomicCmpExchange(var Target: Int64; NewValue: Int64; Comparand: Int64; out Succeeded: Boolean): Int64; inline; public;
begin
  result := interlockedCompareExchange(var Target, Comparand, NewValue)
end;

function AtomicCmpExchange(var Target: Pointer; NewValue: Pointer; Comparand: Pointer; out Succeeded: Boolean): Pointer; inline; public;
begin
  result := interlockedCompareExchange(var Target, Comparand, NewValue)
end;

//function AtomicCmpExchange(var Target; NewValue: Integer; Comparand: Integer; out Succeeded: Boolean): Integer; public;
//function AtomicCmpExchange(var Target; NewValue: NativeInt; Comparand: NativeInt; out Succeeded: Boolean): Int64; public;
//function AtomicCmpExchange(var Target; NewValue: Pointer>; Comparand: Pointer; out Succeeded: Boolean): Pointer; public;

function AtomicDecrement(var Target: Integer): Integer; inline; public;
begin
  result := interlockedDec(var Target)-1;
end;

function AtomicDecrement(var Target: Int64): Int64; inline; public;
begin
  result := interlockedDec(var Target)-1;
end;

function AtomicDecrement(var Target: Pointer): Pointer; inline; public;
begin
  result := interlockedDec(var Target)-1;
end;

function AtomicDecrement(var Target: Integer; Decrement: Integer): Integer; inline; public;
begin
  result := interlockedDec(var Target)-Decrement;
end;

function AtomicDecrement(var Target: Int64; Decrement: Int64): Int64; inline; public;
begin
  result := interlockedDec(var Target, Decrement)-Decrement;
end;

function AtomicDecrement(var Target: Pointer; Decrement: NativeInt): Pointer; inline; public;
begin
  result := interlockedDec(var Target, Decrement)-Decrement;
end;

function AtomicExchange(var Target: Integer; Value: Integer): Integer; inline; public;
begin
  result := interlockedExchange(var Target, Value);
end;

function AtomicExchange(var Target: Int64; Value: Int64): Int64; inline; public;
begin
  result := interlockedExchange(var Target, Value);
end;

function AtomicExchange(var Target: Pointer; Value: Pointer): Pointer; inline; public;
begin
  result := interlockedExchange(var Target, Value);
end;

//function AtomicExchange(var Target; Value: NativeInt): NativeInt; public;
//begin

//end;

function AtomicIncrement(var Target: Integer): Integer; inline; public;
begin
  result := interlockedInc(var Target)+1;
end;

function AtomicIncrement(var Target: Integer; Increment: Integer): Integer; inline; public;
begin
  result := interlockedInc(var Target, Increment)+Increment;
end;

function AtomicIncrement(var Target: Int64): Int64; inline; public;
begin
  result := interlockedInc(var Target)+1;
end;

function AtomicIncrement(var Target: Int64; Increment: Int64): Int64; inline; public;
begin
  result := interlockedInc(var Target, Increment)+Increment;
end;

function AtomicIncrement(var Target: Pointer): Pointer; inline; public;
begin
  result := interlockedInc(var Target)+1;
end;

function AtomicIncrement(var Target: Pointer; Increment: NativeInt): Pointer; inline; public;
begin
  result := interlockedInc(var Target, Increment)+Increment;
end;

// break
//...
// chr

function Concat(S1: string; S2: string): string; inline; public;
begin
  result := S1+S2;
end;

function Concat(S1: string; params S2: sequence of string): string; public;
begin
  var lSB := new StringBuilder;
  lSB.Append(S1);
  for each s in S2 do
    lSB.Append(s);
  result := lSB.ToString;
end;

function Concat<T>(S1: array of T; S2: array of T): array of T; public;
begin
  result := new array of T(length(S1)+length(S2));
  for i := 0 to length(S1)-1 do
    result[i] := S1[i];
  for i := 0 to length(S2)-1 do
    result[length(S1)+i] := S2[i];
end;

function Concat<T>(S1: array of T; params S2: array of array of T): array of T; public;
begin
  var len := length(S1);
  for each s in S2 do
    len := len+length(s);
  result := new array of T(len);

  for i := 0 to length(S1)-1 do
    result[i] := S1[i];

  var offset := length(S1);
  for each s in S2 do begin
    for i := 0 to length(s)-1 do
      result[offset+i] := s[i];
    inc(offset, length(s));
  end;
end;

//continue
//function Copy(S: <string or dynamic array>; Index: Integer; Count: Integer): string;
// dec
// default
procedure Delete(var S: string; &Index: Integer; Count: Integer); public;
begin
  if Count > 0 then
    S := (S as IslandString).Remove(&Index, Count); {$HINT this casts. maybe optimize later?}
end;

procedure Delete<T>(var S: array of T; &Index: Integer; Count: Integer); public;
begin
  raise new NotImplementedException("Delete is not implemented");
end;


//procedure Dispose(var P: Pointer); public;
// exclude
// exit
//procedure Fail; public;

procedure FillChar(var X; Count: Integer; Value: Integer); public;
begin
  RemObjects.Elements.System.memset(@X, Value, Count);
end;

//procedure Finalize(var V; [ Count: NativeUInt]); public;
//procedure Finalize(var V; [ Count: NativeUInt]); public;

procedure FreeMem(var P: Pointer); inline; public;
begin
  :Delphi.System.SysFreeMem(P);
end;

procedure FreeMem(var P: Pointer; Size: Integer); public;
begin
  :Delphi.System.SysFreeMem(P/*, Size*/);
end;

//procedure GetDir(Drive: Byte; var S: String); public;
// GetTypeKind
//procedure Halt([ExitCode: Integer]); public;
//procedure Halt([ExitCode: Integer]); public;

function Hi(X: Integer): Byte; inline; public;
begin
  result := (Word(X) and $ff00) shr 8;
end;

//high
//inc
//include
//procedure Initialize(var V; [ Count: NativeUInt]); public;

procedure Insert(Source: string; var Dest: string; &Index: Integer); public;
begin
  Dest := (Dest as IslandString).Insert(&Index, Source); {$HINT this casts. maybe optimize later?}
end;

procedure Insert<T>(Source: array of T; var Dest: array of T; &Index: Integer); public;
begin
  raise new NotImplementedException("Insert is not implemented");
end;

function Lo(X: Integer): Byte; inline; public;
begin
  result := Word(X) and $ff;
end;

// IsManagedType
//length
//low
//procedure MemoryBarrier; public;

function MulDivInt64(AValue, AMul, ADiv: Int64): Int64; public;
begin
  result := MulDivInt64(AValue, AMul, ADiv, out nil);
end;

function MulDivInt64(AValue, AMul, ADiv: Int64; out Remainder: Int64): Int64; public;
begin
  raise new NotImplementedException("MulDivInt64 is not implemented");
end;

//procedure New(var X: Pointer); public;

function Odd(X: Integer): Boolean; inline; public;
begin
  result := (X mod 2) ≠ 0
end;

//ord

function Pi: Extended; public;
begin
  //result := RemObjects.Elements.System.Math.PI;
  raise new NotImplementedException("Pi is not implemented");
end;

// pred

function Ptr(Address: Integer): Pointer; inline; public;
begin
  result := ^Void(Address);
end;

//procedure ReallocMem(var P: Pointer; Size: Integer); public;

function Round(X: Real): Int64; public;
begin
  result := Int64(RemObjects.Elements.System.Math.Round(X));
end;

procedure RunError; public;
begin
  raise new NotImplementedException("RunError is not implemented");
end;

procedure RunError(ErrorCode: Byte); public;
begin
  raise new NotImplementedException("RunError is not implemented");
end;

method SetLength<T>(var aArray: array of T; aNewLength: Int32); public; inline;
begin
  if aNewLength < length(aArray) then begin
    aArray := &Array.SubArray(aArray, 0, aNewLength);
  end
  else if aNewLength > length(aArray) then begin
    var lNewArray := new array of T(aNewLength);
    &Array.Copy(aArray, lNewArray, length(aArray));
    aArray := lNewArray;
  end;
end;

// sizeOf

function Slice(var A: Array; Count: Integer): Pointer; public;
begin
  raise new NotImplementedException("Slice is not implemented");
end;

function Sqr(X: Real): Extended; public;
begin
  raise new NotImplementedException("Sqr is not implemented");
end;

function Sqr(X: Int64): Int64; public;
begin
  raise new NotImplementedException("Sqr is not implemented");
end;

function Sqr(X: Integer): Integer; public;
begin
  raise new NotImplementedException("Sqr is not implemented");
end;

//procedure Str(const X [: Width [:Decimals]]; var S: String);
procedure Str(const X: Object; var S: string); public;
begin
  S := X:ToString;
end;

// succ

function Swap(X: Word/*Integer*/): Word/*Integer*/; inline; public;
begin
  result := Hi(X)+(Lo(X) shl 8)
end;

function Trunc(X: Real): Int64; public;
begin
  result := Int64(RemObjects.Elements.System.Math.Truncate(X));
end;

//function TypeHandle(T: TypeIdentifier): Pointer; public;
//function TypeInfo(T: TypeIdentifier): Pointer; public;
//typeOf
//procedure Val(S: String; var V; var Code: Integer); public;

procedure VarArrayRedim(var A: Variant; HighBound: Integer); public;
begin
  raise new NotImplementedException("VarCast is not implemented");
end;

procedure VarCast(var Dest: Variant; Source: Variant; VarType: Integer); public;
begin
  raise new NotImplementedException("VarCast is not implemented");
end;

procedure VarClear(var V: Variant); public;
begin
  RemObjects.Elements.System.memset(@V, 0, sizeOf(Variant));
end;

procedure VarCopy(var Dest: Variant; Source: Variant); public;
begin
  RemObjects.Elements.System.memcpy(@Dest, ^Void(@Source), sizeOf(Variant));
end;

end.