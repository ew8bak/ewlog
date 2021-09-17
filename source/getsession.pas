(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit getSession;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, infoDM_U,
  {$IFDEF DARWIN}
  ns_url_request,
  {$ENDIF DARWIN}
  fphttpclient;

const
  QRZRU_URL: string = 'https://api.qrz.ru/login?';
  QRZCOM_URL: string = 'http://xmldata.qrz.com/xml/?';
  HAMQTH_URL: string = 'http://www.hamqth.com/xml.php?';

type
  TGetSessionThread = class(TThread)
  protected
    procedure Execute; override;
    function GetSession(user, key, fromSYS: string): boolean;
    function GetHTTPResponse(URL: string): string;
  private
    errorCode, error: string;
    session_key: string;

  public
    Login: string;
    Password: string;
    From: string;

    constructor Create;
    procedure ResultProc;
  end;

var
  GetSessionThread: TGetSessionThread;

implementation

function TGetSessionThread.GetHTTPResponse(URL: string): string;
var
{$IFDEF DARWIN}
  HTTP: TNSHTTPSendAndReceive;
{$ELSE}
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
{$ENDIF}
begin
{$IFDEF DARWIN}
  try
    HTTP := TNSHTTPSendAndReceive.Create;
    HTTP.Method := 'GET';
    HTTP.Address := URL;
    HTTP.SendAndReceive(Result);
  finally
    FreeAndNil(HTTP);
  end;
{$ELSE}
  try
    Document := TMemoryStream.Create;
    HTTP := TFPHttpClient.Create(nil);
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; EWLog)');
    HTTP.HTTPMethod('GET', URL, Document, []);
    SetString(Result, PChar(Document.Memory), Document.Size div SizeOf(char));
  finally
    FreeAndNil(HTTP);
    FreeAndNil(Document);
  end;
{$ENDIF}
end;

function TGetSessionThread.GetSession(user, key, fromSYS: string): boolean;
var
  response: string;
  AURL: string;
  beginSTR, endSTR: integer;
begin
  try
    Result := False;
    errorCode := '';
    error := '';
    if fromSYS = 'QRZRU' then
    begin
      AURL := QRZRU_URL + 'u=' + user + '&p=' + key + '';
      response := GetHTTPResponse(AURL);
      beginSTR := response.IndexOf('<session_id>');
      endSTR := response.IndexOf('</session_id>');
      if (beginSTR <> endSTR) then
        session_key := response.Substring(beginSTR + 12, endSTR - beginSTR - 12);
      beginSTR := response.IndexOf('<errorcode>');
      endSTR := response.IndexOf('</errorcode>');
      if (beginSTR <> endSTR) then
        errorCode := response.Substring(beginSTR + 11, endSTR - beginSTR - 11);
      beginSTR := response.IndexOf('<error>');
      endSTR := response.IndexOf('</error>');
      if (beginSTR <> endSTR) then
        error := response.Substring(beginSTR + 7, endSTR - beginSTR - 7);
    end;

    if fromSYS = 'QRZCOM' then
    begin
      AURL := QRZCOM_URL + 'username=' + user + ';password=' + key + ';agent=EWLog';
      response := GetHTTPResponse(AURL);
      beginSTR := response.IndexOf('<Key>');
      endSTR := response.IndexOf('</Key>');
      if (beginSTR <> endSTR) then
        session_key := response.Substring(beginSTR + 5, endSTR - beginSTR - 5);
      beginSTR := response.IndexOf('<errorcode>');
      endSTR := response.IndexOf('</errorcode>');
      if (beginSTR <> endSTR) then
        errorCode := response.Substring(beginSTR + 11, endSTR - beginSTR - 11);
      beginSTR := response.IndexOf('<Error>');
      endSTR := response.IndexOf('</Error>');
      if (beginSTR <> endSTR) then
        error := response.Substring(beginSTR + 7, endSTR - beginSTR - 7);
    end;

    if (fromSYS = 'HAMQTH') or (fromSYS = '') then
    begin
      AURL := HAMQTH_URL + 'u=' + user + '&p=' + key + '';
      response := GetHTTPResponse(AURL);
      beginSTR := response.IndexOf('<session_id>');
      endSTR := response.IndexOf('</session_id>');
      if (beginSTR <> endSTR) then
        session_key := response.Substring(beginSTR + 12, endSTR - beginSTR - 12);
      beginSTR := response.IndexOf('<error>');
      endSTR := response.IndexOf('</error>');
      if (beginSTR <> endSTR) then
        error := response.Substring(beginSTR + 7, endSTR - beginSTR - 7);
    end;

    if (Length(session_key) > 0) or (Length(error) > 0) or (Length(errorCode) > 0) then
      Result := True;

  except
    on E: Exception do
      error := 'GetSessionThread:' + E.Message;
  end;
end;

constructor TGetSessionThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TGetSessionThread.ResultProc;
begin
  InfoDM.SyncFromThreadSession(session_key, error, errorCode);
end;

procedure TGetSessionThread.Execute;
begin
  if GetSession(Login, Password, From) then
    Synchronize(@ResultProc);
end;

end.
