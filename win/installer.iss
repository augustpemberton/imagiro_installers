#define Year GetDateTimeString("yyyy","","")

[Setup]
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible
AppName={#PluginName}
OutputBaseFilename={#PluginName}-{#Version}
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

[Types]
Name: "full"; Description: "Full installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "vst3"; Description: "VST3 Plugin"; Types: full custom
Name: "aax"; Description: "AAX Plugin"; Types: full custom
Name: "standalone"; Description: "Standalone Application"; Types: full custom

[UninstallDeletescc]
Type: filesandordirs; Name: "{app}\{#PluginName}.vst3"
Type: filesandordirs; Name: "{commonpf}\{#Publisher}\{#PluginName}"
Type: filesandordirs; Name: "{userappdata}\{#Publisher}\{#ResourceName}"
Type: filesandordirs; Name: "{commonappdata}\{#Publisher}\{#ResourceName}"
Type: filesandordirs; Name: "{commonpf64}\Common Files\Avid\Audio\Plug-Ins\{#PluginName}.aaxplugin"

[Files]
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\VST3\{#PluginName}.vst3\*"; DestDir: "{app}\"; Flags: ignoreversion recursesubdirs; Excludes: *.ilk; Components: vst3
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\AAX\{#PluginName}.aaxplugin\*"; DestDir: "{commonpf64}\Common Files\Avid\Audio\Plug-Ins\{#PluginName}.aaxplugin\"; Flags: ignoreversion recursesubdirs; Excludes: *.ilk; Components: aax
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\Standalone\{#PluginName}.exe"; DestDir: "{commonpf}\{#Publisher}\{#PluginName}"; Flags: ignoreversion recursesubdirs; Components: standalone
Source: "..\..\resources\user\*"; DestDir: "{userappdata}\{#Publisher}\{#ResourceName}\"; Flags: ignoreversion recursesubdirs skipifsourcedoesntexist; Permissions: everyone-full
Source: "..\..\resources\system\*"; DestDir: "{commonappdata}\{#Publisher}\{#ResourceName}\"; Flags: ignoreversion recursesubdirs skipifsourcedoesntexist; Permissions: everyone-full

[Icons]
Name: "{group}\{#PluginName}"; Filename: "{commonpf}\{#Publisher}\{#PluginName}\{#PluginName}.exe"; Components: standalone