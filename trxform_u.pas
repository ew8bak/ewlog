unit TRXForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Arrow, uRigControl,
  lNetComponents, Types;

const
  empty_freq = '0.000"."00';
  khz_freq = '0.00000';

type

  { TTRXForm }

  TTRXForm = class(TForm)
    Arrow1: TArrow;
    Arrow10: TArrow;
    Arrow11: TArrow;
    Arrow12: TArrow;
    Arrow13: TArrow;
    Arrow14: TArrow;
    Arrow15: TArrow;
    Arrow16: TArrow;
    Arrow17: TArrow;
    Arrow18: TArrow;
    Arrow2: TArrow;
    Arrow3: TArrow;
    Arrow4: TArrow;
    Arrow5: TArrow;
    Arrow6: TArrow;
    Arrow7: TArrow;
    Arrow8: TArrow;
    Arrow9: TArrow;
    btn10m: TButton;
    btn12m: TButton;
    btn15m: TButton;
    btn160m: TButton;
    btn17m: TButton;
    btn20m: TButton;
    btn2m: TButton;
    btn30m: TButton;
    btn40m: TButton;
    btn6m: TButton;
    btn70cm: TButton;
    btn70cm1: TButton;
    btn70cm2: TButton;
    btn80m: TButton;
    btnAM: TButton;
    btnCW: TButton;
    btnFM: TButton;
    btnRTTY: TButton;
    btnSSB: TButton;
    btnVFOA: TButton;
    btnVFOB: TButton;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblMode: TLabel;
    rbRadio1: TRadioButton;
    rbRadio2: TRadioButton;
    tmrRadio: TTimer;
    procedure Arrow1MouseLeave(Sender: TObject);
    procedure Arrow1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure btn10mClick(Sender: TObject);
    procedure btn12mClick(Sender: TObject);
    procedure btn15mClick(Sender: TObject);
    procedure btn160mClick(Sender: TObject);
    procedure btn17mClick(Sender: TObject);
    procedure btn20mClick(Sender: TObject);
    procedure btn30mClick(Sender: TObject);
    procedure btn40mClick(Sender: TObject);
    procedure btn6mClick(Sender: TObject);
    procedure btn70cm1Click(Sender: TObject);
    procedure btn70cmClick(Sender: TObject);
    procedure btn80mClick(Sender: TObject);
    procedure btnAMClick(Sender: TObject);
    procedure btnCWClick(Sender: TObject);
    procedure btnFMClick(Sender: TObject);
    procedure btnRTTYClick(Sender: TObject);
    procedure btnSSBClick(Sender: TObject);
    procedure btnVFOAClick(Sender: TObject);
    procedure btnVFOBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure Label11MouseLeave(Sender: TObject);
    procedure Label11MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label11MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Label1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label2MouseLeave(Sender: TObject);
    procedure Label2MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label2MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label3MouseLeave(Sender: TObject);
    procedure Label3MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label3MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label4MouseLeave(Sender: TObject);
    procedure Label4MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label4MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label5MouseLeave(Sender: TObject);
    procedure Label5MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label5MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label6MouseLeave(Sender: TObject);
    procedure Label6MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label6MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label7MouseLeave(Sender: TObject);
    procedure Label7MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label7MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label8MouseLeave(Sender: TObject);
    procedure Label8MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure Label8MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: boolean);
    procedure rbRadio1Click(Sender: TObject);
    procedure rbRadio2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure tmrRadioTimer(Sender: TObject);
    procedure SetMode(mode: string; bandwidth: integer);
    function GetFreqHz: double;
    function GetFreqkHz: double;
    function GetFreqMHz: double;
  private

    { private declarations }
  public
    radio: TRigControl;
    AutoMode: boolean;
    bwith: string;
    procedure SynTRX;
    procedure Freq(Hz: integer);
    function InicializeRig: boolean;
    { public declarations }
  end;

type
  TRigThread = class(TThread)
  protected
    procedure Execute; override;
  public
    Rig_RigCtldPath: string;
    Rig_RigCtldArgs: string;
    Rig_RunRigCtld: boolean;
    Rig_RigId: word;
    Rig_RigDevice: string;
    Rig_RigCtldPort: word;
    Rig_RigCtldHost: string;
    Rig_RigPoll: word;
    Rig_RigSendCWR: boolean;
    Rig_ClearRit: boolean;
  end;

var
  TRXForm: TTRXForm;
  thRig: TRigThread;

implementation

uses
  MainForm_U, dmFunc_U, const_u, ConfigForm_U;

{$R *.lfm}

{ TTRXForm }

procedure TTRXForm.Freq(Hz: integer);
var
  fr: array[1..9] of string;
begin
  fr[1] := IntToStr(hz mod 10);
  fr[2] := IntToStr(Trunc((hz mod 100) / 10));
  fr[3] := IntToStr(Trunc((hz mod 1000) / 100));
  fr[4] := IntToStr(Trunc((hz mod 10000) / 1000));
  fr[5] := IntToStr(Trunc((hz mod 100000) / 10000));
  fr[6] := IntToStr(Trunc((hz mod 1000000) / 100000));
  fr[7] := IntToStr(Trunc((hz mod 10000000) / 1000000));
  fr[8] := IntToStr(Trunc((hz mod 100000000) / 10000000));
  fr[9] := IntToStr(Trunc((hz mod 1000000000) / 100000000));
  label1.Caption := fr[9];
  label2.Caption := fr[8];
  label3.Caption := fr[7];
  label4.Caption := fr[6];
  label5.Caption := fr[5];
  label6.Caption := fr[4];
  label7.Caption := fr[3];
  label8.Caption := fr[2];
  label11.Caption := fr[1];
end;

function TTRXForm.GetFreqHz: double;
begin
  if Assigned(radio) then
    Result := radio.GetFreqHz
  else
    Result := 0;
end;

function TTRXForm.GetFreqkHz: double;
begin
  if Assigned(radio) then
    Result := radio.GetFreqKHz
  else
    Result := 0;
end;

function TTRXForm.GetFreqMHz: double;
begin
  if Assigned(radio) then
    Result := radio.GetFreqMHz
  else
    Result := 0;
end;

procedure TTRXForm.SetMode(mode: string; bandwidth: integer);
var
  rmode: TRigMode;
begin
  if Assigned(radio) then
  begin
    rmode.mode := mode;
    rmode.pass := bandwidth;
    radio.SetModePass(rmode);
  end;
end;

procedure TTRXForm.SynTRX;
var
  f: double;
  m: string;
  mode, submode: string;
begin
  m := '';
  mode := '';
  submode := '';
  if Assigned(radio) then
  begin
    f := radio.GetFreqMHz;
    m := radio.GetModeOnly;
    Freq(radio.GetFreqHz);
   {$IFDEF WIN64}
    bwith := radio.GetBandwich(radio.GetRawMode);
  {$ENDIF}
  end
  else
    f := 0;

  if (fldigiactive = False) and (f <> 0) then
  begin
    if ConfigForm.CheckBox2.Checked = True then
      MainForm.ComboBox1.Text := dmFunc.GetBandFromFreq(FormatFloat(view_freq, f))
    else
      MainForm.ComboBox1.Text := FormatFloat(view_freq, f);
  end;

  if Length(m) > 1 then
    dmFunc.GetRIGMode(m, mode, submode);


  if (fldigiactive = False) and (Length(m) > 1) then
  begin
    MainForm.ComboBox2.Text := mode;
    MainForm.ComboBox9.Text := submode;
  end;
  lblMode.Caption := m;
end;

function TTRXForm.InicializeRig: boolean;
var
  n: string = '';
  id: integer = 0;
begin
  if Assigned(radio) then
  begin
    FreeAndNil(radio);
  end;

  Application.ProcessMessages;
  //Sleep(500);

  tmrRadio.Enabled := False;

  if rbRadio1.Checked then
    n := '1'
  else
    n := '2';

  radio := TRigControl.Create;

  if not TryStrToInt(IniF.ReadString('TRX' + n, 'model', ''), id) then
    radio.RigId := 1
  else
    radio.RigId := id;

  radio.RigCtldPath := IniF.ReadString('TRX' + n, 'RigCtldPath', '') +
    ' -T 127.0.0.1 -vvvvv';
  radio.RigCtldArgs := dmFunc.GetRadioRigCtldCommandLine(StrToInt(n));
  //  radio.RunRigCtld  := IniF.ReadBool('TRX'+n,'RunRigCtld',True);
  if IniF.ReadString('TRX' + n, 'model', '') <> IntToStr(2) then
    radio.RigDevice := IniF.ReadString('TRX' + n, 'device', '');
  radio.RigCtldPort := StrToInt(IniF.ReadString('TRX' + n, 'RigCtldPort', '4532'));
  radio.RigCtldHost := IniF.ReadString('TRX' + n, 'host', '127.0.0.1');
  if StrToInt(IniF.ReadString('TRX' + n, 'Poll', '100')) < 3 then
  radio.RigPoll := 3 else
  radio.RigPoll := StrToInt(IniF.ReadString('TRX' + n, 'Poll', '3'));
  radio.RigSendCWR := IniF.ReadBool('TRX' + n, 'CWR', False);
  rbRadio1.Caption := IniF.ReadString('TRX' + n, 'name', '');
  TRXForm.Caption := IniF.ReadString('TRX' + n, 'name', '');

  tmrRadio.Interval := radio.RigPoll;
  tmrRadio.Enabled := True;

  Result := True;
  if not radio.Connected then
  begin
    tmrRadio.Enabled := False;
    FreeAndNil(radio);
  end;
end;

procedure TTRXForm.FormCreate(Sender: TObject);
var
  n: string = '';
begin
  Arrow1.Visible:=False;
  Arrow2.Visible:=False;
  Arrow3.Visible:=False;
  Arrow4.Visible:=False;
  Arrow5.Visible:=False;
  Arrow6.Visible:=False;
  Arrow7.Visible:=False;
  Arrow8.Visible:=False;
  Arrow9.Visible:=False;
  Arrow10.Visible:=False;
  Arrow11.Visible:=False;
  Arrow12.Visible:=False;
  Arrow13.Visible:=False;
  Arrow14.Visible:=False;
  Arrow15.Visible:=False;
  Arrow16.Visible:=False;
  Arrow17.Visible:=False;
  Arrow18.Visible:=False;

  Radio := nil;
  thRig := nil;
  AutoMode := True;
  if rbRadio1.Checked then
    n := '1'
  else
    n := '2';

  if IniF.ReadString('TRX' + n, 'RigCtldPath', '') <> '' then
    InicializeRig;

  if ShowTRXForm = True then
  begin
    TRXForm.Parent := MainForm.Panel13;
    TRXForm.BorderStyle := bsNone;
    TRXForm.Align := alClient;
    TRXForm.Show;
  end;

end;

procedure TTRXForm.Label11MouseLeave(Sender: TObject);
begin
  Arrow17.ArrowColor := clBtnFace;
  Arrow18.ArrowColor := clBtnFace;
end;

procedure TTRXForm.Label11MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow18.ArrowColor := clBlue;
  Arrow17.ArrowColor := clBtnFace;
  Application.ProcessMessages;
  //  radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+
  //  Label4.Caption+Label5.Caption+
  //  Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)-1);
end;

procedure TTRXForm.Label11MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
var
  freqCh: integer;
begin
  Arrow17.ArrowColor := clBlue;
  Arrow18.ArrowColor := clBtnFace;
  Application.ProcessMessages;
  freqCH := StrToInt(Label1.Caption + Label2.Caption + Label3.Caption +
    Label4.Caption + Label5.Caption + Label6.Caption + Label7.Caption +
    Label8.Caption + Label11.Caption) + 1;
  // radio.SetFreqHz(freqCh);
end;

procedure TTRXForm.Label1MouseLeave(Sender: TObject);
begin
  Arrow1.ArrowColor := clBtnFace;
  Arrow9.ArrowColor := clBtnFace;
end;

procedure TTRXForm.Label1MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow9.ArrowColor := clBlue;
  Arrow1.ArrowColor := clBtnFace;
  //  radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  //Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)-100000000);
end;

procedure TTRXForm.Label1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow1.ArrowColor := clBlue;
  Arrow9.ArrowColor := clBtnFace;

  //radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  //Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)+100000000);
end;

procedure TTRXForm.Label2MouseLeave(Sender: TObject);
begin
  Arrow2.ArrowColor := clBtnFace;
  Arrow10.ArrowColor := clBtnFace;
end;

procedure TTRXForm.Label2MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow10.ArrowColor := clBlue;
  Arrow2.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)-10000000);
end;

procedure TTRXForm.Label2MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow2.ArrowColor := clBlue;
  Arrow10.ArrowColor := clBtnFace;
  //  radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)+10000000);
end;

procedure TTRXForm.Label3MouseLeave(Sender: TObject);
begin
  Arrow3.ArrowColor := clBtnFace;
  Arrow11.ArrowColor := clBtnFace;
end;

procedure TTRXForm.Label3MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow11.ArrowColor := clBlue;
  Arrow3.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  //Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)-1000000);
end;

procedure TTRXForm.Label3MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow3.ArrowColor := clBlue;
  Arrow11.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)+1000000);
end;

procedure TTRXForm.Label4MouseLeave(Sender: TObject);
begin
  Arrow4.ArrowColor := clBtnFace;
  Arrow12.ArrowColor := clBtnFace;
end;

procedure TTRXForm.Label4MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow12.ArrowColor := clBlue;
  Arrow4.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)-100000);
end;

procedure TTRXForm.Label4MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow4.ArrowColor := clBlue;
  Arrow12.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)+100000);
end;

procedure TTRXForm.Label5MouseLeave(Sender: TObject);
begin
  Arrow5.ArrowColor := clBtnFace;
  Arrow13.ArrowColor := clBtnFace;
end;

procedure TTRXForm.Label5MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow13.ArrowColor := clBlue;
  Arrow5.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)-10000);
end;

procedure TTRXForm.Label5MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow5.ArrowColor := clBlue;
  Arrow13.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)+10000);
end;

procedure TTRXForm.Label6MouseLeave(Sender: TObject);
begin
  Arrow6.ArrowColor := clBtnFace;
  Arrow14.ArrowColor := clBtnFace;
end;

procedure TTRXForm.Label6MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow14.ArrowColor := clBlue;
  Arrow6.ArrowColor := clBtnFace;
  //    radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  //  Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)-1000);
end;

procedure TTRXForm.Label6MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow6.ArrowColor := clBlue;
  Arrow14.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)+1000);
end;

procedure TTRXForm.Label7MouseLeave(Sender: TObject);
begin
  Arrow7.ArrowColor := clBtnFace;
  Arrow15.ArrowColor := clBtnFace;
end;

procedure TTRXForm.Label7MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow15.ArrowColor := clBlue;
  Arrow7.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)-100);

end;

procedure TTRXForm.Label7MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow7.ArrowColor := clBlue;
  Arrow15.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  // Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)+100);
end;

procedure TTRXForm.Label8MouseLeave(Sender: TObject);
begin
  Arrow8.ArrowColor := clBtnFace;
  Arrow16.ArrowColor := clBtnFace;
end;

procedure TTRXForm.Label8MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow16.ArrowColor := clBlue;
  Arrow8.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  //  Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)-10);
end;

procedure TTRXForm.Label8MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: boolean);
begin
  Arrow8.ArrowColor := clBlue;
  Arrow16.ArrowColor := clBtnFace;
  //   radio.SetFreqHz(StrToInt(Label1.Caption+Label2.Caption+Label3.Caption+Label4.Caption+Label5.Caption+
  //  Label6.Caption+Label7.Caption+Label8.Caption+Label11.Caption)+10);
end;

procedure TTRXForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Assigned(thRig) then
    thRig.Terminate;
end;

procedure TTRXForm.btnSSBClick(Sender: TObject);
var
  tmp: currency;
begin
  if not TryStrToCurr(FormatFloat('0.00000', radio.GetFreqMHz), tmp) then
    SetMode('LSB', 0)
  else
  begin
    if tmp > 10 then
      SetMode('USB', 0)
    else
      SetMode('LSB', 0);
  end;
end;

procedure TTRXForm.btnVFOAClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetCurrVFO(VFOA);
end;

procedure TTRXForm.btnVFOBClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetCurrVFO(VFOB);
end;

procedure TTRXForm.btnFMClick(Sender: TObject);
begin
  if Assigned(radio) then
    SetMode('FM', 0);
end;

procedure TTRXForm.btnRTTYClick(Sender: TObject);
begin
  if Assigned(radio) then
    SetMode('RTTY', 0);
end;

procedure TTRXForm.btnCWClick(Sender: TObject);
begin
  if Assigned(radio) then
    SetMode('CW', 0);
end;

procedure TTRXForm.btnAMClick(Sender: TObject);
begin
  if Assigned(radio) then
    SetMode('AM', 0);
end;

procedure TTRXForm.btn160mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(1800);
end;

procedure TTRXForm.btn15mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(21150);
end;

procedure TTRXForm.btn12mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(24900);
end;

procedure TTRXForm.btn10mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(28500);
end;

procedure TTRXForm.Arrow1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  TArrow(Sender).ArrowColor := clBlue;
end;

procedure TTRXForm.Arrow1MouseLeave(Sender: TObject);
begin
  TArrow(Sender).ArrowColor := clBtnFace;
end;

procedure TTRXForm.btn17mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(18100);
end;

procedure TTRXForm.btn20mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(14150);
end;

procedure TTRXForm.btn30mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(10100);
end;

procedure TTRXForm.btn40mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(7100);
end;

procedure TTRXForm.btn6mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(50100);
end;

procedure TTRXForm.btn70cm1Click(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(430500);
end;

procedure TTRXForm.btn70cmClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(145500);
end;

procedure TTRXForm.btn80mClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetFreqKHz(3600);
end;

procedure TTRXForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if Assigned(radio) then
    FreeAndNil(radio);
end;

procedure TTRXForm.rbRadio1Click(Sender: TObject);
begin
  InicializeRig;
end;

procedure TTRXForm.rbRadio2Click(Sender: TObject);
begin
  InicializeRig;
end;

procedure TTRXForm.Timer1Timer(Sender: TObject);
begin

end;

procedure TTRXForm.tmrRadioTimer(Sender: TObject);
begin
  SynTRX;
end;

procedure TRigThread.Execute;
var
  mRig: TRigControl;

  procedure ReadSettings;
  begin
    mRig.RigCtldPath := Rig_RigCtldPath;
    mRig.RigCtldArgs := Rig_RigCtldArgs;
    mRig.RunRigCtld := Rig_RunRigCtld;
    mRig.RigId := Rig_RigId;
    mRig.RigDevice := Rig_RigDevice;
    mRig.RigCtldPort := Rig_RigCtldPort;
    mRig.RigCtldHost := Rig_RigCtldHost;
    mRig.RigPoll := Rig_RigPoll;
    mRig.RigSendCWR := Rig_RigSendCWR;
  end;

begin
end;

end.
