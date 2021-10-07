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
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons;

type

  { TTRXForm }

  TTRXForm = class(TForm)
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
    SBConnect: TSpeedButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
  private

    { private declarations }
  public
    procedure ShowInfoFromRIG;
    procedure Freq(Hz: integer);
    procedure SavePosition;
    { public declarations }
  end;

var
  TRXForm: TTRXForm;

implementation

uses
  dmFunc_U, InitDB_dm, MainFuncDM, WSJT_UDP_Form_U,
  dmCat, dmTCI_u;

{$R *.lfm}

{ TTRXForm }

procedure TTRXForm.ShowInfoFromRIG;
begin

end;

procedure TTRXForm.SavePosition;
begin
  if TRXForm.Showing then
    MainFunc.SaveWindowPosition(TRXForm);
end;

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

procedure TTRXForm.FormShow(Sender: TObject);
begin
  MainFunc.LoadWindowPosition(TRXForm);
end;

procedure TTRXForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  IniSet.trxShow := False;
  MainFunc.SaveWindowPosition(TRXForm);
end;

end.
