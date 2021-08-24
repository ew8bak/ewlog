unit CWKeysDM_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, Dialogs, SQLite3Conn;

type
  TMacros = record
    ButtonID: integer;
    ButtonName: string[20];
    Macro: string[255];
  end;

type
  TMacroArray = array of TMacros;

type

  { TCWKeysDM }

  TCWKeysDM = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    MacroDB: TSQLite3Connection;
    MacroQuery: TSQLQuery;
    MacroTransaction: TSQLTransaction;
    function OpenOrCreateMacroDB: boolean;
    function CreateMacroDBTable: boolean;
    procedure CloseMacroDB;
    procedure LoadMacroArray;

  public
    function ReplaceMacro(str: string): string;
    function SearchMacro(ButtonID: integer): TMacros;
    procedure AddMacro(Macro: TMacros);
    procedure UpdateMacro(Macro: TMacros);

  end;

var
  CWKeysDM: TCWKeysDM;
  MacrosArray: TMacroArray;

implementation

uses
  InitDB_dm, miniform_u, MainFuncDM, SetupSQLquery;

{$R *.lfm}

function TCWKeysDM.OpenOrCreateMacroDB: boolean;
begin
  try
    Result := False;
    MacroDB := TSQLite3Connection.Create(nil);
    MacroQuery := TSQLQuery.Create(nil);
    MacroTransaction := TSQLTransaction.Create(nil);
    if (FileExists(FilePATH + 'macro.db')) then
    begin
      MacroDB.DatabaseName := FilePATH + 'macro.db';
      MacroDB.Transaction := MacroTransaction;
      MacroQuery.DataBase := MacroDB;
      MacroDB.Connected := True;
      MacroQuery.SQL.Text :=
        'SELECT name FROM sqlite_master WHERE type=''table'' AND name=' +
        QuotedStr('MacroTable');
      MacroQuery.Open;
      if MacroQuery.RecordCount > 0 then
        Result := True
      else
        Result := CreateMacroDBTable;
    end
    else
    begin
      MacroDB.DatabaseName := FilePATH + 'macro.db';
      MacroDB.Transaction := MacroTransaction;
      MacroQuery.DataBase := MacroDB;
      MacroDB.Connected := True;
      Result := CreateMacroDBTable;
    end;
    MacroQuery.Close;
  except
    Result := False;
  end;
end;

function TCWKeysDM.CreateMacroDBTable: boolean;
begin
  Result := False;
  try
    MacroQuery.Close;
    MacroQuery.SQL.Text := Table_MacroTable;
    MacroQuery.ExecSQL;
    MacroTransaction.Commit;
    Result := True;
  except
    Result := False;
  end;
end;

procedure TCWKeysDM.CloseMacroDB;
begin
  MacroDB.Connected := False;
  FreeAndNil(MacroQuery);
  FreeAndNil(MacroTransaction);
  FreeAndNil(MacroDB);
end;

procedure TCWKeysDM.LoadMacroArray;
var
  i: integer;
begin
  try
    MacroQuery.SQL.Text := 'SELECT * FROM MacroTable';
    MacroQuery.Open;
    if MacroQuery.RecordCount > 0 then
    begin
      SetLength(MacrosArray, MacroQuery.RecordCount);
      for i := 0 to MacroQuery.RecordCount - 1 do
      begin
        MacrosArray[i].ButtonID := MacroQuery.Fields.Fields[0].AsInteger;
        MacrosArray[i].ButtonName := MacroQuery.Fields.Fields[1].AsString;
        MacrosArray[i].Macro := MacroQuery.Fields.Fields[2].AsString;
        MacroQuery.Next;
      end;
    end;
    MacroQuery.Close;

  except
    on E: Exception do
      WriteLn(ExceptFile, 'AddMacroArray:' + E.ClassName + ':' + E.Message);
  end;
end;

function TCWKeysDM.SearchMacro(ButtonID: integer): TMacros;
var
  i: integer;
begin
  Result.ButtonID := -1;
  for i := 0 to High(MacrosArray) do
    if MacrosArray[i].ButtonID = ButtonID then
    begin
      Result.ButtonID := MacrosArray[i].ButtonID;
      Result.ButtonName := MacrosArray[i].ButtonName;
      Result.Macro := MacrosArray[i].Macro;
      Break;
    end;
end;

procedure TCWKeysDM.AddMacro(Macro: TMacros);
begin
  try
    MacroQuery.SQL.Text := 'INSERT INTO MacroTable (ButtonID, ButtonName, Macro) ' +
      'VALUES (' + IntToStr(Macro.ButtonID) + ',' + QuotedStr(Macro.ButtonName) +
      ',' + QuotedStr(Macro.Macro) + ')';
    MacroQuery.ExecSQL;
    MacroTransaction.Commit;
    LoadMacroArray;
  except
    on E: ESQLDatabaseError do
      if E.ErrorCode = 1555 then
        UpdateMacro(Macro);
  end;
end;

procedure TCWKeysDM.UpdateMacro(Macro: TMacros);
begin
  MacroQuery.SQL.Text := 'UPDATE MacroTable SET ButtonName = ' +
    QuotedStr(Macro.ButtonName) + ', Macro = ' + QuotedStr(Macro.Macro) +
    ' WHERE ButtonID = ' + IntToStr(Macro.ButtonID);
  MacroQuery.ExecSQL;
  MacroTransaction.Commit;
  LoadMacroArray;
end;

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
  if OpenOrCreateMacroDB then
    LoadMacroArray;
end;

procedure TCWKeysDM.DataModuleDestroy(Sender: TObject);
begin
  CloseMacroDB;
end;

end.
