(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit eqsl_file_upload;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, fphttpclient;

const
  UploadURL = 'https://www.eqsl.cc/qslcard/ImportADIF.cfm';

type
  TeqslFileUploadThread = class(TThread)
  protected
    procedure Execute; override;
  private
    response: string;
    procedure SendFile(FileName: string);
    procedure ShowResult;

  public
    FileName: string;
    constructor Create;
  end;

var
  eqslFileUploadThread: TeqslFileUploadThread;


implementation

uses Forms, LCLType;

procedure TeqslFileUploadThread.SendFile(FileName: string);
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
  res : TStringList;
begin
  try
    res := TStringList.Create;
    Document := TMemoryStream.Create;
    HTTP := TFPHttpClient.Create(nil);
    HTTP.AddHeader('Content-Type', 'application/json; charset=UTF-8');
    HTTP.AddHeader('Accept', 'application/json');
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
    HTTP.AllowRedirect := True;
    HTTP.FileFormPost(UploadURL, 'Filename', FileName, Document);
    Document.Position := 0;
    res.LoadFromStream(Document);
    response := res.Text;
  finally
    Synchronize(@ShowResult);
    FreeAndNil(Document);
    FreeAndNil(HTTP);
    FreeAndNil(res);
  end;
end;

procedure TeqslFileUploadThread.ShowResult;
begin
  if Length(response) > 0 then
    Application.MessageBox(PChar(response),
      'eQSL', MB_ICONEXCLAMATION);
end;

constructor TeqslFileUploadThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TeqslFileUploadThread.Execute;
begin
  SendFile(FileName);
end;

end.
