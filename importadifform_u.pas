unit ImportADIFForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, EditBtn, LCLType, LConvEncoding, LazUTF8, LCLIntf, dateutils;

resourcestring
  rDone = 'Done';
  rImport = 'Import';
  rImportRecord = 'Imported Records';
  rFileError = 'Error file:';
  rImportErrors = 'Import Errors';
  rNumberDup = 'Number of duplicates';
  rNothingImport = 'Nothing to import';
  rProcessing = 'Processing';

const
  ERR_FILE = 'errors.adi';
  MyWhiteSpace = [#0..#31];

type

  { TImportADIFForm }

  TImportADIFForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    FileNameEdit1: TFileNameEdit;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblErrorLog: TLabel;
    lblErrors: TLabel;
    lblCount: TLabel;
    lblComplete: TLabel;
    Memo1: TMemo;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FileNameEdit1ButtonClick(Sender: TObject);
    procedure FileNameEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblErrorLogClick(Sender: TObject);
  private
    procedure WriteWrongADIF(Lines: array of string);
    { private declarations }
  public
    procedure ADIFImport(path: string);
    { public declarations }
  end;

var
  ImportADIFForm: TImportADIFForm;

implementation

uses dmFunc_U, MainForm_U;

{$R *.lfm}

{ TImportADIFForm }

function getField(s, field: string): string;
var
  start: integer = 0;
  stop: integer = 0;
begin
  field := UpperCase(field);
  if field = 'VALIDDX' then
    field := 'ValidDX';
  if field = 'NOCALCDXCC' then
    field := 'NoCalcDXCC';
  try
    Result := '';
    start := s.IndexOf('<' + field + ':');
    if (start >= 0) then
    begin
      s := s.Substring(start + field.Length);
      start := s.IndexOf('>');
      stop := s.IndexOf('<');
      if (start < stop) and (start > -1) then
        Result := s.Substring(start + 1, stop - start - 1);
    end;
  except
    Result := '';
  end;
end;

function Q(s: string): string;
var
  i: integer;
  Quote: char;
  char2: char;
begin
  Quote := #39;
  char2 := ',';
  Result := s;
  if Result = 'NULL' then
  begin
    Result := Result + char2;
    exit;
  end;
  for i := Length(Result) downto 1 do
    if Result[i] = Quote then
      Insert(Quote, Result, i);
  Result := Quote + Result + Quote + char2;
end;

procedure TImportADIFForm.ADIFImport(path: string);
var
  i: integer;
  f: TextFile;
  s: string;
  BAND: string;
  BAND_RX: string;
  CALL: string;
  COMMENT: string;
  CONT: string;
  COUNTRY: string;
  CQZ: string;
  DXCC: string;
  DXCC_PREF: string;
  EQSL_QSLRDATE: string;
  EQSL_QSLSDATE: string;
  EQSL_QSL_RCVD: string;
  EQSL_QSL_SENT: string;
  FREQ: string;
  FREQ_RX: string;
  GRIDSQUARE: string;
  IOTA: string;
  ITUZ: string;
  LOTW_QSLRDATE: string;
  LOTW_QSLSDATE: string;
  LOTW_QSL_RCVD: string;
  LOTW_QSL_SENT: string;
  MARKER: string;
  MODE: string;
  MY_GRIDSQUARE: string;
  sNAME: string;
  NOTES: string;
  NoCalcDXCC: string;
  PFX: string;
  PROP_MODE: string;
  QSLMSG: string;
  QSLRDATE: string;
  QSLSDATE: string;
  QSL_RCVD: string;
  QSL_RCVD_VIA: string;
  QSL_SENT: string;
  QSL_SENT_VIA: string;
  QSL_VIA: string;
  QSO_DATE: string;
  QSL_STATUS: string;
  QTH: string;
  RST_RCVD: string;
  RST_SENT: string;
  SAT_MODE: string;
  SAT_NAME: string;
  SRX: string;
  SRX_STRING: string;
  STATE: string;
  STATE1: string;
  STATE2: string;
  STATE3: string;
  STATE4: string;
  STX: string;
  STX_STRING: string;
  SUBMODE: string;
  TIME_OFF: string;
  TIME_ON: string;
  ValidDX: string;
  PosEOH: word;
  PosEOR: word;
  QSOTIME: string;
  yyyy, mm, dd: word;
  paramQSLSent: string;
  paramQSLSentAdv: string;
  paramQSODate: string;
  ParamQSL_RCVD: string;
  paramMARKER: string;
  paramEQSL_QSL_RCVD: string;
  paramLOTW_QSL_RCVD: string;
  paramValidDX: string;
  paramLOTW_QSL_SENT: string;
  paramNoCalcDXCC: string;
  paramQSLSDATE: string;
  paramQSLRDATE: string;
  paramLOTW_QSLRDATE: string;
  Query: string;
  DupeCount: integer;
  ErrorCount, RecCount: integer;
begin
  try
    if MainForm.MySQLLOGDBConnection.Connected then
      MainForm.MySQLLOGDBConnection.ExecuteDirect(
        'ALTER TABLE ' + LogTable +
        ' DROP INDEX Dupe_index, ADD UNIQUE Dupe_index (CallSign, QSODate, QSOTime, QSOBand)')
    else
    begin
      MainForm.SQLiteDBConnection.ExecuteDirect('DROP INDEX IF EXISTS Dupe_index');
      MainForm.SQLiteDBConnection.ExecuteDirect('CREATE UNIQUE INDEX Dupe_index ON ' +
        LogTable + '(CallSign, QSODate, QSOTime, QSOBand)');
    end;
  except
    on E: ESQLDatabaseError do
    begin
      //  WriteLn(IntToStr(E.ErrorCode) + ' : ' + E.Message);
      if E.ErrorCode = 1091 then
        MainForm.MySQLLOGDBConnection.ExecuteDirect('ALTER TABLE ' +
          LogTable + ' ADD UNIQUE Dupe_index (CallSign, QSODate, QSOTime, QSOBand)');
    end;
  end;
  RecCount := 0;
  DupeCount := 0;
  ErrorCount := 0;
  PosEOH := 0;
  PosEOR := 0;
  try
    AssignFile(f, path);
    Reset(f);
    while not (PosEOH > 0) do
    begin
      Readln(f, s);
      PosEOH := Pos('<EOH>', UpperCase(s));
    end;
    while not (EOF(f)) do
    begin
      try
        paramQSLSent := '';
        paramQSLSentAdv := '';
        paramQSODate := '';
        ParamQSL_RCVD := '';
        paramMARKER := '';
        paramEQSL_QSL_RCVD := '';
        paramLOTW_QSL_RCVD := '';
        paramValidDX := '';
        paramLOTW_QSL_SENT := '';
        paramNoCalcDXCC := '';
        paramQSLSDATE := '';
        paramQSLRDATE := '';
        paramLOTW_QSLRDATE := '';
        PosEOR := 0;
        BAND := '';
        BAND_RX := '';
        CALL := '';
        COMMENT := '';
        CONT := '';
        COUNTRY := '';
        CQZ := '';
        DXCC := '';
        DXCC_PREF := '';
        EQSL_QSLRDATE := '';
        EQSL_QSLSDATE := '';
        EQSL_QSL_RCVD := '';
        EQSL_QSL_SENT := '';
        FREQ := '';
        FREQ_RX := '';
        GRIDSQUARE := '';
        IOTA := '';
        ITUZ := '';
        LOTW_QSLRDATE := '';
        LOTW_QSLSDATE := '';
        LOTW_QSL_RCVD := '';
        LOTW_QSL_SENT := '';
        MARKER := '';
        MODE := '';
        MY_GRIDSQUARE := '';
        sNAME := '';
        NOTES := '';
        NoCalcDXCC := '';
        PFX := '';
        PROP_MODE := '';
        QSLMSG := '';
        QSLRDATE := '';
        QSLSDATE := '';
        QSL_RCVD := '';
        QSL_RCVD_VIA := '';
        QSL_SENT := '';
        QSL_SENT_VIA := '';
        QSL_VIA := '';
        QSO_DATE := '';
        QSL_STATUS := '';
        QTH := '';
        RST_RCVD := '';
        RST_SENT := '';
        SAT_MODE := '';
        SAT_NAME := '';
        SRX := '';
        SRX_STRING := '';
        STATE := '';
        STATE1 := '';
        STATE2 := '';
        STATE3 := '';
        STATE4 := '';
        STX := '';
        STX_STRING := '';
        SUBMODE := '';
        TIME_OFF := '';
        TIME_ON := '';
        ValidDX := '';

        Readln(f, s);
        if GuessEncoding(s) <> 'utf8' then
          sNAME := CP1251ToUTF8(s);

        PosEOR := Pos('<EOR>', UpperCase(s));
        if not (PosEOR > 0) then
          Continue;

        BAND := getField(s, 'BAND');
        BAND_RX := getField(s, 'BAND_RX');
        CALL := getField(s, 'CALL');
        COMMENT := getField(s, 'COMMENT');
        CONT := getField(s, 'CONT');
        COUNTRY := getField(s, 'COUNTRY');
        CQZ := getField(s, 'CQZ');
        DXCC := getField(s, 'DXCC');
        DXCC_PREF := getField(s, 'DXCC_PREF');
        EQSL_QSLRDATE := getField(s, 'EQSL_QSLRDATE');
        EQSL_QSLSDATE := getField(s, 'EQSL_QSLSDATE');
        EQSL_QSL_RCVD := getField(s, 'EQSL_QSL_RCVD');
        EQSL_QSL_SENT := getField(s, 'EQSL_QSL_SENT');
        FREQ := getField(s, 'FREQ');
        FREQ_RX := getField(s, 'FREQ_RX');
        GRIDSQUARE := getField(s, 'GRIDSQUARE');
        IOTA := getField(s, 'IOTA');
        ITUZ := getField(s, 'ITUZ');
        LOTW_QSLRDATE := getField(s, 'LOTW_QSLRDATE');
        LOTW_QSLSDATE := getField(s, 'LOTW_QSLSDATE');
        LOTW_QSL_RCVD := getField(s, 'LOTW_QSL_RCVD');
        LOTW_QSL_SENT := getField(s, 'LOTW_QSL_SENT');
        MARKER := getField(s, 'MARKER');
        MODE := getField(s, 'MODE');
        MY_GRIDSQUARE := getField(s, 'MY_GRIDSQUARE');
        sNAME := getField(s, 'NAME');
        NOTES := getField(s, 'NOTES');
        NoCalcDXCC := getField(s, 'NoCalcDXCC');
        PFX := getField(s, 'PFX');
        PROP_MODE := getField(s, 'PROP_MODE');
        QSLMSG := getField(s, 'QSLMSG');
        QSLRDATE := getField(s, 'QSLRDATE');
        QSLSDATE := getField(s, 'QSLSDATE');
        QSL_RCVD := getField(s, 'QSL_RCVD');
        QSL_RCVD_VIA := getField(s, 'QSL_RCVD_VIA');
        QSL_SENT := getField(s, 'QSL_SENT');
        QSL_SENT_VIA := getField(s, 'QSL_SENT_VIA');
        QSL_VIA := getField(s, 'QSL_VIA');
        QSO_DATE := getField(s, 'QSO_DATE');
        QSL_STATUS := getField(s, 'QSL_STATUS');
        QTH := getField(s, 'QTH');
        RST_RCVD := getField(s, 'RST_RCVD');
        RST_SENT := getField(s, 'RST_SENT');
        SAT_MODE := getField(s, 'SAT_MODE');
        SAT_NAME := getField(s, 'SAT_NAME');
        SRX := getField(s, 'SRX');
        SRX_STRING := getField(s, 'SRX_STRING');
        STATE := getField(s, 'STATE');
        STATE1 := getField(s, 'STATE1');
        STATE2 := getField(s, 'STATE2');
        STATE3 := getField(s, 'STATE3');
        STATE4 := getField(s, 'STATE4');
        STX := getField(s, 'STX');
        STX_STRING := getField(s, 'STX_STRING');
        SUBMODE := getField(s, 'SUBMODE');
        TIME_OFF := getField(s, 'TIME_OFF');
        TIME_ON := getField(s, 'TIME_ON');
        ValidDX := getField(s, 'ValidDX');

        if PosEOR > 0 then
        begin

          if Length(Memo1.Text) > 0 then
            COMMENT := Memo1.Text;

          if (TIME_ON <> '') then
            TIME_ON := TIME_ON[1] + TIME_ON[2] + ':' + TIME_ON[3] + TIME_ON[4];
          if (TIME_OFF <> '') then
            TIME_OFF := TIME_OFF[1] + TIME_OFF[2] + ':' + TIME_OFF[3] + TIME_OFF[4];

          if ((MODE = 'CW') and (RST_SENT = '')) then
            RST_SENT := '599';
          if ((MODE = 'CW') and (RST_RCVD = '')) then
            RST_RCVD := '599';
          if (MODE = 'USB') or (MODE = 'LSB') then
            MODE := 'SSB';

          if FREQ = '' then
            FREQ := dmFunc.FreqFromBand(BAND, MODE);
          FREQ := FormatFloat('0.000"."00', StrToFloat(FREQ));
          BAND := FloatToStr(dmFunc.GetDigiBandFromFreq(FREQ));

          yyyy := StrToInt(QSO_DATE[1] + QSO_DATE[2] + QSO_DATE[3] +
            QSO_DATE[4]);
          mm := StrToInt(QSO_DATE[5] + QSO_DATE[6]);
          dd := StrToInt(QSO_DATE[7] + QSO_DATE[8]);

          if RadioButton1.Checked = True then
            QSOTIME := TIME_OFF;
          if RadioButton2.Checked = True then
            QSOTIME := TIME_ON;

    {  if not dmFunc.IsAdifOK(QSO_DATE, QSOTIME, QSOTIME, CALL, FREQ,
        MODE, RST_SENT, RST_RCVD, IOTA, ITUZ, CQZ, GRIDSQUARE, MY_GRIDSQUARE, BAND) then
      begin
        Inc(err);
        lblErrors.Caption :=
          rImportErrors + ' ' + IntToStr(err);
        lblErrorLog.Caption :=
          rFileError + PathMyDoc + ERR_FILE;
        Repaint;
        Application.ProcessMessages;
        WriteWrongADIF(Lines);
        Len := 0;
        SetLength(Lines, 0);
        Continue;
      end;}

          if MainForm.MySQLLOGDBConnection.Connected then
            paramQSODate := dmFunc.ADIFDateToDate(QSO_DATE)
          else
            paramQSODate := FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd)));

          if QSL_SENT = 'Y' then
          begin
            paramQSLSent := '1';
            paramQSLSentAdv := 'T';
          end;

          if QSL_SENT = 'Q' then
          begin
            paramQSLSent := '0';
            paramQSLSentAdv := 'Q';
          end;

          if QSL_SENT = 'N' then
          begin
            paramQSLSent := '0';
            paramQSLSentAdv := 'F';
          end;

          if (QSL_SENT = '') and (QSL_STATUS = '') then
          begin
            paramQSLSent := '0';
            paramQSLSentAdv := 'F';
          end;

          if QSL_STATUS <> '' then
            paramQSLSentAdv := QSL_STATUS;

          if QSLSDATE <> '' then
          begin
            yyyy := StrToInt(QSLSDATE[1] + QSLSDATE[2] + QSLSDATE[3] +
              QSLSDATE[4]);
            mm := StrToInt(QSLSDATE[5] + QSLSDATE[6]);
            dd := StrToInt(QSLSDATE[7] + QSLSDATE[8]);
            if MainForm.MySQLLOGDBConnection.Connected then
              paramQSLSDATE := dmFunc.ADIFDateToDate(QSLSDATE)
            else
              paramQSLSDATE :=
                FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd)));
            paramQSLSent := '1';
            paramQSLSentAdv := 'T';
          end
          else
            paramQSLSDATE := 'NULL';

          if QSL_RCVD = 'Y' then
            paramQSL_RCVD := '1';
          if QSL_RCVD = 'N' then
            ParamQSL_RCVD := '0';

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
            paramQSL_RCVD := '1';
          end
          else
            paramQSLRDATE := 'NULL';

          if MARKER = 'Y' then
            paramMARKER := '1'
          else
            paramMARKER := '0';

          if EQSL_QSL_RCVD = 'Y' then
            paramEQSL_QSL_RCVD := '1'
          else
            paramEQSL_QSL_RCVD := '0';

          if (LOTW_QSL_RCVD = 'L') or (LOTW_QSL_RCVD = 'Y') then
            paramLOTW_QSL_RCVD := '1'
          else
            paramLOTW_QSL_RCVD := '0';


          if LOTW_QSLRDATE <> '' then
          begin
            yyyy := StrToInt(LOTW_QSLRDATE[1] + LOTW_QSLRDATE[2] +
              LOTW_QSLRDATE[3] + LOTW_QSLRDATE[4]);
            mm := StrToInt(LOTW_QSLRDATE[5] + LOTW_QSLRDATE[6]);
            dd := StrToInt(LOTW_QSLRDATE[7] + LOTW_QSLRDATE[8]);
            if MainForm.MySQLLOGDBConnection.Connected then
              paramLOTW_QSLRDATE := dmFunc.ADIFDateToDate(LOTW_QSLRDATE)
            else
              paramLOTW_QSLRDATE :=
                FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd)));
            paramLOTW_QSL_RCVD := '1';
          end
          else
            paramLOTW_QSLRDATE := 'NULL';

          if ValidDX = 'N' then
            paramValidDX := '0'
          else
            paramValidDX := '1';

          if LOTW_QSL_SENT = 'Y' then
            paramLOTW_QSL_SENT := '1';

          if (LOTW_QSL_SENT = 'N') or (LOTW_QSL_SENT = '') then
            paramLOTW_QSL_SENT := '0';

          if NoCalcDXCC = 'Y' then
            paramNoCalcDXCC := '1'
          else
            paramNoCalcDXCC := '0';

          if SRX = '' then
            SRX := 'NULL';
          if STX = '' then
            STX := 'NULL';

          Query := 'INSERT INTO ' + LogTable + ' (' +
            'CallSign, QSODate, QSOTime, QSOBand, QSOMode, QSOReportSent,' +
            'QSOReportRecived, OMName, OMQTH, State, Grid, IOTA, QSLManager, QSLSent,' +
            'QSLSentAdv, QSLSentDate, QSLRec, QSLRecDate, MainPrefix, DXCCPrefix,' +
            'CQZone, ITUZone, QSOAddInfo, Marker, ManualSet, DigiBand, Continent,'
            +
            'ShortNote, QSLReceQSLcc, LoTWRec, LoTWRecDate, QSLInfo, `Call`, State1, State2, '
            + 'State3, State4, WPX, AwardsEx, ValidDX, SRX, SRX_STRING, STX, STX_STRING, SAT_NAME,'
            + 'SAT_MODE, PROP_MODE, LoTWSent, QSL_RCVD_VIA, QSL_SENT_VIA, DXCC,'
            + 'NoCalcDXCC) VALUES (' + Q(CALL) + Q(paramQSODate) +
            Q(QSOTIME) + Q(FREQ) + Q(MODE) + Q(RST_SENT) + Q(RST_RCVD) +
            Q(sNAME) + Q(QTH) + Q(STATE) + Q(GRIDSQUARE) + Q(IOTA) +
            Q(QSL_VIA) + Q(paramQSLSent) + Q(paramQSLSentAdv) +
            Q(paramQSLSDATE) + Q(ParamQSL_RCVD) + Q(paramQSLRDATE) +
            Q(PFX) + Q(DXCC_PREF) + Q(CQZ) + Q(ITUZ) + Q(COMMENT) +
            Q(paramMARKER) + Q('0') + Q(BAND) + Q(CONT) + Q(COMMENT) +
            Q(paramEQSL_QSL_RCVD) + Q(paramLOTW_QSL_RCVD) +
            Q(paramLOTW_QSLRDATE) + Q(QSLMSG) + Q(dmFunc.ExtractCallsign(CALL)) +
            Q(STATE1) + Q(STATE2) + Q(STATE3) + Q(STATE4) +
            Q(dmFunc.ExtractWPXPrefix(CALL)) + Q('Awards') + Q(paramValidDX) +
            Q(SRX) + Q(SRX_STRING) + Q(STX) + Q(STX_STRING) + Q(SAT_NAME) +
            Q(SAT_MODE) + Q(PROP_MODE) + Q(paramLOTW_QSL_SENT) +
            Q(QSL_RCVD_VIA) + Q(QSL_SENT_VIA) + Q(DXCC) +
            QuotedStr(paramNoCalcDXCC) + ')';

          if MainForm.MySQLLOGDBConnection.Connected then
            MainForm.MySQLLOGDBConnection.ExecuteDirect(Query)
          else
            MainForm.SQLiteDBConnection.ExecuteDirect(Query);
        end;

        Inc(RecCount);
        if RecCount mod 1000 = 0 then
        begin
          lblCount.Caption := rImportRecord + ' ' + IntToStr(RecCount);
          Application.ProcessMessages;
        end;

      except
        on E: ESQLDatabaseError do
        begin
          // WriteLn(IntToStr(E.ErrorCode) + ' : ' + E.Message);
          if (E.ErrorCode = 1062) or (E.ErrorCode = 2067) then
          begin
            Inc(DupeCount);
            if DupeCount mod 100 = 0 then
            begin
              Label2.Caption := rNumberDup + ':' + IntToStr(DupeCount);
              Application.ProcessMessages;
            end;
            Label2.Caption := rNumberDup + ':' + IntToStr(DupeCount);
          end;
          if E.ErrorCode = 1366 then
          begin
            Inc(ErrorCount);
            if ErrorCount mod 100 = 0 then
            begin
              lblErrors.Caption := rImportErrors + ':' + IntToStr(ErrorCount);
              Application.ProcessMessages;
            end;
            WriteWrongADIF(s);
          end;
        end;
      end;
    end;
  finally
    lblCount.Caption := rImportRecord + ' ' + IntToStr(RecCount);
    MainForm.SQLTransaction1.Commit;
    lblComplete.Caption := rDone;
    Button1.Enabled := True;
    CloseFile(f);
    MainForm.SelDB(CallLogBook);
  end;

end;

procedure TImportADIFForm.WriteWrongADIF(Lines: array of string);
var
  f: TextFile;
  i: integer;
  PathMyDoc: string;
begin
   {$IFDEF UNIX}
  PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
    {$ELSE}
  PathMyDoc := GetEnvironmentVariable('SystemDrive') +
    GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
    {$ENDIF UNIX}


  if FileExists(PathMyDoc + ERR_FILE) then
  begin
    AssignFile(f, PathMyDoc + ERR_FILE);
    Append(f);
    for i := 0 to Length(Lines) - 1 do
      WriteLn(f, Lines[i]);
    writeln(f);
    CloseFile(f);
  end
  else
  begin
    AssignFile(f, PathMyDoc + ERR_FILE);
    Rewrite(f);
    for i := 0 to Length(Lines) - 1 do
      WriteLn(f, Lines[i]);
    writeln(f);
    CloseFile(f);
  end;
  lblErrorLog.Caption := rFileError + ERR_FILE;
  lblErrorLog.Font.Color := clBlue;
  lblErrorLog.Cursor := crHandPoint;
end;



procedure TImportADIFForm.Button2Click(Sender: TObject);
begin
  ImportADIFForm.Close;
end;

procedure TImportADIFForm.FileNameEdit1ButtonClick(Sender: TObject);
begin
  FileNameEdit1.InitialDir := Inif.ReadString('SetLog', 'ImportPath', '');
end;

procedure TImportADIFForm.FileNameEdit1Change(Sender: TObject);
begin
  IniF.WriteString('SetLog', 'ImportPath', ExtractFilePath(FileNameEdit1.FileName));
end;

procedure TImportADIFForm.FormCreate(Sender: TObject);
begin
end;

procedure TImportADIFForm.FormShow(Sender: TObject);
begin
  if MainForm.MySQLLOGDBConnection.Connected then begin
    MainForm.SQLTransaction1.DataBase := MainForm.MySQLLOGDBConnection;
  end
  else begin
    MainForm.SQLTransaction1.DataBase := MainForm.SQLiteDBConnection;
  end;

  Button1.Enabled := True;
  Button1.Caption := rImport;
  FileNameEdit1.Text := '';
  Memo1.Clear;
  Label2.Caption := rNumberDup + ' ';
  lblCount.Caption := rImportRecord + ' ';
  lblErrors.Caption := rImportErrors + ' ';
  lblErrorLog.Caption := rFileError;

end;

procedure TImportADIFForm.lblErrorLogClick(Sender: TObject);
var
  PathMyDoc: string;
begin
 {$IFDEF UNIX}
  PathMyDoc := GetEnvironmentVariable('HOME') + '/EWLog/';
  {$ELSE}
  PathMyDoc := GetEnvironmentVariable('SystemDrive') +
    GetEnvironmentVariable('HOMEPATH') + '\EWLog\';
  {$ENDIF UNIX}
  OpenDocument(PathMyDoc + ERR_FILE);

end;

procedure TImportADIFForm.Button1Click(Sender: TObject);
begin
  if FileNameEdit1.Text = '' then
  begin
    ShowMessage(rNothingImport);
  end
  else
  begin
    if Button1.Caption <> rDone then
    begin
      DeleteFile(dmFunc.DataDir + ERR_FILE);
      lblComplete.Caption := rProcessing;
      ADIFImport(SysToUTF8(FileNameEdit1.Text));
    end
    else
      ImportADIFForm.Close;
  end;
end;



end.
