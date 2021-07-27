unit MacroEditorForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, CWKeysDM_u;

type

  { TMacroEditorForm }

  TMacroEditorForm = class(TForm)
    BtApply: TButton;
    BtClose: TButton;
    EditMacroButtonLabel: TEdit;
    LBMacroButtonLabel: TLabel;
    LBMacroText: TLabel;
    LVMacro: TListView;
    MemoMacroText: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Splitter1: TSplitter;
    procedure BtApplyClick(Sender: TObject);
    procedure BtCloseClick(Sender: TObject);
    procedure LVMacroSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    ButtonNumber: integer;

  public
    procedure ShowWithButton(ButtonName: string; Number: integer);

  end;

var
  MacroEditorForm: TMacroEditorForm;

implementation
uses
  CWKeysForm_u;

{$R *.lfm}

procedure TMacroEditorForm.BtApplyClick(Sender: TObject);
var
  Rec: TMacros;
begin
  Rec.Name := EditMacroButtonLabel.Text;
  Rec.Button := 'F' + IntToStr(ButtonNumber);
  Rec.Macro := MemoMacroText.Text;
  if CWKeysDM.ReadRec(ButtonNumber - 1).Button <> '' then
    CWKeysDM.ModifyRec(ButtonNumber - 1, Rec)
  else
    CWKeysDM.AddRec(Rec);
end;

procedure TMacroEditorForm.BtCloseClick(Sender: TObject);
begin
  CWKeysForm.LoadButtonLabel;
  Close;
end;

procedure TMacroEditorForm.LVMacroSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
  MemoMacroText.Text:=MemoMacroText.Text + ' ' + LVMacro.Selected.Caption;
end;

procedure TMacroEditorForm.ShowWithButton(ButtonName: string; Number: integer);
var
  MacroRec: TMacros;
begin
  EditMacroButtonLabel.Text := ButtonName;
  ButtonNumber := Number;
  MacroRec := CWKeysDM.ReadRec(Number - 1);
  MemoMacroText.Text := MacroRec.Macro;
  if MacroRec.Name <> '' then
    EditMacroButtonLabel.Text := MacroRec.Name
  else
    EditMacroButtonLabel.Text := 'F' + IntToStr(Number);
  MacroEditorForm.Show;
end;

end.
