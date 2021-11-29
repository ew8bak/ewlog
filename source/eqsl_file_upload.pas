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
  Classes, SysUtils, strutils, fphttpclient, SQLDB;

const
  UploadURL = 'https://www.eqsl.cc/qslcard/ImportADIF.cfm';

  type
  TInfoExport = record
    From: string;
    AllRec: integer;
    RecCount: integer;
    ErrorStr: string;
    ErrorCode: integer;
    Result: boolean;
  end;

type
  TeqslFileUploadThread = class(TThread)
  protected
    procedure Execute; override;
  private
    response: string;
    procedure SendFile(FileName: string);
    procedure ADIcreateFile;
    procedure ShowResult;
    function SetSizeLoc(Loc: string): string;
    procedure ToForm;

  public
    FileName: string;
    Info: TInfoExport;
    constructor Create;
  end;

var
  eqslFileUploadThread: TeqslFileUploadThread;


implementation

uses Forms, LCLType, InitDB_dm, dmFunc_U;

procedure TeqslFileUploadThread.ToForm;
begin

end;

function TeqslFileUploadThread.SetSizeLoc(Loc: string): string;
begin
  Result := '';
  while Length(Loc) > 6 do
    Delete(Loc, Length(Loc), 1);
  Result := Loc;
end;

procedure TeqslFileUploadThread.ADIcreateFile;
var
  Query: TSQLQuery;
  f: TextFile;
  tmp: string;
  DefMyLAT: string;
  DefMyLON: string;
  DefMyGrid: string;
  EQSL_QSL_RCVD, QSL_RCVD, QSL_SENT: string;
  tmpFreq: string;
  i: integer;
  numberToExp: string = '';
  SafeFreq: double;
  path: string;
begin
  try
    path := FilePATH + 'adiToeqsl.adi';
    Info.ErrorCode := 0;
    Info.Result := False;
    Info.RecCount := 0;
    Info.AllRec := 0;

    Query := TSQLQuery.Create(nil);
    if DBRecord.CurrentDB = 'MySQL' then
      Query.DataBase := InitDB.MySQLConnection
    else
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
    Info.ErrorCode := IOResult;
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
      ' ORDER BY UnUsedIndex ASC WHERE EQSL_QSL_SENT = ''N''';

    Query.Open;
    Query.Last;
    Info.AllRec := Query.RecordCount;
    Synchronize(@ToForm);
    Query.First;
    while not Query.EOF do
    begin
      try
        EQSL_QSL_RCVD := '';
        QSL_RCVD := '';
        QSL_SENT := '';
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

        Inc(Info.RecCount);
        Synchronize(@ToForm);
        Query.Next;

        if Terminated then
          Exit;

      except
        on E: Exception do
        begin
          Write(f, '<EOR>'#13#10);
          WriteLn(ExceptFile, 'ExportThread:' + E.ClassName + ':' +
            E.Message + ' NumberString:' + IntToStr(Info.RecCount + 1));
          Query.Next;
          Continue;
        end;
      end;
    end;

  finally
    CloseFile(f);
    Info.Result := True;
    Synchronize(@ToForm);
    FreeAndNil(Query);
  end;
end;


procedure TeqslFileUploadThread.SendFile(FileName: string);
var
  HTTP: TFPHttpClient;
  Document: TMemoryStream;
  res: TStringList;
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
