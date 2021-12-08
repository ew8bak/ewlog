(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)
unit LoTWservice_u;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, fphttpclient, SQLDB, LazFileUtils, LazUTF8, ResourceStr;

const
  UploadURL = 'https://LoTW.arrl.org/lotwuser/upload?';
  DownloadURL = 'https://lotw.arrl.org/lotwuser/lotwreport.adi?';

type
  TdataLoTW = record
    User: string;
    Password: string;
    Date: string;
    TaskType: string;
    DownloadAllFileSize: int64;
    DownloadedFileSize: int64;
    DownloadedPercent: integer;
    DownloadedFilePATH: string;
    UploadFilePATH: string;
    StatusDownload: boolean;
    StatusUpload: boolean;
    RecCount: integer;
    AllRecCount: integer;
    Message: string;
    Error: boolean;
    ErrorCode: integer;
    ErrorString: string;
    Result: boolean;
  end;

type
  TLoTWThread = class(TThread)
  protected
    procedure Execute; override;
  private
    Status: TdataLoTW;
    procedure DownloadQSL(ServiceData: TdataLoTW);
    procedure UploadQSLFile(FileName: string);
    function CreateADIFile(FileName: string): boolean;
    function SetSizeLoc(Loc: string): string;
    procedure OnDataReceived(Sender: TObject; const ContentLength, CurrentPos: int64);
    procedure ClearStatus;

  public
    DataFromServiceLoTWForm: TdataLoTW;

    constructor Create;
    procedure ToForm;
  end;

var
  LoTWThread: TLoTWThread;

implementation

uses InitDB_dm, dmFunc_U, ServiceLoTWForm_u;

constructor TLoTWThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TLoTWThread.Execute;
begin
  if DataFromServiceLoTWForm.TaskType = 'Download' then
    DownloadQSL(DataFromServiceLoTWForm);
  if DataFromServiceLoTWForm.TaskType = 'Generate' then
    CreateADIFile('upload_LoTW.adi');
  if DataFromServiceLoTWForm.TaskType = 'Upload' then
    UploadQSLFile(FilePATH + 'upload_LoTW.tq8');
end;

procedure TLoTWThread.ToForm;
begin
  ServiceLoTWForm.DataFromThread(Status);
end;

procedure TLoTWThread.DownloadQSL(ServiceData: TdataLoTW);
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

    SaveFilePATH := FilePATH + 'LotW_' + ServiceData.Date + '.adi';
    FullURL := DownloadURL + 'login=' + ServiceData.User + '&password=' +
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

  finally
    FreeAndNil(HTTP);
    FreeAndNil(Document);
  end;

end;

procedure TLoTWThread.OnDataReceived(Sender: TObject;
  const ContentLength, CurrentPos: int64);
begin
  Status.TaskType := 'Download';
  Status.DownloadAllFileSize := ContentLength;
  Status.DownloadedFileSize := CurrentPos;
  Status.DownloadedPercent := integer((Trunc((CurrentPos / ContentLength) * 100)));
  Synchronize(@ToForm);
end;

procedure TLoTWThread.UploadQSLFile(FileName: string);
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
  res: TStringList;
  URL: string;
begin
  try
    try
      URL := UploadURL + 'login=' + LBRecord.LoTWLogin + '&password=' +
        LBRecord.LoTWPassword;
      Status.StatusUpload := False;
      Status.Error := False;
      res := TStringList.Create;
      Document := TMemoryStream.Create;
      HTTP := TFPHttpClient.Create(nil);
      HTTP.AddHeader('Content-Type', 'Application/octet-string');
      HTTP.AddHeader('Accept', 'Application/octet-string');
      HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
      HTTP.AllowRedirect := True;
      HTTP.FileFormPost(URL, 'upfile', FileName, Document);
      Document.Position := 0;
      res.LoadFromStream(Document);
      if Pos('<!-- .UPL.  accepted -->', res.Text) > 0 then
      begin
        Status.Message := 'Uploading was successful';
        Status.StatusUpload := True;
      end
      else
      begin
        Status.Error := True;
        Status.ErrorString := 'File was rejected with this error:' + res.Text;
        Status.StatusUpload := False;
      end;
      Status.TaskType := 'Upload';
      Synchronize(@ToForm);

    except
      on E: Exception do
      begin
        Status.TaskType := 'Upload';
        Status.ErrorString := E.Message;
        Status.Error := True;
        Synchronize(@ToForm);
        Exit;
      end;
    end;
  finally
    FreeAndNil(Document);
    FreeAndNil(HTTP);
    FreeAndNil(res);
  end;
end;

function TLoTWThread.SetSizeLoc(Loc: string): string;
begin
  Result := '';
  while Length(Loc) > 6 do
    Delete(Loc, Length(Loc), 1);
  Result := Loc;
end;

function TLoTWThread.CreateADIFile(FileName: string): boolean;
var
  Query: TSQLQuery;
  f: TextFile;
  tmp: string;
  DefMyGrid: string;
  tmpFreq: string;
  SafeFreq: double;
  path: string;
begin
  try
    Result := False;
    ClearStatus;
    path := FilePATH + FileName;
    Status.ErrorCode := 0;
    Status.Result := False;
    Status.RecCount := 0;
    Status.AllRecCount := 0;
    Status.TaskType := 'GenerateADI';
    Status.Message := 'Create ADI file';
    Query := TSQLQuery.Create(nil);
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
      Query.DataBase := InitDB.SQLiteConnection;

    Query.SQL.Text := 'SELECT Loc FROM LogBookInfo WHERE LogTable = ' +
      QuotedStr(LBRecord.LogTable);
    Query.Open;
    DefMyGrid := Query.Fields.FieldByName('Loc').AsString;
    Query.Close;

    if FileExists(Path) then
      DeleteFile(Path);

    AssignFile(f, Path);
  {$i-}
    Rewrite(f);
  {$i+}
    Status.ErrorCode := IOResult;
    if IOresult <> 0 then
    begin
      Synchronize(@ToForm);
      Exit;
    end;
    Writeln(f, '<ADIF_VER:5>3.1.1');
    WriteLn(f, '<CREATED_TIMESTAMP' + dmFunc.StringToADIF(
      FormatDateTime('yyyymmdd hhnnss', Now), False));
    WriteLn(f, '<PROGRAMID' + dmFunc.StringToADIF('EWLog', False));
    WriteLn(f, '<PROGRAMVERSION' + dmFunc.StringToADIF(dmFunc.GetMyVersion, False));
    Writeln(f, '<EOH>');

    Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
      ' WHERE LoTWSent <> 1 AND PROP_MODE <> ''RPT'' ORDER BY UnUsedIndex ASC';

    Query.Open;
    Query.Last;
    Status.AllRecCount := Query.RecordCount;
    Synchronize(@ToForm);
    Query.First;
    while not Query.EOF do
    begin
      try
        tmpFreq := '';

        tmp := '<CALL' + dmFunc.StringToADIF(
          dmFunc.RemoveSpaces(Query.Fields.FieldByName('CallSign').AsString),
          False);
        Write(f, tmp);

        tmp := FormatDateTime('yyyymmdd', Query.Fields.FieldByName(
          'QSODate').AsDateTime);
        tmp := '<QSO_DATE' + dmFunc.StringToADIF(tmp, False);
        Write(f, tmp);

        tmp := Query.Fields.FieldByName('QSOTime').AsString;
        tmp := copy(tmp, 1, 2) + copy(tmp, 4, 2);
        tmp := '<TIME_ON' + dmFunc.StringToADIF(tmp, False);
        Write(f, tmp);

        if Query.Fields.FieldByName('QSOMode').AsString <> '' then
        begin
          tmp := '<MODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSOMode').AsString, False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('QSOSubMode').AsString <> '' then
        begin
          tmp := '<SUBMODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSOSubMode').AsString, False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('QSOBand').AsString <> '' then
        begin
          tmpFreq := Query.Fields.FieldByName('QSOBand').AsString;
          Delete(tmpFreq, Length(tmpFreq) - 2, 1);
          TryStrToFloatSafe(tmpFreq, SafeFreq);
          tmp := '<FREQ' + dmFunc.StringToADIF(
            StringReplace(FormatFloat('0.#####', SafeFreq), ',', '.', [rfReplaceAll]),
            False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('FREQ_RX').AsString <> '' then
        begin
          tmpFreq := Query.Fields.FieldByName('FREQ_RX').AsString;
          Delete(tmpFreq, Length(tmpFreq) - 2, 1);
          TryStrToFloatSafe(tmpFreq, SafeFreq);
          tmp := '<FREQ_RX' + dmFunc.StringToADIF(
            StringReplace(FormatFloat('0.#####', SafeFreq), ',', '.', [rfReplaceAll]),
            False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('QSOReportSent').AsString <> '' then
        begin
          tmp := '<RST_SENT' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSOReportSent').AsString, False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('QSOReportRecived').AsString <> '' then
        begin
          tmp := '<RST_RCVD' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'QSOReportRecived').AsString, False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('QSOBand').AsString <> '' then
        begin
          tmp := '<BAND' + dmFunc.StringToADIF(dmFunc.GetBandFromFreq(
            Query.Fields.FieldByName('QSOBand').AsString), False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('BAND_RX').AsString <> '' then
        begin
          tmp := '<BAND_RX' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'BAND_RX').AsString, False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('PROP_MODE').AsString <> '' then
        begin
          tmp := '<PROP_MODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'PROP_MODE').AsString, False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('SAT_MODE').AsString <> '' then
        begin
          tmp := '<SAT_MODE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'SAT_MODE').AsString, False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('SAT_NAME').AsString <> '' then
        begin
          tmp := '<SAT_NAME' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'SAT_NAME').AsString, False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('MY_GRIDSQUARE').AsString <> '' then
        begin
          tmp := '<MY_GRIDSQUARE' + dmFunc.StringToADIF(Query.Fields.FieldByName(
            'MY_GRIDSQUARE').AsString, False);
          Write(f, tmp);
        end
        else
        begin
          tmp := '<MY_GRIDSQUARE' + dmFunc.StringToADIF(DefMyGrid, False);
          Write(f, tmp);
        end;

        Write(f, '<EOR>'#13#10);

        Inc(Status.RecCount);
        Synchronize(@ToForm);
        Query.Next;

        if Terminated then
          Exit;

      except
        on E: Exception do
        begin
          Write(f, '<EOR>'#13#10);
          WriteLn(ExceptFile, 'ExportThread:' + E.ClassName + ':' +
            E.Message + ' NumberString:' + IntToStr(Status.RecCount + 1));
          Query.Next;
          Continue;
        end;
      end;
    end;

  finally
    CloseFile(f);
    Status.Result := True;
    Status.Message := 'Create ADI file DONE';
    Synchronize(@ToForm);
    FreeAndNil(Query);
    Result := True;
  end;
end;

procedure TLoTWThread.ClearStatus;
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
  Status.TaskType := '';
  Status.User := '';
  Status.AllRecCount := 0;
  Status.RecCount := 0;
  Status.Result := False;
end;

end.
