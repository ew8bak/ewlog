(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit GetPhotoFromInternet;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, LazFileUtils, fphttpclient;

type
  TGetPhotoThread = class(TThread)
  protected
    procedure Execute; override;
    procedure GetPhoto(url: string);
  private
    PhotoStream: TMemoryStream;
  public
    url: string;
    Call: string;
    Main: boolean;
    constructor Create;
    procedure ResultProc;
  end;

var
  GetPhotoThread: TGetPhotoThread;

implementation

uses infoDM_U;

procedure TGetPhotoThread.GetPhoto(url: string);
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
begin
  try
    PhotoStream := TMemoryStream.Create;
    Document := TMemoryStream.Create;
    HTTP := TFPHttpClient.Create(nil);
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
    HTTP.HTTPMethod('GET', url, Document, []);
    if HTTP.ResponseStatusCode = 200 then
      PhotoStream.LoadFromStream(Document);
  finally
    FreeAndNil(HTTP);
    FreeAndNil(Document);
    Synchronize(@ResultProc);
  end;
end;

constructor TGetPhotoThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TGetPhotoThread.ResultProc;
begin
  InfoDM.ViewPhoto(PhotoStream, url);
  PhotoStream.Free;
end;

procedure TGetPhotoThread.Execute;
begin
  GetPhoto(url);
end;

end.
