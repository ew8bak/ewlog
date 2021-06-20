(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit download_lotw;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, ssl_openssl, ResourceStr, LazUTF8, blcksock;

const
  LotW_URL = 'https://lotw.arrl.org/lotwuser/lotwreport.adi?';

type
  TLoTWThread = class(TThread)
  protected
    procedure Execute; override;
    function DownLoTW(lotw_user, lotw_password, lotw_date: string): boolean;
    procedure SynaProgress(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
    procedure updSize;
    procedure updAllSize;
  private
    downSize: integer;
    AllDownSize: int64;
  public
    user_lotw: string;
    password_lotw: string;
    date_lotw: string;
    result_mes: string;
    SaveFile: string;
    importFlag: boolean;
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
  importFlag := False;
  response := '';
  try
    {$IFDEF UNIX}
    SaveFile := SysUtils.GetEnvironmentVariable('HOME') + '/EWLog/LotW_' +
      lotw_date + '.adi';
    {$ELSE}
    SaveFile := SysUtils.GetEnvironmentVariable('SystemDrive') +
      SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) +
      '/EWLog/LotW_' + lotw_date + '.adi';
    {$ENDIF UNIX}
    fullURL := LotW_URL + 'login=' + lotw_user + '&password=' +
      lotw_password + '&qso_query=1&qso_qsldetail="yes"' + '&qso_qslsince=' + lotw_date;
    HTTP := THTTPSend.Create;
    HTTP.Sock.OnStatus := @SynaProgress;
    AllDownSize := dmFunc.GetSize(fullURL);
    Synchronize(@updAllSize);
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
        importFlag := True;
      end;
    end;
  finally
    HTTP.Free;
    Result := True;
  end;
end;

procedure TLoTWThread.updAllSize;
begin
  ServiceForm.ProgressBar1.Position := 0;
  if AllDownSize > 0 then
    ServiceForm.ProgressBar1.Max := AllDownSize
  else
    ServiceForm.ProgressBar1.Max := 0;
end;

procedure TLoTWThread.updSize;
begin
  ServiceForm.DownSize := ServiceForm.DownSize + downSize;
  ServiceForm.Label7.Caption :=
    FormatFloat('0.###', ServiceForm.DownSize / 1048576) + ' ' + rMBytes;
  ServiceForm.ProgressBar1.Position := round(ServiceForm.DownSize);
end;

procedure TLoTWThread.SynaProgress(Sender: TObject; Reason: THookSocketReason;
  const Value: string);
begin
  if Reason = HR_ReadCount then
  begin
    downSize := StrToInt(Value);
    Synchronize(@updSize);
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
  if importFlag then
    ServiceForm.LotWImport(SaveFile);
end;

procedure TLoTWThread.Execute;
begin
  if DownLoTW(user_lotw, password_lotw, date_lotw) then
    Synchronize(@ShowResult);
end;

end.
