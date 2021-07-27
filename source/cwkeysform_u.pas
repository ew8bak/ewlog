unit CWKeysForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, CWKeysDM_u;

type

  { TCWKeysForm }

  TCWKeysForm = class(TForm)
    BtF1: TButton;
    BtF10: TButton;
    BtF2: TButton;
    BtF3: TButton;
    BtF4: TButton;
    BtF5: TButton;
    BtF6: TButton;
    BtF7: TButton;
    BtF8: TButton;
    BtF9: TButton;
    procedure BtF10Click(Sender: TObject);
    procedure BtF10MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BtF1Click(Sender: TObject);
    procedure BtF1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BtF2Click(Sender: TObject);
    procedure BtF2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BtF3Click(Sender: TObject);
    procedure BtF3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BtF4Click(Sender: TObject);
    procedure BtF4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BtF5Click(Sender: TObject);
    procedure BtF5MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BtF6Click(Sender: TObject);
    procedure BtF6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BtF7Click(Sender: TObject);
    procedure BtF7MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BtF8Click(Sender: TObject);
    procedure BtF8MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BtF9Click(Sender: TObject);
    procedure BtF9MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    procedure SendMacros(number: integer);

  public
    procedure LoadButtonLabel;

  end;

var
  CWKeysForm: TCWKeysForm;

implementation

uses InitDB_dm, CWDaemonDM_u, MacroEditorForm_u;

{$R *.lfm}

{ TCWKeysForm }

procedure TCWKeysForm.LoadButtonLabel;
var
  i: integer;
  comp: TComponent;
  Macros: array [0..9] of TMacros;
begin
  if not CWKeysDM.OpenMacroFile(FilePATH + 'macros.dat') then
    CWKeysDM.CreateMacroFile(FilePATH + 'macros.dat');
  for i := 0 to 9 do
  begin
    Macros[i] := CWKeysDM.ReadNextRec;
  end;

  for i := 0 to 9 do
  begin
    comp := FindComponent('BtF' + IntToStr(i + 1));
    if comp is TButton then
      if Macros[i].Name <> TButton(comp).Caption then
        TButton(comp).Caption := 'F' + IntToStr(i + 1) + ' ' + Macros[i].Name;
  end;
end;

procedure TCWKeysForm.SendMacros(number: integer);
var
  Macros: TMacros;
begin
  Macros := CWKeysDM.ReadRec(number - 1);
  CWDaemonDM.SendTextCWDaemon(CWKeysDM.ReplaceMacro(Macros.Macro));
end;

procedure TCWKeysForm.BtF1Click(Sender: TObject);
begin
  SendMacros(1);
end;

procedure TCWKeysForm.BtF10Click(Sender: TObject);
begin
  SendMacros(10);
end;

procedure TCWKeysForm.BtF10MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF10.Caption, 10);
end;

procedure TCWKeysForm.BtF1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF1.Caption, 1);
end;

procedure TCWKeysForm.BtF2Click(Sender: TObject);
begin
  SendMacros(2);
end;

procedure TCWKeysForm.BtF2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF2.Caption, 2);
end;

procedure TCWKeysForm.BtF3Click(Sender: TObject);
begin
  SendMacros(3);
end;

procedure TCWKeysForm.BtF3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF3.Caption, 3);
end;

procedure TCWKeysForm.BtF4Click(Sender: TObject);
begin
  SendMacros(4);
end;

procedure TCWKeysForm.BtF4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF4.Caption, 4);
end;

procedure TCWKeysForm.BtF5Click(Sender: TObject);
begin
  SendMacros(5);
end;

procedure TCWKeysForm.BtF5MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF5.Caption, 5);
end;

procedure TCWKeysForm.BtF6Click(Sender: TObject);
begin
  SendMacros(6);
end;

procedure TCWKeysForm.BtF6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF6.Caption, 6);
end;

procedure TCWKeysForm.BtF7Click(Sender: TObject);
begin
  SendMacros(7);
end;

procedure TCWKeysForm.BtF7MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF7.Caption, 7);
end;

procedure TCWKeysForm.BtF8Click(Sender: TObject);
begin
  SendMacros(8);
end;

procedure TCWKeysForm.BtF8MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF8.Caption, 8);
end;

procedure TCWKeysForm.BtF9Click(Sender: TObject);
begin
  SendMacros(9);
end;

procedure TCWKeysForm.BtF9MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    MacroEditorForm.ShowWithButton(BtF9.Caption, 9);
end;

procedure TCWKeysForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CWKeysDM.CloseMacroFile;
end;

procedure TCWKeysForm.FormShow(Sender: TObject);
begin
  LoadButtonLabel;
end;

end.
