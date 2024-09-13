Param(
    [string] $installationFolder
)

$appPath = Join-Path $installationFolder "RD-Tools.exe"
$appDirectory = Split-Path $appPath -Parent #extrahiert den Pfad
Write-Output "aktueller Pfad: " + $appDirectory
# Erstelle die geplante Aufgabe
$taskName = "RD_Tools starten"
$action = New-ScheduledTaskAction -Execute $appPath  -WorkingDirectory $installationFolder 
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "$env:UserName" -LogonType Interactive -RunLevel Highest

# Aufgabe erstellen
#Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Force

# Prüfen, ob die Aufgabe bereits existiert
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    # Aufgabe löschen, wenn sie bereits existiert
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Aufgabe registrieren
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Force
