(***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *   Author Vladimir Karpenko (EW8BAK)                                     *
 *                                                                         *
 ***************************************************************************)

unit darkmode_u;

{$mode objfpc}{$H+}

interface

const
  { Values of the SetLog/WinDarkMode key in settings.ini. The numbering follows
    TPreferredAppMode of MetaDarkStyle. }
  dmSystem = 0;
  dmAllowDark = 1;
  dmForceDark = 2;
  dmForceLight = 3;

  dmDefault = dmSystem;

{ Reads SetLog/WinDarkMode from ASettingsFile and applies the colour scheme.

  MetaDarkStyle swaps widgetset classes and hooks a Screen handler, so it only
  affects controls created after the call. It therefore has to run from the
  program body, before Application.Initialize - at that point no data module
  exists and IniSet is not loaded yet, hence reading the ini file directly.

  Dark mode is provided by MetaDarkStyle for Windows 10 1809 and later only;
  on every other platform this is a no-op. }
procedure ApplyDarkMode(const ASettingsFile: string);

{ True when the running platform can actually switch the theme. Used to hide
  the setting where it would do nothing. }
function DarkModeSupported: boolean;

implementation

uses
  SysUtils, IniFiles
  {$IFDEF WINDOWS}
  , uDarkStyleParams, uDarkStyleSchemes, uMetaDarkStyle
  {$ENDIF WINDOWS};

function DarkModeSupported: boolean;
begin
  {$IFDEF WINDOWS}
  Result := True;
  {$ELSE}
  Result := False;
  {$ENDIF WINDOWS}
end;

procedure ApplyDarkMode(const ASettingsFile: string);
{$IFDEF WINDOWS}
var
  INI: TIniFile;
  Mode: integer;
begin
  INI := TIniFile.Create(ASettingsFile);
  try
    Mode := INI.ReadInteger('SetLog', 'WinDarkMode', dmDefault);
  finally
    INI.Free;
  end;

  case Mode of
    dmAllowDark: PreferredAppMode := pamAllowDark;
    dmForceDark: PreferredAppMode := pamForceDark;
    dmForceLight: PreferredAppMode := pamForceLight;
    else
      PreferredAppMode := pamDefault;
  end;

  if Mode = dmForceDark then
    ApplyMetaDarkStyle(DefaultDark);
end;
{$ELSE}
begin
  { nothing to do - MetaDarkStyle is Windows only }
end;
{$ENDIF WINDOWS}

end.
