unit ImportADIFForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, EditBtn, LCLType, LConvEncoding, LazUTF8, LCLIntf;

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
    ImportQuery: TSQLQuery;
    DUPEQuery: TSQLQuery;
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
  if field = 'VALIDDX' then field:='ValidDX';
  if field = 'NOCALCDXCC' then field:='NoCalcDXCC';
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

procedure TImportADIFForm.ADIFImport(path: string);
var
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
  errr: integer;
  yyyy, mm, dd, RecCount: word;
begin
  RecCount := 0;
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
          if GuessEncoding(sNAME) <> 'utf8' then
            sNAME := CP1251ToUTF8(sNAME);
          if GuessEncoding(QTH) <> 'utf8' then
            QTH := CP1251ToUTF8(QTH);
          if GuessEncoding(COMMENT) <> 'utf8' then
            COMMENT := CP1251ToUTF8(COMMENT);


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

          DUPEQuery.Close;         //Проверка на дубликаты
          DUPEQuery.SQL.Clear;
          if DefaultDB = 'MySQL' then
          begin
            DUPEQuery.SQL.Text :=
              'SELECT COUNT(*) FROM ' + LogTable + ' WHERE QSODate = ' +
              QuotedStr(QSO_DATE) + ' AND QSOTime = ' + QuotedStr(QSOTIME) +
              ' AND CallSign = ' + QuotedStr(CALL);

          end
          else
          begin
            DUPEQuery.SQL.Text :=
              'SELECT COUNT(*) FROM ' + LogTable +
              ' WHERE strftime(''%Y-%m-%d'',QSODate) = ' +
              QuotedStr(QSO_DATE) + ' AND QSOTime = ' + QuotedStr(QSOTIME) +
              ' AND CallSign = ' + QuotedStr(CALL);
          end;
          DUPEQuery.Open;
          if DUPEQuery.Fields.Fields[0].AsInteger > 0 then
          begin
            Inc(errr);
            Label2.Caption :=
              rNumberDup + ' ' + IntToStr(errr);
            Break;
          end
          else                   //Если всё норм -> поехали добавлять)
          begin

            ImportQuery.Close;
            ImportQuery.Params.Clear;
            ImportQuery.SQL.Clear;
            ImportQuery.SQL.Text :=
              'INSERT INTO ' + LogTable + ' (' +
              'CallSign, QSODate, QSOTime, QSOBand, QSOMode, QSOReportSent,' +
              'QSOReportRecived, OMName, OMQTH, State, Grid, IOTA, QSLManager, QSLSent,' +
              'QSLSentAdv, QSLSentDate, QSLRec, QSLRecDate, MainPrefix,' +
              'DXCCPrefix, CQZone, ITUZone, QSOAddInfo, Marker, ManualSet, DigiBand, Continent,' +
              'ShortNote, QSLReceQSLcc, LoTWRec, LoTWRecDate, QSLInfo, Call, State1, State2, ' +
              'State3, State4, WPX, AwardsEx, ValidDX, SRX, SRX_STRING, STX, STX_STRING, SAT_NAME,' +
              'SAT_MODE, PROP_MODE, LoTWSent, QSL_RCVD_VIA, QSL_SENT_VIA, DXCC,' +
              'NoCalcDXCC) VALUES (' +
              ':CallSign, :QSODate, :QSOTime, :QSOBand, :QSOMode, :QSOReportSent,' +
              ':QSOReportRecived, :OMName, :OMQTH, :State, :Grid, :IOTA, :QSLManager, :QSLSent,' +
              ':QSLSentAdv, :QSLSentDate, :QSLRec, :QSLRecDate, :MainPrefix,' +
              ':DXCCPrefix, :CQZone, :ITUZone, :QSOAddInfo, :Marker, :ManualSet, :DigiBand, :Continent,' +
              ':ShortNote, :QSLReceQSLcc, :LoTWRec, :LoTWRecDate, :QSLInfo, :Call, :State1,' +
              ':State2, :State3, :State4, :WPX, :AwardsEx, :ValidDX, :SRX, :SRX_STRING, :STX,'+
              ':STX_STRING, :SAT_NAME, :SAT_MODE, :PROP_MODE, :LoTWSent, :QSL_RCVD_VIA,' +
              ':QSL_SENT_VIA, :DXCC,:NoCalcDXCC)';

            ImportQuery.Prepare;
            ImportQuery.Params.ParamByName('CallSign').AsString := CALL;
            if DefaultDB = 'MySQL' then
              ImportQuery.Params.ParamByName('QSODate').AsString := QSO_DATE
            else
              ImportQuery.Params.ParamByName('QSODate').AsDate :=
                EncodeDate(yyyy, mm, dd);
            ImportQuery.Params.ParamByName('QSOTime').AsString := QSOTIME;
            ImportQuery.Params.ParamByName('QSOBand').AsString := FREQ;
            ImportQuery.Params.ParamByName('QSOMode').AsString := MODE;
            ImportQuery.Params.ParamByName('QSOReportSent').AsString := RST_SENT;
            ImportQuery.Params.ParamByName('QSOReportRecived').AsString := RST_RCVD;
            ImportQuery.Params.ParamByName('OMName').AsString := sNAME;
            ImportQuery.Params.ParamByName('OMQTH').AsString := QTH;
            ImportQuery.Params.ParamByName('State').AsString := STATE;
            ImportQuery.Params.ParamByName('Grid').AsString := GRIDSQUARE;
            ImportQuery.Params.ParamByName('IOTA').AsString := IOTA;
            ImportQuery.Params.ParamByName('QSLManager').AsString := QSL_VIA;

            if QSL_SENT = 'Y' then
            begin
              ImportQuery.Params.ParamByName('QSLSent').AsInteger := 1;
              ImportQuery.Params.ParamByName('QSLSentAdv').AsString := 'T';
            end;

            if QSL_SENT = 'Q' then
            begin
              ImportQuery.Params.ParamByName('QSLSent').IsNull;
              ImportQuery.Params.ParamByName('QSLSentAdv').AsString := 'Q';
            end;

            if QSL_SENT = 'N' then
            begin
              ImportQuery.Params.ParamByName('QSLSent').IsNull;
              ImportQuery.Params.ParamByName('QSLSentAdv').AsString := 'F';
            end;

            if (QSL_SENT = '') and (QSL_STATUS = '') then
            begin
              ImportQuery.Params.ParamByName('QSLSent').IsNull;
              ImportQuery.Params.ParamByName('QSLSentAdv').AsString := 'F';
            end;

            if QSL_STATUS <> '' then
              ImportQuery.Params.ParamByName('QSLSentAdv').AsString := QSL_STATUS;

            if QSLSDATE <> '' then
            begin
              yyyy := StrToInt(QSLSDATE[1] + QSLSDATE[2] + QSLSDATE[3] +
                QSLSDATE[4]);
              mm := StrToInt(QSLSDATE[5] + QSLSDATE[6]);
              dd := StrToInt(QSLSDATE[7] + QSLSDATE[8]);

              if DefaultDB = 'MySQL' then
                ImportQuery.Params.ParamByName('QSLSentDate').AsString := QSLSDATE
              else
                ImportQuery.Params.ParamByName('QSLSentDate').AsDate :=
                  EncodeDate(yyyy, mm, dd);
              ImportQuery.Params.ParamByName('QSLSent').AsInteger := 1;
              ImportQuery.Params.ParamByName('QSLSentAdv').AsString := 'T';
            end
            else
              ImportQuery.Params.ParamByName('QSLSentDate').IsNull;

            if QSL_RCVD = 'Y' then
              ImportQuery.Params.ParamByName('QSLRec').AsInteger := 1;
            if QSL_RCVD = 'N' then
              ImportQuery.Params.ParamByName('QSLRec').AsInteger := 0;

            if QSLRDATE <> '' then
            begin
              yyyy := StrToInt(QSLRDATE[1] + QSLRDATE[2] + QSLRDATE[3] +
                QSLRDATE[4]);
              mm := StrToInt(QSLRDATE[5] + QSLRDATE[6]);
              dd := StrToInt(QSLRDATE[7] + QSLRDATE[8]);

              if DefaultDB = 'MySQL' then
                ImportQuery.Params.ParamByName('QSLRecDate').AsString := QSLRDATE
              else
                ImportQuery.Params.ParamByName('QSLRecDate').AsDate :=
                  EncodeDate(yyyy, mm, dd);
              ImportQuery.Params.ParamByName('QSLRec').AsInteger := 1;
            end
            else
              ImportQuery.Params.ParamByName('QSLRecDate').IsNull;

            ImportQuery.Params.ParamByName('MainPrefix').AsString := PFX;
            ImportQuery.Params.ParamByName('DXCCPrefix').AsString := DXCC_PREF;
            ImportQuery.Params.ParamByName('CQZone').AsString := CQZ;
            ImportQuery.Params.ParamByName('ITUZone').AsString := ITUZ;
            ImportQuery.Params.ParamByName('QSOAddInfo').AsString := COMMENT;
            if MARKER = 'Y' then
            ImportQuery.Params.ParamByName('Marker').AsString := '1'
            else
            ImportQuery.Params.ParamByName('Marker').AsString := '0';
            ImportQuery.Params.ParamByName('ManualSet').AsString := '0';
            ImportQuery.Params.ParamByName('DigiBand').AsString := BAND;
            ImportQuery.Params.ParamByName('Continent').AsString := CONT;
            ImportQuery.Params.ParamByName('ShortNote').AsString := COMMENT;

            if EQSL_QSL_RCVD = 'Y' then
              ImportQuery.Params.ParamByName('QSLReceQSLcc').AsString := '1'
            else
              ImportQuery.Params.ParamByName('QSLReceQSLcc').AsString := '0';

            if (LOTW_QSL_RCVD = 'L') or (LOTW_QSL_RCVD = 'Y') then
              ImportQuery.Params.ParamByName('LoTWRec').AsString := '1'
            else
              ImportQuery.Params.ParamByName('LoTWRec').AsString := '0';

            if LOTW_QSLRDATE <> '' then
            begin
              yyyy := StrToInt(LOTW_QSLRDATE[1] + LOTW_QSLRDATE[2] + LOTW_QSLRDATE[3] +
                QSLRDATE[4]);
              mm := StrToInt(LOTW_QSLRDATE[5] + LOTW_QSLRDATE[6]);
              dd := StrToInt(LOTW_QSLRDATE[7] + LOTW_QSLRDATE[8]);

              if DefaultDB = 'MySQL' then
                ImportQuery.Params.ParamByName('LoTWRecDate').AsString := LOTW_QSLRDATE
              else
                ImportQuery.Params.ParamByName('LoTWRecDate').AsDate :=
                  EncodeDate(yyyy, mm, dd);
              ImportQuery.Params.ParamByName('LoTWRec').AsInteger := 1;
            end
            else
              ImportQuery.Params.ParamByName('LoTWRecDate').IsNull;

            ImportQuery.Params.ParamByName('QSLInfo').AsString := QSLMSG;
            ImportQuery.Params.ParamByName('Call').AsString := dmFunc.ExtractCallsign(CALL);
            ImportQuery.Params.ParamByName('State1').AsString := STATE1;
            ImportQuery.Params.ParamByName('State2').AsString := STATE2;
            ImportQuery.Params.ParamByName('State3').AsString := STATE3;
            ImportQuery.Params.ParamByName('State4').AsString := STATE4;
            //WPX
            //   ImportQuery.Params.ParamByName('WPX').AsString := PFX;
            //AwardsEx
            if ValidDX = 'N' then
            ImportQuery.Params.ParamByName('ValidDX').AsString := '0' else
            ImportQuery.Params.ParamByName('ValidDX').AsString := '1';
            ImportQuery.Params.ParamByName('SRX').AsString := SRX;
            ImportQuery.Params.ParamByName('SRX_STRING').AsString := SRX_STRING;
            ImportQuery.Params.ParamByName('STX').AsString := STX;
            ImportQuery.Params.ParamByName('STX_STRING').AsString := STX_STRING;
            ImportQuery.Params.ParamByName('SAT_NAME').AsString := SAT_NAME;
            ImportQuery.Params.ParamByName('SAT_MODE').AsString := SAT_MODE;
            ImportQuery.Params.ParamByName('PROP_MODE').AsString := PROP_MODE;

            if LOTW_QSL_SENT = 'Y' then
              ImportQuery.Params.ParamByName('LoTWSent').AsInteger := 1;
            if LOTW_QSL_SENT = 'N' then
              ImportQuery.Params.ParamByName('LoTWSent').AsInteger := 0;

            ImportQuery.Params.ParamByName('QSL_RCVD_VIA').AsString := QSL_RCVD_VIA;
            ImportQuery.Params.ParamByName('QSL_SENT_VIA').AsString := QSL_SENT_VIA;
            ImportQuery.Params.ParamByName('DXCC').AsString := DXCC;
            if NoCalcDXCC = 'Y' then
            ImportQuery.Params.ParamByName('NoCalcDXCC').AsString := '1'
            else
            ImportQuery.Params.ParamByName('NoCalcDXCC').AsString := '0';

            ImportQuery.ExecSQL;

            Inc(RecCount);
            if RecCount mod 1000 = 0 then
            begin
              lblCount.Caption :=
                rImportRecord + ' ' + IntToStr(RecCount);
              MainForm.SQLTransaction1.Commit;
              Application.ProcessMessages;
            end;
          end;
        end;
      except
      end;
    end;
  finally
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
  if DefaultDB = 'MySQL' then
  begin
    DUPEQuery.DataBase := MainForm.MySQLLOGDBConnection;
    ImportQuery.DataBase := MainForm.MySQLLOGDBConnection;
    MainForm.SQLTransaction1.DataBase := MainForm.MySQLLOGDBConnection;
  end
  else
  begin
    DUPEQuery.DataBase := MainForm.SQLiteDBConnection;
    ImportQuery.DataBase := MainForm.SQLiteDBConnection;
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
