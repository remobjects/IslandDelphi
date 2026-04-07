namespace RemObjects.Elements.System;

method SetLength<T>(var aArray: array of T; aNewLength: Int32); public;
begin
  if assigned(aArray) and (aNewLength ≠ length(aArray)) then begin
    var lNewArray := new T[aNewLength];
    for i := 0 to Math.Min(length(aArray), length(lNewArray)) do
      lNewArray[i] := aArray[i];
    aArray := lNewArray;
  end;
end;

end.