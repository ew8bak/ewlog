(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit dmContest_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, StdCtrls, InitDB_dm, qso_record, prefix_record,
  MainFuncDM, dmFunc_U, serverDM_u;

type
  TdmContest = class(TDataModule)
  private

  public
    procedure LoadContestName(var CBContest: TComboBox);
    procedure SaveQSOContest(SQSO: TQSO);
    procedure LoadBands(Mode: string; var CBBand: TComboBox);
    procedure SaveIni;
    function ContestNameToADIf(contestName: string): string;
    function CheckTourTime(Callsign, TourTime, ContestSession: string): boolean;
    function AddZero(number: integer): string;

  end;

var
  dmContest: TdmContest;

implementation

{$R *.lfm}

function TdmContest.AddZero(number: integer): string;
begin
  if (Length(IntToStr(number)) > 0) and (Length(IntToStr(number)) <= 1) then
  begin
    Result := '00' + IntToStr(number);
    Exit;
  end;

  if (Length(IntToStr(number)) > 1) and (Length(IntToStr(number)) <= 2) then
  begin
    Result := '0' + IntToStr(number);
    Exit;
  end;

  if Length(IntToStr(number)) > 2 then
  begin
    Result := IntToStr(number);
    Exit;
  end;
end;

procedure TdmContest.SaveIni;
begin
  INIFile.WriteInteger('Contest', 'ContestLastNumber', IniSet.ContestLastNumber);
  INIFile.WriteString('Contest', 'ContestName', IniSet.ContestName);
  INIFile.WriteInteger('Contest', 'TourTime', IniSet.ContestTourTime);
  INIFile.WriteString('Contest', 'ContestSession', IniSet.ContestSession);
end;

function TdmContest.CheckTourTime(Callsign, TourTime, ContestSession: string): boolean;
var
  Query: TSQLQuery;
begin
  try
    Query := TSQLQuery.Create(nil);
    Query.SQL.Text := 'SELECT UnUsedIndex FROM ' + LBRecord.LogTable +
      ' WHERE ContestSession = ' + QuotedStr(ContestSession) + ' AND ' +
      ' CallSign = ' + QuotedStr(Callsign) + ' AND ';
    if DBRecord.CurrentDB = 'SQLite' then
    begin
      Query.DataBase := InitDB.SQLiteConnection;
      Query.SQL.Add('QSOTime > time(''now'', ''-' + TourTime + ' minutes'')');
    end
    else
    begin
      Query.DataBase := InitDB.MySQLConnection;
      Query.SQL.Add('STR_TO_DATE(QSOTime, ''%h:%i'') > UTC_TIMESTAMP() - INTERVAL ' +
        TourTime + ' MINUTE');
    end;

    Query.Open;
    if Query.RecordCount > 0 then
      Result := False
    else
      Result := True;
  finally
    FreeAndNil(Query);
  end;
end;

procedure TdmContest.LoadBands(Mode: string; var CBBand: TComboBox);
var
  i: integer;
begin
  CBBand.Items.Clear;
  for i := 0 to High(MainFunc.LoadBands(Mode)) do
    if IniSet.showBand then
      CBBand.Items.Add(MainFunc.LoadBands(Mode)[i])
    else
      CBBand.Items.Add(dmFunc.GetBandFromFreq(MainFunc.LoadBands(Mode)[i]));
end;

procedure TdmContest.SaveQSOContest(SQSO: TQSO);
var
  PFXR: TPFXR;
begin
  PFXR := MainFunc.SearchPrefix(SQSO.CallSing, SQSO.Grid);
  SQSO.MainPrefix := PFXR.Prefix;
  SQSO.DXCCPrefix := PFXR.ARRLPrefix;
  SQSO.CQZone := PFXR.CQZone;
  SQSO.ITUZone := PFXR.ITUZone;
  SQSO.Continent := PFXR.Continent;
  SQSO.Call := dmFunc.ExtractCallsign(SQSO.CallSing);
  SQSO.WPX := dmFunc.ExtractWPXPrefix(SQSO.CallSing);
  SQSO.DXCC := IntToStr(PFXR.DXCCNum);
  SQSO.IOTA := '';
  SQSO.QSLManager := '';
  SQSO.QSOAddInfo := '';
  SQSO.Marker := '0';
  SQSO.State1 := '';
  SQSO.State2 := '';
  SQSO.State3 := '';
  SQSO.State4 := '';
  SQSO.QSLInfo := '';
  SQSO.SAT_NAME := '';
  SQSO.SAT_MODE := '';
  SQSO.PROP_MODE := '';
  SQSO.QSLRec := '0';
  SQSO.ManualSet := 0;
  SQSO.QSLReceQSLcc := 0;
  SQSO.LotWRec := '';
  SQSO.QSLSent := '0';
  SQSO.QSLSentAdv := 'F';
  SQSO.ManualSet := 0;
  SQSO.ValidDX := '1';
  SQSO.LotWSent := 0;
  SQSO.QSL_RCVD_VIA := '';
  SQSO.QSL_SENT_VIA := '';
  SQSO.USERS := '';
  SQSO.NoCalcDXCC := 0;
  SQSO.SYNC := 0;
  SQSO.My_State := '';
  SQSO.My_Grid := '';
  SQSO.My_Lat := '';
  SQSO.My_Lon := '';
  SQSO.My_Grid := LBRecord.OpLoc;
  SQSO.NLogDB := LBRecord.LogTable;

  MainFunc.SaveQSO(SQSO);
  if IniSet.WorkOnLAN then
    ServerDM.SendBroadcastADI(ServerDM.CreateADIBroadcast(SQSO, 'ANY', 'TRUE'));
end;

function TdmContest.ContestNameToADIf(contestName: string): string;
var
  Query: TSQLQuery;
begin
  Result := '';
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := InitDB.ServiceDBConnection;
      Query.SQL.Text := 'SELECT * FROM contest WHERE name = ' + QuotedStr(contestName);
      Query.Open;
      if Result <> '' then
        Result := Query.Fields[2].AsString
      else
        Result := contestName;
      Query.Clear;
    finally
      FreeAndNil(Query);
    end;
  except
    on E: Exception do
    begin
      WriteLn(ExceptFile, 'ContestNameToADIf:' + E.ClassName + ':' + E.Message);
    end;
  end;

end;

procedure TdmContest.LoadContestName(var CBContest: TComboBox);
var
  Query: TSQLQuery;
begin
  try
    try
      Query := TSQLQuery.Create(nil);
      CBContest.Items.Clear;
      Query.DataBase := InitDB.ServiceDBConnection;
      Query.SQL.Text := 'SELECT * FROM contest';
      Query.Open;
      while not Query.EOF do
      begin
        CBContest.Items.Add(Query.Fields[1].AsString);
        Query.Next;
      end;
      Query.Close;
    finally
      if CBContest.Items.IndexOf(IniSet.ContestName) <> -1 then
        CBContest.ItemIndex := CBContest.Items.IndexOf(IniSet.ContestName)
      else if IniSet.ContestName <> '' then
        CBContest.Text := IniSet.ContestName
      else
        CBContest.ItemIndex := 0;
      FreeAndNil(Query);
    end;
  except
    on E: Exception do
    begin
      WriteLn(ExceptFile, 'LoadContestName:' + E.ClassName + ':' + E.Message);
    end;
  end;
end;

end.
