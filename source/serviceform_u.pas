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
  LazUtils, LazFileUtils, ssl_openssl, dateutils, resourcestr,
  download_lotw, download_eqslcc, LCLType;

type

  { TServiceForm }

  TServiceForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Button1: TButton;
    Button2: TButton;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    SpeedButton1: TSpeedButton;
    UPDATEQuery: TSQLQuery;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    DownSize: double;
    procedure LotWImport(FPath: string);
    procedure eQSLImport(FPath: string);
    { public declarations }
  end;

var
  ServiceForm: TServiceForm;

implementation

{$R *.lfm}
uses dmFunc_U, MainForm_U, const_u, InitDB_dm, LogConfigForm_U;

procedure TServiceForm.eQSLImport(FPath: string);
var
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
  Query: string;
  DupeCount: integer;
  ErrorCount, RecCount: integer;
  PosEOH: word;
  PosEOR: word;
  yyyy, mm, dd: word;
  digiBand: double;
  nameBand: string;
  Stream: TMemoryStream;
  TempFile: string;
  SQLString: string;
begin
  TempFile:=FilePATH + 'temp.adi';
  RecCount := 0;
  DupeCount := 0;
  ErrorCount := 0;
  PosEOH := 0;
  PosEOR := 0;
  try
    Stream := TMemoryStream.Create;
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
        digiBand := -1;
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
            NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(BAND, MODE))
          else
            nameBand := BAND;

          Delete(nameBand, length(nameBand) - 2, 1);
          digiBand := dmFunc.GetDigiBandFromFreq(nameBand);

          if Length(SUBMODE) > 0 then
            SQLString := 'UPDATE ' + LBRecord.LogTable + ' SET QSOMode = ' +
              dmFunc.Q(MODE) + 'QSOSubMode = ' + dmFunc.Q(SUBMODE)
          else
            SQLString := 'UPDATE ' + LBRecord.LogTable + ' SET QSOMode = ' +
              dmFunc.Q(MODE);

          if DBRecord.CurrentDB = 'MySQL' then
            Query := SQLString + 'QSL_RCVD_VIA = ' +
              dmFunc.Q(QSL_SENT_VIA) + 'Grid = ' + dmFunc.Q(GRIDSQUARE) +
              'QSLInfo = ' + dmFunc.Q(QSLMSG) + 'QSOReportRecived = ' +
              dmFunc.Q(RST_SENT) + 'PROP_MODE = ' + dmFunc.Q(PROP_MODE) +
              'QSLReceQSLcc = ' + QuotedStr(paramQSL_SENT) +
              ' WHERE CallSign = ' + QuotedStr(CALL) + ' AND QSODate = ' +
              QuotedStr(QSO_DATE) + ' AND DigiBand = ' + FloatToStr(digiBand) +
              ' AND (QSOMode = ' + QuotedStr(MODE) + ' OR QSOSubMode = ' +
              QuotedStr(SUBMODE) + ')'
          else
            Query := SQLString + 'QSL_RCVD_VIA = ' +
              dmFunc.Q(QSL_SENT_VIA) + 'Grid = ' + dmFunc.Q(GRIDSQUARE) +
              'QSLInfo = ' + dmFunc.Q(QSLMSG) + 'QSOReportRecived = ' +
              dmFunc.Q(RST_SENT) + 'PROP_MODE = ' + dmFunc.Q(PROP_MODE) +
              'QSLReceQSLcc = ' + QuotedStr(paramQSL_SENT) +
              ' WHERE CallSign = ' + QuotedStr(CALL) +
              ' AND strftime(''%Y%m%d'',QSODate) = ' + QuotedStr(QSO_DATE) +
              ' AND DigiBand = ' + FloatToStr(digiBand) + ' AND (QSOMode = ' +
              QuotedStr(MODE) + ' OR QSOSubMode = ' + QuotedStr(SUBMODE) + ')';

          UPDATEQuery.SQL.Text := Query;
          UPDATEQuery.ExecSQL;

          Inc(RecCount);
          if RecCount mod 10 = 0 then
          begin
            Label4.Caption := rProcessedData + IntToStr(RecCount);
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
    if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
      ShowMessage(rDBError);
    Label4.Caption := rProcessedData + IntToStr(RecCount);
    Label6.Caption := rStatusDone;
    Button2.Enabled := True;
  end;
end;

procedure TServiceForm.LotWImport(FPath: string);
var
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
  Query: string;
  paramQSLRDATE: string;
  DupeCount: integer;
  ErrorCount, RecCount: integer;
  PosEOH: word;
  PosEOR: word;
  yyyy, mm, dd: word;
  digiBand: double;
  nameBand: string;
  Stream: TMemoryStream;
  TempFile: string;
begin
  TempFile:=FilePATH + 'temp.adi';
  RecCount := 0;
  DupeCount := 0;
  ErrorCount := 0;
  PosEOH := 0;
  PosEOR := 0;
  try
    Stream := TMemoryStream.Create;
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
        digiBand := -1;

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
            NameBand := FormatFloat(view_freq, dmFunc.GetFreqFromBand(BAND, MODE))
          else
            nameBand := BAND;

          Delete(nameBand, length(nameBand) - 2, 1);
          digiBand := dmFunc.GetDigiBandFromFreq(nameBand);

          if DBRecord.CurrentDB = 'MySQL' then
            Query := 'UPDATE ' + LBRecord.LogTable + ' SET GRID = ' +
              dmFunc.Q(GRIDSQUARE) + 'CQZone = ' + dmFunc.Q(CQZ) +
              'ITUZone = ' + dmFunc.Q(ITUZ) + 'WPX = ' + dmFunc.Q(PFX) +
              'DXCC = ' + dmFunc.Q(DXCC) + 'LoTWSent = ' +
              dmFunc.Q(paramAPP_LOTW_2XQSL) + 'LoTWRec = ''1'', LoTWRecDate = ' +
              QuotedStr(paramQSLRDATE) + ' WHERE CallSign = ' +
              QuotedStr(CALL) + ' AND DigiBand = ' + FloatToStr(digiBand) +
              ' AND (QSOMode = ' + QuotedStr(MODE) + ' OR QSOSubMode = ' +
              QuotedStr(MODE) + ')'
          else
            Query := 'UPDATE ' + LBRecord.LogTable + ' SET GRID = ' +
              dmFunc.Q(GRIDSQUARE) + 'CQZone = ' + dmFunc.Q(CQZ) +
              'ITUZone = ' + dmFunc.Q(ITUZ) + 'WPX = ' + dmFunc.Q(PFX) +
              'DXCC = ' + dmFunc.Q(DXCC) + 'LoTWSent = ' +
              dmFunc.Q(paramAPP_LOTW_2XQSL) + 'LoTWRec = ''1'', LoTWRecDate = ' +
              QuotedStr(paramQSLRDATE) + ' WHERE CallSign = ' +
              QuotedStr(CALL) + ' AND strftime(''%Y%m%d'',QSODate) = ' +
              QuotedStr(QSO_DATE) + ' AND DigiBand = ' + FloatToStr(digiBand) +
              ' AND (QSOMode = ' + QuotedStr(MODE) + ' OR QSOSubMode = ' +
              QuotedStr(MODE) + ')';
          UPDATEQuery.SQL.Text := Query;
          UPDATEQuery.ExecSQL;

          Inc(RecCount);
          if RecCount mod 10 = 0 then
          begin
            Label4.Caption := rProcessedData + IntToStr(RecCount);
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
    if not InitDB.SelectLogbookTable(LBRecord.LogTable) then
      ShowMessage(rDBError);
    Label4.Caption := rProcessedData + IntToStr(RecCount);
    Label6.Caption := rStatusDone;
    Button1.Enabled := True;
    INIFile.WriteDate('SetLog', 'LastLoTW', Now);
  end;
end;

procedure TServiceForm.FormCreate(Sender: TObject);
begin
  if DBRecord.CurrentDB = 'MySQL' then
  begin
    UPDATEQuery.DataBase := InitDB.MySQLConnection;
  end
  else
  begin
    UPDATEQuery.DataBase := InitDB.SQLiteConnection;
  end;
end;

procedure TServiceForm.Button2Click(Sender: TObject);
begin
  DownSize := 0;
  ProgressBar1.Position := 0;
  if (LBRecord.eQSLccLogin = '') or (LBRecord.eQSLccPassword = '') then
  begin
    if Application.MessageBox(PChar(rNotDataForConnect + #10#13 + rGoToSettings),
      PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      LogConfigForm.Show;
    LogConfigForm.PageControl1.ActivePageIndex:=1;
  end
  else
  begin
    Button2.Enabled := False;
    eQSLccThread := TeQSLccThread.Create;
    if Assigned(eQSLccThread.FatalException) then
      raise eQSLccThread.FatalException;
    with eQSLccThread do
    begin
      user_eqslcc := LBRecord.eQSLccLogin;
      password_eqslcc := LBRecord.eQSLccPassword;
      date_eqslcc := FormatDateTime('yyyymmdd', DateEdit2.Date);
      Start;
    end;
    Label6.Caption := rStatusConnecteQSL;
  end;
end;

procedure TServiceForm.Button1Click(Sender: TObject);
begin
  DownSize := 0;
  ProgressBar1.Position := 0;
  if (LBRecord.LoTWLogin = '') or (LBRecord.LoTWPassword = '') then
  begin
    if Application.MessageBox(PChar(rNotDataForConnect + #10#13 + rGoToSettings),
      PChar(rWarning), MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION) = idYes then
      LogConfigForm.Show;
    LogConfigForm.PageControl1.ActivePageIndex:=2;
  end
  else
  begin
    Button1.Enabled := False;
    LoTWThread := TLoTWThread.Create;
    if Assigned(LoTWThread.FatalException) then
      raise LoTWThread.FatalException;
    with LoTWThread do
    begin
      user_lotw := LBRecord.LoTWLogin;
      password_lotw := LBRecord.LoTWPassword;
      date_lotw := FormatDateTime('yyyy-mm-dd', DateEdit1.Date);
      Start;
      Label6.Caption := rStatusConnectLotW;
    end;
  end;
end;

procedure TServiceForm.FormShow(Sender: TObject);
begin
  Button2.Enabled := True;
  Button1.Enabled := True;
  if DBRecord.CurrentDB = 'MySQL' then
  begin
    UPDATEQuery.DataBase := InitDB.MySQLConnection;
  end
  else
  begin
    UPDATEQuery.DataBase := InitDB.SQLiteConnection;
  end;
  DateEdit1.Date := INIFile.ReadDate('SetLog', 'LastLoTW', Now);
  DateEdit2.Date := Now;
  DownSize := 0;
  Label7.Caption := FloatToStr(DownSize) + ' ' + rMBytes;
  ProgressBar1.Position := 0;
end;

procedure TServiceForm.SpeedButton1Click(Sender: TObject);
begin
  OpenDialog1.Execute;
  if OpenDialog1.FileName <> '' then
    eQSLImport(OpenDialog1.FileName);
end;

end.
