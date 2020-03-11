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
    procedure SessionTimerStartTimer(Sender: TObject);
  private
    calsign: string;
    ErrorCall: string;
    loginQRZru: string;
    passQRZru: string;
    loginQRZcom: string;
    passQRZcom: string;
    { private declarations }
  public
    sessionNumQRZRU: string;
    sessionNumQRZCOM: string;
  //  procedure GetInformation;
    { public declarations }
  end;

var
  InformationForm: TInformationForm;

implementation

uses MainForm_U, editqso_u, dmFunc_U, getSessionID;

{$R *.lfm}

{ TInformationForm }

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
  ErrorCall := '';
  loginQRZru := IniF.ReadString('SetLog', 'QRZ_Login', '');
  passQRZru := IniF.ReadString('SetLog', 'QRZ_Pass', '');

  loginQRZcom := IniF.ReadString('SetLog', 'QRZCOM_Login', '');
  passQRZcom := IniF.ReadString('SetLog', 'QRZCOM_Pass', '');

  DirectoryEdit1.Text := MainForm.PhotoDir;

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

end;

procedure TInformationForm.SessionTimerStartTimer(Sender: TObject);
begin

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
  GetSessionThread := TGetSessionThread.Create;
  if Assigned(GetSessionThread.FatalException) then
    raise GetSessionThread.FatalException;
  with GetSessionThread do
  begin
    qrzcom_login:=IniF.ReadString('SetLog', 'QRZCOM_Login', '');
    qrzcom_pass:=IniF.ReadString('SetLog', 'QRZCOM_Pass', '');
    qrzru_login:=IniF.ReadString('SetLog', 'QRZ_Login', '');
    qrzru_pass:=IniF.ReadString('SetLog', 'QRZ_Pass', '');
    Start;
  end;
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
