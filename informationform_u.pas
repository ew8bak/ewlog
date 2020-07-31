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
  TInform = record
    Callsign: string;
    Country: string;
    Name: string;
    SurName: string;
    Address1: string;
    Address: string;
    Grid: string;
    HomePage: string;
    State: string;
    Telephone: string;
    eMail: string;
    ICQ: string;
    QSL_VIA: string;
  end;

  { TInformationForm }

  TInformationForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    DirectoryEdit1: TDirectoryEdit;
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
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
    PhotoJPEG: TJPEGImage;
    PhotoGIF: TGIFImage;
    PhotoPNG: TPortableNetworkGraphic;
    calsign: string;
    statusInfo: boolean;
    ViewReload: boolean;
    ErrorCode: string;
    { private declarations }
  public
    sessionNumQRZRU: string;
    sessionNumQRZCOM: string;
    sessionNumHAMQTH: string;
    Inform: TInform;
    procedure GetInformation(Call: string; Main: boolean);
    procedure GetQRZru(Call: string);
    procedure GetQRZcom(Call: string);
    procedure GetHAMQTH(Call: string);
    procedure GetInfoFromThread(resp, from: string);
    procedure GetSession;
    procedure GetPhoto(url, Call: string);
    procedure ReloadInformation;
    procedure ViewInfo(Main: boolean);
    procedure ViewPhoto(Photo: TMemoryStream; url, call: string; Main: boolean);
    procedure LabelClear;
    function GetError(error_msg: string): boolean;
    function GetXMLField(resp, field: string): string;
    { public declarations }
  end;

var
  InformationForm: TInformationForm;

implementation

uses MainForm_U, editqso_u, dmFunc_U, getSessionID, GetPhotoFromInternet,
  GetInfoFromInternetThread, InitDB_dm;

{$R *.lfm}

{ TInformationForm }

procedure TInformationForm.LabelClear;
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
end;

procedure TInformationForm.ViewPhoto(Photo: TMemoryStream; url, call: string;
  Main: boolean);
begin
  try
    if url <> '' then
    begin
      if dmFunc.Extention(url) = '.gif' then
        if Assigned(PhotoGIF) then
          PhotoGIF.LoadFromStream(Photo);
      if dmFunc.Extention(url) = '.jpg' then
        if Assigned(PhotoJPEG) then
          PhotoJPEG.LoadFromStream(Photo);
      if dmFunc.Extention(url) = '.png' then
        if Assigned(PhotoPNG) then
          PhotoPNG.LoadFromStream(Photo);

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
      if not Main then
      begin
        if dmFunc.Extention(url) = '.gif' then
          Image1.Picture.Assign(PhotoGIF);
        if dmFunc.Extention(url) = '.jpg' then
          Image1.Picture.Assign(PhotoJPEG);
        if dmFunc.Extention(url) = '.png' then
          Image1.Picture.Assign(PhotoPNG);
      end
      else if MainForm.MenuItem111.Checked = True then
      begin
        if dmFunc.Extention(url) = '.gif' then
          MainForm.tIMG.Picture.Assign(PhotoGIF);
        if dmFunc.Extention(url) = '.jpg' then
          MainForm.tIMG.Picture.Assign(PhotoJPEG);
        if dmFunc.Extention(url) = '.png' then
          MainForm.tIMG.Picture.Assign(PhotoPNG);
      end;
    end;

  finally
    FreeAndNil(PhotoJPEG);
    FreeAndNil(PhotoGIF);
    FreeAndNil(PhotoPNG);
  end;
end;

procedure TInformationForm.ViewInfo(Main: boolean);
begin
  try
    if Inform.Callsign <> '' then
      MainForm.StatusBar1.Panels.Items[0].Text := '';

    if Main then
    begin
      MainForm.Edit1.Text := Inform.Name;
      MainForm.Edit2.Text := Inform.Address;
      MainForm.Edit3.Text := Inform.Grid;
      MainForm.Edit4.Text := Inform.State;
    end
    else
    begin
      Label14.Caption := Inform.Callsign;
      GroupBox1.Caption := Label14.Caption;
      Label16.Caption := Inform.Name + ' ' + Inform.SurName;
      Label17.Caption := Inform.Address1;
      Label18.Caption := Inform.Address;
      Label19.Caption := Inform.Grid;
      Label21.Caption := Inform.State;
      Label15.Caption := Inform.Country;
      Label20.Caption := Inform.HomePage;
      Label22.Caption := Inform.Telephone;
      Label23.Caption := Inform.eMail;
      Label24.Caption := Inform.ICQ;
      Label26.Caption := Inform.QSL_VIA;
    end;
  finally
    if Inform.Callsign <> '' then
      statusInfo := True
    else
      statusInfo := False;
  end;
end;

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
  GetPhotoThread := TGetPhotoThread.Create;
  if Assigned(GetPhotoThread.FatalException) then
    raise GetPhotoThread.FatalException;
  Delete(url, Pos('?', url), Length(url));
  GetPhotoThread.url := url;
  GetPhotoThread.call := Call;
  GetPhotoThread.Main := ViewReload;
  GetPhotoThread.Start;
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
    GetInformation(calsign, ViewReload);
  end;
end;

procedure TInformationForm.GetSession;
begin
  GetSessionThread := TGetSessionThread.Create;
  if Assigned(GetSessionThread.FatalException) then
    raise GetSessionThread.FatalException;
  with GetSessionThread do
  begin
    qrzcom_login := INIFile.ReadString('SetLog', 'QRZCOM_Login', '');
    qrzcom_pass := INIFile.ReadString('SetLog', 'QRZCOM_Pass', '');
    qrzru_login := INIFile.ReadString('SetLog', 'QRZ_Login', '');
    qrzru_pass := INIFile.ReadString('SetLog', 'QRZ_Pass', '');
    Start;
  end;
end;

procedure TInformationForm.GetInfoFromThread(resp, from: string);
var
  pictureURL: string;
begin
  pictureURL := '';
  if from = 'HAMQTH' then
  begin
    try
      //Обработка ошибки
      ErrorCode := GetXMLField(resp, 'error');
      if ErrorCode <> '' then
        if GetError(ErrorCode) then
          Exit;

      Inform.Callsign := GetXMLField(resp, 'callsign');
      Inform.Name := GetXMLField(resp, 'nick');
      Inform.Address1 := GetXMLField(resp, 'street');
      Inform.Grid := GetXMLField(resp, 'grid');
      Inform.State := GetXMLField(resp, 'state');
      Inform.Country := GetXMLField(resp, 'country');
      Inform.HomePage := GetXMLField(resp, 'web');
      Inform.Telephone := GetXMLField(resp, 'telephone');
      Inform.eMail := GetXMLField(resp, 'email');
      Inform.Address := GetXMLField(resp, 'adr_city');
      Inform.ICQ := GetXMLField(resp, 'icq');
      pictureURL := GetXMLField(resp, 'picture');
      if pictureURL <> '' then
        GetPhoto(pictureURL, Inform.Callsign);
    finally
      if Inform.Callsign <> '' then
        statusInfo := True
      else
        statusInfo := False;
    end;
  end;

  if from = 'QRZRU' then
  begin
    try
      //Обработка ошибки
      ErrorCode := GetXMLField(resp, 'error');

      if ErrorCode <> '' then
        if GetError(ErrorCode) then
          Exit;

      Inform.Callsign := GetXMLField(resp, 'call');
      Inform.Name := GetXMLField(resp, 'name');
      Inform.SurName := GetXMLField(resp, 'surname');
      Inform.Address := GetXMLField(resp, 'city');
      Inform.Address1 := GetXMLField(resp, 'street');
      Inform.Grid := GetXMLField(resp, 'qthloc');
      Inform.State := GetXMLField(resp, 'state');
      Inform.Country := GetXMLField(resp, 'country');
      Inform.HomePage := GetXMLField(resp, 'url');
      Inform.Telephone := GetXMLField(resp, 'telephone');
      Inform.eMail := GetXMLField(resp, 'email');
      Inform.ICQ := GetXMLField(resp, 'icq');
      Inform.QSL_VIA := GetXMLField(resp, 'qslvia');
      pictureURL := GetXMLField(resp, 'file');
      if pictureURL <> '' then
        GetPhoto(pictureURL, Inform.Callsign);

    finally
      if Inform.Callsign <> '' then
        statusInfo := True
      else
        statusInfo := False;
    end;
  end;

  if from = 'QRZCOM' then
  begin
    try
      //Обработка ошибки
      errorCode := GetXMLField(resp, 'Error');

      if ErrorCode <> '' then
        if GetError(ErrorCode) then
          Exit;

      Inform.Callsign := GetXMLField(resp, 'call');
      Inform.Name := GetXMLField(resp, 'fname');
      Inform.Address := GetXMLField(resp, 'addr2');
      Inform.Address1 := GetXMLField(resp, 'addr1');
      Inform.Grid := GetXMLField(resp, 'grid');
      Inform.State := GetXMLField(resp, 'state');
      Inform.Country := GetXMLField(resp, 'country');
      Inform.HomePage := GetXMLField(resp, 'url');
      Inform.Telephone := GetXMLField(resp, 'telephone');
      Inform.eMail := GetXMLField(resp, 'email');
      Inform.ICQ := GetXMLField(resp, 'icq');
      Inform.QSL_VIA := GetXMLField(resp, 'qslvia');
      pictureURL := GetXMLField(resp, 'image');
      if pictureURL <> '' then
        GetPhoto(pictureURL, Inform.Callsign);

    finally
      if Inform.Callsign <> '' then
        statusInfo := True
      else
        statusInfo := False;
    end;
  end;

  if not statusInfo then
  begin
    if sessionNumHAMQTH <> '' then
    begin
      GetHAMQTH(calsign);
    end
    else
      GetSession;
  end;

  ViewInfo(ViewReload);
end;

procedure TInformationForm.GetHAMQTH(Call: string);
begin
  ErrorCode := '';
  GetInfoThread := TGetInfoThread.Create;
  if Assigned(GetInfoThread.FatalException) then
    raise GetInfoThread.FatalException;
  GetInfoThread.url := URL_HAMQTH + sessionNumHAMQTH + '&callsign=' +
    Call + '&prg=EWLog';
  GetInfoThread.from := 'HAMQTH';
  GetInfoThread.Start;
end;

procedure TInformationForm.GetQRZcom(Call: string);
begin
  ErrorCode := '';
  GetInfoThread := TGetInfoThread.Create;
  if Assigned(GetInfoThread.FatalException) then
    raise GetInfoThread.FatalException;
  GetInfoThread.url := URL_QRZCOM + sessionNumQRZCOM + ';callsign=' + Call;
  GetInfoThread.from := 'QRZCOM';
  GetInfoThread.Start;
end;

procedure TInformationForm.GetQRZru(Call: string);
begin
  ErrorCode := '';
  GetInfoThread := TGetInfoThread.Create;
  if Assigned(GetInfoThread.FatalException) then
    raise GetInfoThread.FatalException;
  GetInfoThread.url := URL_QRZRU + sessionNumQRZRU + '&callsign=' + Call;
  GetInfoThread.from := 'QRZRU';
  GetInfoThread.Start;
end;

procedure TInformationForm.GetInformation(Call: string; Main: boolean);
begin
  if Call <> '' then
  begin
    Call := dmFunc.ExtractCallSign(Call);
    calsign := Call;
    ViewReload := Main;
    if not Assigned(PhotoJPEG) then
    PhotoJPEG := TJPEGImage.Create;
    if not Assigned(PhotoGIF) then
    PhotoGIF := TGIFImage.Create;
    if not Assigned(PhotoPNG) then
    PhotoPNG := TPortableNetworkGraphic.Create;
    Image1.Picture.Clear;
    if INIFile.ReadString('SetLog', 'Sprav', 'False') = 'True' then
    begin
      if sessionNumQRZRU <> '' then
      begin
        GetQRZru(Call);
      end
      else
        GetSession;
    end;

    if INIFile.ReadString('SetLog', 'SpravQRZCOM', 'False') = 'True' then
    begin
      if sessionNumQRZCOM <> '' then
      begin
        GetQRZcom(Call);
      end
      else
        GetSession;
    end;

    if (INIFile.ReadString('SetLog', 'SpravQRZCOM', 'False') = 'False') and
      (INIFile.ReadString('SetLog', 'Sprav', 'False') = 'False') then
    begin
      if sessionNumHAMQTH <> '' then
      begin
        GetHAMQTH(Call);
      end
      else
        GetSession;
    end;
  end;
end;

procedure TInformationForm.FormShow(Sender: TObject);
begin
  LabelClear;
  GroupBox1.Caption := rCallSign;
  ErrorCode := '';
  calsign := '';

  DirectoryEdit1.Text := MainForm.PhotoDir;

  if (MainForm.EditButton1.Text <> '') and (EditQSO_Form.Edit1.Text = '') then
    calsign := MainForm.EditButton1.Text
  else
    calsign := EditQSO_Form.Edit1.Text;

  GetInformation(calsign, False);
end;

procedure TInformationForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  INIFile.WriteString('SetLog', 'PhotoDir', DirectoryEdit1.Text);
  MainForm.PhotoDir := DirectoryEdit1.Text;
  LabelClear;
  GroupBox1.Caption := rCallSign;
end;

procedure TInformationForm.FormCreate(Sender: TObject);
begin
  ErrorCode := '';
  PhotoJPEG := nil;
  PhotoGIF := nil;
  PhotoPNG := nil;
  GetSession;
end;

procedure TInformationForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(PhotoJPEG);
  FreeAndNil(PhotoGIF);
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
