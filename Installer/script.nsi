# INCLUDES
!include MUI2.nsh ;Modern interface
!include LogicLib.nsh ;nsDialogs
!include "DotNet.nsh"

# INIT
Name "OnTopReplica 3.5.2"
InstallDir "$PROGRAMFILES\OnTopReplica"
OutFile "OnTopReplica-Setup.exe"
RequestExecutionLevel admin

# REFS
!define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\OnTopReplica"
!define START_LINK_DIR "$STARTMENU\Programs\OnTopReplica"
!define START_LINK_RUN "$STARTMENU\Programs\OnTopReplica\OnTopReplica.lnk"
!define START_LINK_UNINSTALLER "$STARTMENU\Programs\OnTopReplica\Uninstall OnTopReplica.lnk"
!define UNINSTALLER_NAME "OnTopReplica-Uninstall.exe"
!define WEBSITE_LINK "http://www.klopfenstein.net/lorenz.aspx/ontopreplica"

# GRAPHICS
!define MUI_ICON "..\OriginalAssets\new-flat-icon.ico"
!define MUI_UNICON "..\OriginalAssets\new-flat-icon.ico"
!define MUI_HEADERIMAGE "..\OriginalAssets\NSI-Banner.bmp"
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "..\OriginalAssets\NSI-Header.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "..\OriginalAssets\NSI-Header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\OriginalAssets\NSI-Banner.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "..\OriginalAssets\NSI-Banner.bmp"

# TEXT AND SETTINGS
!define MUI_PAGE_HEADER_TEXT "OnTopReplica"

!define MUI_FINISHPAGE_RUN "$INSTDIR\OnTopReplica.exe"
;!define MUI_FINISHPAGE_RUN_TEXT "Run OnTopReplica now."

;Do not skip to finish automatially
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

# PAGE DEFINITIONS
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# LANGUAGES
!insertmacro MUI_LANGUAGE "English"

# INITIALIZATION AND ERROR CHECKING
Function .onInit
  ${HasDotNet4} $R0
  ${If} $R0 == 1
	;noop
  ${Else}
	MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "Microsoft .NET Framework 4.0 appears not to be installed.$\n$\nOnTopReplica requires .NET 4.0 to run: please install it before running the installer.$\n$\nDo you wish to proceed anyway?" IDOK proceedAnyway
		Abort ".NET 4.0 required to install"
	proceedAnyway:
  ${EndIf}
FunctionEnd

# CALLBACKS
Function RegisterApplication
	;Register uninstaller into Add/Remove panel (for local user only)
	WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayName" "OnTopReplica"
	WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayIcon" "$\"$INSTDIR\OnTopReplica.exe$\""
	WriteRegStr HKCU "${REG_UNINSTALL}" "Publisher" "Lorenz Cuno Klopfenstein"
	WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayVersion" "3.4"
	WriteRegDWord HKCU "${REG_UNINSTALL}" "EstimatedSize" 992 ;KB
	WriteRegStr HKCU "${REG_UNINSTALL}" "HelpLink" "${WEBSITE_LINK}"
	WriteRegStr HKCU "${REG_UNINSTALL}" "URLInfoAbout" "${WEBSITE_LINK}"
	WriteRegStr HKCU "${REG_UNINSTALL}" "InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKCU "${REG_UNINSTALL}" "InstallSource" "$\"$EXEDIR$\""
	WriteRegDWord HKCU "${REG_UNINSTALL}" "NoModify" 1
	WriteRegDWord HKCU "${REG_UNINSTALL}" "NoRepair" 1
	WriteRegStr HKCU "${REG_UNINSTALL}" "UninstallString" "$\"$INSTDIR\${UNINSTALLER_NAME}$\""
	WriteRegStr HKCU "${REG_UNINSTALL}" "Comments" "Uninstalls OnTopReplica."
	
	;Links
	SetShellVarContext current
	CreateDirectory "${START_LINK_DIR}"
	CreateShortCut "${START_LINK_RUN}" "$INSTDIR\OnTopReplica.exe"
	CreateShortCut "${START_LINK_UNINSTALLER}" "$INSTDIR\${UNINSTALLER_NAME}"
	
	;Fix link with AppID
	ExecWait '"$INSTDIR\PostInstaller.exe" "${START_LINK_RUN}" "LorenzCunoKlopfenstein.OnTopReplica.MainForm"' $0
	DetailPrint "Post installation shortcut fix (returned $0)."
FunctionEnd

Function un.DeregisterApplication
	;Deregister uninstaller from Add/Remove panel
	DeleteRegKey HKCU "${REG_UNINSTALL}"
	
	;Start menu links
	SetShellVarContext current
	RMDir /r "${START_LINK_DIR}"
FunctionEnd

# INSTALL SECTIONS
Section "!OnTopReplica" OnTopReplica
	SectionIn RO
	
	SetOutPath $INSTDIR
	SetOverwrite on
	
	;Ensure that old VistaControls.dll is removed
	Delete "$INSTDIR\VistaControls.dll"
	
	;Main installation
	File "..\src\OnTopReplica\bin\Release\OnTopReplica.exe"
	File "..\src\OnTopReplica\bin\Release\OnTopReplica.exe.config"
	File "..\src\OnTopReplica\bin\Release\WindowsFormsAero.dll"
	
	;Text stuff
	File "..\src\OnTopReplica\bin\Release\CREDITS.txt"
	File "..\src\OnTopReplica\bin\Release\LICENSE.txt"
	
	;Post installer
	File "..\src\PostInstaller\bin\Release\PostInstaller.exe"
	File "..\src\PostInstaller\bin\Release\PostInstaller.exe.config"
	
	;Install localization files
	SetOutPath "$INSTDIR\it"
	File "..\src\OnTopReplica\bin\Release\it\OnTopReplica.resources.dll"
	SetOutPath "$INSTDIR\cs"
	File "..\src\OnTopReplica\bin\Release\cs\OnTopReplica.resources.dll"
	SetOutPath "$INSTDIR\da"
	File "..\src\OnTopReplica\bin\Release\da\OnTopReplica.resources.dll"
	SetOutPath "$INSTDIR\de"
	File "..\src\OnTopReplica\bin\Release\de\OnTopReplica.resources.dll"
	SetOutPath "$INSTDIR\es"
	File "..\src\OnTopReplica\bin\Release\es\OnTopReplica.resources.dll"
	SetOutPath "$INSTDIR\pl"
	File "..\src\OnTopReplica\bin\Release\pl\OnTopReplica.resources.dll"
		
	;Uninstaller
	WriteUninstaller "$INSTDIR\${UNINSTALLER_NAME}"
	Call RegisterApplication
SectionEnd

Section "Uninstall"
	;Remove whole directory (no data is stored there anyway)
	RMDir /r "$INSTDIR"
	
	;Remove roaming AppData folder (settings and logs)
	RMDir /r "$APPDATA\OnTopReplica"
	
	;Remove uninstaller
	Call un.DeregisterApplication
SectionEnd
