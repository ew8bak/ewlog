(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit TRXForm_U;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Dialogs, StdCtrls,
  ExtCtrls, Buttons, Classes;

type

  { TTRXForm }

  TTRXForm = class(TForm)
    Bevel1: TBevel;
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
    ImConnect: TImage;
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
    SBConnect: TSpeedButton;
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
    procedure btn70cm1Click(Sender: TObject);
    procedure btn70cmClick(Sender: TObject);
    procedure btn80mClick(Sender: TObject);
    procedure btnAMClick(Sender: TObject);
    procedure btnCWClick(Sender: TObject);
    procedure btnFMClick(Sender: TObject);
    procedure btnRTTYClick(Sender: TObject);
    procedure btnSSBClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure SBConnectClick(Sender: TObject);
  private
    statusConnect: boolean;

    { private declarations }
  public
    procedure ShowInfoFromRIG;
    procedure FreqHz(Hz: integer);
    procedure SavePosition;
    procedure SetFreqMode(Freq: integer; Mode: string);
    { public declarations }
  end;

var
  TRXForm: TTRXForm;

implementation

uses
  MainFuncDM, dmTCI_u, dmHamLib_u;

{$R *.lfm}

{ TTRXForm }

procedure TTRXForm.SetFreqMode(Freq: integer; Mode: string);
begin
  if IniSet.RIGConnected then
  begin
    if TCIRec.STATUS then
    begin
      if Freq > 0 then
        dmTCI.SendValue('VFO', IntToStr(Freq));
      dmTCI.SendValue('MODULATION', Mode);
      Exit;
    end
    else
    begin
      if Freq > 0 then
        dmHamLib.SetFreq(Freq);
      dmHamLib.SetMode(Mode);
      Exit;
    end;
  end;
end;

procedure TTRXForm.ShowInfoFromRIG;
var
  hz_freq: longint;
begin
  if FMS.Freq > 0 then
  begin
    hz_freq := trunc(FMS.Freq);
    FreqHz(hz_freq);
  end;
  lblMode.Caption := FMS.Mode;

  if statusConnect <> IniSet.RIGConnected then
  begin
    if IniSet.RIGConnected then
      ImConnect.Picture.LoadFromLazarusResource('bullet_green')
    else
      ImConnect.Picture.LoadFromLazarusResource('bullet_red');
    statusConnect := IniSet.RIGConnected;
  end;
end;

procedure TTRXForm.SavePosition;
begin
  if TRXForm.Showing then
    MainFunc.SaveWindowPosition(TRXForm);
end;

procedure TTRXForm.FreqHz(Hz: integer);
var
  fr: array[0..9] of string;
begin
  fr[0] := IntToStr(hz mod 10);
  fr[1] := IntToStr(Trunc((hz mod 100) / 10));
  fr[2] := IntToStr(Trunc((hz mod 1000) / 100));
  fr[3] := IntToStr(Trunc((hz mod 10000) / 1000));
  fr[4] := IntToStr(Trunc((hz mod 100000) / 10000));
  fr[5] := IntToStr(Trunc((hz mod 1000000) / 100000));
  fr[6] := IntToStr(Trunc((hz mod 10000000) / 1000000));
  fr[7] := IntToStr(Trunc((hz mod 100000000) / 10000000));
  fr[8] := IntToStr(Trunc((hz mod 1000000000) / 100000000));
  fr[9] := IntToStr(Trunc((hz mod 10000000000) / 1000000000));
  label1.Caption := fr[8];
  label2.Caption := fr[7];
  label3.Caption := fr[6];
  label4.Caption := fr[5];
  label5.Caption := fr[4];
  label6.Caption := fr[3];
  label7.Caption := fr[2];
  label11.Caption := fr[1];
  label8.Caption := fr[0];

end;

procedure TTRXForm.FormShow(Sender: TObject);
begin
  MainFunc.LoadWindowPosition(TRXForm);
  statusConnect := False;
  ImConnect.Picture.LoadFromLazarusResource('bullet_red');
end;

procedure TTRXForm.SBConnectClick(Sender: TObject);
begin
  MainFunc.StartRadio(IniSet.CurrentRIG);
end;

procedure TTRXForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  IniSet.trxShow := False;
  MainFunc.SaveWindowPosition(TRXForm);
end;

procedure TTRXForm.btn160mClick(Sender: TObject);
begin
  SetFreqMode(1850000, 'LSB');
end;

procedure TTRXForm.btn15mClick(Sender: TObject);
begin
  SetFreqMode(21150000, 'USB');
end;

procedure TTRXForm.btn12mClick(Sender: TObject);
begin
  SetFreqMode(24915000, 'USB');
end;

procedure TTRXForm.btn10mClick(Sender: TObject);
begin
  SetFreqMode(28500000, 'USB');
end;

procedure TTRXForm.btn17mClick(Sender: TObject);
begin
  SetFreqMode(18100000, 'USB');
end;

procedure TTRXForm.btn20mClick(Sender: TObject);
begin
  SetFreqMode(14080000, 'USB');
end;

procedure TTRXForm.btn2mClick(Sender: TObject);
begin
  SetFreqMode(70000000, 'USB');
end;

procedure TTRXForm.btn30mClick(Sender: TObject);
begin
  SetFreqMode(10120000, 'USB');
end;

procedure TTRXForm.btn40mClick(Sender: TObject);
begin
  SetFreqMode(7100000, 'LSB');
end;

procedure TTRXForm.btn6mClick(Sender: TObject);
begin
  SetFreqMode(52000000, 'USB');
end;

procedure TTRXForm.btn70cm1Click(Sender: TObject);
begin
  SetFreqMode(433500000, 'NFM');
end;

procedure TTRXForm.btn70cmClick(Sender: TObject);
begin
  SetFreqMode(145500000, 'NFM');
end;

procedure TTRXForm.btn80mClick(Sender: TObject);
begin
  SetFreqMode(3600000, 'LSB');
end;

procedure TTRXForm.btnAMClick(Sender: TObject);
begin
  SetFreqMode(0, 'AM');
end;

procedure TTRXForm.btnCWClick(Sender: TObject);
begin
  SetFreqMode(0, 'CW');
end;

procedure TTRXForm.btnFMClick(Sender: TObject);
begin
  SetFreqMode(0, 'NFM');
end;

procedure TTRXForm.btnRTTYClick(Sender: TObject);
begin
  SetFreqMode(0, 'DIGU');
end;

procedure TTRXForm.btnSSBClick(Sender: TObject);
begin
  if FMS.Freq >= 10 then
    SetFreqMode(0, 'USB')
  else
    SetFreqMode(0, 'LSB');
end;

end.
