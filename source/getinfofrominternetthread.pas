(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit GetInfoFromInternetThread;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, LazFileUtils,
  {$IFDEF DARWIN}
  ns_url_request,
  {$ENDIF DARWIN}
  fphttpclient;

type
  TGetInfoThread = class(TThread)
  protected
    procedure Execute; override;
    function GetInfo(url: string): boolean;
  private
    resp: string;
  public
    url: string;
    constructor Create;
    procedure ResultProc;
  end;

var
  GetInfoThread: TGetInfoThread;

implementation

uses
  infoDM_U;

function TGetInfoThread.GetInfo(url: string): boolean;
var
{$IFDEF DARWIN}
  HTTP: TNSHTTPSendAndReceive;
{$ELSE}
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
{$ENDIF}
begin
  Result := False;
{$IFDEF DARWIN}
  try
    HTTP := TNSHTTPSendAndReceive.Create;
    HTTP.Method := 'GET';
    HTTP.Address := url;
    HTTP.SendAndReceive(resp);
  finally
    Result := True;
    FreeAndNil(HTTP);
  end;
{$ELSE}
  try
    Document := TMemoryStream.Create;
    HTTP := TFPHttpClient.Create(nil);
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
    HTTP.HTTPMethod('GET', url, Document, []);
    SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
  finally
    Result := True;
    FreeAndNil(HTTP);
    FreeAndNil(Document);
  end;
{$ENDIF}
end;

constructor TGetInfoThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TGetInfoThread.ResultProc;
begin
  InfoDM.GetResponseFromThread(resp);
end;

procedure TGetInfoThread.Execute;
begin
  if GetInfo(url) then
    Synchronize(@ResultProc);
end;

end.
