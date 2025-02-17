#define Year GetDateTimeString("yyyy","","")

[Setup]
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible
AppName={#PluginName}
OutputBaseFilename={#ProductSlug}-win-{#Version}
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
#if IncludeAAX == "true"
Name: "aax"; Description: "AAX Plugin"; Types: full custom
#endif
Name: "standalone"; Description: "Standalone Application"; Types: full custom

[UninstallDelete]
Type: filesandordirs; Name: "{app}\{#PluginName}.vst3"
Type: filesandordirs; Name: "{commonpf}\{#Publisher}\{#PluginName}"
Type: filesandordirs; Name: "{userappdata}\{#Publisher}\{#ResourceName}"
Type: filesandordirs; Name: "{commonappdata}\{#Publisher}\{#ResourceName}"
#if IncludeAAX == "true"
Type: filesandordirs; Name: "{commonpf64}\Common Files\Avid\Audio\Plug-Ins\{#PluginName}.aaxplugin"
#endif

[InstallDelete]
; Add this line to remove the incorrectly created directory
Type: filesandordirs; Name: "{commonpf}\{#Publisher}\{#PluginName}\{#PluginName}.exe"
Type: filesandordirs; Name: "{app}\{#PluginName}.vst3"
Type: filesandordirs; Name: "{commonpf}\{#Publisher}\{#PluginName}"
#if IncludeAAX == "true"
Type: filesandordirs; Name: "{commonpf64}\Common Files\Avid\Audio\Plug-Ins\{#PluginName}.aaxplugin"
#endif

[Files]
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\VST3\{#PluginName}.vst3\*"; DestDir: "{app}\"; Flags: ignoreversion recursesubdirs; Excludes: *.ilk; Components: vst3
#if IncludeAAX == "true"
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\AAX\{#PluginName}.aaxplugin\*"; DestDir: "{commonpf64}\Common Files\Avid\Audio\Plug-Ins\{#PluginName}.aaxplugin\"; Flags: ignoreversion recursesubdirs; Excludes: *.ilk; Components: aax
#endif
Source: "..\..\build\{#ProjectName}_artefacts\{#BuildType}\Standalone\{#PluginName}.exe"; DestDir: "{commonpf}\{#Publisher}\{#PluginName}"; Flags: ignoreversion recursesubdirs; Components: standalone
        Source: "..\..\resources\user\*"; DestDir: "{userappdata}\{#Publisher}\{#ResourceName}\"; Flags: ignoreversion recursesubdirs skipifsourcedoesntexist; Permissions: everyone-full
Source: "..\..\resources\system\*"; DestDir: "{commonappdata}\{#Publisher}\{#ResourceName}\"; Flags: ignoreversion recursesubdirs skipifsourcedoesntexist; Permissions: everyone-full

[Icons]
Name: "{autoprograms}\{#Publisher}\{#PluginName}"; Filename: "{commonpf}\{#Publisher}\{#PluginName}\{#PluginName}.exe"; Components: standalone