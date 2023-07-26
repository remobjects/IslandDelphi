namespace Delphi.System;

function Abs(X: Real): Real; inline;
begin
  result := RemObjects.Elements.System.Math.Abs(X);
end;

function Abs(X: Int64): Int64; inline;
begin
  result := RemObjects.Elements.System.Math.Abs(X);
end;

function Abs(X: Integer): Integer; inline;
begin
  result := RemObjects.Elements.System.Math.Abs(X);
end;

function Addr(var X): Pointer; inline;
begin
  result := @X;
end;

// assert
// assigned

function AtomicCmpExchange(var Target: Integer; NewValue: Integer; Comparand: Integer; out Succeeded: Boolean): Integer; inline;
begin
  result := interlockedCompareExchange(var Target, Comparand, NewValue)
end;

function AtomicCmpExchange(var Target: Int64; NewValue: Int64; Comparand: Int64; out Succeeded: Boolean): Int64; inline;
begin
  result := interlockedCompareExchange(var Target, Comparand, NewValue)
end;

function AtomicCmpExchange(var Target: Pointer; NewValue: Pointer; Comparand: Pointer; out Succeeded: Boolean): Pointer; inline;
begin
  result := interlockedCompareExchange(var Target, Comparand, NewValue)
end;

//function AtomicCmpExchange(var Target; NewValue: Integer; Comparand: Integer; out Succeeded: Boolean): Integer;
//function AtomicCmpExchange(var Target; NewValue: NativeInt; Comparand: NativeInt; out Succeeded: Boolean): Int64;
//function AtomicCmpExchange(var Target; NewValue: Pointer>; Comparand: Pointer; out Succeeded: Boolean): Pointer;

function AtomicDecrement(var Target: Integer): Integer; inline;
begin
  interlockedDec(var Target);
end;

function AtomicDecrement(var Target: Int64; Decrement: Int64): Int64; inline;
begin
  interlockedDec(var Target, Decrement);
end;

function AtomicDecrement(var Target: Pointer; Decrement: NativeInt): Pointer; inline;
begin
  interlockedDec(var Target, Decrement);
end;

function AtomicExchange(var Target: Integer; Value: Integer): Integer; inline;
begin
  interlockedExchange(var Target, Value);
end;

function AtomicExchange(var Target: Int64; Value: Int64): Int64; inline;
begin
  interlockedExchange(var Target, Value);
end;

function AtomicExchange(var Target: Pointer; Value: Pointer): Pointer; inline;
begin
  interlockedExchange(var Target, Value);
end;

//function AtomicExchange(var Target; Value: NativeInt): NativeInt;
//begin

//end;

function AtomicIncrement(var Target: Integer): Integer; inline;
begin
  interlockedInc(var Target);
end;

function AtomicIncrement(var Target: Integer; Increment: Integer): Integer; inline;
begin
  interlockedInc(var Target, Increment);
end;

function AtomicIncrement(var Target: Int64): Int64; inline;
begin
  interlockedInc(var Target);
end;

function AtomicIncrement(var Target: Int64; Increment: Int64): Int64; inline;
begin
  interlockedInc(var Target, Increment);
end;

function AtomicIncrement(var Target: Pointer): Pointer; inline;
begin
  interlockedInc(var Target);
end;

function AtomicIncrement(var Target: Pointer; Increment: NativeInt): Pointer; inline;
begin
  interlockedInc(var Target, Increment);
end;

// break
//...
// chr

function Concat(S1: string; S2: string): string; inline;
begin
  result := S1+S2;
end;

function Concat(S1: string; params S2: sequence of string): string;
begin
  var lSB := new StringBuilder;
  lSB.Append(S1);
  for each s in S2 do
    lSB.Append(s);
  result := lSB.ToString;
end;

function Concat<T>(S1: array of T; S2: array of T): array of T;
begin
  result := new array of T(length(S1)+length(S2));
  {$HINT copy}
  raise new NotImplementedException("Concat is not implemented");
end;

function Concat<T>(S1: array of T; params S2: array of array of T): array of T;
begin
  var len := length(S1);
  for each s in S2 do
    len := len+length(s);
  result := new array of T(len);
  {$HINT copy}
  raise new NotImplementedException("Concat is not implemented");
end;

//continue
//function Copy(S: <string or dynamic array>; Index: Integer; Count: Integer): string;
// dec
// default
procedure Delete(var S: string; &Index: Integer; Count: Integer);
begin
  if Count > 0 then
    S := (S as IslandString).Remove(&Index, Count); {$HINT this casts. maybe optimize later?}
end;

procedure Delete<T>(var S: array of T; &Index: Integer; Count: Integer);
begin
  raise new NotImplementedException("Delete is not implemented");
end;


//procedure Dispose(var P: Pointer);
// exclude
// exit
//procedure Fail;
//procedure FillChar(var X; Count: Integer; Value: Ordinal);
//procedure Finalize(var V; [ Count: NativeUInt]);
//procedure Finalize(var V; [ Count: NativeUInt]);

procedure FreeMem(var P: Pointer); inline;
begin
  :Delphi.System.SysFreeMem(P);
end;

procedure FreeMem(var P: Pointer; Size: Integer);
begin
  :Delphi.System.SysFreeMem(P/*, Size*/);
end;

//procedure GetDir(Drive: Byte; var S: String);
// GetTypeKind
//procedure Halt([ExitCode: Integer]);
//procedure Halt([ExitCode: Integer]);

function Hi(X: Integer): Byte; inline;
begin
  result := (Word(X) and $ff00) shr 8;
end;

//high
//inc
//include
//procedure Initialize(var V; [ Count: NativeUInt]);
//procedure Initialize(var V; [ Count: NativeUInt]);
procedure Insert(Source: string; var Dest: string; &Index: Integer);
begin
  Dest := (Dest as IslandString).Insert(&Index, Source); {$HINT this casts. maybe optimize later?}
end;

procedure Insert<T>(Source: array of T; var Dest: array of T; &Index: Integer);
begin
  raise new NotImplementedException("Insert is not implemented");
end;

function Lo(X: Integer): Byte; inline;
begin
  result := Word(X) and $ff;
end;

// IsManagedType
//length
//low
//procedure MemoryBarrier;

function MulDivInt64(AValue, AMul, ADiv: Int64): Int64;
begin
  MulDivInt64(AValue, AMul, ADiv, out nil);
end;

function MulDivInt64(AValue, AMul, ADiv: Int64; out Remainder: Int64): Int64;
begin
  raise new NotImplementedException("MulDivInt64 is not implemented");
end;

//procedure New(var X: Pointer);

function Odd(X: Integer): Boolean; inline;
begin
  result := (X mod 2) ≠ 0
end;

//ord

function Pi: Extended;
begin
  //result := RemObjects.Elements.System.Math.PI;
  raise new NotImplementedException("Pi is not implemented");
end;

// pred

function Ptr(Address: Integer): Pointer; inline;
begin
  result := ^Void(Address);
end;

//procedure ReallocMem(var P: Pointer; Size: Integer);

function Round(X: Real): Int64;
begin
  result := Int64(RemObjects.Elements.System.Math.Round(X));
end;

procedure RunError;
begin
  raise new NotImplementedException("RunError is not implemented");
end;

procedure RunError(ErrorCode: Byte);
begin
  raise new NotImplementedException("RunError is not implemented");
end;

// sizeOf

function Slice(var A: Array; Count: Integer): Pointer;
begin
  raise new NotImplementedException("Slice is not implemented");
end;

function Sqr(X: Real): Extended;
begin
  raise new NotImplementedException("Sqr is not implemented");
end;

function Sqr(X: Int64): Int64;
begin
  raise new NotImplementedException("Sqr is not implemented");
end;

function Sqr(X: Integer): Integer;
begin
  raise new NotImplementedException("Sqr is not implemented");
end;

//procedure Str(const X [: Width [:Decimals]]; var S: String);
procedure Str(const X: Object; var S: string);
begin
  S := X:ToString;
end;

// succ

function Swap(X: Word/*Integer*/): Word/*Integer*/; inline;
begin
  result := Hi(X)+(Lo(X) shl 8)
end;


function Trunc(X: Real): Int64;
begin
  result := Int64(RemObjects.Elements.System.Math.Truncate(X));
end;

//function TypeHandle(T: TypeIdentifier): Pointer;
//function TypeInfo(T: TypeIdentifier): Pointer;
//typeOf
//procedure Val(S: String; var V; var Code: Integer);

procedure VarArrayRedim(var A: Variant; HighBound: Integer);
begin
  raise new NotImplementedException("VarCast is not implemented");
end;

procedure VarCast(var Dest: Variant; Source: Variant; VarType: Integer);
begin
  raise new NotImplementedException("VarCast is not implemented");
end;

procedure VarClear(var V: Variant);
begin
  rtl.memset(@V, 0, sizeOf(Variant));
end;

procedure VarCopy(var Dest: Variant; Source: Variant);
begin
  rtl.memcpy(@Dest, @Source, sizeOf(Variant));
end;

end.