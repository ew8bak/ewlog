unit hrdlog;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils;

const
  UploadURL = 'http://robot.hrdlog.net/NewEntry.aspx';

type
  THRDSentEvent = procedure of object;

  TSendHRDThread = class(TThread)
  protected
    procedure Execute; override;
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
    qslinf: string;
    locat: string;
    information, inform: integer;
    OnHRDSent: THRDSentEvent;
    constructor Create;
  end;

function SendHRD(hrduser, hrdcode, call: string; timestarted, datestarted: TDateTime;
  qsofreq, mode, rsts, rstr, qslinfo, locat: string; inform: integer): boolean;
function StripStr(t, s: string): string;

var
  SendHRDThread: TSendHRDThread;
  dataStream: TMemoryStream;
  uploadok: boolean;


implementation

uses Forms, LCLType, HTTPSend, dmFunc_U, MainForm_U;

function StripStr(t, s: string): string;
begin
  Result := StringReplace(s, t, '', [rfReplaceAll]);
end;

function SendHRD(hrduser, hrdcode, call: string; timestarted, datestarted: TDateTime;
  qsofreq, mode, rsts, rstr, qslinfo, locat: string; inform: integer): boolean;
var
  logdata, url, appname: string;
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
  appname := 'EWLog';
  // Запись
  AddData('CALL', call);
  AddData('QSO_DATE', FormatDateTime('yyyymmdd', datestarted));
  AddData('TIME_ON', FormatDateTime('hhnnss', timestarted));
  AddData('BAND', dmFunc.GetAdifBandFromFreq(qsofreq));
  AddData('MODE', mode);
  AddData('RST_SENT', rsts);
  AddData('RST_RCVD', rstr);
  AddData('QSLMSG', qslinfo);
  AddData('GRIDSQUARE', locat);
  AddData('FREQ', qsofreq);
  AddData('LOG_PGM', 'EW8BAK_Log');
  logdata := logdata + '<EOR>';
  // Генерация http запроса
  url := 'Callsign=' + hrduser + '&Code=' + hrdcode + '&App=' + appname +
    '&ADIFData=' + UrlEncode(logdata);
  // Отправка запроса
  res := TStringList.Create;
  try
    try
      uploadok := HttpPostURL(UploadURL, url, dataStream);
    except
      Application.MessageBox('Ошибка отправки данных', 'HRDLog Ошибка',
        MB_ICONEXCLAMATION);
    end;
  finally
  end;
  if uploadok then
  begin
    try
      res := TStringList.Create;
      dataStream.Position := 0;
      res.LoadFromStream(dataStream);
      if res.Text <> '' then
        Result := AnsiContainsStr(res.Text, '<insert>1</insert>');
      if inform = 1 then
      begin
        if pos('<insert>1</insert>', Res.Text) > 0 then
          Application.MessageBox(PChar('Запись успешно добавлена'),
            'HRDLog', MB_ICONEXCLAMATION);
        if pos('<insert>0</insert>', Res.Text) > 0 then
          Application.MessageBox(PChar('Запись не добавлена! Возможно дубликат!'),
            'HRDLog', MB_ICONEXCLAMATION);
        if pos('<error>Unknown user</error>', Res.Text) > 0 then
          Application.MessageBox(PChar('Неизвестный пользователь! Посмотрите настройки'),
            'HRDLog', MB_ICONEXCLAMATION);
      end;
    finally
      res.Destroy;
      dataStream.Free;
    end;
  end;

end;

constructor TSendHRDThread.Create;
begin
  FreeOnTerminate := True;
  OnHRDSent := nil;
  inherited Create(True);
end;

procedure TSendHRDThread.Execute;
begin
  if SendHRD(userid, userpwd, call, starttime, startdate, freq, mode,
    rsts, rstr, locat, qslinf, information) then
    if Assigned(OnHRDSent) then
      Synchronize(OnHRDSent);
end;

end.
