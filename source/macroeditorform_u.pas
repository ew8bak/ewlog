unit MacroEditorForm_u;

{$mode objfpc}{$H+}

interface

uses
  Forms, Controls, Dialogs, ExtCtrls, StdCtrls,
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
      Selected: boolean);
  private
    ButSearchNumber: integer;
    ButRealNumber: integer;

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
  Rec.ButtonID := ButRealNumber;
  Rec.ButtonName := EditMacroButtonLabel.Text;
  Rec.Macro := MemoMacroText.Text;
  if ButSearchNumber > -1 then
    CWKeysDM.UpdateMacro(Rec)
  else
    CWKeysDM.AddMacro(Rec);
end;

procedure TMacroEditorForm.BtCloseClick(Sender: TObject);
begin
  CWKeysForm.LoadButtonLabel;
  Close;
end;

procedure TMacroEditorForm.LVMacroSelectItem(Sender: TObject;
  Item: TListItem; Selected: boolean);
begin
  if Selected then
    MemoMacroText.Text := MemoMacroText.Text + ' ' + LVMacro.Selected.Caption;
end;

procedure TMacroEditorForm.ShowWithButton(ButtonName: string; Number: integer);
var
  Macro: TMacros;
begin
  Macro := CWKeysDM.SearchMacro(Number);
  ButSearchNumber := Macro.ButtonID;
  ButRealNumber := Number;
  if Macro.ButtonID > -1 then
  begin
    EditMacroButtonLabel.Text := Macro.ButtonName;
    MemoMacroText.Text := Macro.Macro;
  end
  else
  begin
    EditMacroButtonLabel.Text := ButtonName;
    MemoMacroText.Text := '';
  end;
  MacroEditorForm.Show;
end;

end.
