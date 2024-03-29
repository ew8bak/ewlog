[Setup]
AppId={{EBB023A8-C51A-4432-B382-BE05DE58DF31}
AppName=EWLog
AppVersion=1.2.3
DefaultDirName={pf}\EWLog
DefaultGroupName=EWLog
UninstallDisplayIcon={app}\ewlog.exe
Compression=lzma2
SolidCompression=yes
OutputDir=C:\Users\karpe\Desktop\BUILD\
OutputBaseFilename=setup_ewlog_1_2_3_x86_XP

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
; �������� ������ �� ������� �����
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked


[Files]
Source: "C:\Users\karpe\Desktop\BUILD\x86\EWLog.exe"; DestDir: "{app}"; DestName: "ewlog.exe"
Source: "C:\Users\karpe\Desktop\BUILD\x86\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\Users\karpe\Desktop\BUILD\x86\serviceLOG.db"; DestDir: "{userdocs}\..\EWLog\"
Source: "C:\Users\karpe\Desktop\BUILD\x86\callbook.db"; DestDir: "{userdocs}\..\EWLog\"

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