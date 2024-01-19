#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
Opt ("MustDeclareVars",1)
Opt('TrayMenuMode',3)

#include <AutoItConstants.au3>
#include <StringConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <Array.au3>
#include <TrayConstants.au3>
#include <File.au3>
#include <Clipboard.au3>
#include <GuiListView.au3>
#include <Clipboard.au3>

Global $IniFile = "AutoLabelSearch.au3.ini"
Local $file = @DesktopDir & "\SYS.de.label.txt"

Local $TestFile = @WindowsDir

Global $Werte [0][4]
Global $MaxSearchResults

Global $pNotepad = "notepad.exe"
Global $pServiceManager = @ScriptDir & "\D365FOServiceManager.exe"
;Const $Process2 = "C:\Users\LucaBorgmann\OneDrive - Roedl Dynamics GmbH\Desktop\PW Tool\Rödl PW Tool.exe"
Const $pFODevSetupTool = @ScriptDir & "\AutoD365FODevSetupTool.exe"
Const $pCalc = "calc.exe"
;Global $pPasswortManager = @DesktopDir & "\PW Tool\Rodl.PW.Tool.exe" ; funktioniert nicht

Global $pLabelfinder = @ScriptDir & "\RD_Labelfinder2.exe"

Global $iDevSetup = TrayCreateItem("FODevSetUp")
Global $iServiceManager = TrayCreateItem("ServiceManager")
Global $iLabelfinder = TrayCreateItem("Labelfinder")
;Global $iCalc = TrayCreateItem("Calculator")
;Global $iPasswortManager = TrayCreateItem("Passwortmanager")

Const $iExit = TrayCreateItem("Beenden")

;ReadIn()
Main()

Func Main()

	TraySetState($TRAY_ICONSTATE_SHOW)

	While 1
		Switch TrayGetMsg()
			Case  $iDevSetup
				Run($pFODevSetupTool,"",@SW_SHOWDEFAULT)
				Main()
			Case $iServiceManager
				Run($pServiceManager,"",@SW_SHOWDEFAULT)
				Main()
		#cs	Case $iCalc
				Run($pCalc,"",@SW_SHOWDEFAULT)
				Main()
			Case $iPasswortManager
				Run($pPasswortManager,"",@SW_SHOWDEFAULT)
		#ce
			Case $iLabelfinder
				Run($pLabelfinder)
				Main()
			Case $iExit
				Exit
		EndSwitch
	WEnd
EndFunc


Func ReadIn()
	ConsoleWrite("Start: " & @HOUR & ":"& @MIN&":"&@SEC & @CRLF)

	MsgBox(0,"",$file)
	MsgBox(0,"",$TestFile)
	_ClipBoard_SetData($IniFile)
	Global $SectionNames = IniReadSectionNames(@ScriptDir & "\" & $INIFile)
	;_ArrayDisplay($SectionNames)

	For $i = 1 to UBound($SectionNames)-1
		Local $SectionName = $SectionNames[$i]
		ConsoleWrite($SectionName&@CRLF)

		if $SectionName == "System" then

			$MaxSearchResults = IniRead($INIFile,$SectionName,"MaxSearchResults",0)

		elseIf $SectionName == "General" Then
			; hier passiert nichts

		else
			Local $SectionContent = _ReadInSection($SectionNames[$i])
			_ArrayAdd($Werte,$SectionContent)
		EndIf


	next

	ConsoleWrite("Ende: " & @HOUR & ":" &@MIN&":"&@SEC&@CRLF)
	_ArrayDisplay($Werte)
	Main()
EndFunc

Func _ReadInSection($pSectionName)

	Local $tmpFilePath = IniRead($INIFile,$pSectionName, "Labelfile","")
	Local $LabelPrefix = IniRead($INIFile,$pSectionName,"Labelprefix","")

	if Not FileExists($tmpFilePath) Then
		MsgBox(16,@ScriptName, "Datei " & $tmpFilePath & " wurde nicht gefunden")
	endif

	Local $FileContent = FileReadToArray($tmpFilePath)

	;_ArrayDisplay($FileContent,"$FileContent");

	Local $FileContent_Rows = Ubound($FileContent)-1
	ConsoleWrite("$FileContent_Rows="  & $FileContent_Rows & @CRLF)
	Local $ValuesCurrentFile[$FileContent_Rows][4]
	;_ArrayDisplay($ValuesCurrentFile)

	Local $n
	Local $CurrentPos = 0

	For $n = 0 to $FileContent_Rows

		Local $FileContentLine = $FileContent[$n]

		; String left um herauszufinden womit die Zeile beginnt
		If StringLeft($FileContentLine,1) <> " " Then
			local $tmpArray = StringSplit($FileContentLine,"=")
			;_ArrayDisplay($tmpArray)

			Local $label = $tmpArray[1]
			Local $text = $tmpArray[2]
			Local $comment = ""

			$ValuesCurrentFile[$CurrentPos][0]=$label
			; ConsoleWrite("Label: "&$label&@CRLF)
			$ValuesCurrentFile[$CurrentPos][1]=$text
			; ConsoleWrite("Text: "&$text&@CRLF)
			$ValuesCurrentFile[$CurrentPos][2]=$comment
			; ConsoleWrite("Kommentar: "&$comment&@CRLF)
			$ValuesCurrentFile[$CurrentPos][3]=$LabelPrefix
			; ConsoleWrite("Prefix: "&$LabelPrefix& @CRLF)

			$CurrentPos += 1
		EndIf

	next

	 $ValuesCurrentFile = _ArrayExtract($ValuesCurrentFile, 0, $CurrentPos-1)

	;_ArrayDisplay($ValuesCurrentFile)
	Return $ValuesCurrentFile

EndFunc
