(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit progressForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExportADIThread, ResourceStr, LazUTF8;

type

  { TProgressBackupForm }

  TProgressBackupForm = class(TForm)
    Label1: TLabel;
    pbExport: TProgressBar;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public
    SenderForm: string;
    procedure FromExportThread(Info: TInfoExport);
  end;

var
  ProgressBackupForm: TProgressBackupForm;

implementation

uses MainForm_U, miniform_u, InitDB_dm, MainFuncDM, dmFunc_U;

{$R *.lfm}

{ TProgressBackupForm }

procedure TProgressBackupForm.FromExportThread(Info: TInfoExport);
begin
  PbExport.Max := Info.AllRec;
  PbExport.Position := Info.RecCount;
  Label1.Caption := rNumberOfQSO + ' ' + IntToStr(Info.RecCount) +
    rOf + IntToStr(Info.AllRec);
  if Info.Result then
  begin
    ExportADIFThread.Terminate;
    ExportADIFThread := nil;
    Close;
  end;
end;

procedure TProgressBackupForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseApp := True;
  if SenderForm = 'MainForm' then
    MainForm.FormClose(ProgressBackupForm, CloseAction);
  if SenderForm = 'MiniForm' then
    MiniForm.Close;
end;

procedure TProgressBackupForm.FormShow(Sender: TObject);
var
  PADIExport: TPADIExport;
begin
  PADIExport.Path := SysToUTF8(IniSet.PathBackupFiles + DirectorySeparator +
    'auto_backup_' + dmFunc.ExtractCallsign(DBRecord.CurrentCall) + '_' +
    FormatDateTime('yyyy-mm-dd-hhnnss', now) + '.adi');
  PADIExport.ExportAll := True;
  PADIExport.FromForm := 'BackupAdifForm';

  ExportADIFThread := TExportADIFThread.Create;
  if Assigned(ExportADIFThread.FatalException) then
    raise ExportADIFThread.FatalException;
  ExportADIFThread.PADIExport := PADIExport;
  ExportADIFThread.Start;
end;

end.
