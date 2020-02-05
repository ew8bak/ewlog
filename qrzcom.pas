unit qrzcom;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils, ssl_openssl;

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
    function SendQRZCom(qrzcomuser, qrzcompassword, call: string;
      timestarted, datestarted: TDateTime;
      qsofreq, mode, submode, rsts, rstr, name, qth, cont, my_grid, qslinfo, locat: string): boolean;
  private
    result_mes: string;
  public
    userid: string;
    userpwd: string;
    call: string;
    startdate: TDateTime;
    starttime: TDateTime;
    freq: string;
    mode: string;
    submode: string;
    rsts: string;
    rstr: string;
    opname: string;
    opqth: string;
    opcont: string;
    mygrid: string;
    qslinf: string;
    locat: string;
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

function TSendQRZComThread.SendQRZCom(qrzcomuser, qrzcompassword, call: string;
  timestarted, datestarted: TDateTime;
  qsofreq, mode, submode, rsts, rstr, name, qth, cont, my_grid, qslinfo, locat: string): boolean;
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
  AddData('CALL', call);
  AddData('QSO_DATE', FormatDateTime('yyyymmdd', datestarted));
  AddData('TIME_ON', FormatDateTime('hhnnss', timestarted));
  AddData('BAND', dmFunc.GetBandFromFreq(qsofreq));
  AddData('MODE', mode);
  AddData('SUBMODE', submode);
  AddData('RST_SENT', rsts);
  AddData('RST_RCVD', rstr);
  AddData('NAME', name);
  AddData('QTH', qth);
  AddData('MY_GRIDSQUARE', my_grid);
  AddData('CONT', cont);
  AddData('QSLMSG', qslinfo);
  AddData('GRIDSQUARE', locat);
  Delete(qsofreq, length(qsofreq) - 2, 1); //Удаляем последнюю точку
  AddData('FREQ', qsofreq);
  AddData('LOG_PGM', 'EWLog');
  logdata := logdata + '<EOR>';
  // Генерация http запроса
  url := 'KEY=' + qrzcompassword + '&ACTION=INSERT' + '&ADIF=' + UrlEncode(logdata);
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
  if SendQRZCom(userid, userpwd, call, starttime, startdate, freq,
    mode, submode, rsts, rstr, opname, opqth, opcont, mygrid, qslinf, locat) then
    if Assigned(OnQRZComSent) then
      Synchronize(OnQRZComSent);
  Synchronize(@ShowResult);
end;

end.
