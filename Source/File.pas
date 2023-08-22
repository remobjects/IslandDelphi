namespace RemObjects.Elements.System;

type
  [Error("Delphi APIs using typed 'file of' are not available from Elements (yet)")]
  DelphiFile<T> = public record
    where T is record;

  public
  end;

//function Append(var F: Text): Integer;
//function Assign(var F: File; FileName: String; [CodePage: Word]): Integer;
//function Assign(var F: File; FileName: String; [CodePage: Word]): Integer;
//function Assign(var F: File; FileName: String; [CodePage: Word]): Integer;
//function BlockRead(var F: File; var Buf; Count: Integer; [var Result: Integer]): Integer;
//function BlockRead(var F: File; var Buf; Count: Integer; [var Result: Integer]): Integer;
//function BlockWrite(var F: File; const Buf; Count: Integer; [var Result: Integer]): Integer;
//function BlockWrite(var F: File; const Buf; Count: Integer; [var Result: Integer]): Integer;
//function Close(var F: File): Integer;
//procedure CloseFile(var F: File);
//function Eof([var F: File]): Boolean;
//function Eof([var F: File]): Boolean;
//function Eoln([var F: Text]): Boolean;
//function Eoln([var F: Text]): Boolean;
//procedure Erase(var F: File);
//function FilePos(var F: File): Integer;
//function FileSize(var F: File): Integer;
//function Flush(var t: Text): Integer;
//procedure &Read(var F: File; V1; [ ..., VN]);
//procedure Readln(var F: File; [ ..., VN]);
//procedure Rename(var F: File; Newname: String);
//procedure Reset(var F: File; [ RecSize: Integer]);
//procedure Reset(var F: File; [ RecSize: Integer]);
//procedure Rewrite(var F: File; [ RecSize: Integer]);
//procedure Rewrite(var F: File; [ RecSize: Integer]);
//procedure Seek(var F: File; N: Integer);
//function SeekEof([var F: Text]): Boolean;
//function SeekEof([var F: Text]): Boolean;
//function SeekEoln([var F: Text]): Boolean;
//procedure Truncate(var F: File);
//procedure SetTextBuf(var F: Text; var Buf; [ Size: Integer]);
//procedure &Write([var F: File]; P1; [ ..., PN]);
//procedure Writeln([var F: File]; [ P1; [ ..., PN] ]);

end.