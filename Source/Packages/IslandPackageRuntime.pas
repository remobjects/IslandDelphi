namespace RemObjects.Elements.System;

// This state belongs to Delphi.Island.bpl. Customer modules only retain their local
// startup records and roots; they never invoke BoehmGC.UnloadGC.
type
  IslandPackageRuntime = public static class
  private
    class var fModules: Integer;

    class method ChangeRoots(aModule: rtl.HMODULE; aAdd: Boolean);
    begin
      var lBase := ^Byte(aModule);
      var lDos := ^rtl.IMAGE_DOS_HEADER(lBase);
      var lHeader := ^rtl.IMAGE_FILE_HEADER(lBase + lDos^.e_lfanew + sizeOf(UInt32));
      if not aAdd then begin
        // BDWGC merges our exact section ranges with page-rounded roots found
        // by VirtualQuery. Remove the entire image interval, including those
        // merged page tails, before the loader unmaps the package.
        var lOptional := ^rtl.IMAGE_OPTIONAL_HEADER64(lHeader + 1);
        RemoveRoots(lBase, lBase + lOptional^.SizeOfImage);
        exit;
      end;
      var lSection := ^rtl.IMAGE_SECTION_HEADER(^Byte(lHeader + 1) + lHeader^.SizeOfOptionalHeader);
      for i: Integer := 0 to lHeader^.NumberOfSections - 1 do begin
        if (lSection^.Characteristics and rtl.IMAGE_SCN_MEM_WRITE) <> 0 then begin
          var lStart := lBase + lSection^.VirtualAddress;
          var lSize := lSection^.Misc.VirtualSize;
          if lSize <> 0 then begin
            if aAdd then
              gc.GC_add_roots(lStart, lStart + lSize)
            else
              RemoveRoots(lStart, lStart + lSize);
          end;
        end;
        inc(lSection);
      end;
    end;

    [SymbolName('GC_remove_roots')]
    class method RemoveRoots(aStart, aEnd: ^Void); external;
  public
    [DisableInlining]
    class method Acquire;
    begin
      RemObjects.Elements.Packages.RuntimePackageModule.Initialize;
    end;

    [DisableInlining]
    class method Release;
    begin
      RemObjects.Elements.Packages.RuntimePackageModule.Finalize;
    end;

    [DisableInlining]
    class method RegisterModule(aModule: rtl.HMODULE);
    begin
      BoehmGC.Load;
      ChangeRoots(aModule, true);
      inc(fModules);
    end;

    [DisableInlining]
    class method UnregisterModule(aModule: rtl.HMODULE);
    begin
      ExternalCalls.FinalizeModule(aModule);
      ChangeRoots(aModule, false);
      dec(fModules);
    end;

    class property ModuleCount: Integer read fModules;
  end;
end.
