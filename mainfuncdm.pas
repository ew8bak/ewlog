unit MainFuncDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, SQLDB, RegExpr, qso_record, Dialogs, ResourceStr,
  prefix_record, LazUTF8, const_u, DBGrids, inifile_record, selectQSO_record,
  foundQSO_record, StdCtrls, Grids, Graphics, DateUtils, mvTypes, mvMapViewer,
  VirtualTrees, LazFileUtils, LCLType, digi_record, CloudLogCAT;

type
  bandArray = array of string;
  modeArray = array of string;
  subModeArray = array of string;
  CallsignArray = array of string;
  StringArray = array of string;
  extProgramArray = array of string;

  { TMainFunc }

  TMainFunc = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    SearchPrefixQuery: TSQLQuery;
  public
    procedure SentCATCloudLog(CatData: TCatData);
    procedure SaveGridsColumnSized(DbGrid: TDBGrid);
    procedure SaveGridsColumnMoved(DbGrid: TDBGrid);
    procedure SaveGrids(DbGrid: TDBGrid);
    procedure SetDXColumns(VST: TVirtualStringTree; Save: boolean;
      var VirtualST: TVirtualStringTree);
    procedure SaveQSO(var SQSO: TQSO);
    procedure SetGrid(var DBGRID: TDBGrid);
    procedure GetDistAzim(Latitude, Longitude: string; var Distance, Azimuth: string);
    procedure CheckDXCC(Callsign, mode, band: string; var DMode, DBand, DCall: boolean);
    procedure LoadINIsettings;
    procedure ClearPFXR(var PFXR: TPFXR);
    procedure LoadBMSL(var CBMode, CBSubMode, CBBand, CBJournal: TComboBox);
    procedure LoadBMSL(var CBMode, CBSubMode, CBBand: TComboBox); overload;
    procedure UpdateQSO(DBGrid: TDBGrid; Field, Value: string);
    procedure DeleteQSO(DBGrid: TDBGrid);
    procedure UpdateEditQSO(index: integer; SQSO: TQSO);
    procedure FilterQSO(Field, Value: string);
    procedure SelectAllQSO(var DBGrid: TDBGrid);
    procedure DrawColumnGrid(DS: TDataSet; Rect: TRect; DataCol: integer;
      Column: TColumn; State: TGridDrawState; var DBGrid: TDBGrid);
    procedure CurrPosGrid(index: integer; var DBGrid: TDBGrid);
    procedure SendQSOto(via: string; SendQSO: TQSO);
    procedure LoadMaps(Lat, Long: string; var MapView: TMapView);
    procedure CopyToJournal(DBGrid: TDBGrid; toCallsign: string);
    procedure LoadJournalItem(var CBJournal: TComboBox);
    function FindWorkedCall(Callsign, band, mode: string): boolean;
    function WorkedQSL(Callsign, band, mode: string): boolean;
    function WorkedLoTW(Callsign, band, mode: string): boolean;
    function SearchPrefix(Callsign, Grid: string): TPFXR;
    function LoadBands(mode: string): bandArray;
    function LoadModes: modeArray;
    function LoadSubModes(mode: string): subModeArray;
    function FindQSO(Callsign: string): TFoundQSOR;
    function SelectQSO(DataSource: TDataSource): TSelQSOR;
    function GetAllCallsign: CallsignArray;
    function FindISOCountry(Country: string): string;
    function FindCountry(ISOCode: string): string;
    function SelectEditQSO(index: integer): TQSO;
    function IntToBool(Value: integer): boolean;
    function StringToBool(Value: string): boolean;
    function FormatFreq(Value, mode: string): string;
    function FindInCallBook(Callsign: string): TFoundQSOR;
    function CheckQSL(Callsign, band, mode: string): integer;
    function EraseTable: boolean;
    function GetMySQLDataBase: StringArray;
    function GetExternalProgramsName: extProgramArray;
    function GetExternalProgramsPath(ProgramName: string): string;
  end;

var
  MainFunc: TMainFunc;
  IniSet: TINIR;
  columnsGrid: array[0..29] of string;
  columnsWidth: array[0..29] of integer;
  columnsVisible: array[0..29] of boolean;
  columnsDX: array[0..8] of string;
  columnsDXWidth: array[0..8] of integer;

implementation

uses InitDB_dm, dmFunc_U, hrdlog,
  hamqth, clublog, qrzcom, eqsl, cloudlog, miniform_u;

{$R *.lfm}

procedure TMainFunc.SentCATCloudLog(CatData: TCatData);
begin
  CatData.freq := FormatFreq(CatData.freq, CatData.mode);
  StringReplace(CatData.freq, '.', '', [rfReplaceAll]);
  CatData.freq := CatData.freq + '0';
  CloudLogCATThread := TCloudLogCATThread.Create;
  if Assigned(CloudLogCATThread.FatalException) then
    raise CloudLogCATThread.FatalException;
  CloudLogCATThread.CatData := CatData;
  CloudLogCATThread.Start;
end;

function TMainFunc.GetExternalProgramsPath(ProgramName: string): string;
var
  i, Count: integer;
  SLPrograms: TStringList;
begin
  Result := '';
  try
    SLPrograms := TStringList.Create;
    SLPrograms.Clear;
    SLPrograms.NameValueSeparator := ',';
    INIFile.ReadSection('ExternalProgram', SLPrograms);
    Count := SLPrograms.Count;
    SLPrograms.Clear;
    for i := 0 to Count - 1 do
      SLPrograms.Add(INIFile.ReadString('ExternalProgram', 'Program' +
        IntToStr(i), ''));
    for i := 0 to SLPrograms.Count - 1 do
      if pos(ProgramName, SLPrograms.Strings[i]) > 0 then
        Result := SLPrograms.ValueFromIndex[i];
  finally
    FreeAndNil(SLPrograms);
  end;
end;

function TMainFunc.GetExternalProgramsName: extProgramArray;
var
  i, CountPrograms: integer;
  SLPrograms: TStringList;
begin
  try
    CountPrograms := 0;
    SLPrograms := TStringList.Create;
    SLPrograms.Clear;
    SLPrograms.NameValueSeparator := ',';
    INIFile.ReadSection('ExternalProgram', SLPrograms);
    CountPrograms := SLPrograms.Count;
    SLPrograms.Clear;
    SetLength(Result, CountPrograms);
    for i := 0 to CountPrograms - 1 do
      SLPrograms.Add(INIFile.ReadString('ExternalProgram', 'Program' +
        IntToStr(i), ''));
  finally
    for i := 0 to SLPrograms.Count - 1 do
      Result[i] := (SLPrograms.Names[i]);
    FreeAndNil(SLPrograms);
  end;
end;

function TMainFunc.GetMySQLDataBase: StringArray;
var
  i: integer;
  Query: TSQLQuery;
  DBList: StringArray;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.PacketRecords := 50;
      if InitDB.MySQLConnection.Connected then
      begin
        Query.DataBase := InitDB.MySQLConnection;
        Query.SQL.Text := 'SHOW DATABASES;';
        Query.Open;
        if Query.RecordCount = 0 then
          Exit;
        SetLength(DBList, Query.RecordCount);
        Query.First;
        for i := 0 to Query.RecordCount - 1 do
        begin
          DBList[i] := Query.Fields.Fields[0].AsString;
          Query.Next;
        end;
        Query.Close;
      end;
      Result := DBList;
    finally
      FreeAndNil(Query);
      InitDB.MySQLConnection.Connected := False;
    end;
  except
    on E: Exception do
      WriteLn(ExceptFile, 'GetMySQLDataBase:' + E.ClassName + ':' + E.Message);
  end;
end;

function TMainFunc.EraseTable: boolean;
var
  Query: TSQLQuery;
begin
  try
    Result := False;
    if InitDB.MySQLConnection.Connected or InitDB.SQLiteConnection.Connected then
    begin
      if Application.MessageBox(PChar(rCleanUpJournal), PChar(rWarning),
        MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      begin
        try
          Query := TSQLQuery.Create(nil);
          if DBRecord.CurrentDB = 'MySQL' then
            Query.DataBase := InitDB.MySQLConnection
          else
            Query.DataBase := InitDB.SQLiteConnection;
          with Query do
          begin
            SQL.Text := 'DELETE FROM ' + LBRecord.LogTable;
            Prepare;
            ExecSQL;
          end;
        finally
          InitDB.DefTransaction.Commit;
          Result := True;
          FreeAndNil(Query);
          if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
            ShowMessage(rDBError);
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('EraseTable:' + E.Message);
      WriteLn(ExceptFile, 'FindInCallBook:' + E.ClassName + ':' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TMainFunc.SaveGridsColumnSized(DbGrid: TDBGrid);
var
  i: integer;
begin
  for i := 0 to 29 do
  begin
    if DbGrid.Columns.Items[i].Width <> 0 then
      INIFile.WriteInteger('GridSettings', 'ColWidth' + IntToStr(i),
        DbGrid.Columns.Items[i].Width)
    else
      INIFile.WriteInteger('GridSettings', 'ColWidth' + IntToStr(i), columnsWidth[i]);
  end;
end;

procedure TMainFunc.SaveGridsColumnMoved(DbGrid: TDBGrid);
var
  i: integer;
begin
  for i := 0 to 29 do
  begin
    INIFile.WriteString('GridSettings', 'Columns' + IntToStr(i),
      DbGrid.Columns.Items[i].FieldName);
  end;
end;

procedure TMainFunc.SaveGrids(DbGrid: TDBGrid);
var
  i: integer;
begin
  for i := 0 to 29 do
  begin
    INIFile.WriteString('GridSettings', 'Columns' + IntToStr(i),
      DbGrid.Columns.Items[i].FieldName);
  end;

  for i := 0 to 29 do
  begin
    if DbGrid.Columns.Items[i].Width <> 0 then
      INIFile.WriteInteger('GridSettings', 'ColWidth' + IntToStr(i),
        DbGrid.Columns.Items[i].Width)
    else
      INIFile.WriteInteger('GridSettings', 'ColWidth' + IntToStr(i), columnsWidth[i]);
  end;
end;

procedure TMainFunc.SetDXColumns(VST: TVirtualStringTree; Save: boolean;
  var VirtualST: TVirtualStringTree);
var
  VSTSaveStream: TMemoryStream;
begin
  try
    VSTSaveStream := TMemoryStream.Create;
    if Save then
    begin
      VST.Header.SaveToStream(VSTSaveStream);
      VSTSaveStream.SaveToFile(FilePATH + 'dxColumns.dat');
    end
    else
    if FileExistsUTF8(FilePATH + 'dxColumns.dat') then
    begin
      VSTSaveStream.LoadFromFile(FilePATH + 'dxColumns.dat');
      VirtualST.Header.LoadFromStream(VSTSaveStream);
    end;
  finally
    VSTSaveStream.Free;
  end;
end;

function TMainFunc.FindInCallBook(Callsign: string): TFoundQSOR;
var
  Query: TSQLQuery;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.ImbeddedCallBookConnection;
      if InitDB.ImbeddedCallBookConnection.Connected = True then
      begin
        Query.SQL.Text := 'SELECT * FROM `Callbook` WHERE `Call` = ' +
          QuotedStr(Callsign);
        Query.Open;
        if Query.RecordCount > 0 then
        begin
          Result.OMName := Query.Fields[2].AsString;
          Result.OMQTH := Query.Fields[3].AsString;
          Result.Grid := Query.Fields[4].AsString;
          Result.State := Query.Fields[5].AsString;
          Result.QSLManager := Query.Fields[6].AsString;
          Result.Found := True;
        end
        else
        begin
          Result.Found := False;
          Result.OMName := '';
          Result.OMQTH := '';
          Result.Grid := '';
          Result.State := '';
          Result.QSLManager := '';
        end;
        Query.Close;
      end;
    finally
      FreeAndNil(Query);
    end;
  except
    on E: Exception do
    begin
      ShowMessage('FindInCallBook:' + E.Message);
      WriteLn(ExceptFile, 'FindInCallBook:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

function TMainFunc.FormatFreq(Value, mode: string): string;
begin
  Result := '0';
  if Value <> '' then
  begin
    if Pos('M', Value) > 0 then
    begin
      Value := FormatFloat(view_freq, dmFunc.GetFreqFromBand(Value, mode));
      Delete(Value, length(Value) - 2, 1);
    end
    else
      Delete(Value, length(Value) - 2, 1);
    Result := Value;
  end;
end;

procedure TMainFunc.CopyToJournal(DBGrid: TDBGrid; toCallsign: string);
var
  Query: TSQLQuery;
  toTable: string;
  i, RecIndex: integer;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      if DBRecord.CurrentDB = 'MySQL' then
        Query.DataBase := InitDB.MySQLConnection
      else
        Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Text := 'SELECT LogTable FROM LogBookInfo WHERE CallName = "' +
        toCallsign + '"';
      Query.Open;
      toTable := Query.Fields[0].AsString;
      Query.Close;
      for i := 0 to DBGrid.SelectedRows.Count - 1 do
      begin
        DBGrid.DataSource.DataSet.GotoBookmark(Pointer(DBGrid.SelectedRows.Items[i]));
        RecIndex := DBGrid.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
        Query.SQL.Text := 'INSERT INTO ' + toTable + ' (' + CopyField +
          ')' + ' SELECT ' + CopyField + ' FROM ' + LBRecord.LogTable +
          ' WHERE UnUsedIndex = ' + IntToStr(RecIndex);
        Query.ExecSQL;
      end;
    except
      on E: ESQLDatabaseError do
      begin
        if (E.ErrorCode = 1062) or (E.ErrorCode = 2067) then
          ShowMessage(rLogEntryExist);
      end;
    end;
  finally
    InitDB.DefTransaction.Commit;
    FreeAndNil(Query);
    if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
      ShowMessage(rDBError);
    SetGrid(DBGrid);
    CurrPosGrid(GridRecordIndex, DBGrid);
  end;
end;

procedure TMainFunc.LoadMaps(Lat, Long: string; var MapView: TMapView);
var
  Center: TRealPoint;
  LatR, LongR: real;
  error: integer;
begin
  val(Long, LongR, Error);
  if error = 0 then
  begin
    Center.Lon := LongR;
    val(Lat, LatR, Error);
    if error = 0 then
    begin
      Center.Lat := LatR;
      MapView.Zoom := 9;
      MapView.Center := Center;
    end;
  end;
end;

procedure TMainFunc.SendQSOto(via: string; SendQSO: TQSO);
begin
  //Отправка в CloudLog
  if via = 'cloudlog' then
  begin
    SendCloudLogThread := TSendCloudLogThread.Create;
    if Assigned(SendCloudLogThread.FatalException) then
      raise SendCloudLogThread.FatalException;
    SendCloudLogThread.SendQSO := SendQSO;
    SendCloudLogThread.server := IniSet.CloudLogServer;
    SendCloudLogThread.key := IniSet.CloudLogApiKey;
    SendCloudLogThread.Start;
    Exit;
  end;
  //Отправка в eQSLcc
  if via = 'eqslcc' then
  begin
    SendEQSLThread := TSendEQSLThread.Create;
    if Assigned(SendEQSLThread.FatalException) then
      raise SendEQSLThread.FatalException;
    SendEQSLThread.SendQSO := SendQSO;
    SendEQSLThread.user := LBRecord.eQSLccLogin;
    SendEQSLThread.password := LBRecord.eQSLccPassword;
    SendEQSLThread.Start;
    Exit;
  end;
  //Отправка в HRDLOG
  if via = 'hrdlog' then
  begin
    SendHRDThread := TSendHRDThread.Create;
    if Assigned(SendHRDThread.FatalException) then
      raise SendHRDThread.FatalException;
    SendHRDThread.SendQSO := SendQSO;
    SendHRDThread.user := LBRecord.HRDLogin;
    SendHRDThread.password := LBRecord.HRDCode;
    SendHRDThread.Start;
    Exit;
  end;
  //Отправка в HAMQTH
  if via = 'hamqth' then
  begin
    SendHamQTHThread := TSendHamQTHThread.Create;
    if Assigned(SendHamQTHThread.FatalException) then
      raise SendHamQTHThread.FatalException;
    SendHamQTHThread.SendQSO := SendQSO;
    SendHamQTHThread.user := LBRecord.HamQTHLogin;
    SendHamQTHThread.password := LBRecord.HamQTHPassword;
    SendHamQTHThread.Start;
    Exit;
  end;
  //Отправка в QRZ.COM
  if via = 'qrzcom' then
  begin
    SendQRZComThread := TSendQRZComThread.Create;
    if Assigned(SendQRZComThread.FatalException) then
      raise SendQRZComThread.FatalException;
    SendQRZComThread.SendQSO := SendQSO;
    SendQRZComThread.user := LBRecord.QRZComLogin;
    SendQRZComThread.password := LBRecord.QRZComPassword;
    SendQRZComThread.Start;
    Exit;
  end;
  //Отправка в ClubLog
  if via = 'clublog' then
  begin
    SendClubLogThread := TSendClubLogThread.Create;
    if Assigned(SendClubLogThread.FatalException) then
      raise SendClubLogThread.FatalException;
    SendClubLogThread.SendQSO := SendQSO;
    SendClubLogThread.user := LBRecord.ClubLogLogin;
    SendClubLogThread.password := LBRecord.ClubLogPassword;
    SendClubLogThread.callsign := LBRecord.CallSign;
    SendClubLogThread.Start;
    Exit;
  end;
end;

function TMainFunc.IntToBool(Value: integer): boolean;
begin
  case Value of
    1: Result := True;
    0: Result := False;
  end;
end;

function TMainFunc.StringToBool(Value: string): boolean;
begin
  case Value of
    '1': Result := True;
    '0': Result := False;
  end;
end;

function TMainFunc.SelectEditQSO(index: integer): TQSO;
var
  Query: TSQLQuery;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      if DBRecord.CurrentDB = 'MySQL' then
        Query.DataBase := InitDB.MySQLConnection
      else
        Query.DataBase := InitDB.SQLiteConnection;

      Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
        ' WHERE UnUsedIndex = ' + IntToStr(index);
      Query.Open;

      Result.CallSing := Query.FieldByName('CallSign').AsString;
      Result.QSODate := Query.FieldByName('QSODate').AsDateTime;
      Result.QSOTime := Query.FieldByName('QSOTime').AsString;
      Result.OMName := Query.FieldByName('OMName').AsString;
      Result.OMQTH := Query.FieldByName('OMQTH').AsString;
      Result.State0 := Query.FieldByName('State').AsString;
      Result.Grid := Query.FieldByName('Grid').AsString;
      Result.QSOReportSent := Query.FieldByName('QSOReportSent').AsString;
      Result.QSOReportRecived := Query.FieldByName('QSOReportRecived').AsString;
      Result.IOTA := Query.FieldByName('IOTA').AsString;
      Result.QSLSentDate := Query.FieldByName('QSLSentDate').AsDateTime;
      Result.QSLRecDate := Query.FieldByName('QSLRecDate').AsDateTime;
      Result.LoTWRecDate := Query.FieldByName('LoTWRecDate').AsDateTime;
      Result.MainPrefix := Query.FieldByName('MainPrefix').AsString;
      Result.DXCCPrefix := Query.FieldByName('DXCCPrefix').AsString;
      Result.DXCC := Query.FieldByName('DXCC').AsString;
      Result.CQZone := Query.FieldByName('CQZone').AsString;
      Result.ITUZone := Query.FieldByName('ITUZone').AsString;
      Result.Marker := Query.FieldByName('Marker').AsString;
      Result.QSOMode := Query.FieldByName('QSOMode').AsString;
      Result.QSOSubMode := Query.FieldByName('QSOSubMode').AsString;
      Result.QSOBand := Query.FieldByName('QSOBand').AsString;
      Result.Continent := Query.FieldByName('Continent').AsString;
      Result.QSLInfo := Query.FieldByName('QSLInfo').AsString;
      Result.ValidDX := Query.FieldByName('ValidDX').AsString;
      Result.QSLManager := Query.FieldByName('QSLManager').AsString;
      Result.State1 := Query.FieldByName('State1').AsString;
      Result.State2 := Query.FieldByName('State2').AsString;
      Result.State3 := Query.FieldByName('State3').AsString;
      Result.State4 := Query.FieldByName('State4').AsString;
      Result.QSOAddInfo := Query.FieldByName('QSOAddInfo').AsString;
      Result.NoCalcDXCC := Query.FieldByName('NoCalcDXCC').AsInteger;
      Result.QSLReceQSLcc := Query.FieldByName('QSLReceQSLcc').AsInteger;
      Result.QSLRec := Query.FieldByName('QSLRec').AsString;
      Result.LoTWRec := Query.FieldByName('LoTWRec').AsString;
      Result.LoTWSent := Query.FieldByName('LoTWSent').AsInteger;
      Result.QSL_RCVD_VIA := Query.FieldByName('QSL_RCVD_VIA').AsString;
      Result.QSL_SENT_VIA := Query.FieldByName('QSL_SENT_VIA').AsString;
      Result.QSLSentAdv := Query.FieldByName('QSLSentAdv').AsString;
      Result.PROP_MODE := Query.FieldByName('PROP_MODE').AsString;
      Query.Close;
    finally
      FreeAndNil(Query);
    end;
  except
    on E: Exception do
    begin
      ShowMessage('SelectEditQSO:' + E.Message);
      WriteLn(ExceptFile, 'SelectEditQSO:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

procedure TMainFunc.CurrPosGrid(index: integer; var DBGrid: TDBGrid);
begin
  try
    DBGrid.DataSource.DataSet.RecNo := index;
  except
    on E: Exception do
      WriteLn(ExceptFile, 'CurrPosGrid:' + E.ClassName + ':' + E.Message);
  end;
end;

procedure TMainFunc.UpdateEditQSO(index: integer; SQSO: TQSO);
var
  QueryTXT: string;
  QSODates, QSLSentDates, QSLRecDates, LotWRecDates: string;
  SRXs, STXs: string;
begin
  try
    try
      if DBRecord.CurrentDB = 'MySQL' then
      begin
        QSODates := dmFunc.ADIFDateToDate(DateToStr(SQSO.QSODate));
        QSLSentDates := dmFunc.ADIFDateToDate(DateToStr(SQSO.QSLSentDate));
        QSLRecDates := dmFunc.ADIFDateToDate(DateToStr(SQSO.QSLRecDate));
        LotWRecDates := dmFunc.ADIFDateToDate(DateToStr(SQSO.LotWRecDate));
      end
      else
      begin
        QSODates := FloatToStr(DateTimeToJulianDate(SQSO.QSODate));
        QSLSentDates := FloatToStr(DateTimeToJulianDate(SQSO.QSLSentDate));
        QSLRecDates := FloatToStr(DateTimeToJulianDate(SQSO.QSLRecDate));
        LotWRecDates := FloatToStr(DateTimeToJulianDate(SQSO.LotWRecDate));
      end;

      SRXs := IntToStr(SQSO.SRX);
      STXs := IntToStr(SQSO.STX);
      if SQSO.SRX = 0 then
        SRXs := 'NULL';
      if SQSO.STX = 0 then
        STXs := 'NULL';
      if SQSO.QSL_RCVD_VIA = '' then
        SQSO.QSL_RCVD_VIA := 'NULL';
      if SQSO.QSL_SENT_VIA = '' then
        SQSO.QSL_SENT_VIA := 'NULL';

      QueryTXT := 'UPDATE ' + LBRecord.LogTable + ' SET ' + 'CallSign = ' +
        dmFunc.Q(SQSO.CallSing) + 'QSODate = ' + dmFunc.Q(QSODates) +
        'QSOTime = ' + dmFunc.Q(SQSO.QSOTime) + 'QSOBand = ' +
        dmFunc.Q(SQSO.QSOBand) + 'QSOMode = ' + dmFunc.Q(SQSO.QSOMode) +
        'QSOSubMode = ' + dmFunc.Q(SQSO.QSOSubMode) + 'QSOReportSent = ' +
        dmFunc.Q(SQSO.QSOReportSent) + 'QSOReportRecived = ' +
        dmFunc.Q(SQSO.QSOReportRecived) + 'OMName = ' + dmFunc.Q(SQSO.OmName) +
        'OMQTH = ' + dmFunc.Q(SQSO.OmQTH) + 'State = ' + dmFunc.Q(SQSO.State0) +
        'Grid = ' + dmFunc.Q(SQSO.Grid) + 'IOTA=' + dmFunc.Q(SQSO.IOTA) +
        'QSLManager = ' + dmFunc.Q(SQSO.QSLManager) + 'QSLSent = ' +
        dmFunc.Q(SQSO.QSLSent) + 'QSLSentAdv = ' + dmFunc.Q(SQSO.QSLSentAdv) +
        'QSLSentDate = ' + dmFunc.Q(QSLSentDates) + 'QSLRec = ' +
        dmFunc.Q(SQSO.QSLRec) + 'QSLRecDate = ' + dmFunc.Q(QSLRecDates) +
        'MainPrefix = ' + dmFunc.Q(SQSO.MainPrefix) + 'DXCCPrefix=' +
        dmFunc.Q(SQSO.DXCCPrefix) + 'CQZone=' + dmFunc.Q(SQSO.CQZone) +
        'ITUZone = ' + dmFunc.Q(SQSO.ITUZone) + 'QSOAddInfo=' +
        dmFunc.Q(SQSO.QSOAddInfo) + 'Marker = ' + dmFunc.Q(SQSO.Marker) +
        'ManualSet=' + dmFunc.Q(IntToStr(SQSO.ManualSet)) + 'DigiBand = ' +
        dmFunc.Q(SQSO.DigiBand) + 'Continent=' + dmFunc.Q(SQSO.Continent) +
        'ShortNote=' + dmFunc.Q(SQSO.ShortNote) + 'QSLReceQSLcc=' +
        dmFunc.Q(IntToStr(SQSO.QSLReceQSLcc)) + 'LoTWRec=' +
        dmFunc.Q(SQSO.LotWRec) + 'LoTWRecDate=' + dmFunc.Q(LotWRecDates) +
        'QSLInfo=' + dmFunc.Q(SQSO.QSLInfo) + '`Call`=' + dmFunc.Q(SQSO.Call) +
        'State1=' + dmFunc.Q(SQSO.State1) + 'State2=' + dmFunc.Q(SQSO.State2) +
        'State3=' + dmFunc.Q(SQSO.State3) + 'State4=' + dmFunc.Q(SQSO.State4) +
        'WPX=' + dmFunc.Q(SQSO.WPX) + 'ValidDX=' + dmFunc.Q(SQSO.ValidDX) +
        'SRX=' + dmFunc.Q(SRXs) + 'SRX_STRING=' + dmFunc.Q(SQSO.SRX_String) +
        'STX=' + dmFunc.Q(STXs) + 'STX_STRING=' + dmFunc.Q(SQSO.STX_String) +
        'SAT_NAME=' + dmFunc.Q(SQSO.SAT_NAME) + 'SAT_MODE=' +
        dmFunc.Q(SQSO.SAT_MODE) + 'PROP_MODE=' + dmFunc.Q(SQSO.PROP_MODE) +
        'LoTWSent=' + dmFunc.Q(IntToStr(SQSO.LotWSent)) + 'QSL_RCVD_VIA=' +
        dmFunc.Q(SQSO.QSL_RCVD_VIA) + 'QSL_SENT_VIA=' + dmFunc.Q(SQSO.QSL_SENT_VIA) +
        'DXCC=' + dmFunc.Q(SQSO.DXCC) + 'NoCalcDXCC=' +
        QuotedStr(IntToStr(SQSO.NoCalcDXCC)) + ' WHERE UnUsedIndex=' +
        QuotedStr(IntToStr(index));
      if DBRecord.CurrentDB = 'MySQL' then
        InitDB.MySQLConnection.ExecuteDirect(QueryTXT)
      else
        InitDB.SQLiteConnection.ExecuteDirect(QueryTXT);
    finally
      InitDB.DefTransaction.Commit;
      if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
        ShowMessage(rDBError);
    end;
  except
    on E: Exception do
      WriteLn(ExceptFile, 'UpdateEditQSO:' + E.ClassName + ':' + E.Message);
  end;
end;

function TMainFunc.FindCountry(ISOCode: string): string;
var
  ISOList: TStringList;
  LanguageList: TStringList;
  Index: integer;
begin
  try
    Result := '';
    ISOList := TStringList.Create;
    LanguageList := TStringList.Create;
    ISOList.AddStrings(constLanguageISO);
    LanguageList.AddStrings(constLanguage);
    Index := ISOList.IndexOf(ISOCode);
    if Index <> -1 then
      Result := LanguageList.Strings[Index]
    else
      Result := 'None';

  finally
    ISOList.Free;
    LanguageList.Free;
  end;
end;

function TMainFunc.FindISOCountry(Country: string): string;
var
  ISOList: TStringList;
  LanguageList: TStringList;
  Index: integer;
begin
  Result := '';
  try
    ISOList := TStringList.Create;
    LanguageList := TStringList.Create;
    ISOList.AddStrings(constLanguageISO);
    LanguageList.AddStrings(constLanguage);
    Index := LanguageList.IndexOf(Country);
    if Index <> -1 then
      Result := ISOList.Strings[Index]
    else
      Result := 'None';

  finally
    ISOList.Free;
    LanguageList.Free;
  end;
end;

procedure TMainFunc.DrawColumnGrid(DS: TDataSet; Rect: TRect;
  DataCol: integer; Column: TColumn; State: TGridDrawState; var DBGrid: TDBGrid);
var
  Field_QSL: string;
  Field_QSLs: string;
  Field_QSLSentAdv: string;
begin
  Field_QSL := DS.FieldByName('QSL').AsString;
  Field_QSLs := DS.FieldByName('QSLs').AsString;
  Field_QSLSentAdv := DS.FieldByName('QSLSentAdv').AsString;
  if Field_QSLSentAdv = 'N' then
    with DBGrid.Canvas do
    begin
      Brush.Color := clRed;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
  if (Field_QSL = '001') or (Field_QSL = '100') or (Field_QSL = '011') or
    (Field_QSL = '110') or (Field_QSL = '111') or (Field_QSL = '101') then
    with DBGrid.Canvas do
    begin
      Brush.Color := clFuchsia;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
  if (Field_QSLs = '10') or (Field_QSLs = '11') then
    with DBGrid.Canvas do
    begin
      Brush.Color := clAqua;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
  if ((Field_QSLs = '10') or (Field_QSLs = '11')) and
    ((Field_QSL = '001') or (Field_QSL = '011') or (Field_QSL = '111') or
    (Field_QSL = '101') or (Field_QSL = '110')) then
    with DBGrid.Canvas do
    begin
      Brush.Color := clLime;
      Font.Color := clBlack;
      if (gdSelected in State) then
      begin
        Brush.Color := clHighlight;
        Font.Color := clWhite;
      end;
      FillRect(Rect);
      DBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
  if (Column.FieldName = 'CallSign') then
    if (Field_QSL = '010') or (Field_QSL = '110') or (Field_QSL = '111') or
      (Field_QSL = '011') then
    begin
      with DBGrid.Canvas do
      begin
        Brush.Color := clYellow;
        Font.Color := clBlack;
        if (gdSelected in State) then
        begin
          Brush.Color := clHighlight;
          Font.Color := clWhite;
        end;
        FillRect(Rect);
        DBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
      end;
    end;
  if (Column.FieldName = 'QSL') then
  begin
    with DBGrid.Canvas do
    begin
      FillRect(Rect);
      if (Field_QSL = '100') then
        TextOut(Rect.Right - 6 - TextWidth('P'), Rect.Top + 0, 'P');
      if (Field_QSL = '110') then
        TextOut(Rect.Right - 10 - TextWidth('PE'), Rect.Top + 0, 'PE');
      if (Field_QSL = '111') then
        TextOut(Rect.Right - 6 - TextWidth('PLE'), Rect.Top + 0, 'PLE');
      if (Field_QSL = '010') then
        TextOut(Rect.Right - 6 - TextWidth('E'), Rect.Top + 0, 'E');
      if (Field_QSL = '001') then
        TextOut(Rect.Right - 6 - TextWidth('L'), Rect.Top + 0, 'L');
      if (Field_QSL = '101') then
        TextOut(Rect.Right - 10 - TextWidth('PL'), Rect.Top + 0, 'PL');
      if (Field_QSL = '011') then
        TextOut(Rect.Right - 10 - TextWidth('LE'), Rect.Top + 0, 'LE');
    end;
  end;
  if (Column.FieldName = 'QSLs') then
  begin
    with DBGrid.Canvas do
    begin
      FillRect(Rect);
      if (Field_QSLs = '10') then
        TextOut(Rect.Right - 6 - TextWidth('P'), Rect.Top + 0, 'P');
      if (Field_QSLs = '11') then
        TextOut(Rect.Right - 10 - TextWidth('PL'), Rect.Top + 0, 'PL');
      if (Field_QSLs = '01') then
        TextOut(Rect.Right - 6 - TextWidth('L'), Rect.Top + 0, 'L');
    end;
  end;
  if IniSet.showBand then
  begin
    if (Column.FieldName = 'QSOBand') then
    begin
      DBGrid.Canvas.FillRect(Rect);
      DBGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 0,
        dmFunc.GetBandFromFreq(DS.FieldByName('QSOBand').AsString));
    end;
  end;
end;

procedure TMainFunc.SelectAllQSO(var DBGrid: TDBGrid);
var
  i: integer;
begin
  if InitDB.DefLogBookQuery.RecordCount > 0 then
  begin
    InitDB.DefLogBookQuery.First;
    for i := 0 to InitDB.DefLogBookQuery.RecordCount - 1 do
    begin
      DBGrid.SelectedRows.CurrentRowSelected := True;
      InitDB.DefLogBookQuery.Next;
    end;
  end;
end;

procedure TMainFunc.FilterQSO(Field, Value: string);
begin
  try
    if InitRecord.SelectLogbookTable then
    begin
      if DBRecord.InitDB = 'YES' then
      begin
        InitDB.DefLogBookQuery.Close;
        if DBRecord.CurrentDB = 'MySQL' then
          InitDB.DefLogBookQuery.SQL.Text :=
            'SELECT `UnUsedIndex`, `CallSign`,' +
            ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
            + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
            + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
            + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
            + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
            + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
            + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
            + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
            + '`LoTWSent`) AS QSLs FROM ' + LBRecord.LogTable + ' WHERE ' +
            Field + ' LIKE ' + QuotedStr(Value) + ' ORDER BY `UnUsedIndex`'
        else
          InitDB.DefLogBookQuery.SQL.Text :=
            'SELECT `UnUsedIndex`, `CallSign`,' +
            ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
            + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
            + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
            + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
            + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
            + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
            + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
            + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||'
            + '`LoTWSent`) AS QSLs FROM ' + LBRecord.LogTable + ' WHERE ' +
            Field + ' LIKE ' + QuotedStr(Value) + ' ORDER BY `UnUsedIndex`';
        InitDB.DefLogBookQuery.Open;
      end;
    end;
  except
    on E: Exception do
      WriteLn(ExceptFile, 'FilterQSO:' + E.ClassName + ':' + E.Message);
  end;
end;

procedure TMainFunc.DeleteQSO(DBGrid: TDBGrid);
var
  i: integer;
  Query: TSQLQuery;
  RecIndex: integer;
begin
  if DBRecord.InitDB = 'YES' then
  begin
    try
      Query := TSQLQuery.Create(nil);
      if DBRecord.CurrentDB = 'MySQL' then
        Query.DataBase := InitDB.MySQLConnection
      else
        Query.DataBase := InitDB.SQLiteConnection;

      for i := 0 to DBGrid.SelectedRows.Count - 1 do
      begin
        DBGrid.DataSource.DataSet.GotoBookmark(Pointer(DBGrid.SelectedRows.Items[i]));
        RecIndex := DBGrid.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
        with Query do
        begin
          Close;
          SQL.Clear;
          SQL.Add('DELETE FROM ' + LBRecord.LogTable +
            ' WHERE `UnUsedIndex`=:UnUsedIndex');
          Params.ParamByName('UnUsedIndex').AsInteger := RecIndex;
          ExecSQL;
        end;
      end;
      InitDB.DefTransaction.Commit;
      if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
        ShowMessage(rDBError);
    finally
      FreeAndNil(Query);
    end;
  end;
end;

procedure TMainFunc.UpdateQSO(DBGrid: TDBGrid; Field, Value: string);
var
  Query: TSQLQuery;
  i: integer;
  RecIndex: integer;
begin
  try
    if InitRecord.SelectLogbookTable then
    begin
      if DBRecord.InitDB = 'YES' then
      begin
        try
          Query := TSQLQuery.Create(nil);
          if DBRecord.CurrentDB = 'MySQL' then
            Query.DataBase := InitDB.MySQLConnection
          else
            Query.DataBase := InitDB.SQLiteConnection;

          for i := 0 to DBGrid.SelectedRows.Count - 1 do
          begin
            DBGrid.DataSource.DataSet.GotoBookmark(
              Pointer(DBGrid.SelectedRows.Items[i]));
            RecIndex := DBGrid.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
            with Query do
            begin
              Close;
              SQL.Clear;
              if (Value = 'E') or (Value = 'F') or (Value = 'T') or
                (Value = 'Q') or (Field = 'QSLRec') then
              begin
                if Value = 'E' then
                begin
                  SQL.Add('UPDATE ' + LBRecord.LogTable + ' SET ' +
                    QuotedStr(Field) + '=:' + Field +
                    ',QSLReceQSLcc=:QSLReceQSLcc WHERE UnUsedIndex=:UnUsedIndex');
                  Params.ParamByName(Field).AsString := Value;
                  Params.ParamByName('QSLReceQSLcc').AsBoolean := True;
                end;
                if Value = 'T' then
                begin
                  SQL.Add('UPDATE ' + LBRecord.LogTable + ' SET ' +
                    QuotedStr(Field) + '=:' + Field +
                    ',QSLSentDate=:QSLSentDate,QSLSent=:QSLSent WHERE UnUsedIndex=:UnUsedIndex');
                  Params.ParamByName(Field).AsString := Value;
                  Params.ParamByName('QSLSentDate').AsDate := Now;
                  Params.ParamByName('QSLSent').Value := 1;
                end;
                if Value = 'F' then
                begin
                  SQL.Add('UPDATE ' + LBRecord.LogTable + ' SET ' +
                    QuotedStr(Field) + '=:' + Field +
                    ',QSLSentDate=:QSLSentDate,QSLSent=:QSLSent WHERE UnUsedIndex=:UnUsedIndex');
                  Params.ParamByName(Field).AsString := Value;
                  Params.ParamByName('QSLSentDate').IsNull;
                  Params.ParamByName('QSLSent').Value := 0;
                end;
                if (Value = 'Q') and (Field = 'QSLSentAdv') then
                begin
                  SQL.Add('UPDATE ' + LBRecord.LogTable + ' SET ' +
                    QuotedStr(Field) + '=:' + Field +
                    ',QSLRec=:QSLRec, QSLRecDate=:QSLRecDate WHERE UnUsedIndex=:UnUsedIndex');
                  Params.ParamByName(Field).AsString := Value;
                  Params.ParamByName('QSLRec').Value := 1;
                  Params.ParamByName('QSLRecDate').AsDate := Now;
                end;
                if Field = 'QSLPrint' then
                begin
                  SQL.Add('UPDATE ' + LBRecord.LogTable + ' SET ' +
                    '`QSLSentAdv`=:QSLSentAdv WHERE `UnUsedIndex`=:UnUsedIndex');
                  Params.ParamByName('QSLSentAdv').AsString := Value;
                end;
                if Field = 'QSLRec' then
                begin
                  SQL.Add('UPDATE ' + LBRecord.LogTable + ' SET ' +
                    QuotedStr(Field) + '=:' + Field +
                    ',`QSLRecDate`=:QSLRecDate WHERE `UnUsedIndex`=:UnUsedIndex');
                  Params.ParamByName(Field).Value := Field;
                  Params.ParamByName('QSLRecDate').AsDate := Now;
                end;
              end
              else
              begin
                SQL.Add('UPDATE ' + LBRecord.LogTable + ' SET ' +
                  QuotedStr(Field) + '=:' + Field + ' WHERE UnUsedIndex=:UnUsedIndex');
                Params.ParamByName(Field).AsString := Value;
              end;
              Params.ParamByName('UnUsedIndex').AsInteger := RecIndex;
              ExecSQL;
            end;
          end;
          InitDB.DefTransaction.Commit;
          if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
            ShowMessage(rDBError);

        finally
          FreeAndNil(Query);
          SetGrid(DBGrid);
          CurrPosGrid(GridRecordIndex, DBGrid);
        end;
      end;
    end;

  except
    on E: Exception do
      WriteLn(ExceptFile, 'UpdateQSO:' + E.ClassName + ':' + E.Message);
  end;
end;

function TMainFunc.GetAllCallsign: CallsignArray;
var
  i: integer;
  Query: TSQLQuery;
  CallsignList: CallsignArray;
begin
  if InitRecord.SelectLogbookTable then
  begin
    try
      Query := TSQLQuery.Create(nil);
      Query.PacketRecords := 50;
      if DBRecord.CurrentDB = 'MySQL' then
        Query.DataBase := InitDB.MySQLConnection
      else
        Query.DataBase := InitDB.SQLiteConnection;

      Query.SQL.Text := 'SELECT CallName FROM LogBookInfo';
      Query.Open;
      if Query.RecordCount = 0 then
        Exit;
      SetLength(CallsignList, Query.RecordCount);
      Query.First;
      for i := 0 to Query.RecordCount - 1 do
      begin
        CallsignList[i] := Query.FieldByName('CallName').AsString;
        Query.Next;
      end;
      Query.Close;
      Result := CallsignList;
    finally
      FreeAndNil(Query);
    end;
  end;
end;

function TMainFunc.SelectQSO(DataSource: TDataSource): TSelQSOR;
begin
  Result.QSODate := DataSource.DataSet.FieldByName('QSODate').AsString;
  Result.QSOTime := DataSource.DataSet.FieldByName('QSOTime').AsString;
  Result.QSOBand := DataSource.DataSet.FieldByName('QSOBand').AsString;
  Result.QSOMode := DataSource.DataSet.FieldByName('QSOMode').AsString;
  Result.OMName := DataSource.DataSet.FieldByName('OMName').AsString;
  Result.NumSelectQSO := DataSource.DataSet.RecNo;
end;

function TMainFunc.FindQSO(Callsign: string): TFoundQSOR;
begin
  try
    Result.Found := False;
    Result.CountQSO := 0;

    if InitRecord.SelectLogbookTable then
    begin
      InitDB.FindQSOQuery.Close;
      if DBRecord.CurrentDB = 'MySQL' then
        InitDB.FindQSOQuery.DataBase := InitDB.MySQLConnection
      else
        InitDB.FindQSOQuery.DataBase := InitDB.SQLiteConnection;
      if DBRecord.CurrentDB = 'MySQL' then
        InitDB.FindQSOQuery.SQL.Text :=
          'SELECT `UnUsedIndex`, `CallSign`,' +
          ' DATE_FORMAT(QSODate, ''%d.%m.%Y'') as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, CONCAT(`QSLRec`,`QSLReceQSLcc`,`LoTWRec`) AS QSL, CONCAT(`QSLSent`,'
          + '`LoTWSent`) AS QSLs FROM ' + LBRecord.LogTable +
          ' WHERE `Call` LIKE ' + QuotedStr(Callsign) +
          ' ORDER BY UNIX_TIMESTAMP(STR_TO_DATE(QSODate, ''%Y-%m-%d'')) DESC, QSOTime DESC'
      else
        InitDB.FindQSOQuery.SQL.Text :=
          'SELECT `UnUsedIndex`, `CallSign`,' +
          'strftime("%d.%m.%Y",QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,`QSOReportSent`,`QSOReportRecived`,'
          + '`OMName`,`OMQTH`, `State`,`Grid`,`IOTA`,`QSLManager`,`QSLSent`,`QSLSentAdv`,'
          + '`QSLSentDate`,`QSLRec`, `QSLRecDate`,`MainPrefix`,`DXCCPrefix`,`CQZone`,`ITUZone`,'
          + '`QSOAddInfo`,`Marker`, `ManualSet`,`DigiBand`,`Continent`,`ShortNote`,`QSLReceQSLcc`,'
          + '`LoTWRec`, `LoTWRecDate`,`QSLInfo`,`Call`,`State1`,`State2`,`State3`,`State4`,'
          + '`WPX`, `AwardsEx`,`ValidDX`,`SRX`,`SRX_STRING`,`STX`,`STX_STRING`,`SAT_NAME`,'
          + '`SAT_MODE`,`PROP_MODE`,`LoTWSent`,`QSL_RCVD_VIA`,`QSL_SENT_VIA`, `DXCC`,`USERS`,'
          + '`NoCalcDXCC`, (`QSLRec` || `QSLReceQSLcc` || `LoTWRec`) AS QSL, (`QSLSent`||`LoTWSent`) AS QSLs FROM '
          + LBRecord.LogTable +
          ' INNER JOIN (SELECT UnUsedIndex, QSODate as QSODate2, QSOTime as QSOTime2 from '
          + LBRecord.LogTable + ' WHERE `Call` LIKE ' +
          QuotedStr(Callsign) +
          ' ORDER BY QSODate2 DESC, QSOTime2 DESC) as lim USING(UnUsedIndex)';
      InitDB.FindQSOQuery.Open;
      if InitDB.FindQSOQuery.RecordCount > 0 then
      begin
        Result.Found := True;
        Result.CountQSO := InitDB.FindQSOQuery.RecordCount;
        Result.OMName := InitDB.FindQSOQuery.FieldByName('OMName').AsString;
        Result.QSOTime := InitDB.FindQSOQuery.FieldByName('QSOTime').AsString;
        Result.QSODate := InitDB.FindQSOQuery.FieldByName('QSODate').AsString;
        Result.QSOBand := InitDB.FindQSOQuery.FieldByName('QSOBand').AsString;
        Result.QSOMode := InitDB.FindQSOQuery.FieldByName('QSOMode').AsString;
        Result.OMQTH := InitDB.FindQSOQuery.FieldByName('OMQTH').AsString;
        Result.Grid := InitDB.FindQSOQuery.FieldByName('Grid').AsString;
        Result.State := InitDB.FindQSOQuery.FieldByName('State').AsString;
        Result.IOTA := InitDB.FindQSOQuery.FieldByName('IOTA').AsString;
        Result.QSLManager := InitDB.FindQSOQuery.FieldByName('QSLManager').AsString;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('FindQSO:' + E.Message);
      WriteLn(ExceptFile, 'FindQSO:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

function TMainFunc.LoadSubModes(mode: string): subModeArray;
var
  i: integer;
  Query: TSQLQuery;
  SubModeList: subModeArray;
  SubModeSlist: TStringList;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.PacketRecords := 50;
      SubModeSlist := TStringList.Create;
      if InitDB.ServiceDBConnection.Connected then
      begin
        SubModeSlist.Delimiter := ',';
        Query.DataBase := InitDB.ServiceDBConnection;
        Query.SQL.Text := 'SELECT submode FROM Modes WHERE mode = ' + QuotedStr(mode);
        Query.Open;
        SubModeSlist.DelimitedText := Query.FieldByName('submode').AsString;
        Query.Close;
      end;
      if SubModeSlist.Count = 0 then
        Exit;
      SetLength(SubModeList, SubModeSlist.Count);
      for i := 0 to SubModeSlist.Count - 1 do
        SubModeList[i] := SubModeSlist.Strings[i];
      Result := SubModeList;
    finally
      FreeAndNil(Query);
      FreeAndNil(SubModeSlist);
    end;
  except
    on E: Exception do
      WriteLn(ExceptFile, 'LoadSubModes:' + E.ClassName + ':' + E.Message);
  end;
end;

function TMainFunc.LoadModes: modeArray;
var
  i: integer;
  Query: TSQLQuery;
  ModeList: modeArray;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.PacketRecords := 50;
      if InitDB.ServiceDBConnection.Connected then
      begin
        Query.DataBase := InitDB.ServiceDBConnection;
        Query.SQL.Text := 'SELECT * FROM Modes WHERE Enable = 1';
        Query.Open;
        if Query.RecordCount = 0 then
          Exit;
        SetLength(ModeList, Query.RecordCount);
        Query.First;
        for i := 0 to Query.RecordCount - 1 do
        begin
          ModeList[i] := Query.FieldByName('mode').AsString;
          Query.Next;
        end;
        Query.Close;
      end;
      Result := ModeList;
    finally
      FreeAndNil(Query);
    end;
  except
    on E: Exception do
      WriteLn(ExceptFile, 'LoadModes:' + E.ClassName + ':' + E.Message);
  end;
end;

function TMainFunc.LoadBands(mode: string): bandArray;
var
  Query: TSQLQuery;
  BandList: bandArray;
  i: integer;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.PacketRecords := 50;
      if InitDB.ServiceDBConnection.Connected then
      begin
        Query.DataBase := InitDB.ServiceDBConnection;
        Query.SQL.Text := 'SELECT * FROM Bands WHERE Enable = 1';
        Query.Open;
        if Query.RecordCount = 0 then
          Exit;
        SetLength(BandList, Query.RecordCount);
        Query.First;
        for i := 0 to Query.RecordCount - 1 do
        begin
          if IniSet.showBand then
            BandList[i] := Query.FieldByName('band').AsString
          else
          begin
            if mode = 'SSB' then
              BandList[i] := FormatFloat(view_freq, Query.FieldByName('ssb').AsFloat);
            if mode = 'CW' then
              BandList[i] := FormatFloat(view_freq, Query.FieldByName('cw').AsFloat);
            if (mode <> 'CW') and (mode <> 'SSB') then
              BandList[i] := FormatFloat(view_freq,
                Query.FieldByName('b_begin').AsFloat);
          end;
          Query.Next;
        end;
        Query.Close;
      end;
      Result := BandList;
    finally
      FreeAndNil(Query);
    end;
  except
    on E: Exception do
      WriteLn(ExceptFile, 'LoadBands:' + E.ClassName + ':' + E.Message);
  end;
end;

procedure TMainFunc.LoadINIsettings;
begin
  IniSet.UseIntCallBook := INIFile.ReadBool('SetLog', 'IntCallBook', True);
  IniSet.PhotoDir := INIFile.ReadString('SetLog', 'PhotoDir', '');
  IniSet.StateToQSLInfo := INIFile.ReadBool('SetLog', 'StateToQSLInfo', False);
  IniSet.Fl_PATH := INIFile.ReadString('FLDIGI', 'FldigiPATH', '');
  IniSet.WSJT_PATH := INIFile.ReadString('WSJT', 'WSJTPATH', '');
  IniSet.FLDIGI_USE := INIFile.ReadBool('FLDIGI', 'USEFLDIGI', False);
  IniSet.WSJT_USE := INIFile.ReadBool('WSJT', 'USEWSJT', False);
  IniSet.PastMode := INIFile.ReadString('SetLog', 'PastMode', '');
  IniSet.PastSubMode := INIFile.ReadString('SetLog', 'PastSubMode', '');
  IniSet.PastBand := INIFile.ReadInteger('SetLog', 'PastBand', 0);
  if IniSet.PastBand = -1 then
    IniSet.PastBand := 0;
  IniSet.Language := INIFile.ReadString('SetLog', 'Language', '');
  IniSet.Map_Use := INIFile.ReadBool('SetLog', 'UseMAPS', False);
  IniSet.PrintPrev := INIFile.ReadBool('SetLog', 'PrintPrev', False);
  IniSet.FormState := INIFile.ReadString('SetLog', 'FormState', '');
  IniSet.showBand := INIFile.ReadBool('SetLog', 'ShowBand', False);
  IniSet.CloudLogServer := INIFile.ReadString('SetLog', 'CloudLogServer', '');
  IniSet.CloudLogApiKey := INIFile.ReadString('SetLog', 'CloudLogApi', '');
  IniSet.AutoCloudLog := INIFile.ReadBool('SetLog', 'AutoCloudLog', False);
  IniSet.FreqToCloudLog := INIFile.ReadBool('SetLog', 'FreqToCloudLog', False);
  IniSet.QRZCOM_Login := INIFile.ReadString('SetLog', 'QRZCOM_Login', '');
  IniSet.QRZCOM_Pass := INIFile.ReadString('SetLog', 'QRZCOM_Pass', '');
  IniSet.QRZRU_Login := INIFile.ReadString('SetLog', 'QRZRU_Login', '');
  IniSet.QRZRU_Pass := INIFile.ReadString('SetLog', 'QRZRU_Pass', '');
  IniSet.CallBookSystem := INIFile.ReadString('SetLog', 'CallBookSystem', '');
  IniSet.HAMQTH_Login := INIFile.ReadString('SetLog', 'HAMQTH_Login', '');
  IniSet.HAMQTH_Pass := INIFile.ReadString('SetLog', 'HAMQTH_Pass', '');
  IniSet.MainForm := INIFile.ReadString('SetLog', 'MainForm', 'MAIN');
  IniSet.Cluster_Login := INIFile.ReadString('TelnetCluster', 'Login', '');
  IniSet.Cluster_Pass := INIFile.ReadString('TelnetCluster', 'Password', '');
  IniSet._l_multi := INIFile.ReadInteger('SetLog', 'multiLeft', 0);
  IniSet._t_multi := INIFile.ReadInteger('SetLog', 'multiTop', 0);
  IniSet._w_multi := INIFile.ReadInteger('SetLog', 'multiWidth', 1043);
  IniSet._h_multi := INIFile.ReadInteger('SetLog', 'multiHeight', 671);
  IniSet._l_main := INIFile.ReadInteger('SetLog', 'mainLeft', 0);
  IniSet._t_main := INIFile.ReadInteger('SetLog', 'mainTop', 0);
  IniSet._w_main := INIFile.ReadInteger('SetLog', 'mainWidth', 1043);
  IniSet._h_main := INIFile.ReadInteger('SetLog', 'mainHeight', 671);
  IniSet.mTop := INIFile.ReadBool('SetLog', 'mTop', False);
  IniSet._l_g := INIFile.ReadInteger('SetLog', 'gLeft', 0);
  IniSet._t_g := INIFile.ReadInteger('SetLog', 'gTop', 0);
  IniSet._w_g := INIFile.ReadInteger('SetLog', 'gWidth', 835);
  IniSet._h_g := INIFile.ReadInteger('SetLog', 'gHeight', 401);
  IniSet.gTop := INIFile.ReadBool('SetLog', 'gTop', False);
  IniSet.gShow := INIFile.ReadBool('SetLog', 'gShow', True);
  IniSet._l_c := INIFile.ReadInteger('SetLog', 'cLeft', 0);
  IniSet._t_c := INIFile.ReadInteger('SetLog', 'cTop', 0);
  IniSet._w_c := INIFile.ReadInteger('SetLog', 'cWidth', 735);
  IniSet._h_c := INIFile.ReadInteger('SetLog', 'cHeight', 240);
  IniSet.cTop := INIFile.ReadBool('SetLog', 'cTop', False);
  IniSet.cShow := INIFile.ReadBool('SetLog', 'cShow', True);
  IniSet._l_e := INIFile.ReadInteger('SetLog', 'eLeft', 0);
  IniSet._t_e := INIFile.ReadInteger('SetLog', 'eTop', 0);
  IniSet._w_e := INIFile.ReadInteger('SetLog', 'eWidth', 320);
  IniSet._h_e := INIFile.ReadInteger('SetLog', 'eHeight', 156);
  IniSet.eTop := INIFile.ReadBool('SetLog', 'eTop', False);
  IniSet.eShow := INIFile.ReadBool('SetLog', 'eShow', True);
  IniSet._l_p := INIFile.ReadInteger('SetLog', 'pLeft', 0);
  IniSet._t_p := INIFile.ReadInteger('SetLog', 'pTop', 0);
  IniSet._w_p := INIFile.ReadInteger('SetLog', 'pWidth', 320);
  IniSet._h_p := INIFile.ReadInteger('SetLog', 'pHeight', 156);
  IniSet.pTop := INIFile.ReadBool('SetLog', 'pTop', False);
  IniSet.pShow := INIFile.ReadBool('SetLog', 'pShow', True);
  IniSet.pSeparate := INIFile.ReadBool('SetLog', 'pSeparate', False);
  IniSet._l_trx := INIFile.ReadInteger('SetLog', 'trxLeft', 0);
  IniSet._t_trx := INIFile.ReadInteger('SetLog', 'trxTop', 0);
  IniSet._w_trx := INIFile.ReadInteger('SetLog', 'trxWidth', 320);
  IniSet._h_trx := INIFile.ReadInteger('SetLog', 'trxHeight', 156);
  IniSet.trxTop := INIFile.ReadBool('SetLog', 'trxTop', False);
  IniSet.trxShow := INIFile.ReadBool('SetLog', 'trxShow', False);
  IniSet.ClusterAutoStart := INIFile.ReadBool('TelnetCluster', 'AutoStart', False);
end;

procedure TMainFunc.CheckDXCC(Callsign, mode, band: string;
  var DMode, DBand, DCall: boolean);
var
  Query: TSQLQuery;
  PFXR: TPFXR;
begin
  try
    if InitRecord.SelectLogbookTable then
    begin
      try
        PFXR := SearchPrefix(Callsign, '');
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
        if DBRecord.CurrentDB = 'MySQL' then
          Query.DataBase := InitDB.MySQLConnection
        else
          Query.DataBase := InitDB.SQLiteConnection;

        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' LIMIT 1';
        Query.Open;
        if Query.RecordCount > 0 then
          DCall := False
        else
          DCall := True;
        Query.Close;
        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND QSOMode = ' +
          QuotedStr(mode) + ' LIMIT 1';
        Query.Open;
        if Query.RecordCount > 0 then
          DMode := False
        else
          DMode := True;
        Query.Close;
        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
          FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band, mode))) + ' LIMIT 1';
        Query.Open;
        if Query.RecordCount > 0 then
          DBand := False
        else
          DBand := True;
      finally
        Query.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('CheckDXCC:' + E.Message);
      WriteLn(ExceptFile, 'CheckDXCC:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

function TMainFunc.CheckQSL(Callsign, band, mode: string): integer;
var
  Query: TSQLQuery;
  PFXR: TPFXR;
begin
  try
    if InitRecord.SelectLogbookTable then
    begin
      try
        PFXR := SearchPrefix(Callsign, '');
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
        if DBRecord.CurrentDB = 'MySQL' then
          Query.DataBase := InitDB.MySQLConnection
        else
          Query.DataBase := InitDB.SQLiteConnection;

        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
          FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band, mode))) +
          ' AND (QSLRec = 1 OR LoTWRec = 1) LIMIT 1';
        Query.Open;
        if Query.RecordCount > 0 then
        begin
          Result := 0;
          Exit;
        end;
        Query.Close;

        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' LIMIT 1';
        Query.Open;
        if Query.RecordCount = 0 then
        begin
          Result := 0;
          Exit;
        end;
        Query.Close;

        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
          FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band, mode))) +
          ' AND (QSLRec = 0 AND LoTWRec = 0) LIMIT 1';
        Query.Open;
        if Query.RecordCount = 0 then
        begin
          Result := 2;
          Exit;
        end
        else
        begin
          Result := 1;
          Exit;
        end;
        Query.Close;

      finally
        Query.Free;
      end;
    end;

  except
    on E: Exception do
    begin
      ShowMessage('CheckQSL:' + E.Message);
      WriteLn(ExceptFile, 'CheckQSL:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

function TMainFunc.FindWorkedCall(Callsign, band, mode: string): boolean;
var
  Query: TSQLQuery;
begin
  try
    Result := False;
    if InitRecord.SelectLogbookTable then
    begin
      try
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
        if DBRecord.CurrentDB = 'MySQL' then
          Query.DataBase := InitDB.MySQLConnection
        else
          Query.DataBase := InitDB.SQLiteConnection;
        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE `Call` = ' + QuotedStr(Callsign) + ' AND DigiBand = ' +
          FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band, mode))) +
          ' AND QSOMode = ' + QuotedStr(mode) + ' LIMIT 1';
        Query.Open;
        if Query.RecordCount > 0 then
          Result := True;

      finally
        Query.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('FindWorkedCall:' + E.Message);
      WriteLn(ExceptFile, 'FindWorkedCall:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

function TMainFunc.WorkedQSL(Callsign, band, mode: string): boolean;
var
  Query: TSQLQuery;
begin
  try
    Result := False;
    if InitRecord.SelectLogbookTable then
    begin
      try
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
        if DBRecord.CurrentDB = 'MySQL' then
          Query.DataBase := InitDB.MySQLConnection
        else
          Query.DataBase := InitDB.SQLiteConnection;
        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE `Call` = ' + QuotedStr(Callsign) + ' AND DigiBand = ' +
          FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band, mode))) +
          ' AND (LoTWRec = 1 OR QSLRec = 1) LIMIT 1';
        Query.Open;
        if Query.RecordCount > 0 then
          Result := True;

      finally
        Query.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('WorkedQSL:' + E.Message);
      WriteLn(ExceptFile, 'WorkedQSL:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

function TMainFunc.WorkedLoTW(Callsign, band, mode: string): boolean;
var
  Query: TSQLQuery;
  PFXR: TPFXR;
begin
  try
    Result := False;
    if InitRecord.SelectLogbookTable then
    begin
      try
        PFXR := SearchPrefix(Callsign, '');
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
        if DBRecord.CurrentDB = 'MySQL' then
          Query.DataBase := InitDB.MySQLConnection
        else
          Query.DataBase := InitDB.SQLiteConnection;

        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
          FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band, mode))) +
          ' AND (LoTWRec = 1 OR QSLRec = 1) LIMIT 1';
        Query.Open;
        if Query.RecordCount > 0 then
          Result := True;

      finally
        Query.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('WorkedLoTW:' + E.Message);
      WriteLn(ExceptFile, 'WorkedLoTW:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

function TMainFunc.SearchPrefix(Callsign, Grid: string): TPFXR;
var
  i: integer;
  La, Lo: currency;
begin
  try
    ClearPFXR(Result);
    if InitRecord.InitPrefix then
    begin
      if UniqueCallsList.IndexOf(Callsign) > -1 then
      begin
        with SearchPrefixQuery do
        begin
          Close;
          SQL.Text := 'SELECT * FROM UniqueCalls WHERE _id = "' +
            IntToStr(UniqueCallsList.IndexOf(Callsign)) + '"';
          Open;
          Result.Country := FieldByName('Country').AsString;
          Result.ARRLPrefix := FieldByName('ARRLPrefix').AsString;
          Result.Prefix := FieldByName('Prefix').AsString;
          Result.CQZone := FieldByName('CQZone').AsString;
          Result.ITUZone := FieldByName('ITUZone').AsString;
          Result.Continent := FieldByName('Continent').AsString;
          Result.Latitude := FieldByName('Latitude').AsString;
          Result.Longitude := FieldByName('Longitude').AsString;
          Result.DXCCNum := FieldByName('DXCC').AsInteger;
        end;
        if (Grid <> '') and dmFunc.IsLocOK(Grid) then
        begin
          dmFunc.CoordinateFromLocator(Grid, La, Lo);
          Result.Latitude := CurrToStr(La);
          Result.Longitude := CurrToStr(Lo);
        end;
        GetDistAzim(Result.Latitude, Result.Longitude, Result.Distance, Result.Azimuth);
        Result.Found := True;
        Exit;
      end;

      for i := 0 to PrefixProvinceCount - 1 do
      begin
        if (PrefixExpProvinceArray[i].reg.Exec(Callsign)) and
          (PrefixExpProvinceArray[i].reg.Match[0] = Callsign) then
        begin
          with SearchPrefixQuery do
          begin
            Close;
            SQL.Text := 'SELECT * FROM Province WHERE _id = "' +
              IntToStr(PrefixExpProvinceArray[i].id) + '"';
            Open;
            Result.Country := FieldByName('Country').AsString;
            Result.ARRLPrefix := FieldByName('ARRLPrefix').AsString;
            Result.Prefix := FieldByName('Prefix').AsString;
            Result.CQZone := FieldByName('CQZone').AsString;
            Result.ITUZone := FieldByName('ITUZone').AsString;
            Result.Continent := FieldByName('Continent').AsString;
            Result.Latitude := FieldByName('Latitude').AsString;
            Result.Longitude := FieldByName('Longitude').AsString;
            Result.DXCCNum := FieldByName('DXCC').AsInteger;
            Result.TimeDiff := FieldByName('TimeDiff').AsInteger;
          end;
          if (Grid <> '') and dmFunc.IsLocOK(Grid) then
          begin
            dmFunc.CoordinateFromLocator(Grid, La, Lo);
            Result.Latitude := CurrToStr(La);
            Result.Longitude := CurrToStr(Lo);
          end;
          GetDistAzim(Result.Latitude, Result.Longitude, Result.Distance,
            Result.Azimuth);
          Result.Found := True;
          Exit;
        end;
      end;

      for i := 0 to PrefixARRLCount - 1 do
      begin
        if (PrefixExpARRLArray[i].reg.Exec(Callsign)) and
          (PrefixExpARRLArray[i].reg.Match[0] = Callsign) then
        begin
          with SearchPrefixQuery do
          begin
            Close;
            SQL.Text := 'SELECT * FROM CountryDataEx WHERE _id = "' +
              IntToStr(PrefixExpARRLArray[i].id) + '"';
            Open;
            if (FieldByName('Status').AsString = 'Deleted') then
            begin
              PrefixExpARRLArray[i].reg.ExecNext;
              Exit;
            end;
          end;
          Result.Country := SearchPrefixQuery.FieldByName('Country').AsString;
          Result.ARRLPrefix := SearchPrefixQuery.FieldByName('ARRLPrefix').AsString;
          Result.Prefix := SearchPrefixQuery.FieldByName('ARRLPrefix').AsString;
          Result.CQZone := SearchPrefixQuery.FieldByName('CQZone').AsString;
          Result.ITUZone := SearchPrefixQuery.FieldByName('ITUZone').AsString;
          Result.Continent := SearchPrefixQuery.FieldByName('Continent').AsString;
          Result.Latitude := SearchPrefixQuery.FieldByName('Latitude').AsString;
          Result.Longitude := SearchPrefixQuery.FieldByName('Longitude').AsString;
          Result.DXCCNum := SearchPrefixQuery.FieldByName('DXCC').AsInteger;
          Result.TimeDiff := SearchPrefixQuery.FieldByName('TimeDiff').AsInteger;
          if (Grid <> '') and dmFunc.IsLocOK(Grid) then
          begin
            dmFunc.CoordinateFromLocator(Grid, La, Lo);
            Result.Latitude := CurrToStr(La);
            Result.Longitude := CurrToStr(Lo);
          end;
          GetDistAzim(Result.Latitude, Result.Longitude, Result.Distance,
            Result.Azimuth);
          Result.Found := True;
          Exit;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('SearchPrefix:' + E.Message);
      WriteLn(ExceptFile, 'SearchPrefix:' + E.ClassName + ':' + E.Message +
        ':' + IntToStr(i));
    end;
  end;
end;

procedure TMainFunc.GetDistAzim(Latitude, Longitude: string;
  var Distance, Azimuth: string);
var
  azim, qra: string;
begin
  qra := '';
  azim := '';
  if (UTF8Pos('W', Longitude) <> 0) then
  begin
    Longitude := '-' + Longitude;
    Delete(Longitude, length(Longitude), 1);
  end;
  if (UTF8Pos('S', Latitude) <> 0) then
  begin
    Latitude := '-' + Latitude;
    Delete(Latitude, length(Latitude), 1);
  end;
  if (UTF8Pos('E', Longitude) <> 0) then
  begin
    Delete(Longitude, length(Longitude), 1);
  end;
  if (UTF8Pos('N', Latitude) <> 0) then
  begin
    Delete(Latitude, length(Latitude), 1);
  end;
  DefaultFormatSettings.DecimalSeparator := '.';
  dmFunc.DistanceFromCoordinate(LBRecord.OpLoc, StrToFloat(Latitude),
    strtofloat(Longitude), qra, azim);
  Azimuth := azim;
  Distance := qra + ' KM';
end;

procedure TMainFunc.DataModuleCreate(Sender: TObject);
begin
  SearchPrefixQuery := TSQLQuery.Create(nil);
  SearchPrefixQuery.DataBase := InitDB.ServiceDBConnection;
end;

procedure TMainFunc.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(SearchPrefixQuery);
end;

procedure TMainFunc.SaveQSO(var SQSO: TQSO);
var
  QueryTXT: string;
  SRXs, STXs, QSODates: string;
begin
  try
    try
      if SQSO.LotWRec = '' then
        SQSO.LotWRec := IntToStr(0)
      else
        SQSO.LotWRec := IntToStr(1);
      SRXs := IntToStr(SQSO.SRX);
      STXs := IntToStr(SQSO.STX);

      if SQSO.SRX = 0 then
        SRXs := 'NULL';

      if SQSO.STX = 0 then
        STXs := 'NULL';

      if SQSO.QSL_RCVD_VIA = '' then
        SQSO.QSL_RCVD_VIA := 'NULL';
      if SQSO.QSL_SENT_VIA = '' then
        SQSO.QSL_SENT_VIA := 'NULL';

      if DBRecord.CurrentDB = 'MySQL' then
        QSODates := DateToStr(SQSO.QSODate)
      else
        QSODates := FloatToStr(DateTimeToJulianDate(SQSO.QSODate));

      QueryTXT := 'INSERT INTO ' + LBRecord.LogTable + ' (' +
        'CallSign, QSODate, QSOTime, QSOBand, QSOMode, QSOSubMode,' +
        'QSOReportSent, QSOReportRecived, OMName, OMQTH, State, Grid, IOTA,' +
        'QSLManager, QSLSent, QSLSentAdv, QSLRec,' +
        'MainPrefix, DXCCPrefix, CQZone, ITUZone, QSOAddInfo, Marker, ManualSet,' +
        'DigiBand, Continent, ShortNote, QSLReceQSLcc, LoTWRec,' +
        'QSLInfo, `Call`, State1, State2, State3, State4, WPX, AwardsEx,' +
        'ValidDX, SRX, SRX_STRING, STX, STX_STRING, SAT_NAME, SAT_MODE,' +
        'PROP_MODE, LoTWSent, QSL_RCVD_VIA, QSL_SENT_VIA, DXCC, USERS, NoCalcDXCC,' +
        'MY_STATE, MY_GRIDSQUARE, MY_LAT, MY_LON, SYNC) VALUES (' +
        dmFunc.Q(SQSO.CallSing) + dmFunc.Q(QSODates) + dmFunc.Q(SQSO.QSOTime) +
        dmFunc.Q(SQSO.QSOBand) + dmFunc.Q(SQSO.QSOMode) +
        dmFunc.Q(SQSO.QSOSubMode) + dmFunc.Q(SQSO.QSOReportSent) +
        dmFunc.Q(SQSO.QSOReportRecived) + dmFunc.Q(SQSO.OmName) +
        dmFunc.Q(SQSO.OmQTH) + dmFunc.Q(SQSO.State0) + dmFunc.Q(SQSO.Grid) +
        dmFunc.Q(SQSO.IOTA) + dmFunc.Q(SQSO.QSLManager) + dmFunc.Q(SQSO.QSLSent) +
        dmFunc.Q(SQSO.QSLSentAdv) + dmFunc.Q(SQSO.QSLRec) +
        dmFunc.Q(SQSO.MainPrefix) + dmFunc.Q(SQSO.DXCCPrefix) +
        dmFunc.Q(SQSO.CQZone) + dmFunc.Q(SQSO.ITUZone) +
        dmFunc.Q(SQSO.QSOAddInfo) + dmFunc.Q(SQSO.Marker) +
        dmFunc.Q(IntToStr(SQSO.ManualSet)) + dmFunc.Q(SQSO.DigiBand) +
        dmFunc.Q(SQSO.Continent) + dmFunc.Q(SQSO.ShortNote) +
        dmFunc.Q(IntToStr(SQSO.QSLReceQSLcc)) + dmFunc.Q(SQSO.LotWRec) +
        dmFunc.Q(SQSO.QSLInfo) + dmFunc.Q(SQSO.Call) + dmFunc.Q(SQSO.State1) +
        dmFunc.Q(SQSO.State2) + dmFunc.Q(SQSO.State3) + dmFunc.Q(SQSO.State4) +
        dmFunc.Q(SQSO.WPX) + dmFunc.Q(SQSO.AwardsEx) + dmFunc.Q(SQSO.ValidDX) +
        dmFunc.Q(SRXs) + dmFunc.Q(SQSO.SRX_String) + dmFunc.Q(STXs) +
        dmFunc.Q(SQSO.STX_String) + dmFunc.Q(SQSO.SAT_NAME) +
        dmFunc.Q(SQSO.SAT_MODE) + dmFunc.Q(SQSO.PROP_MODE) +
        dmFunc.Q(IntToStr(SQSO.LotWSent)) + dmFunc.Q(SQSO.QSL_RCVD_VIA) +
        dmFunc.Q(SQSO.QSL_SENT_VIA) + dmFunc.Q(SQSO.DXCC) +
        dmFunc.Q(SQSO.USERS) + dmFunc.Q(IntToStr(SQSO.NoCalcDXCC)) +
        dmFunc.Q(SQSO.My_State) + dmFunc.Q(SQSO.My_Grid) + dmFunc.Q(SQSO.My_Lat) +
        dmFunc.Q(SQSO.My_Lon) + QuotedStr(IntToStr(SQSO.SYNC)) + ')';

      if DBRecord.CurrentDB = 'MySQL' then
        InitDB.MySQLConnection.ExecuteDirect(QueryTXT)
      else
        InitDB.SQLiteConnection.ExecuteDirect(QueryTXT);
    finally
      InitDB.DefTransaction.Commit;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('SaveQSO:' + E.Message);
      WriteLn(ExceptFile, 'SaveQSO:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

procedure TMainFunc.SetGrid(var DBGRID: TDBGrid);
var
  i: integer;
  QBAND: string;
  ColorTextGrid: integer;
  ColorBackGrid: integer;
  SizeTextGrid: integer;
begin
  for i := 0 to 29 do
  begin
    columnsGrid[i] :=
      INIFile.ReadString('GridSettings', 'Columns' + IntToStr(i), constColumnName[i]);
    columnsWidth[i] :=
      INIFile.ReadInteger('GridSettings', 'ColWidth' + IntToStr(i), constColumnWidth[i]);
    columnsVisible[i] :=
      INIFile.ReadBool('GridSettings', 'ColVisible' + IntToStr(i), True);
  end;

  ColorTextGrid := INIFile.ReadInteger('GridSettings', 'TextColor', 0);
  SizeTextGrid := INIFile.ReadInteger('GridSettings', 'TextSize', 8);
  ColorBackGrid := INIFile.ReadInteger('GridSettings', 'BackColor', -2147483617);

  DBGRID.Font.Size := SizeTextGrid;
  DBGRID.Font.Color := ColorTextGrid;
  DBGRID.Color := ColorBackGrid;

  if INIFile.ReadString('SetLog', 'ShowBand', '') = 'True' then
    QBAND := rQSOBand
  else
    QBAND := rQSOBandFreq;

  for i := 0 to 29 do
  begin
    DBGRID.Columns.Items[i].FieldName := columnsGrid[i];
    DBGRID.Columns.Items[i].Width := columnsWidth[i];
    case columnsGrid[i] of
      'QSL': DBGRID.Columns.Items[i].Title.Caption := rQSL;
      'QSLs': DBGRID.Columns.Items[i].Title.Caption := rQSLs;
      'QSODate': DBGRID.Columns.Items[i].Title.Caption := rQSODate;
      'QSOTime': DBGRID.Columns.Items[i].Title.Caption := rQSOTime;
      'QSOBand': DBGRID.Columns.Items[i].Title.Caption := QBAND;
      'CallSign': DBGRID.Columns.Items[i].Title.Caption := rCallSign;
      'QSOMode': DBGRID.Columns.Items[i].Title.Caption := rQSOMode;
      'QSOSubMode': DBGRID.Columns.Items[i].Title.Caption := rQSOSubMode;
      'OMName': DBGRID.Columns.Items[i].Title.Caption := rOMName;
      'OMQTH': DBGRID.Columns.Items[i].Title.Caption := rOMQTH;
      'State': DBGRID.Columns.Items[i].Title.Caption := rState;
      'Grid': DBGRID.Columns.Items[i].Title.Caption := rGrid;
      'QSOReportSent': DBGRID.Columns.Items[i].Title.Caption := rQSOReportSent;
      'QSOReportRecived': DBGRID.Columns.Items[i].Title.Caption := rQSOReportRecived;
      'IOTA': DBGRID.Columns.Items[i].Title.Caption := rIOTA;
      'QSLManager': DBGRID.Columns.Items[i].Title.Caption := rQSLManager;
      'QSLSentDate': DBGRID.Columns.Items[i].Title.Caption := rQSLSentDate;
      'QSLRecDate': DBGRID.Columns.Items[i].Title.Caption := rQSLRecDate;
      'LoTWRecDate': DBGRID.Columns.Items[i].Title.Caption := rLoTWRecDate;
      'MainPrefix': DBGRID.Columns.Items[i].Title.Caption := rMainPrefix;
      'DXCCPrefix': DBGRID.Columns.Items[i].Title.Caption := rDXCCPrefix;
      'CQZone': DBGRID.Columns.Items[i].Title.Caption := rCQZone;
      'ITUZone': DBGRID.Columns.Items[i].Title.Caption := rITUZone;
      'ManualSet': DBGRID.Columns.Items[i].Title.Caption := rManualSet;
      'Continent': DBGRID.Columns.Items[i].Title.Caption := rContinent;
      'ValidDX': DBGRID.Columns.Items[i].Title.Caption := rValidDX;
      'QSL_RCVD_VIA': DBGRID.Columns.Items[i].Title.Caption := rQSL_RCVD_VIA;
      'QSL_SENT_VIA': DBGRID.Columns.Items[i].Title.Caption := rQSL_SENT_VIA;
      'USERS': DBGRID.Columns.Items[i].Title.Caption := rUSERS;
      'NoCalcDXCC': DBGRID.Columns.Items[i].Title.Caption := rNoCalcDXCC;
    end;

    case columnsGrid[i] of
      'QSL': DBGRID.Columns.Items[i].Visible := columnsVisible[0];
      'QSLs': DBGRID.Columns.Items[i].Visible := columnsVisible[1];
      'QSODate': DBGRID.Columns.Items[i].Visible := columnsVisible[2];
      'QSOTime': DBGRID.Columns.Items[i].Visible := columnsVisible[3];
      'QSOBand': DBGRID.Columns.Items[i].Visible := columnsVisible[4];
      'CallSign': DBGRID.Columns.Items[i].Visible := columnsVisible[5];
      'QSOMode': DBGRID.Columns.Items[i].Visible := columnsVisible[6];
      'QSOSubMode': DBGRID.Columns.Items[i].Visible := columnsVisible[7];
      'OMName': DBGRID.Columns.Items[i].Visible := columnsVisible[8];
      'OMQTH': DBGRID.Columns.Items[i].Visible := columnsVisible[9];
      'State': DBGRID.Columns.Items[i].Visible := columnsVisible[10];
      'Grid': DBGRID.Columns.Items[i].Visible := columnsVisible[11];
      'QSOReportSent': DBGRID.Columns.Items[i].Visible := columnsVisible[12];
      'QSOReportRecived': DBGRID.Columns.Items[i].Visible := columnsVisible[13];
      'IOTA': DBGRID.Columns.Items[i].Visible := columnsVisible[14];
      'QSLManager': DBGRID.Columns.Items[i].Visible := columnsVisible[15];
      'QSLSentDate': DBGRID.Columns.Items[i].Visible := columnsVisible[16];
      'QSLRecDate': DBGRID.Columns.Items[i].Visible := columnsVisible[17];
      'LoTWRecDate': DBGRID.Columns.Items[i].Visible := columnsVisible[18];
      'MainPrefix': DBGRID.Columns.Items[i].Visible := columnsVisible[19];
      'DXCCPrefix': DBGRID.Columns.Items[i].Visible := columnsVisible[20];
      'CQZone': DBGRID.Columns.Items[i].Visible := columnsVisible[21];
      'ITUZone': DBGRID.Columns.Items[i].Visible := columnsVisible[22];
      'ManualSet': DBGRID.Columns.Items[i].Visible := columnsVisible[23];
      'Continent': DBGRID.Columns.Items[i].Visible := columnsVisible[24];
      'ValidDX': DBGRID.Columns.Items[i].Visible := columnsVisible[25];
      'QSL_RCVD_VIA': DBGRID.Columns.Items[i].Visible := columnsVisible[26];
      'QSL_SENT_VIA': DBGRID.Columns.Items[i].Visible := columnsVisible[27];
      'USERS': DBGRID.Columns.Items[i].Visible := columnsVisible[28];
      'NoCalcDXCC': DBGRID.Columns.Items[i].Visible := columnsVisible[29];
    end;
  end;

  case SizeTextGrid of
    8: DBGRID.DefaultRowHeight := 15;
    10: DBGRID.DefaultRowHeight := DBGRID.Font.Size + 12;
    12: DBGRID.DefaultRowHeight := DBGRID.Font.Size + 12;
    14: DBGRID.DefaultRowHeight := DBGRID.Font.Size + 12;
  end;

  for i := 0 to DBGRID.Columns.Count - 1 do
    DBGRID.Columns.Items[i].Title.Font.Size := SizeTextGrid;
end;

procedure TMainFunc.LoadBMSL(var CBMode, CBSubMode, CBBand, CBJournal: TComboBox);
var
  i: integer;
begin
  //Загрузка модуляций
  CBMode.Items.Clear;
  for i := 0 to High(LoadModes) do
    CBMode.Items.Add(LoadModes[i]);
  CBMode.ItemIndex := CBMode.Items.IndexOf(IniSet.PastMode);
  //Загрузка Sub модуляций
  CBSubMode.Items.Clear;
  for i := 0 to High(MainFunc.LoadSubModes(CBMode.Text)) do
    CBSubMode.Items.Add(MainFunc.LoadSubModes(CBMode.Text)[i]);
  CBSubMode.Text := IniSet.PastSubMode;
  //загрузка диапазонов
  CBBand.Items.Clear;
  for i := 0 to High(LoadBands(CBMode.Text)) do
    CBBand.Items.Add(LoadBands(CBMode.Text)[i]);
  CBBand.ItemIndex := IniSet.PastBand;
  if DBRecord.InitDB = 'YES' then
  begin
    //загрузка позывных журналов
    CBJournal.Items.Clear;
    for i := 0 to High(GetAllCallsign) do
      CBJournal.Items.Add(GetAllCallsign[i]);
    CBJournal.ItemIndex := CBJournal.Items.IndexOf(DBRecord.CurrCall);
  end;
end;

procedure TMainFunc.LoadBMSL(var CBMode, CBSubMode, CBBand: TComboBox); overload;
var
  i: integer;
begin
  //Загрузка модуляций
  CBMode.Items.Clear;
  for i := 0 to High(LoadModes) do
    CBMode.Items.Add(LoadModes[i]);
  //Загрузка Sub модуляций
  CBSubMode.Items.Clear;
  for i := 0 to High(MainFunc.LoadSubModes(CBMode.Text)) do
    CBSubMode.Items.Add(MainFunc.LoadSubModes(CBMode.Text)[i]);
  //загрузка диапазонов
  CBBand.Items.Clear;
  for i := 0 to High(LoadBands(CBMode.Text)) do
    CBBand.Items.Add(LoadBands(CBMode.Text)[i]);
end;

procedure TMainFunc.LoadJournalItem(var CBJournal: TComboBox);
var
  i: integer;
begin
  if DBRecord.InitDB = 'YES' then
  begin
    //загрузка позывных журналов
    CBJournal.Items.Clear;
    for i := 0 to High(GetAllCallsign) do
      CBJournal.Items.Add(GetAllCallsign[i]);
    CBJournal.ItemIndex := CBJournal.Items.IndexOf(DBRecord.CurrCall);
  end;
end;

procedure TMainFunc.ClearPFXR(var PFXR: TPFXR);
begin
  PFXR.Country := '';
  PFXR.ARRLPrefix := '';
  PFXR.Prefix := '';
  PFXR.CQZone := '';
  PFXR.ITUZone := '';
  PFXR.Continent := '';
  PFXR.Latitude := '';
  PFXR.Longitude := '';
  PFXR.DXCCNum := 0;
  PFXR.TimeDiff := 0;
  PFXR.Distance := '';
  PFXR.Azimuth := '';
  PFXR.Found := False;
end;

end.
