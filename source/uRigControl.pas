(*
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Petr Hlozek ok2cqr AND OH1KH                                   *
 ***************************************************************************
*)

unit uRigControl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, ExtCtrls, IdTelnet, IdGlobal,
  Dialogs, MainFuncDM;

type
  TRigMode = record
    mode: string[10];
    pass: word;
    raw: string[10];
  end;

type
  TVFO = (VFOA, VFOB);


type
  TExplodeArray = array of string;

type
  TRigControl = class
    rcvdFreqMode: TIdTelnet;
    rigProcess: TProcess;
    tmrRigPoll: TTimer;
  private
    fRigCtldPath: string;
    fRigCtldArgs: string;
    fRunRigCtld: boolean;
    fMode: TRigMode;
    fFreq: double;
    fPTT: string;
    fRigPoll: word;
    fRigCtldPort: word;
    fLastError: string;
    fRigId: word;
    fRigDevice: string;
    fDebugMode: boolean;
    fRigCtldHost: string;
    fVFO: TVFO;
    RigCommand: TStringList;
    fRigSendCWR: boolean;
    BadRcvd: integer;
    fRXOffset: double;
    fTXOffset: double;

    function RigConnected: boolean;
    function StartRigctld: boolean;
    function Explode(const cSeparator, vString: string): TExplodeArray;
    procedure OnRigPollTimer(Sender: TObject);
    procedure OnDataAvailable(Sender: TIdTelnet; const Buffer: TIdBytes);
    //   procedure OnStatus(ASender: TObject; const AStatus: TIdStatus;
    //     const AStatusText: string);
  public


    constructor Create;
    destructor Destroy; override;

    property DebugMode: boolean read fDebugMode write fDebugMode;

    property RigCtldPath: string read fRigCtldPath write fRigCtldPath;
    //path to rigctld binary
    property RigCtldArgs: string read fRigCtldArgs write fRigCtldArgs;
    //rigctld command line arguments
    property RunRigCtld: boolean read fRunRigCtld write fRunRigCtld;
    //run rigctld command before connection
    property RigId: word read fRigId write fRigId;
    //hamlib rig id
    property RigDevice: string read fRigDevice write fRigDevice;
    //port where is rig connected
    property RigCtldPort: word read fRigCtldPort write fRigCtldPort;
    // port where rigctld is listening to connecions, default 4532
    property RigCtldHost: string read fRigCtldHost write fRigCtldHost;
    //host where is rigctld running
    property Connected: boolean read RigConnected;
    //connect rigctld
    property RigPoll: word read fRigPoll write fRigPoll;
    //poll rate in miliseconds
    property RigSendCWR: boolean read fRigSendCWR write fRigSendCWR;
    //send CWR instead of CW
    property LastError: string read fLastError;
    //last error during operation
    //RX offset for transvertor in MHz
    property RXOffset: double read fRXOffset write fRXOffset;

    //TX offset for transvertor in MHz
    property TXOffset: double read fTXOffset write fTXOffset;


    function GetCurrVFO: TVFO;
    function GetModePass: TRigMode;
    function GetModeOnly: string;
    function GetFreqHz: integer;
    function GetFreqKHz: double;
    function GetFreqMHz: double;
    function GetModePass(vfo: TVFO): TRigMode; overload;
    function GetModeOnly(vfo: TVFO): string; overload;
    function GetFreqHz(vfo: TVFO): double; overload;
    function GetFreqKHz(vfo: TVFO): double; overload;
    function GetFreqMHz(vfo: TVFO): double; overload;
    function GetRawMode: string;
    function GetBandwich(bw: string): string;

    procedure SetCurrVFO(vfo: TVFO);
    procedure SetModePass(mode: TRigMode);
    procedure SetFreqKHz(freq: double);
    procedure SetFreqHz(freq: integer);
    procedure ClearRit;
    procedure Restart;
  end;

implementation

uses
  TRXForm_U;

constructor TRigControl.Create;
begin
  RigCommand := TStringList.Create;
  fRigCtldHost := '127.0.0.1';
  fRigCtldPort := 4532;
  fRigPoll := 500;
  fRunRigCtld := True;
  rcvdFreqMode := TIdTelnet.Create;
  rigProcess := TProcess.Create(nil);
  rigProcess.ShowWindow := swoHIDE;
  tmrRigPoll := TTimer.Create(nil);
  tmrRigPoll.Enabled := False;
  tmrRigPoll.OnTimer := @OnRigPollTimer;
  rcvdFreqMode.OnDataAvailable := @OnDataAvailable;

end;

function TRigControl.StartRigctld: boolean;
var
  cmd: string;
begin
  if IniSet.rigctldStartUp then
  begin
    cmd := fRigCtldPath + ' ' + RigCtldArgs;
    rigProcess.CommandLine := cmd;
    try
      rigProcess.Execute;
      sleep(1500);
      if not rigProcess.Active then
      begin
        Result := False;
        exit;
      end
    except
      on E: Exception do
      begin
        fLastError := E.Message;
        Result := False;
        // TRXForm.tmrRadio.Enabled := False;
        exit;
      end
    end;
  end;
  Result := True;
end;

function TRigControl.RigConnected: boolean;
const
  ERR_MSG = 'Could not connect to rigctld';
begin

  // if (RigId = 1) then
  // begin
  //   Result := False;
  //   exit
  //  end;

  if fRunRigCtld then
  begin
    if (not StartRigctld) and (RigId <> 2) then
    begin
      Result := False;
      exit;
    end;
  end;

  rcvdFreqMode.Host := fRigCtldHost;
  rcvdFreqMode.Port := fRigCtldPort;
  rcvdFreqMode.Connect;

  if rcvdFreqMode.Connected then
  begin
    Result := True;
    tmrRigPoll.Interval := fRigPoll * 100;
    tmrRigPoll.Enabled := True;
  end
  else
  begin
    fLastError := ERR_MSG;
    Result := False;
  end;
end;

procedure TRigControl.SetCurrVFO(vfo: TVFO);
begin
  case vfo of
    VFOA: RigCommand.Add('V VFOA');//sendCommand.SendMessage('V VFOA'+LineEnding);
    VFOB: RigCommand.Add('V VFOB')//sendCommand.SendMessage('V VFOB'+LineEnding);
  end; //case
end;

procedure TRigControl.SetModePass(mode: TRigMode);
begin
  if (mode.mode = 'CW') and fRigSendCWR then
    mode.mode := 'CWR';
  RigCommand.Add('M ' + mode.mode + ' ' + IntToStr(mode.pass));
end;

procedure TRigControl.SetFreqKHz(freq: double);
begin
  RigCommand.Add('F ' + FloatToStr(freq * 1000 - TXOffset * 1000000));
end;

procedure TRigControl.ClearRit;
begin
  RigCommand.Add('J 0');
end;

function TRigControl.GetCurrVFO: TVFO;
begin
  Result := fVFO;
end;

function TRigControl.GetModePass: TRigMode;
begin
  Result := fMode;
end;

function TRigControl.GetModeOnly: string;
begin
  Result := fMode.mode;
end;

function TRigControl.GetFreqHz: integer;
begin
  try
    Result := Trunc(fFreq) + Trunc(fRXOffset) * 1000000;
  except
    Result := 0;
  end;
end;

function TRigControl.GetFreqKHz: double;
begin
  Result := (fFreq + fRXOffset * 1000000) / 1000;
end;

function TRigControl.GetFreqMHz: double;
begin
  Result := (fFreq + fRXOffset * 1000000) / 1000000;
end;

function TRigControl.GetModePass(vfo: TVFO): TRigMode;
var
  old_vfo: TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll * 2);
    Result := fMode;
    SetCurrVFO(old_vfo);
  end;
  Result := fMode;
end;

function TRigControl.GetModeOnly(vfo: TVFO): string;
var
  old_vfo: TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll * 2);
    Result := fMode.mode;
    SetCurrVFO(old_vfo);
  end;
  Result := fMode.mode;
end;

procedure TRigControl.SetFreqHz(freq: integer);
begin
  RigCommand.Add('F ' + IntToStr(freq));
end;

function TRigControl.GetFreqHz(vfo: TVFO): double;
var
  old_vfo: TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll * 2);
    Result := fFreq;
    SetCurrVFO(old_vfo);
  end;
  Result := fFreq;
end;

function TRigControl.GetFreqKHz(vfo: TVFO): double;
var
  old_vfo: TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll * 2);
    Result := fFreq / 1000;
    SetCurrVFO(old_vfo);
  end;
  Result := fFreq;
end;

function TRigControl.GetFreqMHz(vfo: TVFO): double;
var
  old_vfo: TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll * 2);
    Result := fFreq / 1000000;
    SetCurrVFO(old_vfo);
  end;
  Result := fFreq;
end;

function TRigControl.GetBandwich(bw: string): string;
var
  i: integer;
begin
  for i := length(bw) downto 1 do
    if not (bw[i] in ['0'..'9']) then
      Delete(bw, i, 1);
  Result := bw;
end;

procedure TRigControl.OnDataAvailable(Sender: TIdTelnet; const Buffer: TIdBytes);
var
  msg: string;
  a: TExplodeArray;
  i: integer;
  f: double;
begin
  msg := BytesToString(Buffer);
  if Length(msg) > 0 then
  begin
    msg := trim(msg);
    a := Explode(LineEnding, msg);
    for i := 0 to Length(a) - 1 do
    begin
      if a[i] = '' then
        Continue;

      if TryStrToFloat(a[i], f) then
      begin
        if f > 20000 then
          fFReq := f
        else
          fMode.pass := round(f);
        Continue;
      end;

      //if (a[i][1] in ['A'..'Z']) and (a[i][1] <> 'V' ) then //receiving mode info
      //FT-920 returned VFO as MEM
      if (a[i][1] in ['A'..'Z']) and (a[i][1] <> 'V') and (a[i] <> 'MEM') then
        //receiving mode info
      begin
        if Pos('RPRT', a[i]) = 0 then
        begin
          BadRcvd := 0;
          fMode.mode := a[i];
          fMode.raw := a[i];
          if fMode.mode = 'CWR' then
            fMode.mode := 'CW';
        end
        else
        begin
          if BadRcvd > 2 then
          begin
            fFreq := 0;
            fVFO := VFOA;
            fMode.mode := '';
            fMode.raw := '';
            fMode.pass := 2700;
          end
          else
            Inc(BadRcvd);
        end;
      end;
      if (a[i][1] = 'V') then
      begin
        if Pos('VFOB', msg) > 0 then
          fVFO := VFOB
        else
          fVFO := VFOA;
      end;
    end;
  end;
end;

procedure TRigControl.OnRigPollTimer(Sender: TObject);
var
  cmd: string;
  i: integer;
begin
  if (RigCommand.Text <> '') then
  begin
    for i := 0 to RigCommand.Count - 1 do
    begin
      sleep(100);
      cmd := RigCommand.Strings[i] + LineEnding;
      rcvdFreqMode.SendString(cmd);
    end;
    RigCommand.Clear;
  end
  else
  begin
    cmd := 'fmv' + LineEnding;
    rcvdFreqMode.SendString(cmd);
  end;
end;

procedure TRigControl.Restart;
var
  excode: integer = 0;
begin
  rigProcess.Terminate(excode);
  tmrRigPoll.Enabled := False;
  rcvdFreqMode.Disconnect(False);
  RigConnected;
end;

function TRigControl.Explode(const cSeparator, vString: string): TExplodeArray;
var
  i: integer;
  S: string;
begin
  S := vString;
  SetLength(Result, 0);
  i := 0;
  while Pos(cSeparator, S) > 0 do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[i] := Copy(S, 1, Pos(cSeparator, S) - 1);
    Inc(i);
    S := Copy(S, Pos(cSeparator, S) + Length(cSeparator), Length(S));
  end;
  SetLength(Result, Length(Result) + 1);
  Result[i] := Copy(S, 1, Length(S));
end;

function TRigControl.GetRawMode: string;
begin
  Result := fMode.raw;
end;

destructor TRigControl.Destroy;
var
  excode: integer = 0;
begin
  inherited;
  if fRunRigCtld then
  begin
    if rigProcess.Running then
      rigProcess.Terminate(excode);
  end;
  tmrRigPoll.Enabled := False;
  rcvdFreqMode.Disconnect();
  FreeAndNil(rcvdFreqMode);
  FreeAndNil(rigProcess);
  FreeAndNil(RigCommand);
  tmrRigPoll.Free;
end;

end.
end.
