namespace RemObjects.Elements.System;

{$IF NOT NO_TYPEINFO_APIS}
{$IF DELPHI11}

uses
  Delphi.System,
  Delphi.System.TypInfo;

type
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

    property Parent: DelphiObjectInfo := if assigned(ParentAddress) and assigned(^^Void(ParentAddress)^) then new DelphiObjectInfo withVMT(^^Void(ParentAddress)^); lazy;
    property Ancestry: String := if assigned(Parent) then $": {Parent.ClassName}{Parent.Ancestry}" else ""; lazy;

    property ParentAddress:         ^Void            read PointerAtOffset(:Delphi.System.vmtParent);
    property InstanceSize:          Cardinal         read (^Cardinal(fVMT+:Delphi.System.vmtInstanceSize))^;
    property ClassName:             String           read (^DelphiShortString(PointerAtOffset(:Delphi.System.vmtClassName)))^ as String;
    property DynamicMethodTable:    PDynaMethodTable read PDynaMethodTable(PointerAtOffset(:Delphi.System.vmtDynamicTable));
    property MethodDefinitionTable: PVmtMethodTable  read PVmtMethodTable(PointerAtOffset(:Delphi.System.vmtMethodTable));
    property FieldDefinitionTable:  PVmtFieldTable   read PVmtFieldTable(PointerAtOffset(:Delphi.System.vmtFieldTable));
    //property TypeInformationTable: ^Void read PointerAtOffset(:Delphi.System.vmtTypeInfo);
    //property InstanceInitializationTable: ^Void read PointerAtOffset(:Delphi.System.vmtInitTable);
    //property AutomationInformationTable: ^Void read PointerAtOffset(:Delphi.System.vmtAutoTable);
    property InterfaceTable:        PInterfaceTable  read PInterfaceTable(PointerAtOffset(:Delphi.System.vmtIntfTable));
    property VirtualMethodTable:    ^Void            read PointerAtOffset(:Delphi.System.vmtSelfPtr);

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
      writeLn($"ClassName {ClassName}{Ancestry}");
      if assigned(Parent) then
        writeLn($"InstanceSize {InstanceSize} (+{Integer(InstanceSize)-Integer(Parent.InstanceSize)})")
      else
        writeLn($"InstanceSize {InstanceSize}");

      writeLn($"VMT {VMT}");
      if VirtualMethodTable ≠ fVMT then // normally just points back to the VMT
        writeLn($"VirtualMethodTable {VirtualMethodTable} (does not match {fVMT})");

      writeLn($"InterfaceTable {InterfaceTable}");
      if assigned(InterfaceTable) then begin
        writeLn($"{InterfaceTable.EntryCount} interface(s) implemented");
        for i := 0 to InterfaceTable.EntryCount-1 do
          writeLn($"- Interface[{i}]: {{{(InterfaceTable^.Entries[i].IID as Guid).ToString.ToUpperInvariant}}} ({InterfaceTable^.Entries[i].VTable})");
      end;

      writeLn($"DynamicMethodTable {DynamicMethodTable}");
      if assigned(DynamicMethodTable) then begin
        writeLn($"{DynamicMethodTable.Count} dynamic method(s)");
        for i := 0 to DynamicMethodTable.Count-1 do
          writeLn($"- Selector[{i}]: {DynamicMethodTable.Selectors[i]}");
      end;

      writeLn($"MethodDefinitionTable {MethodDefinitionTable}");
      if assigned(MethodDefinitionTable) then begin
        writeLn($"{MethodDefinitionTable.Count} method(s)");
        var p := ^Void(MethodDefinitionTable);
        var lCount := ^Word(p)^;
        inc(p, 2);

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
        writeLn($"{FieldDefinitionTable.Count} field(s)");
        if assigned(FieldDefinitionTable.ClassTab) then begin
          writeLn($"{FieldDefinitionTable.ClassTab.Count} field type(s)");
          for i := 0 to FieldDefinitionTable.ClassTab.Count-1 do
            writeLn($"Class[{i}]: {FieldDefinitionTable.ClassTab.ClassRef[i]} = {new DelphiObjectInfo withVMT(^^Void(FieldDefinitionTable.ClassTab.ClassRef[i])^).ClassName}");

          var p: ^Void := FieldDefinitionTable;
          inc(p, sizeOf(TVmtFieldTable));
          if not defined("LINUX") then begin
            for i := 0 to FieldDefinitionTable.Count-1 do begin
              var lEntry := PVmtFieldEntry(p);
              writeLn($"Field[{i}]: {lEntry.Name as DelphiShortString as IslandString}: {lEntry.TypeIndex} at +{lEntry.FieldOffset}");
              inc(p, sizeOf(Cardinal)+sizeOf(Word)+ord(lEntry.Name[0])+1);
            end;
          end;
          var lExtCount := ^Word(p)^;
          inc(p, sizeOf(Word));
          writeLn($"lExtCount {lExtCount}");
          if lExtCount > 0 then begin
            //for i := 0 to lExtCount-1 do begin
              ////...
              //inc(p, sizeOf(TVmtFieldExEntry));
            //end;
          end;
        end;
      end;

      writeLn($"TypeInfo {TypeInfo}");
      if not defined("LINUX") or not defined("DELPHI10_2") then begin // Delphi 10.2 for Linux has some stuff badly defined, so we wont bother.
        if assigned(TypeInfo) then begin
          if TypeInfo.Kind ≠ 7 then
            writeLn($"TypeInfo Kind: {Int32(TypeInfo.Kind)} (should be 7 for class!)");
          if TypeInfo.Name as DelphiShortString as IslandString ≠ ClassName then
            writeLn($"TypeInfo Name: {TypeInfo.Name as DelphiShortString as IslandString} (does not match '{ClassName}')");

          if exists(TypeInfo.TypeData) then begin
            var lTypeData := TypeInfo.TypeData;
            writeLn($"TypeData {lTypeData}");
            //writeLn($"lTypeData.UnitNameFld {lTypeData.UnitNameFld}"); // AV

            if ^Void(lTypeData.ClassType) ≠ VMT then
              writeLn($"TypeData Class Type: {^Void(lTypeData.ClassType)} (does not match {fVMT})");
            if assigned(lTypeData.ParentInfo) then begin
              writeLn($"TypeData Parent Info @: {lTypeData.ParentInfo}");
              writeLn($"TypeData Parent Info: {^^Void(lTypeData.ParentInfo)^}");
            end;
            writeLn($"TypeData Property Count: {lTypeData.PropCount} Properties");
            writeLn($"UnitName: {lTypeData.UnitName as DelphiShortString as IslandString}"); // hack for E26339: Island/Delphi: explicit cast not called

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
        end;
      end;

      //var lVMT := ^^Void(aInstance)^;
      //var lInterfaceTable := (^^Void(lVMT+:Delphi.System.vmtIntfTable))^ as Delphi.System.PInterfaceTable;
      //if not assigned(lInterfaceTable) then
        //exit;

      //for i := 0 to lInterfaceTable.EntryCount-1 do begin
        //writeLn($"lInterfaceTable.Entries[i].VTable {lInterfaceTable.Entries[i].VTable}");
        //writeLn($"lInterfaceTable.Entries[i].IID {lInterfaceTable.Entries[i].IID as Guid}");
        //writeLn($"lInterfaceTable.Entries[i].ImplGetter {lInterfaceTable.Entries[i].ImplGetter}");
        //writeLn($"lInterfaceTable.Entries[i].IOffset {lInterfaceTable.Entries[i].IOffset}");
        //if lGuid = lInterfaceTable.Entries[i].IID as Guid then
          //getInterface
          //exit lInterfaceTable.Entries[i].VTable;
      //end;


      writeLn($"ParentAddress at {ParentAddress}");
      if assigned(ParentAddress) then begin
        writeLn($"ParentAddress {^^Void(PointerAtOffset(:Delphi.System.vmtParent))^}");
        writeLn();
        if assigned(Parent) then
          Parent.Dump;
      end;
    end;

    method DumpFields;
    begin
      writeLn($"ClassName {ClassName}{Ancestry}");
      if assigned(Parent) then
        writeLn($"InstanceSize {InstanceSize} (+{Integer(InstanceSize)-Integer(Parent.InstanceSize)})")
      else
        writeLn($"InstanceSize {InstanceSize}");

      writeLn($"FieldDefinitionTable {FieldDefinitionTable}");
      if assigned(FieldDefinitionTable) then begin
        writeLn($"{FieldDefinitionTable.Count} field(s)");
        writeLn($"FieldDefinitionTable.ClassTab {FieldDefinitionTable.ClassTab}");
        if assigned(FieldDefinitionTable.ClassTab) then begin
          writeLn($"{FieldDefinitionTable.ClassTab.Count} field type(s)");
          for i := 0 to FieldDefinitionTable.ClassTab.Count-1 do
            writeLn($"Class[{i}]: {FieldDefinitionTable.ClassTab.ClassRef[i]} = {new DelphiObjectInfo withVMT(^^Void(FieldDefinitionTable.ClassTab.ClassRef[i])^).ClassName}");

          var p: ^Void := FieldDefinitionTable;
          inc(p, sizeOf(TVmtFieldTable));
          if not defined("LINUX") then begin
            for i := 0 to FieldDefinitionTable.Count-1 do begin
              var lEntry := PVmtFieldEntry(p);
              writeLn($"Field[{i}]: {lEntry.Name as DelphiShortString as IslandString}: {lEntry.TypeIndex} at +{lEntry.FieldOffset}");
              inc(p, sizeOf(Cardinal)+sizeOf(Word)+ord(lEntry.Name[0])+1);
            end;
          end;
          var lExtCount := ^Word(p)^;
          inc(p, sizeOf(Word));
          writeLn($"lExtCount {lExtCount}");
          if lExtCount > 0 then begin
            //for i := 0 to lExtCount-1 do begin
              ////...
              //inc(p, sizeOf(TVmtFieldExEntry));
            //end;
          end;
        end;
      end;

      if assigned(ParentAddress) then begin
        writeLn($"ParentAddress {^^Void(PointerAtOffset(:Delphi.System.vmtParent))^}");
        writeLn();
        if assigned(Parent) then
          Parent.DumpFields;
      end;
    end;

  private

    fVMT: ^Void;

    class method DumpMemory(aAddress: ^Void);
    begin
      for i := 0 to 100 do
        writeLn($"[{if i > 0 then '+'}{i}]^ ({^Byte(aAddress+i)^}) {^AnsiChar(aAddress+i)^}");
    end;

  end;

  {$HIDE H6} // H6 Field is never used
  {$HIDE H7} // H7 Field is assigned to but never read
  {$HIDE H8} // H8 Field is never assigned

  // Dynamic Methods.

  [Internal]
  Delphi.System.PDynaMethodTable = public ^Delphi.System.TDynaMethodTable;

  [Internal]
  Delphi.System.TDynaMethodTable = public packed record
  public
    var Count: UInt16;
    var Selectors: array[0..0] of Int16;
  end;

  // Method RTTI. Type is private in System.pas

  TMethData2 = assembly packed record
    MethCount: Word;
    MethList: /*array[0..0] of */ TMethRec; // Not really an array
  end;

  PMethRec = ^TMethRec;
  TMethRec = assembly packed record
    RecSize: Word;
    MethAddr: Pointer;
    //Name: TSymbolName; // Is sized dynamically
  end;

  // Property RTTI. Types redeclared to handle dynamic length for "Name"

  TPropData2 = assembly packed record
    PropCount: Word;
    PropList: /*array[0..0] of */ TPropInfo; // Not really an array
  end;

  PPropInfo2 = ^TPropInfo2;
  TPropInfo2 = assembly packed record
    PropType: PPTypeInfo;
    GetProc: Pointer;
    SetProc: Pointer;
    StoredProc: Pointer;
    &Index: Integer;
    &Default: Integer;
    NameIndex: SmallInt;
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

{$ENDIF}
{$ENDIF}

end.