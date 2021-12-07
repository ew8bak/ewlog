(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)
unit ServiceLoTWForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  EditBtn, StdCtrls, DBGrids, SQLDB, DB, ResourceStr, DateUtils, LoTWservice_u,
  LCLType, process;

type

  { TServiceLoTWForm }

  TServiceLoTWForm = class(TForm)
    Bevel3: TBevel;
    BtConnectLoTW: TButton;
    Button2: TButton;
    Button3: TButton;
    DBGrid1: TDBGrid;
    DELoTW: TDateEdit;
    Image1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LBCurrError: TLabel;
    LBCurrStatus: TLabel;
    LBDownload: TLabel;
    LBDownloadSize: TLabel;
    LBErrors: TLabel;
    LBProcessed: TLabel;
    LBStatus: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PBDownload: TProgressBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure BtConnectLoTWClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabSheet2Hide(Sender: TObject);
    procedure TabSheet2Show(Sender: TObject);
  private
    AProcess: TProcess;
    tmrLoTW: TTimer;
    UploadDS: TDataSource;
    needUploadQuery: TSQLQuery;
    ListQSONumberToUpload: TStringList;
    procedure RefreshData;
    procedure LotWImport(FPath: string);
    procedure tmrLoTWTimer(Sender: TObject);
    procedure SignAdi(FileName: string);

  public
    procedure DataFromThread(Status: TdataLoTW);

  end;

var
  ServiceLoTWForm: TServiceLoTWForm;

implementation

uses InitDB_dm, LogConfigForm_U, dmFunc_U, MainFuncDM, ConfigForm_U;

{$R *.lfm}

{ TServiceLoTWForm }

procedure TServiceLoTWForm.SignAdi(FileName: string);
var
  paramList: TStringList;
  i: integer;
begin
  i := 0;
  paramList := TStringList.Create;
  paramList.Delimiter := ' ';
  paramList.DelimitedText := IniSet.LoTW_Path + ' -d -l "' + IniSet.LoTW_QTH +
    '" ' + FileName + ' -q -p ' + IniSet.LoTW_Key;
  AProcess.Parameters.Clear;
  while i < paramList.Count do
  begin
    if (i = 0) then
      AProcess.Executable := paramList[i]
    else
      AProcess.Parameters.Add(paramList[i]);
    Inc(i);
  end;
  paramList.Free;
  //AProcess.Options := [poUsePipes];

  AProcess.Execute;
  tmrLoTW.Enabled := True;
end;

procedure TServiceLoTWForm.tmrLoTWTimer(Sender: TObject);
var
  OutputLines: TStringList;
begin
  if not AProcess.Running then
  begin
   { OutputLines := TStringList.Create;
    try
      OutputLines.LoadFromStream(Aprocess.Output);
      writeln(OutputLines.Text);
      OutputLines.LoadFromStream(Aprocess.Stderr);
      writeln(OutputLines.Text);
    finally
      OutputLines.Free;
    end;
    }
    if Aprocess.ExitCode = 0 then
    begin
      Label7.Caption := 'Signed';
      //  writeln('If you did not see any errors, you can send signed file to LoTW website by'
      //    + ' pressing Upload button');
      Button2.Caption := 'Upload';
      Button2.Enabled := True;
    end
    else
    begin
      ShowMessage('Что то пошло не так, попробуйте ещё раз');
      Button2.Caption := 'Generate';
      Button2.Enabled := True;
      tmrLoTW.Enabled := False;
    end;
    tmrLoTW.Enabled := False;
  end;
end;

procedure TServiceLoTWForm.DataFromThread(Status: TdataLoTW);
var
  Query: TSQLQuery;
  i: integer;
begin
  if Status.TaskType = 'GenerateADI' then
  begin
    Label5.Caption := Status.Message;
    Label7.Caption := IntToStr(Status.RecCount) + ' of ' + IntToStr(Status.AllRecCount);
    if Status.Result then
      SignAdi(FilePATH + 'upload_LoTW.adi');
  end;
  if Status.TaskType = 'SignADI' then
  begin
    Label5.Caption := Status.Message;
    Label7.Caption := '';

  end;

  PBDownload.Position := Status.DownloadedPercent;
  if Status.TaskType = 'Download' then
    LBCurrStatus.Caption := Status.Message;
  if Status.Error then
  begin
    LBCurrError.Caption := Status.ErrorString;
    BtConnectLoTW.Enabled := True;
  end;
  LBDownloadSize.Caption := FormatFloat('0.###', Status.DownloadedFileSize / 1048576) +
    ' ' + rMBytes;

  if (Status.StatusDownload) and (Status.TaskType = 'Download') then
  begin
    LotWImport(status.DownloadedFilePATH);
  end;

  if (Status.StatusUpload) and (Status.TaskType = 'Upload') then
  begin
    try
      Query := TSQLQuery.Create(nil);

      if DBRecord.CurrentDB = 'MySQL' then
        Query.DataBase := InitDB.MySQLConnection
      else
        Query.DataBase := InitDB.SQLiteConnection;

      for i := 0 to ListQSONumberToUpload.Count - 1 do
      begin
        Query.SQL.Text := 'UPDATE ' + LBRecord.LogTable +
          ' SET LoTWSent = 1 WHERE UnUsedIndex = ' +
          ListQSONumberToUpload.Strings[i];
        Query.ExecSQL;
      end;
      ShowMessage(status.Message);

    finally
      InitDB.DefTransaction.Commit;
      if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
        ShowMessage(rDBError);
      ListQSONumberToUpload.Clear;
      FreeAndNil(Query);
      RefreshData;
    end;
  end;

end;

procedure TServiceLoTWForm.RefreshData;
var
  RecordCount: integer;
  CountQuery: TSQLQuery;
  i: integer;
begin
  Button2.Visible := False;
  if not Assigned(needUploadQuery) then
    needUploadQuery := TSQLQuery.Create(nil);
  if not Assigned(UploadDS) then
    UploadDS := TDataSource.Create(nil);
  if not Assigned(ListQSONumberToUpload) then
    ListQSONumberToUpload := TStringList.Create;

  if not Assigned(AProcess) then
    AProcess := TProcess.Create(nil);

  if not Assigned(tmrLoTW) then
  begin
    tmrLoTW := TTimer.Create(nil);
    tmrLoTW.Enabled := False;
    tmrLoTW.Interval := 1000;
    tmrLoTW.OnTimer := @tmrLoTWTimer;
  end;

  try
    needUploadQuery.Close;
    CountQuery := TSQLQuery.Create(nil);
    if DBRecord.CurrentDB = 'MySQL' then
    begin
      needUploadQuery.DataBase := InitDB.MySQLConnection;
      CountQuery.DataBase := InitDB.MySQLConnection;
    end
    else
    begin
      needUploadQuery.DataBase := InitDB.SQLiteConnection;
      CountQuery.DataBase := InitDB.SQLiteConnection;
    end;
    CountQuery.SQL.Text := 'SELECT COUNT(*) FROM ' + LBRecord.LogTable +
      ' WHERE LoTWSent = 0';
    CountQuery.Open;
    RecordCount := CountQuery.Fields[0].AsInteger;
  finally
    FreeAndNil(CountQuery);
  end;

  needUploadQuery.SQL.Text :=
    'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
    ' WHERE LoTWSent = 0 ORDER BY UnUsedIndex DESC';
  needUploadQuery.Open;
  needUploadQuery.First;
  for i := 0 to RecordCount - 1 do
  begin
    ListQSONumberToUpload.Add(needUploadQuery.Fields[0].AsString);
    needUploadQuery.Next;
  end;
  needUploadQuery.Close;

  needUploadQuery.SQL.Text :=
    'SELECT CallSign, datetime(QSODateTime, ''unixepoch'') AS QSODateTime, QSOBand, QSOMode FROM '
    + LBRecord.LogTable + ' WHERE LoTWSent = 0 ORDER BY UnUsedIndex DESC';

  needUploadQuery.Open;

  UploadDS.DataSet := needUploadQuery;
  DBGrid1.DataSource := UploadDS;
  DBGrid1.Columns.Items[0].Width := 80;
  DBGrid1.Columns.Items[1].Width := 150;
  DBGrid1.Columns.Items[2].Width := 80;
  DBGrid1.Columns.Items[3].Width := 50;
  DBGrid1.Columns.Items[0].Title.Caption := rCallSign;
  DBGrid1.Columns.Items[1].Title.Caption := rQSODate;
  DBGrid1.Columns.Items[2].Title.Caption := rQSOBand;
  DBGrid1.Columns.Items[3].Title.Caption := rQSOMode;

  if RecordCount > 0 then
  begin
    Label5.Caption := rNeedUpload + ' ' + IntToStr(RecordCount) + ' QSOs';
    Button2.Visible := True;
  end
  else
    Label5.Caption := rAllQSOsuploadedtoLoTW;
end;

procedure TServiceLoTWForm.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  DELoTW.Date := INIFile.ReadDate('SetLog', 'LastLoTW', Now);
end;

procedure TServiceLoTWForm.TabSheet2Hide(Sender: TObject);
begin
  needUploadQuery.Close;
end;

procedure TServiceLoTWForm.TabSheet2Show(Sender: TObject);
begin
  RefreshData;
end;

procedure TServiceLoTWForm.Button3Click(Sender: TObject);
var
  MarkQuery: TSQLQuery;
begin
  try
    MarkQuery := TSQLQuery.Create(nil);
    if DBRecord.CurrentDB = 'MySQL' then
      MarkQuery.DataBase := InitDB.MySQLConnection
    else
      MarkQuery.DataBase := InitDB.SQLiteConnection;
    MarkQuery.SQL.Text := 'UPDATE ' + LBRecord.LogTable + ' SET LoTWSent = 1';
    MarkQuery.ExecSQL;
  finally
    InitDB.DefTransaction.Commit;
    if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
      ShowMessage(rDBError);
    FreeAndNil(MarkQuery);
  end;

end;

procedure TServiceLoTWForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  FreeAndNil(tmrLoTW);
  FreeAndNil(AProcess);
end;

procedure TServiceLoTWForm.BtConnectLoTWClick(Sender: TObject);
begin
  PBDownload.Position := 0;
  if (LBRecord.LoTWLogin = '') or (LBRecord.LoTWPassword = '') then
  begin
    if Application.MessageBox(PChar(rNotDataForConnectLoTW + #10#13 + rGoToSettings),
      PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      LogConfigForm.Show;
    LogConfigForm.PageControl1.ActivePageIndex := 2;
  end
  else
  begin
    BtConnectLoTW.Enabled := False;

    LoTWThread := TLoTWThread.Create;
    if Assigned(LoTWThread.FatalException) then
      raise LoTWThread.FatalException;
    with LoTWThread do
    begin
      DataFromServiceLoTWForm.TaskType := 'Download';
      DataFromServiceLoTWForm.User := LBRecord.LoTWLogin;
      DataFromServiceLoTWForm.Password := LBRecord.LoTWPassword;
      DataFromServiceLoTWForm.Date := FormatDateTime('yyyy-mm-dd', DELoTW.Date);
      Start;
    end;
    LBCurrStatus.Caption := rStatusConnectLotW;
  end;

end;

procedure TServiceLoTWForm.Button2Click(Sender: TObject);
begin
  PBDownload.Position := 0;
  if (LBRecord.LoTWLogin = '') or (LBRecord.LoTWPassword = '') then
  begin
    if Application.MessageBox(PChar(rNotDataForConnectLoTW + #10#13 + rGoToSettings),
      PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      LogConfigForm.Show;
    LogConfigForm.PageControl1.ActivePageIndex := 2;
  end
  else
  begin
    if (IniSet.LoTW_Path = '') or (IniSet.LoTW_QTH = '') or (IniSet.LoTW_Key = '') then
    begin
      if Application.MessageBox(PChar(rNotDataForConnectLoTW + #10#13 + rGoToSettings),
        PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
        ConfigForm.Show;
      ConfigForm.PControl.ActivePageIndex := 4;
      ConfigForm.TSLoTWShow(self);
    end
    else
    begin
      if Button2.Caption = 'Generate' then
      begin
        Button2.Enabled := False;
        LoTWThread := TLoTWThread.Create;
        if Assigned(LoTWThread.FatalException) then
          raise LoTWThread.FatalException;
        with LoTWThread do
        begin
          DataFromServiceLoTWForm.User := LBRecord.LoTWLogin;
          DataFromServiceLoTWForm.Password := LBRecord.LoTWPassword;
          DataFromServiceLoTWForm.TaskType := 'Generate';
          Start;
        end;
      end
      else
      begin
        Button2.Enabled := False;
        LoTWThread := TLoTWThread.Create;
        if Assigned(LoTWThread.FatalException) then
          raise LoTWThread.FatalException;
        with LoTWThread do
        begin
          DataFromServiceLoTWForm.User := LBRecord.LoTWLogin;
          DataFromServiceLoTWForm.Password := LBRecord.LoTWPassword;
          DataFromServiceLoTWForm.TaskType := 'Upload';
          Start;
        end;
      end;
    end;
  end;
end;

procedure TServiceLoTWForm.FormCreate(Sender: TObject);
begin
  UploadDS := nil;
  needUploadQuery := nil;
  ListQSONumberToUpload := nil;
  AProcess := nil;
  tmrLoTW := nil;
end;

procedure TServiceLoTWForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(ListQSONumberToUpload);
  FreeAndNil(UploadDS);
  FreeAndNil(needUploadQuery);
end;

procedure TServiceLoTWForm.LotWImport(FPath: string);
var
  Query: TSQLQuery;
  i: integer;
  f: TextFile;
  temp_f: TextFile;
  s: string;
  CALL: string;
  BAND: string;
  FREQ: string;
  MODE: string;
  QSO_DATE: string;
  TIME_ON: string;
  QSL_RCVD: string;
  QSLRDATE: string;
  DXCC: string;
  PFX: string;
  GRIDSQUARE: string;
  CQZ: string;
  ITUZ: string;
  APP_LOTW_2XQSL: string;
  paramAPP_LOTW_2XQSL: string;
  QueryTXT: string;
  paramQSLRDATE: string;
  DupeCount: integer;
  ErrorCount, RecCount: integer;
  PosEOH: word;
  PosEOR: word;
  yyyy, mm, dd: word;
  digiBand: string;
  nameBand: string;
  Stream: TMemoryStream;
  TempFile: string;
begin
  TempFile := FilePATH + 'temp.adi';
  RecCount := 0;
  DupeCount := 0;
  ErrorCount := 0;
  PosEOH := 0;
  PosEOR := 0;
  try
    Stream := TMemoryStream.Create;
    Query := TSQLQuery.Create(nil);
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;
    AssignFile(f, FPath);
    Reset(f);

    while not (PosEOH > 0) do
    begin
      Readln(f, s);
      PosEOH := Pos('<EOH>', UpperCase(s));
    end;

    while not EOF(f) do
    begin
      Readln(f, s);
      s := StringReplace(s, #10, '', [rfReplaceAll]);
      s := StringReplace(s, #13, '', [rfReplaceAll]);
      s := StringReplace(UpperCase(s), '<EOR>', '<EOR>'#13#10, [rfReplaceAll]);
      if Length(s) > 0 then
      begin
        Stream.Write(s[1], length(s));
      end;
    end;
    Stream.SaveToFile(TempFile);

    AssignFile(temp_f, TempFile);
    Reset(temp_f);

    while not (EOF(temp_f)) do
    begin
      try
        CALL := '';
        BAND := '';
        FREQ := '';
        MODE := '';
        QSO_DATE := '';
        TIME_ON := '';
        QSL_RCVD := '';
        QSLRDATE := '';
        DXCC := '';
        PFX := '';
        GRIDSQUARE := '';
        CQZ := '';
        ITUZ := '';
        APP_LOTW_2XQSL := '';
        paramQSLRDATE := '';
        nameBand := '';
        digiBand := '';

        Readln(temp_f, s);
        s := Trim(s);

        PosEOR := Pos('<EOR>', UpperCase(s));
        if not (PosEOR > 0) then
          Continue;

        CALL := dmFunc.getField(s, 'CALL');
        BAND := dmFunc.getField(s, 'BAND');
        FREQ := dmFunc.getField(s, 'FREQ');
        MODE := dmFunc.getField(s, 'MODE');
        QSO_DATE := dmFunc.getField(s, 'QSO_DATE');
        TIME_ON := dmFunc.getField(s, 'TIME_ON');
        QSL_RCVD := dmFunc.getField(s, 'QSL_RCVD');
        QSLRDATE := dmFunc.getField(s, 'QSLRDATE');
        DXCC := dmFunc.getField(s, 'DXCC');
        PFX := dmFunc.getField(s, 'PFX');
        GRIDSQUARE := dmFunc.getField(s, 'GRIDSQUARE');
        CQZ := dmFunc.getField(s, 'CQZ');
        ITUZ := dmFunc.getField(s, 'ITUZ');
        APP_LOTW_2XQSL := dmFunc.getField(s, 'APP_LOTW_2XQSL');

        if PosEOR > 0 then
        begin
          if APP_LOTW_2XQSL = 'Y' then
            paramAPP_LOTW_2XQSL := '1'
          else
            paramAPP_LOTW_2XQSL := '0';

          if QSLRDATE <> '' then
          begin
            yyyy := StrToInt(QSLRDATE[1] + QSLRDATE[2] + QSLRDATE[3] +
              QSLRDATE[4]);
            mm := StrToInt(QSLRDATE[5] + QSLRDATE[6]);
            dd := StrToInt(QSLRDATE[7] + QSLRDATE[8]);
            if DBRecord.CurrentDB = 'MySQL' then
              paramQSLRDATE := dmFunc.ADIFDateToDate(QSLRDATE)
            else
              paramQSLRDATE :=
                FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd)));
          end;

          if Pos('M', BAND) > 0 then
            NameBand := MainFunc.ConvertFreqToSave(
              FloatToStr(dmFunc.GetFreqFromBand(BAND, MODE)))
          else
            NameBand := MainFunc.ConvertFreqToSave(BAND);

          digiBand := StringReplace(FloatToStr(dmFunc.GetDigiBandFromFreq(NameBand)),
            ',', '.', [rfReplaceAll]);

          if DBRecord.CurrentDB = 'MySQL' then
            QueryTXT := 'UPDATE ' + LBRecord.LogTable + ' SET GRID = ' +
              dmFunc.Q(GRIDSQUARE) + 'CQZone = ' + dmFunc.Q(CQZ) +
              'ITUZone = ' + dmFunc.Q(ITUZ) + 'WPX = ' + dmFunc.Q(PFX) +
              'DXCC = ' + dmFunc.Q(DXCC) + 'LoTWSent = ' +
              dmFunc.Q(paramAPP_LOTW_2XQSL) + 'LoTWRec = ''1'', LoTWRecDate = ' +
              QuotedStr(paramQSLRDATE) + ' WHERE CallSign = ' +
              QuotedStr(CALL) + ' AND DigiBand = ' + digiBand +
              ' AND (QSOMode = ' + QuotedStr(MODE) + ' OR QSOSubMode = ' +
              QuotedStr(MODE) + ')'
          else
            QueryTXT := 'UPDATE ' + LBRecord.LogTable + ' SET GRID = ' +
              dmFunc.Q(GRIDSQUARE) + 'CQZone = ' + dmFunc.Q(CQZ) +
              'ITUZone = ' + dmFunc.Q(ITUZ) + 'WPX = ' + dmFunc.Q(PFX) +
              'DXCC = ' + dmFunc.Q(DXCC) + 'LoTWSent = ' +
              dmFunc.Q(paramAPP_LOTW_2XQSL) + 'LoTWRec = ''1'', LoTWRecDate = ' +
              QuotedStr(paramQSLRDATE) + ' WHERE CallSign = ' +
              QuotedStr(CALL) + ' AND strftime(''%Y%m%d'',QSODate) = ' +
              QuotedStr(QSO_DATE) + ' AND DigiBand = ' + digiBand +
              ' AND (QSOMode = ' + QuotedStr(MODE) + ' OR QSOSubMode = ' +
              QuotedStr(MODE) + ')';
          Query.SQL.Text := QueryTXT;
          Query.ExecSQL;

          Inc(RecCount);
          if RecCount mod 10 = 0 then
          begin
            LBProcessed.Caption := rProcessedData + IntToStr(RecCount);
            InitDB.DefTransaction.Commit;
            Application.ProcessMessages;
          end;

        end;
      except
        InitDB.DefTransaction.Rollback;
      end;
    end;
  finally
    InitDB.DefTransaction.Commit;
    CloseFile(f);
    CloseFile(temp_f);
    Stream.Free;
    FreeAndNil(Query);
    if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
      ShowMessage(rDBError);
    LBProcessed.Caption := rProcessedData + IntToStr(RecCount);
    LBCurrStatus.Caption := rDone;
    BtConnectLoTW.Enabled := True;
    INIFile.WriteDate('SetLog', 'LastLoTW', Now);
  end;
end;

end.
