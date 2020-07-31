unit MainFuncDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, RegExpr, qso_record, Dialogs, ResourceStr,
  prefix_record, LazUTF8;

type

  { TMainFunc }

  TMainFunc = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    SearchPrefixQuery: TSQLQuery;
  public
    procedure SaveQSO(var SQSO: TQSO);
    procedure GetDistAzim(la, lo: string; var Distance, Azimuth: string);
    function SearchPrefix(Callsign, Grid: string): TPFXR;

  end;

var
  MainFunc: TMainFunc;


implementation

uses InitDB_dm, dmFunc_U, MainForm_U;

{$R *.lfm}

function TMainFunc.SearchPrefix(Callsign, Grid: string): TPFXR;
var
  i, j: integer;
  La, Lo: currency;
  PFXR: TPFXR;
begin
  if UniqueCallsList.IndexOf(Callsign) > -1 then
  begin
    with SearchPrefixQuery do
    begin
      Close;
      SQL.Text := 'SELECT * FROM UniqueCalls WHERE _id = "' +
        IntToStr(UniqueCallsList.IndexOf(Callsign)) + '"';
      Open;
      PFXR.Country := FieldByName('Country').AsString;
      PFXR.ARRLPrefix := FieldByName('ARRLPrefix').AsString;
      PFXR.Prefix := FieldByName('Prefix').AsString;
      PFXR.CQZone := FieldByName('CQZone').AsString;
      PFXR.ITUZone := FieldByName('ITUZone').AsString;
      PFXR.Continent := FieldByName('Continent').AsString;
      PFXR.Latitude := FieldByName('Latitude').AsString;
      PFXR.Longitude := FieldByName('Longitude').AsString;
      PFXR.DXCCNum := FieldByName('DXCC').AsInteger;
    end;
    if (Grid <> '') and dmFunc.IsLocOK(Grid) then
    begin
      dmFunc.CoordinateFromLocator(Grid, La, Lo);
      PFXR.Latitude := CurrToStr(La);
      PFXR.Longitude := CurrToStr(Lo);
    end;
    GetDistAzim(PFXR.Latitude, PFXR.Longitude, PFXR.Distance, PFXR.Azimuth);
    Exit;
  end;

  for i := 0 to PrefixProvinceCount do
  begin
    if (PrefixExpProvinceArray[i].reg.Exec(Callsign)) and
      (PrefixExpProvinceArray[i].reg.Match[0] = Callsign) then
    begin
      with SearchPrefixQuery do
      begin
        Close;
        SQL.Text := 'SELECT * FROM Province WHERE _id = "' +
          IntToStr(PrefixExpProvinceArray[i].id) + '"';
        Open;
        PFXR.Country := FieldByName('Country').AsString;
        PFXR.ARRLPrefix := FieldByName('ARRLPrefix').AsString;
        PFXR.Prefix := FieldByName('Prefix').AsString;
        PFXR.CQZone := FieldByName('CQZone').AsString;
        PFXR.ITUZone := FieldByName('ITUZone').AsString;
        PFXR.Continent := FieldByName('Continent').AsString;
        PFXR.Latitude := FieldByName('Latitude').AsString;
        PFXR.Longitude := FieldByName('Longitude').AsString;
        PFXR.DXCCNum := FieldByName('DXCC').AsInteger;
        PFXR.TimeDiff := FieldByName('TimeDiff').AsInteger;
      end;
      if (Grid <> '') and dmFunc.IsLocOK(Grid) then
      begin
        dmFunc.CoordinateFromLocator(Grid, La, Lo);
        PFXR.Latitude := CurrToStr(La);
        PFXR.Longitude := CurrToStr(Lo);
      end;
      GetDistAzim(PFXR.Latitude, PFXR.Longitude, PFXR.Distance, PFXR.Azimuth);
      Exit;
    end;
  end;

  for j := 0 to PrefixARRLCount do
  begin
    if (PrefixExpARRLArray[j].reg.Exec(Callsign)) and
      (PrefixExpARRLArray[j].reg.Match[0] = Callsign) then
    begin
      with SearchPrefixQuery do
      begin
        Close;
        SQL.Text := 'SELECT * FROM CountryDataEx WHERE _id = "' +
          IntToStr(PrefixExpARRLArray[j].id) + '"';
        Open;
        if (FieldByName('Status').AsString = 'Deleted') then
        begin
          PrefixExpARRLArray[j].reg.ExecNext;
          Exit;
        end;
      end;
      PFXR.Country := SearchPrefixQuery.FieldByName('Country').AsString;
      PFXR.ARRLPrefix := SearchPrefixQuery.FieldByName('ARRLPrefix').AsString;
      PFXR.Prefix := SearchPrefixQuery.FieldByName('ARRLPrefix').AsString;
      PFXR.CQZone := SearchPrefixQuery.FieldByName('CQZone').AsString;
      PFXR.ITUZone := SearchPrefixQuery.FieldByName('ITUZone').AsString;
      PFXR.Continent := SearchPrefixQuery.FieldByName('Continent').AsString;
      PFXR.Latitude := SearchPrefixQuery.FieldByName('Latitude').AsString;
      PFXR.Longitude := SearchPrefixQuery.FieldByName('Longitude').AsString;
      PFXR.DXCCNum := SearchPrefixQuery.FieldByName('DXCC').AsInteger;
      PFXR.TimeDiff := SearchPrefixQuery.FieldByName('TimeDiff').AsInteger;
      if (Grid <> '') and dmFunc.IsLocOK(Grid) then
      begin
        dmFunc.CoordinateFromLocator(Grid, La, Lo);
        PFXR.Latitude := CurrToStr(La);
        PFXR.Longitude := CurrToStr(Lo);
      end;
      GetDistAzim(PFXR.Latitude, PFXR.Longitude, PFXR.Distance, PFXR.Azimuth);
      Exit;
    end;
  end;
  Result:=PFXR;
end;

procedure TMainFunc.GetDistAzim(la, lo: string; var Distance, Azimuth: string);
var
  R: extended;
  azim, qra: string;
begin
  qra := '';
  azim := '';
  if (UTF8Pos('W', lo) <> 0) then
    lo := '-' + lo;
  if (UTF8Pos('S', la) <> 0) then
    la := '-' + la;
  Delete(la, length(la), 1);
  Delete(lo, length(lo), 1);
  R := dmFunc.Vincenty(QTH_LAT, QTH_LON, StrToFloat(la), StrToFloat(lo)) / 1000;
  Distance := FormatFloat('0.00', R) + ' KM';
  dmFunc.DistanceFromCoordinate(LBRecord.OpLoc, StrToFloat(la),
    strtofloat(lo), qra, azim);
  Azimuth := azim;
end;

procedure TMainFunc.DataModuleCreate(Sender: TObject);
begin
  SearchPrefixQuery := TSQLQuery.Create(nil);
  SearchPrefixQuery.DataBase := InitDB.ServiceDBConnection;
end;

procedure TMainFunc.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(SearchPrefixQuery);
end;

procedure TMainFunc.SaveQSO(var SQSO: TQSO);
var
  Query: TSQLQuery;
begin
  try
    Query := TSQLQuery.Create(nil);
    Query.Transaction := InitDB.DefTransaction;
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;

    with Query do
    begin
      SQL.Text := 'INSERT INTO ' + SQSO.NLogDB +
        '(`CallSign`, `QSODate`, `QSOTime`, `QSOBand`, `QSOMode`, `QSOSubMode`, ' +
        '`QSOReportSent`, `QSOReportRecived`, `OMName`, `OMQTH`, `State`, `Grid`, `IOTA`,'
        + '`QSLManager`, `QSLSent`, `QSLSentAdv`, `QSLSentDate`, `QSLRec`, `QSLRecDate`,'
        + '`MainPrefix`, `DXCCPrefix`, `CQZone`, `ITUZone`, `QSOAddInfo`, `Marker`, `ManualSet`,'
        + '`DigiBand`, `Continent`, `ShortNote`, `QSLReceQSLcc`, `LoTWRec`, `LoTWRecDate`,'
        + '`QSLInfo`, `Call`, `State1`, `State2`, `State3`, `State4`, `WPX`, `AwardsEx`, '
        + '`ValidDX`, `SRX`, `SRX_STRING`, `STX`, `STX_STRING`, `SAT_NAME`, `SAT_MODE`,'
        + '`PROP_MODE`, `LoTWSent`, `QSL_RCVD_VIA`, `QSL_SENT_VIA`, `DXCC`, `USERS`, `NoCalcDXCC`,'
        + '`MY_STATE`, `MY_GRIDSQUARE`, `MY_LAT`, `MY_LON`, `SYNC`)' +
        'VALUES (:CallSign, :QSODate, :QSOTime, :QSOBand, :QSOMode, :QSOSubMode, :QSOReportSent,'
        + ':QSOReportRecived, :OMName, :OMQTH, :State, :Grid, :IOTA, :QSLManager, :QSLSent,'
        + ':QSLSentAdv, :QSLSentDate, :QSLRec, :QSLRecDate, :MainPrefix, :DXCCPrefix, :CQZone,'
        + ':ITUZone, :QSOAddInfo, :Marker, :ManualSet, :DigiBand, :Continent, :ShortNote,'
        + ':QSLReceQSLcc, :LoTWRec, :LoTWRecDate, :QSLInfo, :Call, :State1, :State2, :State3, :State4,'
        + ':WPX, :AwardsEx, :ValidDX, :SRX, :SRX_STRING, :STX, :STX_STRING, :SAT_NAME,'
        + ':SAT_MODE, :PROP_MODE, :LoTWSent, :QSL_RCVD_VIA, :QSL_SENT_VIA, :DXCC, :USERS, :NoCalcDXCC, :MY_STATE, :MY_GRIDSQUARE, :MY_LAT, :MY_LON, :SYNC)';

      Params.ParamByName('CallSign').AsString := SQSO.CallSing;
      Params.ParamByName('QSODate').AsDateTime := SQSO.QSODate;
      Params.ParamByName('QSOTime').AsString := SQSO.QSOTime;
      Params.ParamByName('QSOBand').AsString := SQSO.QSOBand;
      Params.ParamByName('QSOMode').AsString := SQSO.QSOMode;
      Params.ParamByName('QSOSubMode').AsString := SQSO.QSOSubMode;
      Params.ParamByName('QSOReportSent').AsString := SQSO.QSOReportSent;
      Params.ParamByName('QSOReportRecived').AsString := SQSO.QSOReportRecived;
      Params.ParamByName('OMName').AsString := SQSO.OmName;
      Params.ParamByName('OMQTH').AsString := SQSO.OmQTH;
      Params.ParamByName('State').AsString := SQSO.State0;
      Params.ParamByName('Grid').AsString := SQSO.Grid;
      Params.ParamByName('IOTA').AsString := SQSO.IOTA;
      Params.ParamByName('QSLManager').AsString := SQSO.QSLManager;
      Params.ParamByName('QSLSent').AsString := SQSO.QSLSent;
      Params.ParamByName('QSLSentAdv').AsString := SQSO.QSLSentAdv;

      if SQSO.QSLSentDate = 'NULL' then
        Params.ParamByName('QSLSentDate').IsNull
      else
        Params.ParamByName('QSLSentDate').AsString := SQSO.QSLSentDate;
      Params.ParamByName('QSLRec').AsString := SQSO.QSLRec;
      if SQSO.QSLRecDate = 'NULL' then
        Params.ParamByName('QSLRecDate').IsNull
      else
        Params.ParamByName('QSLRecDate').AsString := SQSO.QSLRecDate;

      Params.ParamByName('MainPrefix').AsString := SQSO.MainPrefix;
      Params.ParamByName('DXCCPrefix').AsString := SQSO.DXCCPrefix;
      Params.ParamByName('CQZone').AsString := SQSO.CQZone;
      Params.ParamByName('ITUZone').AsString := SQSO.ITUZone;
      Params.ParamByName('QSOAddInfo').AsString := SQSO.QSOAddInfo;
      Params.ParamByName('Marker').AsString := SQSO.Marker;
      Params.ParamByName('ManualSet').AsInteger := SQSO.ManualSet;
      Params.ParamByName('DigiBand').AsString := SQSO.DigiBand;
      Params.ParamByName('Continent').AsString := SQSO.Continent;
      Params.ParamByName('ShortNote').AsString := SQSO.ShortNote;
      Params.ParamByName('QSLReceQSLcc').AsInteger := SQSO.QSLReceQSLcc;
      if SQSO.LotWRec = '' then
        Params.ParamByName('LoTWRec').AsInteger := 0
      else
        Params.ParamByName('LoTWRec').AsInteger := 1;
      if SQSO.LotWRecDate = 'NULL' then
        Params.ParamByName('LoTWRecDate').IsNull
      else
        Params.ParamByName('LoTWRecDate').AsString := SQSO.LotWRecDate;
      Params.ParamByName('QSLInfo').AsString := SQSO.QSLInfo;
      Params.ParamByName('Call').AsString := SQSO.Call;
      Params.ParamByName('State1').AsString := SQSO.State1;
      Params.ParamByName('State2').AsString := SQSO.State2;
      Params.ParamByName('State3').AsString := SQSO.State3;
      Params.ParamByName('State4').AsString := SQSO.State4;
      Params.ParamByName('WPX').AsString := SQSO.WPX;
      Params.ParamByName('AwardsEx').AsString := SQSO.AwardsEx;
      Params.ParamByName('ValidDX').AsString := SQSO.ValidDX;
      if SQSO.SRX = 0 then
        Params.ParamByName('SRX').IsNull
      else
        Params.ParamByName('SRX').AsInteger := SQSO.SRX;
      Params.ParamByName('SRX_STRING').AsString := SQSO.SRX_String;
      if SQSO.STX = 0 then
        Params.ParamByName('STX').IsNull
      else
        Params.ParamByName('STX').AsInteger := SQSO.STX;
      Params.ParamByName('STX_STRING').AsString := SQSO.STX_String;
      Params.ParamByName('SAT_NAME').AsString := SQSO.SAT_NAME;
      Params.ParamByName('SAT_MODE').AsString := SQSO.SAT_MODE;
      Params.ParamByName('PROP_MODE').AsString := SQSO.PROP_MODE;
      Params.ParamByName('LoTWSent').AsInteger := SQSO.LotWSent;
      if SQSO.QSL_RCVD_VIA = '' then
        Params.ParamByName('QSL_RCVD_VIA').IsNull
      else
        Params.ParamByName('QSL_RCVD_VIA').AsString := SQSO.QSL_RCVD_VIA;
      if SQSO.QSL_SENT_VIA = '' then
        Params.ParamByName('QSL_SENT_VIA').IsNull
      else
        Params.ParamByName('QSL_SENT_VIA').AsString := SQSO.QSL_SENT_VIA;
      Params.ParamByName('DXCC').AsString := SQSO.DXCC;
      Params.ParamByName('USERS').AsString := SQSO.USERS;
      Params.ParamByName('NoCalcDXCC').AsInteger := SQSO.NoCalcDXCC;
      Params.ParamByName('MY_STATE').AsString := SQSO.My_State;
      Params.ParamByName('MY_GRIDSQUARE').AsString := SQSO.My_Grid;
      Params.ParamByName('MY_LAT').AsString := SQSO.My_Lat;
      Params.ParamByName('MY_LON').AsString := SQSO.My_Lon;
      Params.ParamByName('SYNC').AsInteger := SQSO.SYNC;
      ExecSQL;
    end;
    InitDB.DefTransaction.Commit;
  finally
    FreeAndNil(Query);
  end;
end;

end.
