(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit ImportADIFForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, EditBtn, LCLType, LConvEncoding, LazUTF8, LCLIntf,
  dateutils, resourcestr, LCLProc, ComCtrls, prefix_record, ImportADIThread;

type

  { TImportADIFForm }

  TImportADIFForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    FileNameEdit1: TFileNameEdit;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblErrorLog: TLabel;
    lblErrors: TLabel;
    lblCount: TLabel;
    lblComplete: TLabel;
    Memo1: TMemo;
    PbImport: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FileNameEdit1ButtonClick(Sender: TObject);
    procedure FileNameEdit1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblErrorLogClick(Sender: TObject);
  private

    { private declarations }
  public
    procedure FromImportThread(Info: TInfo);
    { public declarations }
  end;

var
  ImportADIFForm: TImportADIFForm;

implementation

uses dmFunc_U, MainForm_U, const_u, InitDB_dm, MainFuncDM;

{$R *.lfm}

{ TImportADIFForm }

procedure TImportADIFForm.Button2Click(Sender: TObject);
begin
  if ImportADIFThread <> nil then
  begin
    ImportADIFThread.Terminate;
    ImportADIFThread := nil;
  end
  else
    ImportADIFForm.Close;
end;

procedure TImportADIFForm.FileNameEdit1ButtonClick(Sender: TObject);
begin
  FileNameEdit1.InitialDir := INIFile.ReadString('SetLog', 'ImportPath', '');
end;

procedure TImportADIFForm.FileNameEdit1Change(Sender: TObject);
begin
  if Length(ExtractFilePath(FileNameEdit1.FileName)) > 0 then
    INIFile.WriteString('SetLog', 'ImportPath', ExtractFilePath(FileNameEdit1.FileName));
end;

procedure TImportADIFForm.FormShow(Sender: TObject);
begin
  Button1.Enabled := True;
  Button1.Caption := rImport;
  FileNameEdit1.Text := '';
  Memo1.Clear;
  Label2.Caption := rNumberDup + ' ';
  lblCount.Caption := rImportRecord + ' ';
  lblErrors.Caption := rImportErrors + ' ';
  lblErrorLog.Caption := rFileError;
  lblErrorLog.Color := clNone;
  lblErrorLog.Cursor := crDefault;
  lblComplete.Caption := rWait;
  PbImport.Position := 0;
end;

procedure TImportADIFForm.lblErrorLogClick(Sender: TObject);
begin
  OpenDocument(FilePATH + ERR_FILE);
end;

procedure TImportADIFForm.FromImportThread(Info: TInfo);
begin
  lblComplete.Caption := rImport;
  PbImport.Max := Info.AllRec;
  PbImport.Position := Info.RecCount;
  lblCount.Caption := RImported + ' ' + IntToStr(Info.RecCount) +
    rOf + (IntToStr(Info.AllRec));
  Label2.Caption := rNumberDup + ':' + IntToStr(info.DupeCount);
  lblErrors.Caption := rImportErrors + ':' + IntToStr(Info.ErrorCount);
  if Info.Result then
  begin
    InitDB.SelectLogbookTable(LBRecord.LogTable);
    lblComplete.Caption := rDone;
    Button1.Enabled := True;
    ShowMessage(rImportCompl);
    ImportADIFThread.Terminate;
    ImportADIFThread := nil;
  end;
  if info.ErrorCount > 0 then
  begin
    lblErrorLog.Caption := rFileError + ' ' + ERR_FILE;
    lblErrorLog.Color := clRed;
    lblErrorLog.Cursor := crAppStart;
  end;
end;

procedure TImportADIFForm.Button1Click(Sender: TObject);
var
  PADIImport: TPADIImport;
begin
  if FileNameEdit1.Text = '' then
  begin
    ShowMessage(rNothingImport);
  end
  else
  begin
    Button1.Enabled := False;
    PADIImport.Path := SysToUTF8(FileNameEdit1.Text);
    PADIImport.Mobile := False;
    PADIImport.SearchPrefix := CheckBox1.Checked;
    PADIImport.Comment := Memo1.Text;
    PADIImport.TimeOnOff := RadioButton1.Checked;
    PADIImport.RemoveDup := CheckBox2.Checked;
    DeleteFile(FilePATH + ERR_FILE);
    ImportADIFThread := TImportADIFThread.Create;
    if Assigned(ImportADIFThread.FatalException) then
      raise ImportADIFThread.FatalException;
    ImportADIFThread.PADIImport := PADIImport;
    ImportADIFThread.Start;
  end;
end;


end.
