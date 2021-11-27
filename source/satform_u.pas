unit satForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  Buttons;

type

  { TSATForm }

  TSATForm = class(TForm)
    CBProp: TComboBox;
    CBSat: TComboBox;
    CBSatMode: TComboBox;
    CbTXFrequency: TComboBox;
    CBqslMsg: TComboBox;
    GbVHF: TGroupBox;
    GbSat: TGroupBox;
    Label1: TLabel;
    LbSatDescription1: TLabel;
    LbSatDescription: TLabel;
    LbPropDescription: TLabel;
    LbDescription: TLabel;
    LbTXFrequency: TLabel;
    LBSATMode: TLabel;
    LBSatelite: TLabel;
    LBPropagation: TLabel;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    procedure CBPropChange(Sender: TObject);
    procedure CBSatChange(Sender: TObject);
    procedure CBSatModeChange(Sender: TObject);
    procedure CbTXFrequencyChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
  private
    SLQslMsg: TStringList;
    procedure LoadQslMsg;
    procedure SaveQslMsg;

  public

  end;

var
  SATForm: TSATForm;
  SATFormActive: boolean;

implementation

uses MainFuncDM, SatEditorForm_u, InitDB_dm;

{$R *.lfm}

{ TSATForm }

procedure TSATForm.LoadQslMsg;
var
  i: integer;
  LastMSG: string;
begin
  CBqslMsg.Items.Clear;
  SLQslMsg.Clear;
  for i := 0 to 9 do
    if INIFile.ReadString('SAT', 'QSLMSG' + IntToStr(i), '') <> '' then
      SLQslMsg.Add(INIFile.ReadString('SAT', 'QSLMSG' + IntToStr(i), ''));
  LastMSG := INIFile.ReadString('SAT', 'QSLMSGLast', 'TNX for QSO! 73!');
  SLQslMsg.Insert(0, LastMSG);
  for i := 0 to SLQslMsg.Count - 1 do
    CBqslMsg.Items.Add(SLQslMsg.Strings[i]);
  CBqslMsg.ItemIndex := CBqslMsg.Items.IndexOf(LastMSG);
end;

procedure TSATForm.SaveQslMsg;
var
  i: integer;
begin
  INIFile.WriteString('SAT', 'QSLMSGLast', CBqslMsg.Text);
  if CBqslMsg.Items.IndexOf(CBqslMsg.Text) = -1 then
  begin
    SLQslMsg.Insert(0, CBqslMsg.Text);
    if SLQslMsg.Count > 10 then
      SLQslMsg.Delete(SLQslMsg.Count - 1);
    CBqslMsg.Items.Clear;
    for i := 0 to SLQslMsg.Count - 1 do
    begin
      INIFile.WriteString('SAT', 'QSLMSG' + IntToStr(i), SLQslMsg.Strings[i]);
      CBqslMsg.Items.Add(SLQslMsg.Strings[i]);
    end;
  end;
end;

procedure TSATForm.FormShow(Sender: TObject);
begin
  MainFunc.LoadWindowPosition(SATForm);
  SATFormActive := True;
  CBProp.Items.Clear;
  CBProp.Items.AddStrings(MainFunc.LoadPropItems);
  CbTXFrequency.Items.Clear;
  CbTXFrequency.Items.AddStrings(MainFunc.LoadBands('ssb'));
  CBSat.Items.Clear;
  CBSat.Items.AddStrings(MainFunc.LoadSATItems);
  LoadQslMsg;
  CBProp.Text := IniSet.VHFProp;
  CbTXFrequency.Text := IniSet.TXFreq;
  CBSat.Text := IniSet.SATName;
  CBSatMode.Text := IniSet.SATMode;
  if Length(CBSat.Text) > 1 then
    CBSatChange(self);
  if Length(CBProp.Text) > 1 then
    CBPropChange(self);
end;

procedure TSATForm.SpeedButton11Click(Sender: TObject);
begin
  SATEditorForm.Show;
end;

procedure TSATForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveQslMsg;
  SATFormActive := False;
end;

procedure TSATForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  MainFunc.SaveWindowPosition(SATForm);
  INIFile.WriteString('VHF', 'VHFProp', IniSet.VHFProp);
  INIFile.WriteString('VHF', 'SATName', IniSet.SATName);
  INIFile.WriteString('VHF', 'SATMode', IniSet.SATMode);
  INIFile.WriteString('VHF', 'TXFreq', IniSet.TXFreq);
end;

procedure TSATForm.CBPropChange(Sender: TObject);
begin
  LbPropDescription.Caption := MainFunc.GetPropDescription(CBProp.Items.IndexOf(CBProp.Text) + 1);
  LbPropDescription.Visible := True;
  IniSet.VHFProp := CBProp.Text;
end;

procedure TSATForm.CBSatChange(Sender: TObject);
begin
  LbSatDescription1.Caption := MainFunc.GetSatDescription(CBSat.Text);
  LbSatDescription1.Visible := True;
  IniSet.SATName := CBSat.Text;
end;

procedure TSATForm.CBSatModeChange(Sender: TObject);
begin
  IniSet.SATMode := CBSatMode.Text;
end;

procedure TSATForm.CbTXFrequencyChange(Sender: TObject);
begin
  IniSet.TXFreq := CbTXFrequency.Text;
end;

procedure TSATForm.FormCreate(Sender: TObject);
begin
  LbPropDescription.Visible := False;
  LbSatDescription1.Visible := False;
  SLQslMsg := TStringList.Create;
end;

procedure TSATForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(SLQslMsg);
end;

end.
