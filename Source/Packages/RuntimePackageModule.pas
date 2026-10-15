namespace RemObjects.Elements.Packages;

// Compiled into each package. Module registration and constructor ranges must
// remain local even when all ordinary Island APIs come from Delphi.Island.bpl.

type
  RuntimePackageModule = assembly static class
  private
    class var fModule: :Delphi.System.TLibModule;
    class var fReferences: Integer;
    class var fUnit: :Delphi.System.PackageUnitEntry;
    class var fInfo: :Delphi.System.PackageInfoTable;

    class var fInitialized: Boolean;
    class var fAttached: Boolean;
  public
    [DllExport('__elements_package_entry'), CallingConvention(CallingConvention.Stdcall)]
    class method Entry(aModule: rtl.HMODULE; aReason: rtl.DWORD; aReserved: ^Void): Boolean;
    begin
      if aReason = rtl.DLL_PROCESS_ATTACH then begin
        fModule.Instance := NativeUInt(aModule);
        fModule.CodeInstance := NativeUInt(aModule);
        fModule.DataInstance := NativeUInt(aModule);
        fModule.ResInstance := NativeUInt(aModule);
        fInfo.UnitCount := 1;
        fInfo.UnitInfo := :Delphi.System.PUnitEntryTable(@fUnit);
        fModule.TypeInfo := @fInfo.TypeInfo;
        :Delphi.System.RegisterModule(@fModule);
        fAttached := true;
        RemObjects.Elements.System.ExternalCalls.fModuleHandle := aModule;
      end else if (aReason = rtl.DLL_PROCESS_DETACH) and fAttached then begin
        // Delphi calls Finalize before FreeLibrary. Detach also covers plain
        // FreeLibrary and a failed InitializePackage.
        if fInitialized then begin
          fReferences := 1;
          Finalize;
        end;
        :Delphi.System.UnregisterModule(@fModule);
        fAttached := false;
      end;
      exit true;
    end;

    // Unit records bind to these no-ops; the package owns constructor ordering.
    [DllExport('__elements_unit_initialize')]
    class method InitializeUnit; empty;

    [DllExport('__elements_unit_finalize')]
    class method FinalizeUnit; empty;

    [DllExport('@GetPackageInfoTable')]
    class method GetPackageInfoTable: :Delphi.System.PackageInfo;
    begin
      exit @fInfo;
    end;

    [DllExport('Initialize')]
    class method Initialize;
    begin
      if fReferences > 0 then begin
        inc(fReferences);
        exit;
      end;
      RemObjects.Elements.System.InitCtors;
      BoehmGC.Load;
      fInitialized := true;
      fReferences := 1;
    end;

    [DllExport('Finalize')]
    class method Finalize;
    begin
      if fReferences = 0 then exit;
      dec(fReferences);
      if fReferences <> 0 then exit;
      fInitialized := false;
      try
        RemObjects.Elements.System.FiniCtors;
        ExternalCalls.FinalizeModule(rtl.HMODULE(fModule.Instance));
      finally
        BoehmGC.UnloadGC;
      end;
    end;
  end;
end.
