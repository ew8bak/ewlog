[Setup]
AppId={{EBB023A8-C51A-4432-B382-BE05DE58DF31}
AppName=EWLog
AppVersion=1.0.6
DefaultDirName={pf}\EWLog
DefaultGroupName=EWLog
UninstallDisplayIcon={app}\EWLog.exe
Compression=lzma2
SolidCompression=yes
OutputDir=D:\ewlog_win\BUILD\
OutputBaseFilename=setup_ewlog_1_0_6_x86

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"


[Tasks]
; Создание иконки на рабочем столе
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked


[Files]
Source: "D:\ewlog_win\BUILD\x86\EWLog.exe"; DestDir: "{app}"; DestName: "EWLog.exe"
Source: "D:\ewlog_win\BUILD\x86\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
;Source: "D:\ewlog_win\BUILD\x86\settings.ini"; DestDir: "{userdocs}\..\EWLog"
Source: "D:\ewlog_win\BUILD\x86\serviceLOG.db"; DestDir: "{userdocs}\..\EWLog\"
Source: "D:\ewlog_win\BUILD\x86\callbook.db"; DestDir: "{userdocs}\..\EWLog\"
Source: "D:\ewlog_win\BUILD\x86\updates\*"; DestDir: "{userdocs}\..\EWLog\updates\"; Flags: ignoreversion recursesubdirs createallsubdirs


[Icons]
Name: "{group}\EWLog"; Filename: "{app}\EWLog.exe"
Name: "{commondesktop}\EWLog"; Filename: "{app}\EWLog.exe"; Tasks: desktopicon
