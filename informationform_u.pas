unit InformationForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, ExtCtrls, httpsend, LCLIntf, IntfGraphics, resourcestr, openssl;

const
  URL_QRZRU = 'https://api.qrz.ru/callsign?id=';
  URL_QRZCOM = 'https://xmldata.qrz.com/xml/current/?s=';
  URL_HAMQTH = 'https://www.hamqth.com/xml.php?id=';

type

  { TInformationForm }

  TInformationForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    DirectoryEdit1: TDirectoryEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    calsign: string;
    statusInfo: boolean;
    ErrorCode: string;
    PhotoJPEG: TJPEGImage;
    PhotoGIF: TGIFImage;
    PhotoPNG: TPortableNetworkGraphic;
    { private declarations }
  public
    sessionNumQRZRU: string;
    sessionNumQRZCOM: string;
    sessionNumHAMQTH: string;
    procedure GetInformation(Call: string);
    procedure GetQRZru(Call: string);
    procedure GetQRZcom(Call: string);
    procedure GetHAMQTH(Call: string);
    procedure GetSession;
    procedure GetPhoto(url, Call: string);
    procedure ReloadInformation;
    function GetError(error_msg: string): boolean;
    function GetXMLField(resp, field: string): string;
    { public declarations }
  end;

var
  InformationForm: TInformationForm;

implementation

uses MainForm_U, editqso_u, dmFunc_U, getSessionID;

{$R *.lfm}

{ TInformationForm }

function TInformationForm.GetXMLField(resp, field: string): string;
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

procedure TInformationForm.GetPhoto(url, Call: string);
begin
  if url <> '' then
  begin
    InformationForm.Height := 658;
    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', url) then
      begin
        Delete(url, Pos('?', url), Length(url));
        if dmFunc.Extention(url) = '.gif' then
          PhotoGIF.LoadFromStream(Document);
        if dmFunc.Extention(url) = '.jpg' then
          PhotoJPEG.LoadFromStream(Document);
        if dmFunc.Extention(url) = '.png' then
          PhotoPNG.LoadFromStream(Document);

        if DirectoryEdit1.Text <> '' then
        begin
          if dmFunc.Extention(url) = '.gif' then
            PhotoGIF.SaveToFile(DirectoryEdit1.Text + DirectorySeparator +
              Call + '.gif');
          if dmFunc.Extention(url) = '.jpg' then
            PhotoJPEG.SaveToFile(DirectoryEdit1.Text + DirectorySeparator +
              Call + '.jpg');
          if dmFunc.Extention(url) = '.png' then
            PhotoPNG.SaveToFile(DirectoryEdit1.Text + DirectorySeparator +
              Call + '.png');
        end;
      end;
      Free;
    end;
    if dmFunc.Extention(url) = '.gif' then
      Image1.Picture.Assign(PhotoGIF);
    if dmFunc.Extention(url) = '.jpg' then
      Image1.Picture.Assign(PhotoJPEG);
    if dmFunc.Extention(url) = '.png' then
      Image1.Picture.Assign(PhotoPNG);
  end
  else
    InformationForm.Height := 364;
end;

function TInformationForm.GetError(error_msg: string): boolean;
begin
  Result := False;
  if (error_msg = 'Invalid session key') or (error_msg = 'Session Timeout') or
    (error_msg = 'Session does not exist or expired') then
  begin
    Result := True;
    GetSession;
    Exit;
  end;

  if (Pos('Not found:', ErrorCode) > 0) then
  begin
    MainForm.StatusBar1.Panels.Items[0].Text := ErrorCode;
    Result := True;
    Exit;
  end;

  if (Pos('Callsign not found', ErrorCode) > 0) then
  begin
    MainForm.StatusBar1.Panels.Items[0].Text := ErrorCode;
    Result := True;
    Exit;
  end;

end;

procedure TInformationForm.ReloadInformation;
begin
  if ErrorCode <> '' then
  begin
    ErrorCode := '';
    GetInformation(calsign);
  end;
end;

procedure TInformationForm.GetSession;
begin
  GetSessionThread := TGetSessionThread.Create;
  if Assigned(GetSessionThread.FatalException) then
    raise GetSessionThread.FatalException;
  with GetSessionThread do
  begin
    qrzcom_login := IniF.ReadString('SetLog', 'QRZCOM_Login', '');
    qrzcom_pass := IniF.ReadString('SetLog', 'QRZCOM_Pass', '');
    qrzru_login := IniF.ReadString('SetLog', 'QRZ_Login', '');
    qrzru_pass := IniF.ReadString('SetLog', 'QRZ_Pass', '');
    Start;
  end;
end;

procedure TInformationForm.GetHAMQTH(Call: string);
var
  resp: string;
begin
  try
    ErrorCode := '';
    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', URL_HAMQTH + sessionNumHAMQTH + '&callsign=' +
        Call + '&prg=EWLog') then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    //Обработка ошибки
    ErrorCode := GetXMLField(resp, 'error');
    if ErrorCode <> '' then
      if GetError(ErrorCode) then
        Exit;

    //Позывной
    Label14.Caption := GetXMLField(resp, 'callsign');
    GroupBox1.Caption := Label14.Caption;
    //Имя
    Label16.Caption := GetXMLField(resp, 'nick');
    //Город
    Label17.Caption := GetXMLField(resp, 'street');
    //Локатор
    Label19.Caption := GetXMLField(resp, 'grid');
    //State
    Label21.Caption := GetXMLField(resp, 'state');
    //Страна
    Label15.Caption := GetXMLField(resp, 'country');
    //Дом страница
    Label20.Caption := GetXMLField(resp, 'web');
    //Телефон
    Label22.Caption := GetXMLField(resp, 'telephone');
    //email
    Label23.Caption := GetXMLField(resp, 'email');
    //улица
    Label18.Caption := GetXMLField(resp, 'adr_city');
    //icq
    Label24.Caption := GetXMLField(resp, 'icq');
    //Photo
    GetPhoto(GetXMLField(resp, 'picture'), Call);
  finally
    FreeAndNil(PhotoGIF);
    FreeAndNil(PhotoJPEG);
    FreeAndNil(PhotoPNG);
  end;
end;

procedure TInformationForm.GetQRZcom(Call: string);
var
  resp: string;
begin
  try
    ErrorCode := '';

    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', URL_QRZCOM + sessionNumQRZCOM +
        ';callsign=' + Call) then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    //Обработка ошибки
    errorCode := GetXMLField(resp, 'Error');

    if ErrorCode <> '' then
      if GetError(ErrorCode) then
        Exit;

    //Позывной
    Label14.Caption := GetXMLField(resp, 'call');
    GroupBox1.Caption := Label14.Caption;
    //Имя
    Label16.Caption := GetXMLField(resp, 'fname');
    //Город
    Label17.Caption := GetXMLField(resp, 'addr1');
    //Локатор
    Label19.Caption := GetXMLField(resp, 'grid');
    //State
    Label21.Caption := GetXMLField(resp, 'state');
    //Страна
    Label15.Caption := GetXMLField(resp, 'country');
    //Дом страница
    Label20.Caption := GetXMLField(resp, 'url');
    //Телефон
    Label22.Caption := GetXMLField(resp, 'telephone');
    //email
    Label23.Caption := GetXMLField(resp, 'email');
    //улица
    Label18.Caption := GetXMLField(resp, 'addr2');
    //icq
    Label24.Caption := GetXMLField(resp, 'icq');
    //QSL VIA
    Label26.Caption := GetXMLField(resp, 'qslvia');
    //Photo
    GetPhoto(GetXMLField(resp, 'image'), Call);
  finally
    if Label14.Caption <> '' then
      statusInfo := True
    else
      statusInfo := False;
    FreeAndNil(PhotoGIF);
    FreeAndNil(PhotoJPEG);
    FreeAndNil(PhotoPNG);
  end;
end;

procedure TInformationForm.GetQRZru(Call: string);
var
  resp: string;
begin
  try
    ErrorCode := '';
    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', URL_QRZRU + sessionNumQRZRU + '&callsign=' + Call) then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    //Обработка ошибки
    ErrorCode := GetXMLField(resp, 'error');

    if ErrorCode <> '' then
      if GetError(ErrorCode) then
        Exit;

    //Позывной
    Label14.Caption := GetXMLField(resp, 'call');
    GroupBox1.Caption := Label14.Caption;
    //Имя
    Label16.Caption := GetXMLField(resp, 'name');
    //Фамилия
    Label16.Caption := Label16.Caption + ' ' + GetXMLField(resp, 'surname');
    //Город
    Label17.Caption := GetXMLField(resp, 'city');
    //Локатор
    Label19.Caption := GetXMLField(resp, 'qthloc');
    //State
    Label21.Caption := GetXMLField(resp, 'state');
    //Страна
    Label15.Caption := GetXMLField(resp, 'country');
    //Дом страница
    Label20.Caption := GetXMLField(resp, 'url');
    //Телефон
    Label22.Caption := GetXMLField(resp, 'telephone');
    //email
    Label23.Caption := GetXMLField(resp, 'email');
    //улица
    Label18.Caption := GetXMLField(resp, 'street');
    //icq
    Label24.Caption := GetXMLField(resp, 'icq');
    //QSL VIA
    Label26.Caption := GetXMLField(resp, 'qslvia');
    //Photo
    GetPhoto(GetXMLField(resp, 'file'), Call);
  finally
    if Label14.Caption <> '' then
      statusInfo := True
    else
      statusInfo := False;
    FreeAndNil(PhotoGIF);
    FreeAndNil(PhotoJPEG);
    FreeAndNil(PhotoPNG);
  end;
end;

procedure TInformationForm.GetInformation(Call: string);
begin
  if Call <> '' then
  begin
    PhotoJPEG := TJPEGImage.Create;
    PhotoGIF := TGIFImage.Create;
    PhotoPNG := TPortableNetworkGraphic.Create;
    if IniF.ReadString('SetLog', 'Sprav', 'False') = 'True' then
    begin
      if sessionNumQRZRU <> '' then
        GetQRZru(Call)  //Получение данных с QRZ.RU
      else
        GetSession;
    end;

    if IniF.ReadString('SetLog', 'SpravQRZCOM', 'False') = 'True' then
    begin
      if sessionNumQRZCOM <> '' then
        GetQRZcom(Call) //Получение данных с QRZ.COM
      else
        GetSession;
    end;

    if not statusInfo then
    begin
      if sessionNumHAMQTH <> '' then
        GetHAMQTH(Call) //Получение данных с HAMQTH
      else
        GetSession;
    end;

  end;
end;

procedure TInformationForm.FormShow(Sender: TObject);
begin
  Label14.Caption := '';
  Label15.Caption := '';
  Label16.Caption := '';
  Label17.Caption := '';
  Label18.Caption := '';
  Label19.Caption := '';
  Label20.Caption := '';
  Label21.Caption := '';
  Label22.Caption := '';
  Label23.Caption := '';
  Label23.Caption := '';
  Label24.Caption := '';
  Label25.Caption := '';
  Label26.Caption := '';
  GroupBox1.Caption := rCallSign;
  ErrorCode := '';
  calsign := '';

  DirectoryEdit1.Text := MainForm.PhotoDir;

  if (MainForm.EditButton1.Text <> '') and (EditQSO_Form.Edit1.Text = '') then
    calsign := MainForm.EditButton1.Text
  else
    calsign := EditQSO_Form.Edit1.Text;

  GetInformation(calsign);
end;

procedure TInformationForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniF.WriteString('SetLog', 'PhotoDir', DirectoryEdit1.Text);
  MainForm.PhotoDir := DirectoryEdit1.Text;
  Label14.Caption := '';
  Label15.Caption := '';
  Label16.Caption := '';
  Label17.Caption := '';
  Label18.Caption := '';
  Label19.Caption := '';
  Label20.Caption := '';
  Label21.Caption := '';
  Label22.Caption := '';
  Label23.Caption := '';
  Label23.Caption := '';
  Label24.Caption := '';
  Label25.Caption := '';
  Label26.Caption := '';
  GroupBox1.Caption := rCallSign;
end;

procedure TInformationForm.FormCreate(Sender: TObject);
begin
  ErrorCode := '';
  GetSession;
end;

procedure TInformationForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(PhotoGIF);
  FreeAndNil(PhotoJPEG);
  FreeAndNil(PhotoPNG);
end;

procedure TInformationForm.Button1Click(Sender: TObject);
begin
  if CheckForm = 'Main' then
  begin
    MainForm.EditButton1.Text := Label14.Caption;
    MainForm.Edit1.Text := Label16.Caption;
    MainForm.Edit2.Text := Label18.Caption;
    MainForm.Edit3.Text := Label19.Caption;
    MainForm.Edit4.Text := Label21.Caption;
  end;
  if CheckForm = 'Edit' then
  begin
    EditQSO_Form.Edit4.Text := Label16.Caption;
    EditQSO_Form.Edit5.Text := Label18.Caption;
    if Label19.Caption <> '' then
      EditQSO_Form.Edit14.Text := Label19.Caption;
    if Label21.Caption <> '' then
      EditQSO_Form.Edit17.Text := Label21.Caption;
  end;
end;

procedure TInformationForm.Button2Click(Sender: TObject);
begin
  OpenURL('http://qrzcq.com/call/' + calsign);
end;

procedure TInformationForm.Button3Click(Sender: TObject);
begin
  OpenURL('https://www.qrz.ru/db/' + calsign);
end;

procedure TInformationForm.Button5Click(Sender: TObject);
begin
  OpenURL('https://www.pskreporter.info/pskmap.html?callsign=' +
    calsign + '&search=Find');
end;

procedure TInformationForm.Button6Click(Sender: TObject);
begin
  OpenURL('https://secure.clublog.org/logsearch/' + calsign);
end;

end.
