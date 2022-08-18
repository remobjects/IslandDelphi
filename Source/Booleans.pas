namespace RemObjects.Elements.System;

type

  DelphiBool16 = public record
  public

    operator &True(aValue: DelphiBool16): Boolean;
    begin
      result := aValue.Value ≠ 0;
    end;

    operator &False(aValue: DelphiBool16): Boolean;
    begin
      result := aValue.Value = 0;
    end;

    operator Implicit(aValue: DelphiBool16): Boolean;
    begin
      result := aValue.Value = 0;
    end;

    operator Implicit(aValue: Boolean): DelphiBool16;
    begin
      result.Value := if aValue then 1 else 0;
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := (Value > 0).ToString;
    end;

  private
    Value: UInt16;
  end;

  DelphiBool32 = public record
  public

    operator &True(aValue: DelphiBool32): Boolean;
    begin
      result := aValue.Value ≠ 0;
    end;

    operator &False(aValue: DelphiBool32): Boolean;
    begin
      result := aValue.Value = 0;
    end;

    operator Implicit(aValue: DelphiBool32): Boolean;
    begin
      result := aValue.Value = 0;
    end;

    operator Implicit(aValue: Boolean): DelphiBool32;
    begin
      result.Value := if aValue then 1 else 0;
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := (Value > 0).ToString;
    end;

  private
    Value: UInt32;
  end;

  DelphiBool64 = public record
  public

    operator &True(aValue: DelphiBool64): Boolean;
    begin
      result := aValue.Value ≠ 0;
    end;

    operator &False(aValue: DelphiBool64): Boolean;
    begin
      result := aValue.Value = 0;
    end;

    operator Implicit(aValue: DelphiBool64): Boolean;
    begin
      result := aValue.Value = 0;
    end;

    operator Implicit(aValue: Boolean): DelphiBool64;
    begin
      result.Value := if aValue then 1 else 0;
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := (Value > 0).ToString;
    end;

  private
    Value: UInt64;
  end;

  [Error("Delphi APIs using boolan sizes other than 8, 16, 32 or 64 not available from Elements (yet)")]
  DelphiUnsupportedBool = public record
  end;

end.