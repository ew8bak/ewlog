unit analyticThread;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, ssl_openssl, LazUTF8, blcksock;

const
  POST_URL = 'https://analytic.ewlog.ru/analytic.php';

type
  TanalyticThread = class(TThread)
  protected
    procedure Execute; override;
    function Upload(call_user, os_user, version_user: string;
      start_num: integer): boolean;
  private
  public
    user_call: string;
    user_os: string;
    user_version: string;
    num_start: integer;
    constructor Create;
    procedure ShowResult;
  end;

var
  analytThread: TanalyticThread;

implementation

uses Forms, LCLType, HTTPSend, dmFunc_U;

function TanalyticThread.Upload(call_user, os_user, version_user: string;
  start_num: integer): boolean;
var
  HTTP: THTTPSend;
  temp: TStringStream;
begin
  Result := False;
  try
    HTTP := THTTPSend.Create;
    temp := TStringStream.Create('');
    HTTP.MimeType := 'application/json';
    temp.Size := 0;
    temp.WriteString('{"user":"' + call_user + '", "os":"' + os_user +
      '","version":"' + version_user + '","num":' + IntToStr(start_num) +
      ',"timestamp":"' + FormatDateTime('yyyy-mm-dd hh:nn', Now) + '"}');
    HTTP.Document.LoadFromStream(temp);
    if HTTP.HTTPMethod('POST', POST_URL) then
    begin
      Result := True;
    end;
  finally
    HTTP.Free;
    temp.Free;
  end;
end;



constructor TanalyticThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TanalyticThread.ShowResult;
begin

end;

procedure TanalyticThread.Execute;
begin
  if Upload(user_call, user_os, user_version, num_start) then
    Synchronize(@ShowResult);
end;

end.
