(*
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *                                                                         *
 ***************************************************************************
*)

unit eqsl;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, Dialogs, LazUTF8, qso_record, fphttpclient;

resourcestring
  rAnswerServer = 'Server response:';
  rErrorSendingSata = 'Error sending data';

type
  TEQSLSentEvent = procedure of object;

  TSendEQSLThread = class(TThread)
  protected
    procedure Execute; override;
    procedure ShowResult;
    function SendEQSL(SendQSOr: TQSO): boolean;
  private
    result_mes: string;
    Done: boolean;
  public
    SendQSO: TQSO;
    user: string;
    password: string;
    callsign: string;
    OnEQSLSent: TEQSLSentEvent;
    constructor Create;
  end;


function StripStr(t, s: string): string;

var
  SendEQSLThread: TSendEQSLThread;

implementation

uses Forms, LCLType, dmFunc_U, MainFuncDM;

function StripStr(t, s: string): string;
begin
  Result := StringReplace(s, t, '', [rfReplaceAll]);
end;

function TSendEQSLThread.SendEQSL(SendQSOr: TQSO): boolean;
var
  logdata, url, response: string;
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
    logdata := 'EWLog <ADIF_VER:4>1.00';
    AddData('EQSL_USER', user);
    AddData('EQSL_PSWD', password);
    logdata := logdata + '<EOH>';
    // Запись
    AddData('CALL', SendQSOr.CallSing);
    AddData('QSO_DATE', FormatDateTime('yyyymmdd', SendQSOr.QSODate));
    SendQSOr.QSOTime := StringReplace(SendQSOr.QSOTime, ':', '', [rfReplaceAll]);
    AddData('TIME_ON', SendQSOr.QSOTime);
    AddData('BAND', dmFunc.GetBandFromFreq(SendQSOr.QSOBand));
    AddData('MODE', SendQSOr.QSOMode);
    AddData('SUBMODE', SendQSOr.QSOSubMode);
    AddData('RST_SENT', SendQSOr.QSOReportSent);
    AddData('SAT_NAME', SendQSOr.SAT_NAME);
    AddData('SAT_MODE', SendQSOr.SAT_MODE);
    AddData('PROP_MODE', SendQSOr.PROP_MODE);
    AddData('QSLMSG', SendQSOr.QSLInfo);
    AddData('LOG_PGM', 'EWLog');
    logdata := logdata + '<EOR>';

    url := 'http://www.eqsl.cc/qslcard/importADIF.cfm?ADIFData=' + URLEncode(logdata);

    try
      HTTP.Get(url, Document);
      if HTTP.ResponseStatusCode = 200 then
      begin
        Document.Position := 0;
        res.LoadFromStream(Document);
        response := res.Text;
        while (res.Count > 0) and (UpperCase(Trim(res.Strings[0])) <> '<BODY>') do
          res.Delete(0);
        while (res.Count > 0) and (UpperCase(Trim(res.Strings[0])) = '<BODY>') do
          res.Delete(0);
        while (res.Count > 0) and (Trim(res.Strings[0]) = '') do
          res.Delete(0);
        if res.Count > 0 then
          response := Trim(StripStr('<BR>', res.Strings[0]));
        Result := Pos('records added', response) > 0;
        Done := Result;
        if (not Result) or not SendQSOr.Auto then
          result_mes := response;
      end
      else
        result_mes := rErrorSendingSata;
    except
      on E: Exception do
        result_mes := E.Message;
    end;
  finally
    res.Destroy;
    FreeAndNil(HTTP);
    FreeAndNil(Document);
  end;
end;

constructor TSendEQSLThread.Create;
begin
  FreeOnTerminate := True;
  OnEQSLSent := nil;
  inherited Create(True);
end;

procedure TSendEQSLThread.ShowResult;
begin
  if Done then
    MainFunc.UpdateQSL('EQSL_QSL_SENT', 'Y', SendQSO);
  if Length(result_mes) > 0 then
    Application.MessageBox(PChar(rAnswerServer + result_mes),
      'eQSL', MB_ICONEXCLAMATION);
end;

procedure TSendEQSLThread.Execute;
begin
  if SendEQSL(SendQSO) then
    if Assigned(OnEQSLSent) then
      Synchronize(OnEQSLSent);
  Synchronize(@ShowResult);
end;

end.
