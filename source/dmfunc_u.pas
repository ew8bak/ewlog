(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit dmFunc_U;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, FileUtil, Forms, Controls, Graphics, Dialogs, character,
  StdCtrls, process, Math, LCLProc, azidis3, aziloc,
  DateUtils, LazUTF8, strutils, LazFileUtils,
  versiontypes, versionresource, UTF8Process, fphttpclient,
    {$IFDEF LINUX}
    users,
    {$ENDIF LINUX}
    {$IFDEF WINDOWS}
    Windows;
    {$ELSE}
    BaseUnix, lclintf;
    {$ENDIF}

const
  ERR_FILE = 'errors.adi';
  MyWhiteSpace = [#0..#31];
  cNO_ANGLE = -999;
  CATHamLib = 2;
  CATdisabled = 0;
  {$IFDEF WINDOWS}
  userenv = 'userenv.dll';
  {$ENDIF}

type
  TExplodeArray = array of string;

type
  TdmFunc = class(TDataModule)
  private
    fDataDir: string;
    fDebugLevel: integer;

    { private declarations }
  public
    function GetSize(cURL: string): int64;
    function GetMyVersion: string;
    function Q(s: string): string;
    function getField(str, field: string): string;
    function antepenultimate_char(s: string): string;
    function penultimate_char(s: string): string;
    function last_char(s: string): char;
    function notHaveDigits(s: string): boolean;
    function find_last_digit(s: string): integer;
    function ExtractWPXPrefix(call: string): string;
    function GetBandFromFreq(MHz: string): string;
    function ReplaceCountry(Country: string): string;
    function Extention(FileName: string): string;
    procedure LoadRigList(RigCtlBinaryPath: string; RigList: TStringList);
    procedure LoadRigListCombo(CurrentRigId: string; RigList: TStringList;
      RigComboBox: TComboBox);
    procedure LoadRigsToComboBox(CurrentRigId: string; RigCtlBinaryPath: string;
      RigComboBox: TComboBox);
    function GetRigIdFromComboBoxItem(ItemText: string): integer;
    procedure DistanceFromCoordinate(my_loc: string; latitude, longitude: real;
      var qra, azim: string);
    procedure Delay(n: cardinal);
    //    procedure InsertModes(cmbMode: TComboBox);
    property DataDir: string read fDataDir write fDataDir;
    property DebugLevel: integer read fDebugLevel write fDebugLevel;
    function ADIFDateToDate(date: string): string;
    function MyTrim(tex: string): string;
    function RemoveSpaces(S: string): string;
    procedure ModifyWAZITU(var waz, itu: string);
    function GetFreqFromBand(band, mode: string): double;
    function LetterFromMode(mode: string): string;
    function IsAdifOK(qsodate, time_on, time_off, call, freq, mode,
      rst_s, rst_r, iota, itu, waz, loc, my_loc, band: string): boolean;
    function IsDateOK(date: string): boolean;
    function IsTimeOK(time: string): boolean;
    function IsModeOK(mode: string): boolean;
    function IsFreqOK(freq: string): boolean;
    function IsIOTAOK(iota: string): boolean;
    //    function GetBandFromFreq(MHz: string): integer;
    function Explode(const cSeparator, vString: string): TExplodeArray;
    function StrToDateFormat(sDate: string): TDateTime;
    function GetIDCall(callsign: string): string;
    function StringToADIF(tex: string; kp: boolean): string;
    //    function GetAdifBandFromFreq(MHz: string): string;
    function IsLocOK(loc: string): boolean;
    function CompleteLoc(loc: string): string;
    function ExtractCallsign(call: string): string;
    function LatLongToGrid(Lat, Long: real): string;
    function RunProgram(progpath, args: string): boolean;
    function RusToEng(Text: string): string;
    function RusToLat(Text: string): string;
    function StrToFreq(const freqstr: string): extended;
    function GetDigiBandFromFreq(MHz: string): double;
    procedure CoordinateFromLocator(loc: string; var latitude, longitude: currency);
    function nr(ch: char): integer;
    function par_str(s: string; n: integer): string;
    function Split(delimiter: string; str: string;
      limit: integer = MaxInt): TStringArray;
    function CheckSQLiteVersion(versionDLL: string): boolean;
    procedure GetRIGMode(rigmode: string; var mode, submode: string);
    procedure GetLatLon(Latitude, Longitude: string; var Lat, Lon: string);
    function CheckProcess(PName: string): boolean;
    function CloseProcess(PName: string): boolean;
    function GetCurrentUserName: string;
    function getFieldFromFldigi(str, field: string): string;
    {$IFDEF WINDOWS}
    function GetWindowsVersion: string;
    function GetUserProfilesDir: string;
   {$ENDIF WINDOWS}
    { public declarations }
  end;

var
  dmFunc: TdmFunc;
  DefaultLang: string = '';

  {$IFDEF WINDOWS}
  wsjt_handle: hWnd;
  {$ENDIF}

implementation

uses const_u, InitDB_dm;

{$IFDEF WINDOWS}
function GetProfilesDirectory(lpProfilesDir: PChar; var Size: DWORD): BOOL;
  stdcall; external userenv Name 'GetProfilesDirectoryA';
{$ENDIF}

{$R *.lfm}
{$IFDEF WINDOWS}
function TdmFunc.GetWindowsVersion: string;
var
  Os: OSVERSIONINFO;
begin
  Os.dwOSVersionInfoSize := sizeof(Os);
  GetVersionEx(Os);
  if ((Os.dwMinorVersion = 1) and (Os.dwMajorVersion = 5)) then
  begin
    Result := ('Windows XP');
  end
  else if ((Os.dwMinorVersion = 0) and (Os.dwMajorVersion = 6)) then
  begin
    Result := ('Windows Vista');
  end
  else if ((Os.dwMinorVersion = 1) and (Os.dwMajorVersion = 6)) then
  begin
    Result := ('Windows 7');
  end
  else if ((Os.dwMinorVersion = 2) and (Os.dwMajorVersion = 6)) then
  begin
    Result := ('Windows 8');
  end
  else if ((Os.dwMinorVersion = 3) and (Os.dwMajorVersion = 6)) then
  begin
    Result := ('Windows 8.1');
  end
  else if ((Os.dwMinorVersion = 0) and (Os.dwMajorVersion = 10)) then
  begin
    Result := ('Windows 10');
  end
  else
  begin
    Result := 'Major:' + IntToStr(os.dwMajorVersion) + ', Minor:' + IntToStr(os.dwMinorVersion);
  end;
end;

function TdmFunc.GetUserProfilesDir: string;
const
  MaxLen = 256;
var
  Len: DWORD;
  WS: string;
  Res: Windows.BOOL;
begin
  Len := MaxLen;
  SetLength(WS, MaxLen - 1);
  Res := GetProfilesDirectory(@WS[1], Len);
  if Res then
  begin
    SetLength(WS, Len - 1);
    Result := Utf16ToUtf8(WS);
  end
  else
    SetLength(Result, 0);
end;

{$ENDIF WINDOWS}
function TdmFunc.GetCurrentUserName: string;
{$IFDEF WINDOWS}
const
  MaxLen = 256;
var
  Len: DWORD;
  WS: WideString;
  Res: Windows.BOOL;
{$ENDIF}
begin
  Result := '';
  {$IFDEF UNIX}
  {$IF (DEFINED(LINUX)) OR (DEFINED(FREEBSD))}
  Result := SysToUtf8(GetUserName(fpgetuid));
  {$ELSE Linux/BSD}
  Result := GetEnvironmentVariableUtf8('USER');
  {$ENDIF UNIX}
  {$ELSE}
  {$IFDEF WINDOWS}
  Len := MaxLen;
  {$IFnDEF WINCE}
  if Win32MajorVersion <= 4 then
  begin
    SetLength(Result, MaxLen);
    Res := Windows.GetuserName(@Result[1], Len);
    if Res then
    begin
      SetLength(Result, Len - 1);
      Result := SysToUtf8(Result);
    end
    else
      SetLength(Result, 0);
  end
  else
  {$ENDIF NOT WINCE}
  begin
    SetLength(WS, MaxLen - 1);
    Res := Windows.GetUserNameW(@WS[1], Len);
    if Res then
    begin
      SetLength(WS, Len - 1);
      Result := Utf16ToUtf8(WS);
    end
    else
      SetLength(Result, 0);
  end;
  {$ENDIF WINDOWS}
  {$ENDIF UNIX}
end;

function TdmFunc.getFieldFromFldigi(str, field: string): string;
var
  start: integer = 0;
  stop: integer = 0;
begin
  try
    Result := '';
    start := str.IndexOf('<' + field + '>');
    if (start >= 0) then
    begin
      str := str.Substring(start + field.Length);
      start := str.IndexOf('>');
      stop := str.IndexOf('<');
      if (start < stop) and (start > -1) then
        Result := TrimRight(str.Substring(start + 1, stop - start - 1));
    end;
  except
    Result := '';
  end;
end;

function TdmFunc.CheckProcess(PName: string): boolean;
var
  AProcess: TProcess;
  AStringList: TStringList;
begin
  AStringList := TStringList.Create;
  AProcess := TProcess.Create(nil);
  AProcess.ShowWindow := swoHIDE;
  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];

  {$IFDEF WINDOWS}
  AProcess.Executable := 'tasklist /FI "IMAGENAME eq ' + PName + '"';
  {$ELSE}
  AProcess.Executable := 'ps -C ' + PName;
  {$ENDIF}
  AProcess.Execute;
  AStringList.LoadFromStream(AProcess.Output);

  if AStringList.Count > 1 then
    Result := True
  else
    Result := False;

  AStringList.Free;
  AProcess.Free;
end;

function TdmFunc.CloseProcess(PName: string): boolean;
var
  AProcess: TProcess;
begin
  AProcess := TProcess.Create(nil);
  AProcess.ShowWindow := swoHIDE;
  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];

  {$IFDEF WINDOWS}
  AProcess.Executable := 'taskkill /f /im "' + PName + '"';
  {$ELSE}
  AProcess.Executable := 'killall ' + PName;
  {$ENDIF}
  AProcess.Execute;

  if CheckProcess(PName) then
    Result := False
  else
    Result := True;
  AProcess.Free;
end;

procedure TdmFunc.GetLatLon(Latitude, Longitude: string; var Lat, Lon: string);
begin
  if (UTF8Pos('W', Longitude) <> 0) then
  begin
    Longitude := '-' + Longitude;
    Delete(Longitude, length(Longitude), 1);
  end;
  if (UTF8Pos('S', Latitude) <> 0) then
  begin
    Latitude := '-' + Latitude;
    Delete(Latitude, length(Latitude), 1);
  end;
  if (UTF8Pos('E', Longitude) <> 0) then
  begin
    Delete(Longitude, length(Longitude), 1);
  end;
  if (UTF8Pos('N', Latitude) <> 0) then
  begin
    Delete(Latitude, length(Latitude), 1);
  end;

  Lat := Latitude;
  Lon := Longitude;
end;

procedure TdmFunc.GetRIGMode(rigmode: string; var mode, submode: string);
begin
  if (Pos('FM', rigmode) > 0) and (Pos('PKTFM', rigmode) <= 0) and
    (Pos('WFM', rigmode) <= 0) then
  begin
    mode := 'FM';
    submode := '';
    Exit;
  end;
  if (Pos('USB', rigmode) > 0) and (Pos('PKTUSB', rigmode) <= 0) then
  begin
    mode := 'SSB';
    submode := 'USB';
    Exit;
  end;
  if (Pos('LSB', rigmode) > 0) and (Pos('PKTLSB', rigmode) <= 0) then
  begin
    mode := 'SSB';
    submode := 'LSB';
    Exit;
  end;
  if (Pos('AM', rigmode) > 0) then
  begin
    mode := 'AM';
    submode := '';
    Exit;
  end;
  if (Pos('CW', rigmode) > 0) then
  begin
    mode := 'CW';
    submode := '';
    Exit;
  end;
  if (Pos('PKTFM', rigmode) > 0) then
  begin
    mode := 'PKT';
    submode := 'PKTFM';
    Exit;
  end;
  if (Pos('PKTUSB', rigmode) > 0) or (Pos('PKTLSB', rigmode) > 0) or
    (Pos('RTTY', rigmode) > 0) then
  begin
    mode := 'RTTY';
    submode := '';
    Exit;
  end;

  if (Pos('WFM', rigmode) > 0) then
  begin
    mode := 'WFM';
    submode := '';
    Exit;
  end;

  if (Pos('DIGU', rigmode) > 0) then
  begin
    mode := 'SSB';
    submode := 'USB';
    Exit;
  end;

  if (Pos('DIGL', rigmode) > 0) then
  begin
    mode := 'SSB';
    submode := 'LSB';
    Exit;
  end;
end;

function TdmFunc.CheckSQLiteVersion(versionDLL: string): boolean;
var
  verInst, VerMin: integer;
begin
  Result := True;
  try
    if versionDLL = '' then
    begin
      Result := True;
      Exit;
    end;
    verMin := StrToInt(StringReplace(min_sqlite_version, '.', '', [rfReplaceAll]));
    verInst := StrToInt(StringReplace(versionDLL, '.', '', [rfReplaceAll]));
    if verInst < VerMin then
      Result := False;
  except
    Result := True;
  end;
end;

function TdmFunc.GetSize(cURL: string): int64;
var
  vHTTP: TFPHTTPClient;
  i: integer;
  s: string;
begin
  Result := -1;
  try
  vHTTP := TFPHTTPClient.Create(nil);
  vHTTP.AllowRedirect := True;
  vHTTP.HTTPMethod('HEAD', cUrl, nil, []);
    for i := 0 to pred(vHTTP.ResponseHeaders.Count) do
    begin
      s := UpperCase(vHTTP.ResponseHeaders[i]);
      if Pos('CONTENT-LENGTH:', s) > 0 then
      begin
        Result := StrToIntDef(Copy(s, Pos(':', s) + 1, Length(s)), 0);
        Break;
      end;
    end;
  finally
  vHTTP.Free;
  end;
end;

function TdmFunc.GetMyVersion: string;
var
  Stream: TResourceStream;
  vr: TVersionResource;
  fi: TVersionFixedInfo;
begin
  Result := '';
  Stream := TResourceStream.CreateFromID(HINSTANCE, 1, PChar(RT_VERSION));
  try
    vr := TVersionResource.Create;
    try
      vr.SetCustomRawDataStream(Stream);
      fi := vr.FixedInfo;
      Result := Format('%d.%d.%d', [fi.FileVersion[0], fi.FileVersion[1],
        fi.FileVersion[2], fi.FileVersion[3]]);
    finally
      vr.Free
    end;
  finally
    Stream.Free
  end;
end;

function TdmFunc.Q(s: string): string;
var
  i: integer;
  Quote: char;
  char2: char;
begin
  Quote := #39;
  char2 := ',';
  Result := s;
  if Result = 'NULL' then
  begin
    Result := Result + char2;
    exit;
  end;
  for i := Length(Result) downto 1 do
    if Result[i] = Quote then
      Insert(Quote, Result, i);
  Result := Quote + Result + Quote + char2;
end;

function TdmFunc.getField(str, field: string): string;
var
  start: integer = 0;
  stop: integer = 0;
begin
  if field = 'VALIDDX' then
    field := 'ValidDX';
  if field = 'NOCALCDXCC' then
    field := 'NoCalcDXCC';
  try
    Result := '';
    start := str.IndexOf('<' + field + ':');
    if (start >= 0) then
    begin
      str := str.Substring(start + field.Length);
      start := str.IndexOf('>');
      stop := str.IndexOf('<');
      if (start < stop) and (start > -1) then
        Result := TrimRight(str.Substring(start + 1, stop - start - 1));
    end;
  except
    Result := '';
  end;

  if (Result = '') and (field <> LowerCase(field)) then
    Result := getField(str, LowerCase(field));
end;

function TdmFunc.LetterFromMode(mode: string): string;
begin
  if (mode = 'CW') or (mode = 'CWQ') then
    Result := 'C'
  else
  begin
    if (mode = 'FM') or (mode = 'SSB') or (mode = 'AM') then
      Result := 'F'
    else
      Result := 'D';
  end;
end;

function TdmFunc.GetFreqFromBand(band, mode: string): double;
var
  bandsMmList: TStringList;
  i, index: integer;
begin
  try
    Result := 0;
    bandsMmList := TStringList.Create;
    mode := UpperCase(mode);
    band := UpperCase(band);

    if (mode = 'RTTY') or (Pos('PSK', mode) > 0) or (Pos('JT', mode) > 0) or
      (mode = 'FT8') then
      mode := 'DIGI';

    for i := 0 to Length(bandsMm) - 1 do
      bandsMmList.Add(bandsMm[i]);
    index := bandsMmList.indexOf(band);

    if mode = 'CW' then
    begin
       TryStrToFloatSafe(bandsCW[index],Result);
       exit;
    end;
    if mode = 'DIGI' then
    begin
       TryStrToFloatSafe(bandsRTTY[index], Result);
       exit;
    end;
    if mode = 'MHZ' then begin
      TryStrToFloatSafe(bandsHz[index], Result);
      exit;
    end;

     TryStrToFloatSafe(bandsOther[index], Result);
  finally
    bandsMmList.Free;
  end;
end;

function TdmFunc.GetBandFromFreq(MHz: string): string;
var
  x: integer;
  tmp: currency;
  Dec: currency;
  band: string;
  dotcount, i: integer;
begin
  Result := '';
  band := '';
  dotcount := 0;

  for i := 1 to length(MHz) do
    if MHz[i] = '.' then
      Inc(dotcount);

  if dotcount > 1 then
    Delete(MHz, length(MHz) - 2, 1);

  if Pos('.', MHz) > 0 then
    MHz[Pos('.', MHz)] := FormatSettings.DecimalSeparator;

  if pos(',', MHz) > 0 then
    MHz[pos(',', MHz)] := FormatSettings.DecimalSeparator;

  if not TryStrToCurr(MHz, tmp) then
    exit;

  if tmp < 1 then
  begin
    Dec := Int(frac(tmp) * 1000);
    if ((Dec >= 133) and (Dec <= 139)) then
      Result := '2190M';
    if ((Dec >= 472) and (Dec <= 480)) then
      Result := '630M';
    exit;
  end;
  x := trunc(tmp);
  case x of
    1: Band := '160M';
    3: band := '80M';
    5: band := '60M';
    7: band := '40M';
    10: band := '30M';
    14: band := '20M';
    18: Band := '17M';
    21: Band := '15M';
    24: Band := '12M';
    28..30: Band := '10M';
    50..53: Band := '6M';
    70..72: Band := '4M';
    144..149: Band := '2M';
    219..225: Band := '1.25M';
    430..440: band := '70CM';
    900..929: band := '33CM';
    1240..1300: Band := '23CM';
    2300..2450: Band := '13CM';
    3400..3475: band := '9CM';
    5650..5850: Band := '6CM';
    10000..10500: band := '3CM';
    24000..24250: band := '1.25CM';
    47000..47200: band := '6MM';
    76000..84000: band := '4MM'
  end;
  Result := band;
end;

function TdmFunc.GetDigiBandFromFreq(MHz: string): double;
var
  x: integer;
  tmp: currency;
  Dec: currency;
  band: double;
  dotcount, i: integer;
begin
  Result := 0;
  band := 0;
  dotcount := 0;
  for i := 1 to length(MHz) do
    if MHz[i] = '.' then
      Inc(dotcount);

  if dotcount > 1 then
    Delete(MHz, length(MHz) - 2, 1);

  if Pos('.', MHz) > 0 then
    MHz[Pos('.', MHz)] := DefaultFormatSettings.DecimalSeparator;

  if pos(',', MHz) > 0 then
    MHz[pos(',', MHz)] := DefaultFormatSettings.DecimalSeparator;

  if not TextToFloat(PChar(MHZ), tmp, fvCurrency) then
    exit;

  if tmp < 1 then
  begin
    Dec := Int(frac(tmp) * 1000);
    if ((Dec >= 133) and (Dec <= 139)) then
      Result := 0.137;
    if ((Dec >= 472) and (Dec <= 480)) then
      Result := 0.475;
    exit;
  end;
  x := trunc(tmp);
  case x of
    1: Band := 1.8;
    3: band := 3.5;
    5: band := 5;
    7: band := 7;
    10: band := 10;
    14: band := 14;
    18: Band := 18;
    21: Band := 21;
    24: Band := 24;
    28..29: Band := 28;
    50..53: Band := 50;
    70..72: Band := 70;
    144..146: Band := 144;
    219..225: band := 219;
    430..440: band := 430;
    902..928: band := 925;
    1240..1300: Band := 1300;
    2300..2450: Band := 2450;
    3400..3475: band := 3475;
    5650..5850: Band := 5850;
    10000..10500: band := 10500;
    24000..24250: band := 24250;
    47000..47200: band := 47200;
    76000..84000: band := 84000;
  end;
  Result := band;
end;


function TdmFunc.antepenultimate_char(s: string): string;
begin
  Result := s.Substring(s.Length - 3, 1);
end;

function TdmFunc.penultimate_char(s: string): string;
begin
  Result := s.Substring(s.Length - 2, 1);
end;

function TdmFunc.last_char(s: string): char;
begin
  Result := s.Chars[s.Length - 1];
end;

function TdmFunc.notHaveDigits(s: string): boolean;
var
  Count, i: integer;
begin
  Count := 0;
  for i := 0 to s.Length - 1 do
  begin
    if IsDigit(s.Chars[i]) then
      Count := Count + 1;
  end;
  if Count = 0 then
    Result := True
  else
    Result := False;
end;

function TdmFunc.find_last_digit(s: string): integer;
var
  i, Count: integer;
begin
  Count := -1;
  for i := 0 to s.Length - 1 do
  begin
    if IsDigit(s.Chars[i]) then
      Count := i;
  end;
  Result := Count;
end;

function TdmFunc.ExtractWPXPrefix(Call: string): string;
var
  callsign: string;
  portable_district: char = #0;
  portables: string = 'AEJMP';
  mobiles: array [0..2] of string = ('AM', 'MA', 'MM');
  item: string;
  slash_posn, last_digit_posn, i: integer;
  left: string;
  left_size: integer;
  right: string;
  right_size: integer;
  designator: string;
  rv: string;
begin

  if Call.length < 3 then
  begin
    Result := '';
    exit;
  end;

  callsign := Call;

  if callsign.EndsWith('/QRP') then
    callsign := callsign.Substring(0, callsign.Length - 4);

  if (callsign.Length >= 2) and (penultimate_char(callsign).Equals('/')) then
  begin
    if portables.IndexOf(last_char(callsign)) >= 0 then
      callsign := callsign.substring(0, callsign.length - 2)
    else
    if IsDigit(last_char(callsign)) then
    begin
      portable_district := last_char(callsign);
      callsign := callsign.substring(0, callsign.length - 2);
    end;
  end;

  if (callsign.Length >= 3) and (antepenultimate_char(callsign).Equals('/')) then
  begin
    for i := 0 to 2 do
    begin
      item := mobiles[i];
      if item.Equals(callsign.substring(callsign.length - 2)) then
      begin
        callsign := callsign.substring(0, callsign.length - 3);
        Break;
      end;
    end;
  end;

  if (notHaveDigits(callsign)) then
  begin
    Result := (callsign.substring(0, 2) + '0');
    exit;
  end;

  slash_posn := callsign.indexOf('/');

  if ((slash_posn < 0) or (slash_posn = callsign.length - 1)) then
  begin
    last_digit_posn := find_last_digit(callsign);
    if (portable_district <> #0) then
      callsign := callsign.substring(0, last_digit_posn) + portable_district +
        callsign.substring(last_digit_posn + 1);
    Result := callsign.substring(0, min(callsign.length, last_digit_posn + 1));
    exit;
  end;

  left := callsign.substring(0, slash_posn);
  left_size := left.length;
  right := callsign.substring(slash_posn + 1);
  right_size := right.length;

  if (left_size = right_size) then
  begin
    Result := left;
    exit;
  end;

  if left_size < right_size then
    designator := left
  else
    designator := right;

  if notHaveDigits(designator) then
    designator := designator + '0';

  rv := designator;
  if rv.length = 1 then
  begin
    if rv.substring(0, 1).equals(call.substring(0, 1)) then
      rv := call.Substring(0, 2);
  end;
  Result := rv;
end;

function TdmFunc.ReplaceCountry(Country: string): string;
begin
  Result := '';
  if Pos('USA', Country) > 0 then
  begin
    Result := 'United-States';
    exit;
  end;

  if Pos(',', Country) > 0 then
  begin
    Delete(Country, Pos(',', Country), Length(Country));
    Result := Country;
    exit;
  end;

  if (Country = 'Russia (European)') or (Country = 'Russia (Asiatic)') or
    (Country = 'Kaliningrad') then
  begin
    Result := 'Russia';
    exit;
  end;
  if (Country = 'United States') then
  begin
    Result := 'United-States';
    exit;
  end;
  if (Country = 'Bosnia-Herzegovina') then
  begin
    Result := 'Bosnia-and-Herzegovina';
    exit;
  end;
  if (Country = 'South Africa') then
  begin
    Result := 'South-Africa';
    exit;
  end;
  if (Country = 'West Malaysia') then
  begin
    Result := 'Malaysia';
    exit;
  end;
  if (Country = 'Canary Is.') then
  begin
    Result := 'Canary-Islands';
    exit;
  end;
  if (Country = 'Isle of Man') then
  begin
    Result := 'Isle-of-Man';
    exit;
  end;
  if (Country = 'Faroe Is.') then
  begin
    Result := 'Faroes';
    exit;
  end;
  if (Country = 'Sao Tome & Principe') then
  begin
    Result := 'Sao-Tome-and-Principe';
    exit;
  end;
  if (Country = 'Czech Republic') then
  begin
    Result := 'Czech-Republic';
    exit;
  end;
  if (Country = 'Northern Ireland') then
  begin
    Result := 'Ireland';
    exit;
  end;
  if (Country = 'Sardinia') then
  begin
    Result := 'Italy';
    exit;
  end;
  if (Country = 'San Marino') then
  begin
    Result := 'San-Marino';
    exit;
  end;
  if (Country = 'Puerto Rico') then
  begin
    Result := 'Puerto-Rico';
    exit;
  end;
  Result := Country;
end;

function TdmFunc.Extention(FileName: string): string;
var
  i: integer;
begin
  i := Length(FileName);
  while (i > 0) and (FileName[i] <> '.') do
    i := i - 1;
  if i <= 0 then
    Result := ''
  else
    Result := Copy(FileName, i, Length(FileName));
end;

function TdmFunc.Split(delimiter: string; str: string;
  limit: integer = MaxInt): TStringArray;
var
  p, cc, dsize: integer;
begin
  cc := 0;
  dsize := length(delimiter);
  if dsize = 0 then
  begin
    setlength(Result, 1);
    Result[0] := str;
    exit;
  end;
  while cc + 1 < limit do
  begin
    p := pos(delimiter, str);
    if p > 0 then
    begin
      Inc(cc);
      setlength(Result, cc);
      Result[cc - 1] := copy(str, 1, p - 1);
      Delete(str, 1, p + dsize - 1);
    end
    else
      break;
  end;
  Inc(cc);
  setlength(Result, cc);
  Result[cc - 1] := str;
end;

function TdmFunc.par_str(s: string; n: integer): string;
  // s - строка, n - нужный элемент
var
  i: integer;
begin
  if n <= 0 then
  begin
    Result := '';
    Exit;
  end; // если введен 0 или отриц. число то выходим;

  if n = 1 then
    Delete(s, pos(':', s), Length(s))
  else     // если элемент первый то выводим его иначе дальше в цикл ищем нужный по кол-ву разделитель
    for i := 1 to n - 1 do
    begin
      if pos(':', s) = 0 then
      begin
        Result := '';
        Exit;
      end;  // если разделитель не найден то выходим;
      Delete(s, 1, pos(':', s));  //удаляем все до разделителя
      if i = n - 1 then
        if pos(':', s) <> 0 then
          Delete(s, pos(':', s), Length(s));
      // удаляем все после нужного элемента
    end;
  Result := s;
end;

procedure TdmFunc.LoadRigList(RigCtlBinaryPath: string; RigList: TStringList);
var
  p: TProcess;
  OutputStream: TStream;
  BytesRead: longint;
  Buffer: array [1..2048] of byte;
begin
  p := TProcess.Create(nil);
  try
    p.Executable := RigCtlBinaryPath;
    p.Parameters.add('-l');
    p.Options := p.Options + [poUsePipes];
    p.ShowWindow := swoHIDE;
    p.Execute;
    OutputStream := TMemoryStream.Create;
    repeat
      BytesRead := p.Output.Read(Buffer, 2048);
      OutputStream.Write(Buffer, BytesRead);
    until BytesRead = 0;
    OutputStream.Position := 0;
    RigList.LoadFromStream(OutputStream);
  finally
    FreeAndNil(p);
    OutputStream.Free;
  end;
end;

procedure TdmFunc.LoadRigListCombo(CurrentRigId: string; RigList: TStringList;
  RigComboBox: TComboBox);
var
  i: integer;
  RigId: string;
  RigName: string;
  RigType: string;
  CmbText: string = '';
begin
  for i := 1 to RigList.Count - 1 do
  begin
    RigId := trim(copy(RigList.Strings[i], 1, 7));
    if RigId <> '' then
    begin
      RigName := trim(copy(RigList.Strings[i], 8, 24));
      RigType := trim(copy(RigList.Strings[i], 32, 23));
      RigComboBox.Items.Add(RigId + ' ' + RigName + ' ' + RigType + ' ');
      if (RigId = CurrentRigId) then
      begin
        CmbText := RigId + ' ' + RigName + ' ' + RigType + ' ';
      end;
    end;
  end;
  if (CmbText = '') then
    RigComboBox.ItemIndex := 0
  else
    RigComboBox.Text := CmbText;
end;

procedure TdmFunc.LoadRigsToComboBox(CurrentRigId: string;
  RigCtlBinaryPath: string; RigComboBox: TComboBox);
var
  RigList: TStringList;
begin
  RigList := TStringList.Create;
  try
    LoadRigList(RigCtlBinaryPath, RigList);
    LoadRigListCombo(CurrentRigId, RigList, RigComboBox)
  finally
    FreeAndNil(RigList)
  end;
end;

function TdmFunc.GetRigIdFromComboBoxItem(ItemText: string): integer;
begin
  Result := StrToInt(Copy(ItemText, 1, Pos(' ', ItemText) - 1));
end;

function TdmFunc.nr(ch: char): integer;
var
  letters: string;
begin
  letters := 'ABCDEFGHIJKLMNOPQRSTUVWX';
  Result := Pos(ch, letters);
end;

procedure TdmFunc.CoordinateFromLocator(loc: string; var latitude, longitude: currency);
var
  a, b, c, d, e, f: integer;
begin
  a := 0;
  b := 0;
  c := 0;
  d := 0;
  e := 0;
  f := 0;
  if not dmFunc.IsLocOK(loc) then
    exit;
  a := nr(loc[1]);
  b := nr(loc[2]);
  c := StrToInt(loc[3]);
  d := StrToInt(loc[4]);
  if Length(loc) > 4 then
    e := nr(loc[5]);
  if Length(loc) > 5 then
    f := nr(loc[6]);

  longitude := (a - 10) * 20 + c * 2 + (e - 1) * 0.083333333333333333330 +
    0.08333333333333333333 / 2;
  latitude := (b - 10) * 10 + d * 1 + (f - 1) * 0.04166666666666666667 +
    0.04166666666666666667 / 2;
end;

procedure TdmFunc.DistanceFromCoordinate(my_loc: string; latitude, longitude: real;
  var qra, azim: string);
var
  loc: string;
  qra1: string;
  azim1: string;
begin
  my_loc := CompleteLoc(my_loc);

  if not IsLocOK(my_loc) then
    exit;

  loc := VratLokator(latitude, longitude);
  if not IsLocOK(loc) then
    exit;

  VzdalenostAAzimut(my_loc, loc, azim1, qra1);
  qra := qra1;
  azim := azim1;
end;

function TdmFunc.StrToFreq(const freqstr: string): extended;
var
  i: integer;
begin
  Result := 0.0;
  i := 1;
  while i <= Length(freqstr) do
  begin
    Result := (Result * 10) + (Ord(freqstr[i]) - Ord('0'));
    Inc(i);
  end;
  Result := Result / 10000000;
end;

function TdmFunc.RusToLat(Text: string): string;
var
  i: integer;
  ch: string;
begin
   Result:='';
  if UTF8Length(Text) < 1 then exit;
  for i:= 1 to UTF8Length(Text) do
  begin
    ch:= UTF8Copy(Text, i, 1);
    case ch of
        'А': ch:= 'A';
        'Б': ch:= 'B';
        'В': ch:= 'V';
        'Г': ch:= 'G';
        'Д': ch:= 'D';
        'Е': ch:= 'E';
        'Ё': ch:= 'YO';
        'Ж': ch:= 'ZH';
        'З': ch:= 'Z';
        'И': ch:= 'I';
        'Й': ch:= 'I';
        'К': ch:= 'K';
        'Л': ch:= 'L';
        'М': ch:= 'M';
        'Н': ch:= 'N';
        'О': ch:= 'O';
        'П': ch:= 'P';
        'Р': ch:= 'R';
        'С': ch:= 'S';
        'Т': ch:= 'T';
        'У': ch:= 'U';
        'Ф': ch:= 'F';
        'Х': ch:= 'H';
        'Ц': ch:= 'C';
        'Ч': ch:= 'CH';
        'Ш': ch:= 'SH';
        'Щ': ch:= 'SH';
        'Ъ', 'ъ': ch:= '';
        'Ы': ch:= 'I';
        'Ь', 'ь': ch:= ''''; //апостроф вместо мягкого знака.
        'Э': ch:= 'E';
        'Ю': ch:= 'YU';
        'Я': ch:= 'YA';

        'а': ch:= 'a';
        'б': ch:= 'b';
        'в': ch:= 'v';
        'г': ch:= 'g';
        'д': ch:= 'd';
        'е': ch:= 'e';
        'ё': ch:= 'yo';
        'ж': ch:= 'zh';
        'з': ch:= 'z';
        'и': ch:= 'i';
        'й': ch:= 'i';
        'к': ch:= 'k';
        'л': ch:= 'l';
        'м': ch:= 'm';
        'н': ch:= 'n';
        'о': ch:= 'o';
        'п': ch:= 'p';
        'р': ch:= 'r';
        'с': ch:= 's';
        'т': ch:= 't';
        'у': ch:= 'u';
        'ф': ch:= 'f';
        'х': ch:= 'h';
        'ц': ch:= 'c';
        'ч': ch:= 'ch';
        'ш': ch:= 'sh';
        'щ': ch:= 'sh';
        'ы': ch:= 'i';
        'э': ch:= 'e';
        'ю': ch:= 'yu';
        'я': ch:= 'ya';
    end;
    Result:= Result + ch;
  end;
end;

function TdmFunc.RusToEng(Text: string): string;
var
  i: integer;
begin
  for i := 1 to Length(Text) do
  begin
    if UTF8copy(Text, i, 1) = 'а' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('f', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'б' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert(',', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'в' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('d', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'г' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('u', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'д' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('l', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'е' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('t', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ё' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('`', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ж' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert(';', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'з' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('p', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'и' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('b', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'й' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('q', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'к' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('r', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'л' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('k', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'м' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('v', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'н' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('y', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'о' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('j', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'п' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('g', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'р' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('h', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'с' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('c', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'т' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('n', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'у' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('e', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ф' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('a', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'х' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('[', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ц' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('w', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ч' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('x', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ш' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('i', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'щ' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('o', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ъ' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert(']', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ы' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('s', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ь' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('m', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'э' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('''', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'ю' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('.', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'я' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('z', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'А' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('F', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Б' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert(',', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'В' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('D', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Г' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('U', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Д' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('L', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Е' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('T', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ё' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('`', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ж' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert(';', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'З' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('P', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'И' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('B', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Й' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('Q', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'К' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('R', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Л' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('K', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'М' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('V', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Н' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('Y', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'О' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('J', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'П' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('G', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Р' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('H', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'С' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('C', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Т' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('N', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'У' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('E', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ф' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('A', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Х' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('[', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ц' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('W', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ч' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('X', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ш' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('I', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Щ' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('O', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ъ' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert(']', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ы' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('S', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ь' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('M', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Э' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('''', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Ю' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('.', Text, i);
    end;
    if UTF8copy(Text, i, 1) = 'Я' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('Z', Text, i);
    end;
    if UTF8copy(Text, i, 1) = '.' then
    begin
      UTF8Delete(Text, i, 1);
      UTF8Insert('/', Text, i);
    end;
  end;

  Result := Text;
end;

function TdmFunc.RunProgram(progpath, args: string): boolean;
var
  progdir: string;
  process: TProcessUTF8;
begin
  Result := False;
  if not FileExists(progpath) then
    Exit;
  Delay(20);
  progdir := SysToUTF8(ExtractFilePath(progpath));
  UTF8Delete(progdir, UTF8Length(progdir), 1);
  process := TProcessUTF8.Create(nil);
  try
    try
      process.Executable := Trim(progpath + ' ' + args);
      process.Options := [poNoConsole
{$IFDEF WINDOWS}
        , poNewProcessGroup
{$ENDIF}
        ];
      process.Execute;
      Result := True;
    except
    end;
  finally
    process.Destroy;
  end;
end;

function TdmFunc.LatLongToGrid(Lat, Long: real): string;
const
  Letters = 'ABCDEFGHIJKLMNOPQRSTUVWZYZ';
  Numbers = '0123456789';
var
  Lat1, Long1: double;
  i1, i2, i3, i4, i5, i6: integer;
begin
  Lat1 := Lat + 90.0;
  Long1 := Long + 180.0;
  i1 := Trunc(Long1 / 20) + 1;
  i2 := Trunc(Lat1 / 10) + 1;
  i3 := Trunc(Long1 / 2) - (Trunc(Long1 / 20) * 10) + 1;
  i4 := Trunc(Lat1) - (Trunc(Lat1 / 10) * 10) + 1;
  i5 := Trunc(Abs((Trunc(long) - Long) * 60.0) / 5) + 1;
  if (Trunc(Long) mod 2) <> 0 then
    i5 := i5 + 12;
  i6 := Trunc(Abs((Trunc(Lat) - Lat) * 60) / 2.5) + 1;
  LatLongToGrid := Letters[i1] + Letters[i2] + //FN
    Numbers[i3] + Numbers[i4] + //34
    Letters[i5] + Letters[i6]; //MV
end;

procedure TdmFunc.Delay(n: cardinal);
var
  start: cardinal;
begin
  start := GetTickCount;
  repeat
    Application.ProcessMessages;
  until (GetTickCount - start) >= n;
end;

function TdmFunc.ExtractCallsign(call: string): string;
var
  Before: string = '';
  After: string = '';
  Middle: string = '';
  ar: TExplodeArray;
  num: integer = 0;
begin
  Result := call;
  if Pos('/', call) = 0 then
    exit;

  SetLength(ar, 0);
  ar := Explode('/', call);
  num := Length(ar) - 1;

  if num = 2 then
  begin
    Before := ar[0];
    Middle := ar[1];

    if Length(Before) > Length(middle) then
      Result := Before // RA1AA/1/M
    else
      Result := Middle; //KH6/OK2CQR/QRP
  end
  else
  begin
    Before := ar[0];
    After := ar[1];

    if Length(Before) <= 3 then
    begin
      Result := After;
      exit;
    end;

    if Length(After) <= 3 then
    begin
      Result := Before;
      exit;
    end;

  end;
end;


function TdmFunc.CompleteLoc(loc: string): string;
begin
  if Length(loc) = 4 then
    Result := loc + 'LL'
  else
    Result := loc;
end;

function TdmFunc.IsLocOK(Loc: string): boolean;
var
  i: integer;
begin
  Result := True;
  loc := CompleteLoc(loc);
  if Length(Loc) = 6 then
  begin
    for i := 1 to 6 do
    begin
      Loc[i] := UpCase(Loc[i]);
      case i of
        1, 2, 5, 6: case Loc[i] of
            'A'..'X':
            begin
            end
            else
              Result := False;
          end;
        3, 4: case Loc[i] of
            '0'..'9':
            begin
            end
            else
              Result := False;
          end;
      end;
    end;
  end
  else
    Result := False;
end;

function TdmFunc.StringToADIF(tex: string; kp: boolean): string;
begin
  if kp = True then
    Result := ':' + IntToStr(UTF8Length(tex)) + '>' + tex      //За байт
  else
    Result := ':' + IntToStr(Length(tex)) + '>' + tex;        //За два байта
end;

function TdmFunc.GetIDCall(callsign: string): string;
var
  Pole: TExplodeArray;
begin
  Result := callsign;
  if Pos('/', callsign) = 0 then
    exit;
  SetLength(pole, 0);
  pole := Explode('/', callsign);
  if Length(pole[0]) > Length(pole[1]) then  //FJ/G3TXF, RA1AA/1/M etc
    Result := pole[0]
  else
    Result := pole[1];
end;

function TdmFunc.StrToDateFormat(sDate: string): TDateTime;
var
  sdf: string;
  Sep: char;
  Fmt: TFormatSettings;
begin
  sdf := fmt.ShortDateFormat;
  sep := fmt.DateSeparator;
  try
    fmt.ShortDateFormat := 'YYYY:MM:DD';
    fmt.DateSeparator := ':';
    Result := StrToDateTime(sDate, fmt);
  finally
    fmt.ShortDateFormat := sdf;
    fmt.DateSeparator := sep;
  end;
end;

function TdmFunc.Explode(const cSeparator, vString: string): TExplodeArray;
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

function TdmFunc.IsIOTAOK(iota: string): boolean;
var
  c, snr: string;
  i: integer;
begin
  Result := False;
  if Length(iota) <> 6 then
    exit;
  c := copy(iota, 1, 2); //AS,EU,OC,NA,SA,AF
  if (c <> 'AS') and (c <> 'EU') and (c <> 'OC') and (c <> 'NA') and
    (c <> 'SA') and (c <> 'AN') and (c <> 'AF') then
    exit;
  snr := copy(iota, 4, 3);
  for i := 1 to 3 do
    if not (snr[i] in ['0'..'9']) then
    begin
      exit;
    end;
  Result := True;
end;

function TdmFunc.IsFreqOK(freq: string): boolean;
begin
 { if GetBandFromFreq(freq) = 0 then
    Result := False
  else
    Result := True;  }
end;

function TdmFunc.IsModeOK(mode: string): boolean;
var
  cmb: TComboBox;
begin
 { Result := False;
  cmb := TComboBox.Create(nil);
  try
    cmb.Clear;
    InsertModes(cmb);
    if cmb.Items.IndexOf(Mode) > -1 then
      Result := True
  finally
    cmb.Free
  end; }
end;

function TdmFunc.IsTimeOK(time: string): boolean;
var
  imin, ihour: integer;
begin
  imin := 0;
  ihour := 0;
  Result := True;
  if length(time) <> 5 then
    Result := False
  else
  begin
    if not TryStrToInt(time[1] + time[2], ihour) then
      exit;
    if not TryStrToInt(time[4] + time[5], imin) then
      exit;
    if ihour > 24 then
      Result := False;
    if imin > 59 then
      Result := False;
  end;
end;

function TdmFunc.IsDateOK(date: string): boolean;
var
  tmp: string;
  Fmt: TFormatSettings;
begin
  Result := True;
{  tmp := fmt.ShortDateFormat;
  fmt.ShortDateFormat := 'YYYYMMDD';
  fmt.LongDateFormat := 'YYYYMMDD';
  try
    try
      StrToDate(date, fmt);
    except
      Result := True;
    end;
  finally
    fmt.ShortDateFormat := tmp;
  end;     }
end;

function TdmFunc.IsAdifOK(qsodate, time_on, time_off, call, freq,
  mode, rst_s, rst_r, iota, itu, waz, loc, my_loc, band: string): boolean;
var
  w: integer;
begin
 { w := 0;
  Result := True;
  DebugLevel := 0;
  if not IsDateOK(qsodate) then
  begin
    Result := False;
    if DebugLevel >= 1 then
      ShowMessage('Wrong QSO date: ' + qsodate);
    exit;
  end;
  if not IsTimeOK(time_on) then
  begin
    Result := False;
    if DebugLevel >= 1 then
      ShowMessage('Wrong QSO time: ' + time_on);
    exit;
  end;
  if time_off <> '' then
  begin
    if not IsTimeOK(time_off) then
    begin
      Result := False;
      if DebugLevel >= 1 then
        ShowMessage('Wrong QSO time: ' + time_off);
      exit;
    end;
  end;
  if call = '' then
  begin
    Result := False;
    if DebugLevel >= 1 then
      ShowMessage('Wrong QSO call: ' + call);
    exit;
  end;
  if Pos('/', mode) = 0 then
  begin
    if not IsModeOK(mode) then
    begin
      Result := False;
      if DebugLevel >= 1 then
        ShowMessage('Wrong QSO mode: ' + mode);
      exit;
    end;
  end;
  if (freq = '') then
    freq := FreqFromBand(band, mode);
  if not IsFreqOK(freq) then
  begin
    Result := False;
    if DebugLevel >= 1 then
      ShowMessage('Wrong QSO freq: ' + freq);
    exit;
  end;

  if rst_r = '' then
  begin
    Result := False;
    if DebugLevel >= 1 then
      ShowMessage('Wrong QSO rst_r');
    exit;
  end;
  if rst_s = '' then
  begin
    Result := False;
    if DebugLevel >= 1 then
      ShowMessage('Wrong QSO rst_s');
    exit;
  end;

  if waz <> '' then
  begin
    if not TryStrToInt(waz, w) then
    begin
      if DebugLevel >= 1 then
        ShowMessage('Wrong QSO waz zone: ' + waz);
      Result := False;
      exit;
    end;
  end;
  if itu <> '' then
  begin
    if not TryStrToInt(itu, w) then
    begin
      Result := False;
      if DebugLevel >= 1 then
        ShowMessage('Wrong QSO itu: ' + itu);
      exit;
    end;
  end;
  if loc <> '' then
  begin
    loc := CompleteLoc(loc);
    if not IsLocOK(loc) then
    begin
      Result := False;
      if DebugLevel >= 1 then
        ShowMessage('Wrong QSO loc: ' + loc);
      exit;
    end;
  end;
  if my_loc <> '' then
  begin
    my_loc := CompleteLoc(my_loc);
    if not IsLocOK(my_loc) then
    begin
      Result := False;
      if DebugLevel >= 1 then
        ShowMessage('Wrong QSO my loc: ' + my_loc);
      exit;
    end;
  end;
  if (iota <> '') then
  begin
    if not IsIOTAOK(iota) then
    begin
      Result := False;
      if DebugLevel >= 1 then
        ShowMessage('Wrong QSO IOTA: ' + iota);
      exit;
    end;
  end;
end;

function TdmFunc.LetterFromMode(mode: string): string;
begin
  if (mode = 'CW') or (mode = 'CWQ') then
    Result := 'C'
  else
  begin
    if (mode = 'FM') or (mode = 'SSB') or (mode = 'AM') then
      Result := 'F'
    else
      Result := 'D';
  end;    }
end;

procedure TdmFunc.ModifyWAZITU(var waz, itu: string);
begin
  if Pos('-', itu) > 0 then
    itu := copy(itu, 1, Pos('-', itu) - 1);
  if Length(itu) = 1 then
    itu := '0' + itu;
  if Pos('-', waz) > 0 then
    waz := copy(waz, 1, Pos('-', waz) - 1);
  if Length(waz) = 1 then
    waz := '0' + waz;
  waz := copy(waz, 1, 2);
  itu := Copy(itu, 1, 2);
end;

function TdmFunc.RemoveSpaces(S: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(s) do
    if S[i] <> #10 then
      Result := Result + S[i];
end;

function TdmFunc.MyTrim(tex: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(tex) do
  begin
    if not (tex[i] in MyWhiteSpace) then
      Result := Result + tex[i];
  end;
end;

function TdmFunc.ADIFDateToDate(date: string): string;
var
  d, m, y: string;
begin
  if (date = '') then
    Result := ''
  else
  begin
    y := Date[1] + Date[2] + Date[3] + Date[4];
    m := Date[5] + Date[6];
    d := Date[7] + Date[8];
    Result := y + '-' + m + '-' + d;
  end;
end;

end.
