(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit MobileSyncThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, const_u, ResourceStr,
  LazUTF8, ImportADIThread, SQLDB, IdTCPServer, IdContext, IdGlobal;

type
  TMobileSynThread = class(TThread)
  protected
    procedure Execute; override;
  private
    PADIImport: TPADIImport;
    BuffToSend: string;
    Stream: TMemoryStream;
    InfoStr: string;
    AdifMobileString: TStringList;
    AdifDataSyncAll: boolean;
    AdifDataSyncDate: boolean;
    AdifFromMobileSyncStart: boolean;
    ImportAdifMobile: boolean;
    AdifDataDate: string;
    function GetNewChunk: string;
    procedure ExportToMobile(range: string; date: string);
    procedure OnExecute(AContext: TIdContext);
    procedure OnDisconnect(AContext: TIdContext);
    procedure OnConnect(AContext: TIdContext);
    procedure StartImport;

  public
    lastTCPport: integer;
    constructor Create;
    destructor Destroy; override;
    procedure ToForm;
  end;

var
  MobileSynThread: TMobileSynThread;
  SyncTCP: TIdTCPServer;

implementation

uses InitDB_dm, dmFunc_U, miniform_u, MainFuncDM;

function TMobileSynThread.GetNewChunk: string;
var
  res: string;
  i: integer;
begin
  res := '';
  for i := 0 to AdifMobileString.Count - 1 do
  begin
    res := res + AdifMobileString[0];
    AdifMobileString.Delete(0);
  end;
  res := res + 'DataSyncSuccess:' + LBRecord.CallSign + #13;
  Result := res;
  AdifMobileString.Free;
end;

procedure TMobileSynThread.OnConnect(AContext: TIdContext);
begin
  InfoStr := rClientConnected + AContext.Connection.Socket.Binding.PeerIP;
  Synchronize(@ToForm);
end;

procedure TMobileSynThread.OnDisconnect(AContext: TIdContext);
begin
  InfoStr := AContext.Connection.Socket.Binding.PeerIP + ':' + rDone;
  Synchronize(@ToForm);
end;

procedure TMobileSynThread.OnExecute(AContext: TIdContext);
var
  MessageFromTCP, rec_call, s: string;
  AdifFile: TextFile;
begin
  MessageFromTCP := AContext.Connection.Socket.ReadLn(
    IndyTextEncoding_UTF8, IndyTextEncoding_UTF8);

  AdifDataSyncAll := False;
  AdifDataSyncDate := False;

  if Length(MessageFromTCP) > 0 then
  begin
    if Pos('DataSyncAll', MessageFromTCP) > 0 then
    begin
      rec_call := dmFunc.par_str(MessageFromTCP, 2);
      if Pos(LBRecord.CallSign, rec_call) > 0 then
      begin
        AdifMobileString := TStringList.Create;
        ExportToMobile('All', '');
        AdifDataSyncAll := True;
        BuffToSend := GetNewChunk;
        AContext.Connection.Socket.Write(BuffToSend, IndyTextEncoding_UTF8,
          IndyTextEncoding_UTF8);
      end;
    end;

    if Pos('DataSyncDate', MessageFromTCP) > 0 then
    begin
      AdifDataDate := dmFunc.par_str(MessageFromTCP, 2);
      rec_call := dmFunc.par_str(MessageFromTCP, 3);
      if Pos(LBRecord.CallSign, rec_call + #13) > 0 then
      begin
        AdifMobileString := TStringList.Create;
        ExportToMobile('Date', AdifDataDate);
        AdifDataSyncDate := True;
        BuffToSend := GetNewChunk;
        AContext.Connection.Socket.Write(BuffToSend, IndyTextEncoding_UTF8,
          IndyTextEncoding_UTF8);
      end;
    end;

    if Pos('DataSyncClientStart', MessageFromTCP) > 0 then
    begin
      rec_call := dmFunc.par_str(MessageFromTCP, 2);
      try
        PADIImport.AllRec := StrToInt(dmFunc.par_str(MessageFromTCP, 3));
      except
        PADIImport.AllRec := 0;
      end;
      if Pos(LBRecord.CallSign, rec_call) > 0 then
      begin
        Stream := TMemoryStream.Create;
        AdifFromMobileSyncStart := True;
      end;
    end;

    if (AdifFromMobileSyncStart = True) then
    begin
      MessageFromTCP := StringReplace(MessageFromTCP, #10, '', [rfReplaceAll]);
      MessageFromTCP := StringReplace(MessageFromTCP, #13, '', [rfReplaceAll]);
      if Length(MessageFromTCP) > 0 then
      begin
        Stream.Write(MessageFromTCP[1], length(MessageFromTCP));
      end;
    end;

    if Pos('DataSyncClientEnd', MessageFromTCP) > 0 then
    begin
      AdifFromMobileSyncStart := False;
      ImportAdifMobile := True;
      Stream.SaveToFile(FilePATH + 'ImportMobile.adi');
      AssignFile(AdifFile, FilePATH + 'ImportMobile.adi');
      Reset(AdifFile);
      while not EOF(AdifFile) do
      begin
        Readln(AdifFile, s);
        s := StringReplace(s, '<EOR>', '<EOR>'#10, [rfReplaceAll]);
        s := StringReplace(s, '<EOH>', '<EOH>'#10, [rfReplaceAll]);
      end;
      CloseFile(AdifFile);
      Rewrite(AdifFile);
      Writeln(AdifFile, s);
      CloseFile(AdifFile);
      StartImport;
      Stream.Free;
      ImportAdifMobile := False;
    end;
  end;
end;

procedure TMobileSynThread.StartImport;
begin
  PADIImport.Path := FilePATH + 'ImportMobile.adi';
  PADIImport.Mobile := True;
  PADIImport.SearchPrefix := True;
  PADIImport.Comment := '';
  PADIImport.TimeOnOff := True;
  ImportADIFThread := TImportADIFThread.Create;
  if Assigned(ImportADIFThread.FatalException) then
    raise ImportADIFThread.FatalException;
  ImportADIFThread.PADIImport := PADIImport;
  ImportADIFThread.Start;
end;

constructor TMobileSynThread.Create;
var
  i: integer;
begin
  FreeOnTerminate := True;
  inherited Create(True);
  SyncTCP := nil;
  SyncTCP := TIdTCPServer.Create;
  SyncTCP.OnConnect := @OnConnect;
  SyncTCP.OnDisconnect := @OnDisconnect;
  SyncTCP.OnExecute := @OnExecute;
  lastTCPport := -1;

  for i := 0 to 5 do
  begin
    SyncTCP.Bindings.Add.IP := IniSet.InterfaceMobileSync;
    SyncTCP.Bindings.Add.Port := port_tcp[i];
    try
      SyncTCP.Active := True;
    except
      SyncTCP.Active := False;
      SyncTCP.Bindings.Clear;
      Continue;
    end;

    if SyncTCP.Active then
    begin
      lastTCPport := port_tcp[i];
      Break;
    end;
  end;

  AdifFromMobileSyncStart := False;
  ImportAdifMobile := False;
end;

destructor TMobileSynThread.Destroy;
begin
  if SyncTCP <> nil then
    FreeAndNil(SyncTCP);
  inherited Destroy;
end;

procedure TMobileSynThread.ToForm;
begin
  MiniForm.FromMobileSyncThread(InfoStr);
end;

procedure TMobileSynThread.Execute;
begin
  while not Terminated do
  begin
    sleep(100);
  end;
end;

procedure TMobileSynThread.ExportToMobile(range: string; date: string);
var
  tmp: string = '';
  tmp2: string = '';
  RecCount: integer = 0;
  tmpFreq: string;
  Freq_float: double;
  Query: TSQLQuery;
  FormatSettings: TFormatSettings;
begin
  try
    FormatSettings.DateSeparator := '.';
    FormatSettings.ShortDateFormat := 'dd.mm.yyyy';
    Query := TSQLQuery.Create(nil);
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;

    if (range = 'All') then
      Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
        ' ORDER BY UnUsedIndex ASC';
    if (range = 'Date') then
    begin
      if DBRecord.CurrentDB = 'MySQL' then
        Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
          ' WHERE QSODate >= ' + '''' + FormatDateTime('yyyy-mm-dd',
          StrToDate(date, FormatSettings)) + '''' +
          ' OR SYNC = 0 ORDER BY UnUsedIndex ASC'
      else
        Query.SQL.Text :=
          'SELECT * FROM ' + LBRecord.LogTable + ' WHERE ' + 'strftime(' +
          QuotedStr('%Y-%m-%d') + ',QSODate) >= ' +
          QuotedStr(FormatDateTime('yyyy-mm-dd', StrToDate(date, FormatSettings))) +
          ' OR SYNC = 0 ORDER BY UnUsedIndex ASC';
    end;
    Query.Open;
    try
      Query.First;
      while not Query.EOF do
      begin
        tmp2 := '';

        tmp := '<OPERATOR' + dmFunc.StringToADIF(
          dmFunc.RemoveSpaces(DBRecord.CurrCall), True);
        tmp2 := tmp2 + tmp;

        tmp := '<CALL' + dmFunc.StringToADIF(
          dmFunc.RemoveSpaces(Query.Fields.FieldByName('CallSign').AsString),
          True);
        tmp2 := tmp2 + tmp;

        tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
          'QSODate').AsDateTime);
        tmp := '<QSO_DATE' + dmFunc.StringToADIF(tmp, True);
        tmp2 := tmp2 + tmp;

        tmp := Query.Fields.FieldByName('QSOTime').AsString;
        tmp := copy(tmp, 1, 2) + copy(tmp, 4, 2);
        tmp := '<TIME_ON' + dmFunc.StringToADIF(tmp, True);
        tmp2 := tmp2 + tmp;

        tmp := Query.Fields.FieldByName('QSOTime').AsString;
        tmp := copy(tmp, 1, 2) + copy(tmp, 4, 2);
        tmp := '<TIME_OFF' + dmFunc.StringToADIF(tmp, True);
        tmp2 := tmp2 + tmp;

        if Query.Fields.FieldByName('QSOMode').AsString <> '' then
        begin
          tmp := '<MODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSOMode').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSOSubMode').AsString <> '' then
        begin
          tmp := '<SUBMODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSOSubMode').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSOBand').AsString <> '' then
        begin
          tmpFreq := Query.Fields.FieldByName('QSOBand').AsString;
          Delete(tmpFreq, Length(tmpFreq) - 2, 1);
          TryStrToFloatSafe(tmpFreq, Freq_float);
          tmp := '<FREQ' + dmFunc.StringToADIF(
            StringReplace(FormatFloat('0.#####', Freq_float), ',',
            '.', [rfReplaceAll]), True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSOReportSent').AsString <> '' then
        begin
          tmp := '<RST_SENT' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSOReportSent').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSOReportRecived').AsString <> '' then
        begin
          tmp := '<RST_RCVD' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSOReportRecived').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if (Query.Fields.FieldByName('SRX').AsInteger <> 0) or
          (not Query.Fields.FieldByName('SRX').IsNull) then
        begin
          tmp := '<SRX' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'SRX').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if (Query.Fields.FieldByName('STX').AsInteger <> 0) or
          (not Query.Fields.FieldByName('STX').IsNull) then
        begin
          tmp := '<STX' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'STX').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if (Query.Fields.FieldByName('SRX_STRING').AsString <> '') then
        begin
          tmp := '<SRX_STRING' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'SRX_STRING').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if (Query.Fields.FieldByName('STX_STRING').AsString <> '') then
        begin
          tmp := '<STX_STRING' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'STX_STRING').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('OMName').AsString <> '' then
        begin
          tmp := '<NAME' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'OMName').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('OMQTH').AsString <> '' then
        begin
          tmp := '<QTH' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'OMQTH').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('State').AsString <> '' then
        begin
          tmp := '<STATE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'State').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('Grid').AsString <> '' then
        begin
          tmp := '<GRIDSQUARE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'Grid').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('WPX').AsString <> '' then
        begin
          tmp := '<PFX' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'WPX').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('DXCCPrefix').AsString <> '' then
        begin
          tmp := '<DXCC_PREF' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'DXCCPrefix').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSOBand').AsString <> '' then
        begin
          tmp := '<BAND' + dmFunc.StringToADIF(dmFunc.GetBandFromFreq(
            Query.Fields.FieldByName('QSOBand').AsString), True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('CQZone').AsString <> '' then
        begin
          tmp := '<CQZ' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'CQZone').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('ITUZone').AsString <> '' then
        begin
          tmp := '<ITUZ' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'ITUZone').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('Continent').AsString <> '' then
        begin
          tmp := '<CONT' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'Continent').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSLInfo').AsString <> '' then
        begin
          tmp := '<QSLMSG' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSLInfo').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSLReceQSLcc').AsString <> '' then
        begin
          tmp := '<EQSL_QSL_RCVD' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSLReceQSLcc').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSLSentDate').AsString <> '' then
        begin
          tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
            'QSLSentDate').AsDateTime);
          tmp := '<QSLSDATE' + dmFunc.StringToADIF(tmp, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSLRecDate').AsString <> '' then
        begin
          tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
            'QSLRecDate').AsDateTime);
          tmp := '<QSLRDATE' + dmFunc.StringToADIF(tmp, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSLRec').AsString <> '' then
        begin
          tmp := '<QSL_RCVD' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSLRec').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSL_RCVD_VIA').AsString <> '' then
        begin
          tmp := '<QSL_RCVD_VIA' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSL_RCVD_VIA').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSL_SENT_VIA').AsString <> '' then
        begin
          tmp := '<QSL_SENT_VIA' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSL_SENT_VIA').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSLSent').AsString <> '' then
        begin
          tmp := '<QSL_SENT' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSLSent').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('DXCC').AsString <> '' then
        begin
          tmp := '<DXCC' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'DXCC').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('QSOAddInfo').AsString <> '' then
        begin
          tmp := '<COMMENT' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSOAddInfo').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('MY_STATE').AsString <> '' then
        begin
          tmp := '<MY_STATE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'MY_STATE').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('MY_GRIDSQUARE').AsString <> '' then
        begin
          tmp := '<MY_GRIDSQUARE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'MY_GRIDSQUARE').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('MY_LAT').AsString <> '' then
        begin
          tmp := '<MY_LAT' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'MY_LAT').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        if Query.Fields.FieldByName('MY_LON').AsString <> '' then
        begin
          tmp := '<MY_LON' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'MY_LON').AsString, True);
          tmp2 := tmp2 + tmp;
        end;

        tmp := '<EOR>';
        tmp2 := tmp2 + tmp;
        tmp := #13;
        tmp2 := tmp2 + tmp;
        AdifMobileString.Add(tmp2);
        Inc(RecCount);
        InfoStr := rSentRecord + ':' + IntToStr(RecCount);
        Synchronize(@ToForm);
        Query.Next;
      end;
    finally
      Query.Close;
    end;

  finally
    FreeAndNil(Query);
  end;
end;

end.
