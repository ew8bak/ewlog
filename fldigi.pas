unit fldigi;

{$mode objfpc}{$H+}

//  Copyright (c) 2008 Julian Moss, G4ILO  (www.g4ilo.com)                           //
//  Released under the GNU GPL v2.0 (www.gnu.org/licenses/old-licenses/gpl-2.0.txt)  //
interface

uses
  {$IFDEF WINDOWS}Windows,{$ENDIF} Classes, SysUtils;

function Fldigi_IsRunning: boolean;
function Fldigi_GetVersion: string;

function Fldigi_GetStatus1: string; // returns contents of 1st status bar panel
function Fldigi_GetStatus2: string; // returns contents of 2nd status bar panel

function Fldigi_GetCall: string;
function Fldigi_GetName: string;
function Fldigi_GetLocator: string;
function Fldigi_GetRSTs: string;
function Fldigi_GetRSTr: string;
function Fldigi_GetQTH: string;
function Fldigi_GetState: string;
function Fldigi_GetModemId: integer;

function Fldigi_GetFrequency: double;
procedure Fldigi_SetFrequency( frequency: double );
procedure Fldigi_ChangeFrequency( increment: double );

function Fldigi_GetQSOFrequency: double;

function Fldigi_IsAFC: boolean;
procedure Fldigi_SetAFC( state: boolean);

function Fldigi_IsSquelch: boolean;
procedure Fldigi_SetSquelch( state: boolean);

function Fldigi_IsLock: boolean;
procedure Fldigi_SetLock( state: boolean);

function Fldigi_IsReverse: boolean;
procedure Fldigi_SetReverse( state: boolean);

function Fldigi_GetCarrier: integer;
procedure Fldigi_SetCarrier( carrier: integer );
procedure Fldigi_ChangeCarrier( increment: integer );

function Fldigi_GetMode: string;
procedure Fldigi_SetMode( mode: string );
function Fldigi_ListModes: string;
function Fldigi_GetBandwidth: integer;

procedure Fldigi_ClearRx;
function Fldigi_RxCharsWaiting: boolean;
function Fldigi_GetRxString: string;

procedure Fldigi_StartTx;
procedure Fldigi_StopTx;
procedure Fldigi_AbortTx;
procedure Fldigi_Tune;
function Fldigi_IsTx: boolean;

procedure Fldigi_ClearTx;
procedure Fldigi_SendTxCharacter(ch: char);
procedure Fldigi_SendTxString(s: string);
procedure Fldigi_SendTxBytes(s: string);

procedure Fldigi_RunMacro( macro_id: integer );

function Fldigi_LastError: string;

var
  fldigiavailable: boolean = false;
  {$IFDEF WINDOWS}
  fl_handle: hWnd;
  {$ENDIF}

implementation

uses
  xmlrpc;

const
  fl_host = 'http://localhost:7362/RPC2';

var
  rxptr: integer = 0;

function Fldigi_IsRunning: boolean;
begin
  {$IFDEF WINDOWS}
  fl_handle := FindWindow('fldigi',PChar(0));
  Result := fl_handle <> 0;
  {$ELSE}
  Result := Length(Fldigi_GetVersion) > 0;
  {$ENDIF}
end;

function Fldigi_GetCall: string;
begin
  Result := RequestStr(fl_host,'log.get_call');
end;

function Fldigi_GetName: string;
begin
  Result := RequestStr(fl_host,'log.get_name');
end;

function Fldigi_GetQTH: string;
begin
  Result := RequestStr(fl_host,'log.get_qth');
end;

function Fldigi_GetState: string;
begin
  Result := RequestStr(fl_host,'log.get_state');
end;

function Fldigi_GetRSTr: string;
begin
  Result := RequestStr(fl_host,'log.get_rst_in');
end;

function Fldigi_GetRSTs: string;
begin
  Result := RequestStr(fl_host,'log.get_rst_out');
end;

function Fldigi_GetLocator: string;
begin
  Result := RequestStr(fl_host,'log.get_locator');
end;

function Fldigi_GetModemId: integer;
begin
  Result := RequestInt(fl_host,'modem.get_id');
end;

function Fldigi_GetVersion: string;
begin
  Result := RequestStr(fl_host,'fldigi.version');
end;

function Fldigi_GetStatus1: string;
begin
  Result := RequestStr(fl_host,'main.get_status1');
end;

function Fldigi_GetStatus2: string;
begin
  Result := RequestStr(fl_host,'main.get_status2');
end;

function Fldigi_GetFrequency: double;
// frequency is in Hz
begin
  Result := RequestFloat(fl_host,'main.get_frequency');
end;

procedure Fldigi_SetFrequency( frequency: double );
// frequency is in Hz
begin
  RequestStr(fl_host,'main.set_frequency',frequency);
end;

procedure Fldigi_ChangeFrequency( increment: double );
// increment is in Hz
begin
  RequestStr(fl_host,'main.inc_frequency',increment);
end;

function Fldigi_GetQSOFrequency: double;
// frequency is in Hz
var
  Request: string;
begin
  Request:= RequestStr(fl_host,'log.get_frequency');
  Request:=StringReplace(Request,',','.',[rfReplaceAll]);
  //Result:=StrToFloat(temp);
  Result := StrToFloatDef(Request,0.0);
end;

function Fldigi_IsAFC: boolean;
begin
  Result := RequestBool(fl_host,'main.get_afc');
end;

procedure Fldigi_SetAFC( state: boolean);
begin
  RequestStr(fl_host,'main.set_afc',state);
end;

function Fldigi_IsSquelch: boolean;
begin
  Result := RequestBool(fl_host,'main.get_squelch');
end;

procedure Fldigi_SetSquelch( state: boolean);
begin
  RequestStr(fl_host,'main.set_squelch',state);
end;

function Fldigi_IsLock: boolean;
begin
  Result := RequestBool(fl_host,'main.get_lock');
end;

procedure Fldigi_SetLock( state: boolean);
begin
  RequestStr(fl_host,'main.set_lock',state);
end;

function Fldigi_IsReverse: boolean;
begin
  Result := RequestBool(fl_host,'main.get_reverse');
end;

procedure Fldigi_SetReverse( state: boolean);
begin
  RequestStr(fl_host,'main.set_reverse',state);
end;

function Fldigi_GetCarrier: integer;
begin
  Result := RequestInt(fl_host,'modem.get_carrier');
end;

procedure Fldigi_SetCarrier( carrier: integer );
begin
  RequestStr(fl_host,'modem.set_carrier',carrier);
end;

procedure Fldigi_ChangeCarrier( increment: integer );
begin
  RequestStr(fl_host,'modem.inc_carrier',increment);
end;

function Fldigi_GetMode: string;
var
  p: integer;
begin
  Result := RequestStr(fl_host,'modem.get_name');
  repeat
    p := Pos('-',Result);
    if p > 0 then Delete(Result,p,1)
  until p = 0;
  repeat
    p := Pos('_',Result);
    if p > 0 then Delete(Result,p,1)
  until p = 0;
end;

procedure Fldigi_SetMode( mode: string );
var
  p,t,f: integer;
  m,n: string;

  function submode( md: string ): string;
  begin
    Result := md;
    while (Length(Result) > 0) and not (Result[1] in ['0'..'9']) do
      Delete(Result,1,1);
  end;
begin
  case Pos(Copy(Uppercase(mode),1,2),'CWRTBPQPMFOLMTDO') div 2 of
  0:  m := 'CW';
  1:  m := 'RTTY';
  2:  m := 'BPSK'+submode(mode);
  3:  m := 'QPSK'+submode(mode);
  4:  begin
        n := submode(mode);
        if n = '16' then
          m := 'MFSK16'
        else
          m := 'MFSK-'+n;
      end;
  5:  begin
        m := 'OLIVIA';
        p := Pos(' ',mode);
        if p > 0 then
        begin
          Delete(mode,1,p);
          p := Pos('/',mode);
          if p > 0 then
          begin
            t := StrToIntDef(Copy(mode,1,p-1),32);
            f := StrToIntDef(Copy(mode,p+1,4),1000);
          end;
        end;
      end;
  6:  begin
        m := 'MT63'+submode(mode);
        p := Pos('000',m);
        if p > 0 then
        begin
          Delete(m,p,3);
          m := m + 'XX';
        end;
      end;
  7:  begin
        n := submode(mode);
        if Length(n) = 1 then
          m := 'DomEX'+n
        else
          m := 'DomX'+n;
      end;
  end;
  RequestStr(fl_host,'modem.set_by_name',m,false);
  if m = 'OLIVIA' then
  begin
    RequestInt(fl_host,'modem.olivia.set_tones',t);
    RequestInt(fl_host,'modem.olivia.set_bandwidth',f);
  end;
end;

function Fldigi_ListModes: string;
begin
  Result := RequestStr(fl_host,'modem.get_names');
//  if RequestError then
    Result := GetLastResponse;
end;

function Fldigi_GetBandwidth: integer;
// only supported by CW modem, returns -1 otherwise
begin
  Result := RequestInt(fl_host,'modem.get_bandwidth');
end;

procedure Fldigi_ClearRx;
begin
  RequestStr(fl_host,'text.clear_rx');
  rxptr := 0;
end;

function Fldigi_RxCharsWaiting: boolean;
var
  l: integer;
begin
  l := RequestInt(fl_host,'text.get_rx_length');
  Result := l > rxptr;
end;

function Fldigi_GetRxString: string;
var
  l: integer;
begin
  l := RequestInt(fl_host,'text.get_rx_length');
  if l < rxptr then rxptr := 0;
  if l > rxptr then
  begin
    Result := RequestStr(fl_host,'text.get_rx',rxptr,l-rxptr);
    rxptr := l;
  end
  else
    Result := '';
end;

procedure Fldigi_StartTx;
begin
  RequestStr(fl_host,'main.tx');
end;

procedure Fldigi_StopTx;
begin
  RequestStr(fl_host,'main.rx');
end;

procedure Fldigi_AbortTx;
begin
  RequestStr(fl_host,'main.abort');
end;

procedure Fldigi_Tune;
begin
  RequestStr(fl_host,'main.tune');
end;

function Fldigi_IsTx: boolean;
begin
  Result := RequestStr(fl_host,'main.get_trx_status') = 'tx';
end;

procedure Fldigi_ClearTx;
begin
  RequestStr(fl_host,'text.clear_tx');
end;

// end text with "^r" to return to receive when sent

procedure Fldigi_SendTxCharacter(ch: char);
begin
  RequestStr(fl_host,'text.add_tx',ch,false);
end;

procedure Fldigi_SendTxString(s: string);
begin
  RequestStr(fl_host,'text.add_tx',s,false);
end;

procedure Fldigi_SendTxBytes(s: string);
begin
  // send byte string
  RequestStr(fl_host,'text.add_tx_bytes',s,true);
end;

procedure Fldigi_RunMacro( macro_id: integer );
// macro_id is an ordinal number. First macro button is 0
begin
  RequestStr(fl_host,'main.run_macro',macro_id);
end;

function Fldigi_LastError: string;
begin
  if RequestError then
    Result := GetLastError
  else
    Result := '';
end;

end.
