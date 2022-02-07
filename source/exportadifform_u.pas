(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit ExportAdifForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, FileUtil, Forms, Controls, Dialogs,
  StdCtrls, EditBtn, ExtCtrls, ComCtrls, LazUTF8,
  ExportADIThread, ExportSOTAThread, ResourceStr;

type

  { TexportAdifForm }

  TexportAdifForm = class(TForm)
    BTExport: TButton;
    BTCancel: TButton;
    CBADIExport: TCheckBox;
    CBExportOnWin: TCheckBox;
    CBConvertLatin: TCheckBox;
    CBSotaExport: TCheckBox;
    CBRemoveSlash: TCheckBox;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    Image1: TImage;
    LBNumberQSO: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PbExport: TProgressBar;
    RadioButton1: TRadioButton;
    rbFileExportAll: TRadioButton;
    SDExport: TSaveDialog;
    procedure BTExportClick(Sender: TObject);
    procedure BTCancelClick(Sender: TObject);
    procedure CBSotaExportChange(Sender: TObject);
    procedure CBADIExportChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure rbFileExportAllClick(Sender: TObject);
    procedure SDExportClose(Sender: TObject);
  private
    FileName: string;
    procedure StartExportADI;
    procedure StartExportSOTA;
    function ShowSaveDialog(ADI: boolean): boolean;
    { private declarations }
  public
    procedure FromExportThread(Info: TInfoExport);
    procedure ExportADIArray;
    { public declarations }
  end;

var
  exportAdifForm: TexportAdifForm;

implementation

uses dmFunc_U, InitDB_dm;

{$R *.lfm}

procedure TexportAdifForm.ExportADIArray;
begin
  if exportAdifForm.ShowSaveDialog(True) then
    exportAdifForm.StartExportADI;
end;

function TexportAdifForm.ShowSaveDialog(ADI: boolean): boolean;
begin
  Result := False;

  if ADI then
  begin
    SDExport.DefaultExt := '.adi';
    SDExport.Filter := '*.adi|*.adi';
  end
  else
  begin
    SDExport.DefaultExt := '.csv';
    SDExport.Filter := '*.csv|*.csv';
  end;

  SDExport.InitialDir := INIFile.ReadString('SetLog', 'ExportPath', '');
  SDExport.FileName := dmFunc.ExtractCallsign(DBRecord.CurrCall) +
    '_' + FormatDateTime('yyyy-mm-dd-hhnnss', now);

  if SDExport.Execute then
  begin
    if SDExport.FileName = '' then
    begin
      Application.MessageBox(
        PChar(pPleaseFile), PChar(rWarning),
        mb_ok + mb_IconWarning);
      Exit;
    end;
    FileName := SysToUTF8(SDExport.FileName);
    if CBADIExport.Checked or CBSotaExport.Checked then
    begin
      BTExport.Enabled := False;
      Result := True;
    end
    else
      Application.MessageBox(PChar(rNoMethodExport),
        PChar(rWarning),
        mb_ok + mb_IconWarning);
  end;
end;

procedure TexportAdifForm.FromExportThread(Info: TInfoExport);
begin
  PbExport.Max := Info.AllRec;
  PbExport.Position := Info.RecCount;
  LBNumberQSO.Caption := rNumberOfQSO + ' ' + IntToStr(Info.RecCount) +
    rOf + IntToStr(Info.AllRec);
  if Info.Result then
  begin
    BTExport.Enabled := True;
    ShowMessage(rExportCompl);
    if Info.From = 'ADIF' then
    begin
      ExportADIFThread.Terminate;
      ExportADIFThread := nil;
    end;
    if Info.From = 'SOTA' then
    begin
      ExportSOTAFThread.Terminate;
      ExportSOTAFThread := nil;
    end;
  end;
end;

procedure TexportAdifForm.StartExportSOTA;
var
  PSOTAExport: TPSOTAExport;
begin
  PSOTAExport.MySOTAreference := '';
  if InputQuery('My SOTA summit Reference', rInputMySotaRef, False,
    PSOTAExport.MySOTAreference) then
  begin
    PSOTAExport.Path := SysToUTF8(FileName);
    PSOTAExport.ExportAll := rbFileExportAll.Checked;
    PSOTAExport.DateStart := DateEdit1.Date;
    PSOTAExport.DateEnd := DateEdit2.Date;
    PSOTAExport.Win1251 := CBExportOnWin.Checked;
    PSOTAExport.RusToLat := CBConvertLatin.Checked;
    PSOTAExport.FromForm := 'ExportAdifForm';
    ExportSOTAFThread := TExportSOTAFThread.Create;
    if Assigned(ExportSOTAFThread.FatalException) then
      raise ExportSOTAFThread.FatalException;
    ExportSOTAFThread.PSOTAExport := PSOTAExport;
    ExportSOTAFThread.Start;
  end
  else
    BTExport.Enabled := True;
end;

procedure TexportAdifForm.StartExportADI;
var
  PADIExport: TPADIExport;
begin
  PADIExport.Path := SysToUTF8(FileName);
  PADIExport.ExportAll := rbFileExportAll.Checked;
  PADIExport.DateStart := DateEdit1.Date;
  PADIExport.DateEnd := DateEdit2.Date;
  PADIExport.Win1251 := CBExportOnWin.Checked;
  PADIExport.RusToLat := CBConvertLatin.Checked;
  PADIExport.FromForm := 'ExportAdifForm';
  PADIExport.RemoveSlash:= CBRemoveSlash.Checked;
  ExportADIFThread := TExportADIFThread.Create;
  if Assigned(ExportADIFThread.FatalException) then
    raise ExportADIFThread.FatalException;
  ExportADIFThread.PADIExport := PADIExport;
  ExportADIFThread.Start;
end;

procedure TexportAdifForm.BTExportClick(Sender: TObject);
begin
  if CBADIExport.Checked then
    if ShowSaveDialog(CBADIExport.Checked) then
      StartExportADI;
  if CBSotaExport.Checked then
    if ShowSaveDialog(CBADIExport.Checked) then
      StartExportSOTA;
  if not CBADIExport.Checked and not CBSotaExport.Checked then
    Application.MessageBox(PChar(rNoMethodExport),
      PChar(rWarning),
      mb_ok + mb_IconWarning);
end;

procedure TexportAdifForm.BTCancelClick(Sender: TObject);
begin
  if ExportADIFThread <> nil then
  begin
    ExportADIFThread.Terminate;
    ExportADIFThread := nil;
  end
  else
    exportAdifForm.Close;
end;

procedure TexportAdifForm.CBSotaExportChange(Sender: TObject);
begin
  if CBSotaExport.Checked then
    CBADIExport.Checked := False;
end;

procedure TexportAdifForm.CBADIExportChange(Sender: TObject);
begin
  if CBADIExport.Checked then
    CBSotaExport.Checked := False;
end;

procedure TexportAdifForm.FormShow(Sender: TObject);
begin
  if rbFileExportAll.Checked = True then
  begin
    DateEdit1.Enabled := False;
    DateEdit2.Enabled := False;
  end;
  BTExport.Caption := rExport;
  Label2.Caption := '';
  LBNumberQSO.Caption := rNumberOfQSO0;
  PbExport.Position := 0;
  if DBRecord.CurrCall[Length(DBRecord.CurrCall)] = '/' then
  begin
    CBRemoveSlash.Enabled := true;
  end
  else
  begin
    CBRemoveSlash.Enabled := false;
    CBRemoveSlash.Checked := false;
  end;
end;

procedure TexportAdifForm.RadioButton1Click(Sender: TObject);
begin
  if RadioButton1.Checked = True then
  begin
    DateEdit1.Enabled := True;
    DateEdit2.Enabled := True;
  end;
end;

procedure TexportAdifForm.rbFileExportAllClick(Sender: TObject);
begin
  if rbFileExportAll.Checked = True then
  begin
    DateEdit1.Enabled := False;
    DateEdit2.Enabled := False;
  end;
end;

procedure TexportAdifForm.SDExportClose(Sender: TObject);
begin
  INIFile.WriteString('SetLog', 'ExportPath', ExtractFilePath(SDExport.FileName));
end;

end.
