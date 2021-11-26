(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit clublog;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, qso_record, fphttpclient;

resourcestring
  rAnswerServer = 'Server response:';
  rErrorSendingSata = 'Error sending data';
  rRecordAddedSuccessfully = 'Record added successfully';
  rNoEntryAdded = 'No entry added! Perhaps a duplicate!';
  rUnknownUser = 'Unknown user! See settings';

const
  UploadURL = 'https://clublog.org/realtime.php';

type
  TClubLogSentEvent = procedure of object;

  TSendClubLogThread = class(TThread)
  protected
    procedure Execute; override;
    procedure ShowResult;
    function SendClubLog(SendQSOr: TQSO): boolean;
  private
    result_mes: string;
  public
    SendQSO: TQSO;
    user: string;
    password: string;
    callsign: string;
    OnClubLogSent: TClubLogSentEvent;
    constructor Create;
  end;

function StripStr(t, s: string): string;

var
  SendClubLogThread: TSendClubLogThread;
  uploadok: boolean;


implementation

uses Forms, LCLType, dmFunc_U;

function StripStr(t, s: string): string;
begin
  Result := StringReplace(s, t, '', [rfReplaceAll]);
end;

function TSendClubLogThread.SendClubLog(SendQSOr: TQSO): boolean;
var
  logdata, url: string;
  res: TStringList;
  HTTP: TFPHttpClient;
  Document: TMemoryStream;

  procedure AddData(const datatype, Data: string);
  begin
    if Data <> '' then
      logdata := logdata + Format('<%s:%d>%s', [datatype, Length(Data), Data]);
  end;

  function UrlEncode(s: string): string;
  var
    i: integer;
  begin
    Result := '';
    for i := 1 to Length(s) do
      case s[i] of
        ' ':
          Result := Result + '+';
        '0'..'9', 'A'..'Z', 'a'..'z', '*', '@', '.', '_', '-', '$', '!', #$27, '(', ')':
          Result := Result + s[i];
        else
          Result := Result + '%' + IntToHex(Ord(s[i]), 2);
      end;
  end;

begin
  try
    HTTP := TFPHttpClient.Create(nil);
    res := TStringList.Create;
    Document := TMemoryStream.Create;
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
    Result := False;
    AddData('CALL', SendQSOr.CallSing);
    AddData('QSO_DATE', FormatDateTime('yyyymmdd', SendQSOr.QSODate));
    SendQSOr.QSOTime := StringReplace(SendQSOr.QSOTime, ':', '', [rfReplaceAll]);
    AddData('TIME_ON', SendQSOr.QSOTime);
    AddData('BAND', dmFunc.GetBandFromFreq(SendQSOr.QSOBand));
    AddData('MODE', SendQSOr.QSOMode);
    AddData('SUBMODE', SendQSOr.QSOSubMode);
    AddData('RST_SENT', SendQSOr.QSOReportSent);
    AddData('RST_RCVD', SendQSOr.QSOReportRecived);
    AddData('QSLMSG', SendQSOr.QSLInfo);
    AddData('SAT_NAME', SendQSOr.SAT_NAME);
    AddData('SAT_MODE', SendQSOr.SAT_MODE);
    AddData('PROP_MODE', SendQSOr.PROP_MODE);
    AddData('GRIDSQUARE', SendQSOr.Grid);
    Delete(SendQSOr.QSOBand, length(SendQSOr.QSOBand) - 2, 1);
    //Удаляем последнюю точку
    AddData('FREQ', SendQSOr.QSOBand);
    AddData('LOG_PGM', 'EWLog');
    logdata := logdata + '<EOR>';

    url := 'email=' + user + '&password=' + password + '&callsign=' +
      callsign + '&api=68679acdccd815f0545873ca81eed96d9806f8f0' +
      '&adif=' + UrlEncode(logdata);
    try
      HTTP.FormPost(UploadURL, url, Document);
      if HTTP.ResponseStatusCode = 200 then
        uploadok := True;
    except
      on E: Exception do
        result_mes := E.Message;
    end;

    if uploadok then
    begin
      Document.Position := 0;
      res.LoadFromStream(Document);
      if Pos('OK', Trim(res.Text)) > 0 then
        Result := True
      else
      begin
        Result := False;
        result_mes := res.Text;
      end;
    end;
  finally
    res.Destroy;
    FreeAndNil(HTTP);
    FreeAndNil(Document);
  end;
end;

constructor TSendClubLogThread.Create;
begin
  FreeOnTerminate := True;
  OnClubLogSent := nil;
  inherited Create(True);
end;

procedure TSendClubLogThread.ShowResult;
begin
  if Length(result_mes) > 0 then
    Application.MessageBox(PChar(rAnswerServer + result_mes),
      'ClubLog', MB_ICONEXCLAMATION);
end;

procedure TSendClubLogThread.Execute;
begin
  if SendClubLog(SendQSO) then
    if Assigned(OnClubLogSent) then
      Synchronize(OnClubLogSent);
  Synchronize(@ShowResult);
end;

end.
