unit ImportADIFForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, EditBtn, LCLType, LConvEncoding, LazUTF8, LCLIntf,
  dateutils, resourcestr, LCLProc;

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
    procedure FormShow(Sender: TObject);
    procedure lblErrorLogClick(Sender: TObject);
  private
    procedure WriteWrongADIF(Lines: array of string);
    { private declarations }
  public
    procedure ADIFImport(path: string; mobile: Boolean);
    { public declarations }
  end;

var
  ImportADIFForm: TImportADIFForm;

implementation

uses dmFunc_U, MainForm_U, const_u, InitDB_dm;

{$R *.lfm}

{ TImportADIFForm }

procedure SearchPrefix(CallName: string;
  var MainPrefix, DXCCPrefix, CQZone, ITUZone, Continent, DXCC: string);
var
  i, j: integer;
  BoolPrefix: boolean;
begin
  if CallName.Length < 1 then
  begin
    exit;
  end;
  BoolPrefix := False;

 { for i := 0 to PrefixProvinceCount do
  begin
    if (MainForm.PrefixExpProvinceArray[i].reg.Exec(CallName)) and
      (MainForm.PrefixExpProvinceArray[i].reg.Match[0] = CallName) then
    begin
      BoolPrefix := True;
      with MainForm.PrefixQuery do
      begin
        Close;
        SQL.Clear;
        SQL.Add('select * from Province where _id = "' +
          IntToStr(MainForm.PrefixExpProvinceArray[i].id) + '"');
        Open;
      end;
      Continent := MainForm.PrefixQuery.FieldByName('Continent').AsString;
      CQZone := MainForm.PrefixQuery.FieldByName('CQZone').AsString;
      ITUZone := MainForm.PrefixQuery.FieldByName('ITUZone').AsString;
      MainPrefix := MainForm.PrefixQuery.FieldByName('Prefix').AsString;
      DXCCPrefix := MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
      DXCC := MainForm.PrefixQuery.FieldByName('DXCC').AsString;
      exit;
    end;
  end;
  if BoolPrefix = False then
  begin
    for j := 0 to PrefixARRLCount do
    begin
      if (MainForm.PrefixExpARRLArray[j].reg.Exec(CallName)) and
        (MainForm.PrefixExpARRLArray[j].reg.Match[0] = CallName) then
      begin
        with MainForm.PrefixQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('select * from CountryDataEx where _id = "' +
            IntToStr(MainForm.PrefixExpARRLArray[j].id) + '"');
          Open;
          if (FieldByName('Status').AsString = 'Deleted') then
          begin
            MainForm.PrefixExpARRLArray[j].reg.ExecNext;
            Exit;
          end;
          Continent := MainForm.PrefixQuery.FieldByName('Continent').AsString;
          CQZone := MainForm.PrefixQuery.FieldByName('CQZone').AsString;
          ITUZone := MainForm.PrefixQuery.FieldByName('ITUZone').AsString;
          MainPrefix := MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
          DXCCPrefix := MainForm.PrefixQuery.FieldByName('ARRLPrefix').AsString;
          DXCC := MainForm.PrefixQuery.FieldByName('DXCC').AsString;
        end;
        Exit;
      end;
    end;
  end;  }
end;

procedure CheckMode(modulation, Freq: string; var ResSubMode, ResMode: string);
begin
  Delete(Freq, length(Freq) - 2, 1);
  case modulation of
    'BPSK31':
    begin
      ResMode := 'PSK';
      ResSubMode := 'PSK31';
    end;
    'BPSK62':
    begin
      ResMode := 'PSK';
      ResSubMode := 'PSK62';
    end;
    'BPSK63':
    begin
      ResMode := 'PSK';
      ResSubMode := 'PSK63';
    end;
    'BPSK125':
    begin
      ResMode := 'PSK';
      ResSubMode := 'PSK125';
    end;
    'MFSK16':
    begin
      ResMode := 'MFSK';
      ResSubMode := 'MFSK16';
    end;
    'PSK31':
    begin
      ResMode := 'PSK';
      ResSubMode := 'PSK31';
    end;
    'PSK63':
    begin
      ResMode := 'PSK';
      ResSubMode := 'PSK63';
    end;
    'PSK125':
    begin
      ResMode := 'PSK';
      ResSubMode := 'PSK125';
    end;
    'LSB':
    begin
      ResMode := 'SSB';
      ResSubMode := 'LSB';
    end;
    'USB':
    begin
      ResMode := 'SSB';
      ResSubMode := 'USB';
    end;
     'SSB':
    begin
      ResMode := 'SSB';
      if StrToDouble(Freq) >= 10 then
      ResSubMode := 'USB' else
      ResSubMode := 'LSB';
    end;
  end;
end;


procedure TImportADIFForm.ADIFImport(path: string; mobile:Boolean);
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
  FREQ_Float: double;
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
  MY_STATE: string;
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
  MY_LAT: string;
  MY_LON: string;
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
  TempQuery: string;
  Stream: TMemoryStream;
  TempFile: string;
  temp_f: TextFile;
begin
   {$IFDEF UNIX}
  TempFile := GetEnvironmentVariable('HOME') + DirectorySeparator +
    'EWLog' + DirectorySeparator + 'temp.adi';
  {$ELSE}
  TempFile := GetEnvironmentVariable('SystemDrive') +
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + DirectorySeparator +
    'EWLog' + DirectorySeparator + 'temp.adi';
  {$ENDIF UNIX}

  Button1.Enabled:=False;
  if MainForm.MySQLLOGDBConnection.Connected then
  begin
    MainForm.MySQLLOGDBConnection.ExecuteDirect('SET autocommit = 0');
    MainForm.MySQLLOGDBConnection.ExecuteDirect('BEGIN');
  end;

  RecCount := 0;
  DupeCount := 0;
  ErrorCount := 0;
  PosEOH := 0;
  PosEOR := 0;
  try
    Stream := TMemoryStream.Create;
    AssignFile(f, path);
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
        FREQ_Float := 0;
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
        MY_STATE := '';
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
        MY_LAT := '';
        MY_LON := '';
        TempQuery := '';

        Readln(temp_f, s);
        if GuessEncoding(s) <> 'utf8' then
          sNAME := CP1251ToUTF8(s);

        PosEOR := Pos('<EOR>', UpperCase(s));
        if not (PosEOR > 0) then
          Continue;

        BAND := dmFunc.getField(s, 'BAND');
        BAND_RX := dmFunc.getField(s, 'BAND_RX');
        CALL := dmFunc.getField(s, 'CALL');
        COMMENT := dmFunc.getField(s, 'COMMENT');
        CONT := dmFunc.getField(s, 'CONT');
        COUNTRY := dmFunc.getField(s, 'COUNTRY');
        CQZ := dmFunc.getField(s, 'CQZ');
        DXCC := dmFunc.getField(s, 'DXCC');
        DXCC_PREF := dmFunc.getField(s, 'DXCC_PREF');
        EQSL_QSLRDATE := dmFunc.getField(s, 'EQSL_QSLRDATE');
        EQSL_QSLSDATE := dmFunc.getField(s, 'EQSL_QSLSDATE');
        EQSL_QSL_RCVD := dmFunc.getField(s, 'EQSL_QSL_RCVD');
        EQSL_QSL_SENT := dmFunc.getField(s, 'EQSL_QSL_SENT');
        FREQ := dmFunc.getField(s, 'FREQ');
        FREQ_RX := dmFunc.getField(s, 'FREQ_RX');
        GRIDSQUARE := dmFunc.getField(s, 'GRIDSQUARE');
        IOTA := dmFunc.getField(s, 'IOTA');
        ITUZ := dmFunc.getField(s, 'ITUZ');
        LOTW_QSLRDATE := dmFunc.getField(s, 'LOTW_QSLRDATE');
        LOTW_QSLSDATE := dmFunc.getField(s, 'LOTW_QSLSDATE');
        LOTW_QSL_RCVD := dmFunc.getField(s, 'LOTW_QSL_RCVD');
        LOTW_QSL_SENT := dmFunc.getField(s, 'LOTW_QSL_SENT');
        MARKER := dmFunc.getField(s, 'MARKER');
        MODE := dmFunc.getField(s, 'MODE');
        MY_GRIDSQUARE := dmFunc.getField(s, 'MY_GRIDSQUARE');
        MY_STATE := dmFunc.getField(s, 'MY_STATE');
        sNAME := dmFunc.getField(s, 'NAME');
        NOTES := dmFunc.getField(s, 'NOTES');
        NoCalcDXCC := dmFunc.getField(s, 'NoCalcDXCC');
        PFX := dmFunc.getField(s, 'PFX');
        PROP_MODE := dmFunc.getField(s, 'PROP_MODE');
        QSLMSG := dmFunc.getField(s, 'QSLMSG');
        QSLRDATE := dmFunc.getField(s, 'QSLRDATE');
        QSLSDATE := dmFunc.getField(s, 'QSLSDATE');
        QSL_RCVD := dmFunc.getField(s, 'QSL_RCVD');
        QSL_RCVD_VIA := dmFunc.getField(s, 'QSL_RCVD_VIA');
        QSL_SENT := dmFunc.getField(s, 'QSL_SENT');
        QSL_SENT_VIA := dmFunc.getField(s, 'QSL_SENT_VIA');
        QSL_VIA := dmFunc.getField(s, 'QSL_VIA');
        QSO_DATE := dmFunc.getField(s, 'QSO_DATE');
        QSL_STATUS := dmFunc.getField(s, 'QSL_STATUS');
        QTH := dmFunc.getField(s, 'QTH');
        RST_RCVD := dmFunc.getField(s, 'RST_RCVD');
        RST_SENT := dmFunc.getField(s, 'RST_SENT');
        SAT_MODE := dmFunc.getField(s, 'SAT_MODE');
        SAT_NAME := dmFunc.getField(s, 'SAT_NAME');
        SRX := dmFunc.getField(s, 'SRX');
        SRX_STRING := dmFunc.getField(s, 'SRX_STRING');
        STATE := dmFunc.getField(s, 'STATE');
        STATE1 := dmFunc.getField(s, 'STATE1');
        STATE2 := dmFunc.getField(s, 'STATE2');
        STATE3 := dmFunc.getField(s, 'STATE3');
        STATE4 := dmFunc.getField(s, 'STATE4');
        STX := dmFunc.getField(s, 'STX');
        STX_STRING := dmFunc.getField(s, 'STX_STRING');
        SUBMODE := dmFunc.getField(s, 'SUBMODE');
        TIME_OFF := dmFunc.getField(s, 'TIME_OFF');
        TIME_ON := dmFunc.getField(s, 'TIME_ON');
        ValidDX := dmFunc.getField(s, 'ValidDX');
        MY_LAT := dmFunc.getField(s, 'MY_LAT');
        MY_LON := dmFunc.getField(s, 'MY_LON');

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

          if FREQ = '' then
            FREQ := FormatFloat(view_freq, dmFunc.GetFreqFromBand(BAND, MODE))
          else begin
            FREQ_Float := StrToFloat(FREQ);
            FREQ := FormatFloat(view_freq, FREQ_Float);
          end;


          CheckMode(MODE, FREQ, SUBMODE, MODE);

          if FREQ_Float = 0 then
          BAND := FloatToStr(dmFunc.GetDigiBandFromFreq(FREQ))
          else
          BAND := FloatToStr(dmFunc.GetDigiBandFromFreq(FloatToStr(FREQ_Float)));

          yyyy := StrToInt(QSO_DATE[1] + QSO_DATE[2] + QSO_DATE[3] +
            QSO_DATE[4]);
          mm := StrToInt(QSO_DATE[5] + QSO_DATE[6]);
          dd := StrToInt(QSO_DATE[7] + QSO_DATE[8]);

          if RadioButton1.Checked = True then
            QSOTIME := TIME_OFF;
          if RadioButton2.Checked = True then
            QSOTIME := TIME_ON;

          if (QSOTIME = '') and (TIME_OFF = '') then
            QSOTIME := TIME_ON;

          if (QSOTIME = '') and (TIME_ON = '') then
            QSOTIME := TIME_OFF;

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
          if (QSL_RCVD = 'N') or (QSL_RCVD = '') then
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

          if CheckBox1.Checked then
            SearchPrefix(CALL, PFX, DXCC_PREF, CQZ, ITUZ, CONT, DXCC);

          if GuessEncoding(sNAME) <> 'utf8' then
            sNAME := CP1251ToUTF8(sNAME);
          if GuessEncoding(QTH) <> 'utf8' then
            QTH := CP1251ToUTF8(QTH);
          if GuessEncoding(COMMENT) <> 'utf8' then
            COMMENT := CP1251ToUTF8(COMMENT);

          if mobile = False then begin
          Query := 'INSERT INTO ' + LBRecord.LogTable + ' (' +
            'CallSign, QSODate, QSOTime, QSOBand, QSOMode, QSOSubMode, QSOReportSent,' +
            'QSOReportRecived, OMName, OMQTH, State, Grid, IOTA, QSLManager, QSLSent,' +
            'QSLSentAdv, QSLSentDate, QSLRec, QSLRecDate, MainPrefix, DXCCPrefix,' +
            'CQZone, ITUZone, QSOAddInfo, Marker, ManualSet, DigiBand, Continent,' +
            'ShortNote, QSLReceQSLcc, LoTWRec, LoTWRecDate, QSLInfo, `Call`, State1, State2, '
            + 'State3, State4, WPX, AwardsEx, ValidDX, SRX, SRX_STRING, STX, STX_STRING, SAT_NAME,'
            + 'SAT_MODE, PROP_MODE, LoTWSent, QSL_RCVD_VIA, QSL_SENT_VIA, DXCC,' +
            'NoCalcDXCC, MY_STATE, MY_GRIDSQUARE, MY_LAT, MY_LON, SYNC) VALUES (' +
            dmFunc.Q(CALL) + dmFunc.Q(paramQSODate) + dmFunc.Q(QSOTIME) +
            dmFunc.Q(FREQ) + dmFunc.Q(MODE) + dmFunc.Q(SUBMODE) +
            dmFunc.Q(RST_SENT) + dmFunc.Q(RST_RCVD) + dmFunc.Q(sNAME) +
            dmFunc.Q(QTH) + dmFunc.Q(STATE) + dmFunc.Q(GRIDSQUARE) +
            dmFunc.Q(IOTA) + dmFunc.Q(QSL_VIA) + dmFunc.Q(paramQSLSent) +
            dmFunc.Q(paramQSLSentAdv) + dmFunc.Q(paramQSLSDATE) +
            dmFunc.Q(ParamQSL_RCVD) + dmFunc.Q(paramQSLRDATE) +
            dmFunc.Q(PFX) + dmFunc.Q(DXCC_PREF) + dmFunc.Q(CQZ) +
            dmFunc.Q(ITUZ) + dmFunc.Q(COMMENT) + dmFunc.Q(paramMARKER) +
            dmFunc.Q('0') + dmFunc.Q(BAND) + dmFunc.Q(CONT) +
            dmFunc.Q(COMMENT) + dmFunc.Q(paramEQSL_QSL_RCVD) +
            dmFunc.Q(paramLOTW_QSL_RCVD) + dmFunc.Q(paramLOTW_QSLRDATE) +
            dmFunc.Q(QSLMSG) + dmFunc.Q(dmFunc.ExtractCallsign(CALL)) +
            dmFunc.Q(STATE1) + dmFunc.Q(STATE2) + dmFunc.Q(STATE3) +
            dmFunc.Q(STATE4) + dmFunc.Q(dmFunc.ExtractWPXPrefix(CALL)) +
            dmFunc.Q('') + dmFunc.Q(paramValidDX) + dmFunc.Q(SRX) +
            dmFunc.Q(SRX_STRING) + dmFunc.Q(STX) + dmFunc.Q(STX_STRING) +
            dmFunc.Q(SAT_NAME) + dmFunc.Q(SAT_MODE) + dmFunc.Q(PROP_MODE) +
            dmFunc.Q(paramLOTW_QSL_SENT) + dmFunc.Q(QSL_RCVD_VIA) +
            dmFunc.Q(QSL_SENT_VIA) + dmFunc.Q(DXCC) + dmFunc.Q(paramNoCalcDXCC) +
            dmFunc.Q(MY_STATE) + dmFunc.Q(MY_GRIDSQUARE) + dmFunc.Q(MY_LAT) +
            dmFunc.Q(MY_LON) + QuotedStr('0') +')';
            end
            else begin
            TempQuery := 'INSERT INTO ' + LBRecord.LogTable + ' (' +
            'CallSign, QSODate, QSOTime, QSOBand, QSOMode, QSOSubMode, QSOReportSent,' +
            'QSOReportRecived, OMName, OMQTH, State, Grid, IOTA, QSLManager, QSLSent,' +
            'QSLSentAdv, QSLSentDate, QSLRec, QSLRecDate, MainPrefix, DXCCPrefix,' +
            'CQZone, ITUZone, QSOAddInfo, Marker, ManualSet, DigiBand, Continent,' +
            'ShortNote, QSLReceQSLcc, LoTWRec, LoTWRecDate, QSLInfo, `Call`, State1, State2, '
            + 'State3, State4, WPX, AwardsEx, ValidDX, SRX, SRX_STRING, STX, STX_STRING, SAT_NAME,'
            + 'SAT_MODE, PROP_MODE, LoTWSent, QSL_RCVD_VIA, QSL_SENT_VIA, DXCC,' +
            'NoCalcDXCC, MY_STATE, MY_GRIDSQUARE, MY_LAT, MY_LON, SYNC) VALUES (' +
            dmFunc.Q(CALL) + dmFunc.Q(paramQSODate) + dmFunc.Q(QSOTIME) +
            dmFunc.Q(FREQ) + dmFunc.Q(MODE) + dmFunc.Q(SUBMODE) +
            dmFunc.Q(RST_SENT) + dmFunc.Q(RST_RCVD) + dmFunc.Q(sNAME) +
            dmFunc.Q(QTH) + dmFunc.Q(STATE) + dmFunc.Q(GRIDSQUARE) +
            dmFunc.Q(IOTA) + dmFunc.Q(QSL_VIA) + dmFunc.Q(paramQSLSent) +
            dmFunc.Q(paramQSLSentAdv) + dmFunc.Q(paramQSLSDATE) +
            dmFunc.Q(ParamQSL_RCVD) + dmFunc.Q(paramQSLRDATE) +
            dmFunc.Q(PFX) + dmFunc.Q(DXCC_PREF) + dmFunc.Q(CQZ) +
            dmFunc.Q(ITUZ) + dmFunc.Q(COMMENT) + dmFunc.Q(paramMARKER) +
            dmFunc.Q('0') + dmFunc.Q(BAND) + dmFunc.Q(CONT) +
            dmFunc.Q(COMMENT) + dmFunc.Q(paramEQSL_QSL_RCVD) +
            dmFunc.Q(paramLOTW_QSL_RCVD) + dmFunc.Q(paramLOTW_QSLRDATE) +
            dmFunc.Q(QSLMSG) + dmFunc.Q(dmFunc.ExtractCallsign(CALL)) +
            dmFunc.Q(STATE1) + dmFunc.Q(STATE2) + dmFunc.Q(STATE3) +
            dmFunc.Q(STATE4) + dmFunc.Q(dmFunc.ExtractWPXPrefix(CALL)) +
            dmFunc.Q('') + dmFunc.Q(paramValidDX) + dmFunc.Q(SRX) +
            dmFunc.Q(SRX_STRING) + dmFunc.Q(STX) + dmFunc.Q(STX_STRING) +
            dmFunc.Q(SAT_NAME) + dmFunc.Q(SAT_MODE) + dmFunc.Q(PROP_MODE) +
            dmFunc.Q(paramLOTW_QSL_SENT) + dmFunc.Q(QSL_RCVD_VIA) +
            dmFunc.Q(QSL_SENT_VIA) + dmFunc.Q(DXCC) + dmFunc.Q(paramNoCalcDXCC) +
            dmFunc.Q(MY_STATE) + dmFunc.Q(MY_GRIDSQUARE) + dmFunc.Q(MY_LAT) +
            dmFunc.Q(MY_LON) + QuotedStr('1');

            if MainForm.MySQLLOGDBConnection.Connected then
            Query:= TempQuery + ') ON DUPLICATE KEY UPDATE SYNC = 1'
            else
            Query:= TempQuery + ') ON CONFLICT (CallSign, QSODate, QSOTime, QSOBand) DO UPDATE SET SYNC = 1';
            end;

          if MainForm.MySQLLOGDBConnection.Connected then
            MainForm.MySQLLOGDBConnection.ExecuteDirect(Query)
          else
            InitDB.SQLiteConnection.ExecuteDirect(Query);

        end;

        Inc(RecCount);
        if RecCount mod 1000 = 0 then
        begin
          lblCount.Caption := rImportRecord + ' ' + IntToStr(RecCount);
          if MainForm.MySQLLOGDBConnection.Connected then
          MainForm.SQLTransaction1.Commit;

          Application.ProcessMessages;
        end;

      except
        on E: ESQLDatabaseError do
        begin
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
    CloseFile(temp_f);
    Stream.Free;
    MainForm.SelDB(CallLogBook);
    Button1.Enabled:=True;
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
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
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
  FileNameEdit1.InitialDir := INIFile.ReadString('SetLog', 'ImportPath', '');
end;

procedure TImportADIFForm.FileNameEdit1Change(Sender: TObject);
begin
  if Length(ExtractFilePath(FileNameEdit1.FileName)) > 0 then
  INIFile.WriteString('SetLog', 'ImportPath', ExtractFilePath(FileNameEdit1.FileName));
end;

procedure TImportADIFForm.FormShow(Sender: TObject);
begin
  if MainForm.MySQLLOGDBConnection.Connected then
  begin
    MainForm.SQLTransaction1.DataBase := MainForm.MySQLLOGDBConnection;
  end
  else
  begin
    MainForm.SQLTransaction1.DataBase := InitDB.SQLiteConnection;
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
    SysToUTF8(GetEnvironmentVariable('HOMEPATH')) + '\EWLog\';
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
      ADIFImport(SysToUTF8(FileNameEdit1.Text), False);
    end
    else
      ImportADIFForm.Close;
  end;
end;



end.
