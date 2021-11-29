(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit ServiceForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, LazUTF8, ExtCtrls, StdCtrls, EditBtn, Buttons, LConvEncoding,
  LazFileUtils, dateutils, resourcestr, LCLType, downloadQSLthread;

type

  { TServiceForm }

  TServiceForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    BtConnectLoTW: TButton;
    BtConnecteQSL: TButton;
    DELoTW: TDateEdit;
    DEeQSLcc: TDateEdit;
    Image1: TImage;
    LBCurrError: TLabel;
    LBCurrStatus: TLabel;
    LBDownloadQSL: TLabel;
    LBLoTW: TLabel;
    LBeQSLcc: TLabel;
    LBProcessed: TLabel;
    LBErrors: TLabel;
    LBStatus: TLabel;
    LBDownloadSize: TLabel;
    LBDownload: TLabel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    PBDownload: TProgressBar;
    SBeQSLFile: TSpeedButton;
    procedure BtConnectLoTWClick(Sender: TObject);
    procedure BtConnecteQSLClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SBeQSLFileClick(Sender: TObject);
  private
    { private declarations }
  public
    procedure LotWImport(FPath: string);
    procedure DataFromThread(status: TdataThread);
    { public declarations }
  end;

var
  ServiceForm: TServiceForm;

implementation

{$R *.lfm}
uses dmFunc_U, InitDB_dm, LogConfigForm_U, MainFuncDM;

procedure TServiceForm.DataFromThread(status: TdataThread);
begin
  PBDownload.Position := status.DownloadedPercent;
  LBCurrStatus.Caption := status.Message;
  if status.Error then
    LBCurrError.Caption := status.ErrorString;
  LBDownloadSize.Caption := FormatFloat('0.###', status.DownloadedFileSize / 1048576) +
    ' ' + rMBytes;

  if status.StatusDownload then
  begin
    if status.Service = 'LoTW' then
      LotWImport(status.DownloadedFilePATH);
  end;
end;

procedure TServiceForm.LotWImport(FPath: string);
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

procedure TServiceForm.BtConnecteQSLClick(Sender: TObject);
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
    downloadQSLTThread := TdownloadQSLThread.Create;
    if Assigned(downloadQSLTThread.FatalException) then
      raise downloadQSLTThread.FatalException;
    with downloadQSLTThread do
    begin
      DataFromServiceForm.Service := 'eQSLcc';
      DataFromServiceForm.User := LBRecord.eQSLccLogin;
      DataFromServiceForm.Password := LBRecord.eQSLccPassword;
      DataFromServiceForm.Date := FormatDateTime('yyyymmdd', DEeQSLcc.Date);
      Start;
    end;
    LBCurrStatus.Caption := rStatusConnecteQSL;
  end;
end;

procedure TServiceForm.BtConnectLoTWClick(Sender: TObject);
begin
  PBDownload.Position := 0;
  if (LBRecord.LoTWLogin = '') or (LBRecord.LoTWPassword = '') then
  begin
    if Application.MessageBox(PChar(rNotDataForConnect + #10#13 + rGoToSettings),
      PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      LogConfigForm.Show;
    LogConfigForm.PageControl1.ActivePageIndex := 2;
  end
  else
  begin
    BtConnectLoTW.Enabled := False;

    downloadQSLTThread := TdownloadQSLThread.Create;
    if Assigned(downloadQSLTThread.FatalException) then
      raise downloadQSLTThread.FatalException;
    with downloadQSLTThread do
    begin
      DataFromServiceForm.Service := 'LoTW';
      DataFromServiceForm.User := LBRecord.LoTWLogin;
      DataFromServiceForm.Password := LBRecord.LoTWPassword;
      DataFromServiceForm.Date := FormatDateTime('yyyy-mm-dd', DELoTW.Date);
      Start;
    end;
    LBCurrStatus.Caption := rStatusConnectLotW;
  end;
end;

procedure TServiceForm.FormShow(Sender: TObject);
begin
  BtConnecteQSL.Enabled := True;
  BtConnectLoTW.Enabled := True;
  LBCurrError.Caption := rNone;
  LBCurrStatus.Caption := rWait;
  PBDownload.Position := 0;
  LBDownloadSize.Caption := '0 ' + rMBytes;
  DELoTW.Date := INIFile.ReadDate('SetLog', 'LastLoTW', Now);
  DEeQSLcc.Date := INIFile.ReadDate('SetLog', 'LasteQSLcc', Now);
end;

procedure TServiceForm.SBeQSLFileClick(Sender: TObject);
begin

end;

end.
