Name "Orange"
Icon OrangeInstall.ico
UninstallIcon OrangeInstall.ico

!ifndef ORANGEDIR
	!define ORANGEDIR orange
!endif

!define INCLUDEMSVCDLL ; by default

!ifdef COMPLETE
  !ifndef OUTFILENAME
		OutFile "Orange-complete.exe"
	!endif
	!define INCLUDEPYTHON
	!define INCLUDEPYTHONWIN
	!define INCLUDEPYQT
	!define INCLUDEPYQWT
	!define INCLUDENUMERIC
	!define INCLUDEQT
	!define INCLUDESCRIPTDOC
	!define INCLUDEDATASETS
!else
!ifdef STANDARD		; orange (*.py *.pyd) and doc only
  !ifndef OUTFILENAME
		OutFile "Orange-standard.exe"
	!endif
	!define INCLUDESCRIPTDOC
!endif
!endif

!define PYFILENAME python-${NPYVER}.msi
!define PYWINFILENAME pywin32-210.win32-py${NPYVER}.exe

; !define INCLUDEGENOMICS

!ifdef OUTFILENAME
OutFile ${OUTFILENAME}
!else
OutFile "orange-temp.exe"
!endif

!include "Sections.nsh"
!include "LogicLib.nsh"

licensedata license.txt
licensetext "Acknowledgments and License Agreement"

; InstallDirRegKey HKEY_LOCAL_MACHINE "SOFTWARE\Python\PythonCore\${NPYVER}\PythonPath\Orange" ""

AutoCloseWindow true
ShowInstDetails nevershow
SilentUninstall silent

Var PythonDir
Var PythonOnDesktop
Var WhatsDownFile
Var SingleUser
Var MissingModules

Page license
Page directory
Page components
Page instfiles

!ifdef INCLUDEPYQT | INCLUDEPYQWT | INCLUDENUMERIC

	ComponentText "Components" "Select components to install" "(The Python stuff that you already have is hidden)"

	Subsection /e "!" SSPYTHON

	!ifdef INCLUDEPYQT
		Section "PyQt" SECPYQT
			SetOutPath $PythonDir\lib\site-packages
			File /r 3rdparty-${PYVER}\pyqt\*.*
		SectionEnd
	!endif

	!ifdef INCLUDEPYQWT
		Section "PyQwt" SECPYQWT
			SetOutPath $PythonDir\lib\site-packages
			File /r 3rdparty-${PYVER}\qwt
		SectionEnd
	!endif

	!ifdef INCLUDENUMERIC
		Section "Numeric Python" SECNUMERIC
			SetOutPath $PythonDir\lib\site-packages
			File /r 3rdparty-${PYVER}\numeric
			File various\Numeric.pth
		SectionEnd
	!endif

	SubsectionEnd
	
!else ; no Python modules included with this installation
	ComponentText "Components" "" "Select components to install"
!endif


!ifdef INCLUDEQT
	Section "Qt 2.2 non-commercial" SECQT
		SetOutPath $PythonDir\lib\site-packages
		File various\qt-mt230nc.dll

		SetOutPath $INSTDIR
		File various\QT-LICENSE.txt
	SectionEnd
!endif

!ifdef INCLUDEMSVCDLL
	Section "MSVCP60.DLL" SECMSVCP60DLL
		SetOutPath $INSTDIR
		File various\MSVCP60.DLL
	SectionEnd
!endif

Section ""
	SetOutPath $INSTDIR ; just to make sure it exists
	FileOpen $WhatsDownFile $INSTDIR\whatsdown.txt w
    
	!include ${INCLUDEPREFIX}_base.inc
SectionEnd

Section "Orange Widgets and Canvas" SECCANVAS
	!include ${INCLUDEPREFIX}_widgets.inc
	!include ${INCLUDEPREFIX}_canvas.inc

	SetOutPath $INSTDIR\icons
	File Orange.ico
	SetOutPath $INSTDIR\OrangeCanvas\icons
	File OrangeOWS.ico
SectionEnd


!ifdef INCLUDEGENOMICS
Section "Genomic Data" SECGENOMIC
	!include ${INCLUDEPREFIX}_genomics.inc
    
	SetOutPath $INSTDIR\doc
	File "various\Orange Genomics.pdf"

	SetOutPath $INSTDIR
	${If} $SingleUser = 0
	    SetShellVarContext all
	${Else}
	    SetShellVarContext current	   
	${Endif}

	CreateDirectory "$SMPROGRAMS\Orange"
	CreateShortCut "$SMPROGRAMS\Orange\Orange Widgets For Functional Genomics.lnk" "$INSTDIR\doc\Orange Genomics.pdf"
;	SetShellVarContext current

	SetOutPath "$INSTDIR\OrangeCanvas"
	File various\bi-visprog\*.tab
	File various\bi-visprog\*.ows
SectionEnd
!endif
	

!ifdef INCLUDESCRIPTDOC
Section "Documentation" SECDOC
            	!include ${INCLUDEPREFIX}_doc.inc

	SetOutPath $INSTDIR\doc
	File "various\Orange White Paper.pdf"
	File "various\Orange Widgets White Paper.pdf"

;   make shortcuts for all users	
	${If} $SingleUser = 0
	    SetShellVarContext all
	${Else}
	    SetShellVarContext current	   
	${Endif}

	CreateDirectory "$SMPROGRAMS\Orange"
	CreateShortCut "$SMPROGRAMS\Orange\Orange White Paper.lnk" "$INSTDIR\doc\Orange White Paper.pdf"
	CreateShortCut "$SMPROGRAMS\Orange\Orange Widgets White Paper.lnk" "$INSTDIR\doc\Orange Widgets White Paper.pdf"
	CreateShortCut "$SMPROGRAMS\Orange\Orange for Beginners.lnk" "$INSTDIR\doc\ofb\default.htm"
	CreateShortCut "$SMPROGRAMS\Orange\Orange Modules Reference.lnk" "$INSTDIR\doc\modules\default.htm"
	CreateShortCut "$SMPROGRAMS\Orange\Orange Reference Guide.lnk" "$INSTDIR\doc\reference\default.htm"
;	SetShellVarContext current
SectionEnd
!endif
  
!ifdef INCLUDEDATASETS
Section "Datasets" SECDATASETS
	SetOutPath $INSTDIR\doc\datasets
	File ${ORANGEDIR}\doc\datasets\*
SectionEnd
!endif


!ifdef INCLUDESOURCE
	Section "Orange Source"
		SetOutPath $INSTDIR
		File /r ${ORANGEDIR}\source
	SectionEnd
!endif

Section ""
	${Unless} ${SectionIsSelected} ${SECDOC}
		FileWrite $WhatsDownFile "-Orange Documentation"
	${EndIf}
	${Unless} ${SectionIsSelected} ${SECCANVAS}
		FileWrite $WhatsDownFile "-Orange Widgets"
	${EndIf}
!ifdef INCLUDEDATASETS
	${Unless} ${SectionIsSelected} ${SECDATASETS}
		FileWrite $WhatsDownFile "-Datasets"
	${EndIf}
!endif
	
	FileClose $WhatsDownFile
	
	SetOutPath $INSTDIR
	
;   make shortcuts for all users	
	${If} $SingleUser = 0
	    SetShellVarContext all
	${Else}
	    SetShellVarContext current	   
	${Endif}
	CreateDirectory "$SMPROGRAMS\Orange"
	CreateShortCut "$SMPROGRAMS\Orange\Orange.lnk" "$INSTDIR\"
	CreateShortCut "$SMPROGRAMS\Orange\Uninstall Orange.lnk" "$INSTDIR\uninst.exe"

	SetOutPath $INSTDIR\OrangeCanvas
	CreateShortCut "$DESKTOP\Orange Canvas.lnk" "$INSTDIR\OrangeCanvas\orngCanvas.pyw" "" $INSTDIR\icons\Orange.ico 0
	CreateShortCut "$SMPROGRAMS\Orange\Orange Canvas.lnk" "$INSTDIR\OrangeCanvas\orngCanvas.pyw" "" $INSTDIR\icons\Orange.ico 0
;	SetShellVarContext current

	${If} $SingleUser = 0
		WriteRegStr HKLM "SOFTWARE\Python\PythonCore\${NPYVER}\PythonPath\Orange" "" "$INSTDIR;$INSTDIR\OrangeWidgets;$INSTDIR\OrangeCanvas"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Orange" "DisplayName" "Orange (remove only)"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Orange" "UninstallString" '"$INSTDIR\uninst.exe"'
	${Else}
		WriteRegStr HKCU "SOFTWARE\Python\PythonCore\${NPYVER}\PythonPath\Orange" "" "$INSTDIR;$INSTDIR\OrangeWidgets;$INSTDIR\OrangeCanvas"
		WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Orange" "DisplayName" "Orange (remove only)"
		WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Orange" "UninstallString" '"$INSTDIR\uninst.exe"'
	${Endif}
	
	;ows icon and association, schema-click launch
	WriteRegStr HKEY_CLASSES_ROOT ".ows" "" "OrangeCanvas"
	WriteRegStr HKEY_CLASSES_ROOT "OrangeCanvas\DefaultIcon" "" "$INSTDIR\OrangeCanvas\icons\OrangeOWS.ico"
	WriteRegStr HKEY_CLASSES_ROOT "OrangeCanvas\Shell\Open\Command\" "" '$PythonDir\python.exe $INSTDIR\orangeCanvas\orngCanvas.pyw "%1"'

	WriteUninstaller "$INSTDIR\uninst.exe"
SectionEnd  

Section Uninstall
	MessageBox MB_YESNO "Are you sure you want to remove Orange?$\r$\n$\r$\nThis won't remove any 3rd party software possibly installed with Orange, such as Python or Qt,$\r$\n$\r$\nbut make sure you have not left any of your files in Orange's directories!" IDNO abort
	RmDir /R "$INSTDIR"
	${If} $SingleUser = 0
	    SetShellVarContext all
	${Else}
	    SetShellVarContext current	   
	${Endif}
	RmDir /R "$SMPROGRAMS\Orange"
;	SetShellVarContext current
	
	ReadRegStr $PythonDir HKLM Software\Python\PythonCore\${NPYVER}\InstallPath ""
	${If} $PythonDir != ""
		DeleteRegKey HKLM "SOFTWARE\Python\PythonCore\${NPYVER}\PythonPath\Orange"
		DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Orange"
	${Else}
		DeleteRegKey HKCU "SOFTWARE\Python\PythonCore\${NPYVER}\PythonPath\Orange"
		DeleteRegKey HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Orange"
	${Endif}
	
	Delete "$DESKTOP\Orange Canvas.lnk"

	; remove owc icon and file type associations
	DeleteRegKey HKEY_CLASSES_ROOT ".ows"
	DeleteRegKey HKEY_CLASSES_ROOT "OrangeCanvas"

	MessageBox MB_OK "Orange has been succesfully removed from your system.$\r$\nPython and other applications need to be removed separately.$\r$\n$\r$\nYou may now continue without rebooting your machine."
  abort:
SectionEnd


!macro HideSection SECTION
	SectionGetFlags ${SECTION} $0
	IntOp $0 $0 & 0xFFFFFFFE ; disable
	IntOp $0 $0 | 0x00000010 ; readonly
	SectionSetFlags ${SECTION} $0
	SectionSetText ${SECTION} ""
!macroend

!macro WarnMissingModule FILE MODULE
	${Unless} ${FileExists} ${FILE}
		${If} $MissingModules == ""
			StrCpy $MissingModules ${MODULE}
		${Else}
			StrCpy $MissingModules "$MissingModules, ${MODULE}"
		${EndIf}
	${EndUnless}
!macroend

!ifdef INCLUDEPYQT | INCLUDEPYQWT | INCLUDENUMERIC
	!macro DisEnSection SECTION
			!insertMacro HideSection ${SECTION}
		${Else}
			SectionSetText ${SSPYTHON} "Python Modules"
	!macroend
!endif

Function .onGUIInit
	StrCpy $PythonOnDesktop 0

	ReadRegStr $PythonDir HKLM Software\Python\PythonCore\${NPYVER}\InstallPath ""
	${If} $PythonDir == ""
		ReadRegStr $PythonDir HKCU Software\Python\PythonCore\${NPYVER}\InstallPath ""
        StrCpy $SingleUser 1
	${Else}
		StrCpy $SingleUser 0
	${EndIf}
		
	${If} $PythonDir == ""
		!ifdef INCLUDEPYTHON
		  askpython:
			MessageBox MB_OKCANCEL "Orange installer will first launch installation of Python ${NPYVER}$\r$\nOrange installation will continue after you finish installing Python." IDOK installpython
			MessageBox MB_YESNO "Orange cannot run without Python.$\r$\nAbort the installation?" IDNO askpython
			Quit
		
		  installpython:
			SetOutPath $DESKTOP
			StrCpy $PythonOnDesktop 1
			!if ${PYVER} == 23
                File 3rdparty-23\Python-2.3.5.exe
				ExecWait "$DESKTOP\Python-2.3.5.exe"
			!else
				File 3rdparty-${PYVER}\${PYFILENAME}
				ExecWait 'msiexec.exe /i "$DESKTOP\${PYFILENAME}" /ADDLOCAL=Extensions,Documentation ALLUSERS=1 /Qb-' $0
				${If} $0 > 0
					ExecWait 'msiexec.exe /i "$DESKTOP\${PYFILENAME}" /ADDLOCAL=Extensions,Documentation /Qb-' $0
                ${EndIf}
            !endif

			ReadRegStr $PythonDir HKLM Software\Python\PythonCore\${NPYVER}\InstallPath ""
			${If} $PythonDir == ""
			    ReadRegStr $PythonDir HKCU Software\Python\PythonCore\${NPYVER}\InstallPath ""
			    ${If} $PythonDir == ""
				    MessageBox MB_OK "Python installation failed.$\r$\nOrange installation cannot continue."
				    Quit
			    ${EndIf}
			    StrCpy $SingleUser 1
			${Else}
			    StrCpy $SingleUser 0
			${EndIf}
		!else
			MessageBox MB_OK "Cannot find Python ${NPYVER}.$\r$\nDownload it from www.python.org and install, or$\r$\nget an Orange distribution that includes Python"
			Quit
		!endif

		; let the user select the modules
		!ifdef INCLUDEPYQT | INCLUDEPYQWT | INCLUDENUMERIC
		SectionSetText ${SSPYTHON} "Python Modules" 
		!endif
	${Else}
		; we have Python already - let's check the modules

		!ifdef INCLUDEPYQT
			${If} ${FileExists} $PythonDir\lib\site-packages\qt.py
				!insertMacro DisEnSection ${SECPYQT}
			${EndIf}
		!else
			!insertMacro WarnMissingModule "$PythonDir\lib\site-packages\qt.py" "PyQt"
		!endif

		!ifdef INCLUDEPYQWT
			${If} ${FileExists} $PythonDir\lib\site-packages\qwt\*.*
				!insertMacro DisEnSection ${SECPYQWT}
			${EndIf}
		!else
			!insertMacro WarnMissingModule "$PythonDir\lib\site-packages\qwt\*.*" "PyQwt"
		!endif

		!ifdef INCLUDENUMERIC
			${If} ${FileExists} $PythonDir\lib\site-packages\Numeric\*.*
				!insertMacro DisEnSection ${SECNUMERIC}
			${EndIf}
		!else
			!insertMacro WarnMissingModule "$PythonDir\lib\site-packages\Numeric\*.*" "Numeric"
		!endif
		
	${EndIf}

;	${If} $SingleUser = 0
;	    MessageBox MB_OK "Multi"
;	${Else}
;	    MessageBox MB_OK "Single user"
;	${Endif}
    
	StrCpy $0 $PythonDir "" -1
    ${If} $0 == "\"
        StrLen $0 $PythonDir
        IntOp $0 $0 - 1
        StrCpy $PythonDir $PythonDir $0 0
    ${EndIf}

	!ifdef INCLUDEPYTHONWIN
		IfFileExists $PythonDir\lib\site-packages\PythonWin dontinstallpythonwin

		MessageBox MB_YESNO "Do you want to install PythonWin?$\r$\n(recommended if you plan programming scripts)" IDNO dontinstallpythonwin
		SetOutPath $DESKTOP
		File 3rdparty-${PYVER}\${PYWINFILENAME}
		StrCpy $PythonOnDesktop 1
		ExecWait "$DESKTOP\${PYWINFILENAME}"

		ReadRegStr $8 HKLM Software\Python\PythonCore\${NPYVER}\PythonPath\PythonWin ""
		${If} $8 == ""
			MessageBox MB_OK "PythonWin installation failed.$\r$\nOrange installation will now resume."
		${EndIf}

	    dontinstallpythonwin:
	!endif

	
	!ifdef INCLUDEQT
		${If} ${FileExists} "$PythonDir\lib\site-packages\qt-mt230nc.dll" ${OrIf} ${FileExists} "$SYSDIR\qt-mt230nc.dll"
			!insertMacro HideSection ${SECQT}
		${EndIf}
	!else
        ${Unless} ${FileExists} "$SYSDIR\qt-mt230nc.dll"
		  !insertMacro WarnMissingModule "$PythonDir\lib\site-packages\qt-mt230nc.dll" "Qt"
        ${EndUnless}
	!endif

	!ifdef INCLUDEMSVCDLL
		${If} ${FileExists} $INSTDIR\MSVCP60.DLL ${OrIf} ${FileExists} "$SYSDIR\MSVCP60.DLL"
			!insertMacro HideSection ${SECMSVCP60DLL}
		${EndIf}
	!else
        ${Unless} ${FileExists} "$SYSDIR\MSVCP60.DLL"
			!insertMacro WarnMissingModule "$INSTDIR\MSVCP60.DLL" "MSVCP60.DLL"
        ${EndUnless}
	!endif


	
	StrCpy $INSTDIR $PythonDir\lib\site-packages\orange

	StrCmp $MissingModules "" continueinst
	MessageBox MB_YESNO "Missing module(s): $MissingModules$\r$\n$\r$\nThese module(s) are not needed for running scripts in Orange, but Orange Canvas will not work properly until you install them.$\r$\nYou can either download them separately or obtain an Orange installation that includes them.$\r$\n$\r$\nContinue with installation?" IDYES continueinst
	Quit
continueinst:

FunctionEnd


Function .onInstSuccess
	${If} $PythonOnDesktop == 1
		MessageBox MB_OK "Orange has been successfully installed.$\r$\n$\r$\nPython installation files have been put on the desktop$\r$\nin case you may want to store them."
	${Else}
		MessageBox MB_OK "Orange has been successfully installed."
	${EndIf}
FunctionEnd
