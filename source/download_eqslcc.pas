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
  Classes, SysUtils, ResourceStr, LazFileUtils, LazUTF8, fphttpclient,
  StreamAdapter_u;

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
    function DowneQSLcc(eqslcc_user, eqslcc_password, eqslcc_date: string;
      OnProgress: TOnProgress): boolean;
    procedure Progress(Sender: TObject; Percent: integer);
    procedure updSize;
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

uses LCLType, dmFunc_U, ServiceForm_U, InitDB_dm;

function TeQSLccThread.DowneQSLcc(eqslcc_user, eqslcc_password, eqslcc_date: string;
  OnProgress: TOnProgress): boolean;
var
  fullURL, tmp: string;
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
  Stream: TStreamAdapter;
  eQSLPage: TStringList;
  i: integer;
  errFlag: boolean;
begin
  Result := False;
  errFlag := False;
  importFlag := False;
  try
    HTTP := TFPHttpClient.Create(nil);
    Document := TMemoryStream.Create;
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
    eQSLPage := TStringList.Create;

    SaveFile := FilePATH + 'eQSLcc_' + eqslcc_date + '.adi';

    fullURL := DowneQSLcc_URL + 'UserName=' + eqslcc_user + '&Password=' +
      eqslcc_password + '&RcvdSince=' + eqslcc_date;

    HTTP.Get(fullURL, Document);
    if HTTP.ResponseStatusCode = 200 then
    begin
      Document.Seek(0, soBeginning);
      eQSLPage.LoadFromStream(Document);
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

    if not errFlag then
    begin
      fullURL := eQSLcc_URL + tmp;
      AllDownSize := dmFunc.GetSize(fullURL);
      Stream := TStreamAdapter.Create(TFileStream.Create(SaveFile, fmCreate),
        AllDownSize);
      Stream.OnProgress := OnProgress;
      HTTP.HTTPMethod('GET', fullURL, Stream, [200]);
      result_mes := rStatusSaveFile;
      importFlag := True;
    end;
  finally
    FreeAndNil(HTTP);
    FreeAndNil(Stream);
    FreeAndNil(Document);
    eQSLPage.Free;
    Result := True;
  end;
end;

procedure TeQSLccThread.updSize;
begin
  ServiceForm.DownSize := ServiceForm.DownSize + downSize;
  ServiceForm.Label7.Caption :=
    FormatFloat('0.###', ServiceForm.DownSize / 1048576) + ' ' + rMBytes;
  ServiceForm.ProgressBar1.Position := downSize;
end;

procedure TeQSLccThread.Progress(Sender: TObject; Percent: integer);
begin
  downSize := Percent;
  Synchronize(@updSize);
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
  if DowneQSLcc(user_eqslcc, password_eqslcc, date_eqslcc, @Progress) then
    Synchronize(@ShowResult);
end;

end.
