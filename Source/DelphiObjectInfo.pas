namespace RemObjects.Elements.System;

uses
  Delphi.System,
  Delphi.System.TypInfo;

type
  [Internal]
  Delphi.System.PDynaMethodTable = public ^Delphi.System.TDynaMethodTable;

  [Internal]
  Delphi.System.TDynaMethodTable = public record
  public
    var Count: UInt16;
    var Selectors: array of Int16;
  end;

  [Internal]
  DelphiObjectInfo = public class
  public

    constructor withObject(aObject: not nullable TObject);
    begin
      fVMT := ^Void((^IntPtr(aObject))^);
    end;

    constructor withClass(aClass: class of TObject);
    begin
      fVMT := ^Void(aClass);
    end;

    constructor withVMT(aVMT: not nullable ^Void);
    begin
      fVMT := aVMT;
    end;

    property VMT: ^Void read fVMT;

    property Parent: DelphiObjectInfo := if assigned(PointerAtOffset(:Delphi.System.vmtParent)) then new DelphiObjectInfo withVMT(^^Void(PointerAtOffset(:Delphi.System.vmtParent))^); lazy;
    property ParentAddress: ^Void read PointerAtOffset(:Delphi.System.vmtParent);

    property InstanceSize: Cardinal read (^Cardinal(fVMT+:Delphi.System.vmtInstanceSize))^;
    property ClassName: String read (^DelphiShortString(PointerAtOffset(:Delphi.System.vmtClassName)))^ as String;
    property DynamicMethodTable: :Delphi.System.PDynaMethodTable read :Delphi.System.PDynaMethodTable(PointerAtOffset(:Delphi.System.vmtDynamicTable));

    property MethodDefinitionTable: PVmtMethodTable read PVmtMethodTable(PointerAtOffset(:Delphi.System.vmtMethodTable));
    property FieldDefinitionTable: PVmtFieldTable read PVmtFieldTable(PointerAtOffset(:Delphi.System.vmtFieldTable));
    //property TypeInformationTable: ^Void read PointerAtOffset(:Delphi.System.vmtTypeInfo);
    //property InstanceInitializationTable: ^Void read PointerAtOffset(:Delphi.System.vmtInitTable);
    //property AutomationInformationTable: ^Void read PointerAtOffset(:Delphi.System.vmtAutoTable);
    property InterfaceTable: PInterfaceTable read PInterfaceTable(PointerAtOffset(:Delphi.System.vmtIntfTable));
    property VirtualMethodTable: ^Void read PointerAtOffset(:Delphi.System.vmtSelfPtr);

    property TypeInfo: PTypeInfo read PointerAtOffset(:Delphi.System.vmtTypeInfo);


    method PointerAtOffset(aOffset: IntPtr): ^Void;
    begin
      result := (^^Void(fVMT+aOffset))^;
    end;

    method Ancestors: sequence of DelphiObjectInfo; iterator;
    begin
      var lCurrent := Parent;
      while assigned(lCurrent) do begin
        yield lCurrent;
        lCurrent := lCurrent.Parent;
      end;
    end;

    method Dump;
    begin
      writeLn($"ClassName {ClassName}");
      writeLn($"InstanceSize {InstanceSize}");
      writeLn($"VMT {VMT}");

      //writeLn($"DynamicMethodTable {DynamicMethodTable}");
      //if assigned(DynamicMethodTable) then begin
        //writeLn($"{DynamicMethodTable.Count} dynamic method(s)");
        //for i := 0 to DynamicMethodTable.Count-1 do
          //writeLn($"Selector[{i}]: {DynamicMethodTable.Selectors[i]}");
      //end;

      if VirtualMethodTable ≠ fVMT then
        writeLn($"VirtualMethodTable {VirtualMethodTable}"); // normally just points back to the VMT

      writeLn($"InterfaceTable {InterfaceTable}");
      if assigned(InterfaceTable) then begin
        writeLn($"{InterfaceTable.EntryCount} interface(s) implemented");
        //for i := 0 to InterfaceTable.EntryCount-1 do
          //writeLn($"Selector[{i}]: {(InterfaceTable^.Entries[i].IID as Guid).ToString}");
      end;

      writeLn($"MethodDefinitionTable {MethodDefinitionTable}");
      if assigned(MethodDefinitionTable) then begin
        writeLn($"{MethodDefinitionTable.Count} method(s)");
        //for i := 0 to MethodDefinitionTable.Count-1 do
          //writeLn($"Selector[{i}]: {MethodDefinitionTable.Selectors[i]}");
      end;

      writeLn($"FieldDefinitionTable {FieldDefinitionTable}");
      if assigned(FieldDefinitionTable) then begin
        writeLn($"{FieldDefinitionTable.Count} fields(s)");
        //for i := 0 to FieldDefinitionTable.Count-1 do
          //writeLn($"Selector[{i}]: {FieldDefinitionTable^.Selectors[i]}");
      end;

      writeLn($"TypeInfo {TypeInfo}");
      if assigned(TypeInfo) then begin
        writeLn($"TypeInfo.Kind {Int32(TypeInfo.Kind)} – Is Class? {Int32(TypeInfo.Kind) = 7}");
        writeLn($"TypeInfo.Name {TypeInfo.Name as DelphiShortString as IslandString}"); // hack for E26339: Island/Delphi: explicit cast not called
        //writeLn($"TypeInfo.NameFld {TypeInfo.NameFld}"); // AV
        var lTypeData := TypeInfo.TypeData;
        writeLn($"TypeData {lTypeData}");
        //writeLn($"lTypeData.UnitNameFld {lTypeData.UnitNameFld}"); // AV
        writeLn($"lTypeData.UnitName {lTypeData.UnitName as DelphiShortString as IslandString}"); // hack for E26339: Island/Delphi: explicit cast not called
        //writeLn($"lTypeData.DynUnitName {lTypeData.DynUnitName as DelphiShortString as IslandString}"); // hack for E26339: Island/Delphi: explicit cast not called
        //writeLn($"lTypeData.IntfUnit {lTypeData.IntfUnit as DelphiShortString as IslandString}"); // hack for E26339: Island/Delphi: explicit cast not called

        writeLn($"lTypeData.ClassType {^Void(lTypeData.ClassType)} – Matches VMT? {^Void(lTypeData.ClassType) = VMT}");
        writeLn($"lTypeData.PropCount {lTypeData.PropCount} Properties");

        var lPropertyData := lTypeData.PropData;
        if assigned(lPropertyData) then begin
          writeLn($"lPropertyData {lPropertyData}");
          writeLn($"lPropertyData.PropCount {lPropertyData.PropCount}");
        end;
      end;

      writeLn($"ParentAddress {ParentAddress}");
      writeLn();
      if assigned(Parent) then
        Parent.Dump;
    end;

  private

    fVMT: ^Void;

    class method DumpMemory(aAddress: ^Void);
    begin
      for i := -100 to 100 do
        writeLn($"^AnsiChar(aType{if i < 0 then '-' else '+'}{ABS(i)})^ ({^Byte(aAddress+i)^}) {^AnsiChar(aAddress+i)^}");
    end;

  end;


end.