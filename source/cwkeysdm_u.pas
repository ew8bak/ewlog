unit CWKeysDM_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TMacros = record
    Button: string[2];
    Name: string[20];
    Macro: string[255];
  end;

type

  { TCWKeysDM }

  TCWKeysDM = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    function OpenMacroFile(const MacroFilePath: string): boolean;
    function CreateMacroFile(const MacroFilePath: string): boolean;
    function ReadRec(const RecNo: integer): TMacros;
    function ReadNextRec: TMacros;
    procedure ModifyRec(const RecNo: integer; const Rec: TMacros);
    procedure ModifyNextRec(const Rec: TMacros);
    procedure AddRec(const Rec: TMacros);
    procedure CloseMacroFile;
    function ReplaceMacro(str: string): string;
  end;

var
  CWKeysDM: TCWKeysDM;
  MacroFile: file of TMacros;
  OpenMacrosFile: boolean;
  MacrosCount: integer;

implementation

uses
  InitDB_dm, miniform_u, MainFuncDM;

{$R *.lfm}

function TCWKeysDM.ReplaceMacro(str: string): string;
var
  MyFREQ: string = '';
  MyCall: string = '';
  MyLoc: string = '';
  MyName: string = '';
  MyQTH: string = '';
  MyRST: string = '';
begin
  MyCall := LBRecord.CallSign;
  MyLoc := LBRecord.OpLoc;
  MyName := LBRecord.OpName;
  MyQTH := LBRecord.OpQTH;
  MyRST := MiniForm.CBRSTs.Text;
  MyFREQ := FloatToStr(FMS.Freq);
  Result := str;
  Result := StringReplace(Result, '<MYFREQ>', MyFREQ, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYCALL>', MyCall, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYLOC>', MyLoc, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYNAME>', MyName, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYQTH>', MyQTH, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '<MYRST>', MyRST, [rfReplaceAll, rfIgnoreCase]);
end;

procedure TCWKeysDM.DataModuleCreate(Sender: TObject);
begin
  OpenMacrosFile := False;
end;

function TCWKeysDM.OpenMacroFile(const MacroFilePath: string): boolean;
begin
  CloseMacroFile;
  AssignFile(MacroFile, MacroFilePath);
  try
    Reset(MacroFile);
    MacrosCount := FileSize(MacroFile);
    OpenMacrosFile := True;
  except
    MacrosCount := 0;
    OpenMacrosFile := False;
  end;
  Result := OpenMacrosFile;
end;

function TCWKeysDM.CreateMacroFile(const MacroFilePath: string): boolean;
begin
  AssignFile(MacroFile, MacroFilePath);
  try
    Rewrite(MacroFile);
    OpenMacrosFile := True;
  except
    OpenMacrosFile := False;
  end;
  MacrosCount := 0;
  Result := OpenMacrosFile;
end;

procedure TCWKeysDM.CloseMacroFile;
begin
  if OpenMacrosFile then
    CloseFile(MacroFile);
end;

function TCWKeysDM.ReadRec(const RecNo: integer): TMacros;
begin
  try
    Seek(MacroFile, RecNo);
    Result := ReadNextRec;
  except
    Result.Macro := '';
    Result.Button := '';
    Result.Name := '';
  end;
end;

function TCWKeysDM.ReadNextRec: TMacros;
begin
  try
    Read(MacroFile, Result);
  except
    Result.Macro := '';
    Result.Button := '';
    Result.Name := '';
  end;
end;

procedure TCWKeysDM.ModifyNextRec(const Rec: TMacros);
begin
  Write(MacroFile, Rec);
end;

procedure TCWKeysDM.ModifyRec(const RecNo: integer; const Rec: TMacros);
begin
  Seek(MacroFile, RecNo);
  ModifyNextRec(Rec);
end;

procedure TCWKeysDM.AddRec(const Rec: TMacros);
begin
  Seek(MacroFile, MacrosCount);
  ModifyNextRec(Rec);
  MacrosCount := FileSize(MacroFile);
end;

end.
