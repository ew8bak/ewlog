(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit MainForm_U;

{$mode objfpc}{$H+}

interface

uses
  Forms, ExtCtrls, Classes, Controls, ResourceStr;

type
  { TMainForm }

  TMainForm = class(TForm)
    LeftPanel: TPanel;
    AllClientPanel: TPanel;
    GridsPanel: TPanel;
    ClusterPanel: TPanel;
    EarthPanel: TPanel;
    MiniPanel: TPanel;
    OtherPanel: TPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    procedure CloseForm;

  public
    procedure SavePosition;
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }
uses MainFuncDM, InitDB_dm, TRXForm_U, miniform_u, viewPhoto_U, dxclusterform_u,
  GridsForm_u, serverDM_u, progressForm_u;

procedure TMainForm.SavePosition;
begin
  if IniSet.MainForm = 'MAIN' then
    if MainForm.WindowState <> wsMaximized then
    begin
      INIFile.WriteInteger('SetLog', 'mainLeft', MainForm.Left);
      INIFile.WriteInteger('SetLog', 'mainTop', MainForm.Top);
      INIFile.WriteInteger('SetLog', 'mainWidth', MainForm.Width);
      INIFile.WriteInteger('SetLog', 'mainHeight', MainForm.Height);
      INIFile.WriteString('SetLog', 'FormState', 'Normal');
    end;
  if MainForm.WindowState = wsMaximized then
    INIFile.WriteString('SetLog', 'FormState', 'Maximized');
  INIFile.WriteString('SetLog', 'MainForm', IniSet.MainForm);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
 { if (IniSet.FormState = 'Maximized') and (IniSet.MainForm = 'MAIN') then
    MainForm.WindowState := wsMaximized
  else
  if (IniSet._l_main <> 0) and (IniSet._t_main <> 0) and
    (IniSet._w_main <> 0) and (IniSet._h_main <> 0) then
    MainForm.SetBounds(IniSet._l_main, IniSet._t_main, IniSet._w_main, IniSet._h_main); }
  MainFunc.LoadWindowPosition(MainForm);
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if IniSet.BackupDBonClose then
    MainFunc.BackupDataDB('MainForm');
  if IniSet.BackupADIonClose then
  begin
    if Sender = ProgressBackupForm then
    begin
      CloseForm;
    end
    else
    begin
      if MainFunc.BackupDataADI('MainForm') then
        CloseAction := caNone;
    end;
  end
  else
    CloseForm;
end;

procedure TMainForm.CloseForm;
var
  CloseAction: TCloseAction;
begin
  MainFunc.SaveWindowPosition(MainForm);
  INIFile.WriteInteger('SetLog', 'PastBand', MiniForm.CBBand.ItemIndex);
  INIFile.WriteString('SetLog', 'PastMode', MiniForm.CBMode.Text);
  INIFile.WriteString('SetLog', 'PastSubMode', MiniForm.CBSubMode.Text);
  INIFile.WriteString('SetLog', 'Language', IniSet.Language);
  INIFile.WriteString('SetLog', 'MainForm', IniSet.MainForm);
  if IniSet.trxShow then
    MainFunc.SaveWindowPosition(TRXForm);
  if IniSet.pShow then
    MainFunc.SaveWindowPosition(viewPhoto);
  if dxClusterForm <> nil then
    dxClusterForm.FormClose(MainForm, CloseAction);
  GridsForm.SavePosition;
  TRXForm.FreeRadio;
  MiniForm.Close;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MiniForm.Caption := rEWLogHAMJournal;
end;

end.
