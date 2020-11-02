unit CloudLogCAT;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, ssl_openssl, qso_record;

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

uses Forms, LCLType, HTTPSend, dmFunc_U;

procedure TCloudLogCATThread.SendRadio(CatData: TCatData);
var
  HTTP: THTTPSend;
  temp: TStringStream;
  Response: TStringList;
begin
  try
    HTTP := THTTPSend.Create;
    temp := TStringStream.Create('');
    Response := TStringList.Create;
    HTTP.MimeType := 'application/json';
    temp.Size := 0;
    temp.WriteString('{"key":"' + CatData.key + '", "radio":"' +
      CatData.radio + '","frequency":' + CatData.freq + ',"mode":"' +
      CatData.mode + '","timestamp":"' + CatData.dt + '"}');
    HTTP.Document.LoadFromStream(temp);
    if HTTP.HTTPMethod('POST', CatData.address + UploadURL) then
    begin
      Response.LoadFromStream(HTTP.Document);
    end;
  finally
    temp.Free;
    HTTP.Free;
    Response.Free;
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
