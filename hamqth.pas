unit hamqth;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, strutils;

resourcestring
  rAnswerServer = 'Server response:';
  rErrorSendingSata = 'Error sending data';
  rRecordAddedSuccessfully = 'Record added successfully';
  rNoEntryAdded = 'No entry added! Perhaps a duplicate!';
  rUnknownUser = 'Unknown user! See settings';

const
  UploadURL = 'http://www.hamqth.com/qso_realtime.php';

type
  THamQTHSentEvent = procedure of object;

  TSendHamQTHThread = class(TThread)
  protected
    procedure Execute; override;
    procedure ShowResult;
    function SendHamQTH(hamqthuser, hamqthpassword, call: string;
      timestarted, datestarted: TDateTime;
      qsofreq, mode, submode, rsts, rstr, qslinfo, locat: string;
      inform: integer): boolean;
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
    qslinf: string;
    locat: string;
    information, inform: integer;
    OnHamQTHSent: THamQTHSentEvent;
    constructor Create;
  end;

function StripStr(t, s: string): string;

var
  SendHamQTHThread: TSendHamQTHThread;
  dataStream: TMemoryStream;
  uploadok: boolean;


implementation

uses Forms, LCLType, HTTPSend, dmFunc_U;

function StripStr(t, s: string): string;
begin
  Result := StringReplace(s, t, '', [rfReplaceAll]);
end;

function TSendHamQTHThread.SendHamQTH(hamqthuser, hamqthpassword, call: string;
  timestarted, datestarted: TDateTime;
  qsofreq, mode, submode, rsts, rstr, qslinfo, locat: string; inform: integer): boolean;
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
  AddData('BAND', dmFunc.GetBandFromFreq(qsofreq));
  AddData('MODE', mode);
  AddData('SUBMODE', submode);
  AddData('RST_SENT', rsts);
  AddData('RST_RCVD', rstr);
  AddData('QSLMSG', qslinfo);
  AddData('GRIDSQUARE', locat);
  Delete(qsofreq, length(qsofreq) - 2, 1); //Удаляем последнюю точку
  AddData('FREQ', qsofreq);
  AddData('LOG_PGM', 'EWLog');
  logdata := logdata + '<EOR>';
  // Генерация http запроса
  url := 'u=' + hamqthuser + '&p=' + hamqthpassword + '&c='+ '&prg=' + appname + '&cmd=INSERT' +
    '&adif=' + UrlEncode(logdata);
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
     // result_mes:=res.Text;
      if res.Text <> '' then
        Result := AnsiContainsStr(res.Text, '<insert>1</insert>');
      if inform = 1 then
      begin
        if pos('<insert>1</insert>', Res.Text) > 0 then
          result_mes := rRecordAddedSuccessfully;
        if pos('<insert>0</insert>', Res.Text) > 0 then
          result_mes := rNoEntryAdded;
        if pos('<error>Unknown user</error>', Res.Text) > 0 then
          result_mes := rUnknownUser;
      end;
    finally
      res.Destroy;
      dataStream.Free;
    end;
  end;

end;

constructor TSendHamQTHThread.Create;
begin
  FreeOnTerminate := True;
  OnHamQTHSent := nil;
  inherited Create(True);
end;

procedure TSendHamQTHThread.ShowResult;
begin
  if Length(result_mes) > 0 then
    Application.MessageBox(PChar(rAnswerServer + result_mes),
      'HamQTH', MB_ICONEXCLAMATION);
end;

procedure TSendHamQTHThread.Execute;
begin
  if SendHamQTH(userid, userpwd, call, starttime, startdate, freq, mode,
    submode, rsts, rstr, qslinf, locat, information) then
    if Assigned(OnHamQTHSent) then
      Synchronize(OnHamQTHSent);
  Synchronize(@ShowResult);
end;

end.
