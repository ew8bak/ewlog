unit ServiceEqslForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  DBGrids, EditBtn, Buttons, StdCtrls, eQSLservice_u, ResourceStr, LCLType,
  SQLDB, DB;

type

  { TServiceEqslForm }

  TServiceEqslForm = class(TForm)
    Bevel3: TBevel;
    Bevel4: TBevel;
    BtConnecteQSL: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    DBGrid1: TDBGrid;
    DEeQSLcc: TDateEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
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
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PBDownload: TProgressBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure BtConnecteQSLClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabSheet2Hide(Sender: TObject);
    procedure TabSheet2Show(Sender: TObject);
  private
    UploadDS: TDataSource;
    needUploadQuery: TSQLQuery;
    ListQSONumberToUpload: TStringList;
    procedure eQSLImport(FPath: string);
    procedure RefreshData;

  public
    procedure DataFromThread(Status: TdataEQSL);

  end;

var
  ServiceEqslForm: TServiceEqslForm;

implementation

uses InitDB_dm, LogConfigForm_U, dmFunc_U, MainFuncDM;

{$R *.lfm}

{ TServiceEqslForm }

procedure TServiceEqslForm.RefreshData;
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
      ' WHERE EQSL_QSL_SENT = ''N''';
    CountQuery.Open;
    RecordCount := CountQuery.Fields[0].AsInteger;
  finally
    FreeAndNil(CountQuery);
  end;

  needUploadQuery.SQL.Text :=
    'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
    ' WHERE EQSL_QSL_SENT = ''N'' ORDER BY UnUsedIndex DESC';
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
    + LBRecord.LogTable + ' WHERE EQSL_QSL_SENT = ''N'' ORDER BY UnUsedIndex DESC';

  if DBRecord.CurrentDB = 'MySQL' then
  needUploadQuery.SQL.Text :=
    'SELECT CallSign, QSODateTime, QSOBand, QSOMode FROM '
    + LBRecord.LogTable + ' WHERE EQSL_QSL_SENT = ''N'' ORDER BY UnUsedIndex DESC';


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
    Label5.Caption := rAllQSOsuploadedtoeQSLcc;
end;

procedure TServiceEqslForm.DataFromThread(Status: TdataEQSL);
var
  Query: TSQLQuery;
  i: integer;
begin
  PBDownload.Position := Status.DownloadedPercent;
  if Status.TaskType = 'Download' then
    LBCurrStatus.Caption := Status.Message;
  if Status.Error then
  begin
    LBCurrError.Caption := Status.ErrorString;
    BtConnecteQSL.Enabled := True;
  end;
  LBDownloadSize.Caption := FormatFloat('0.###', Status.DownloadedFileSize / 1048576) +
    ' ' + rMBytes;

  if (Status.StatusDownload) and (Status.TaskType = 'Download') then
  begin
    eQSLImport(status.DownloadedFilePATH);
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
          ' SET EQSL_QSL_SENT = ''Y'' WHERE UnUsedIndex = ' +
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

procedure TServiceEqslForm.Button1Click(Sender: TObject);
begin
  OpenDialog1.Execute;
  if OpenDialog1.FileName <> '' then
  begin
    Label2.Caption := ExtractFileName(OpenDialog1.FileName);
    eQSLImport(OpenDialog1.FileName);
  end;
end;

procedure TServiceEqslForm.Button2Click(Sender: TObject);
begin
  PBDownload.Position := 0;
  if (LBRecord.eQSLccLogin = '') or (LBRecord.eQSLccPassword = '') then
  begin
    if Application.MessageBox(PChar(rNotDataForConnect + #10#13 + rGoToSettings),
      PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      LogConfigForm.Show;
    LogConfigForm.PageControl1.ActivePageIndex := 1;
  end
  else
  begin
    Button2.Enabled := False;
    eQSLThread := TeQSLThread.Create;
    if Assigned(eQSLThread.FatalException) then
      raise eQSLThread.FatalException;
    with eQSLThread do
    begin
      DataFromServiceEqslForm.User := LBRecord.eQSLccLogin;
      DataFromServiceEqslForm.Password := LBRecord.eQSLccPassword;
      DataFromServiceEqslForm.TaskType := 'Upload';
      Start;
    end;
  end;
end;

procedure TServiceEqslForm.Button3Click(Sender: TObject);
var
  MarkQuery: TSQLQuery;
begin
  try
    MarkQuery := TSQLQuery.Create(nil);
    if DBRecord.CurrentDB = 'MySQL' then
      MarkQuery.DataBase := InitDB.MySQLConnection
    else
      MarkQuery.DataBase := InitDB.SQLiteConnection;
    MarkQuery.SQL.Text := 'UPDATE ' + LBRecord.LogTable + ' SET EQSL_QSL_SENT = ''Y''';
    MarkQuery.ExecSQL;
  finally
    InitDB.DefTransaction.Commit;
    if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
      ShowMessage(rDBError);
    FreeAndNil(MarkQuery);
  end;
end;

procedure TServiceEqslForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TServiceEqslForm.FormCreate(Sender: TObject);
begin
  UploadDS := nil;
  needUploadQuery := nil;
  ListQSONumberToUpload := nil;
end;

procedure TServiceEqslForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(ListQSONumberToUpload);
  FreeAndNil(UploadDS);
  FreeAndNil(needUploadQuery);
end;

procedure TServiceEqslForm.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  DEeQSLcc.Date := INIFile.ReadDate('SetLog', 'LasteQSLcc', Now);
end;

procedure TServiceEqslForm.TabSheet2Hide(Sender: TObject);
begin
  needUploadQuery.Close;
end;

procedure TServiceEqslForm.TabSheet2Show(Sender: TObject);
begin
  RefreshData;
end;

procedure TServiceEqslForm.BtConnecteQSLClick(Sender: TObject);
begin
  PBDownload.Position := 0;
  if (LBRecord.eQSLccLogin = '') or (LBRecord.eQSLccPassword = '') then
  begin
    if Application.MessageBox(PChar(rNotDataForConnect + #10#13 + rGoToSettings),
      PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      LogConfigForm.Show;
    LogConfigForm.PageControl1.ActivePageIndex := 1;
  end
  else
  begin
    BtConnecteQSL.Enabled := False;
    eQSLThread := TeQSLThread.Create;
    if Assigned(eQSLThread.FatalException) then
      raise eQSLThread.FatalException;
    with eQSLThread do
    begin
      DataFromServiceEqslForm.User := LBRecord.eQSLccLogin;
      DataFromServiceEqslForm.Password := LBRecord.eQSLccPassword;
      DataFromServiceEqslForm.Date := FormatDateTime('yyyymmdd', DEeQSLcc.Date);
      DataFromServiceEqslForm.TaskType := 'Download';
      Start;
    end;
    LBCurrStatus.Caption := rStatusConnecteQSL;
  end;
end;

procedure TServiceEqslForm.eQSLImport(FPath: string);
var
  Query: TSQLQuery;
  f: TextFile;
  temp_f: TextFile;
  s: string;
  CALL: string;
  BAND: string;
  MODE: string;
  SUBMODE: string;
  RST_SENT: string;
  QSO_DATE: string;
  TIME_ON: string;
  QSL_SENT: string;
  QSL_SENT_VIA: string;
  PROP_MODE: string;
  QSLMSG: string;
  GRIDSQUARE: string;
  paramQSL_SENT: string;
  QueryTXT: string;
  DupeCount: integer;
  ErrorCount, RecCount: integer;
  PosEOH: word;
  PosEOR: word;
  yyyy, mm, dd: word;
  digiBand: string;
  nameBand: string;
  Stream: TMemoryStream;
  TempFile: string;
  SQLString: string;
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
        MODE := '';
        SUBMODE := '';
        RST_SENT := '';
        QSO_DATE := '';
        TIME_ON := '';
        GRIDSQUARE := '';
        QSL_SENT_VIA := '';
        QSLMSG := '';
        QSL_SENT := '';
        PROP_MODE := '';
        paramQSL_SENT := '';
        nameBand := '';
        SQLString := '';
        digiBand := '';
        Readln(temp_f, s);
        s := Trim(s);

        PosEOR := Pos('<EOR>', UpperCase(s));
        if not (PosEOR > 0) then
          Continue;

        CALL := dmFunc.getField(s, 'CALL');
        BAND := dmFunc.getField(s, 'BAND');
        MODE := dmFunc.getField(s, 'MODE');
        SUBMODE := dmFunc.getField(s, 'SUBMODE');
        QSO_DATE := dmFunc.getField(s, 'QSO_DATE');
        TIME_ON := dmFunc.getField(s, 'TIME_ON');
        GRIDSQUARE := dmFunc.getField(s, 'GRIDSQUARE');
        QSL_SENT_VIA := dmFunc.getField(s, 'QSL_SENT_VIA');
        QSLMSG := dmFunc.getField(s, 'QSLMSG');
        RST_SENT := dmFunc.getField(s, 'RST_SENT');
        QSL_SENT := dmFunc.getField(s, 'QSL_SENT');
        PROP_MODE := dmFunc.getField(s, 'PROP_MODE');

        if PosEOR > 0 then
        begin

          if QSL_SENT = 'Y' then
            paramQSL_SENT := '1'
          else
            paramQSL_SENT := '0';

          if Pos('M', BAND) > 0 then
            NameBand := MainFunc.ConvertFreqToSave(
              FloatToStr(dmFunc.GetFreqFromBand(BAND, MODE)))
          else
            NameBand := MainFunc.ConvertFreqToSave(BAND);

          digiBand := StringReplace(FloatToStr(dmFunc.GetDigiBandFromFreq(NameBand)),
            ',', '.', [rfReplaceAll]);

          if Length(SUBMODE) > 0 then
            SQLString := 'UPDATE ' + LBRecord.LogTable + ' SET QSOMode = ' +
              dmFunc.Q(MODE) + 'QSOSubMode = ' + dmFunc.Q(SUBMODE)
          else
            SQLString := 'UPDATE ' + LBRecord.LogTable + ' SET QSOMode = ' +
              dmFunc.Q(MODE);

          if DBRecord.CurrentDB = 'MySQL' then
            QueryTXT := SQLString + 'QSL_RCVD_VIA = ' +
              dmFunc.Q(QSL_SENT_VIA) + 'Grid = ' + dmFunc.Q(GRIDSQUARE) +
              'QSLInfo = ' + dmFunc.Q(QSLMSG) + 'QSOReportRecived = ' +
              dmFunc.Q(RST_SENT) + 'PROP_MODE = ' + dmFunc.Q(PROP_MODE) +
              'QSLReceQSLcc = ' + QuotedStr(paramQSL_SENT) +
              ' WHERE CallSign = ' + QuotedStr(CALL) + ' AND QSODate = ' +
              QuotedStr(QSO_DATE) + ' AND DigiBand = ' + digiBand +
              ' AND (QSOMode = ' + QuotedStr(MODE) + ' OR QSOSubMode = ' +
              QuotedStr(SUBMODE) + ')'
          else
            QueryTXT := SQLString + 'QSL_RCVD_VIA = ' +
              dmFunc.Q(QSL_SENT_VIA) + 'Grid = ' + dmFunc.Q(GRIDSQUARE) +
              'QSLInfo = ' + dmFunc.Q(QSLMSG) + 'QSOReportRecived = ' +
              dmFunc.Q(RST_SENT) + 'PROP_MODE = ' + dmFunc.Q(PROP_MODE) +
              'QSLReceQSLcc = ' + QuotedStr(paramQSL_SENT) +
              ' WHERE CallSign = ' + QuotedStr(CALL) +
              ' AND strftime(''%Y%m%d'',QSODate) = ' + QuotedStr(QSO_DATE) +
              ' AND DigiBand = ' + digiBand + ' AND (QSOMode = ' +
              QuotedStr(MODE) + ' OR QSOSubMode = ' + QuotedStr(SUBMODE) + ')';

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
    BtConnecteQSL.Enabled := True;
    INIFile.WriteDate('SetLog', 'LasteQSLcc', Now);
  end;
end;

end.
