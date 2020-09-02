unit InformationForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls,
  EditBtn, ExtCtrls, LCLIntf, resourcestr, inform_record;

type

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
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    Callsign: string;
    FromForm: string;
    procedure LabelClear;
    procedure LoadFromInternetCallBook(info: TInformRecord);
    procedure LoadPhotoFromInternetCallbook(info: TInformRecord);

    { public declarations }
  end;

var
  InformationForm: TInformationForm;

implementation

uses MainForm_U, editqso_u, dmFunc_U, InitDB_dm, MainFuncDM, infoDM_U;

{$R *.lfm}

{ TInformationForm }

procedure TInformationForm.LoadFromInternetCallBook(info: TInformRecord);
begin
  if Length(info.Callsign) = 0 then begin
  GroupBox1.Caption := info.Error;
  Exit;
  end;
  Label14.Caption := info.Callsign;
  GroupBox1.Caption := info.Callsign;
  Label16.Caption := info.Name + ' ' + info.SurName;
  Label17.Caption := info.Address;
  Label18.Caption := info.City;
  Label19.Caption := info.Grid;
  Label21.Caption := info.State;
  Label15.Caption := info.Country;
  Label20.Caption := info.HomePage;
  Label22.Caption := info.Telephone;
  Label23.Caption := info.eMail;
  Label24.Caption := info.ICQ;
  Label26.Caption := info.qslVia;
end;

procedure TInformationForm.LoadPhotoFromInternetCallbook(info: TInformRecord);
begin
    if dmFunc.Extention(info.PhotoURL) = '.gif' then
      Image1.Picture.Assign(info.PhotoGIF);
    if dmFunc.Extention(info.PhotoURL) = '.jpg' then
      Image1.Picture.Assign(info.PhotoJPEG);
    if dmFunc.Extention(info.PhotoURL) = '.png' then
      Image1.Picture.Assign(info.PhotoPNG);
end;

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
  Image1.Picture.Clear;
end;

procedure TInformationForm.FormShow(Sender: TObject);
begin
  LabelClear;
  GroupBox1.Caption := rCallSign;
  DirectoryEdit1.Text := IniSet.PhotoDir;
  InfoDM.GetInformation(Callsign, 'InformationForm');
end;

procedure TInformationForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  INIFile.WriteString('SetLog', 'PhotoDir', DirectoryEdit1.Text);
  IniSet.PhotoDir := DirectoryEdit1.Text;
  LabelClear;
  GroupBox1.Caption := rCallSign;
  Callsign:='';
end;

procedure TInformationForm.Button1Click(Sender: TObject);
begin
  if FromForm = 'MainForm' then
  begin
    MainForm.EditButton1.Text := Label14.Caption;
    MainForm.Edit1.Text := Label16.Caption;
    MainForm.Edit2.Text := Label18.Caption;
    MainForm.Edit3.Text := Label19.Caption;
    MainForm.Edit4.Text := Label21.Caption;
  end;
  if FromForm = 'EditForm' then
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
   OpenURL('http://qrzcq.com/call/' + Callsign);
end;

procedure TInformationForm.Button3Click(Sender: TObject);
begin
   OpenURL('https://www.qrz.ru/db/' + Callsign);
end;

procedure TInformationForm.Button5Click(Sender: TObject);
begin
  OpenURL('https://www.pskreporter.info/pskmap.html?callsign=' +
    Callsign + '&search=Find');
end;

procedure TInformationForm.Button6Click(Sender: TObject);
begin
  OpenURL('https://secure.clublog.org/logsearch/' + Callsign);
end;

end.
