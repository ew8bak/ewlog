(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit DownloadUpdates;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, LazFileUtils, LazUTF8, fphttpclient;

type
  TDownUpdThread = class(TThread)
  protected
    procedure Execute; override;
    function DownUpdates(file_name, directory, file_url, file_urlssl: string): boolean;
  private
  public
    name_file: string;
    name_directory: string;
    url_file: string;
    urlssl_file: string;
    result_mes: string;
    SaveFile: string;
    importFlag: boolean;
    constructor Create;
    procedure ShowResult;
  end;

var
  DownUpdThread: TDownUpdThread;

implementation

uses Forms, LCLType, dmFunc_U, UpdateForm_U, ResourceStr;

function TDownUpdThread.DownUpdates(file_name, directory, file_url,
  file_urlssl: string): boolean;
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
begin
  Result := False;
  try
    HTTP := TFPHttpClient.Create(nil);
    Document := TMemoryStream.Create;
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; ewlog)');
    HTTP.Get(file_urlssl, Document);
    if HTTP.ResponseStatusCode = 200 then
    begin
      if FileExists(directory + file_name) then
        DeleteFileUTF8(directory + file_name);
      Document.SaveToFile(directory + file_name);
      Result := True;
    end;

  finally
    FreeAndNil(Document);
    FreeAndNil(HTTP);
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
  if DownUpdates(name_file, name_directory, url_file, urlssl_file) then
    Synchronize(@ShowResult);
end;

end.
