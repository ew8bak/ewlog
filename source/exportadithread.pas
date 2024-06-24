(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit ExportADIThread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, Forms, LCLType, LConvEncoding, ResourceStr, DateUtils;

type
  TInfoExport = record
    From: string;
    AllRec: integer;
    RecCount: integer;
    ErrorStr: string;
    ErrorCode: integer;
    Result: boolean;
  end;

type
  TPADIExport = record
    Path: string;
    DateStart: TDateTime;
    DateEnd: TDateTime;
    ExportAll: boolean;
    Win1251: boolean;
    RusToLat: boolean;
    RemoveSlash: boolean;
    Mobile: boolean;
    AllRec: integer;
    FromForm: string;
  end;

type
  TExportADIFThread = class(TThread)
  protected
    procedure Execute; override;
  private
    FromForm: string;
    procedure ADIFExport(PADIExport: TPADIExport);
    function SetSizeLoc(Loc: string): string;
  public
    PADIExport: TPADIExport;
    Info: TInfoExport;
    constructor Create;
    procedure ToForm;
  end;

var
  ExportADIFThread: TExportADIFThread;

implementation

uses InitDB_dm, dmFunc_U, ExportAdifForm_u,
  GridsForm_u, progressForm_u, MainFuncDM;

function TExportADIFThread.SetSizeLoc(Loc: string): string;
begin
  Result := '';
  while Length(Loc) > 6 do
    Delete(Loc, Length(Loc), 1);
  Result := Loc;
end;

procedure TExportADIFThread.ADIFExport(PADIExport: TPADIExport);
var
  Query: TSQLQuery;
  f: TextFile;
  tmp: string;
  DefMyLAT: string;
  DefMyLON: string;
  DefMyGrid: string;
  DefStationCallsign: string;
  EQSL_QSL_RCVD, QSL_RCVD, QSL_SENT: string;
  LOTW_QSL_RCVD, LOTW_QSL_SENT: string;
  tmpFreq, MyCurrCall: string;
  i: integer;
  numberToExp: string = '';
  SafeFreq: double;
  tmpdate: int64;
begin
  try
    Info.ErrorCode := 0;
    Info.Result := False;
    Info.RecCount := 0;
    Info.AllRec := 0;
    FromForm := PADIExport.FromForm;
    Query := TSQLQuery.Create(nil);
    Query.DataBase := InitDB.SQLiteConnection;
    Query.SQL.Text := 'SELECT * FROM LogBookInfo WHERE LogTable = ' +
      QuotedStr(LBRecord.LogTable);
    Query.Open;
    DefMyGrid := Query.Fields.FieldByName('Loc').AsString;
    DefMyLat := SetSizeLoc(Query.Fields.FieldByName('Lat').AsString);
    DefMyLon := SetSizeLoc(Query.Fields.FieldByName('Lon').AsString);
    Query.Close;

    if FileExists(PADIExport.Path) then
      DeleteFile(PADIExport.Path);

    AssignFile(f, PADIExport.Path);
    {$i-}
    Rewrite(f);
    {$i+}
    Info.ErrorCode := IOResult;
    if IOresult <> 0 then
    begin
      Synchronize(@ToForm);
      Exit;
    end;
    Writeln(f, '<ADIF_VER:5>3.1.1');
    WriteLn(f, '<CREATED_TIMESTAMP' + dmFunc.StringToADIF(
      FormatDateTime('yyyymmdd hhnnss', Now), False));
    WriteLn(f, '<PROGRAMID' + dmFunc.StringToADIF('EWLog', False));
    WriteLn(f, '<PROGRAMVERSION' + dmFunc.StringToADIF(dmFunc.GetMyVersion, False));

    Writeln(f, '<EOH>');

    if PADIExport.ExportAll then
      Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
        ' ORDER BY UnUsedIndex ASC'
    else
      Query.SQL.Text :=
        'SELECT * FROM ' + LBRecord.LogTable + ' WHERE ' + 'strftime(' +
        QuotedStr('%Y-%m-%d') + ',QSODate) BETWEEN ' +
        QuotedStr(FormatDateTime('yyyy-mm-dd', PADIExport.DateStart)) +
        ' and ' + QuotedStr(FormatDateTime('yyyy-mm-dd', PADIExport.DateEnd)) +
        ' ORDER BY UnUsedIndex ASC';


    if GridsForm.ExportAdifSelect = True then
    begin
      for i := 0 to High(GridsForm.ExportAdifArray) do
      begin
        if i > 0 then
          numberToExp := numberToExp + ', ';
        numberToExp := numberToExp + IntToStr(GridsForm.ExportAdifArray[i]);
      end;
      for i := 0 to Length(GridsForm.ExportAdifArray) - 1 do
      begin
        Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
          ' WHERE `UnUsedIndex` in (' + numberToExp + ')' + ' ORDER BY UnUsedIndex ASC';
      end;
    end;
    GridsForm.ExportAdifSelect := False;

    Query.Open;
    Query.Last;
    Info.AllRec := Query.RecordCount;
    Synchronize(@ToForm);
    Query.First;
    MyCurrCall := DBRecord.CurrentCall;
    DefStationCallsign := DBRecord.CurrentCall;
    if (PADIExport.RemoveSlash) then
    begin
      if MyCurrCall[length(MyCurrCall)] = '/' then
      begin
        Delete(MyCurrCall, length(MyCurrCall), 1);
      end;
    end;
    while not Query.EOF do
    begin
      try
        EQSL_QSL_RCVD := '';
        LOTW_QSL_RCVD := '';
        LOTW_QSL_SENT := '';
        QSL_RCVD := '';
        QSL_SENT := '';
        tmpFreq := '';

        if exportAdiSet.fSTATION_CALLSIGN then
        begin
          tmp := '<STATION_CALLSIGN' + dmFunc.StringToADIF(
            dmFunc.RemoveSpaces(MyCurrCall), PADIExport.Win1251);
          Write(f, tmp);
        end;

        if exportAdiSet.fOPERATOR then
        begin
          tmp := '<OPERATOR' + dmFunc.StringToADIF(
            dmFunc.RemoveSpaces(MyCurrCall), PADIExport.Win1251);
          Write(f, tmp);
        end;

        if exportAdiSet.fCALL then
        begin
          tmp := '<CALL' + dmFunc.StringToADIF(
            dmFunc.RemoveSpaces(Query.Fields.FieldByName('CallSign').AsString),
            PADIExport.Win1251);
          Write(f, tmp);
        end;

        if exportAdiSet.fQSO_DATE then
        begin
          tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
            'QSODate').AsDateTime);
          tmp := '<QSO_DATE' + dmFunc.StringToADIF(tmp, PADIExport.Win1251);
          Write(f, tmp);
        end;

        if exportAdiSet.fTIME_ON then
        begin
          tmp := Query.Fields.FieldByName('QSOTime').AsString;
          tmp := copy(tmp, 1, 2) + copy(tmp, 4, 2);
          tmp := '<TIME_ON' + dmFunc.StringToADIF(tmp, PADIExport.Win1251);
          Write(f, tmp);
        end;

        if exportAdiSet.fMODE then
          if Query.Fields.FieldByName('QSOMode').AsString <> '' then
          begin
            tmp := '<MODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'QSOMode').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fSUBMODE then
          if Query.Fields.FieldByName('QSOSubMode').AsString <> '' then
          begin
            tmp := '<SUBMODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'QSOSubMode').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fBAND then
          if Query.Fields.FieldByName('QSOBand').AsString <> '' then
          begin
            tmpFreq := Query.Fields.FieldByName('QSOBand').AsString;
            Delete(tmpFreq, Length(tmpFreq) - 2, 1);
            TryStrToFloatSafe(tmpFreq, SafeFreq);
            tmp := '<FREQ' + dmFunc.StringToADIF(
              StringReplace(FormatFloat('0.#####', SafeFreq), ',', '.', [rfReplaceAll]),
              PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fFREQ_RX then
          if Query.Fields.FieldByName('FREQ_RX').AsString <> '' then
          begin
            tmpFreq := Query.Fields.FieldByName('FREQ_RX').AsString;
            Delete(tmpFreq, Length(tmpFreq) - 2, 1);
            TryStrToFloatSafe(tmpFreq, SafeFreq);
            tmp := '<FREQ_RX' + dmFunc.StringToADIF(
              StringReplace(FormatFloat('0.#####', SafeFreq), ',', '.', [rfReplaceAll]),
              PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fRST_SENT then
          if Query.Fields.FieldByName('QSOReportSent').AsString <> '' then
          begin
            tmp := '<RST_SENT' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'QSOReportSent').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fRST_RCVD then
          if Query.Fields.FieldByName('QSOReportRecived').AsString <> '' then
          begin
            tmp := '<RST_RCVD' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'QSOReportRecived').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;


        if exportAdiSet.fSRX then
          if ((Query.Fields.FieldByName('SRX').AsInteger <> 0) and
            (not Query.Fields.FieldByName('SRX').IsNull)) then
          begin
            tmp := '<SRX' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'SRX').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fSTX then
          if ((Query.Fields.FieldByName('STX').AsInteger <> 0) and
            (not Query.Fields.FieldByName('STX').IsNull)) then
          begin
            tmp := '<STX' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'STX').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fSRX_STRING then
          if (Query.Fields.FieldByName('SRX_STRING').AsString <> '') then
          begin
            tmp := '<SRX_STRING' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'SRX_STRING').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fSTX_STRING then
          if (Query.Fields.FieldByName('STX_STRING').AsString <> '') then
          begin
            tmp := '<STX_STRING' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'STX_STRING').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fNAME then
          if Query.Fields.FieldByName('OMName').AsString <> '' then
          begin
            if PADIExport.RusToLat then
              tmp := '<NAME' + dmFunc.StringToADIF(
                dmFunc.RusToLat(Query.Fields.FieldByName('OMName').AsString),
                PADIExport.Win1251)
            else
              tmp := '<NAME' + dmFunc.StringToADIF(Query.Fields.FieldByName(
                'OMName').AsString, PADIExport.Win1251);
            if PADIExport.Win1251 then
              Write(f, UTF8ToCP1251(tmp))
            else
              Write(f, tmp);
          end;

        if exportAdiSet.fQTH then
          if Query.Fields.FieldByName('OMQTH').AsString <> '' then
          begin
            if PADIExport.RusToLat then
              tmp := '<QTH' + dmFunc.StringToADIF(
                dmFunc.RusToLat(Query.Fields.FieldByName('OMQTH').AsString),
                PADIExport.Win1251)
            else
              tmp := '<QTH' + dmFunc.StringToADIF(Query.Fields.FieldByName(
                'OMQTH').AsString, PADIExport.Win1251);
            if PADIExport.Win1251 then
              Write(f, UTF8ToCP1251(tmp))
            else
              Write(f, tmp);
          end;

        if exportAdiSet.fSTATE then
          if Query.Fields.FieldByName('State').AsString <> '' then
          begin
            tmp := '<STATE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'State').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;


        if exportAdiSet.fGRIDSQUARE then
          if Query.Fields.FieldByName('Grid').AsString <> '' then
          begin
            tmp := '<GRIDSQUARE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'Grid').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fWPX then
          if Query.Fields.FieldByName('WPX').AsString <> '' then
          begin
            tmp := '<PFX' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'WPX').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fDXCC_PREF then
          if Query.Fields.FieldByName('DXCCPrefix').AsString <> '' then
          begin
            tmp := '<DXCC_PREF' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'DXCCPrefix').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fBAND then
          if Query.Fields.FieldByName('QSOBand').AsString <> '' then
          begin
            tmp := '<BAND' + dmFunc.StringToADIF(dmFunc.GetBandFromFreq(
              Query.Fields.FieldByName('QSOBand').AsString), PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fBAND_RX then
          if Query.Fields.FieldByName('BAND_RX').AsString <> '' then
          begin
            tmp := '<BAND_RX' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'BAND_RX').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fPROP_MODE then
          if Query.Fields.FieldByName('PROP_MODE').AsString <> '' then
          begin
            tmp := '<PROP_MODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'PROP_MODE').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fSAT_MODE then
          if Query.Fields.FieldByName('SAT_MODE').AsString <> '' then
          begin
            tmp := '<SAT_MODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'SAT_MODE').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fSAT_NAME then
          if Query.Fields.FieldByName('SAT_NAME').AsString <> '' then
          begin
            tmp := '<SAT_NAME' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'SAT_NAME').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fCQZ then
          if Query.Fields.FieldByName('CQZone').AsString <> '' then
          begin
            tmp := '<CQZ' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'CQZone').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fITUZ then
          if Query.Fields.FieldByName('ITUZone').AsString <> '' then
          begin
            tmp := '<ITUZ' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'ITUZone').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fCONT then
          if Query.Fields.FieldByName('Continent').AsString <> '' then
          begin
            tmp := '<CONT' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'Continent').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fQSLMSG then
          if Query.Fields.FieldByName('QSLInfo').AsString <> '' then
          begin
            tmp := '<QSLMSG' + dmFunc.StringToADIF(
              dmFunc.MyTrim(Query.Fields.FieldByName('QSLInfo').AsString),
              PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fEQSL_QSL_RCVD then
          if Query.Fields.FieldByName('QSLReceQSLcc').AsString = '1' then
          begin
            EQSL_QSL_RCVD := Query.Fields.FieldByName('QSLReceQSLcc').AsString;
            if EQSL_QSL_RCVD = '0' then
              tmp := '<EQSL_QSL_RCVD' + dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<EQSL_QSL_RCVD' + dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fQSLSDATE then
          if Query.Fields.FieldByName('QSLSentDate').AsString <> '' then
          begin
            tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
              'QSLSentDate').AsDateTime);
            tmp := '<QSLSDATE' + dmFunc.StringToADIF(tmp, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fQSLRDATE then
          if Query.Fields.FieldByName('QSLRecDate').AsString <> '' then
          begin
            tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
              'QSLRecDate').AsDateTime);
            tmp := '<QSLRDATE' + dmFunc.StringToADIF(tmp, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fQSL_RCVD then
          if Query.Fields.FieldByName('QSLRec').AsString = '1' then
          begin
            QSL_RCVD := Query.Fields.FieldByName('QSLRec').AsString;
            if QSL_RCVD = '0' then
              tmp := '<QSL_RCVD' + dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<QSL_RCVD' + dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fQSL_RCVD_VIA then
          if Query.Fields.FieldByName('QSL_RCVD_VIA').AsString <> '' then
          begin
            tmp := '<QSL_RCVD_VIA' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'QSL_RCVD_VIA').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fQSL_SENT_VIA then
          if Query.Fields.FieldByName('QSL_SENT_VIA').AsString <> '' then
          begin
            tmp := '<QSL_SENT_VIA' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'QSL_SENT_VIA').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fQSL_SENT then
          if Query.Fields.FieldByName('QSLSent').AsString = '1' then
          begin
            QSL_SENT := Query.Fields.FieldByName('QSLSent').AsString;
            if QSL_SENT = '0' then
              tmp := '<QSL_SENT' + dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<QSL_SENT' + dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fLOTW_QSL_RCVD then
          if Query.Fields.FieldByName('LoTWRec').AsString = '1' then
          begin
            LOTW_QSL_RCVD := Query.Fields.FieldByName('LoTWRec').AsString;
            if LOTW_QSL_RCVD = '0' then
              tmp := '<LOTW_QSL_RCVD' + dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<LOTW_QSL_RCVD' + dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fLOTW_QSLRDATE then
          if Query.Fields.FieldByName('LoTWRecDate').AsString <> '' then
          begin
            tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
              'LoTWRecDate').AsDateTime);
            tmp := '<LOTW_QSLRDATE' + dmFunc.StringToADIF(tmp, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fLOTW_QSL_SENT then
          if Query.Fields.FieldByName('LoTWSent').AsString = '1' then
          begin
            LOTW_QSL_RCVD := Query.Fields.FieldByName('LoTWSent').AsString;
            if LOTW_QSL_RCVD = '0' then
              tmp := '<LOTW_QSL_SENT' + dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<LOTW_QSL_SENT' + dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fDXCC then
          if Query.Fields.FieldByName('DXCC').AsString <> '' then
          begin
            tmp := '<DXCC' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'DXCC').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fCOMMENT then
          if Query.Fields.FieldByName('QSOAddInfo').AsString <> '' then
          begin
            if PADIExport.RusToLat then
              tmp := '<COMMENT' + dmFunc.StringToADIF(
                dmFunc.MyTrim(dmFunc.RusToLat(Query.Fields.FieldByName(
                'QSOAddInfo').AsString)), PADIExport.Win1251)
            else
              tmp := '<COMMENT' + dmFunc.StringToADIF(
                dmFunc.MyTrim(Query.Fields.FieldByName('QSOAddInfo').AsString),
                PADIExport.Win1251);
            if PADIExport.Win1251 then
              Write(f, UTF8ToCP1251(tmp))
            else
              Write(f, tmp);
          end;

        if exportAdiSet.fMY_STATE then
          if Query.Fields.FieldByName('MY_STATE').AsString <> '' then
          begin
            tmp := '<MY_STATE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'MY_STATE').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fSOTA_REF then
          if Query.Fields.FieldByName('SOTA_REF').AsString <> '' then
          begin
            tmp := '<SOTA_REF' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'SOTA_REF').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fMY_SOTA_REF then
          if Query.Fields.FieldByName('MY_SOTA_REF').AsString <> '' then
          begin
            tmp := '<MY_SOTA_REF' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'MY_SOTA_REF').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fEQSL_QSL_SENT then
          if Query.Fields.FieldByName('EQSL_QSL_SENT').AsString <> '' then
          begin
            tmp := '<EQSL_QSL_SENT' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'EQSL_QSL_SENT').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fHAMLOG_QSL_RCVD then
          if Query.Fields.FieldByName('HAMLOGRec').AsString = '1' then
          begin
            tmp := '<HAMLOG_QSL_RCVD' + dmFunc.StringToADIF(
              Query.Fields.FieldByName('HAMLOGRec').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fCLUBLOG_QSO_UPLOAD_DATE then
          if Query.Fields.FieldByName('CLUBLOG_QSO_UPLOAD_DATE').AsString <> '' then
          begin
            tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
              'CLUBLOG_QSO_UPLOAD_DATE').AsDateTime);
            tmp := '<CLUBLOG_QSO_UPLOAD_DATE' +
              dmFunc.StringToADIF(tmp, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fCLUBLOG_QSO_UPLOAD_STATUS then
          if Query.Fields.FieldByName('CLUBLOG_QSO_UPLOAD_STATUS').AsString = '1' then
          begin
            LOTW_QSL_RCVD := Query.Fields.FieldByName(
              'CLUBLOG_QSO_UPLOAD_STATUS').AsString;
            if LOTW_QSL_RCVD = '0' then
              tmp := '<CLUBLOG_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<CLUBLOG_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fHRDLOG_QSO_UPLOAD_DATE then
          if Query.Fields.FieldByName('HRDLOG_QSO_UPLOAD_DATE').AsString <> '' then
          begin
            tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
              'HRDLOG_QSO_UPLOAD_DATE').AsDateTime);
            tmp := '<HRDLOG_QSO_UPLOAD_DATE' +
              dmFunc.StringToADIF(tmp, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fHRDLOG_QSO_UPLOAD_STATUS then
          if Query.Fields.FieldByName('HRDLOG_QSO_UPLOAD_STATUS').AsString = '1' then
          begin
            LOTW_QSL_RCVD := Query.Fields.FieldByName(
              'HRDLOG_QSO_UPLOAD_STATUS').AsString;
            if LOTW_QSL_RCVD = '0' then
              tmp := '<HRDLOG_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<HRDLOG_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fQRZCOM_QSO_UPLOAD_DATE then
          if Query.Fields.FieldByName('QRZCOM_QSO_UPLOAD_DATE').AsString <> '' then
          begin
            tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
              'QRZCOM_QSO_UPLOAD_DATE').AsDateTime);
            tmp := '<QRZCOM_QSO_UPLOAD_DATE' +
              dmFunc.StringToADIF(tmp, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fQRZCOM_QSO_UPLOAD_STATUS then
          if Query.Fields.FieldByName('QRZCOM_QSO_UPLOAD_STATUS').AsString = '1' then
          begin
            LOTW_QSL_RCVD := Query.Fields.FieldByName(
              'QRZCOM_QSO_UPLOAD_STATUS').AsString;
            if LOTW_QSL_RCVD = '0' then
              tmp := '<QRZCOM_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<QRZCOM_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fHAMLOGEU_QSO_UPLOAD_DATE then
          if Query.Fields.FieldByName('HAMLOGEU_QSO_UPLOAD_DATE').AsString <> '' then
          begin
            tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
              'HAMLOGEU_QSO_UPLOAD_DATE').AsDateTime);
            tmp := '<HAMLOGEU_QSO_UPLOAD_DATE' +
              dmFunc.StringToADIF(tmp, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fHAMLOGEU_QSO_UPLOAD_STATUS then
          if Query.Fields.FieldByName('HAMLOGEU_QSO_UPLOAD_STATUS').AsString
            = '1' then
          begin
            LOTW_QSL_RCVD := Query.Fields.FieldByName(
              'HAMLOGEU_QSO_UPLOAD_STATUS').AsString;
            if LOTW_QSL_RCVD = '0' then
              tmp := '<HAMLOGEU_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<HAMLOGEU_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fHAMLOGRU_QSO_UPLOAD_DATE then
          if Query.Fields.FieldByName('HAMLOGRU_QSO_UPLOAD_DATE').AsString <> '' then
          begin
            tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
              'HAMLOGRU_QSO_UPLOAD_DATE').AsDateTime);
            tmp := '<HAMLOGRU_QSO_UPLOAD_DATE' +
              dmFunc.StringToADIF(tmp, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fHAMLOGRU_QSO_UPLOAD_STATUS then
          if Query.Fields.FieldByName('HAMLOGRU_QSO_UPLOAD_STATUS').AsString
            = '1' then
          begin
            LOTW_QSL_RCVD := Query.Fields.FieldByName(
              'HAMLOGRU_QSO_UPLOAD_STATUS').AsString;
            if LOTW_QSL_RCVD = '0' then
              tmp := '<HAMLOGRU_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<HAMLOGRU_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fHAMQTH_QSO_UPLOAD_DATE then
          if Query.Fields.FieldByName('HAMQTH_QSO_UPLOAD_DATE').AsString <> '' then
          begin
            tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
              'HAMQTH_QSO_UPLOAD_DATE').AsDateTime);
            tmp := '<HAMQTH_QSO_UPLOAD_DATE' +
              dmFunc.StringToADIF(tmp, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fHAMQTH_QSO_UPLOAD_STATUS then
          if Query.Fields.FieldByName('HAMQTH_QSO_UPLOAD_STATUS').AsString
            = '1' then
          begin
            LOTW_QSL_RCVD := Query.Fields.FieldByName(
              'HAMQTH_QSO_UPLOAD_STATUS').AsString;
            if LOTW_QSL_RCVD = '0' then
              tmp := '<HAMQTH_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('N', PADIExport.Win1251)
            else
              tmp := '<HAMQTH_QSO_UPLOAD_STATUS' +
                dmFunc.StringToADIF('Y', PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fMY_GRIDSQUARE then
          if Query.Fields.FieldByName('MY_GRIDSQUARE').AsString <> '' then
          begin
            tmp := '<MY_GRIDSQUARE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
              'MY_GRIDSQUARE').AsString, PADIExport.Win1251);
            Write(f, tmp);
          end
          else
          begin
            tmp := '<MY_GRIDSQUARE' + dmFunc.StringToADIF(DefMyGrid, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fMY_LAT then
          if Query.Fields.FieldByName('MY_LAT').AsString <> '' then
          begin
            tmp := '<MY_LAT' + dmFunc.StringToADIF(
              SetSizeLoc(Query.Fields.FieldByName('MY_LAT').AsString),
              PADIExport.Win1251);
            Write(f, tmp);
          end
          else
          begin
            tmp := '<MY_LAT' + dmFunc.StringToADIF(DefMyLAT, PADIExport.Win1251);
            Write(f, tmp);
          end;

        if exportAdiSet.fMY_LON then
          if Query.Fields.FieldByName('MY_LON').AsString <> '' then
          begin
            tmp := '<MY_LON' + dmFunc.StringToADIF(
              SetSizeLoc(Query.Fields.FieldByName('MY_LON').AsString),
              PADIExport.Win1251);
            Write(f, tmp);
          end
          else
          begin
            tmp := '<MY_LON' + dmFunc.StringToADIF(DefMyLON, PADIExport.Win1251);
            Write(f, tmp);
          end;

        Write(f, '<EOR>'#13#10);

        Inc(Info.RecCount);
        Synchronize(@ToForm);
        Query.Next;

        if Terminated then
          Exit;

      except
        on E: Exception do
        begin
          Write(f, '<EOR>'#13#10);
          WriteLn(ExceptFile, 'ExportThread:' + E.ClassName + ':' +
            E.Message + ' NumberString:' + IntToStr(Info.RecCount + 1));
          Query.Next;
          Continue;
        end;
      end;
    end;

  finally
    CloseFile(f);
    Info.Result := True;
    Synchronize(@ToForm);
    FreeAndNil(Query);
  end;
end;


constructor TExportADIFThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TExportADIFThread.ToForm;
begin
  Info.From := 'ADIF';
  if Info.ErrorCode <> 0 then
    Application.MessageBox(PChar(rErrorOpenFile + ' ' + IntToStr(IOResult)),
      PChar(rError), mb_ok + mb_IconError);
  if FromForm = 'ExportAdifForm' then
    exportAdifForm.FromExportThread(Info);
  if FromForm = 'BackupAdifForm' then
    ProgressBackupForm.FromExportThread(Info);
end;

procedure TExportADIFThread.Execute;
begin
  ADIFExport(PADIExport);
end;

end.
