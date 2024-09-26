#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=DBSync.ico
#AutoIt3Wrapper_Res_Description=Rödl Dynamics DB Sync
#AutoIt3Wrapper_Res_Fileversion=1.0.0.6
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=Rödl Dynamcs DB Sync
#AutoIt3Wrapper_Res_ProductVersion=1.0
#AutoIt3Wrapper_Res_CompanyName=Rödl Dynamics
#AutoIt3Wrapper_Res_LegalCopyright=Rödl Dynamcis
#AutoIt3Wrapper_Res_LegalTradeMarks=Rödl Dynamcs
#AutoIt3Wrapper_Res_Language=1031
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         myName

 Script Function:
	This Script ask you for your password if the password in the

exe- Icon Source: https://www.iconarchive.com/show/small-n-flat-icons-by-paomedia/sign-sync-icon.html

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#RequireAdmin
Opt("MustDeclareVars", 1)

#include <File.au3>
#include <Array.au3>
#include <StringConstants.au3>
#include <MsgBoxConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <TrayConstants.au3>


Local $batPath = @ScriptDir & "\DB Sync.bat"

Local $sFileContent = FileRead($batPath)
;Local $passwordRow = StringSplit($sFileContent," ")
Local $passwordRow = StringSplit($sFileContent, " " & @CRLF, $STR_CHRSPLIT)

Global $password = $passwordRow[22]

if $password == "$Password" then
	openGUI()
	;Run(@ScriptDir & "\DB Sync.bat")
Else
	ConsoleWrite("Das Platzhalter ist bereits geändert" & @CRLF)
	;Run(@ScriptDir & "\DB Sync.bat")
EndIf
Run(@ScriptDir & "\DB Sync.bat")


func openGUI()


	#Region ### START Koda GUI section ### Form=
	Global $InputPasswordForm = GUICreate("Geben sie das fehlende Password ein: ", 447, 75, 2580, 362)
	Global $InputPasswordField = GUICtrlCreateInput("", 16, 8, 409, 21,BitOR($GUI_SS_DEFAULT_INPUT, $ES_PASSWORD))
	Global $SafeButton = GUICtrlCreateButton("Speichern", 264, 40, 75, 25)
	Global $CancelButton = GUICtrlCreateButton("Schließen", 352, 40, 75, 25)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	While 1
		Global $nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Exit
			Case $SafeButton
				Local $userInput = GUICtrlRead($InputPasswordField)
				_WritePasswordInFile($userInput)
				ExitLoop
			Case $CancelButton
				Exit
		EndSwitch
	WEnd


EndFunc

Func _WritePasswordInFile($pPassword)
    ; Lese den gesamten Inhalt der Datei ein
    Local $file = FileOpen($batPath, 0) ;Lesemodus
    If $file = -1 Then
        MsgBox(0, "Fehler", "Die Datei konnte nicht gelesen werden.")
        Return
    EndIf

    Local $sFileContent = FileRead($file); ließt den Inhalt der Datei ein
    FileClose($file) ; Datei nach dem Lesen sofort schließen

    Local $newContent = StringReplace($sFileContent, "$Password", $pPassword)

    $file = FileOpen($batPath, 2) ;(überschreibt den alten Inhalt)
    If $file = -1 Then ;-1 = Fehlermeldung
        MsgBox(0, "Fehler", "Die Datei konnte nicht beschrieben werden.")
        Return
    EndIf

    FileWrite($file, $newContent)

    FileClose($file)

EndFunc