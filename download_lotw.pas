unit download_lotw;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, ssl_openssl, ResourceStr;

const
  LotW_URL = 'https://lotw.arrl.org/lotwuser/lotwreport.adi?';

type
  TLoTWThread = class(TThread)
  protected
    procedure Execute; override;
    function DownLoTW(lotw_user, lotw_password, lotw_date: string): boolean;
  private
  public
    user_lotw: string;
    password_lotw: string;
    date_lotw: string;
    result_mes: string;
    SaveFile: string;
    constructor Create;
    procedure ShowResult;
  end;

var
  LoTWThread: TLoTWThread;

implementation

uses Forms, LCLType, HTTPSend, dmFunc_U, ServiceForm_U;

function TLoTWThread.DownLoTW(lotw_user, lotw_password, lotw_date: string): boolean;
var
  fullURL: string;
  HTTP: THTTPSend;
  response: string;
begin
  Result := False;
  response := '';
  try
    {$IFDEF UNIX}
    SaveFile := SysUtils.GetEnvironmentVariable('HOME') + '/EWLog/LotW_' +
      lotw_date + '.adi';
    {$ELSE}
    SaveFile := SysUtils.GetEnvironmentVariable('SystemDrive') +
      SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) + '/EWLog/LotW_' +
      lotw_date + '.adi';
    {$ENDIF UNIX}
    fullURL := LotW_URL + 'login=' + lotw_user + '&password=' +
      lotw_password + '&qso_query=1&qso_qsldetail="yes"' + '&qso_qslsince=' + lotw_date;
    HTTP := THTTPSend.Create;
    if HTTP.HTTPMethod('GET', fullURL) then
    begin
      SetString(response, PChar(HTTP.Document.Memory), HTTP.Document.Size div
        SizeOf(char));
      if Pos('Username/password incorrect', response) > 0 then
        result_mes := rStatusIncorrect
      else
      begin
        HTTP.Document.SaveToFile(SaveFile);
        result_mes := rStatusSaveFile;
      end;
    end;
  finally
    HTTP.Free;
    Result := True;
  end;
end;

constructor TLoTWThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TLoTWThread.ShowResult;
begin
  if Length(result_mes) > 0 then
    ServiceForm.Label6.Caption := result_mes;
  if result_mes = rStatusSaveFile then
  ServiceForm.LotWImport(SaveFile);
end;

procedure TLoTWThread.Execute;
begin
  if DownLoTW(user_lotw, password_lotw, date_lotw) then
    Synchronize(@ShowResult);
end;

end.
