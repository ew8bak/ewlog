unit eqsl;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  CThreads,
  {$ENDIF}
  Classes, SysUtils, Dialogs, LazUTF8, ssl_openssl;
resourcestring
  rAnswerServer = 'Server response:';
  rErrorSendingSata = 'Error sending data';

type
  TEQSLSentEvent = procedure of object;

  TSendEQSLThread = class(TThread)
  protected
    procedure Execute; override;
    procedure ShowResult;
    function SendEQSL(eqsluser, eqslpasswd, call: string;
  timestarted, datestarted: TDateTime; qsofreq, mode, submode, rst, qslinfo: string;
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
    rst: string;
    qslinf: string;
    information: integer;
    OnEQSLSent: TEQSLSentEvent;
    constructor Create;
  end;


function StripStr(t, s: string): string;

var
  SendEQSLThread: TSendEQSLThread;

implementation

uses Forms, LCLType, HTTPSend, dmFunc_U;

function StripStr(t, s: string): string;
begin
  Result := StringReplace(s, t, '', [rfReplaceAll]);
end;

function TSendEQSLThread.SendEQSL(eqsluser, eqslpasswd, call: string;
  timestarted, datestarted: TDateTime; qsofreq, mode, submode, rst, qslinfo: string;
  inform: integer): boolean;
var
  logdata, url, response: string;
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
  Result := False;
  // Создание данных для отправки
  logdata := 'EWLog <ADIF_VER:4>1.00';
  AddData('EQSL_USER', eqsluser);
  AddData('EQSL_PSWD', eqslpasswd);
  logdata := logdata + '<EOH>';
  // Запись
  AddData('CALL', call);
  AddData('QSO_DATE', FormatDateTime('yyyymmdd', datestarted));
  AddData('TIME_ON', FormatDateTime('hhnnss', timestarted));
  AddData('BAND', dmFunc.GetBandFromFreq(qsofreq));
  AddData('MODE', mode);
  AddData('SUBMODE', submode);
  AddData('RST_SENT', rst);
  AddData('QSLMSG', qslinfo);
  AddData('LOG_PGM', 'EWLog');
  logdata := logdata + '<EOR>';
  // ShowMessage(logdata);
  // Генерация http запроса
  url := 'http://www.eqsl.cc/qslcard/importADIF.cfm?ADIFData=' + URLEncode(logdata);
  // Отправка запроса
  res := TStringList.Create;
  try
    try
      if HTTPGetText(url, res) then
      begin
        response := res.Text;
        while (res.Count > 0) and (UpperCase(Trim(res.Strings[0])) <> '<BODY>') do
          res.Delete(0);
        while (res.Count > 0) and (UpperCase(Trim(res.Strings[0])) = '<BODY>') do
          res.Delete(0);
        while (res.Count > 0) and (Trim(res.Strings[0]) = '') do
          res.Delete(0);
        if res.Count > 0 then
          response := Trim(StripStr('<BR>', res.Strings[0]));
        Result := Pos('records added', response) > 0;
        if (not Result) or (inform = 1) then
        result_mes:=response;
      end
      else
      result_mes:=rErrorSendingSata;
    except on E: Exception do
      result_mes:=E.Message;
    end;
  finally
    res.Destroy;
  end;
end;

constructor TSendEQSLThread.Create;
begin
  FreeOnTerminate := True;
  OnEQSLSent := nil;
  inherited Create(True);
end;

procedure TSendEQSLThread.ShowResult;
begin
  if Length(result_mes) > 0 then
  Application.MessageBox(PChar(rAnswerServer + result_mes),
  'eQSL', MB_ICONEXCLAMATION);
end;

procedure TSendEQSLThread.Execute;
begin
  if SendEQSL(userid, userpwd, call, starttime, startdate, freq, mode, submode,
    rst, qslinf, information) then
    if Assigned(OnEQSLSent) then
      Synchronize(OnEQSLSent);
  Synchronize(@ShowResult);
end;

end.
