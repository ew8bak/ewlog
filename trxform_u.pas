unit TRXForm_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Arrow, ActnList, uRigControl,
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
    btn80m: TButton;
    btnAM: TButton;
    btnCW: TButton;
    btnFM: TButton;
    btnRTTY: TButton;
    btnSSB: TButton;
    btnVFOA: TButton;
    btnVFOB: TButton;
    Button1: TButton;
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
    procedure btn10mClick(Sender: TObject);
    procedure btn12mClick(Sender: TObject);
    procedure btn15mClick(Sender: TObject);
    procedure btn160mClick(Sender: TObject);
    procedure btn17mClick(Sender: TObject);
    procedure btn20mClick(Sender: TObject);
    procedure btn2mClick(Sender: TObject);
    procedure btn30mClick(Sender: TObject);
    procedure btn40mClick(Sender: TObject);
    procedure btn6mClick(Sender: TObject);
    procedure btn70cmClick(Sender: TObject);
    procedure btn80mClick(Sender: TObject);
    procedure btnAMClick(Sender: TObject);
    procedure btnCWClick(Sender: TObject);
    procedure btnFMClick(Sender: TObject);
    procedure btnRTTYClick(Sender: TObject);
    procedure btnSSBClick(Sender: TObject);
    procedure btnVFOAClick(Sender: TObject);
    procedure btnVFOBClick(Sender: TObject);
    procedure Button1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure rbRadio1Click(Sender: TObject);
    procedure rbRadio2Click(Sender: TObject);
    procedure tmrRadioTimer(Sender: TObject);
  private

    old_mode: string;
    function GetActualMode: string;
    // function  GetModeNumber(mode : String) : Cardinal;
    procedure SetMode(mode: string; bandwidth: integer);
    procedure ShowFreq(mHz: double);
    { private declarations }
  public
    radio: TRigControl;
    //  radio: TRigControl;
    AutoMode: boolean;
    // bwith: string;
    procedure SynTRX;

    function GetFreqFromModeBand(band: integer; smode: string): string;
    //    function  GetModeFreqNewQSO(var mode,freq : String) : Boolean;
    function GetBandWidth(mode: string): integer;
    function GetModeBand(var mode, band: string): boolean;
    function InicializeRig: boolean;
    function GetFreqHz: double;
    function GetFreqkHz: double;
    function GetFreqMHz: double;
    function GetDislayFreq: string;
    function GetRawMode: string;
    procedure ClearButtonsColor;

    procedure SetModeFreq(mode, freq: string);
    procedure SetFreqModeBandWidth(freq: double; mode: string; BandWidth: integer);
    procedure CloseRigs;
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
  MainForm_U, dmFunc_U, const_u, ConfigForm_U, MinimalForm_U;

{$R *.lfm}

{ TTRXForm }

procedure TTRXForm.ShowFreq(mHz: double);
var
  fr: array[1..9] of string;
  hz: integer;
begin
  hz := trunc(mhz);
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
  end
  else
    f := 0;

  if (fldigiactive = False) and (f <> 0) then
  begin
    if ConfigForm.CheckBox2.Checked = True then
    begin
        ShowFreq(radio.GetFreqHz);
      if Minimal then
        MinimalForm.ComboBox1.Text := dmFunc.GetBandFromFreq(FormatFloat(view_freq, f))
      else
        MainForm.ComboBox1.Text := dmFunc.GetBandFromFreq(FormatFloat(view_freq, f));
    end
    else
    begin
        ShowFreq(radio.GetFreqHz);
      if Minimal then
        MinimalForm.ComboBox1.Text := FormatFloat(view_freq, f)
      else
        MainForm.ComboBox1.Text := FormatFloat(view_freq, f);
    end;
  end;

  if Length(m) > 1 then
    dmFunc.GetRIGMode(m, mode, submode);


  if (fldigiactive = False) and (Length(m) > 1) then
  begin
    if Minimal then
    begin
      MinimalForm.ComboBox2.Text := mode;
      MinimalForm.ComboBox3.Text := submode;
    end
    else
    begin
      MainForm.ComboBox2.Text := mode;
      MainForm.ComboBox9.Text := submode;
    end;
  end;
  lblMode.Caption := m;
end;

function TTRXForm.InicializeRig: boolean;
var
  n: string = '';
  id: integer = 0;
  poll: integer;
begin
  if Assigned(radio) then
  begin
    FreeAndNil(radio);
  end;

  Application.ProcessMessages;
  //Sleep(500);

  // tmrRadio.Enabled := False;
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
  if not TryStrToInt(IniF.ReadString('TRX' + n, 'Poll', '500'), poll) then
    poll := 500;
  radio.RigPoll := poll;
  radio.RigSendCWR := IniF.ReadBool('TRX' + n, 'CWR', False);
  rbRadio1.Caption := IniF.ReadString('TRX' + n, 'name', '');
  TRXForm.Caption := IniF.ReadString('TRX' + n, 'name', '');

  tmrRadio.Interval := radio.RigPoll;
  tmrRadio.Enabled := True;
  Result := True;
  if not radio.Connected then
  begin
    FreeAndNil(radio);
  end;
end;

function TTRXForm.GetFreqFromModeBand(band: integer; smode: string): string;
var
  freq: currency = 0;
  mode: integer = 0;
begin
  if smode = 'CW' then
    mode := 0
  else if smode = 'SSB' then
    mode := 1
  else if smode = 'RTTY' then
    mode := 2
  else if smode = 'AM' then
    mode := 3
  else if smode = 'FM' then
    mode := 4;

  case band of
    0:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '160cw', 1830);
        1: freq := IniF.ReadFloat('DefFreq', '160ssb', 1830);
        2: freq := IniF.ReadFloat('DefFreq', '160rtty', 1845);
        3: freq := IniF.ReadFloat('DefFreq', '160am', 1845);
        4: freq := IniF.ReadFloat('DefFreq', '160fm', 1845);
      end; //case
    end;

    1:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '80cw', 3525);
        1: freq := IniF.ReadFloat('DefFreq', '80ssb', 3750);
        2: freq := IniF.ReadFloat('DefFreq', '80rtty', 3590);
        3: freq := IniF.ReadFloat('DefFreq', '80am', 3750);
        4: freq := IniF.ReadFloat('DefFreq', '80fm', 3750);
      end; //case
    end;

    2:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '40cw', 7015);
        1: freq := IniF.ReadFloat('DefFreq', '40ssb', 7080);
        2: freq := IniF.ReadFloat('DefFreq', '40rtty', 7040);
        3: freq := IniF.ReadFloat('DefFreq', '40am', 7080);
        4: freq := IniF.ReadFloat('DefFreq', '40fm', 7080);
      end; //case
    end;

    3:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '30cw', 10110);
        1: freq := IniF.ReadFloat('DefFreq', '30ssb', 10130);
        2: freq := IniF.ReadFloat('DefFreq', '30rtty', 10130);
        3: freq := IniF.ReadFloat('DefFreq', '30am', 10130);
        4: freq := IniF.ReadFloat('DefFreq', '30fm', 10130);
      end; //case
    end;

    4:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '20cw', 14025);
        1: freq := IniF.ReadFloat('DefFreq', '20ssb', 14195);
        2: freq := IniF.ReadFloat('DefFreq', '20rtty', 14090);
        3: freq := IniF.ReadFloat('DefFreq', '20am', 14195);
        4: freq := IniF.ReadFloat('DefFreq', '20fm', 14195);
      end; //case
    end;

    5:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '17cw', 18080);
        1: freq := IniF.ReadFloat('DefFreq', '17ssb', 18140);
        2: freq := IniF.ReadFloat('DefFreq', '17rtty', 18110);
        3: freq := IniF.ReadFloat('DefFreq', '17am', 18140);
        4: freq := IniF.ReadFloat('DefFreq', '17fm', 18140);
      end; //case
    end;

    6:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '15cw', 21025);
        1: freq := IniF.ReadFloat('DefFreq', '15ssb', 21255);
        2: freq := IniF.ReadFloat('DefFreq', '15rtty', 21090);
        3: freq := IniF.ReadFloat('DefFreq', '15am', 21255);
        4: freq := IniF.ReadFloat('DefFreq', '15fm', 21255);
      end; //case
    end;

    7:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '12cw', 24895);
        1: freq := IniF.ReadFloat('DefFreq', '12ssb', 24925);
        2: freq := IniF.ReadFloat('DefFreq', '12rtty', 24910);
        3: freq := IniF.ReadFloat('DefFreq', '12am', 24925);
        4: freq := IniF.ReadFloat('DefFreq', '12fm', 24925);
      end; //case
    end;

    8:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '10cw', 28025);
        1: freq := IniF.ReadFloat('DefFreq', '10ssb', 28550);
        2: freq := IniF.ReadFloat('DefFreq', '10rtty', 28090);
        3: freq := IniF.ReadFloat('DefFreq', '10am', 28550);
        4: freq := IniF.ReadFloat('DefFreq', '10fm', 28550);
      end; //case
    end;

    9:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '6cw', 50090);
        1: freq := IniF.ReadFloat('DefFreq', '6ssb', 51300);
        2: freq := IniF.ReadFloat('DefFreq', '6rtty', 51300);
        3: freq := IniF.ReadFloat('DefFreq', '6am', 51300);
        4: freq := IniF.ReadFloat('DefFreq', '6fm', 51300);
      end; //case
    end;

    10:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '2cw', 144050);
        1: freq := IniF.ReadFloat('DefFreq', '2ssb', 144300);
        2: freq := IniF.ReadFloat('DefFreq', '2rtty', 144300);
        3: freq := IniF.ReadFloat('DefFreq', '2am', 144300);
        4: freq := IniF.ReadFloat('DefFreq', '2fm', 145300);
      end; //case
    end;

    11:
    begin
      case mode of
        0: freq := IniF.ReadFloat('DefFreq', '70cw', 3525);
        1: freq := IniF.ReadFloat('DefFreq', '70ssb', 3750);
        2: freq := IniF.ReadFloat('DefFreq', '70rtty', 3590);
        3: freq := IniF.ReadFloat('DefFreq', '70am', 3750);
        4: freq := IniF.ReadFloat('DefFreq', '70fm', 3750);
      end; //case
    end;

  end; //case
  Result := FloatToStr(freq);
end;

function TTRXForm.GetModeBand(var mode, band: string): boolean;
var
  freq: string;
begin
  mode := '';
  band := '';
  Result := True;
  freq := '';//lblFreq.Caption;
  mode := GetActualMode;
  if (freq = empty_freq) or (freq = '') then
    Result := False
  else
    band := dmFunc.GetBandFromFreq(freq);
end;

function TTRXForm.GetBandWidth(mode: string): integer;
var
  section: string;
begin
  if rbRadio1.Checked then
    section := 'Band1'
  else
    section := 'Band2';
  Result := 500;
  if (mode = 'LSB') or (mode = 'USB') then
    mode := 'SSB';
  if mode = 'CW' then
    Result := (IniF.ReadInteger(section, 'CW', 500));
  if mode = 'SSB' then
    Result := (IniF.ReadInteger(section, 'SSB', 1800));
  if mode = 'RTTY' then
    Result := (IniF.ReadInteger(section, 'RTTY', 500));
  if mode = 'AM' then
    Result := (IniF.ReadInteger(section, 'AM', 3000));
  if mode = 'FM' then
    Result := (IniF.ReadInteger(section, 'FM', 2500));
end;

function TTRXForm.GetActualMode: string;
begin
  if Assigned(radio) then
  begin
    Result := radio.GetModeOnly;
  end;
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

procedure TTRXForm.SetFreqModeBandWidth(freq: double; mode: string; BandWidth: integer);
var
  rmode: TRigMode;
  RXOffset: currency;
  TXOffset: currency;
begin
  if mode = 'SSB' then
  begin
    if (freq > 5000) and (freq < 6000) then
      mode := 'USB'
    else
    begin
      if freq > 10000 then
        mode := 'USB'
      else
        mode := 'LSB';
    end;
  end;

  if Assigned(radio) then
  begin
    // dmFunc.GetRXTXOffset(freq/1000,RXOffset,TXOffset);
    //  radio.RXOffset := RXOffset;
    //  radio.TXOffset := TXOffset;

    radio.SetFreqKHz(freq);
    if AutoMode then
    begin
      rmode.mode := mode;
      rmode.pass := BandWidth;
      radio.SetModePass(rmode);
    end;
  end;
end;

procedure TTRXForm.SetModeFreq(mode, freq: string); //freq in kHz
var
  bandwidth: integer = 0;
  f: double = 0;
begin
  // if (lblFreq.Caption = empty_freq) then
  //   exit;
  bandwidth := GetBandWidth(mode);
  f := StrToFloat(freq);
  if mode = 'SSB' then
  begin
    if (f > 5000) and (f < 6000) then
      mode := 'USB'
    else
    begin
      if f > 10000 then
        mode := 'USB'
      else
        mode := 'LSB';
    end;
  end;
  SetFreqModeBandWidth(f, mode, bandwidth);
end;

procedure TTRXForm.CloseRigs;
begin
  if Assigned(radio) then
    FreeAndNil(radio);
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

function TTRXForm.GetDislayFreq: string;
begin
  if Assigned(radio) then
    Result := FormatFloat(empty_freq + ';;', radio.GetFreqMHz)
  else
    Result := FormatFloat(empty_freq + ';;', 0);
end;

function TTRXForm.GetRawMode: string;
begin
  if Assigned(radio) then
    Result := radio.GetRawMode
  else
    Result := '';
end;


procedure TTRXForm.FormCreate(Sender: TObject);
var
  n: string = '';
begin
  Arrow1.Visible := False;
  Arrow2.Visible := False;
  Arrow3.Visible := False;
  Arrow4.Visible := False;
  Arrow5.Visible := False;
  Arrow6.Visible := False;
  Arrow7.Visible := False;
  Arrow8.Visible := False;
  Arrow9.Visible := False;
  Arrow10.Visible := False;
  Arrow11.Visible := False;
  Arrow12.Visible := False;
  Arrow13.Visible := False;
  Arrow14.Visible := False;
  Arrow15.Visible := False;
  Arrow16.Visible := False;
  Arrow17.Visible := False;
  Arrow18.Visible := False;

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
    SetMode('LSB', GetBandWidth('SSB'))
  else
  begin
    if (tmp > 5) and (tmp < 6) then
      SetMode('USB', GetBandWidth('SSB'))
    else
    begin
      if tmp > 10 then
        SetMode('USB', GetBandWidth('SSB'))
      else
        SetMode('LSB', GetBandWidth('SSB'));
    end;
  end;
end;

procedure TTRXForm.btnVFOAClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetCurrVfo(VFOA);
end;

procedure TTRXForm.btnVFOBClick(Sender: TObject);
begin
  if Assigned(radio) then
    radio.SetCurrVfo(VFOB);
end;

procedure TTRXForm.Button1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  radio.PttOn;
end;

procedure TTRXForm.Button1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  radio.PttOff;
end;

procedure TTRXForm.btnFMClick(Sender: TObject);
begin
  SetMode('FM', GetBandWidth('FM'));
end;

procedure TTRXForm.btnRTTYClick(Sender: TObject);
begin
  SetMode('RTTY', GetBandWidth('RTTY'));
end;

procedure TTRXForm.btnCWClick(Sender: TObject);
begin
  SetMode('CW', GetBandWidth('CW'));
end;

procedure TTRXForm.btnAMClick(Sender: TObject);
begin
  SetMode('AM', GetBandWidth('AM'));
end;

procedure TTRXForm.ClearButtonsColor;
begin
  btn160m.Font.Color := clDefault;
  btn80m.Font.Color := clDefault;
  btn40m.Font.Color := clDefault;
  btn30m.Font.Color := clDefault;
  btn20m.Font.Color := clDefault;
  btn17m.Font.Color := clDefault;
  btn15m.Font.Color := clDefault;
  btn12m.Font.Color := clDefault;
  btn10m.Font.Color := clDefault;
  btn6m.Font.Color := clDefault;
  btn2m.Font.Color := clDefault;
  btn70cm.Font.Color := clDefault;

end;

procedure TTRXForm.btn160mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(0, mode);
  SetModeFreq(mode, freq);
  btn160m.Font.Color := clRed;
end;

procedure TTRXForm.btn15mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(6, mode);
  SetModeFreq(mode, freq);
  btn15m.Font.Color := clRed;
end;

procedure TTRXForm.btn12mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(7, mode);
  SetModeFreq(mode, freq);
  btn12m.Font.Color := clRed;
end;

procedure TTRXForm.btn10mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(8, mode);
  SetModeFreq(mode, freq);
  btn10m.Font.Color := clRed;
end;

procedure TTRXForm.btn17mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(5, mode);
  SetModeFreq(mode, freq);
  btn17m.Font.Color := clRed;
end;

procedure TTRXForm.btn20mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(4, mode);
  SetModeFreq(mode, freq);
  btn20m.Font.Color := clRed;
end;

procedure TTRXForm.btn2mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(10, mode);
  SetModeFreq(mode, freq);
  btn2m.Font.Color := clRed;
end;

procedure TTRXForm.btn30mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(3, mode);
  SetModeFreq(mode, freq);
  btn30m.Font.Color := clRed;
end;

procedure TTRXForm.btn40mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(2, mode);
  SetModeFreq(mode, freq);
  btn40m.Font.Color := clRed;
end;

procedure TTRXForm.btn6mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(9, mode);
  SetModeFreq(mode, freq);
  btn6m.Font.Color := clRed;
end;

procedure TTRXForm.btn70cmClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(11, mode);
  SetModeFreq(mode, freq);
  btn70cm.Font.Color := clRed;
end;

procedure TTRXForm.btn80mClick(Sender: TObject);
var
  freq: string = '';
  mode: string = '';
begin
  ClearButtonsColor;
  mode := GetActualMode;
  freq := GetFreqFromModeBand(1, mode);
  SetModeFreq(mode, freq);
  btn80m.Font.Color := clRed;
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
