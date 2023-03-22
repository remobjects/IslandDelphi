﻿namespace RemObjects.Elements.System;

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

      // STILL BAD FOR OUR OBJECTS
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
        var p := ^Void(MethodDefinitionTable);
        var lCount := ^Word(p)^;
        writeLn($"lCount {lCount}");

        while lCount > 0 do begin
          var lMethod := PMethRec(p);
          var lName := ^DelphiShortString(p+sizeOf(TMethRec))^ as IslandString;
          writeLn($"lName {lName} {lMethod.MethAddr}");
          inc(p, lMethod.RecSize);
          dec(lCount);
        end;
      end;

      writeLn($"FieldDefinitionTable {FieldDefinitionTable}");
      if assigned(FieldDefinitionTable) then begin
        writeLn($"{FieldDefinitionTable.Count} fields(s)");
        //for i := 0 to FieldDefinitionTable.Count-1 do
          //writeLn($"Selector[{i}]: {FieldDefinitionTable^.Selectors[i]}");
      end;

      writeLn($"TypeInfo {TypeInfo}");
      if assigned(TypeInfo) then begin
        writeLn($"TypeInfo Kind: {Int32(TypeInfo.Kind)} – Is Class? {Int32(TypeInfo.Kind) = 7}");
        writeLn($"TypeInfo Name: {TypeInfo.Name as DelphiShortString as IslandString}"); // hack for E26339: Island/Delphi: explicit cast not called

        var lTypeData := TypeInfo.TypeData;
        writeLn($"TypeData {lTypeData}");
        //writeLn($"lTypeData.UnitNameFld {lTypeData.UnitNameFld}"); // AV
        writeLn($"TypeData UnitName: {lTypeData.UnitName as DelphiShortString as IslandString}"); // hack for E26339: Island/Delphi: explicit cast not called
        writeLn($"TypeData DynUnitName: {lTypeData.DynUnitName as DelphiShortString as IslandString}"); // hack for E26339: Island/Delphi: explicit cast not called
        writeLn($"TypeData IntfUnit: {lTypeData.IntfUnit as DelphiShortString as IslandString}"); // hack for E26339: Island/Delphi: explicit cast not called
        writeLn($"TypeData Class Type: {^Void(lTypeData.ClassType)} – Matches VMT? {^Void(lTypeData.ClassType) = VMT}");
        if assigned(lTypeData.ParentInfo) then
          writeLn($"TypeData Parent Info: {^^Void(lTypeData.ParentInfo)^}");
        writeLn($"TypeData Property Count: {lTypeData.PropCount} Properties");

        var lPropertyData := lTypeData.PropData;
        if assigned(lPropertyData) then begin
          var lData := ^TPropData2(lPropertyData);
          writeLn($"lPropertyData: {lPropertyData}");
          writeLn($"lPropertyData PropteryInfo Count: {lData.PropCount}");
          var p := ^Void(@lData.PropList);
          assert(sizeOf(TPropInfo2) = 42);
          for i := 0 to lData.PropCount-1 do begin
            var lProperty := PPropInfo2(p);
            var lName := ^DelphiShortString(p+sizeOf(TPropInfo2))^;
            writeLn($"Property Name: {lName as DelphiShortString as IslandString}");
            if assigned(lProperty.PropType) then
              writeLn($"  PropType: {^^Void(lProperty.PropType)}");
            writeLn($"  GetProc {lProperty.GetProc}");
            writeLn($"  SetProc {lProperty.SetProc}");
            writeLn($"  Index: {lProperty.Index}");
            writeLn($"  Default {lProperty.Default}");
            writeLn($"  NameIndex {lProperty.NameIndex}");
            //inc(p, sizeOf(TPropInfo2)+length(lName)+1); // doesnt call Length
            //p := p + sizeOf(TPropInfo2)+(lName.Length)+1; // E643 Cannot call Object methods on a static array
            p := p + sizeOf(TPropInfo2)+ord(lName[0])+1;
          end;

          //var lExData := ^TPropDataEx(lPropertyData);
          //writeLn($"lPropertyData PropteryInfoEx Count {lExData.PropCount}");
          //for i := 0 to lExData.PropCount-1 do begin
            //var lProperty := PPropInfoEx(p);
            //writeLn($"lProperty.Flags {lProperty.Flags}");
            //writeLn($"lProperty.AttrData {lProperty.AttrData}");
            //writeLn($"lProperty.Info {lProperty.Info}");

          //end;

        end;
      end;

      writeLn($"ParentAddress at {ParentAddress}");
      if assigned(ParentAddress) then begin
        writeLn($"ParentAddress {^^Void(PointerAtOffset(:Delphi.System.vmtParent))^}");
        writeLn();
        Parent.Dump;
      end;
    end;

  private

    fVMT: ^Void;

    //class method DumpMemory(aAddress: ^Void);
    //begin
      //for i := 0 to 100 do
        //writeLn($"^AnsiChar(aType{if i > 0 then '+'}{i})^ ({^Byte(aAddress+i)^}) {^AnsiChar(aAddress+i)^}");
    //end;

  end;

  {$HIDE H6} // H6 Field "StoredProc" defined in type "TPropInfo2" is never used
  {$HIDE H8} // H8 Field "PropType" defined in type "TPropInfo2" is never assigned

  PMethRec = ^TMethRec;
  TMethRec = assembly packed record
    RecSize: Word;
    MethAddr: Pointer;
    //Name: TSymbolName; // Is sized dynamically
  end;

  //E26467: Island/Delphi: IE System.IndexOutOfRangeException building DephiSupport in latest

  TPropData2 = assembly packed record
    PropCount: Word;
    PropList: /*array[0..0] of */ TPropInfo; // Not really an array
  end;

  PPropInfo2 = ^TPropInfo2;
  TPropInfo2 = assembly packed record
    PropType: PPTypeInfo; //8
    GetProc: Pointer; //8
    SetProc: Pointer; //8
    StoredProc: Pointer; //8
    &Index: Integer; //4

    &Default: Integer; //4
    NameIndex: SmallInt; //2
    //Name: TSymbolName; // Is sized dynamically
  end;

  TPropDataEx2 = packed record
    PropCount: Word;
    PropList: /*array[0..0] of */ TPropInfoEx; // Not really an array
  end;

  PPropInfoEx2 = ^TPropInfoEx2;
  TPropInfoEx2 = packed record
    Flags: Byte;
    Info: PPropInfo;
    AttrData: TAttrData
  end;

end.