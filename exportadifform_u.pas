unit ExportAdifForm_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, EditBtn, ExtCtrls, ComCtrls, sqldb, LazUTF8, LConvEncoding,
  ExportADIThread, ResourceStr;

type

  { TexportAdifForm }

  TexportAdifForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PbExport: TProgressBar;
    RadioButton1: TRadioButton;
    rbFileExportAll: TRadioButton;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure rbFileExportAllClick(Sender: TObject);
    procedure SaveDialog1Close(Sender: TObject);
  private
    FileName: string;
    procedure StartExport;
    { private declarations }
  public
    procedure FromExportThread(Info: TInfoExport);
    { public declarations }
  end;

var
  exportAdifForm: TexportAdifForm;

implementation

uses dmFunc_U, InitDB_dm, MainFuncDM;

{$R *.lfm}

procedure TexportAdifForm.FromExportThread(Info: TInfoExport);
begin
  PbExport.Max := Info.AllRec;
  PbExport.Position := Info.RecCount;
  Label1.Caption := rNumberOfQSO + ' ' + IntToStr(Info.RecCount) +
    rOf + IntToStr(Info.AllRec);
  if Info.Result then
  begin
    Button1.Enabled := True;
    ShowMessage(rExportCompl);
    ExportADIFThread.Terminate;
    ExportADIFThread := nil;
  end;
end;

procedure TexportAdifForm.StartExport;
var
  PADIExport: TPADIExport;
begin
  PADIExport.Path := SysToUTF8(FileName);
  PADIExport.ExportAll := rbFileExportAll.Checked;
  PADIExport.DateStart := DateEdit1.Date;
  PADIExport.DateEnd := DateEdit2.Date;
  PADIExport.Win1251 := CheckBox2.Checked;
  PADIExport.RusToLat := CheckBox4.Checked;
  PADIExport.FromForm := 'ExportAdifForm';

  ExportADIFThread := TExportADIFThread.Create;
  if Assigned(ExportADIFThread.FatalException) then
    raise ExportADIFThread.FatalException;
  ExportADIFThread.PADIExport := PADIExport;
  ExportADIFThread.Start;
end;

procedure TexportAdifForm.Button1Click(Sender: TObject);
begin
  SaveDialog1.InitialDir := INIFile.ReadString('SetLog', 'ExportPath', '');
  SaveDialog1.FileName := dmFunc.ExtractCallsign(DBRecord.CurrCall) +
    '_' + FormatDateTime('yyyy-mm-dd-hhnnss', now);

  if SaveDialog1.Execute then
  begin
    if SaveDialog1.FileName = '' then
    begin
      Application.MessageBox(
        PChar(pPleaseFile), PChar(rWarning),
        mb_ok + mb_IconWarning);
      exit;
    end;
    FileName := SysToUTF8(SaveDialog1.FileName);
    if CheckBox1.Checked then
    begin
      Button1.Enabled := False;
      StartExport;
    end
    else
      Application.MessageBox(PChar(rNoMethodExport),
        PChar(rWarning),
        mb_ok + mb_IconWarning);
  end;
end;

procedure TexportAdifForm.Button2Click(Sender: TObject);
begin
  if ExportADIFThread <> nil then
  begin
    ExportADIFThread.Terminate;
    ExportADIFThread := nil;
  end
  else
    exportAdifForm.Close;
end;

procedure TexportAdifForm.FormShow(Sender: TObject);
begin
  if rbFileExportAll.Checked = True then
  begin
    DateEdit1.Enabled := False;
    DateEdit2.Enabled := False;
  end;
  Button1.Caption := rExport;
  Label2.Caption := '';
  Label1.Caption := rNumberOfQSO0;
  PbExport.Position := 0;
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

procedure TexportAdifForm.SaveDialog1Close(Sender: TObject);
begin
  INIFile.WriteString('SetLog', 'ExportPath', ExtractFilePath(SaveDialog1.FileName));
end;

end.
