unit ServiceForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, LazUTF8, ExtCtrls, StdCtrls, EditBtn, Buttons, LConvEncoding,
  LazUtils, LazFileUtils, ssl_openssl, dateutils, resourcestr,
  download_lotw, download_eqslcc;

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
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    OpenDialog1: TOpenDialog;
    SpeedButton1: TSpeedButton;
    UPDATEQuery: TSQLQuery;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    procedure LotWImport(FilePATH: string);
    procedure eQSLImport(FilePATH: string);
    { public declarations }
  end;

var
  ServiceForm: TServiceForm;

implementation

{$R *.lfm}
uses dmFunc_U, MainForm_U;

procedure TServiceForm.eQSLImport(FilePATH: string);
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
  Stream: TMemoryStream;
  TempFile: string;
begin
  {$IFDEF UNIX}
  TempFile := GetEnvironmentVariable('HOME') + DirectorySeparator +
    'EWLog' + DirectorySeparator + 'temp.adi';
  {$ELSE}
  TempFile := GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + DirectorySeparator +
    'EWLog' + DirectorySeparator + 'temp.adi';
  {$ENDIF UNIX}
  RecCount := 0;
  DupeCount := 0;
  ErrorCount := 0;
  PosEOH := 0;
  PosEOR := 0;
  try
    Stream := TMemoryStream.Create;
    AssignFile(f, FilePATH);
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

          if MainForm.MySQLLOGDBConnection.Connected then
            Query := ''
          else
            Query := 'UPDATE ' + LogTable + ' SET QSOmode = ' +
              dmFunc.Q(MODE) + 'QSOSubMode = ' + dmFunc.Q(SUBMODE) +
              'QSL_RCVD_VIA = ' + dmFunc.Q(QSL_SENT_VIA) + 'Grid = ' +
              dmFunc.Q(GRIDSQUARE) + 'QSLInfo = ' + dmFunc.Q(QSLMSG) +
              'QSOReportRecived = ' + dmFunc.Q(RST_SENT) + 'PROP_MODE = ' +
              dmFunc.Q(PROP_MODE) + 'QSLReceQSLcc = ' + QuotedStr(paramQSL_SENT) +
              ' WHERE CallSign = ' + QuotedStr(CALL) +
              ' AND strftime(''%Y%m%d'',QSODate) = ' + QuotedStr(QSO_DATE) + ';';
          UPDATEQuery.SQL.Text := Query;
          UPDATEQuery.ExecSQL;
          MainForm.SQLTransaction1.Commit;

          Inc(RecCount);
          if RecCount mod 10 = 0 then
          begin
            Label4.Caption := rProcessedData + IntToStr(RecCount);
            Application.ProcessMessages;
          end;

        end;
      except
        MainForm.SQLTransaction1.Rollback;
      end;
    end;
  finally
    CloseFile(f);
    CloseFile(temp_f);
    Stream.Free;
    MainForm.SelDB(CallLogBook);
    Label4.Caption := rProcessedData + IntToStr(RecCount);
    Label6.Caption := rStatusDone;
  end;
end;

procedure TServiceForm.LotWImport(FilePATH: string);
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
  Stream: TMemoryStream;
  TempFile: string;
begin
  {$IFDEF UNIX}
  TempFile := GetEnvironmentVariable('HOME') + DirectorySeparator +
    'EWLog' + DirectorySeparator + 'temp.adi';
  {$ELSE}
  TempFile := GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + DirectorySeparator +
    'EWLog' + DirectorySeparator + 'temp.adi';
  {$ENDIF UNIX}
  RecCount := 0;
  DupeCount := 0;
  ErrorCount := 0;
  PosEOH := 0;
  PosEOR := 0;
  try
    Stream := TMemoryStream.Create;
    AssignFile(f, FilePATH);
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
            if MainForm.MySQLLOGDBConnection.Connected then
              paramQSLRDATE := dmFunc.ADIFDateToDate(QSLRDATE)
            else
              paramQSLRDATE :=
                FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd)));
          end;

          if MainForm.MySQLLOGDBConnection.Connected then
            Query := ''
          else
            Query := 'UPDATE ' + LogTable + ' SET GRID = ' +
              dmFunc.Q(GRIDSQUARE) + 'CQZone = ' + dmFunc.Q(CQZ) +
              'ITUZone = ' + dmFunc.Q(ITUZ) + 'WPX = ' + dmFunc.Q(PFX) +
              'DXCC = ' + dmFunc.Q(DXCC) + 'LoTWSent = ' +
              dmFunc.Q(paramAPP_LOTW_2XQSL) + 'LoTWRec = ''1'', LoTWRecDate = ' +
              QuotedStr(paramQSLRDATE) + ' WHERE CallSign = ' +
              QuotedStr(CALL) + ' AND strftime(''%Y%m%d'',QSODate) = ' +
              QuotedStr(QSO_DATE) + ';';
          UPDATEQuery.SQL.Text := Query;
          UPDATEQuery.ExecSQL;
          MainForm.SQLTransaction1.Commit;

          Inc(RecCount);
          if RecCount mod 10 = 0 then
          begin
            Label4.Caption := rProcessedData + IntToStr(RecCount);
            Application.ProcessMessages;
          end;

        end;
      except
        MainForm.SQLTransaction1.Rollback;
      end;
    end;
  finally
    CloseFile(f);
    CloseFile(temp_f);
    Stream.Free;
    MainForm.SelDB(CallLogBook);
    Label4.Caption := rProcessedData + IntToStr(RecCount);
    Label6.Caption := rStatusDone;
  end;
end;

procedure TServiceForm.FormCreate(Sender: TObject);
begin
  if MainForm.MySQLLOGDBConnection.Connected then
  begin
    UPDATEQuery.DataBase := MainForm.MySQLLOGDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.MySQLLOGDBConnection;
  end
  else
  begin
    UPDATEQuery.DataBase := MainForm.SQLiteDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.SQLiteDBConnection;
  end;
end;

procedure TServiceForm.Button2Click(Sender: TObject);
begin
  if (eQSLccLogin = '') or (eQSLccPassword = '') then
    ShowMessage(rNotDataForConnect)
  else
  begin
    eQSLccThread := TeQSLccThread.Create;
    if Assigned(eQSLccThread.FatalException) then
      raise eQSLccThread.FatalException;
    with eQSLccThread do
    begin
      user_eqslcc := eQSLccLogin;
      password_eqslcc := eQSLccPassword;
      date_eqslcc := FormatDateTime('yyyymmdd', DateEdit2.Date);
      Start;
      Label6.Caption := rStatusConnecteQSL;
    end;
  end;
end;

procedure TServiceForm.Button1Click(Sender: TObject);
begin
  if (LotWLogin = '') or (LotWPassword = '') then
    ShowMessage(rNotDataForConnect)
  else
  begin
    LoTWThread := TLoTWThread.Create;
    if Assigned(LoTWThread.FatalException) then
      raise LoTWThread.FatalException;
    with LoTWThread do
    begin
      user_lotw := LotWLogin;
      password_lotw := LotWPassword;
      date_lotw := FormatDateTime('yyyy-mm-dd', DateEdit1.Date);
      Start;
      Label6.Caption := rStatusConnectLotW;
    end;
  end;
end;

procedure TServiceForm.FormShow(Sender: TObject);
begin
  if MainForm.MySQLLOGDBConnection.Connected then
  begin
    UPDATEQuery.DataBase := MainForm.MySQLLOGDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.MySQLLOGDBConnection;
  end
  else
  begin
    UPDATEQuery.DataBase := MainForm.SQLiteDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.SQLiteDBConnection;
  end;
  DateEdit1.Date := Now;
  DateEdit2.Date := Now;
end;

procedure TServiceForm.SpeedButton1Click(Sender: TObject);
begin
  OpenDialog1.Execute;
  eQSLImport(OpenDialog1.FileName);
end;

end.
