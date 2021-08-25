(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit downloadQSLthread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ResourceStr, LazFileUtils, LazUTF8, fphttpclient;

type
  TdataThread = record
    User: string;
    Password: string;
    Date: string;
    Service: string;
    DownloadAllFileSize: int64;
    DownloadedFileSize: int64;
    DownloadedPercent: integer;
    DownloadedFilePATH: string;
    StatusDownload: boolean;
    Message: string;
    Error: boolean;
    ErrorString: string;
  end;

type
  TdownloadQSLThread = class(TThread)
  protected
    procedure Execute; override;
  private
    Status: TdataThread;
    procedure DownloadQSL(ServiceData: TdataThread);
    procedure OnDataReceived(Sender: TObject; const ContentLength, CurrentPos: int64);
    procedure ClearStatus;
    function ParseDownloadURLeQSLcc(Document: TMemoryStream): string;
  public
    DataFromServiceForm: TdataThread;
    constructor Create;
    procedure ToForm;
  end;

var
  downloadQSLTThread: TdownloadQSLThread;

implementation

uses InitDB_dm, ServiceForm_U;

constructor TdownloadQSLThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TdownloadQSLThread.Execute;
begin
  DownloadQSL(DataFromServiceForm);
end;

procedure TdownloadQSLThread.ToForm;
begin
  ServiceForm.DataFromThread(Status);
end;

procedure TdownloadQSLThread.OnDataReceived(Sender: TObject;
  const ContentLength, CurrentPos: int64);
begin
  Status.DownloadAllFileSize := ContentLength;
  Status.DownloadedFileSize := CurrentPos;
  Status.DownloadedPercent := integer((Trunc((CurrentPos / ContentLength) * 100)));
  Synchronize(@ToForm);
end;

procedure TdownloadQSLThread.DownloadQSL(ServiceData: TdataThread);
const
  eQSLcc_URL = 'http://www.eqsl.cc/qslcard/DownloadInBox.cfm?';
  LoTW_URL = 'https://lotw.arrl.org/lotwuser/lotwreport.adi?';
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
  SaveFilePATH: string;
  FullURL: string;
  response: string;
begin
  try
    ClearStatus;
    HTTP := TFPHttpClient.Create(nil);
    Document := TMemoryStream.Create;
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; EWLog)');
    HTTP.OnDataReceived := @OnDataReceived;
    status.Service := ServiceData.Service;

    if ServiceData.Service = 'eQSLcc' then
    begin
      SaveFilePATH := FilePATH + 'eQSLcc_' + ServiceData.Date + '.adi';
      FullURL := eQSLcc_URL + 'UserName=' + ServiceData.User +
        '&Password=' + ServiceData.Password + '&RcvdSince=' + ServiceData.Date;
      try
        HTTP.Get(FullURL, Document);
        if HTTP.ResponseStatusCode = 200 then
        begin
          FullURL := ParseDownloadURLeQSLcc(Document);
          if FullURL <> '' then
          begin
            HTTP.Get(FullURL, Document);
            if HTTP.ResponseStatusCode = 200 then
            begin
              Document.SaveToFile(SaveFilePATH);
              Status.DownloadedFilePATH := SaveFilePATH;
              Status.Message := rStatusSaveFile;
              Status.StatusDownload := True;
              Synchronize(@ToForm);
            end;
          end;
        end;
      except
        on E: Exception do
        begin
          Status.ErrorString := E.Message;
          Status.Error := True;
          Synchronize(@ToForm);
          Exit;
        end;
      end;
      Exit;
    end;

    if ServiceData.Service = 'LoTW' then
    begin
      SaveFilePATH := FilePATH + 'LotW_' + ServiceData.Date + '.adi';
      FullURL := LotW_URL + 'login=' + ServiceData.User + '&password=' +
        ServiceData.Password + '&qso_query=1&qso_qsldetail="yes"' +
        '&qso_qslsince=' + ServiceData.Date;
      try
        HTTP.Get(FullURL, Document);
        if HTTP.ResponseStatusCode = 200 then
        begin
          SetString(response, PChar(Document.Memory), Document.Size div SizeOf(char));
          if Pos('Username/password incorrect', response) > 0 then
          begin
            Status.Error := True;
            Status.ErrorString := rStatusIncorrect;
            Synchronize(@ToForm);
          end
          else
          begin
            Document.SaveToFile(SaveFilePATH);
            Status.DownloadedFilePATH := SaveFilePATH;
            Status.Message := rStatusSaveFile;
            Status.StatusDownload := True;
            Synchronize(@ToForm);
          end;
        end;
      except
        on E: Exception do
        begin
          Status.ErrorString := E.Message;
          Status.Error := True;
          Synchronize(@ToForm);
          Exit;
        end;
      end;
      Exit;
    end;

  finally
    FreeAndNil(HTTP);
    FreeAndNil(Document);
  end;

end;

function TdownloadQSLThread.ParseDownloadURLeQSLcc(Document: TMemoryStream): string;
const
  CDWNLD = '.adi">';
  errorMess = '<H3>ERROR:';
  dateErr = '<H3>YOU HAVE NO LOG ENTRIES';
  eQSLcc_URL = 'http://www.eqsl.cc/downloadedfiles/';
var
  eQSLPage: TStringList;
  tmp: string;
  i: integer;
begin
  try
    Result := '';
    eQSLPage := TStringList.Create;
    Document.Seek(0, soBeginning);
    eQSLPage.LoadFromStream(Document);
    if Pos(errorMess, UpperCase(eQSLPage.Text)) > 0 then
    begin
      Status.Error := True;
      Status.ErrorString := rStatusIncorrect;
      Synchronize(@ToForm);
      Exit;
    end
    else
    if Pos(dateErr, UpperCase(eQSLPage.Text)) > 0 then
    begin
      Status.Error := True;
      Status.ErrorString := rStatusNotData;
      Synchronize(@ToForm);
      Exit;
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
    Result := eQSLcc_URL + tmp;
  finally
    FreeAndNil(eQSLPage);
  end;
end;

procedure TdownloadQSLThread.ClearStatus;
begin
  Status.DownloadAllFileSize := 0;
  Status.DownloadedFileSize := 0;
  Status.DownloadedPercent := 0;
  Status.DownloadedFilePATH := '';
  Status.Error := False;
  Status.ErrorString := '';
  Status.StatusDownload := False;
  Status.Date := '';
  Status.Message := '';
  Status.Password := '';
  Status.Service := '';
  Status.User := '';
end;

end.
