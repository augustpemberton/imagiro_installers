#define Year GetDateTimeString("yyyy","","")

[Setup]
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
AppName={#PluginName}
OutputBaseFilename={#PluginName}
AppCopyright=Copyright (C) {#Year} {#Publisher}
AppPublisher={#Publisher}
AppVersion={#Version}
DefaultDirName="{commoncf64}\VST3\{#PluginName}.vst3"
DisableDirPage=yes
LicenseFile="..\License.txt"
UninstallFilesDir="{commonappdata}\{#PluginName}\uninstall"
Compression=zip
SolidCompression=yes
LZMAUseSeparateProcess=yes
LZMANumBlockThreads=6

[UninstallDelete]
Type: filesandordirs; Name: "{commoncf64}\VST3\{#PluginName}Data"

[Files]
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\VST3\{#PluginName}.vst3\*"; DestDir: "{commoncf64}\VST3\{#PluginName}.vst3\"; Excludes: *.ilk; Flags: ignoreversion recursesubdirs;
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\Standalone\{#PluginName}.exe"; DestDir: "{commonpf}\{#Publisher}\{#PluginName}"; Flags: ignoreversion recursesubdirs;
Source: "..\..\resources\user\*"; DestDir: "{userappdata}\{#Publisher}\{#PluginName}\"; Flags: ignoreversion recursesubdirs skipifsourcedoesntexist;
Source: "..\..\resources\system\*"; DestDir: "{commonappdata}\{#Publisher}\{#PluginName}\"; Flags: ignoreversion recursesubdirs skipifsourcedoesntexist;

[Icons]
Name: "{group}\{#ProjectName}"; Filename: "{commonpf}\{#Publisher}\{#PluginName}\{#PluginName}.exe";