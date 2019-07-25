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
    CheckBox1: TCheckBox;
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
  MainForm_U;

{$R *.lfm}

{ TSettingsProgramForm }

procedure TSettingsProgramForm.Button2Click(Sender: TObject);
begin
  SettingsProgramForm.Close;
end;

procedure TSettingsProgramForm.FormShow(Sender: TObject);
begin
  FileNameEdit1.Text:=fl_path;
  If XMLRPC_FL_USE = 'YES' then CheckBox1.Checked:=True
  else CheckBox1.Checked:=False;
  If FLDIGI_USE = 'YES' then CheckBox2.Checked:=True
  else CheckBox2.Checked:=False;
  FileNameEdit2.Text:=wsjt_path;
  If WSJT_USE = 'YES' then CheckBox4.Checked:=True
  else CheckBox4.Checked:=False;
end;

procedure TSettingsProgramForm.Button1Click(Sender: TObject);
begin
  IniF.WriteString('FLDIGI', 'FldigiPATH', FileNameEdit1.Text);
  IniF.WriteString('WSJT', 'WSJTPATH', FileNameEdit2.Text);
  case CheckBox1.Checked of
  True: IniF.WriteString('FLDIGI', 'XMLRPC', 'YES');
  False: IniF.WriteString('FLDIGI', 'XMLRPC', 'NO');
  end;

    case CheckBox4.Checked of
  True: IniF.WriteString('WSJT', 'USEWSJT', 'YES');
  False: IniF.WriteString('WSJT', 'USEWSJT', 'NO');
  end;

  case CheckBox2.Checked of
  True: begin IniF.WriteString('FLDIGI', 'USEFLDIGI', 'YES'); MainForm.MenuItem74.Enabled:=True; end;
  False: begin IniF.WriteString('FLDIGI', 'USEFLDIGI', 'NO'); MainForm.MenuItem74.Enabled:=False; end;
  end;
  SettingsProgramForm.Close;
end;

end.

