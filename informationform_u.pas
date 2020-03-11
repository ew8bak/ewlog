unit InformationForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, ExtCtrls, httpsend, LCLIntf, IntfGraphics, resourcestr;

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
    procedure FormShow(Sender: TObject);
  private
    calsign: string;
    statusInfo: boolean;
    ErrorCode: string;
    { private declarations }
  public
    sessionNumQRZRU: string;
    sessionNumQRZCOM: string;
    procedure GetInformation(Call: string);
    procedure GetQRZru(Call: string);
    procedure GetQRZcom(Call: string);
    procedure GetSession;
    function GetError(error_msg: string): boolean;
    procedure ReloadInformation;
    { public declarations }
  end;

var
  InformationForm: TInformationForm;

implementation

uses MainForm_U, editqso_u, dmFunc_U, getSessionID;

{$R *.lfm}

{ TInformationForm }

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
    MainForm.StatusBar1.Panels.Items[0].Text := 'QRZ.COM XML:' + ErrorCode;
    Result := True;
    Exit;
  end;

  if (Pos('Callsign not found', ErrorCode) > 0) then
  begin
    MainForm.StatusBar1.Panels.Items[0].Text := 'QRZ.RU XML:' + ErrorCode;
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

procedure TInformationForm.GetQRZcom(Call: string);
var
  resp, PhotoString: string;
  beginSTR, endSTR: integer;
  Photo: TJPEGImage;
begin
  try
    ErrorCode := '';
    Photo := TJPEGImage.Create;
    PhotoString := '';
    Photo.Clear;

    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', 'http://xmldata.qrz.com/xml/current/?s=' +
        sessionNumQRZCOM + ';callsign=' + Call) then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    //Обработка ошибки
    beginSTR := resp.IndexOf('<Error>');
    endSTR := resp.IndexOf('</Error>');
    if (beginSTR <> endSTR) then
      errorCode := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    if ErrorCode <> '' then
      if GetError(ErrorCode) then
        Exit;

    //Позывной
    beginSTR := resp.IndexOf('<call>');
    endSTR := resp.IndexOf('</call>');
    if (beginSTR <> endSTR) then
    begin
      Label14.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);
      GroupBox1.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);
    end;

    //Имя
    beginSTR := resp.IndexOf('<fname>');
    endSTR := resp.IndexOf('</fname>');
    if (beginSTR <> endSTR) then
      Label16.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //Город
    beginSTR := resp.IndexOf('<addr1>');
    endSTR := resp.IndexOf('</addr1>');
    if (beginSTR <> endSTR) then
      Label17.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //Локатор
    beginSTR := resp.IndexOf('<grid>');
    endSTR := resp.IndexOf('</grid>');
    if (beginSTR <> endSTR) then
      Label19.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    //State
    beginSTR := resp.IndexOf('<state>');
    endSTR := resp.IndexOf('</state>');
    if (beginSTR <> endSTR) then
      Label21.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //Страна
    beginSTR := resp.IndexOf('<country>');
    endSTR := resp.IndexOf('</country>');
    if (beginSTR <> endSTR) then
      Label15.Caption := resp.Substring(beginSTR + 9, endSTR - beginSTR - 9);

    //Дом страница
    beginSTR := resp.IndexOf('<url>');
    endSTR := resp.IndexOf('</url>');
    if (beginSTR <> endSTR) then
      Label20.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);

    //Телефон
    beginSTR := resp.IndexOf('<telephone>');
    endSTR := resp.IndexOf('</telephone>');
    if (beginSTR <> endSTR) then
      Label22.Caption := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);

    //email
    beginSTR := resp.IndexOf('<email>');
    endSTR := resp.IndexOf('</email>');
    if (beginSTR <> endSTR) then
      Label23.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //улица
    beginSTR := resp.IndexOf('<addr2>');
    endSTR := resp.IndexOf('</addr2>');
    if (beginSTR <> endSTR) then
      Label18.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //icq
    beginSTR := resp.IndexOf('<icq>');
    endSTR := resp.IndexOf('</icq>');
    if (beginSTR <> endSTR) then
      Label24.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);

    //QSL VIA
    beginSTR := resp.IndexOf('<qslvia>');
    endSTR := resp.IndexOf('</qslvia>');
    if (beginSTR <> endSTR) then
      Label26.Caption := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

    //Photo
    beginSTR := resp.IndexOf('<image>');
    endSTR := resp.IndexOf('</image>');
    if (beginSTR <> endSTR) then
      PhotoString := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    if PhotoString <> '' then
    begin
      InformationForm.Height := 658;
      with THTTPSend.Create do
      begin
        if HTTPMethod('GET', PhotoString) then
        begin
          Photo.LoadFromStream(Document);
          if DirectoryEdit1.Text <> '' then
            Photo.SaveToFile(DirectoryEdit1.Text + DirectorySeparator + Call + '.jpg');
        end;
        Free;
      end;
      Image1.Picture.Assign(Photo);
    end
    else
      InformationForm.Height := 364;
  finally
    Photo.Free;
  end;
end;

procedure TInformationForm.GetQRZru(Call: string);
var
  resp, PhotoString: string;
  beginSTR, endSTR: integer;
  Photo: TJPEGImage;
begin
  try
    ErrorCode := '';
    Photo := TJPEGImage.Create;
    PhotoString := '';
    Photo.Clear;

    with THTTPSend.Create do
    begin
      if HTTPMethod('GET', 'http://api.qrz.ru/callsign?id=' +
        sessionNumQRZRU + '&callsign=' + Call) then
      begin
        SetString(resp, PChar(Document.Memory), Document.Size div SizeOf(char));
      end;
      Free;
    end;

    //Обработка ошибки
    beginSTR := resp.IndexOf('<error>');
    endSTR := resp.IndexOf('</error>');
    if (beginSTR <> endSTR) then
      ErrorCode := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    if ErrorCode <> '' then
      if GetError(ErrorCode) then
        Exit;

    //Позывной
    beginSTR := resp.IndexOf('<call>');
    endSTR := resp.IndexOf('</call>');
    if (beginSTR <> endSTR) then
    begin
      Label14.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);
      GroupBox1.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);
    end;

    //Имя
    beginSTR := resp.IndexOf('<name>');
    endSTR := resp.IndexOf('</name>');
    if (beginSTR <> endSTR) then
      Label16.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    //Фамилия
    beginSTR := resp.IndexOf('<surname>');
    endSTR := resp.IndexOf('</surname>');
    if (beginSTR <> endSTR) then
      Label16.Caption := Label16.Caption + ' ' +
        resp.Substring(beginSTR + 9, endSTR - beginSTR - 9);

    //Город
    beginSTR := resp.IndexOf('<city>');
    endSTR := resp.IndexOf('</city>');
    if (beginSTR <> endSTR) then
      Label17.Caption := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    //Локатор
    beginSTR := resp.IndexOf('<qthloc>');
    endSTR := resp.IndexOf('</qthloc>');
    if (beginSTR <> endSTR) then
      Label19.Caption := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

    //State
    beginSTR := resp.IndexOf('<state>');
    endSTR := resp.IndexOf('</state>');
    if (beginSTR <> endSTR) then
      Label21.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //Страна
    beginSTR := resp.IndexOf('<country>');
    endSTR := resp.IndexOf('</country>');
    if (beginSTR <> endSTR) then
      Label15.Caption := resp.Substring(beginSTR + 9, endSTR - beginSTR - 9);

    //Дом страница
    beginSTR := resp.IndexOf('<url>');
    endSTR := resp.IndexOf('</url>');
    if (beginSTR <> endSTR) then
      Label20.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);


    //Телефон
    beginSTR := resp.IndexOf('<telephone>');
    endSTR := resp.IndexOf('</telephone>');
    if (beginSTR <> endSTR) then
      Label22.Caption := resp.Substring(beginSTR + 11, endSTR - beginSTR - 11);

    //email
    beginSTR := resp.IndexOf('<email>');
    endSTR := resp.IndexOf('</email>');
    if (beginSTR <> endSTR) then
      Label23.Caption := resp.Substring(beginSTR + 7, endSTR - beginSTR - 7);

    //улица
    beginSTR := resp.IndexOf('<street>');
    endSTR := resp.IndexOf('</street>');
    if (beginSTR <> endSTR) then
      Label18.Caption := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

    //icq
    beginSTR := resp.IndexOf('<icq>');
    endSTR := resp.IndexOf('</icq>');
    if (beginSTR <> endSTR) then
      Label24.Caption := resp.Substring(beginSTR + 5, endSTR - beginSTR - 5);

    //QSL VIA
    beginSTR := resp.IndexOf('<qslvia>');
    endSTR := resp.IndexOf('</qslvia>');
    if (beginSTR <> endSTR) then
      Label26.Caption := resp.Substring(beginSTR + 8, endSTR - beginSTR - 8);

    //Photo
    beginSTR := resp.IndexOf('<file>');
    endSTR := resp.IndexOf('</file>');
    if (beginSTR <> endSTR) then
      PhotoString := resp.Substring(beginSTR + 6, endSTR - beginSTR - 6);

    if PhotoString <> '' then
    begin
      InformationForm.Height := 658;
      with THTTPSend.Create do
      begin
        if HTTPMethod('GET', PhotoString) then
        begin
          Photo.LoadFromStream(Document);
          if DirectoryEdit1.Text <> '' then
            Photo.SaveToFile(DirectoryEdit1.Text + DirectorySeparator + Call + '.jpg');
        end;
        Free;
      end;
      Image1.Picture.Assign(Photo);
    end
    else
      InformationForm.Height := 364;
  finally
    Photo.Free;
  end;
end;

procedure TInformationForm.GetInformation(Call: string);
begin
  if Call <> '' then
  begin
    if IniF.ReadString('SetLog', 'Sprav', 'False') = 'True' then
    begin
      if sessionNumQRZRU <> '' then
      begin
        //Получение данных с QRZ.RU
        GetQRZru(Call);
      end
      else
        GetSession;
    end;

    if IniF.ReadString('SetLog', 'SpravQRZCOM', 'False') = 'True' then
    begin
      if sessionNumQRZCOM <> '' then
      begin
        //Получение данных с QRZ.COM
        GetQRZcom(Call);
      end
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
  statusInfo := False;

  DirectoryEdit1.Text := MainForm.PhotoDir;

  if (MainForm.EditButton1.Text <> '') and (EditQSO_Form.Edit1.Text = '') then
    calsign := MainForm.EditButton1.Text
  else
    calsign := EditQSO_Form.Edit1.Text;

  GetInformation(calsign);

{
  if (IniF.ReadString('SetLog', 'Sprav', 'False') = 'False') and
    (IniF.ReadString('SetLog', 'SpravQRZCOM', 'False') = 'False') then
    ShowMessage(rNotConfigSprav)
  else
    ErrorCall := 'F';

  if IniF.ReadString('SetLog', 'Sprav', 'False') = 'True' then
    if (loginQRZru = '') or (passQRZru = '') then
      ShowMessage(rNotConfigQRZRU);
  if IniF.ReadString('SetLog', 'SpravQRZCOM', 'False') = 'True' then
    if (loginQRZcom = '') or (passQRZcom = '') then
      ShowMessage(rNotConfigQRZCOM);


  if (MainForm.EditButton1.Text <> '') and (EditQSO_Form.Edit1.Text = '') then
    calsign := MainForm.EditButton1.Text
  else
    calsign := EditQSO_Form.Edit1.Text;

  if IniF.ReadString('SetLog', 'Sprav', '') = 'True' then
    if (loginQRZru = '') or (passQRZru = '') then
    begin
      ShowMessage(rNotConfigQRZRU);
      ErrorCall := 'F';
    end
    else
    begin
      InformationForm.Caption := rInformationFromQRZRU;
      //   QRZRU(calsign);
      if (ErrorCall <> '') and (ErrorCall <> 'F') then
        ShowMessage('QRZ.RU:' + ErrorCall);
    end;


  if IniF.ReadString('SetLog', 'SpravQRZCOM', '') = 'True' then
    if (loginQRZcom <> '') or (passQRZcom <> '') then
    begin
      ShowMessage(rNotConfigQRZCOM);
      ErrorCall := 'F';
    end
    else
    begin
      InformationForm.Caption := rInformationFromQRZCOM;
      //     QRZCOM(calsign);
      if (ErrorCall <> '') and (ErrorCall <> 'F') then
        ShowMessage('QRZ.COM:' + ErrorCall);
    end;


  if ErrorCall <> '' then
  begin
    ErrorCall := '';
    //   HAMQTH(calsign);
    InformationForm.Caption := rInformationFromHamQTH;
  end;
   }
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
