#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Launcher.ico
#AutoIt3Wrapper_Res_Description=Rödl Dynamics RD_Tools
#AutoIt3Wrapper_Res_Fileversion=1.0.0.19
#AutoIt3Wrapper_Res_ProductName=RD_Tools
#AutoIt3Wrapper_Res_ProductVersion=1.0
#AutoIt3Wrapper_Res_CompanyName=Rödl Dynamics GmbH
#AutoIt3Wrapper_Res_LegalCopyright=Rödl Dynamics GmbH
#AutoIt3Wrapper_Res_LegalTradeMarks=Rödl Dynamics GmbH
#AutoIt3Wrapper_Res_Language=1031
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         myName

 Script Function:
	This Tool make it easier to Use the RD-Modules

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
#include <GuiListView.au3>
#include <Clipboard.au3>

Global $IniFile = "AutoLabelSearch.au3.ini"
Local $file = @DesktopDir & "\SYS.de.label.txt"

Local $TestFile = @WindowsDir

Global $Werte [0][4]
Global $MaxSearchResults


Global $pServiceManager = @ScriptDir & "\D365FOServiceManager.exe"
Const $pFODevSetupTool = @ScriptDir & "\AutoD365FODevSetupTool.exe"
Global $pLabelfinder = @ScriptDir & "\RDD_Labelfinder.exe"
Global $pDBSync = @ScriptDir & "\DBSync.exe"

Global $iDevSetup = TrayCreateItem("FODevSetUp")
Global $iServiceManager = TrayCreateItem("ServiceManager")
Global $iLabelfinder = TrayCreateItem("Labelfinder")
Global $iDBSync = TrayCreateItem("Datenbank Syncronisation")

Const $iExit = TrayCreateItem("Beenden")

Global $LabelDatei = @ScriptDir& "\Labels.txt"
Global $Labels[0][4]
Global $openedByLauncher
Global $Labelfail = false

ReadIn()

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
			Case $iLabelfinder
				if $Labelfail == true then
					MsgBox(16,"Warnung","die Labeldateien konnten nicht korrekt eingelesen werden")
					ExitLoop
				EndIf
				Run($pLabelfinder,"",@SW_SHOWDEFAULT)
				Main()
			Case $iDBSync
				Run($pDBSync,"",@SW_SHOWDEFAULT)
				Main()
			Case $iExit
				clearFile()
				IniWrite($IniFile,"Launcher","openedByLauncher","false")
				Exit
		EndSwitch
	WEnd
EndFunc


Func ReadIn()
	Local $FileSize = FileGetSize($LabelDatei)
	ConsoleWrite("Start: " & @HOUR & ":"& @MIN&":"&@SEC & @CRLF)
	Global $SectionNames = IniReadSectionNames(@ScriptDir & "\" & $INIFile)
	ConsoleWrite("Dateigröße: "& $FileSize & @CRLF)


	Local $z
	For $z = 4 to UBound($SectionNames)-1
		Local $path = IniRead($INIFile,$SectionNames,"Labelfile","")
		if $path == " " then
			MsgBox(16, @ScriptName,"bitte Dateipfad für " &$SectionNames[$z]&" angeben")
			Main()
		EndIf
	next

	if UBound($SectionNames)-1 < 4 then
		MsgBox(16,"Warnung","sie haben keine Labeldateien angegeben")
		$Labelfail = true
		Main()
	EndIf

	if $FileSize == 0 then
		; hier muss das Tool die Labels in die neue Textdatei einlesen
		ConsoleWrite("Die Labeldatei ist leer" & @CRLF)
		For $i = 1 to Ubound($SectionNames)-1
			Local $SectionName = $SectionNames[$i]
			if $SectionName <> "System" and $SectionName <> "General" and $SectionName <> "Launcher" then
				Local $SectionContent = _ReadInSection($SectionNames[$i])
				_ArrayAdd($Werte,$SectionContent)
				_FileWriteFromArray($LabelDatei,$Werte) ; schreibt das Array in das neue Dokument Labels.txt

			EndIf
		next
		ConsoleWrite("Größe des Arrays(Labels): " & UBound($Labels)&","& UBound($Labels,2) & @CRLF)
		ConsoleWrite("Größe des Arrays(Werte): " & UBound($Werte) & ","&Ubound($Werte,2)& @CRLF)

		; mit der Funktion readLabelFile_Into_2DArray in das 2D-Array einlesen
		$Labels = readLabelFile_Into_2DArray($LabelDatei)
	else
		; hier muss das Tool nur auf die bereits eingelesenen Werte in der neuen Textdatei zugreifen
		ConsoleWrite("Die Labeldatei ist nicht leer"& @CRLF)
		$Labels = readLabelFile_Into_2DArray($LabelDatei) ; methode zum einlesen der Datei in das 2D Array



	EndIf

	IniWrite($IniFile,"Launcher","openedByLauncher","True")
	ConsoleWrite("Ende: " & @HOUR & ":" &@MIN&":"&@SEC&@CRLF)
	Main()
EndFunc

Func _ReadInSection($pSectionName)

	Local $tmpFilePath = IniRead($INIFile,$pSectionName, "Labelfile","")
	Local $LabelPrefix = IniRead($INIFile,$pSectionName,"Labelprefix","")

	if $tmpFilePath == "" then
		MsgBox(16, @ScriptName,"bitte Dateipfad für " &$pSectionName&" angeben")
	EndIf

	if Not FileExists($tmpFilePath) Then
		MsgBox(16,"Warnung", "Die Datei konnte nicht gefunden werden")
		$Labelfail = True
		Main()
	endif

	Local $FileContent = FileReadToArray($tmpFilePath)

	Local $FileContent_Rows = Ubound($FileContent)-1
	ConsoleWrite("$FileContent_Rows="  & $FileContent_Rows & @CRLF)
	Local $ValuesCurrentFile[$FileContent_Rows][4]

	Local $n
	Local $CurrentPos = 0

	For $n = 0 to $FileContent_Rows-1

		Local $FileContentLine = $FileContent[$n]

		; String left um herauszufinden womit die Zeile beginnt
		If StringLeft($FileContentLine,1) <> " " Then
			local $tmpArray = StringSplit($FileContentLine,"=")
			ConsoleWrite("n= " & $n & @CRLF)
			ConsoleWrite("CurrentPos= " & $CurrentPos & @CRLF)

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

	Return $ValuesCurrentFile
EndFunc

Func readLabelFile_Into_2DArray($pFile)
	; Prüft ob das File Existiert
	if Not FileExists($pFile) then
		MsgBox(16,@ScriptName,"Datei " & $pFile & " wurde nicht gefunden")
	EndIf

	Local $FileContent = FileReadToArray($pFile)

	Local $FileContent_Rows = UBound($FileContent)-1
	ConsoleWrite("$FileContent_Rows=" & $FileContent_Rows & @CRLF)
	Local $ValuesCurrentFile[$FileContent_Rows][4]

	Local $n
	Local $CurrentPos = 0

	For $n = 0 to $FileContent_Rows-1
		Local $FileContentLine = $FileContent[$n]

		If StringLeft($FileContentLine,1) <> " " Then
			Local $tmpArray = StringSplit($FileContentLine,"|")
			ConsoleWrite("CurrentPos "& $CurrentPos & @CRLF)


			Local $label = $tmpArray[1]
			Local $text = $tmpArray[2]
			Local $comment = ""
			Local $prefix = $tmpArray[4]

			$ValuesCurrentFile[$CurrentPos][0] = $label
			$ValuesCurrentFile[$CurrentPos][1] = $text
			$ValuesCurrentFile[$CurrentPos][2] = $comment
			$ValuesCurrentFile[$CurrentPos][3] = $prefix

			$CurrentPos += 1

		EndIf

	next


		Return $ValuesCurrentFile
EndFunc

Func clearFile()
	Local $oFile  = FileOpen($LabelDatei,2)
	FileWrite($oFile,"")
	FileClose($oFile)
EndFunc