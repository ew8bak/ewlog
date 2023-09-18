(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit ImportADIThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, Forms, LazFileUtils, LCLType,
  DateUtils, prefix_record, LConvEncoding, LCLProc;

type
  TInfo = record
    AllRec: integer;
    RecCount: integer;
    DupeCount: integer;
    ErrorCount: integer;
    Result: boolean;
  end;

type
  TPADIImport = record
    Path: string;
    Comment: string;
    Mobile: boolean;
    TimeOnOff: boolean;
    AllRec: integer;
    SearchPrefix: boolean;
    RemoveDup: boolean;
  end;

type
  TImportADIFThread = class(TThread)
  protected
    procedure Execute; override;
  private
    procedure ADIFImport(PADIImport: TPADIImport);
  public
    PADIImport: TPADIImport;
    Info: TInfo;
    constructor Create;
    procedure ToForm;
  end;

var
  ImportADIFThread: TImportADIFThread;

implementation

uses MainFuncDM, miniform_u, InitDB_dm, dmFunc_U, ImportADIFForm_U;

procedure CheckMode(modulation, Freq: string; var ResSubMode, ResMode: string);
var
  FreqSafeDouble: double;
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
      TryStrToFloatSafe(Freq, FreqSafeDouble);
      if FreqSafeDouble >= 10 then
        ResSubMode := 'USB'
      else
        ResSubMode := 'LSB';
    end;
  end;
end;

procedure WriteWrongADIF(Lines: array of string);
var
  f: TextFile;
  i: integer;
begin
  if FileExists(FilePATH + ERR_FILE) then
  begin
    AssignFile(f, FilePATH + ERR_FILE);
    Append(f);
    for i := 0 to Length(Lines) - 1 do
      WriteLn(f, Lines[i]);
    writeln(f);
    CloseFile(f);
  end
  else
  begin
    AssignFile(f, FilePATH + ERR_FILE);
    Rewrite(f);
    for i := 0 to Length(Lines) - 1 do
      WriteLn(f, Lines[i]);
    writeln(f);
    CloseFile(f);
  end;
end;

function CountLine(MStream: TMemoryStream): integer;
var
  tmp: TStringList;
begin
  Result := 0;
  try
    tmp := TStringList.Create;
    MStream.Position := 0;
    tmp.LoadFromStream(MStream);
    if Pos('DATASYNCCLIENTEND', tmp.Strings[tmp.Count - 1]) > 0 then
      tmp.Delete(tmp.Count - 1);
  finally
    Result := tmp.Count;
    tmp.Free;
  end;
end;

procedure TImportADIFThread.ADIFImport(PADIImport: TPADIImport);
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
  MY_SOTA_REF: string;
  SOTA_REF: string;
  HAMLOGRec: string;
  CLUBLOG_QSO_UPLOAD_DATE: string;
  CLUBLOG_QSO_UPLOAD_STATUS: string;
  HRDLOG_QSO_UPLOAD_DATE: string;
  HRDLOG_QSO_UPLOAD_STATUS: string;
  QRZCOM_QSO_UPLOAD_DATE: string;
  QRZCOM_QSO_UPLOAD_STATUS: string;
  HAMLOGEU_QSO_UPLOAD_DATE: string;
  HAMLOGEU_QSO_UPLOAD_STATUS: string;
  HAMLOGRU_QSO_UPLOAD_DATE: string;
  HAMLOGRU_QSO_UPLOAD_STATUS: string;
  HAMQTH_QSO_UPLOAD_DATE: string;
  HAMQTH_QSO_UPLOAD_STATUS: string;
  PosEOH: word;
  PosEOR: word;
  QSOTIME: string;
  yyyy, mm, dd: word;
  paramQSLSent: string;
  paramQSLSentAdv: string;
  paramQSODate: string;
  paramQSODateTime: string;
  paramQSL_RCVD: string;
  paramMARKER: string;
  paramEQSL_QSL_RCVD: string;
  paramLOTW_QSL_RCVD: string;
  paramValidDX: string;
  paramLOTW_QSL_SENT: string;
  paramNoCalcDXCC: string;
  paramQSLSDATE: string;
  paramQSLRDATE: string;
  paramLOTW_QSLRDATE: string;
  paramHRDLOG_QSO_UPLOAD_STATUS: string;
  paramHRDLOG_QSO_UPLOAD_DATE: string;
  paramHAMQTH_QSO_UPLOAD_STATUS: string;
  paramHAMQTH_QSO_UPLOAD_DATE: string;
  paramCLUBLOG_QSO_UPLOAD_DATE: string;
  paramCLUBLOG_QSO_UPLOAD_STATUS: string;
  paramQRZCOM_QSO_UPLOAD_DATE: string;
  paramQRZCOM_QSO_UPLOAD_STATUS: string;
  paramHAMLOGEU_QSO_UPLOAD_DATE: string;
  paramHAMLOGEU_QSO_UPLOAD_STATUS: string;
  paramHAMLOGRU_QSO_UPLOAD_DATE: string;
  paramHAMLOGRU_QSO_UPLOAD_STATUS: string;

  Query: string;
  TempQuery: string;
  Stream: TMemoryStream;
  TempFile: string;
  temp_f: TextFile;
  PFXR: TPFXR;
begin
  TempFile := FilePATH + 'temp.adi';
  Info.Result := False;
  Info.AllRec := 0;
  if PADIImport.AllRec > 0 then
    Info.AllRec := PADIImport.AllRec;
  Info.ErrorCount := 0;
  Info.RecCount := 0;
  Info.DupeCount := 0;
  PosEOH := 0;
  PosEOR := 0;
  try
    Stream := TMemoryStream.Create;
    AssignFile(f, PADIImport.Path);
    Reset(f);
    while not (PosEOH > 0) do
    begin
      Readln(f, s);
      s := StringReplace(UpperCase(s), '<EH>', '<EOH>', [rfReplaceAll]);
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
    if not PADIImport.Mobile then
      Info.AllRec := CountLine(Stream);
    Stream.SaveToFile(TempFile);

    AssignFile(temp_f, TempFile);
    Reset(temp_f);

    while not (EOF(temp_f)) do
    begin
      try
        paramQSLSent := '';
        paramQSLSentAdv := '';
        paramQSODate := '';
        paramQSODateTime := '';
        paramQSL_RCVD := '';
        paramMARKER := '';
        paramEQSL_QSL_RCVD := '';
        paramLOTW_QSL_RCVD := '';
        paramValidDX := '';
        paramLOTW_QSL_SENT := '';
        paramNoCalcDXCC := '';
        paramQSLSDATE := '';
        paramQSLRDATE := '';
        paramLOTW_QSLRDATE := '';
        paramHRDLOG_QSO_UPLOAD_DATE := '';
        paramHRDLOG_QSO_UPLOAD_STATUS := '';
        paramHAMQTH_QSO_UPLOAD_STATUS := '';
        paramHAMQTH_QSO_UPLOAD_DATE := '';
        paramCLUBLOG_QSO_UPLOAD_DATE := '';
        paramCLUBLOG_QSO_UPLOAD_STATUS := '';
        paramQRZCOM_QSO_UPLOAD_DATE := '';
        paramQRZCOM_QSO_UPLOAD_STATUS := '';
        paramHAMLOGEU_QSO_UPLOAD_DATE := '';
        paramHAMLOGEU_QSO_UPLOAD_STATUS := '';
        paramHAMLOGRU_QSO_UPLOAD_DATE := '';
        paramHAMLOGRU_QSO_UPLOAD_STATUS := '';
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
        MY_SOTA_REF := '';
        SOTA_REF := '';
        HAMLOGRec := '';
        CLUBLOG_QSO_UPLOAD_DATE := '';
        CLUBLOG_QSO_UPLOAD_STATUS := '';
        HRDLOG_QSO_UPLOAD_DATE := '';
        HRDLOG_QSO_UPLOAD_STATUS := '';
        QRZCOM_QSO_UPLOAD_DATE := '';
        QRZCOM_QSO_UPLOAD_STATUS := '';
        HAMLOGEU_QSO_UPLOAD_DATE := '';
        HAMLOGEU_QSO_UPLOAD_STATUS := '';
        HAMLOGRU_QSO_UPLOAD_DATE := '';
        HAMLOGRU_QSO_UPLOAD_STATUS := '';
        HAMQTH_QSO_UPLOAD_DATE := '';
        HAMQTH_QSO_UPLOAD_STATUS := '';
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
        SOTA_REF := dmFunc.getField(s, 'SOTA_REF');
        MY_SOTA_REF := dmFunc.getField(s, 'MY_SOTA_REF');
        HAMLOGRec := dmFunc.getField(s, 'HAMLOGRec');
        CLUBLOG_QSO_UPLOAD_DATE := dmFunc.getField(s, 'CLUBLOG_QSO_UPLOAD_DATE');
        CLUBLOG_QSO_UPLOAD_STATUS := dmFunc.getField(s, 'CLUBLOG_QSO_UPLOAD_STATUS');
        HRDLOG_QSO_UPLOAD_DATE := dmFunc.getField(s, 'HRDLOG_QSO_UPLOAD_DATE');
        HRDLOG_QSO_UPLOAD_STATUS := dmFunc.getField(s, 'HRDLOG_QSO_UPLOAD_STATUS');
        QRZCOM_QSO_UPLOAD_DATE := dmFunc.getField(s, 'QRZCOM_QSO_UPLOAD_DATE');
        QRZCOM_QSO_UPLOAD_STATUS := dmFunc.getField(s, 'QRZCOM_QSO_UPLOAD_STATUS');
        HAMLOGEU_QSO_UPLOAD_DATE := dmFunc.getField(s, 'HAMLOGEU_QSO_UPLOAD_DATE');
        HAMLOGEU_QSO_UPLOAD_STATUS := dmFunc.getField(s, 'HAMLOGEU_QSO_UPLOAD_STATUS');
        HAMLOGRU_QSO_UPLOAD_DATE := dmFunc.getField(s, 'HAMLOGRU_QSO_UPLOAD_DATE');
        HAMLOGRU_QSO_UPLOAD_STATUS := dmFunc.getField(s, 'HAMLOGRU_QSO_UPLOAD_STATUS');
        HAMQTH_QSO_UPLOAD_DATE := dmFunc.getField(s, 'HAMQTH_QSO_UPLOAD_DATE');
        HAMQTH_QSO_UPLOAD_STATUS := dmFunc.getField(s, 'HAMQTH_QSO_UPLOAD_STATUS');

        if PosEOR > 0 then
        begin
          if Length(PADIImport.Comment) > 0 then
            COMMENT := PADIImport.Comment;

          if (TIME_ON <> '') then
            TIME_ON := TIME_ON[1] + TIME_ON[2] + ':' + TIME_ON[3] + TIME_ON[4];
          if (TIME_OFF <> '') then
            TIME_OFF := TIME_OFF[1] + TIME_OFF[2] + ':' + TIME_OFF[3] + TIME_OFF[4];

          if ((MODE = 'CW') and (RST_SENT = '')) then
            RST_SENT := '599';
          if ((MODE = 'CW') and (RST_RCVD = '')) then
            RST_RCVD := '599';

          if FREQ = '' then
            FREQ := MainFunc.ConvertFreqToSave(
              FloatToStr(dmFunc.GetFreqFromBand(BAND, MODE)))
          else
            FREQ := MainFunc.ConvertFreqToSave(FREQ);

          if FREQ_RX = '' then
            FREQ_RX := 'NULL'
          else
            FREQ_RX := MainFunc.ConvertFreqToSave(FREQ_RX);

          CheckMode(MODE, FREQ, SUBMODE, MODE);

          BAND := StringReplace(FloatToStr(dmFunc.GetDigiBandFromFreq(FREQ)),
            ',', '.', [rfReplaceAll]);

          yyyy := StrToInt(QSO_DATE[1] + QSO_DATE[2] + QSO_DATE[3] +
            QSO_DATE[4]);
          mm := StrToInt(QSO_DATE[5] + QSO_DATE[6]);
          dd := StrToInt(QSO_DATE[7] + QSO_DATE[8]);

          if PADIImport.TimeOnOff then
            QSOTIME := TIME_OFF
          else
            QSOTIME := TIME_ON;

          if (QSOTIME = '') and (TIME_OFF = '') then
            QSOTIME := TIME_ON;

          if (QSOTIME = '') and (TIME_ON = '') then
            QSOTIME := TIME_OFF;

          paramQSODateTime :=
            IntToStr(DateTimeToUnix(EncodeDateTime(yyyy, mm, dd, StrToInt(QSOTIME[1] + QSOTIME[2]),
            StrToInt(QSOTIME[4] + QSOTIME[5]), 0, 0)));
          paramQSODate := StringReplace(
            FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
            ',', '.', [rfReplaceAll]);

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
            paramQSLSDATE :=
              StringReplace(FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
              ',', '.', [rfReplaceAll]);
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
            paramQSLRDATE :=
              StringReplace(FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
              ',', '.', [rfReplaceAll]);
            paramQSL_RCVD := '1';
          end
          else
            paramQSLRDATE := 'NULL';

          if HRDLOG_QSO_UPLOAD_DATE <> '' then
          begin
            yyyy := StrToInt(HRDLOG_QSO_UPLOAD_DATE[1] +
              HRDLOG_QSO_UPLOAD_DATE[2] + HRDLOG_QSO_UPLOAD_DATE[3] +
              HRDLOG_QSO_UPLOAD_DATE[4]);
            mm := StrToInt(HRDLOG_QSO_UPLOAD_DATE[5] + HRDLOG_QSO_UPLOAD_DATE[6]);
            dd := StrToInt(HRDLOG_QSO_UPLOAD_DATE[7] + HRDLOG_QSO_UPLOAD_DATE[8]);
            paramHRDLOG_QSO_UPLOAD_DATE :=
              StringReplace(FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
              ',', '.', [rfReplaceAll]);
            paramHRDLOG_QSO_UPLOAD_STATUS := '1';
          end
          else
            paramHRDLOG_QSO_UPLOAD_DATE := 'NULL';

          if HAMQTH_QSO_UPLOAD_DATE <> '' then
          begin
            yyyy := StrToInt(HAMQTH_QSO_UPLOAD_DATE[1] +
              HAMQTH_QSO_UPLOAD_DATE[2] + HAMQTH_QSO_UPLOAD_DATE[3] +
              HAMQTH_QSO_UPLOAD_DATE[4]);
            mm := StrToInt(HAMQTH_QSO_UPLOAD_DATE[5] + HAMQTH_QSO_UPLOAD_DATE[6]);
            dd := StrToInt(HAMQTH_QSO_UPLOAD_DATE[7] + HAMQTH_QSO_UPLOAD_DATE[8]);
            paramHAMQTH_QSO_UPLOAD_DATE :=
              StringReplace(FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
              ',', '.', [rfReplaceAll]);
            paramHAMQTH_QSO_UPLOAD_STATUS := '1';
          end
          else
            paramHAMQTH_QSO_UPLOAD_DATE := 'NULL';

          if CLUBLOG_QSO_UPLOAD_DATE <> '' then
          begin
            yyyy := StrToInt(CLUBLOG_QSO_UPLOAD_DATE[1] +
              CLUBLOG_QSO_UPLOAD_DATE[2] + CLUBLOG_QSO_UPLOAD_DATE[3] +
              CLUBLOG_QSO_UPLOAD_DATE[4]);
            mm := StrToInt(CLUBLOG_QSO_UPLOAD_DATE[5] + CLUBLOG_QSO_UPLOAD_DATE[6]);
            dd := StrToInt(CLUBLOG_QSO_UPLOAD_DATE[7] + CLUBLOG_QSO_UPLOAD_DATE[8]);
            paramCLUBLOG_QSO_UPLOAD_DATE :=
              StringReplace(FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
              ',', '.', [rfReplaceAll]);
            paramCLUBLOG_QSO_UPLOAD_STATUS := '1';
          end
          else
            paramCLUBLOG_QSO_UPLOAD_DATE := 'NULL';

          if HAMLOGEU_QSO_UPLOAD_DATE <> '' then
          begin
            yyyy := StrToInt(HAMLOGEU_QSO_UPLOAD_DATE[1] +
              HAMLOGEU_QSO_UPLOAD_DATE[2] + HAMLOGEU_QSO_UPLOAD_DATE[3] +
              HAMLOGEU_QSO_UPLOAD_DATE[4]);
            mm := StrToInt(HAMLOGEU_QSO_UPLOAD_DATE[5] + HAMLOGEU_QSO_UPLOAD_DATE[6]);
            dd := StrToInt(HAMLOGEU_QSO_UPLOAD_DATE[7] + HAMLOGEU_QSO_UPLOAD_DATE[8]);
            paramHAMLOGEU_QSO_UPLOAD_DATE :=
              StringReplace(FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
              ',', '.', [rfReplaceAll]);
            paramHAMLOGEU_QSO_UPLOAD_STATUS := '1';
          end
          else
            paramHAMLOGEU_QSO_UPLOAD_DATE := 'NULL';

          if HAMLOGRU_QSO_UPLOAD_DATE <> '' then
          begin
            yyyy := StrToInt(HAMLOGRU_QSO_UPLOAD_DATE[1] +
              HAMLOGRU_QSO_UPLOAD_DATE[2] + HAMLOGRU_QSO_UPLOAD_DATE[3] +
              HAMLOGRU_QSO_UPLOAD_DATE[4]);
            mm := StrToInt(HAMLOGRU_QSO_UPLOAD_DATE[5] + HAMLOGRU_QSO_UPLOAD_DATE[6]);
            dd := StrToInt(HAMLOGRU_QSO_UPLOAD_DATE[7] + HAMLOGRU_QSO_UPLOAD_DATE[8]);
            paramHAMLOGRU_QSO_UPLOAD_DATE :=
              StringReplace(FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
              ',', '.', [rfReplaceAll]);
            paramHAMLOGRU_QSO_UPLOAD_STATUS := '1';
          end
          else
            paramHAMLOGRU_QSO_UPLOAD_DATE := 'NULL';

          if QRZCOM_QSO_UPLOAD_DATE <> '' then
          begin
            yyyy := StrToInt(QRZCOM_QSO_UPLOAD_DATE[1] +
              QRZCOM_QSO_UPLOAD_DATE[2] + QRZCOM_QSO_UPLOAD_DATE[3] +
              QRZCOM_QSO_UPLOAD_DATE[4]);
            mm := StrToInt(QRZCOM_QSO_UPLOAD_DATE[5] + QRZCOM_QSO_UPLOAD_DATE[6]);
            dd := StrToInt(QRZCOM_QSO_UPLOAD_DATE[7] + QRZCOM_QSO_UPLOAD_DATE[8]);
            paramQRZCOM_QSO_UPLOAD_DATE :=
              StringReplace(FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
              ',', '.', [rfReplaceAll]);
            paramQRZCOM_QSO_UPLOAD_STATUS := '1';
          end
          else
            paramQRZCOM_QSO_UPLOAD_DATE := 'NULL';

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
            paramLOTW_QSLRDATE :=
              StringReplace(FloatToStr(DateTimeToJulianDate(EncodeDate(yyyy, mm, dd))),
              ',', '.', [rfReplaceAll]);
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

          if (SRX = '') or (SRX = '0') then
            SRX := 'NULL';
          if (STX = '') or (STX = '0') then
            STX := 'NULL';

          if PADIImport.SearchPrefix then
          begin
            PFXR := MainFunc.SearchPrefix(CALL, GRIDSQUARE);
            PFX := PFXR.Prefix;
            DXCC_PREF := PFXR.ARRLPrefix;
            CQZ := PFXR.CQZone;
            ITUZ := PFXR.ITUZone;
            CONT := PFXR.Continent;
            DXCC := IntToStr(PFXR.DXCCNum);
          end;

          if GuessEncoding(sNAME) <> 'utf8' then
            sNAME := CP1251ToUTF8(sNAME);
          if GuessEncoding(QTH) <> 'utf8' then
            QTH := CP1251ToUTF8(QTH);
          if GuessEncoding(COMMENT) <> 'utf8' then
            COMMENT := CP1251ToUTF8(COMMENT);

          if not PADIImport.Mobile then
          begin
            Query := 'INSERT INTO ' + LBRecord.LogTable + ' (' +
              'CallSign, QSODateTime, QSODate, QSOTime, QSOBand, FREQ_RX, BAND_RX,'
              +
              'QSOMode, QSOSubMode, QSOReportSent,' +
              'QSOReportRecived, OMName, OMQTH, State, Grid, IOTA, QSLManager, QSLSent,'
              +
              'QSLSentAdv, QSLSentDate, QSLRec, QSLRecDate, MainPrefix, DXCCPrefix,' +
              'CQZone, ITUZone, QSOAddInfo, Marker, ManualSet, DigiBand, Continent,' +
              'ShortNote, QSLReceQSLcc, LoTWRec, LoTWRecDate, QSLInfo, `Call`, State1, State2, '
              + 'State3, State4, WPX, AwardsEx, ValidDX, SRX, SRX_STRING, STX, STX_STRING, SAT_NAME,'
              + 'SAT_MODE, PROP_MODE, LoTWSent, QSL_RCVD_VIA, QSL_SENT_VIA, DXCC,' +
              'NoCalcDXCC, MY_STATE, MY_GRIDSQUARE, MY_LAT, MY_LON,' +
              'EQSL_QSL_SENT, SOTA_REF, MY_SOTA_REF, HRDLOG_QSO_UPLOAD_STATUS, ' +
              'HRDLOG_QSO_UPLOAD_DATE, QRZCOM_QSO_UPLOAD_STATUS, QRZCOM_QSO_UPLOAD_DATE, ' +
              'HAMQTH_QSO_UPLOAD_STATUS, HAMQTH_QSO_UPLOAD_DATE, CLUBLOG_QSO_UPLOAD_STATUS, ' +
              'CLUBLOG_QSO_UPLOAD_DATE, HAMLOGEU_QSO_UPLOAD_STATUS, HAMLOGEU_QSO_UPLOAD_DATE, ' +
              'HAMLOGRU_QSO_UPLOAD_STATUS, HAMLOGRU_QSO_UPLOAD_DATE, SYNC)' + ' VALUES (' +
              dmFunc.Q(CALL) + dmFunc.Q(paramQSODateTime) +
              dmFunc.Q(paramQSODate) + dmFunc.Q(QSOTIME) +
              dmFunc.Q(FREQ) + dmFunc.Q(FREQ_RX) + dmFunc.Q(BAND_RX) +
              dmFunc.Q(MODE) + dmFunc.Q(SUBMODE) + dmFunc.Q(RST_SENT) +
              dmFunc.Q(RST_RCVD) + dmFunc.Q(sNAME) + dmFunc.Q(QTH) +
              dmFunc.Q(STATE) + dmFunc.Q(GRIDSQUARE) + dmFunc.Q(IOTA) +
              dmFunc.Q(QSL_VIA) + dmFunc.Q(paramQSLSent) + dmFunc.Q(paramQSLSentAdv) +
              dmFunc.Q(paramQSLSDATE) + dmFunc.Q(ParamQSL_RCVD) +
              dmFunc.Q(paramQSLRDATE) + dmFunc.Q(PFX) + dmFunc.Q(DXCC_PREF) +
              dmFunc.Q(CQZ) + dmFunc.Q(ITUZ) + dmFunc.Q(COMMENT) +
              dmFunc.Q(paramMARKER) + dmFunc.Q('0') + dmFunc.Q(BAND) +
              dmFunc.Q(CONT) + dmFunc.Q(COMMENT) + dmFunc.Q(paramEQSL_QSL_RCVD) +
              dmFunc.Q(paramLOTW_QSL_RCVD) + dmFunc.Q(paramLOTW_QSLRDATE) +
              dmFunc.Q(QSLMSG) + dmFunc.Q(dmFunc.ExtractCallsign(CALL)) +
              dmFunc.Q(STATE1) + dmFunc.Q(STATE2) + dmFunc.Q(STATE3) +
              dmFunc.Q(STATE4) + dmFunc.Q(dmFunc.ExtractWPXPrefix(CALL)) +
              dmFunc.Q('') + dmFunc.Q(paramValidDX) + dmFunc.Q(SRX) +
              dmFunc.Q(SRX_STRING) + dmFunc.Q(STX) + dmFunc.Q(STX_STRING) +
              dmFunc.Q(SAT_NAME) + dmFunc.Q(SAT_MODE) + dmFunc.Q(PROP_MODE) +
              dmFunc.Q(paramLOTW_QSL_SENT) + dmFunc.Q(QSL_RCVD_VIA) +
              dmFunc.Q(QSL_SENT_VIA) + dmFunc.Q(DXCC) + dmFunc.Q(paramNoCalcDXCC) +
              dmFunc.Q(MY_STATE) + dmFunc.Q(MY_GRIDSQUARE) +
              dmFunc.Q(MY_LAT) + dmFunc.Q(MY_LON) + dmFunc.Q(EQSL_QSL_SENT) +
              dmFunc.Q(SOTA_REF) + dmFunc.Q(MY_SOTA_REF) +
              dmFunc.Q(paramHRDLOG_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramHRDLOG_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramQRZCOM_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramQRZCOM_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramHAMQTH_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramHAMQTH_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramCLUBLOG_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramCLUBLOG_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramHAMLOGEU_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramHAMLOGEU_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramHAMLOGRU_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramHAMLOGRU_QSO_UPLOAD_DATE) + QuotedStr('0') + ')';
          end
          else
          begin
            TempQuery := 'INSERT INTO ' + LBRecord.LogTable + ' (' +
              'CallSign, QSODateTime, QSODate, QSOTime, QSOBand, FREQ_RX, BAND_RX,'
              +
              'QSOMode, QSOSubMode, QSOReportSent,' +
              'QSOReportRecived, OMName, OMQTH, State, Grid, IOTA, QSLManager, QSLSent,'
              +
              'QSLSentAdv, QSLSentDate, QSLRec, QSLRecDate, MainPrefix, DXCCPrefix,' +
              'CQZone, ITUZone, QSOAddInfo, Marker, ManualSet, DigiBand, Continent,' +
              'ShortNote, QSLReceQSLcc, LoTWRec, LoTWRecDate, QSLInfo, `Call`, State1, State2, '
              + 'State3, State4, WPX, AwardsEx, ValidDX, SRX, SRX_STRING, STX, STX_STRING, SAT_NAME,'
              + 'SAT_MODE, PROP_MODE, LoTWSent, QSL_RCVD_VIA, QSL_SENT_VIA, DXCC,' +
              'NoCalcDXCC, MY_STATE, MY_GRIDSQUARE, MY_LAT, MY_LON, HRDLOG_QSO_UPLOAD_STATUS, ' +
              'HRDLOG_QSO_UPLOAD_DATE, QRZCOM_QSO_UPLOAD_STATUS, QRZCOM_QSO_UPLOAD_DATE, ' +
              'HAMQTH_QSO_UPLOAD_STATUS, HAMQTH_QSO_UPLOAD_DATE, CLUBLOG_QSO_UPLOAD_STATUS, ' +
              'CLUBLOG_QSO_UPLOAD_DATE, HAMLOGEU_QSO_UPLOAD_STATUS, HAMLOGEU_QSO_UPLOAD_DATE, ' +
              'HAMLOGRU_QSO_UPLOAD_STATUS, HAMLOGRU_QSO_UPLOAD_DATE, SYNC) VALUES (' +
              dmFunc.Q(CALL) + dmFunc.Q(paramQSODateTime) +
              dmFunc.Q(paramQSODate) + dmFunc.Q(QSOTIME) +
              dmFunc.Q(FREQ) + dmFunc.Q(FREQ_RX) + dmFunc.Q(BAND_RX) +
              dmFunc.Q(MODE) + dmFunc.Q(SUBMODE) + dmFunc.Q(RST_SENT) +
              dmFunc.Q(RST_RCVD) + dmFunc.Q(sNAME) + dmFunc.Q(QTH) +
              dmFunc.Q(STATE) + dmFunc.Q(GRIDSQUARE) + dmFunc.Q(IOTA) +
              dmFunc.Q(QSL_VIA) + dmFunc.Q(paramQSLSent) + dmFunc.Q(paramQSLSentAdv) +
              dmFunc.Q(paramQSLSDATE) + dmFunc.Q(ParamQSL_RCVD) +
              dmFunc.Q(paramQSLRDATE) + dmFunc.Q(PFX) + dmFunc.Q(DXCC_PREF) +
              dmFunc.Q(CQZ) + dmFunc.Q(ITUZ) + dmFunc.Q(COMMENT) +
              dmFunc.Q(paramMARKER) + dmFunc.Q('0') + dmFunc.Q(BAND) +
              dmFunc.Q(CONT) + dmFunc.Q(COMMENT) + dmFunc.Q(paramEQSL_QSL_RCVD) +
              dmFunc.Q(paramLOTW_QSL_RCVD) + dmFunc.Q(paramLOTW_QSLRDATE) +
              dmFunc.Q(QSLMSG) + dmFunc.Q(dmFunc.ExtractCallsign(CALL)) +
              dmFunc.Q(STATE1) + dmFunc.Q(STATE2) + dmFunc.Q(STATE3) +
              dmFunc.Q(STATE4) + dmFunc.Q(dmFunc.ExtractWPXPrefix(CALL)) +
              dmFunc.Q('') + dmFunc.Q(paramValidDX) + dmFunc.Q(SRX) +
              dmFunc.Q(SRX_STRING) + dmFunc.Q(STX) + dmFunc.Q(STX_STRING) +
              dmFunc.Q(SAT_NAME) + dmFunc.Q(SAT_MODE) + dmFunc.Q(PROP_MODE) +
              dmFunc.Q(paramLOTW_QSL_SENT) + dmFunc.Q(QSL_RCVD_VIA) +
              dmFunc.Q(QSL_SENT_VIA) + dmFunc.Q(DXCC) + dmFunc.Q(paramNoCalcDXCC) +
              dmFunc.Q(MY_STATE) + dmFunc.Q(MY_GRIDSQUARE) +
              dmFunc.Q(MY_LAT) + dmFunc.Q(MY_LON) +
              dmFunc.Q(paramHRDLOG_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramHRDLOG_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramQRZCOM_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramQRZCOM_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramHAMQTH_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramHAMQTH_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramCLUBLOG_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramCLUBLOG_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramHAMLOGEU_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramHAMLOGEU_QSO_UPLOAD_DATE) +
              dmFunc.Q(paramHAMLOGRU_QSO_UPLOAD_STATUS) +
              dmFunc.Q(paramHAMLOGRU_QSO_UPLOAD_DATE) + QuotedStr('1');

            Query := TempQuery +
              ') ON CONFLICT (CallSign, QSODate, QSOTime, QSOBand) DO UPDATE SET SYNC = 1';
          end;

          InitDB.SQLiteConnection.ExecuteDirect(Query);

        end;

        Inc(Info.RecCount);

        if Terminated then
          Exit;

      except
        on E: ESQLDatabaseError do
        begin
          if (E.ErrorCode = 1062) or (E.ErrorCode = 2067) then
          begin
            Inc(Info.DupeCount);
            Synchronize(@ToForm);
            WriteWrongADIF(s);
          end;
          if E.ErrorCode = 1366 then
          begin
            Inc(Info.ErrorCount);
            Synchronize(@ToForm);
            WriteWrongADIF(s);
          end;
        end;
        on E: Exception do
        begin
          Inc(Info.ErrorCount);
          Synchronize(@ToForm);
          WriteWrongADIF(s);
          Continue;
        end;
      end;
      Synchronize(@ToForm);
    end;
  finally
    InitDB.DefTransaction.Commit;
    Info.Result := True;
    CloseFile(f);
    CloseFile(temp_f);
    Stream.Free;
    Synchronize(@ToForm);
  end;

end;

constructor TImportADIFThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TImportADIFThread.ToForm;
begin
  if not PADIImport.Mobile then
    ImportADIFForm.FromImportThread(Info)
  else
    MiniForm.FromImportThread(Info);
end;

procedure TImportADIFThread.Execute;
begin
  ADIFImport(PADIImport);
end;

end.
