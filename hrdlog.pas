(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit hrdlog;

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
  UploadURL = 'http://robot.hrdlog.net/NewEntry.aspx';

type
  THRDSentEvent = procedure of object;

  TSendHRDThread = class(TThread)
  protected
    procedure Execute; override;
    procedure ShowResult;
    function SendHRD(SendQSOr:TQSO): boolean;
  private
    result_mes: string;
  public
    SendQSO: TQSO;
    user: string;
    password: string;
    callsign: string;
    OnHRDSent: THRDSentEvent;
    constructor Create;
  end;

function StripStr(t, s: string): string;

var
  SendHRDThread: TSendHRDThread;
  dataStream: TMemoryStream;
  uploadok: boolean;


implementation

uses Forms, LCLType, HTTPSend, dmFunc_U;

function StripStr(t, s: string): string;
begin
  Result := StringReplace(s, t, '', [rfReplaceAll]);
end;

function TSendHRDThread.SendHRD(SendQSOr:TQSO): boolean;
var
  logdata, url, appname: string;
  res: TStringList;


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
  dataStream := TMemoryStream.Create;
  Result := False;
  appname := 'EWLog';
  AddData('CALL', SendQSOr.CallSing);
  AddData('QSO_DATE', FormatDateTime('yyyymmdd', SendQSOr.QSODate));
  SendQSOr.QSOTime:= StringReplace(SendQSOr.QSOTime, ':', '', [rfReplaceAll]);
  AddData('TIME_ON', SendQSOr.QSOTime);
  AddData('BAND', dmFunc.GetBandFromFreq(SendQSOr.QSOBand));
  AddData('MODE', SendQSOr.QSOMode);
  AddData('SUBMODE', SendQSOr.QSOSubMode);
  AddData('RST_SENT', SendQSOr.QSOReportSent);
  AddData('RST_RCVD', SendQSOr.QSOReportRecived);
  AddData('QSLMSG', SendQSOr.QSLInfo);
  AddData('GRIDSQUARE', SendQSOr.Grid);
  Delete(SendQSOr.QSOBand, length(SendQSOr.QSOBand) - 2, 1); //Удаляем последнюю точку
  AddData('FREQ', SendQSOr.QSOBand);
  AddData('LOG_PGM', 'EWLog');
  logdata := logdata + '<EOR>';

  url := 'Callsign=' + user + '&Code=' + password + '&App=' + appname +
    '&ADIFData=' + UrlEncode(logdata);

  res := TStringList.Create;
  try
    try
      uploadok := HttpPostURL(UploadURL, url, dataStream);
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
      if res.Text <> '' then
        Result := AnsiContainsStr(res.Text, '<insert>1</insert>');
      //if inform = 1 then
      //begin
      if not SendQSOr.Auto then
        if pos('<insert>1</insert>', Res.Text) > 0 then
          result_mes := rRecordAddedSuccessfully;
        if pos('<insert>0</insert>', Res.Text) > 0 then
          result_mes := rNoEntryAdded;
        if pos('<error>Unknown user</error>', Res.Text) > 0 then
          result_mes := rUnknownUser;
      //end;
    finally
      res.Destroy;
      dataStream.Free;
    end;
  end;

end;

constructor TSendHRDThread.Create;
begin
  FreeOnTerminate := True;
  OnHRDSent := nil;
  inherited Create(True);
end;

procedure TSendHRDThread.ShowResult;
begin
  if Length(result_mes) > 0 then
    Application.MessageBox(PChar(rAnswerServer + result_mes),
      'HRDLog', MB_ICONEXCLAMATION);
end;

procedure TSendHRDThread.Execute;
begin
  if SendHRD(SendQSO) then
    if Assigned(OnHRDSent) then
      Synchronize(OnHRDSent);
  Synchronize(@ShowResult);
end;

end.
