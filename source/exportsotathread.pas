unit ExportSOTAThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, Forms, LCLType, LConvEncoding, const_u,
  ResourceStr, ExportADIThread;

type
  TPSOTAExport = record
    Path: string;
    DateStart: TDateTime;
    DateEnd: TDateTime;
    ExportAll: boolean;
    Win1251: boolean;
    RusToLat: boolean;
    AllRec: integer;
    MySOTAreference: string;
    FromForm: string;
  end;

type
  TExportSOTAFThread = class(TThread)
  protected
    procedure Execute; override;
  private
    FromForm: string;
    procedure SOTAExport(PSOTAExport: TPSOTAExport);
    function SetSizeLoc(Loc: string): string;
  public
    PSOTAExport: TPSOTAExport;
    Info: TInfoExport;
    constructor Create;
    procedure ToForm;
  end;

var
  ExportSOTAFThread: TExportSOTAFThread;

implementation

uses
  ExportAdifForm_u, InitDB_dm, dmFunc_U;

procedure TExportSOTAFThread.SOTAExport(PSOTAExport: TPSOTAExport);
var
  Query: TSQLQuery;
  f: TextFile;
  tmp: string;
begin
  try
    Info.ErrorCode := 0;
    Info.Result := False;
    Info.RecCount := 0;
    Info.AllRec := 0;
    FromForm := PSOTAExport.FromForm;
    Query := TSQLQuery.Create(nil);
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;

    if FileExists(PSOTAExport.Path) then
      DeleteFile(PSOTAExport.Path);

    AssignFile(f, PSOTAExport.Path);
  {$i-}
    Rewrite(f);
  {$i+}
    Info.ErrorCode := IOResult;
    if IOresult <> 0 then
    begin
      Synchronize(@ToForm);
      Exit;
    end;

    if PSOTAExport.ExportAll then
      Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
        ' ORDER BY UnUsedIndex ASC'
    else
    begin
      if DBRecord.CurrentDB = 'MySQL' then
        Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
          ' WHERE QSODate BETWEEN ' + '''' + FormatDateTime('yyyy-mm-dd',
          PSOTAExport.DateStart) + '''' + ' and ' + '''' +
          FormatDateTime('yyyy-mm-dd', PSOTAExport.DateEnd) + '''' +
          ' ORDER BY UnUsedIndex ASC'
      else
        Query.SQL.Text :=
          'SELECT * FROM ' + LBRecord.LogTable + ' WHERE ' + 'strftime(' +
          QuotedStr('%Y-%m-%d') + ',QSODate) BETWEEN ' +
          QuotedStr(FormatDateTime('yyyy-mm-dd', PSOTAExport.DateStart)) +
          ' and ' + QuotedStr(FormatDateTime('yyyy-mm-dd', PSOTAExport.DateEnd)) +
          ' ORDER BY UnUsedIndex ASC';
    end;
    Query.Open;
    Query.Last;
    Info.AllRec := Query.RecordCount;
    Synchronize(@ToForm);
    Query.First;
    while not Query.EOF do
    begin
      try
        tmp := 'V2,';
        Write(f, tmp);
        tmp := dmFunc.RemoveSpaces(Query.Fields.FieldByName('CallSign').AsString) + ',';
        Write(f, tmp);
        tmp := PSOTAExport.MySOTAreference + ',';
        Write(f, tmp);
        tmp := FormatDateTime('dd/mm/yy', Query.Fields.FieldByName(
          'QSODate').AsDateTime) + ',';
        Write(f, tmp);
        tmp := Query.Fields.FieldByName('QSOTime').AsString + ',';
        Write(f, tmp);
        tmp := Query.Fields.FieldByName('DigiBand').AsString + 'MHz' + ',';
        Write(f, tmp);
        tmp := Query.Fields.FieldByName('QSOMode').AsString + ',';
        Write(f, tmp);
        tmp := DBRecord.CurrCall + ',';
        Write(f, tmp);
        if not Query.Fields.FieldByName('SOTA_REF').IsNull then
          tmp := Query.Fields.FieldByName('SOTA_REF').AsString
        else
        if Length(Query.Fields.FieldByName('QSOAddInfo').AsString) > 0 then
          tmp := Query.Fields.FieldByName('QSOAddInfo').AsString;

        Writeln(f, '');
        Inc(Info.RecCount);
        Synchronize(@ToForm);
        Query.Next;

        if Terminated then
          Exit;
      except
        on E: Exception do
        begin
          Writeln(f, '');
          Inc(Info.RecCount);
          Synchronize(@ToForm);
          WriteLn(ExceptFile, 'ExportSOTAThread:' + E.ClassName +
            ':' + E.Message + ' NumberString:' + IntToStr(Info.RecCount + 1));
          Query.Next;
          Continue;
        end;
      end;
    end;
  finally
    CloseFile(f);
    Info.Result := True;
    Synchronize(@ToForm);
    FreeAndNil(Query);
  end;
end;

function TExportSOTAFThread.SetSizeLoc(Loc: string): string;
begin
  Result := '';
  while Length(Loc) > 6 do
    Delete(Loc, Length(Loc), 1);
  Result := Loc;
end;

constructor TExportSOTAFThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TExportSOTAFThread.ToForm;
begin
  Info.From := 'SOTA';
  if Info.ErrorCode <> 0 then
    Application.MessageBox(PChar(rErrorOpenFile + ' ' + IntToStr(IOResult)),
      PChar(rError), mb_ok + mb_IconError);
  if FromForm = 'ExportAdifForm' then
    exportAdifForm.FromExportThread(Info);
end;

procedure TExportSOTAFThread.Execute;
begin
  SOTAExport(PSOTAExport);
end;

end.
