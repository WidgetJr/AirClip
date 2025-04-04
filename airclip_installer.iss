; AirClip Inno Setup Script

[Setup]
AppName=AirClip
AppVersion=1.0.0
DefaultDirName={autopf}\AirClip
DefaultGroupName=AirClip
UninstallDisplayIcon={app}\airclip.exe
OutputDir=.\installer
OutputBaseFilename=AirClipInstaller
Compression=lzma
SolidCompression=yes
WizardStyle=modern
DisableWelcomePage=no

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\AirClip"; Filename: "{app}\airclip.exe"
Name: "{commondesktop}\AirClip"; Filename: "{app}\airclip.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Run]
Filename: "{app}\airclip.exe"; Description: "Launch AirClip"; Flags: nowait postinstall skipifsilent
