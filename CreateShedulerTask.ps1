Param(
    [string] $installationFolder
)
#$appPath = "C:\Program Files (x86)\RDTools\RDTools.exe" #Muss dynamisch an den Pfad des Installationsordners angepasst werden
#$appPath = $installationFolder+"\RDTools.exe"#
#$appPath = "$installationFolder\RD-Tools.exe"
#$appPath = "$installationFolder\RD-Tools.exe"
#$appPath = "C:\Ordner\RD-Tools\RD-Tools.exe"
$appPath = Join-Path $installationFolder "RD-Tools.exe"
$appDirectory = Split-Path $appPath -Parent #extrahiert den Pfad
Write-Output "aktueller Pfad: " + $appDirectory
# Erstelle die geplante Aufgabe
$taskName = "RD_Tools starten (erstellt durch Powershell)"
$action = New-ScheduledTaskAction -Execute $appPath  -WorkingDirectory $installationFolder
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "$env:UserName" -LogonType Interactive -RunLevel Highest

# Aufgabe erstellen
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Force