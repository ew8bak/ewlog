unit getSessionID;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Classes, SysUtils, LazFileUtils, LazUTF8, ssl_openssl;

type
  TGetSessionThread = class(TThread)
  protected
    procedure Execute; override;
    function GetSession(login_qrzcom, pass_qrzcom, login_qrzru, pass_qrzru:
      string): boolean;
  private
  public
    qrzcom_login: string;
    qrzcom_pass: string;
    qrzru_login: string;
    qrzru_pass: string;

    constructor Create;
    procedure ResultProc;
  end;

var
  GetSessionThread: TGetSessionThread;

implementation

uses Forms, LCLType, HTTPSend, ResourceStr, MainForm_U, InformationForm_U;

function TGetSessionThread.GetSession(login_qrzcom, pass_qrzcom,
  login_qrzru, pass_qrzru: string): boolean;
var
  resp, errorCode, error: string;
  beginSTR, endSTR: integer;
begin
  try
    Result := False;
    errorCode := '';
    error := '';

    if (login_qrzru <> '') and (pass_qrzru <> '') then
    begin
      errorCode := '';
      error := '';
      with THTTPSend.Create do
      begin
        if HTTPMethod('GET', 'http://api.qrz.ru/login?u=' + login_qrzru +
          '&p=' + pass_qrzru + '') then
        begin
          SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
        end;
        Free;
      end;

      beginSTR := resp.IndexOf('<session_id>');
      endSTR := resp.IndexOf('</session_id>');
      if (beginSTR <> endSTR) then
        InformationForm.sessionNumQRZRU :=
          resp.Substring(beginSTR + 12, endSTR - beginSTR - 12);
      beginSTR := resp.IndexOf('<errorcode>');
      endSTR := resp.IndexOf('</errorcode>');
      if (beginSTR <> endSTR) then
        errorCode := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);
      if errorCode <> '' then
        MainForm.StatusBar1.Panels.Items[0].Text := rErrorXMLAPI + errorCode;

      beginSTR := resp.IndexOf('<error>');
      endSTR := resp.IndexOf('</error>');
      if (beginSTR <> endSTR) then
        error := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);
      if error <> '' then
      begin
        MainForm.StatusBar1.Panels.Items[0].Text := 'QRZ.RU XML:' + error;
      end;
    end;

    if (login_qrzcom <> '') and (pass_qrzcom <> '') then
    begin
      errorCode := '';
      error := '';
      with THTTPSend.Create do
      begin
        if HTTPMethod('GET', 'http://xmldata.qrz.com/xml/?username=' +
          login_qrzcom + ';password=' + pass_qrzcom + ';agent=EWLog') then
        begin
          SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
        end;
        Free;
      end;

      beginSTR := resp.IndexOf('<Key>');
      endSTR := resp.IndexOf('</Key>');
      if (beginSTR <> endSTR) then
        InformationForm.sessionNumQRZCOM :=
          resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);
      beginSTR := resp.IndexOf('<errorcode>');
      endSTR := resp.IndexOf('</errorcode>');
      if (beginSTR <> endSTR) then
        errorCode := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);
      if errorCode <> '' then
        MainForm.StatusBar1.Panels.Items[0].Text := rErrorXMLAPI + errorCode;

      beginSTR := resp.IndexOf('<Error>');
      endSTR := resp.IndexOf('</Error>');
      if (beginSTR <> endSTR) then
        error := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);
      if error <> '' then
      begin
        MainForm.StatusBar1.Panels.Items[0].Text := 'QRZ.COM XML:' + error;
      end;
    end;

    //HAMQTH
    error := '';
    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', 'http://www.hamqth.com/xml.php?u=ew8bak&p=Ml197895551ml') then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    beginSTR := resp.IndexOf('<session_id>');
    endSTR := resp.IndexOf('</session_id>');
    if (beginSTR <> endSTR) then
      InformationForm.sessionNumHAMQTH := resp.Substring(beginSTR + 12, endSTR - beginSTR - 12);
    beginSTR := resp.IndexOf('<error>');
    endSTR := resp.IndexOf('</error>');
    if (beginSTR <> endSTR) then
      error := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);
    if error <> '' then
    begin
      MainForm.StatusBar1.Panels.Items[0].Text := 'HAMQTH XML:' + error;
    end;


  finally
    if (InformationForm.sessionNumQRZCOM <> '') or
      (InformationForm.sessionNumQRZRU <> '') then
      Result := True;
  end;
end;

constructor TGetSessionThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(True);
end;

procedure TGetSessionThread.ResultProc;
begin
  InformationForm.ReloadInformation;
end;

procedure TGetSessionThread.Execute;
begin
  if GetSession(qrzcom_login, qrzcom_pass, qrzru_login, qrzru_pass) then
    Synchronize(@ResultProc);
end;

end.
