unit infoDM_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, openssl, httpsend, Graphics, inform_record, Dialogs;

const
  URL_QRZRU = 'https://api.qrz.ru/callsign?id=';
  URL_QRZCOM = 'https://xmldata.qrz.com/xml/current/?s=';
  URL_HAMQTH = 'https://www.hamqth.com/xml.php?id=';

type

  { TInfoDM }

  TInfoDM = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure GetSession;
    function GetXMLField(resp, field: string): string;
    function GetError(error_msg: string): boolean;
    procedure GetHAMQTH(Call: string);
    procedure GetQRZcom(Call: string);
    procedure GetQRZru(Call: string);
    procedure GetPhoto(url: string);
    procedure ClearRecord(var Info: TInformRecord);

  public
    InfoR: TInformRecord;
    procedure SyncFromThreadSession(sessionID, error, errorcode: string);
    procedure GetInformation(Callsign: string; Sender: string);
    procedure GetResponseFromThread(response: string);
    procedure ViewPhoto(Photo: TMemoryStream; url: string);
  end;

var
  InfoDM: TInfoDM;

implementation

uses
  MainFuncDM, getSession, GetInfoFromInternetThread, MainForm_U,
  dmFunc_U, GetPhotoFromInternet, InformationForm_U;

{$R *.lfm}

procedure TInfoDM.ViewPhoto(Photo: TMemoryStream; url: string);
begin
  try
    if url <> '' then
    begin
      if dmFunc.Extention(url) = '.gif' then
        if Assigned(InfoR.PhotoGIF) then
          InfoR.PhotoGIF.LoadFromStream(Photo);
      if dmFunc.Extention(url) = '.jpg' then
        if Assigned(InfoR.PhotoJPEG) then
          InfoR.PhotoJPEG.LoadFromStream(Photo);
      if dmFunc.Extention(url) = '.png' then
        if Assigned(InfoR.PhotoPNG) then
          InfoR.PhotoPNG.LoadFromStream(Photo);
    end;

  finally
    if InfoR.Sender = 'MainForm' then
      MainForm.LoadPhotoFromInternetCallbook(InfoR);
    if InfoR.Sender = 'InformationForm' then
      InformationForm.LoadPhotoFromInternetCallbook(InfoR);
  end;
end;

procedure TInfoDM.GetPhoto(url: string);
begin
  GetPhotoThread := TGetPhotoThread.Create;
  if Assigned(GetPhotoThread.FatalException) then
    raise GetPhotoThread.FatalException;
  Delete(url, Pos('?', url), Length(url));
  GetPhotoThread.url := url;
  GetPhotoThread.Start;
end;

procedure TInfoDM.GetResponseFromThread(response: string);
begin
  try
    ClearRecord(InfoR);
    if InfoR.System = 'QRZRU' then
    begin
      InfoR.Error := GetXMLField(response, 'error');
      if InfoR.Error <> '' then
        if GetError(InfoR.Error) then
          Exit;
      InfoR.Callsign := GetXMLField(response, 'call');
      InfoR.Name := GetXMLField(response, 'name');
      InfoR.SurName := GetXMLField(response, 'surname');
      InfoR.City := GetXMLField(response, 'city');
      InfoR.Address := GetXMLField(response, 'street');
      InfoR.Grid := GetXMLField(response, 'qthloc');
      InfoR.State := GetXMLField(response, 'state');
      InfoR.Country := GetXMLField(response, 'country');
      InfoR.HomePage := GetXMLField(response, 'url');
      InfoR.Telephone := GetXMLField(response, 'telephone');
      InfoR.eMail := GetXMLField(response, 'email');
      InfoR.ICQ := GetXMLField(response, 'icq');
      InfoR.qslVia := GetXMLField(response, 'qslvia');
      InfoR.PhotoURL := GetXMLField(response, 'file');
      if InfoR.PhotoURL <> '' then
        GetPhoto(InfoR.PhotoURL);
    end;

    if InfoR.System = 'HAMQTH' then
    begin
      InfoR.Error := GetXMLField(response, 'error');
      if InfoR.Error <> '' then
        if GetError(InfoR.Error) then
          Exit;
      InfoR.Callsign := GetXMLField(response, 'callsign');
      InfoR.Name := GetXMLField(response, 'nick');
      InfoR.Address := GetXMLField(response, 'street');
      InfoR.Grid := GetXMLField(response, 'grid');
      InfoR.State := GetXMLField(response, 'state');
      InfoR.Country := GetXMLField(response, 'country');
      InfoR.HomePage := GetXMLField(response, 'web');
      InfoR.Telephone := GetXMLField(response, 'telephone');
      InfoR.eMail := GetXMLField(response, 'email');
      InfoR.City := GetXMLField(response, 'adr_city');
      InfoR.ICQ := GetXMLField(response, 'icq');
      InfoR.PhotoURL := GetXMLField(response, 'picture');
      if InfoR.PhotoURL <> '' then
        GetPhoto(InfoR.PhotoURL);
    end;

    if InfoR.System = 'QRZCOM' then
    begin
      InfoR.Error := GetXMLField(response, 'Error');
      if InfoR.Error <> '' then
        if GetError(InfoR.Error) then
          Exit;
      InfoR.Callsign := GetXMLField(response, 'call');
      InfoR.Name := GetXMLField(response, 'fname');
      InfoR.Address := GetXMLField(response, 'addr2');
      InfoR.City := GetXMLField(response, 'addr1');
      InfoR.Grid := GetXMLField(response, 'grid');
      InfoR.State := GetXMLField(response, 'state');
      InfoR.Country := GetXMLField(response, 'country');
      InfoR.HomePage := GetXMLField(response, 'url');
      InfoR.Telephone := GetXMLField(response, 'telephone');
      InfoR.eMail := GetXMLField(response, 'email');
      InfoR.ICQ := GetXMLField(response, 'icq');
      InfoR.qslVia := GetXMLField(response, 'qslvia');
      InfoR.PhotoURL := GetXMLField(response, 'image');
      if InfoR.PhotoURL <> '' then
        GetPhoto(InfoR.PhotoURL);
    end;

  finally
    if InfoR.Sender = 'MainForm' then
      MainForm.LoadFromInternetCallBook(InfoR);
    if InfoR.Sender = 'InformationForm' then
      InformationForm.LoadFromInternetCallBook(InfoR);
  end;
end;

procedure TInfoDM.GetHAMQTH(Call: string);
begin
  InfoR.Error := '';
  GetInfoThread := TGetInfoThread.Create;
  if Assigned(GetInfoThread.FatalException) then
    raise GetInfoThread.FatalException;
  GetInfoThread.url := URL_HAMQTH + InfoR.sessionid + '&callsign=' +
    Call + '&prg=EWLog';
  GetInfoThread.Start;
end;

procedure TInfoDM.GetQRZcom(Call: string);
begin
  InfoR.Error := '';
  GetInfoThread := TGetInfoThread.Create;
  if Assigned(GetInfoThread.FatalException) then
    raise GetInfoThread.FatalException;
  GetInfoThread.url := URL_QRZCOM + InfoR.sessionid + ';callsign=' + Call;
  GetInfoThread.Start;
end;

procedure TInfoDM.GetQRZru(Call: string);
begin
  InfoR.Error := '';
  GetInfoThread := TGetInfoThread.Create;
  if Assigned(GetInfoThread.FatalException) then
    raise GetInfoThread.FatalException;
  GetInfoThread.url := URL_QRZRU + InfoR.sessionid + '&callsign=' + Call;
  GetInfoThread.Start;
end;

function TInfoDM.GetXMLField(resp, field: string): string;
var
  beginSTR, endSTR, lenField: integer;
begin
  Result := '';
  lenField := Length(field) + 2;
  beginSTR := resp.IndexOf('<' + field + '>');
  endSTR := resp.IndexOf('</' + field + '>');
  if (beginSTR <> endSTR) then
    Result := resp.Substring(beginSTR + lenField, endSTR - beginSTR - lenField);
end;

procedure TInfoDM.GetInformation(Callsign: string; Sender: string);
begin
  InfoR.Sender := Sender;
  if Length(InfoR.sessionid) = 0 then
    GetSession;
  if (IniSet.CallBookSystem = '') or (IniSet.CallBookSystem = 'HAMQTH') then
  begin
    IniSet.CallBookSystem := 'HAMQTH';
    InfoR.System := 'HAMQTH';
    GetHAMQTH(Callsign);
  end;
  if IniSet.CallBookSystem = 'QRZRU' then
  begin
    InfoR.System := 'QRZRU';
    GetQRZru(Callsign);
  end;
  if IniSet.CallBookSystem = 'QRZCOM' then
  begin
    InfoR.System := 'QRZCOM';
    GetQRZcom(Callsign);
  end;
end;

function TInfoDM.GetError(error_msg: string): boolean;
begin
  Result := False;
  if (error_msg = 'Invalid session key') or (error_msg = 'Session Timeout') or
    (error_msg = 'Session does not exist or expired') or
    (error_msg = 'Wrong session identifier') then
  begin
    GetSession;
    Result := True;
    Exit;
  end;
end;

procedure TInfoDM.SyncFromThreadSession(sessionID, error, errorcode: string);
begin
  if Length(sessionID) > 0 then
  begin
    InfoR.sessionid := sessionID;
    InfoR.Error := '';
    InfoR.ErrorCode := '';
    Exit;
  end;
  if (Length(error) > 0) or (Length(errorcode) > 0) then
  begin
   // ShowMessage('Error:' + error + '; Error code:' + errorcode);
    InfoR.Error := error;
    InfoR.ErrorCode := errorcode;
  end;
end;

procedure TInfoDM.DataModuleCreate(Sender: TObject);
begin
  InfoR.PhotoJPEG := nil;
  InfoR.PhotoGIF := nil;
  InfoR.PhotoPNG := nil;
  GetSession;
  if not Assigned(InfoR.PhotoJPEG) then
    InfoR.PhotoJPEG := TJPEGImage.Create;
  if not Assigned(InfoR.PhotoGIF) then
    InfoR.PhotoGIF := TGIFImage.Create;
  if not Assigned(InfoR.PhotoPNG) then
    InfoR.PhotoPNG := TPortableNetworkGraphic.Create;
end;

procedure TInfoDM.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(InfoR.PhotoJPEG);
  FreeAndNil(InfoR.PhotoGIF);
  FreeAndNil(InfoR.PhotoPNG);
end;

procedure TInfoDM.GetSession;
var
  Login, Password: string;
begin
  if (IniSet.CallBookSystem = '') or (IniSet.CallBookSystem = 'HAMQTH') then
  begin
    Login := IniSet.HAMQTH_Login;
    Password := IniSet.HAMQTH_Pass;
  end;

  if IniSet.CallBookSystem = 'QRZRU' then
  begin
    Login := IniSet.QRZRU_Login;
    Password := IniSet.QRZRU_Pass;
  end;

  if IniSet.CallBookSystem = 'QRZCOM' then
  begin
    Login := IniSet.QRZCOM_Login;
    Password := IniSet.QRZCOM_Pass;
  end;

  GetSessionThread := TGetSessionThread.Create;
  if Assigned(GetSessionThread.FatalException) then
    raise GetSessionThread.FatalException;
  GetSessionThread.Login := Login;
  GetSessionThread.Password := Password;
  GetSessionThread.From := IniSet.CallBookSystem;
  GetSessionThread.Start;
end;

procedure TInfoDM.ClearRecord(var Info: TInformRecord);
begin
  Info.Callsign := '';
  Info.Country := '';
  Info.Name := '';
  Info.SurName := '';
  Info.Address := '';
  Info.City := '';
  Info.Grid := '';
  Info.HomePage := '';
  Info.State := '';
  Info.Telephone := '';
  Info.eMail := '';
  Info.icq := '';
  Info.qslVia := '';
  Info.PhotoURL := '';
  Info.Error := '';
  Info.ErrorCode := '';
end;

end.
