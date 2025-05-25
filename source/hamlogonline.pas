(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Ulazdimir Karpenka (EW8BAK)                                    *
 *                                                                         *
 ***************************************************************************)

unit hamlogonline;

{$mode ObjFPC}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, qso_record, fphttpclient, LazUTF8;

resourcestring
  rAnswerServer = 'Server response:';
  rErrorSendingSata = 'Error sending data';
  rRecordAddedSuccessfully = 'Record added successfully';
  rNoEntryAdded = 'No entry added! Perhaps a duplicate!';
  rUnknownUser = 'Unknown user! See settings';

const
  UploadURL = 'https://hamlog.online/api/agent/v2/';

type
  THAMLogOnlineSentEvent = procedure of object;

  TSendHAMLogOnlineThread = class(TThread)
  protected
    procedure Execute; override;
    procedure ShowResult;
    function SendHAMLogOnline(SendQSOr: TQSO): boolean;
  private
    result_mes: string;
    uploadok: boolean;
    Done: boolean;
  public
    SendQSO: TQSO;
    CurrentCallsign: string;
    apikey: string;
    OnHAMLogOnlineSent: THAMLogOnlineSentEvent;
    constructor Create;
  end;

var
  SendHAMLogOnlineThread: TSendHAMLogOnlineThread;

implementation

uses Forms, LCLType, dmFunc_U, MainFuncDM;

function TSendHAMLogOnlineThread.SendHAMLogOnline(SendQSOr: TQSO): boolean;
var
  logdata, url: string;
  res: TStringList;
  HTTP: TFPHttpClient;
  Document: TMemoryStream;

  procedure AddData(const datatype, Data: string);
  begin
    if Data <> '' then
      logdata := logdata + Format('<%s:%d>%s', [datatype, UTF8Length(Data), Data]);
  end;

begin
  try
    Result := False;
    HTTP := TFPHttpClient.Create(nil);
    res := TStringList.Create;
    Document := TMemoryStream.Create;
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'HAMLOG Agent 1.2.0');
    HTTP.AddHeader('Content-Type', 'application/json; charset=UTF-8');

    AddData('adif_ver', '3.1.0');
    AddData('programid', 'HAMLOG Agent');
    AddData('programversion', '1.2.0');
    logdata := logdata + '<EOH>';
    AddData('CALL', SendQSOr.CallSing);
    AddData('station_callsign', CurrentCallsign);
    AddData('QSO_DATE', FormatDateTime('yyyymmdd', SendQSOr.QSODate));
    AddData('qso_date_off', FormatDateTime('yyyymmdd', SendQSOr.QSODate));
    SendQSOr.QSOTime := StringReplace(SendQSOr.QSOTime, ':', '', [rfReplaceAll]);
    AddData('TIME_ON', SendQSOr.QSOTime);
    AddData('time_off', SendQSOr.QSOTime);
    AddData('BAND', dmFunc.GetBandFromFreq(SendQSOr.QSOBand));
    AddData('MODE', SendQSOr.QSOMode);
    AddData('SUBMODE', SendQSOr.QSOSubMode);
    AddData('RST_SENT', SendQSOr.QSOReportSent);
    AddData('RST_RCVD', SendQSOr.QSOReportRecived);
    AddData('COMMENT', SendQSOr.ShortNote);
    AddData('QTH', SendQSOr.OmQTH);
    AddData('NAME', SendQSOr.OmName);
    AddData('STATE', SendQSOr.State0);
    AddData('QSLMSG', SendQSOr.QSLInfo);
    AddData('GRIDSQUARE', SendQSOr.Grid);
    AddData('my_gridsquare', SendQSOr.My_Grid);
    Delete(SendQSOr.QSOBand, length(SendQSOr.QSOBand) - 2, 1);
    AddData('FREQ', SendQSOr.QSOBand);
    logdata := logdata + '<EOR>';

    url := '{' + '"ADIFADD": {' + '"ADIFDATA": "' + logdata +
      '",' + '"APIKEY": "' + apikey + '"' + '}' + '}';
    try
      HTTP.FormPost(UploadURL, url, Document);
      if (HTTP.ResponseStatusCode = 200) or (HTTP.ResponseStatusCode = 201) then
        uploadok := True;
    except
      on E: Exception do
        result_mes := E.Message;
    end;
    if uploadok then
    begin
      Document.Position := 0;
      res.LoadFromStream(Document);
      if Pos('"STATUS":"OK"', Trim(res.Text)) > 0 then
      begin
        Result := True;
        Done := Result;
      end
      else
      begin
        Result := False;
        result_mes := res.Text;
      end;

      if not SendQSOr.Auto then
        if pos('"STATUS":"OK"', Res.Text) > 0 then
          result_mes := rRecordAddedSuccessfully;
      if pos('"ERROR":', Res.Text) > 0 then
        result_mes := Res.Text;
    end;

  finally
    FreeAndNil(res);
    FreeAndNil(HTTP);
    FreeAndNil(Document);
  end;
end;

constructor TSendHAMLogOnlineThread.Create;
begin
  FreeOnTerminate := True;
  OnHAMLogOnlineSent := nil;
  inherited Create(True);
end;

procedure TSendHAMLogOnlineThread.ShowResult;
begin
  if Done then
    MainFunc.UpdateQSL('HAMLOGONLINE_QSO_UPLOAD_STATUS', '1', SendQSO);
  if Length(result_mes) > 0 then
    Application.MessageBox(PChar(rAnswerServer + result_mes),
      PChar('HAMLogOnline -> ' + SendQSO.CallSing), MB_ICONEXCLAMATION);
end;

procedure TSendHAMLogOnlineThread.Execute;
begin
  if SendHAMLogOnline(SendQSO) then
    if Assigned(OnHAMLogOnlineSent) then
      Synchronize(OnHAMLogOnlineSent);
  Synchronize(@ShowResult);
end;

end.
