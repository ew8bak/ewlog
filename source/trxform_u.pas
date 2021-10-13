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
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure SBConnectClick(Sender: TObject);
  private
    statusConnect: boolean;

    { private declarations }
  public
    procedure ShowInfoFromRIG(Hz: integer);
    procedure Freq(Hz: integer);
    procedure SavePosition;
    { public declarations }
  end;

var
  TRXForm: TTRXForm;

implementation

uses
  MainFuncDM;

{$R *.lfm}

{ TTRXForm }

procedure TTRXForm.ShowInfoFromRIG(Hz: integer);
begin
  if Hz > 0 then
  begin
    Freq(Hz);
    lblMode.Caption := FMS.Mode;
  end;
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

procedure TTRXForm.Freq(Hz: integer);
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
  label8.Caption := fr[1];
  label11.Caption := fr[0];
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

end.
