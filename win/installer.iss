#define Year GetDateTimeString("yyyy","","")

[Setup]
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible
AppName={#PluginName}
OutputBaseFilename={#PluginName}
AppCopyright=Copyright (C) {#Year} {#Publisher}
AppPublisher={#Publisher}
AppVersion={#Version}
DefaultDirName="{commoncf64}\VST3\{#PluginName}.vst3"
DisableDirPage=no
LicenseFile="..\License.txt"
UninstallFilesDir="{commonappdata}\{#PluginName}\uninstall"
Compression=zip
SolidCompression=yes
LZMAUseSeparateProcess=yes
LZMANumBlockThreads=6

[UninstallDelete]
Type: filesandordirs; Name: "{app}\{#PluginName}.vst3"
Type: filesandordirs; Name: "{commonpf}\{#Publisher}\{#PluginName}"
Type: filesandordirs; Name: "{userappdata}\{#Publisher}\{#ResourceName}"
Type: filesandordirs; Name: "{commonappdata}\{#Publisher}\{#ResourceName}"

[Files]
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\VST3\{#PluginName}.vst3\*"; DestDir: "{app}\"; Flags: ignoreversion recursesubdirs; Excludes: *.ilk;
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\Standalone\{#PluginName}.exe"; DestDir: "{commonpf}\{#Publisher}\{#PluginName}"; Flags: ignoreversion recursesubdirs;
Source: "..\..\resources\user\*"; DestDir: "{userappdata}\{#Publisher}\{#ResourceName}\"; Flags: ignoreversion recursesubdirs skipifsourcedoesntexist;
Source: "..\..\resources\system\*"; DestDir: "{commonappdata}\{#Publisher}\{#ResourceName}\"; Flags: ignoreversion recursesubdirs skipifsourcedoesntexist;

[Icons]
Name: "{group}\{#PluginName}"; Filename: "{commonpf}\{#Publisher}\{#PluginName}\{#PluginName}.exe";