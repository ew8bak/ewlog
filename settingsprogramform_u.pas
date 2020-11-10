unit SettingsProgramForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, Buttons, Menus, ResourceStr;

type

  { TSettingsProgramForm }

  TSettingsProgramForm = class(TForm)
    BtCancel: TButton;
    BtAddProgram: TButton;
    BtSave: TButton;
    BtDelete: TButton;
    CBUseDIGI: TCheckBox;
    EditName: TEdit;
    FNEdit: TFileNameEdit;
    LBNote: TLabel;
    LBPath: TLabel;
    LBName: TLabel;
    LBProgram: TListBox;
    MNote: TMemo;
    PopupMenu1: TPopupMenu;
    procedure BtAddProgramClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtDeleteClick(Sender: TObject);
    procedure BtSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LBProgramClick(Sender: TObject);
  private
    SLProgram: TStringList;
    function GetCountProgram: integer;
    procedure LoadProgramList;
    procedure EnDisControl;
    { private declarations }
  public
    { public declarations }
  end;

var
  SettingsProgramForm: TSettingsProgramForm;

implementation

uses
  InitDB_dm, MainFuncDM, serverDM_u, WSJT_UDP_Form_U;

{$R *.lfm}

{ TSettingsProgramForm }

procedure TSettingsProgramForm.BtCancelClick(Sender: TObject);
begin
  SettingsProgramForm.Close;
end;

procedure TSettingsProgramForm.BtDeleteClick(Sender: TObject);
var
  i: integer;
begin
  if LBProgram.SelCount > 0 then
  begin
    INIFile.DeleteKey('ExternalProgram', 'Program' + IntToStr(LBProgram.ItemIndex - 2));
    SLProgram.Delete(LBProgram.ItemIndex - 2);
    for i := 0 to SLProgram.Count - 1 do
      INIFile.WriteString('ExternalProgram', 'Program' + IntToStr(i),
        SLProgram.Strings[i]);
    INIFile.DeleteKey('ExternalProgram', 'Program' + IntToStr(SLProgram.Count));
    LoadProgramList;
  end;
end;

procedure TSettingsProgramForm.BtSaveClick(Sender: TObject);
begin
  if Length(EditName.Text) < 1 then
  begin
    ShowMessage(rTheNameFieldCannotBeEmpty);
    Exit;
  end;
  if LBProgram.ItemIndex > 1 then
  begin
    if LBProgram.SelCount > 0 then
    begin
      INIFile.WriteString('ExternalProgram', 'Program' +
        IntToStr(LBProgram.ItemIndex - 2), EditName.Text + ',' + FNEdit.Text);
      LoadProgramList;
      LBProgram.ItemIndex := LBProgram.Items.IndexOf(EditName.Text);
    end;
  end
  else
  begin
    if LBProgram.Items[LBProgram.ItemIndex] = 'WSJT-X' then
    begin
      INIFile.WriteString('WSJT', 'WSJTPATH', FNEdit.Text);
      INIFile.WriteBool('WSJT', 'USEWSJT', CBUseDIGI.Checked);
      IniSet.WSJT_PATH := FNEdit.Text;
      IniSet.WSJT_USE := CBUseDIGI.Checked;
      WSJT_UDP_Form.IdWsjtUDP.Active := IniSet.WSJT_USE;
      Exit;
    end;

    if LBProgram.Items[LBProgram.ItemIndex] = 'Fldigi' then
    begin
      INIFile.WriteString('FLDIGI', 'FldigiPATH', FNEdit.Text);
      INIFile.WriteBool('FLDIGI', 'USEFLDIGI', CBUseDIGI.Checked);
      IniSet.Fl_PATH := FNEdit.Text;
      IniSet.FLDIGI_USE := CBUseDIGI.Checked;
      ServerDM.IdFldigiTCP.Active := IniSet.FLDIGI_USE;
      Exit;
    end;
  end;
end;

procedure TSettingsProgramForm.LoadProgramList;
var
  i: integer;
begin
  try
    SLProgram.Clear;
    LBProgram.Items.Clear;
    LBProgram.Items.Add('WSJT-X');
    LBProgram.Items.Add('Fldigi');
    SLProgram.NameValueSeparator := ',';
    if GetCountProgram > 0 then
    begin
      for i := 0 to GetCountProgram - 1 do
        SLProgram.Add(INIFile.ReadString('ExternalProgram', 'Program' +
          IntToStr(i), ''));
      for i := 0 to SLProgram.Count - 1 do
        LBProgram.Items.Add(SLProgram.Names[i]);
    end;
  finally
    EnDisControl;
  end;
end;

function TSettingsProgramForm.GetCountProgram: integer;
var
  SLSection: TStringList;
  CountProgram: integer;
begin
  try
    Result := 0;
    SLSection := TStringList.Create;
    INIFile.ReadSection('ExternalProgram', SLSection);
    CountProgram := SLSection.Count;
  finally
    Result := CountProgram;
    FreeAndNil(SLSection);
  end;
end;

procedure TSettingsProgramForm.FormCreate(Sender: TObject);
begin
  SLProgram := TStringList.Create;
  LoadProgramList;
end;

procedure TSettingsProgramForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(SLProgram);
end;

procedure TSettingsProgramForm.FormShow(Sender: TObject);
begin
  CBUseDIGI.Visible := False;
  LBNote.Visible := False;
  MNote.Visible := False;
  MNote.Text := rNotefldigi;
  EnDisControl;
end;

procedure TSettingsProgramForm.EnDisControl;
begin
  if LBProgram.SelCount = 0 then
  begin
    EditName.Enabled := False;
    FNEdit.Enabled := False;
    BtSave.Enabled := False;
    BtDelete.Enabled := False;
  end
  else
  begin
    EditName.Enabled := True;
    FNEdit.Enabled := True;
    BtSave.Enabled := True;
    BtDelete.Enabled := True;
  end;
end;

procedure TSettingsProgramForm.LBProgramClick(Sender: TObject);
begin
  EnDisControl;
  if LBProgram.SelCount > 0 then
  begin
    if LBProgram.Items[LBProgram.ItemIndex] = 'WSJT-X' then
    begin
      EditName.Enabled := False;
      EditName.Text := 'WSJT-X';
      FNEdit.Text := IniSet.WSJT_PATH;
      CBUseDIGI.Checked := IniSet.WSJT_USE;
      CBUseDIGI.Caption := rUseWSJT;
      CBUseDIGI.Visible := True;
      LBNote.Visible := False;
      MNote.Visible := False;
      Exit;
    end;

    if LBProgram.Items[LBProgram.ItemIndex] = 'Fldigi' then
    begin
      EditName.Enabled := False;
      EditName.Text := 'Fldigi';
      FNEdit.Text := IniSet.Fl_PATH;
      CBUseDIGI.Checked := IniSet.FLDIGI_USE;
      CBUseDIGI.Caption := rUseFldigi;
      CBUseDIGI.Visible := True;
      LBNote.Visible := True;
      MNote.Visible := True;
      Exit;
    end;

    if LBProgram.ItemIndex > 1 then
    begin
      EditName.Text := LBProgram.Items[LBProgram.ItemIndex];
      FNEdit.Text := SLProgram.ValueFromIndex[LBProgram.ItemIndex - 2];
      CBUseDIGI.Visible := False;
      LBNote.Visible := False;
      MNote.Visible := False;
    end;
  end;
end;

procedure TSettingsProgramForm.BtAddProgramClick(Sender: TObject);
begin
  LBProgram.Items.Add(rNewProgram + ' ' + IntToStr(LBProgram.Items.Count + 1));
  LBProgram.ItemIndex := LBProgram.Count - 1;
  SLProgram.Add(LBProgram.Items[LBProgram.ItemIndex] + ',');
  LBProgramClick(Self);
  INIFile.WriteString('ExternalProgram', 'Program' + IntToStr(LBProgram.Count - 3),
    LBProgram.Items[LBProgram.ItemIndex] + ',');
end;

end.
