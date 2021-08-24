(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit CloudLogCAT;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, fphttpclient;

const
  UploadURL = '/index.php/api/radio/';

type
  TCatData = record
    freq: string;
    mode: string;
    dt: string;
    key: string;
    radio: string;
    address: string;
  end;

type
  TCloudLogCATThread = class(TThread)
  protected
    procedure Execute; override;
  private
    procedure SendRadio(CatData: TCatData);

  public
    CatData: TCatData;
    constructor Create;
  end;

var
  CloudLogCATThread: TCloudLogCATThread;


implementation

uses Forms, LCLType;

procedure TCloudLogCATThread.SendRadio(CatData: TCatData);
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
  str: string;
begin
  try
    HTTP := TFPHttpClient.Create(nil);
    HTTP.AddHeader('Content-Type', 'application/json; charset=UTF-8');
    HTTP.AddHeader('Accept', 'application/json');
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
    HTTP.AllowRedirect := True;
    Document := TMemoryStream.Create;
    str := '{"key":"' + CatData.key + '", "radio":"' + CatData.radio +
      '","frequency":' + CatData.freq + ',"mode":"' + CatData.mode +
      '","timestamp":"' + CatData.dt + '"}';
    HTTP.FormPost(CatData.address + UploadURL, str, Document);
  finally
    FreeAndNil(HTTP);
    FreeAndNil(Document);
  end;
end;

constructor TCloudLogCATThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TCloudLogCATThread.Execute;
begin
  SendRadio(CatData);
end;

end.
