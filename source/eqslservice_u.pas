(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)
unit eQSLservice_u;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, fphttpclient, SQLDB, LazFileUtils, LazUTF8, ResourceStr;

const
  UploadURL = 'https://www.eqsl.cc/qslcard/ImportADIF.cfm';
  DownloadURL = 'http://www.eqsl.cc/qslcard/DownloadInBox.cfm?';

type
  TdataEQSL = record
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
  TeQSLThread = class(TThread)
  protected
    procedure Execute; override;
  private
    Status: TdataEQSL;
    procedure DownloadQSL(ServiceData: TdataEQSL);
    procedure UploadQSLFile(FileName: string);
    function CreateADIFile(FileName: string): boolean;
    function SetSizeLoc(Loc: string): string;
    function ParseDownloadURLeQSLcc(Document: TMemoryStream): string;
    procedure OnDataReceived(Sender: TObject; const ContentLength, CurrentPos: int64);
    procedure ClearStatus;

  public
    DataFromServiceEqslForm: TdataEQSL;

    constructor Create;
    procedure ToForm;
  end;

var
  eQSLThread: TeQSLThread;

implementation

uses InitDB_dm, dmFunc_U, ServiceEqslForm_u;

constructor TeQSLThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TeQSLThread.Execute;
begin
  if DataFromServiceEqslForm.TaskType = 'Download' then
    DownloadQSL(DataFromServiceEqslForm);
  if DataFromServiceEqslForm.TaskType = 'Upload' then
    if CreateADIFile('upload_eQSLcc.adi') then
      UploadQSLFile(FilePATH + 'upload_eQSLcc.adi');
end;

procedure TeQSLThread.ToForm;
begin
  ServiceEqslForm.DataFromThread(Status);
end;

procedure TeQSLThread.DownloadQSL(ServiceData: TdataEQSL);
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
  SaveFilePATH: string;
  FullURL: string;
begin
  try
    ClearStatus;
    HTTP := TFPHttpClient.Create(nil);
    Document := TMemoryStream.Create;
    HTTP.AllowRedirect := True;
    HTTP.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; EWLog)');
    HTTP.OnDataReceived := @OnDataReceived;

    SaveFilePATH := FilePATH + 'eQSLcc_' + ServiceData.Date + '.adi';
    FullURL := DownloadURL + 'UserName=' + ServiceData.User +
      '&Password=' + ServiceData.Password + '&RcvdSince=' + ServiceData.Date;
    try
      HTTP.Get(FullURL, Document);
      if HTTP.ResponseStatusCode = 200 then
      begin
        FullURL := ParseDownloadURLeQSLcc(Document);
        if FullURL <> '' then
        begin
          Document.Clear;
          HTTP.Get(FullURL, Document);
          if HTTP.ResponseStatusCode = 200 then
          begin
            Document.SaveToFile(SaveFilePATH);
            Status.DownloadedFilePATH := SaveFilePATH;
            Status.Message := rStatusSaveFile;
            Status.StatusDownload := True;
            Status.TaskType := 'Download';
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

  finally
    FreeAndNil(HTTP);
    FreeAndNil(Document);
  end;

end;

procedure TeQSLThread.OnDataReceived(Sender: TObject;
  const ContentLength, CurrentPos: int64);
begin
  Status.TaskType := 'Download';
  Status.DownloadAllFileSize := ContentLength;
  Status.DownloadedFileSize := CurrentPos;
  Status.DownloadedPercent := integer((Trunc((CurrentPos / ContentLength) * 100)));
  Synchronize(@ToForm);
end;

function TeQSLThread.ParseDownloadURLeQSLcc(Document: TMemoryStream): string;
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

procedure TeQSLThread.UploadQSLFile(FileName: string);
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
  res: TStringList;
begin
  try
    Status.StatusUpload := False;
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
    Status.Message := res.Text;
  finally
    Status.StatusUpload := True;
    Status.TaskType := 'Upload';
    Synchronize(@ToForm);
    FreeAndNil(Document);
    FreeAndNil(HTTP);
    FreeAndNil(res);
  end;
end;

function TeQSLThread.SetSizeLoc(Loc: string): string;
begin
  Result := '';
  while Length(Loc) > 6 do
    Delete(Loc, Length(Loc), 1);
  Result := Loc;
end;

function TeQSLThread.CreateADIFile(FileName: string): boolean;
var
  Query: TSQLQuery;
  f: TextFile;
  tmp: string;
  DefMyLAT: string;
  DefMyLON: string;
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

    Query := TSQLQuery.Create(nil);
    Query.DataBase := InitDB.SQLiteConnection;
    Query.SQL.Text := 'SELECT * FROM LogBookInfo WHERE LogTable = ' +
      QuotedStr(LBRecord.LogTable);
    Query.Open;
    DefMyGrid := Query.Fields.FieldByName('Loc').AsString;
    DefMyLat := SetSizeLoc(Query.Fields.FieldByName('Lat').AsString);
    DefMyLon := SetSizeLoc(Query.Fields.FieldByName('Lon').AsString);
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

    Writeln(f, '<EQSL_USER' + dmFunc.StringToADIF(LBRecord.eQSLccLogin, False));
    Writeln(f, '<EQSL_PSWD' + dmFunc.StringToADIF(LBRecord.eQSLccPassword, False));
    Writeln(f, '<EOH>');

    Query.SQL.Text := 'SELECT * FROM ' + LBRecord.LogTable +
      ' WHERE EQSL_QSL_SENT = ''N'' ORDER BY UnUsedIndex ASC';

    Query.Open;
    Query.Last;
    Status.AllRecCount := Query.RecordCount;
    Synchronize(@ToForm);
    Query.First;
    while not Query.EOF do
    begin
      try
        tmpFreq := '';

        tmp := '<OPERATOR' + dmFunc.StringToADIF(
          dmFunc.RemoveSpaces(DBRecord.CurrCall), False);
        Write(f, tmp);

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

        if Query.Fields.FieldByName('QSLInfo').AsString <> '' then
        begin
          tmp := '<QSLMSG' + dmFunc.StringToADIF(
            dmFunc.MyTrim(Query.Fields.FieldByName('QSLInfo').AsString),
            False);
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

        if Query.Fields.FieldByName('MY_LAT').AsString <> '' then
        begin
          tmp := '<MY_LAT' + dmFunc.StringToADIF(
            SetSizeLoc(Query.Fields.FieldByName('MY_LAT').AsString), False);
          Write(f, tmp);
        end
        else
        begin
          tmp := '<MY_LAT' + dmFunc.StringToADIF(DefMyLAT, False);
          Write(f, tmp);
        end;

        if Query.Fields.FieldByName('MY_LON').AsString <> '' then
        begin
          tmp := '<MY_LON' + dmFunc.StringToADIF(
            SetSizeLoc(Query.Fields.FieldByName('MY_LON').AsString), False);
          Write(f, tmp);
        end
        else
        begin
          tmp := '<MY_LON' + dmFunc.StringToADIF(DefMyLON, False);
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
    Synchronize(@ToForm);
    FreeAndNil(Query);
    Result := True;
  end;
end;

procedure TeQSLThread.ClearStatus;
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
