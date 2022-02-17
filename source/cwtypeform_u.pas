unit CWTypeForm_u;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Controls, Dialogs, ExtCtrls, StdCtrls,
  Spin, Classes;

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
    procedure BtClearClick(Sender: TObject);
    procedure BtCloseClick(Sender: TObject);
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
  MainFuncDM, CWKeysForm_u, miniform_u, CWDaemonDM_u;

{$R *.lfm}

{ TCWTypeForm }

procedure TCWTypeForm.FormShow(Sender: TObject);
begin
  SESpeed.Value := IniSet.CWWPM;
  CWKeysForm.BorderStyle := bsNone;
  CWKeysForm.Parent := CWTypeForm.PanelCWKey;
  CWKeysForm.Align := alClient;
  CWKeysForm.Show;
end;

procedure TCWTypeForm.SESpeedChange(Sender: TObject);
begin
  IniSet.CWWPM := SESpeed.Value;
  CWDaemonDM.SendCWDaemonWPM(IniSet.CWWPM);
end;

procedure TCWTypeForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CWKeysForm.BorderStyle := bsSingle;
  CWKeysForm.Parent := nil;
  CWKeysForm.Align := alNone;
  CWKeysForm.Close;
  MiniForm.MiCWKeys.Enabled := True;
end;

procedure TCWTypeForm.BtCloseClick(Sender: TObject);
begin
   CWTypeForm.Close;
end;

procedure TCWTypeForm.BtClearClick(Sender: TObject);
begin
  MemoCWText.Clear;
end;

end.
