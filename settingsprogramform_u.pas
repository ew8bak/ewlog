unit SettingsProgramForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn;

type

  { TSettingsProgramForm }

  TSettingsProgramForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox2: TCheckBox;
    CheckBox4: TCheckBox;
    FileNameEdit1: TFileNameEdit;
    FileNameEdit2: TFileNameEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SettingsProgramForm: TSettingsProgramForm;

implementation

uses
  MainForm_U, InitDB_dm;

{$R *.lfm}

{ TSettingsProgramForm }

procedure TSettingsProgramForm.Button2Click(Sender: TObject);
begin
  SettingsProgramForm.Close;
end;

procedure TSettingsProgramForm.FormShow(Sender: TObject);
begin

//  fl_path := INIFile.ReadString('FLDIGI', 'FldigiPATH', '');
//  wsjt_path := INIFile.ReadString('WSJT', 'WSJTPATH', '');
//  FLDIGI_USE := INIFile.ReadString('FLDIGI', 'USEFLDIGI', '');
//  WSJT_USE := INIFile.ReadString('WSJT', 'USEWSJT', '');

{  FileNameEdit1.Text := fl_path;
  if FLDIGI_USE = 'YES' then
    CheckBox2.Checked := True
  else
    CheckBox2.Checked := False;
  FileNameEdit2.Text := wsjt_path;
  if WSJT_USE = 'YES' then
    CheckBox4.Checked := True
  else
    CheckBox4.Checked := False;
}
end;

procedure TSettingsProgramForm.Button1Click(Sender: TObject);
begin
  INIFile.WriteString('FLDIGI', 'FldigiPATH', FileNameEdit1.Text);
  INIFile.WriteString('WSJT', 'WSJTPATH', FileNameEdit2.Text);

  case CheckBox4.Checked of
    True:
    begin
      INIFile.WriteString('WSJT', 'USEWSJT', 'YES');
      MainForm.MenuItem43.Enabled := True;
    end;
    False:
    begin
      INIFile.WriteString('WSJT', 'USEWSJT', 'NO');
      MainForm.MenuItem43.Enabled := False;
    end
  end;

  case CheckBox2.Checked of
    True:
    begin
      INIFile.WriteString('FLDIGI', 'USEFLDIGI', 'YES');
      MainForm.MenuItem74.Enabled := True;
    end;
    False:
    begin
      INIFile.WriteString('FLDIGI', 'USEFLDIGI', 'NO');
      MainForm.MenuItem74.Enabled := False;
    end;
  end;
  SettingsProgramForm.Close;
end;

end.
