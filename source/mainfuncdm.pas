(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit MainFuncDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, SQLDB, RegExpr, qso_record, Dialogs, ResourceStr,
  prefix_record, LazUTF8, const_u, DBGrids, inifile_record, selectQSO_record,
  foundQSO_record, StdCtrls, Grids, Graphics, DateUtils, mvTypes, mvMapViewer,
  VirtualTrees, LazFileUtils, LCLType, CloudLogCAT, progressForm_u,
  FileUtil, FMS_record, telnetaddresrecord_u, LazSysUtils, SQLite3DS,
  exportFields_record, qsosu, fphttpclient, fpjson;

type
  bandArray = array of string;
  modeArray = array of string;
  subModeArray = array of string;
  CallsignArray = array of string;
  StringArray = array of string;
  extProgramArray = array of string;
  PropArray = array of string;
  SATArray = array of string;

  { TMainFunc }

  TMainFunc = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    SearchPrefixQuery: TSQLQuery;
    function GetDPIScaleFactor(Form: TForm): Double;
  public
    procedure SaveWindowPosition(nameForm: TForm);
    procedure LoadWindowPosition(nameForm: TForm);
    procedure LoadTelnetAddress;
    procedure SentCATCloudLog(CatData: TCatData);
    procedure SaveGrids(DbGrid: TDBGrid);
    procedure SetDXColumns(VST: TVirtualStringTree; Save: boolean;
      var VirtualST: TVirtualStringTree);
    procedure SaveQSO(var SQSO: TQSO);
    procedure SetGrid(var DBGRID: TDBGrid);
    procedure GetDistAzim(Latitude, Longitude: string; var Distance, Azimuth: string);
    procedure CheckDXCC(Callsign, mode, band: string; var DMode, DBand, DCall: boolean);
    procedure LoadINIsettings;
    procedure LoadExportAdiSettings;
    procedure ClearPFXR(var PFXR: TPFXR);
    procedure LoadBMSL(var CBMode, CBSubMode, CBBand, CBJournal: TComboBox);
    procedure LoadBMSL(var CBMode, CBSubMode, CBBand: TComboBox); overload;
    procedure LoadBMSL(var CBMode, CBSubMode: TComboBox); overload;
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
    procedure CopyToJournal(DBGrid: TDBGrid; toDescription: string);
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
    function FindInCallBook(Callsign: string): TFoundQSOR;
    function CheckQSL(Callsign, band, mode: string): integer;
    function GetExternalProgramsName: extProgramArray;
    function GetExternalProgramsPath(ProgramName: string): string;
    function BackupDataADI(Sender: string): boolean;
    function BackupDataDB(Sender: string): boolean;
    function GenerateRandomID: string;
    function FormatFreq(Value: string): string;
    function ConvertFreqToSave(Freq: string): string;
    function ConvertFreqToShow(Freq: string): string;
    function ConvertFreqToSelectView(Freq: string): string;
    procedure LoadRadioItems;
    function CompareVersion(Local, Server: string): boolean;
    function LoadPropItems: PropArray;
    function LoadSATItems: SATArray;
    function GetPropDescription(i: integer): string;
    function GetSatDescription(SATname: string): string;
    procedure StartRadio(RIGid: string);
    procedure StopRadio;
    procedure UpdateQSL(Field, Value: string; UQSO: TQSO);
    procedure TruncateTable(TableName: string);
    procedure VacuumDB;
    procedure DeleteQSOsu(hash: string);
  end;

var
  MainFunc: TMainFunc;
  IniSet: TINIR;
  exportAdiSet: TexportRecord;
  columnsGrid: array[0..29] of string;
  columnsWidth: array[0..29] of integer;
  columnsVisible: array[0..29] of boolean;
  columnsDX: array[0..8] of string;
  columnsDXWidth: array[0..8] of integer;
  FMS: TFMSRecord;
  TARecord: array[0..8] of TTelnetAddressRecord;

implementation

uses InitDB_dm, dmFunc_U, GridsForm_u, hrdlog,
  hamqth, clublog, qrzcom, eqsl, cloudlog, miniform_u, dxclusterform_u, dmHamLib_u,
  dmTCI_u;

{$R *.lfm}

function TMainFunc.GetPropDescription(i: integer): string;
var
  Query: TSQLQuery;
begin
  Result := '';
  try
    Query := TSQLQuery.Create(nil);
    Query.DataBase := InitDB.ServiceDBConnection;
    Query.SQL.Text := 'SELECT Description FROM PropMode WHERE _id = ' + IntToStr(i);
    Query.Open;
    Result := Query.FieldByName('Description').AsString;
    Query.Close;
  finally
    FreeAndNil(Query);
  end;
end;

function TMainFunc.GetSatDescription(SATname: string): string;
var
  Query: TSQLQuery;
begin
  Result := '';
  try
    Query := TSQLQuery.Create(nil);
    Query.DataBase := InitDB.ServiceDBConnection;
    Query.SQL.Text := 'SELECT Description FROM Satellite WHERE Name = ' +
      QuotedStr(SATname);
    Query.Open;
    Result := Query.FieldByName('Description').AsString;
    Query.Close;
  finally
    FreeAndNil(Query);
  end;
end;

function TMainFunc.LoadPropItems: PropArray;
var
  i: integer;
  Query: TSQLQuery;
  PropList: PropArray;
begin
  try
    Query := TSQLQuery.Create(nil);
    Query.DataBase := InitDB.ServiceDBConnection;
    Query.PacketRecords := 50;
    Query.SQL.Text := 'SELECT Type FROM PropMode';
    Query.Open;
    if Query.RecordCount = 0 then
      Exit;
    SetLength(PropList, Query.RecordCount);
    Query.First;
    for i := 0 to Query.RecordCount - 1 do
    begin
      PropList[i] := Query.FieldByName('Type').AsString;
      Query.Next;
    end;
    Query.Close;
    Result := PropList;
  finally
    FreeAndNil(Query);
  end;
end;

function TMainFunc.LoadSATItems: SATArray;
var
  i: integer;
  Query: TSQLQuery;
  SATList: SATArray;
begin
  try
    Query := TSQLQuery.Create(nil);
    Query.DataBase := InitDB.ServiceDBConnection;
    Query.PacketRecords := 100;
    Query.SQL.Text := 'SELECT Name FROM Satellite WHERE enable = 1';
    Query.Open;
    if Query.RecordCount = 0 then
      Exit;
    SetLength(SATList, Query.RecordCount);
    Query.First;
    for i := 0 to Query.RecordCount - 1 do
    begin
      SATList[i] := Query.FieldByName('Name').AsString;
      Query.Next;
    end;
    Query.Close;
    Result := SATList;
  finally
    FreeAndNil(Query);
  end;
end;

procedure TMainFunc.StopRadio;
begin
  dmHamLib.FreeRadio;
  dmTCI.StopTCI;
end;

procedure TMainFunc.StartRadio(RIGid: string);
var
  id: integer;
begin
  StopRadio;
  if Pos('TRX', RIGid) > 0 then
  begin
    id := StrToInt(RIGid[4]);
    IniSet.RIGConnected := dmHamLib.InicializeHLRig(id);
    Exit;
  end;
  if Pos('TCI', RIGid) > 0 then
  begin
    id := StrToInt(RIGid[4]);
    IniSet.RIGConnected := dmTCI.InicializeTCI(id);
    Exit;
  end;
end;

function TMainFunc.CompareVersion(Local, Server: string): boolean;
var
  LocalVersion, ServerVersion: integer;
begin
  Result := False;
  if (TryStrToInt(StringReplace(Local, '.', '', [rfReplaceAll]), LocalVersion)) and
    (TryStrToInt(StringReplace(Server, '.', '', [rfReplaceAll]), ServerVersion)) then
  begin
    if LocalVersion < ServerVersion then
      Result := True;
  end;
end;

procedure TMainFunc.LoadRadioItems;
var
  i: integer;
begin
  RadioList.Clear;
  for i := 1 to 4 do
  begin
    if INIFile.ReadString('TRX' + IntToStr(i), 'name', '') <> '' then
      RadioList.AddPair(INIFile.ReadString('TRX' + IntToStr(i), 'name', ''),
        'TRX' + IntToStr(i));
    if INIFile.ReadString('TCI' + IntToStr(i), 'name', '') <> '' then
      RadioList.AddPair(INIFile.ReadString('TCI' + IntToStr(i), 'name', ''),
        'TCI' + IntToStr(i));
  end;
  RadioList.Sort;
  RadioList.Sorted := True;
end;

function TMainFunc.ConvertFreqToSave(Freq: string): string;
var
  tempFreq: double;
  tempFreqStr: string;
  dotcount, i: integer;
begin
  dotcount := 0;
  if Pos('M', Freq) > 0 then
  begin
    tempFreqStr := FormatFloat('0.000"."00', dmFunc.GetFreqFromBand(Freq, 'MHZ'));
    Result := StringReplace(tempFreqStr, ',', '.', [rfReplaceAll]);
  end
  else
  begin
    Freq := StringReplace(Freq, ',', '.', [rfReplaceAll]);
    for i := 1 to length(Freq) do
      if Freq[i] = '.' then
        Inc(dotcount);
    if dotcount > 1 then
      Delete(Freq, length(Freq) - 2, 1);
    TryStrToFloatSafe(Freq, tempFreq);
    tempFreqStr := FormatFloat('0.000"."00', tempFreq);
    Result := StringReplace(tempFreqStr, ',', '.', [rfReplaceAll]);
  end;
end;

function TMainFunc.ConvertFreqToShow(Freq: string): string;
begin
  if Pos('M', Freq) > 0 then
    Result := FormatFloat(view_freq[IniSet.ViewFreq], dmFunc.GetFreqFromBand(
      Freq, 'MHZ'))
  else
    Result := Freq;
  Result := StringReplace(Result, ',', '.', [rfReplaceAll]);
end;

function TMainFunc.ConvertFreqToSelectView(Freq: string): string;
var
  tmpFreq: double;
begin
  if Freq = '' then
    exit;
  Result := 'err';
  Delete(Freq, length(Freq) - 2, 1);
  if TryStrToFloatSafe(Freq, tmpFreq) then
    Result := StringReplace(FormatFloat(view_freq[IniSet.ViewFreq], tmpFreq),
      ',', '.', [rfReplaceAll]);
end;

function TMainFunc.FormatFreq(Value: string): string;
var
  tmpFreq: string;
begin
  Result := '0';
  if Value <> '' then
  begin
    tmpFreq := ConvertFreqToSave(Value);
    Delete(tmpFreq, length(tmpFreq) - 2, 1);
    Result := tmpFreq;
  end;
end;

procedure TMainFunc.SaveWindowPosition(nameForm: TForm);
begin
  if nameForm.WindowState <> wsMaximized then
  begin
    INIFile.WriteInteger(nameForm.Name, 'Left', nameForm.Left);
    INIFile.WriteInteger(nameForm.Name, 'Top', nameForm.Top);
    INIFile.WriteInteger(nameForm.Name, 'Width', nameForm.Width);
    INIFile.WriteInteger(nameForm.Name, 'Height', nameForm.Height);
    INIFile.WriteBool(nameForm.Name, 'Maximized', False);
  end
  else
    INIFile.WriteBool(nameForm.Name, 'Maximized', True);
end;

procedure TMainFunc.LoadWindowPosition(nameForm: TForm);
var
  Left, Top, Width, Height: integer;
  Maximized: boolean;
begin
  Left := INIFile.ReadInteger(nameForm.Name, 'Left', nameForm.Left);
  Top := INIFile.ReadInteger(nameForm.Name, 'Top', nameForm.Top);
  Width := INIFile.ReadInteger(nameForm.Name, 'Width', nameForm.Width);
  Height := INIFile.ReadInteger(nameForm.Name, 'Height', nameForm.Height);
  Maximized := INIFile.ReadBool(nameForm.Name, 'Maximized', False);
  if not Maximized then
    nameForm.SetBounds(Left, Top, Width, Height)
  else
    nameForm.WindowState := wsMaximized;
end;

procedure TMainFunc.LoadTelnetAddress;
var
  SLAddress: TStringList;
  i: integer;
  addressString: string;
begin
  try
    Finalize(TARecord);
    SLAddress := TStringList.Create;
    for i := 0 to 9 do
    begin
      addressString := INIFile.ReadString('TelnetCluster', 'Server' + IntToStr(i), '');
      if (addressString <> '') and (pos('->', addressString) < 1) then
        SLAddress.Add(INIFile.ReadString('TelnetCluster', 'Server' + IntToStr(i), ''));
    end;
    if SLAddress.Count = 0 then
      SLAddress.Add('FEERC,dx.feerc.ru,8000');

    for i := 0 to SLAddress.Count - 1 do
    begin
      addressString := SLAddress[i];
      TARecord[i].Name := copy(addressString, 1, pos(',', addressString) - 1);
      Delete(addressString, 1, pos(',', addressString));
      TARecord[i].Address := copy(addressString, 1, pos(',', addressString) - 1);
      Delete(addressString, 1, pos(',', addressString));
      TARecord[i].Port := StrToIntDef(addressString, 8000);
    end;

  finally
    FreeAndNil(SLAddress);
    DXClusterForm.LoadClusterString;
  end;
end;

function TMainFunc.GenerateRandomID: string;
var
  a: integer;
  b: integer;
  s: integer;
begin
  Randomize;
  Result := '';
  for s := 1 to 5 do
  begin
    for a := 1 to 5 do
      Result := Result + Chr(65 + Random(25));
    for b := 1 to 3 do
      Result := Result + Chr(48 + Random(10));
    Result := Result;
  end;
end;

function TMainFunc.BackupDataADI(Sender: string): boolean;
begin
  Result := True;
  if IniSet.BackupADIonClose then
  begin
    ProgressBackupForm.SenderForm := Sender;
    ProgressBackupForm.Show;
  end
  else
    Result := False;
end;

function TMainFunc.BackupDataDB(Sender: string): boolean;
begin
  if IniSet.BackupDBonClose then
  begin
    Result := CopyFile(DBRecord.SQLitePATH, SysToUTF8(IniSet.PathBackupFiles +
      DirectorySeparator + 'auto_backup_' + dmFunc.ExtractCallsign(
      DBRecord.CurrentCall) + '_' + FormatDateTime('yyyy-mm-dd-hhnnss', now) + '.db'));
  end
  else
    Result := False;
end;

procedure TMainFunc.SentCATCloudLog(CatData: TCatData);
begin
  CatData.freq := FormatFreq(CatData.freq);
  CatData.freq := StringReplace(CatData.freq, '.', '', [rfReplaceAll]);
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

function TMainFunc.GetDPIScaleFactor(Form: TForm): Double;
begin
  if Form.Monitor <> nil then
    Result := Form.Monitor.PixelsPerInch / 96.0
  else
    Result := Screen.PixelsPerInch / 96.0;
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
    FreeAndNil(VSTSaveStream);
  end;
end;

//procedure TMainFunc.SetDXColumns(VST: TVirtualStringTree; Save: boolean;
//  var VirtualST: TVirtualStringTree);
//var
//  HeaderHeight: Integer;
//  HeaderWidth: Integer;
//  ScaleFactor: Double;
//  VSTSaveStream: TFileStream;
//  VSTLoadStream: TFileStream;
//  i: integer;
//begin
//  VSTSaveStream := nil;
//  VSTLoadStream := nil;
//  try
//    ScaleFactor := GetDPIScaleFactor(dxClusterForm);
//
//    if Save then
//    begin
//      HeaderHeight := Round(VST.Header.Height / ScaleFactor);
//      VSTSaveStream := TFileStream.Create(FilePATH + 'Header.vst', fmOpenReadWrite or fmCreate);
//      VSTSaveStream.Write(HeaderHeight, SizeOf(Integer));
//      for i:=0 to VST.Header.Columns.Count - 1 do begin
//          HeaderWidth := Round(VST.Header.Columns[i].Width / ScaleFactor);
//          VSTSaveStream.Write(HeaderWidth, SizeOf(Integer));
//      end;
//    end
//   else
//    if FileExistsUTF8(FilePATH + 'Header.vst') then
//    begin
//      VSTLoadStream := TFileStream.Create(FilePATH + 'Header.vst', fmOpenRead);
//      VSTLoadStream.Read(HeaderHeight, SizeOf(Integer));
//      VST.Header.Height := Round(HeaderHeight * ScaleFactor);
//
//      for i:=0 to VST.Header.Columns.Count - 1 do begin
//        VSTLoadStream.Read(HeaderWidth, SizeOf(Integer));
//        VST.Header.Columns[i].Width := Round(HeaderWidth * ScaleFactor);
//      end;
//    end;
//  finally
//    FreeAndNil(VSTSaveStream);
//    FreeAndNil(VSTLoadStream);
//  end;
//end;


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

procedure TMainFunc.CopyToJournal(DBGrid: TDBGrid; toDescription: string);
var
  Query: TSQLQuery;
  toTable: string;
  i, RecIndex: integer;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Text := 'SELECT LogTable FROM LogBookInfo WHERE Description = "' +
        toDescription + '"';
      Query.Open;
      toTable := Query.Fields[0].AsString;
      Query.Close;
      for i := 0 to DBGrid.SelectedRows.Count - 1 do
      begin
        DBGrid.DataSource.DataSet.GotoBookmark(Pointer(DBGrid.SelectedRows.Items[i]));
        RecIndex := DBGrid.DataSource.DataSet.FieldByName('UnUsedIndex').AsInteger;
        Query.SQL.Text := 'INSERT INTO ' + toTable + ' (' +
          CopyFieldJournalToJournal + ')' + ' SELECT ' +
          CopyFieldJournalToJournal + ' FROM ' + LBRecord.LogTable +
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
    SendCloudLogThread.CloudLogStationId := IniSet.CloudLogStationId;
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
  //Отправка в QSO.su
  if via = 'qsosu' then
  begin
    SendQsoSuThread := TSendQSOsuLogThread.Create;
    if Assigned(SendQsoSuThread.FatalException) then
       raise SendQsoSuThread.FatalException;
    SendQsoSuThread.SendQSO := SendQSO;
    SendQsoSuThread.callsign := LBRecord.CallSign;
    SendQsoSuThread.token := LBRecord.QSOSuToken;
    SendQsoSuThread.Start;
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
  Fmt: TFormatSettings;
begin
  try
    try
      Query := TSQLQuery.Create(nil);

      fmt.ShortDateFormat := 'yyyy-mm-dd';
      fmt.DateSeparator := '-';
      fmt.LongTimeFormat := 'hh:nn';
      fmt.TimeSeparator := ':';
      Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Text :=
        'SELECT datetime(QSODateTime, ''unixepoch'') AS QSODateTime FROM ' +
        LBRecord.LogTable + ' WHERE UnUsedIndex = ' + IntToStr(index);
      Query.Open;
      Result.QSODateTime :=
        StrToDateTime(Query.FieldByName('QSODateTime').AsString, Fmt);
      Query.Close;

      Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
        ' WHERE UnUsedIndex = ' + IntToStr(index);
      Query.Open;

      Result.CallSing := Query.FieldByName('CallSign').AsString;
      Result.QSODate := Query.FieldByName('QSODate').AsDateTime;
      Result.QSOTime := Query.FieldByName('QSOTime').AsString;
      Result.OMName := Query.FieldByName('OMName').AsString;
      Result.OMQTH := Query.FieldByName('OMQTH').AsString;
      Result.State0 := Query.FieldByName('State').AsString;
      Result.STX := Query.FieldByName('STX').AsInteger;
      Result.SRX := Query.FieldByName('SRX').AsInteger;
      Result.STX_String := Query.FieldByName('STX_String').AsString;
      Result.SRX_String := Query.FieldByName('SRX_String').AsString;
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
      Result.QSOBand := ConvertFreqToSelectView(Query.FieldByName('QSOBand').AsString);
      Result.DigiBand := Query.FieldByName('DigiBand').AsString;
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
      Result.SAT_NAME := Query.FieldByName('SAT_NAME').AsString;
      Result.SAT_MODE := Query.FieldByName('SAT_MODE').AsString;
      Result.PROP_MODE := Query.FieldByName('PROP_MODE').AsString;
      Result.ShortNote := Query.FieldByName('ShortNote').AsString;
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
  QSODateTime: string;
  SRXs, STXs: string;
  FormatSettings: TFormatSettings;
begin
  try
    FormatSettings.DateSeparator := '.';
    FormatSettings.ShortDateFormat := 'dd.mm.yyyy';

    try
      QSODates := StringReplace(FloatToStr(DateTimeToJulianDate(SQSO.QSODate)),
        ',', '.', [rfReplaceAll]);
      if SQSO.QSLSentDate = StrToDate('30.12.1899', FormatSettings) then
        QSLSentDates := 'NULL'
      else
        QSLSentDates := StringReplace(FloatToStr(DateTimeToJulianDate(SQSO.QSLSentDate)),
        ',', '.', [rfReplaceAll]);
      if SQSO.QSLRecDate = StrToDate('30.12.1899', FormatSettings) then
        QSLRecDates := 'NULL'
      else
        QSLRecDates := StringReplace(FloatToStr(DateTimeToJulianDate(SQSO.QSLRecDate)),
        ',', '.', [rfReplaceAll]);
      if SQSO.LotWRecDate = StrToDate('30.12.1899', FormatSettings) then
        LotWRecDates := 'NULL'
      else
        LotWRecDates := StringReplace(FloatToStr(DateTimeToJulianDate(SQSO.LotWRecDate)),
        ',', '.', [rfReplaceAll]);

      QSODateTime := IntToStr(DateTimeToUnix(SQSO.QSODateTime));

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
        dmFunc.Q(SQSO.CallSing) + 'QSODateTime = ' + dmFunc.Q(QSODateTime) +
        'QSODate = ' + dmFunc.Q(QSODates) +
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
  Field: TField;
begin
  Field := DS.FindField('QSL');
  if not Assigned(Field) then Exit;

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
      DBGrid.Canvas.TextOut(Rect.Left + 3, Rect.Top + 1,
        dmFunc.GetBandFromFreq(DS.FieldByName('QSOBand').AsString));
    end;
  end;
  if (IniSet.ViewFreq > 0) and not IniSet.showBand then
  begin
    if (Column.FieldName = 'QSOBand') then
    begin
      DBGrid.Canvas.FillRect(Rect);
      DBGrid.Canvas.TextOut(Rect.Left + 3, Rect.Top + 1,
        ConvertFreqToSelectView(DS.FieldByName('QSOBand').AsString));
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
        InitDB.DefLogBookQuery.SQL.Text :=
          'SELECT `UnUsedIndex`, `CallSign`,' +
          ' strftime(''%d.%m.%Y'',QSODate) as QSODate,`QSOTime`,`QSOBand`,`QSOMode`,`QSOSubMode`,'
          +
          '(COALESCE(`QSOReportSent`, '''') || '' '' || COALESCE(`STX`, '''') || '' '' || COALESCE(`STX_STRING`, '''')) AS QSOReportSent,'
          +
          '(COALESCE(`QSOReportRecived`, '''') || '' '' || COALESCE(`SRX`, '''') || '' '' || COALESCE(`SRX_STRING`, '''')) AS QSOReportRecived,'
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
  DS: TDataSet;
  CurrentID, NextID: Integer;
  QSOsu_HASH: string;
begin
  if DBRecord.InitDB = 'YES' then
  begin
    DS := DBGrid.DataSource.DataSet;
    if DS.IsEmpty then Exit;

    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;
      CurrentID := DS.FieldByName('UnUsedIndex').AsInteger;

      Query.SQL.Clear;
      Query.SQL.Text := 'SELECT QSOSU_HASH FROM ' + LBRecord.LogTable + ' WHERE UnUsedIndex = ' + intToStr(CurrentID);
      Query.Open;
      QSOsu_HASH := Query.FieldByName('QSOSU_HASH').AsString;

      if (QSOsu_HASH <> '') and (LBRecord.AutoQSOsu) then DeleteQSOsu(QSOsu_HASH);

      DS.Next;
      if not DS.EOF then
        NextID := DS.FieldByName('UnUsedIndex').AsInteger
      else
        NextID := -1;
      DS.Prior;
      for i := 0 to DBGrid.SelectedRows.Count - 1 do
      begin
        DS.GotoBookmark(Pointer(DBGrid.SelectedRows.Items[i]));
        RecIndex := DS.FieldByName('UnUsedIndex').AsInteger;
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

      if NextID <> -1 then
      begin
        if not DS.Locate('UnUsedIndex', NextID, []) then
          DS.Last;
      end
      else
      begin
        DS.Last;
      end;

    finally
      FreeAndNil(Query);
    end;
  end;
end;

procedure TMainFunc.DeleteQSOsu(hash: string);
var
  QSOData: TJSONObject;
  HTTP: TFPHttpClient;
  RequestBody: TStringStream;
begin
  QSOData := TJSONObject.Create;
  QSOData.Add('hash', hash);
  HTTP := TFPHttpClient.Create(nil);
  RequestBody := TStringStream.Create(QSOData.AsJSON, TEncoding.UTF8);
  try
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('Authorization', 'Bearer ' + LBRecord.QSOSuToken);
    HTTP.AddHeader('Content-Type', 'application/json');
    HTTP.RequestBody := RequestBody;
    HTTP.Delete('https://api.qso.su/method/v1/deleteByHashLog');
  finally
  end;
end;

procedure TMainFunc.UpdateQSL(Field, Value: string; UQSO: TQSO);
var
  Query: TSQLQuery;
  SQLString: string;
  QSODateTime: string;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.SQLiteConnection;
      QSODateTime := FloatToStr(DateTimeToJulianDate(NowUTC));

      QSODateTime := StringReplace(QSODateTime, ',', '.', [rfReplaceAll]);

      SQLString := 'UPDATE ' + LBRecord.LogTable + ' SET ' + Field +
        ' = ' + QuotedStr(Value);

      case Field of
        'HRDLOG_QSO_UPLOAD_STATUS': SQLString :=
            SQLString + ', HRDLOG_QSO_UPLOAD_DATE = ' + QuotedStr(QSODateTime);
        'QRZCOM_QSO_UPLOAD_STATUS': SQLString :=
            SQLString + ', QRZCOM_QSO_UPLOAD_DATE = ' + QuotedStr(QSODateTime);
        'CLUBLOG_QSO_UPLOAD_STATUS': SQLString :=
            SQLString + ', CLUBLOG_QSO_UPLOAD_DATE = ' + QuotedStr(QSODateTime);
        'HAMQTH_QSO_UPLOAD_STATUS': SQLString :=
            SQLString + ', HAMQTH_QSO_UPLOAD_DATE = ' + QuotedStr(QSODateTime);
        'QSOSU_QSO_UPLOAD_STATUS': SQLString :=
            SQLString + ', QSOSU_QSO_UPLOAD_DATE = ' + QuotedStr(QSODateTime);
      end;


      SQLString := SQLString + ' WHERE CallSign = ' + QuotedStr(UQSO.CallSing);
      SQLString := SQLString + ' AND QSODateTime = ' +
        QuotedStr(IntToStr(DateTimeToUnix(UQSO.QSODateTime)));

      SQLString := SQLString + ' AND DigiBand = ' + UQSO.DigiBand +
        ' AND (QSOMode = ' + QuotedStr(UQSO.QSOMode) + ' OR QSOSubMode = ' +
        QuotedStr(UQSO.QSOSubMode) + ')';

      Query.SQL.Text := SQLString;
      Query.ExecSQL;

    finally
      InitDB.DefTransaction.Commit;
      if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
        ShowMessage(rDBError);
      FreeAndNil(Query);
    end;

  except
    on E: Exception do
      WriteLn(ExceptFile, 'UpdateQSL:' + E.ClassName + ':' + E.Message);
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
                (Value = 'Q') or (Value = 'N') or (Field = 'QSLRec') then
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
                  Params.ParamByName('QSLSentDate').AsDate := Date;
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
                  Params.ParamByName('QSLRecDate').AsDate := Date;
                end;
                if (Value = 'N') and (Field = 'QSLSentAdv') then
                begin
                  SQL.Add('UPDATE ' + LBRecord.LogTable + ' SET ' +
                    QuotedStr(Field) + '=:' + Field +
                    ',QSLSent=:QSLSent, QSLSentDate=:QSLSentDate WHERE UnUsedIndex=:UnUsedIndex');
                  Params.ParamByName(Field).AsString := Value;
                  Params.ParamByName('QSLSent').Value := 0;
                  Params.ParamByName('QSLSentDate').IsNull;
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
                  Params.ParamByName('QSLRecDate').AsDate := Date;
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
          if (DBGrid.Name = 'DBGrid1') then
            CurrPosGrid(GridRecordIndex, DBGrid);
          GridsForm.DBGrid1.DataSource.DataSet.Locate('UnUsedIndex', UnUsIndex, []);
          GridsForm.DBGrid1CellClick(nil);
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
      Query.DataBase := InitDB.SQLiteConnection;

      Query.SQL.Text := 'SELECT Description, CallName FROM LogBookInfo';
      Query.Open;
      if Query.RecordCount = 0 then
        Exit;
      SetLength(CallsignList, Query.RecordCount);
      Query.First;
      for i := 0 to Query.RecordCount - 1 do
      begin
        CallsignList[i] := Query.FieldByName('Description').AsString;
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
      InitDB.FindQSOQuery.DataBase := InitDB.SQLiteConnection;
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
        +
        LBRecord.LogTable + ' WHERE `Call` LIKE ' + QuotedStr(Callsign) +
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
              BandList[i] :=
                StringReplace(FormatFloat(view_freq[IniSet.ViewFreq],
                Query.FieldByName('ssb').AsFloat), ',', '.', [rfReplaceAll]);
            if mode = 'CW' then
              BandList[i] :=
                StringReplace(FormatFloat(view_freq[IniSet.ViewFreq],
                Query.FieldByName('cw').AsFloat), ',', '.', [rfReplaceAll]);
            if (mode <> 'CW') and (mode <> 'SSB') then
              BandList[i] :=
                StringReplace(FormatFloat(view_freq[IniSet.ViewFreq],
                Query.FieldByName('b_begin').AsFloat), ',', '.', [rfReplaceAll]);
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

procedure TMainFunc.LoadExportAdiSettings;
begin
  exportAdiSet.fOPERATOR:=INIFile.ReadBool('ExportFieldsADI', 'OPERATOR', True);
  exportAdiSet.fTIME_ON:=INIFile.ReadBool('ExportFieldsADI', 'TIME_ON', True);
  exportAdiSet.fFREQ:=INIFile.ReadBool('ExportFieldsADI', 'FREQ', True);
  exportAdiSet.fNAME:=INIFile.ReadBool('ExportFieldsADI', 'NAME', True);
  exportAdiSet.fPFX:=INIFile.ReadBool('ExportFieldsADI', 'PFX', True);
  exportAdiSet.fCQZ:=INIFile.ReadBool('ExportFieldsADI', 'CQZ', True);
  exportAdiSet.fQSLMSG:=INIFile.ReadBool('ExportFieldsADI', 'QSLMSG', True);
  exportAdiSet.fEQSL_QSL_SENT:=INIFile.ReadBool('ExportFieldsADI', 'EQSL_QSL_SENT', True);
  exportAdiSet.fMY_LON:=INIFile.ReadBool('ExportFieldsADI', 'MY_LON', True);
  exportAdiSet.fHRDLOG_QSO_UPLOAD_DATE:=INIFile.ReadBool('ExportFieldsADI', 'HRDLOG_QSO_UPLOAD_DATE', True);
  exportAdiSet.fHAMQTH_QSO_UPLOAD_STATUS:=INIFile.ReadBool('ExportFieldsADI', 'HAMQTH_QSO_UPLOAD_STATUS', True);
  exportAdiSet.fCALL:=INIFile.ReadBool('ExportFieldsADI', 'CALL', True);
  exportAdiSet.fMODE:=INIFile.ReadBool('ExportFieldsADI', 'MODE', True);
  exportAdiSet.fRST_SENT:=INIFile.ReadBool('ExportFieldsADI', 'RST_SENT', True);
  exportAdiSet.fQTH:=INIFile.ReadBool('ExportFieldsADI', 'QTH', True);
  exportAdiSet.fDXCC_PREF:=INIFile.ReadBool('ExportFieldsADI', 'DXCC_PREF', True);
  exportAdiSet.fITUZ:=INIFile.ReadBool('ExportFieldsADI', 'ITUZ', True);
  exportAdiSet.fLOTW_QSL_SENT:=INIFile.ReadBool('ExportFieldsADI', 'LOTW_QSL_SENT', True);
  exportAdiSet.fMY_GRIDSQUARE:=INIFile.ReadBool('ExportFieldsADI', 'MY_GRIDSQUARE', True);
  exportAdiSet.fCLUBLOG_QSO_UPLOAD_DATE:=INIFile.ReadBool('ExportFieldsADI', 'CLUBLOG_QSO_UPLOAD_DATE', True);
  exportAdiSet.fHRDLOG_QSO_UPLOAD_STATUS:=INIFile.ReadBool('ExportFieldsADI', 'HRDLOG_QSO_UPLOAD_STATUS', True);
  exportAdiSet.fFREQ_RX:=INIFile.ReadBool('ExportFieldsADI', 'FREQ_RX', True);
  exportAdiSet.fQSO_DATE:=INIFile.ReadBool('ExportFieldsADI', 'QSO_DATE', True);
  exportAdiSet.fSUBMODE:=INIFile.ReadBool('ExportFieldsADI', 'SUBMODE', True);
  exportAdiSet.fRST_RCVD:=INIFile.ReadBool('ExportFieldsADI', 'RST_RCVD', True);
  exportAdiSet.fGRIDSQUARE:=INIFile.ReadBool('ExportFieldsADI', 'GRIDSQUARE', True);
  exportAdiSet.fBAND:=INIFile.ReadBool('ExportFieldsADI', 'BAND', True);
  exportAdiSet.fCONT:=INIFile.ReadBool('ExportFieldsADI', 'CONT', True);
  exportAdiSet.fDXCC:=INIFile.ReadBool('ExportFieldsADI', 'DXCC', True);
  exportAdiSet.fMY_LAT:=INIFile.ReadBool('ExportFieldsADI', 'MY_LAT', True);
  exportAdiSet.fCLUBLOG_QSO_UPLOAD_STATUS:=INIFile.ReadBool('ExportFieldsADI', 'CLUBLOG_QSO_UPLOAD_STATUS', True);
  exportAdiSet.fHAMQTH_QSO_UPLOAD_DATE:=INIFile.ReadBool('ExportFieldsADI', 'HAMQTH_QSO_UPLOAD_DATE', True);
  exportAdiSet.fSTATION_CALLSIGN:=INIFile.ReadBool('ExportFieldsADI', 'STATION_CALLSIGN', True);

  exportAdiSet.fSRX:=INIFile.ReadBool('ExportFieldsADI', 'SRX', True);
  exportAdiSet.fSTX:=INIFile.ReadBool('ExportFieldsADI', 'STX', True);
  exportAdiSet.fSRX_STRING:=INIFile.ReadBool('ExportFieldsADI', 'SRX_STRING', True);
  exportAdiSet.fSTX_STRING:=INIFile.ReadBool('ExportFieldsADI', 'STX_STRING', True);
  exportAdiSet.fSTATE:=INIFile.ReadBool('ExportFieldsADI', 'STATE', True);
  exportAdiSet.fWPX:=INIFile.ReadBool('ExportFieldsADI', 'WPX', True);
  exportAdiSet.fBAND_RX:=INIFile.ReadBool('ExportFieldsADI', 'BAND_RX', True);
  exportAdiSet.fPROP_MODE:=INIFile.ReadBool('ExportFieldsADI', 'PROP_MODE', True);
  exportAdiSet.fSAT_MODE:=INIFile.ReadBool('ExportFieldsADI', 'SAT_MODE', True);
  exportAdiSet.fSAT_NAME:=INIFile.ReadBool('ExportFieldsADI', 'SAT_NAME', True);
  exportAdiSet.fEQSL_QSL_RCVD:=INIFile.ReadBool('ExportFieldsADI', 'EQSL_QSL_RCVD', True);
  exportAdiSet.fQSLSDATE:=INIFile.ReadBool('ExportFieldsADI', 'QSLSDATE', True);
  exportAdiSet.fQSLRDATE:=INIFile.ReadBool('ExportFieldsADI', 'QSLRDATE', True);
  exportAdiSet.fQSL_RCVD:=INIFile.ReadBool('ExportFieldsADI', 'QSL_RCVD', True);
  exportAdiSet.fQSL_RCVD_VIA:=INIFile.ReadBool('ExportFieldsADI', 'QSL_RCVD_VIA', True);
  exportAdiSet.fQSL_SENT_VIA:=INIFile.ReadBool('ExportFieldsADI', 'QSL_SENT_VIA', True);
  exportAdiSet.fQSL_SENT:=INIFile.ReadBool('ExportFieldsADI', 'QSL_SENT', True);
  exportAdiSet.fLOTW_QSL_RCVD:=INIFile.ReadBool('ExportFieldsADI', 'LOTW_QSL_RCVD', True);
  exportAdiSet.fLOTW_QSLRDATE:=INIFile.ReadBool('ExportFieldsADI', 'LOTW_QSLRDATE', True);
  exportAdiSet.fCOMMENT:=INIFile.ReadBool('ExportFieldsADI', 'COMMENT', True);
  exportAdiSet.fMY_STATE:=INIFile.ReadBool('ExportFieldsADI', 'STATIOMY_STATEN_CALLSIGN', True);
  exportAdiSet.fSOTA_REF:=INIFile.ReadBool('ExportFieldsADI', 'SOTA_REF', True);
  exportAdiSet.fMY_SOTA_REF:=INIFile.ReadBool('ExportFieldsADI', 'MY_SOTA_REF', True);
  exportAdiSet.fHAMLOG_QSL_RCVD:=INIFile.ReadBool('ExportFieldsADI', 'HAMLOG_QSL_RCVD', True);
  exportAdiSet.fQRZCOM_QSO_UPLOAD_DATE:=INIFile.ReadBool('ExportFieldsADI', 'QRZCOM_QSO_UPLOAD_DATE', True);
  exportAdiSet.fQRZCOM_QSO_UPLOAD_STATUS:=INIFile.ReadBool('ExportFieldsADI', 'QRZCOM_QSO_UPLOAD_STATUS', True);
  exportAdiSet.fHAMLOGEU_QSO_UPLOAD_DATE:=INIFile.ReadBool('ExportFieldsADI', 'HAMLOGEU_QSO_UPLOAD_DATE', True);
  exportAdiSet.fHAMLOGEU_QSO_UPLOAD_STATUS:=INIFile.ReadBool('ExportFieldsADI', 'HAMLOGEU_QSO_UPLOAD_STATUS', True);
  exportAdiSet.fHAMLOGRU_QSO_UPLOAD_DATE:=INIFile.ReadBool('ExportFieldsADI', 'HAMLOGRU_QSO_UPLOAD_DATE', True);
  exportAdiSet.fHAMLOGRU_QSO_UPLOAD_STATUS:=INIFile.ReadBool('ExportFieldsADI', 'HAMLOGRU_QSO_UPLOAD_STATUS', True);
end;

procedure TMainFunc.LoadINIsettings;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings.TimeSeparator := ':';
  FormatSettings.ShortTimeFormat := 'hh:mm';
  IniSet.UniqueID := GenerateRandomID;
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
  IniSet.CloudLogStationId := INIFile.ReadString('SetLog', 'CloudLogStationId', '');
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
  if IniSet.Cluster_Login = '' then
    IniSet.Cluster_Login := dmFunc.ExtractCallsign(LBRecord.CallSign);
  IniSet.mTop := INIFile.ReadBool('SetLog', 'mTop', False);
  IniSet.gTop := INIFile.ReadBool('SetLog', 'gTop', False);
  IniSet.gShow := INIFile.ReadBool('SetLog', 'gShow', True);
  IniSet.cTop := INIFile.ReadBool('SetLog', 'cTop', False);
  IniSet.cShow := INIFile.ReadBool('SetLog', 'cShow', True);
  IniSet.eTop := INIFile.ReadBool('SetLog', 'eTop', False);
  IniSet.eShow := INIFile.ReadBool('SetLog', 'eShow', True);
  IniSet.pTop := INIFile.ReadBool('SetLog', 'pTop', False);
  IniSet.pShow := INIFile.ReadBool('SetLog', 'pShow', True);
  IniSet.pSeparate := INIFile.ReadBool('SetLog', 'pSeparate', False);
  IniSet.trxTop := INIFile.ReadBool('SetLog', 'trxTop', False);
  IniSet.trxShow := INIFile.ReadBool('SetLog', 'trxShow', False);
  IniSet.ClusterAutoStart := INIFile.ReadBool('TelnetCluster', 'AutoStart', False);
  IniSet.VisibleComment := INIFile.ReadBool('SetLog', 'VisibleComment', True);
  IniSet.PathBackupFiles := INIFile.ReadString('SetBackup', 'PathBackupFiles', '');
  IniSet.BackupDB := INIFile.ReadBool('SetBackup', 'BackupDB', False);
  IniSet.BackupADI := INIFile.ReadBool('SetBackup', 'BackupADI', False);
  IniSet.BackupADIonClose := INIFile.ReadBool('SetBackup', 'BackupADIonClose', False);
  IniSet.BackupDBonClose := INIFile.ReadBool('SetBackup', 'BackupDBonClose', False);
  IniSet.BackupTime := INIFile.ReadTime('SetBackup', 'BackupTime',
    StrToTime('12:00', FormatSettings));
  IniSet.rigctldStartUp := INIFile.ReadBool('SetCAT', 'rigctldStartUp', True);
  IniSet.rigctldExtra := INIFile.ReadString('SetCAT', 'rigctldExtra', '');
  IniSet.rigctldPath := INIFile.ReadString('SetCAT', 'rigctldPath', '');
  IniSet.KeySave := INIFile.ReadString('Key', 'Save', 'Alt+S');
  IniSet.KeyClear := INIFile.ReadString('Key', 'Clear', 'Alt+C');
  IniSet.KeyReference := INIFile.ReadString('Key', 'Reference', 'Enter');
  IniSet.KeyImportADI := INIFile.ReadString('Key', 'ImportADI', 'Alt+I');
  IniSet.KeyExportADI := INIFile.ReadString('Key', 'ExportADI', 'Alt+E');
  IniSet.KeySentSpot := INIFile.ReadString('Key', 'SentSpot', 'Alt+D');
  IniSet.ContestLastNumber := INIFile.ReadInteger('Contest', 'ContestLastNumber', 1);
  IniSet.ContestLastMSG := INIFile.ReadString('Contest', 'ContestLastMSG', '');
  IniSet.ContestName := INIFile.ReadString('Contest', 'ContestName', '');
  IniSet.ContestTourTime := INIFile.ReadInteger('Contest', 'TourTime', 0);
  IniSet.ContestSession := INIFile.ReadString('Contest', 'ContestSession', 'none');
  IniSet.ContestExchangeType := INIFile.ReadString('Contest', 'ExchangeType', 'Serial');
  IniSet.WorkOnLAN := INIFile.ReadBool('WorkOnLAN', 'Enable', False);
  IniSet.WOLAddress := INIFile.ReadString('WorkOnLAN', 'Address', '0.0.0.0');
  IniSet.WOLPort := INIFile.ReadInteger('WorkOnLAN', 'Port', 2238);
  IniSet.CWOverTCI := INIFile.ReadBool('CWGeneral', 'CWOverTCI', False);
  IniSet.CWWPM := INIFile.ReadInteger('CWGeneral', 'WPM', 24);
  IniSet.CWDaemonAddr := INIFile.ReadString('CWDaemon', 'Address', '127.0.0.1');
  IniSet.CWDaemonPort := INIFile.ReadInteger('CWDaemon', 'Port', 6789);
  IniSet.CWDaemonEnable := INIFile.ReadBool('CWDaemon', 'Enable', False);
  IniSet.CWTypeEnable := INIFile.ReadBool('CWType', 'Enable', False);
  IniSet.CWManager := INIFile.ReadString('CWGeneral', 'Manager', '');

  IniSet.InterfaceMobileSync :=
    INIFile.ReadString('SetLog', 'InterfaceMobileSync', '0.0.0.0');
  IniSet.ViewFreq := INIFile.ReadInteger('SetLog', 'ViewFreq', 0);
  if IniSet.ViewFreq > 3 then
    IniSet.ViewFreq := 0;
  IniSet.CurrentRIG := INIFile.ReadString('SetCAT', 'CurrentRIG', 'TRX1');
  IniSet.VHFProp := INIFile.ReadString('VHF', 'VHFProp', '');
  IniSet.TXFreq := INIFile.ReadString('VHF', 'TXFreq', '');
  IniSet.SATName := INIFile.ReadString('VHF', 'SATName', '');
  IniSet.SATMode := INIFile.ReadString('VHF', 'SATMode', '');
  IniSet.LoTW_Path := INIFile.ReadString('LoTW', 'Path', '');
  IniSet.LoTW_QTH := INIFile.ReadString('LoTW', 'QTH', '');
  IniSet.LoTW_Key := INIFile.ReadString('LoTW', 'Key', '');
end;

procedure TMainFunc.CheckDXCC(Callsign, mode, band: string;
  var DMode, DBand, DCall: boolean);
var
  Query: TSQLQuery;
  PFXR: TPFXR;
  DigiBandStr: string;
begin
  try
    if InitRecord.SelectLogbookTable then
    begin
      try
        PFXR := SearchPrefix(Callsign, '');
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
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
        DigiBandStr := FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band)));
        DigiBandStr := StringReplace(DigiBandStr, ',', '.', [rfReplaceAll]);
        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
          DigiBandStr + ' LIMIT 1';
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
  DigiBandStr: string;
begin
  try
    if InitRecord.SelectLogbookTable then
    begin
      try
        PFXR := SearchPrefix(Callsign, '');
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
        Query.DataBase := InitDB.SQLiteConnection;

        DigiBandStr := FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band)));
        DigiBandStr := StringReplace(DigiBandStr, ',', '.', [rfReplaceAll]);
        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
          DigiBandStr + ' AND (QSLRec = 1 OR LoTWRec = 1) LIMIT 1';
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
          DigiBandStr + ' AND (QSLRec = 0 AND LoTWRec = 0) LIMIT 1';
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
  DigiBandStr: string;
begin
  try
    Result := False;
    if InitRecord.SelectLogbookTable then
    begin
      try
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
        Query.DataBase := InitDB.SQLiteConnection;
        DigiBandStr := FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band)));
        DigiBandStr := StringReplace(DigiBandStr, ',', '.', [rfReplaceAll]);
        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE `Call` = ' + QuotedStr(Callsign) + ' AND DigiBand = ' +
          DigiBandStr + ' AND QSOMode = ' + QuotedStr(mode) + ' LIMIT 1';
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
  DigiBandStr: string;
begin
  try
    Result := False;
    if InitRecord.SelectLogbookTable then
    begin
      try
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
        Query.DataBase := InitDB.SQLiteConnection;
        DigiBandStr := FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band)));
        DigiBandStr := StringReplace(DigiBandStr, ',', '.', [rfReplaceAll]);
        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE `Call` = ' + QuotedStr(Callsign) + ' AND DigiBand = ' +
          DigiBandStr + ' AND (LoTWRec = 1 OR QSLRec = 1) LIMIT 1';
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
  DigiBandStr: string;
begin
  try
    Result := False;
    if InitRecord.SelectLogbookTable then
    begin
      try
        PFXR := SearchPrefix(Callsign, '');
        Query := TSQLQuery.Create(nil);
        Query.Transaction := InitDB.DefTransaction;
        Query.DataBase := InitDB.SQLiteConnection;
        DigiBandStr := FloatToStr(dmFunc.GetDigiBandFromFreq(FormatFreq(band)));
        DigiBandStr := StringReplace(DigiBandStr, ',', '.', [rfReplaceAll]);
        Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
          ' WHERE DXCC = ' + IntToStr(PFXR.DXCCNum) + ' AND DigiBand = ' +
          DigiBandStr + ' AND (LoTWRec = 1 OR QSLRec = 1) LIMIT 1';
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
          Result.Latitude := StringReplace(CurrToStr(La), ',', '.', [rfReplaceAll]);
          Result.Longitude := StringReplace(CurrToStr(Lo), ',', '.', [rfReplaceAll]);
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
            Result.Latitude := StringReplace(CurrToStr(La), ',', '.', [rfReplaceAll]);
            Result.Longitude := StringReplace(CurrToStr(Lo), ',', '.', [rfReplaceAll]);
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
            Result.Latitude := StringReplace(CurrToStr(La), ',', '.', [rfReplaceAll]);
            Result.Longitude := StringReplace(CurrToStr(Lo), ',', '.', [rfReplaceAll]);
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
        ':' + IntToStr(i) + ':' + PrefixExpProvinceArray[i].reg.Expression);
    end;
  end;
end;

procedure TMainFunc.GetDistAzim(Latitude, Longitude: string;
  var Distance, Azimuth: string);
var
  azim, qra: string;
  Lat, Lon: double;
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
  TryStrToFloatSafe(Latitude, Lat);
  TryStrToFloatSafe(Longitude, Lon);
  dmFunc.DistanceFromCoordinate(LBRecord.OpLoc, Lat, lon, qra, azim);
  Azimuth := azim;
  Distance := qra + ' KM';
end;

procedure TMainFunc.DataModuleCreate(Sender: TObject);
begin
  SearchPrefixQuery := TSQLQuery.Create(nil);
  SearchPrefixQuery.DataBase := InitDB.ServiceDBConnection;
  RadioList := TStringList.Create;
  LoadRadioItems;
end;

procedure TMainFunc.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(RadioList);
  FreeAndNil(SearchPrefixQuery);
end;

procedure TMainFunc.SaveQSO(var SQSO: TQSO);
var
  QueryTXT: string;
  SRXs, STXs, QSODates: string;
  QSODateTime: string;
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

      SQSO.My_Lat := StringReplace(SQSO.My_Lat, ',', '.', [rfReplaceAll]);
      SQSO.My_Lon := StringReplace(SQSO.My_Lon, ',', '.', [rfReplaceAll]);

      QSODates := StringReplace(FloatToStr(DateTimeToJulianDate(SQSO.QSODate)),
        ',', '.', [rfReplaceAll]);
      QSODateTime := IntToStr(DateTimeToUnix(SQSO.QSODateTime));

      QueryTXT := 'INSERT INTO ' + LBRecord.LogTable + ' (' +
        'CallSign, QSODateTime, QSODate, QSOTime, QSOBand, FREQ_RX, BAND_RX, QSOMode, QSOSubMode,'
        + 'QSOReportSent, QSOReportRecived, OMName, OMQTH, State, Grid, IOTA, ' +
        'QSLManager, QSLSent, QSLSentAdv, QSLRec,' +
        'MainPrefix, DXCCPrefix, CQZone, ITUZone, QSOAddInfo, Marker, ManualSet,' +
        'DigiBand, Continent, ShortNote, QSLReceQSLcc, LoTWRec,' +
        'QSLInfo, `Call`, State1, State2, State3, State4, WPX, AwardsEx,' +
        'ValidDX, SRX, SRX_STRING, STX, STX_STRING, SAT_NAME, SAT_MODE,' +
        'PROP_MODE, LoTWSent, QSL_RCVD_VIA, QSL_SENT_VIA, DXCC, USERS, NoCalcDXCC,' +
        'MY_STATE, MY_GRIDSQUARE, MY_LAT, MY_LON, SYNC, ContestSession, ContestName) VALUES ('
        + dmFunc.Q(Trim(SQSO.CallSing)) + dmFunc.Q(QSODateTime) +
        dmFunc.Q(QSODates) + dmFunc.Q(SQSO.QSOTime) + dmFunc.Q(SQSO.QSOBand) +
        dmFunc.Q(SQSO.FreqRX) + dmFunc.Q(SQSO.BandRX) +
        dmFunc.Q(SQSO.QSOMode) + dmFunc.Q(SQSO.QSOSubMode) +
        dmFunc.Q(SQSO.QSOReportSent) + dmFunc.Q(SQSO.QSOReportRecived) +
        dmFunc.Q(SQSO.OmName) + dmFunc.Q(SQSO.OmQTH) + dmFunc.Q(SQSO.State0) +
        dmFunc.Q(SQSO.Grid) + dmFunc.Q(SQSO.IOTA) + dmFunc.Q(SQSO.QSLManager) +
        dmFunc.Q(SQSO.QSLSent) + dmFunc.Q(SQSO.QSLSentAdv) +
        dmFunc.Q(SQSO.QSLRec) + dmFunc.Q(SQSO.MainPrefix) +
        dmFunc.Q(SQSO.DXCCPrefix) + dmFunc.Q(SQSO.CQZone) +
        dmFunc.Q(SQSO.ITUZone) + dmFunc.Q(SQSO.QSOAddInfo) +
        dmFunc.Q(SQSO.Marker) + dmFunc.Q(IntToStr(SQSO.ManualSet)) +
        dmFunc.Q(SQSO.DigiBand) + dmFunc.Q(SQSO.Continent) +
        dmFunc.Q(SQSO.ShortNote) + dmFunc.Q(IntToStr(SQSO.QSLReceQSLcc)) +
        dmFunc.Q(SQSO.LotWRec) + dmFunc.Q(SQSO.QSLInfo) +
        dmFunc.Q(Trim(SQSO.Call)) + dmFunc.Q(SQSO.State1) +
        dmFunc.Q(SQSO.State2) + dmFunc.Q(SQSO.State3) + dmFunc.Q(SQSO.State4) +
        dmFunc.Q(SQSO.WPX) + dmFunc.Q(SQSO.AwardsEx) + dmFunc.Q(SQSO.ValidDX) +
        dmFunc.Q(SRXs) + dmFunc.Q(SQSO.SRX_String) + dmFunc.Q(STXs) +
        dmFunc.Q(SQSO.STX_String) + dmFunc.Q(SQSO.SAT_NAME) +
        dmFunc.Q(SQSO.SAT_MODE) + dmFunc.Q(SQSO.PROP_MODE) +
        dmFunc.Q(IntToStr(SQSO.LotWSent)) + dmFunc.Q(SQSO.QSL_RCVD_VIA) +
        dmFunc.Q(SQSO.QSL_SENT_VIA) + dmFunc.Q(SQSO.DXCC) +
        dmFunc.Q(SQSO.USERS) + dmFunc.Q(IntToStr(SQSO.NoCalcDXCC)) +
        dmFunc.Q(SQSO.My_State) + dmFunc.Q(SQSO.My_Grid) + dmFunc.Q(SQSO.My_Lat) +
        dmFunc.Q(SQSO.My_Lon) + dmFunc.Q(IntToStr(SQSO.SYNC)) +
        dmFunc.Q(SQSO.ContestSession) + QuotedStr(SQSO.ContestName) + ')';
      //    WriteLn(ExceptFile, 'SaveQSO:' + QueryTXT);
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
  if InitDB.GetLogBookTable(DBRecord.CurrentLogTable) then
    if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
      ShowMessage(rDBError);
end;

procedure TMainFunc.SetGrid(var DBGRID: TDBGrid);
var
  i: integer;
  QBAND: string;
  ColorTextGrid: integer;
  ColorBackGrid: integer;
  // SizeTextGrid: integer;
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

  ColorTextGrid := INIFile.ReadInteger('GridSettings', 'TextColor', clDefault);
  //SizeTextGrid := INIFile.ReadInteger('GridSettings', 'TextSize', 8);
  ColorBackGrid := INIFile.ReadInteger('GridSettings', 'BackColor', clDefault);

  // DBGRID.Font.Size := SizeTextGrid;
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

  //  case SizeTextGrid of
  //    8: DBGRID.DefaultRowHeight := 15;
  //    10: DBGRID.DefaultRowHeight := DBGRID.Font.Size + 12;
  //    12: DBGRID.DefaultRowHeight := DBGRID.Font.Size + 12;
  //    14: DBGRID.DefaultRowHeight := DBGRID.Font.Size + 12;
  //  end;

  //  for i := 0 to DBGRID.Columns.Count - 1 do
  //   DBGRID.Columns.Items[i].Title.Font.Size := SizeTextGrid;
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
    CBJournal.ItemIndex := CBJournal.Items.IndexOf(DBRecord.CurrentLogTable);
  end;
end;

procedure TMainFunc.LoadBMSL(var CBMode, CBSubMode, CBBand: TComboBox); overload;
var
  i, bandIndex: integer;
begin
  bandIndex := CBBand.ItemIndex;
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
  CBBand.ItemIndex := bandIndex;
end;

procedure TMainFunc.LoadBMSL(var CBMode, CBSubMode: TComboBox); overload;
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
    CBJournal.ItemIndex := CBJournal.Items.IndexOf(DBRecord.CurrentLogTable);
  end;
end;

procedure TMainFunc.TruncateTable(TableName: string);
begin
  InitDB.SQLiteConnection.ExecuteDirect('DELETE FROM ' + TableName);
  InitDB.DefTransaction.Commit;
  VacuumDB;
end;

procedure TMainFunc.VacuumDB;
var
  dsLite: TSqlite3Dataset;
begin
  try
    dsLite := TSqlite3Dataset.Create(nil);
    dsLite.FileName := DBRecord.SQLitePATH;
    dsLite.ExecSQL('VACUUM;');
  finally
    FreeAndNil(dsLite);
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
