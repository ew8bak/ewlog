unit ConfigGridForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ColorBox;

type

  { TConfigGrid_Form }

  TConfigGrid_Form = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    CheckBox19: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox20: TCheckBox;
    CheckBox21: TCheckBox;
    CheckBox22: TCheckBox;
    CheckBox23: TCheckBox;
    CheckBox24: TCheckBox;
    CheckBox25: TCheckBox;
    CheckBox26: TCheckBox;
    CheckBox27: TCheckBox;
    CheckBox28: TCheckBox;
    CheckBox29: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox30: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    ColorBox1: TColorBox;
    ColorBox2: TColorBox;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
    procedure ColorBox2Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  ConfigGrid_Form: TConfigGrid_Form;

implementation

uses MainForm_U;

{$R *.lfm}

{ TConfigGrid_Form }

procedure TConfigGrid_Form.Button2Click(Sender: TObject);
begin
  ConfigGrid_Form.Close;
end;

procedure TConfigGrid_Form.Button1Click(Sender: TObject);
begin
  IniF.WriteBool('GridSettings', 'ColVisible0', CheckBox1.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible1', CheckBox2.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible2', CheckBox3.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible3', CheckBox4.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible4', CheckBox5.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible5', CheckBox6.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible6', CheckBox7.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible7', CheckBox30.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible8', CheckBox8.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible9', CheckBox9.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible10', CheckBox10.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible11', CheckBox11.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible12', CheckBox12.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible13', CheckBox13.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible14', CheckBox14.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible15', CheckBox15.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible16', CheckBox16.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible17', CheckBox17.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible18', CheckBox18.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible19', CheckBox19.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible20', CheckBox20.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible21', CheckBox21.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible22', CheckBox22.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible23', CheckBox23.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible24', CheckBox24.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible25', CheckBox25.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible26', CheckBox26.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible27', CheckBox27.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible28', CheckBox28.Checked);
  IniF.WriteBool('GridSettings', 'ColVisible29', CheckBox29.Checked);
  IniF.WriteInteger('GridSettings', 'TextColor', ColorBox1.Selected);
  IniF.WriteInteger('GridSettings', 'BackColor', ColorBox2.Selected);
  case ComboBox1.ItemIndex of
    0: IniF.WriteInteger('GridSettings', 'TextSize', 8);
    1: IniF.WriteInteger('GridSettings', 'TextSize', 10);
    2: IniF.WriteInteger('GridSettings', 'TextSize', 12);
    3: IniF.WriteInteger('GridSettings', 'TextSize', 14);
  end;

  MainForm.SetGrid;
end;

procedure TConfigGrid_Form.Button3Click(Sender: TObject);
begin
  CheckBox1.Checked := True;
  CheckBox2.Checked := True;
  CheckBox3.Checked := True;
  CheckBox4.Checked := True;
  CheckBox5.Checked := True;
  CheckBox6.Checked := True;
  CheckBox7.Checked := True;
  CheckBox30.Checked := True;
  CheckBox8.Checked := True;
  CheckBox9.Checked := True;
  CheckBox10.Checked := True;
  CheckBox11.Checked := True;
  CheckBox12.Checked := True;
  CheckBox13.Checked := True;
  CheckBox14.Checked := True;
  CheckBox15.Checked := True;
  CheckBox16.Checked := True;
  CheckBox17.Checked := True;
  CheckBox18.Checked := True;
  CheckBox19.Checked := True;
  CheckBox20.Checked := True;
  CheckBox21.Checked := True;
  CheckBox22.Checked := True;
  CheckBox23.Checked := True;
  CheckBox24.Checked := True;
  CheckBox25.Checked := True;
  CheckBox26.Checked := True;
  CheckBox27.Checked := True;
  CheckBox28.Checked := True;
  CheckBox29.Checked := True;
  ComboBox1.ItemIndex := 0;
  ColorBox2.ItemIndex := ColorBox2.Items.IndexOf('clForm');
  ColorBox1.ItemIndex := ColorBox1.Items.IndexOf('clBlack');
end;

procedure TConfigGrid_Form.ColorBox1Change(Sender: TObject);
begin
  MainForm.DBGrid1.Font.Color := ColorBox1.Selected;
  MainForm.DBGrid2.Font.Color := ColorBox1.Selected;
end;

procedure TConfigGrid_Form.ColorBox2Change(Sender: TObject);
begin
  MainForm.DBGrid1.Color := ColorBox2.Selected;
  MainForm.DBGrid2.Color := ColorBox2.Selected;
end;

procedure TConfigGrid_Form.ComboBox1Change(Sender: TObject);
var
  i: integer;
begin
  case ComboBox1.ItemIndex of
    0: MainForm.DBGrid1.Font.Size := 8;
    1: MainForm.DBGrid1.Font.Size := 10;
    2: MainForm.DBGrid1.Font.Size := 12;
    3: MainForm.DBGrid1.Font.Size := 14;
  end;

  case ComboBox1.ItemIndex of
    0: MainForm.DBGrid1.DefaultRowHeight := 15;
    1: MainForm.DBGrid1.DefaultRowHeight := MainForm.DBGrid1.Font.Size + 12;
    2: MainForm.DBGrid1.DefaultRowHeight := MainForm.DBGrid1.Font.Size + 12;
    3: MainForm.DBGrid1.DefaultRowHeight := MainForm.DBGrid1.Font.Size + 12;
  end;
  case ComboBox1.ItemIndex of
    0: MainForm.DBGrid2.Font.Size := 8;
    1: MainForm.DBGrid2.Font.Size := 10;
    2: MainForm.DBGrid2.Font.Size := 12;
    3: MainForm.DBGrid2.Font.Size := 14;
  end;

  case ComboBox1.ItemIndex of
    0: MainForm.DBGrid2.DefaultRowHeight := 15;
    1: MainForm.DBGrid2.DefaultRowHeight := MainForm.DBGrid2.Font.Size + 12;
    2: MainForm.DBGrid2.DefaultRowHeight := MainForm.DBGrid2.Font.Size + 12;
    3: MainForm.DBGrid2.DefaultRowHeight := MainForm.DBGrid2.Font.Size + 12;
  end;

  for i := 0 to MainForm.DBGrid1.Columns.Count - 1 do
  begin
    case ComboBox1.ItemIndex of
      0: MainForm.DBGrid1.Columns.Items[i].Title.Font.Size := 8;
      1: MainForm.DBGrid1.Columns.Items[i].Title.Font.Size := 10;
      2: MainForm.DBGrid1.Columns.Items[i].Title.Font.Size := 12;
      3: MainForm.DBGrid1.Columns.Items[i].Title.Font.Size := 14;
    end;
  end;
  for i := 0 to MainForm.DBGrid2.Columns.Count - 1 do
  begin
    case ComboBox1.ItemIndex of
      0: MainForm.DBGrid2.Columns.Items[i].Title.Font.Size := 8;
      1: MainForm.DBGrid2.Columns.Items[i].Title.Font.Size := 10;
      2: MainForm.DBGrid2.Columns.Items[i].Title.Font.Size := 12;
      3: MainForm.DBGrid2.Columns.Items[i].Title.Font.Size := 14;
    end;
  end;

end;

procedure TConfigGrid_Form.FormShow(Sender: TObject);
begin
  CheckBox1.Checked := IniF.ReadBool('GridSettings', 'ColVisible0', True);
  CheckBox2.Checked := IniF.ReadBool('GridSettings', 'ColVisible1', True);
  CheckBox3.Checked := IniF.ReadBool('GridSettings', 'ColVisible2', True);
  CheckBox4.Checked := IniF.ReadBool('GridSettings', 'ColVisible3', True);
  CheckBox5.Checked := IniF.ReadBool('GridSettings', 'ColVisible4', True);
  CheckBox6.Checked := IniF.ReadBool('GridSettings', 'ColVisible5', True);
  CheckBox7.Checked := IniF.ReadBool('GridSettings', 'ColVisible6', True);
  CheckBox30.Checked := IniF.ReadBool('GridSettings', 'ColVisible7', True);
  CheckBox8.Checked := IniF.ReadBool('GridSettings', 'ColVisible8', True);
  CheckBox9.Checked := IniF.ReadBool('GridSettings', 'ColVisible9', True);
  CheckBox10.Checked := IniF.ReadBool('GridSettings', 'ColVisible10', True);
  CheckBox11.Checked := IniF.ReadBool('GridSettings', 'ColVisible11', True);
  CheckBox12.Checked := IniF.ReadBool('GridSettings', 'ColVisible12', True);
  CheckBox13.Checked := IniF.ReadBool('GridSettings', 'ColVisible13', True);
  CheckBox14.Checked := IniF.ReadBool('GridSettings', 'ColVisible14', True);
  CheckBox15.Checked := IniF.ReadBool('GridSettings', 'ColVisible15', True);
  CheckBox16.Checked := IniF.ReadBool('GridSettings', 'ColVisible16', True);
  CheckBox17.Checked := IniF.ReadBool('GridSettings', 'ColVisible17', True);
  CheckBox18.Checked := IniF.ReadBool('GridSettings', 'ColVisible18', True);
  CheckBox19.Checked := IniF.ReadBool('GridSettings', 'ColVisible19', True);
  CheckBox20.Checked := IniF.ReadBool('GridSettings', 'ColVisible20', True);
  CheckBox21.Checked := IniF.ReadBool('GridSettings', 'ColVisible21', True);
  CheckBox22.Checked := IniF.ReadBool('GridSettings', 'ColVisible22', True);
  CheckBox23.Checked := IniF.ReadBool('GridSettings', 'ColVisible23', True);
  CheckBox24.Checked := IniF.ReadBool('GridSettings', 'ColVisible24', True);
  CheckBox25.Checked := IniF.ReadBool('GridSettings', 'ColVisible25', True);
  CheckBox26.Checked := IniF.ReadBool('GridSettings', 'ColVisible26', True);
  CheckBox27.Checked := IniF.ReadBool('GridSettings', 'ColVisible27', True);
  CheckBox28.Checked := IniF.ReadBool('GridSettings', 'ColVisible28', True);
  CheckBox29.Checked := IniF.ReadBool('GridSettings', 'ColVisible29', True);
  ColorBox1.Selected := MainForm.DBGrid1.Font.Color;
  ColorBox2.Selected := MainForm.DBGrid1.Color;

  case IniF.ReadInteger('GridSettings', 'TextSize', 8) of
    8: ComboBox1.ItemIndex := 0;
    10: ComboBox1.ItemIndex := 1;
    12: ComboBox1.ItemIndex := 2;
    14: ComboBox1.ItemIndex := 3;
  end;
end;

end.
