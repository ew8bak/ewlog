unit DownloadUpdates;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, ssl_openssl, LazFileUtils, LazUTF8;

type
  TDownUpdThread = class(TThread)
  protected
    procedure Execute; override;
    function DownUpdates(file_name, directory, file_url: string): boolean;
    function GetSize(URL: string): int64;
  private
  public
    name_file: string;
    name_directory: string;
    url_file: string;
    result_mes: string;
    SaveFile: string;
    importFlag: boolean;
    constructor Create;
    procedure ShowResult;
  end;

var
  DownUpdThread: TDownUpdThread;

implementation

uses Forms, LCLType, HTTPSend, dmFunc_U, UpdateForm_U;

function TDownUpdThread.DownUpdates(file_name, directory, file_url: string): boolean;
var
  HTTP: THTTPSend;
begin
  Result := False;
  try
    HTTP := THTTPSend.Create;
    if HTTP.HTTPMethod('GET', file_url) then
    begin
      if FileExists(directory + file_name) then
        DeleteFileUTF8(directory + file_name);
      HTTP.Document.SaveToFile(directory + file_name);
    end;
  finally
    HTTP.Free;
    Result := True;
  end;
end;

function TDownUpdThread.GetSize(URL: string): int64;
var
  i: integer;
  size: string;
  ch: char;
begin
  Result := -1;
  with THTTPSend.Create do
    if HTTPMethod('HEAD', URL) then
    begin
      for I := 0 to Headers.Count - 1 do
      begin
        if pos('content-length', lowercase(Headers[i])) > 0 then
        begin
          size := '';
          for ch in Headers[i] do
            if ch in ['0'..'9'] then
              size := size + ch;
          Result := StrToInt(size) + Length(Headers.Text);
          break;
        end;
      end;
      Free;
    end;
end;

constructor TDownUpdThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TDownUpdThread.ShowResult;
begin
  // if Length(result_mes) > 0 then
  Update_Form.CheckVersion;
end;

procedure TDownUpdThread.Execute;
begin
  if DownUpdates(name_file, name_directory, url_file) then
    Synchronize(@ShowResult);
end;

end.
