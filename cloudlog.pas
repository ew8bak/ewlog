(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit cloudlog;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, ssl_openssl, qso_record;

resourcestring
  rAnswerServer = 'Server response:';
  rErrorSendingSata = 'Error sending data';
  rRecordAddedSuccessfully = 'Record added successfully';
  rNoEntryAdded = 'No entry added! Perhaps a duplicate!';
  rUnknownUser = 'Unknown user! See settings';

const
  UploadURL = '/index.php/api/qso/';

type
  TCloudLogSentEvent = procedure of object;

  TSendCloudLogThread = class(TThread)
  protected
    procedure Execute; override;
    procedure ShowResult;
    function SendCloudLog(SendQSOr: TQSO): boolean;
  private
    result_mes: string;
  public
    SendQSO: TQSO;
    server: string;
    key: string;
    OnCloudLogSent: TCloudLogSentEvent;
    constructor Create;
  end;

var
  SendCloudLogThread: TSendCloudLogThread;
  dataStream: TMemoryStream;
  uploadok: boolean;


implementation

uses Forms, LCLType, HTTPSend, dmFunc_U;

function TSendCloudLogThread.SendCloudLog(SendQSOr: TQSO): boolean;
var
  logdata, url: string;
  res: TStringList;

  procedure AddData(const datatype, Data: string);
  begin
    if Data <> '' then
      logdata := logdata + Format('<%s:%d>%s', [datatype, Length(Data), Data]);
  end;

begin
  dataStream := TMemoryStream.Create;
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
  AddData('COMMENT', SendQSOr.ShortNote);
  AddData('QTH', SendQSOr.OmQTH);
  AddData('NAME', SendQSOr.OmName);
  AddData('STATE', SendQSOr.State0);
  AddData('QSLMSG', SendQSOr.QSLInfo);
  AddData('GRIDSQUARE', SendQSOr.Grid);
  Delete(SendQSOr.QSOBand, length(SendQSOr.QSOBand) - 2, 1);
  AddData('FREQ', SendQSOr.QSOBand);
  AddData('LOG_PGM', 'EWLog');
  logdata := logdata + '<EOR>';
  url := '{"key":"' + key + '", "type":"adif", "string":"' + logdata + '"}';
  res := TStringList.Create;
  try
    try
      uploadok := HttpPostURL(server+UploadURL, url, dataStream);
    except
      on E: Exception do
        result_mes := E.Message;
    end;
  finally
  end;
  if uploadok then
  begin
    try
      res := TStringList.Create;
      dataStream.Position := 0;
      res.LoadFromStream(dataStream);
      if Pos('"status":"created"', Trim(res.Text)) > 0 then
        Result := True
      else
      begin
        Result := False;
        result_mes := res.Text;
      end;
    finally
      res.Destroy;
      dataStream.Free;
    end;
  end;

end;

constructor TSendCloudLogThread.Create;
begin
  FreeOnTerminate := True;
  OnCloudLogSent := nil;
  inherited Create(True);
end;

procedure TSendCloudLogThread.ShowResult;
begin
  if Length(result_mes) > 0 then
    Application.MessageBox(PChar(rAnswerServer + result_mes),
      'CloudLog', MB_ICONEXCLAMATION);
end;

procedure TSendCloudLogThread.Execute;
begin
  if SendCloudLog(SendQSO) then
    if Assigned(OnCloudLogSent) then
      Synchronize(OnCloudLogSent);
  Synchronize(@ShowResult);
end;

end.
