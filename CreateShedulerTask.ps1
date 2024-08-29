# Definiere den Pfad zur RD-Tools.exe
#$appPath = "C:\Pfad\zu\deinem\RD-Tools.exe"  # Ersetze dies durch den tatsächlichen Pfad
$appPath = "C:\Program Files (x86)\RDTools\RDTools.exe" #Muss dynamisch an den Pfad des Installationsordners angepasst werden
$appDirectory = Split-Path $appPath -Parent #extrahiert den Pfad
# Erstelle die geplante Aufgabe
$taskName = "RD_Tools starten (erstellt durch Powershell)"
$action = New-ScheduledTaskAction -Execute $appPath  -WorkingDirectory $appDirectory
$trigger = New-ScheduledTaskTrigger -AtLogOn
#$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$principal = New-ScheduledTaskPrincipal -UserId "$env:UserName" -LogonType Interactive -RunLevel Highest

# Aufgabe erstellen
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Force