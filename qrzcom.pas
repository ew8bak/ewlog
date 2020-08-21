unit qrzcom;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, ssl_openssl, qso_record;

resourcestring
  rAnswerServer = 'Server response:';
  rErrorSendingSata = 'Error sending data';
  rRecordAddedSuccessfully = 'Record added successfully';
  rNoEntryAdded = 'No entry added! Perhaps a duplicate!';
  rUnknownUser = 'Unknown user! See settings';

const
  UploadURL = 'http://logbook.qrz.com/api';

type
  TQRZComSentEvent = procedure of object;

  TSendQRZComThread = class(TThread)
  protected
    procedure Execute; override;
    procedure ShowResult;
    function SendQRZCom(SendQSOr: TQSO): boolean;
  private
    result_mes: string;
  public
    SendQSO: TQSO;
    user: string;
    password: string;
    callsign: string;
    OnQRZComSent: TQRZComSentEvent;
    constructor Create;
  end;

function StripStr(t, s: string): string;

var
  SendQRZComThread: TSendQRZComThread;
  dataStream: TMemoryStream;
  uploadok: boolean;


implementation

uses Forms, LCLType, HTTPSend, dmFunc_U;

function StripStr(t, s: string): string;
begin
  Result := StringReplace(s, t, '', [rfReplaceAll]);
end;

function TSendQRZComThread.SendQRZCom(SendQSOr: TQSO): boolean;
var
  logdata, url: string;
  res: TStringList;


  procedure AddData(const datatype, Data: string);
  begin
    if Data <> '' then
      logdata := logdata + Format('<%s:%d>%s', [datatype, Length(Data), Data]);
  end;

  function UrlEncode(s: string): string;
  var
    i: integer;
  begin
    Result := '';
    for i := 1 to Length(s) do
      case s[i] of
        ' ':
          Result := Result + '+';
        '0'..'9', 'A'..'Z', 'a'..'z', '*', '@', '.', '_', '-', '$', '!', #$27, '(', ')':
          Result := Result + s[i];
        else
          Result := Result + '%' + IntToHex(Ord(s[i]), 2);
      end;
  end;

begin
  dataStream := TMemoryStream.Create;
  Result := False;
  // Создание данных для отправки
  // Запись
  AddData('CALL', SendQSOr.CallSing);
  AddData('QSO_DATE', FormatDateTime('yyyymmdd', SendQSOr.QSODate));
  SendQSOr.QSOTime := StringReplace(SendQSOr.QSOTime, ':', '', [rfReplaceAll]);
  AddData('TIME_ON', SendQSOr.QSOTime);
  AddData('BAND', dmFunc.GetBandFromFreq(SendQSOr.QSOBand));
  AddData('MODE', SendQSOr.QSOMode);
  AddData('SUBMODE', SendQSOr.QSOSubMode);
  AddData('RST_SENT', SendQSOr.QSOReportSent);
  AddData('RST_RCVD', SendQSOr.QSOReportRecived);
  AddData('NAME', SendQSOr.OmName);
  AddData('QTH', SendQSOr.OmQTH);
  AddData('MY_GRIDSQUARE', SendQSOr.My_Grid);
  AddData('CONT', SendQSOr.Continent);
  AddData('QSLMSG', SendQSOr.QSLInfo);
  AddData('GRIDSQUARE', SendQSOr.Grid);
  Delete(SendQSOr.QSOBand, length(SendQSOr.QSOBand) - 2, 1); //Удаляем последнюю точку
  AddData('FREQ', SendQSOr.QSOBand);
  AddData('LOG_PGM', 'EWLog');
  logdata := logdata + '<EOR>';
  // Генерация http запроса
  url := 'KEY=' + password + '&ACTION=INSERT' + '&ADIF=' + UrlEncode(logdata);
  // Отправка запроса
  res := TStringList.Create;
  try
    try
      uploadok := HttpPostURL(UploadURL, url, dataStream);
    except
      on E: Exception do
        result_mes := E.Message;
    end;
  finally
  end;
  if uploadok then
  begin
    try
      res := TStringList.Create;
      dataStream.Position := 0;
      res.LoadFromStream(dataStream);
      if Pos('RESULT=OK', Trim(res.Text)) > 0 then
        Result := True
      else
      begin
        Result := False;
        result_mes := res.Text;
      end;
    finally
      res.Destroy;
      dataStream.Free;
    end;
  end;

end;

constructor TSendQRZComThread.Create;
begin
  FreeOnTerminate := True;
  OnQRZComSent := nil;
  inherited Create(True);
end;

procedure TSendQRZComThread.ShowResult;
begin
  if Length(result_mes) > 0 then
    Application.MessageBox(PChar(rAnswerServer + result_mes),
      'HamQTH', MB_ICONEXCLAMATION);
end;

procedure TSendQRZComThread.Execute;
begin
  if SendQRZCom(SendQSO) then
    if Assigned(OnQRZComSent) then
      Synchronize(OnQRZComSent);
  Synchronize(@ShowResult);
end;

end.
