[Setup]
AppId={{EBB023A8-C51A-4432-B382-BE05DE58DF31}
AppName=EWLog
AppVersion=__VERSION__
DefaultDirName={pf}\EWLog
DefaultGroupName=EWLog
UninstallDisplayIcon={app}\ewlog.exe
Compression=lzma2
SolidCompression=yes
OutputDir=__OUTPUT_DIR__
OutputBaseFilename=__OUTPUT_FILENAME__

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]

Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked


[Files]
Source: "__SOURCE_PATH__\__ARCH__\EWLog.exe"; DestDir: "{app}"; DestName: "ewlog.exe"
Source: "__SOURCE_PATH__\__ARCH__\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "__SOURCE_PATH__\__ARCH__\serviceLOG.db"; DestDir: "{userdocs}\..\EWLog\"
Source: "__SOURCE_PATH__\__ARCH__\callbook.db"; DestDir: "{userdocs}\..\EWLog\"

[Icons]
Name: "{group}\EWLog"; Filename: "{app}\EWLog.exe"
Name: "{commondesktop}\EWLog"; Filename: "{app}\EWLog.exe"; Tasks: desktopicon

[Run]
Filename: {app}\ewlog.exe; Description: {cm:LaunchProgram,EWLog}; Flags: nowait showcheckbox

[code]
procedure CurPageChanged(CurPageID: Integer);
var
 ResultCode:Integer;
begin
  if CurPageID = wpWelcome then
  begin
	Exec('taskkill', '/F /IM ewlog.exe', '', 0, ewWaitUntilTerminated, ResultCode);
  end;
end;
