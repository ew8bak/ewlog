unit SettingsProgramForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, Buttons, ResourceStr;

type

  { TSettingsProgramForm }

  TSettingsProgramForm = class(TForm)
    BtCancel: TButton;
    BtAddProgram: TButton;
    BtSave: TButton;
    BtDelete: TButton;
    EditName: TEdit;
    FNEdit: TFileNameEdit;
    LBPath: TLabel;
    LBName: TLabel;
    LBProgram: TListBox;
    procedure BtAddProgramClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtDeleteClick(Sender: TObject);
    procedure BtSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure LBProgramClick(Sender: TObject);
  private
    SLProgram: TStringList;
    function GetCountProgram: integer;
    procedure LoadProgramList;
    { private declarations }
  public
    { public declarations }
  end;

var
  SettingsProgramForm: TSettingsProgramForm;

implementation

uses
  InitDB_dm, MainFuncDM;

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

  if LBProgram.SelCount > 0 then
  begin
    INIFile.WriteString('ExternalProgram', 'Program' +
      IntToStr(LBProgram.ItemIndex - 2), EditName.Text + ',' + FNEdit.Text);
    LoadProgramList;
    LBProgram.ItemIndex := LBProgram.Items.IndexOf(EditName.Text);
  end;
end;

procedure TSettingsProgramForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  FreeAndNil(SLProgram);
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

procedure TSettingsProgramForm.LBProgramClick(Sender: TObject);
begin
  if LBProgram.SelCount > 0 then
  begin
    if LBProgram.Items[LBProgram.ItemIndex] = 'WSJT-X' then
    begin
      EditName.Text := 'WSJT-X';
      FNEdit.Text := IniSet.WSJT_PATH;
      Exit;
    end;

    if LBProgram.Items[LBProgram.ItemIndex] = 'Fldigi' then
    begin
      EditName.Text := 'Fldigi';
      FNEdit.Text := IniSet.Fl_PATH;
      Exit;
    end;
    if LBProgram.ItemIndex > 1 then
    begin
      EditName.Text := LBProgram.Items[LBProgram.ItemIndex];
      FNEdit.Text := SLProgram.ValueFromIndex[LBProgram.ItemIndex - 2];
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
