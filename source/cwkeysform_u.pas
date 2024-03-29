unit CWKeysForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls, CWKeysDM_u;

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
    procedure SavePosition;

  end;

var
  CWKeysForm: TCWKeysForm;

implementation

uses MacroEditorForm_u, MainFuncDM, CWDaemonDM_u;

{$R *.lfm}

{ TCWKeysForm }

procedure TCWKeysForm.SavePosition;
begin
  if CWKeysForm.Showing then
    MainFunc.SaveWindowPosition(CWKeysForm);
end;

procedure TCWKeysForm.LoadButtonLabel;
var
  i: integer;
  comp: TComponent;
begin
  for i := 0 to High(MacrosArray) do
  begin
    comp := FindComponent('BtF' + IntToStr(MacrosArray[i].ButtonID));
    if comp is TButton then
      if TButton(comp).Name = 'BtF' + IntToStr(MacrosArray[i].ButtonID) then
        TButton(comp).Caption :=
          'F' + IntToStr(MacrosArray[i].ButtonID) + ' ' + MacrosArray[i].ButtonName;
  end;
end;

procedure TCWKeysForm.SendMacros(number: integer);
var
  Macros: TMacros;
begin
  Macros := CWKeysDM.SearchMacro(number);
  {$IFDEF LINUX}
  if IniSet.CWManager = 'CWDaemon' then begin
  if CWDaemonDM.IdCWDaemonClient.Active then
    CWDaemonDM.SendTextCWDaemon(CWKeysDM.ReplaceMacro(Macros.Macro));
  end;
  {$ENDIF LINUX}
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
  SavePosition;
end;

procedure TCWKeysForm.FormShow(Sender: TObject);
begin
  MainFunc.LoadWindowPosition(CWKeysForm);
  LoadButtonLabel;
end;

end.
