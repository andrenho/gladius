#
# Set version
#
!define PRODUCT_VERSION "0.0.1"

#
# Set compressor
#
SetCompressor /SOLID lzma
#SetCompressor zlib

#
# Modern UI
#
!include "MUI.nsh"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\license.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_INSTFILES

#
# Languages avaliable
#
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "PortugueseBR"
Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

#
# Installed data
Name "Gladius"

#DirText "Choose a installation path"
InstallDir $PROGRAMFILES\Gladius

OutFile "Gladius-win32-${PRODUCT_VERSION}.exe"

ShowInstDetails show
ShowUnInstDetails show

#
# Gladius section
#
Section "Gladius ${PRODUCT_VERSION}"

	#
	# Files
	#
	SetOverwrite off
#	SetOutPath $DOCUMENTS\bibliomori
#	File "..\db\*"

	SetOverwrite ifnewer
	SetOutPath $INSTDIR
	File "..\gladius.bat"
	File "..\gladius.rb"
	File "..\license.txt"
	File "..\version.txt"

	SetOutPath $INSTDIR\i18n
	File "..\i18n\*"

	SetOutPath $INSTDIR\img
	File "..\img\*"

	SetOutPath $INSTDIR\src
	File "..\src\*.rb"

	SetOutPath $INSTDIR\bibles
	File "..\bibles\kjv.bible"

	#
	# Create initialization files
	#
	FileOpen $0 $INSTDIR\win32.rb w
	FileWrite $0 "INSTDIR='$INSTDIR'$\n"
	FileWrite $0 "HOMEDIR='$DOCUMENTS/Gladius/'"
	FileClose $0

	FileOpen $0 $INSTDIR\gladius.bat a
	FileWrite $0 "SET PATH=$INSTDIR\win32;$INSTDIR\win32\bin;$INSTDIR\win32\gtk\bin;$INSTDIR\win32\gtk\lib$\n"
	FileWrite $0 "SET RUBYOPT=$\n"
	FileWrite $0 "start rubyw.exe gladius.rb"
	FileClose $0

	#
	# Shortcuts
	#
	SetOutPath $INSTDIR
	CreateDirectory "$SMPROGRAMS\Gladius"
	CreateShortCut "$SMPROGRAMS\Gladius\Gladius ${PRODUCT_VERSION}.lnk" "$INSTDIR\gladius.bat" \
		"" "$INSTDIR\img\stock_book_yellow-16.ico"
	CreateShortCut "$SMPROGRAMS\Gladius\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

SectionEnd

#
# Ruby section
#
Section "Required libraries (Ruby + GTK + SQLite)"
	SetOutPath $INSTDIR\win32
	File /nonfatal /r /x "*.swp" /x "Gladius-win32-*.exe" /x "*.nsi" /x ".svn" /x "*.bz2" "*"
SectionEnd

#
# Uninstaller
#
Section "Uninstall"
	RMDir /r $INSTDIR
	RMDir /r $SMPROGRAMS\Gladius
SectionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to remove $(^Name) completely? (your personal files will not be removed)" IDYES +2
  Abort
FunctionEnd

Section -Post
	WriteUninstaller $INSTDIR\Uninstall.exe
SectionEnd
