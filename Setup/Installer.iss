; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppBinDir "..\bin\x64\Release\net461"
#define ServerBinDir "..\..\audiobookshelf\dist\win"

#define MyAppName "Audiobookshelf"
#define MyAppVersion "v2.7.1.2"
#define MyAppPublisher "Audiobookshelf"
#define MyAppURL "https://www.audiobookshelf.org/"
#define MyAppExeName "AudiobookshelfTray.exe"
#define ServerExeName "audiobookshelf.exe"


[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{398D8732-4648-4C71-A30C-C0688D46BB13}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
PrivilegesRequired=lowest
OutputBaseFilename=AudiobookshelfInstaller
SetupIconFile=..\Resources\AppIcon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#MyAppBinDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppBinDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#ServerBinDir}\{#ServerExeName}"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall

[Registry]
; Don't delete datadir in HKCU during uninstall - we want to keep the data dir if the user reinstalls
Root: HKCU; Subkey: "Software\{#MyAppName}"; ValueType: string; ValueName: "DataDir"; ValueData: "{code:GetDataDir}"; 
Root: HKCU; Subkey: "Software\{#MyAppName}"; ValueType: string; ValueName: "InstallDir"; ValueData: "{app}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\{#MyAppName}"; ValueType: string; ValueName: "AppVersion"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletevalue

[Code]
var
  DataDirPage: TInputDirWizardPage;
const
  WM_CLOSE = $0010;

function IsRunningInstanceClosed(): Boolean;
var
  Wnd: HWND;
  label return;
begin
  Wnd := FindWindowByWindowName('AudiobookshelfTray');
  if Wnd <> 0 then
  begin
    if MsgBox('Audiobookshelf is already running.'#10'OK to close it, Cancel to exit setup.', mbInformation, MB_OKCANCEL) = IDCANCEL then
    begin
      Result := False;
      goto return;
    end;
    SendMessage(Wnd, WM_CLOSE, 0, 0);
  end;
  Result := True;
  return:  
end;

function InitializeSetup(): Boolean;
var
  Version: TWindowsVersion;
  label return;
begin
  GetWindowsVersionEx(Version);
  if (not IsWin64) or (Version.Major < 10) then
  begin
    MsgBox('{#MyAppName} requires 64-bit Windows 10 or later.', mbError, MB_OK);
    Result := False;
    goto return;
  end;

  if not IsRunningInstanceClosed() then
  begin
    Result := False;
    goto return;
  end;

  Result := True;
  return:
end;

function InitializeUninstall(): Boolean;
label return;
begin
  if not IsRunningInstanceClosed() then
  begin
    Result := False;
    goto return;
  end;

  Result := True;
  return:
end;

procedure InitializeWizard;
var
    DataDir: String;
begin
    DataDirPage := CreateInputDirPage(wpSelectDir, 'Select Data Directory', 'Where should Audiobookshelf store its data?', 'Select the directory in which Audiobookshelf should store its data, then click Next.', False, '');
    DataDirPage.Add('');
    DataDirPage.Values[0] := ExpandConstant('{localappdata}\Audiobookshelf');
    if RegQueryStringValue(HKCU, 'Software\Audiobookshelf', 'DataDir', DataDir) then
    begin
        DataDirPage.Values[0] := DataDir;
    end;        
end;

function GetDataDir(Param: String): String;
begin
    Result := DataDirPage.Values[0];
end;