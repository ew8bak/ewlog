(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit download_eqslcc;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, ssl_openssl, ResourceStr, LazFileUtils, LazUTF8, blcksock;

const
  DowneQSLcc_URL = 'http://www.eqsl.cc/qslcard/DownloadInBox.cfm?';
  eQSLcc_URL = 'http://www.eqsl.cc/downloadedfiles/';
  CDWNLD = '.adi">';
  errorMess = '<H3>ERROR:';
  dateErr = '<H3>YOU HAVE NO LOG ENTRIES';

type
  TeQSLccThread = class(TThread)
  protected
    procedure Execute; override;
    function DowneQSLcc(eqslcc_user, eqslcc_password, eqslcc_date: string): boolean;
    procedure SynaProgress(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
    procedure updSize;
    procedure updAllSize;
  private
    downSize: integer;
    AllDownSize: int64;
  public
    user_eqslcc: string;
    password_eqslcc: string;
    date_eqslcc: string;
    result_mes: string;
    SaveFile: string;
    importFlag: boolean;
    constructor Create;
    procedure ShowResult;
  end;

var
  eQSLccThread: TeQSLccThread;

implementation

uses Forms, LCLType, HTTPSend, dmFunc_U, ServiceForm_U;

function TeQSLccThread.DowneQSLcc(eqslcc_user, eqslcc_password,
  eqslcc_date: string): boolean;
var
  fullURL, tmp: string;
  HTTP: THTTPSend;
  eQSLPage: TStringList;
  i: integer;
  errFlag: boolean;
begin
  Result := False;
  errFlag := False;
  importFlag := False;
  try
    HTTP := THTTPSend.Create;
    HTTP.Sock.OnStatus := @SynaProgress;
    eQSLPage := TStringList.Create;
    {$IFDEF UNIX}
    SaveFile := SysUtils.GetEnvironmentVariable('HOME') + '/EWLog/eQSLcc_' +
      eqslcc_date + '.adi';
    {$ELSE}
    SaveFile := SysUtils.GetEnvironmentVariable('SystemDrive') +
      SysToUTF8(SysUtils.GetEnvironmentVariable('HOMEPATH')) +
      '/EWLog/eQSLcc_' + eqslcc_date + '.adi';
    {$ENDIF UNIX}
    fullURL := DowneQSLcc_URL + 'UserName=' + eqslcc_user + '&Password=' +
      eqslcc_password + '&RcvdSince=' + eqslcc_date;
    if HTTP.HTTPMethod('GET', fullURL) then
    begin
      HTTP.Document.Seek(0, soBeginning);
      eQSLPage.LoadFromStream(HTTP.Document);
      if Pos(errorMess, UpperCase(eQSLPage.Text)) > 0 then
      begin
        errFlag := True;
        result_mes := rStatusIncorrect;
      end
      else
      if Pos(dateErr, UpperCase(eQSLPage.Text)) > 0 then
      begin
        result_mes := rStatusNotData;
        errFlag := True;
      end
      else
      begin
        if Pos(CDWNLD, eQSLPage.Text) > 0 then
        begin
          for i := 0 to Pred(eQSLPage.Count) do
          begin
            if Pos(CDWNLD, eQSLPage[i]) > 0 then
            begin
              tmp := copy(eQSLPage[i], pos('HREF="', eQSLPage[i]) +
                6, length(eQSLPage[i]));
              tmp := copy(eQSLPage[i], 1, pos('.adi"', eQSLPage[i]) + 3);
              tmp := ExtractFileNameOnly(tmp) + ExtractFileExt(tmp);
            end;
          end;
        end;
      end;
    end;
    HTTP.Clear;
    if not errFlag then
    begin
      fullURL := eQSLcc_URL + tmp;
      AllDownSize := dmFunc.GetSize(fullURL);
      Synchronize(@updAllSize);
      if HTTP.HTTPMethod('GET', fullURL) then
        HTTP.Document.SaveToFile(SaveFile);
      result_mes := rStatusSaveFile;
      importFlag := True;
    end;
  finally
    HTTP.Free;
    eQSLPage.Free;
    Result := True;
  end;
end;

procedure TeQSLccThread.updAllSize;
begin
  ServiceForm.ProgressBar1.Position := 0;
  if AllDownSize > 0 then
    ServiceForm.ProgressBar1.Max := AllDownSize
  else
    ServiceForm.ProgressBar1.Max := 0;
end;

procedure TeQSLccThread.updSize;
begin
  ServiceForm.DownSize := ServiceForm.DownSize + downSize;
  ServiceForm.Label7.Caption :=
    FormatFloat('0.###', ServiceForm.DownSize / 1048576) + ' ' + rMBytes;
  ServiceForm.ProgressBar1.Position := round(ServiceForm.DownSize);
end;


procedure TeQSLccThread.SynaProgress(Sender: TObject; Reason: THookSocketReason;
  const Value: string);
begin
  if Reason = HR_ReadCount then
  begin
    downSize := StrToInt(Value);
    Synchronize(@updSize);
  end;
end;

constructor TeQSLccThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TeQSLccThread.ShowResult;
begin
  if Length(result_mes) > 0 then
    ServiceForm.Label6.Caption := result_mes;
  if importFlag then
    ServiceForm.eQSLImport(SaveFile);
end;

procedure TeQSLccThread.Execute;
begin
  if DowneQSLcc(user_eqslcc, password_eqslcc, date_eqslcc) then
    Synchronize(@ShowResult);
end;

end.
