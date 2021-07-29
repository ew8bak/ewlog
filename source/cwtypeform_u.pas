unit CWTypeForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin;

type

  { TCWTypeForm }

  TCWTypeForm = class(TForm)
    BtClear: TButton;
    BtClose: TButton;
    LBSpeed: TLabel;
    MemoCWText: TMemo;
    PanelBottom: TPanel;
    PanelSetting: TPanel;
    PanelCWKey: TPanel;
    PanelTop: TPanel;
    SESpeed: TSpinEdit;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SESpeedChange(Sender: TObject);
  private

  public

  end;

var
  CWTypeForm: TCWTypeForm;

implementation

uses
  InitDB_dm, MainFuncDM, CWKeysForm_u, miniform_u, CWDaemonDM_u;

{$R *.lfm}

{ TCWTypeForm }

procedure TCWTypeForm.FormShow(Sender: TObject);
begin
  SESpeed.Value := IniSet.CWDaemonWPM;
  CWKeysForm.BorderStyle := bsNone;
  CWKeysForm.Parent := CWTypeForm.PanelCWKey;
  CWKeysForm.Align := alClient;
  CWKeysForm.Show;
end;

procedure TCWTypeForm.SESpeedChange(Sender: TObject);
begin
  IniSet.CWDaemonWPM := SESpeed.Value;
  CWDaemonDM.SendCWDaemonWPM(IniSet.CWDaemonWPM);
end;

procedure TCWTypeForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CWKeysForm.BorderStyle := bsSingle;
  CWKeysForm.Parent := nil;
  CWKeysForm.Align := alNone;
  CWKeysForm.Close;
  MiniForm.MiCWKeys.Enabled := True;
end;

end.
