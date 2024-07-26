$Target = "C:\ProgramData\Scripts"
$Script = "Create-Backup.ps1"

#Create directory and copy file
if (!(Test-Path $Target)) {
    New-Item $Target -ItemType Directory
}
Copy-Item ".\$Script" -Destination "C:\ProgramData\Scripts" -Force

#Create check file
$env:COMPUTERNAME | Out-File "$Target\$env:COMPUTERNAME.pc"

# Create the scheduled task to run the script at logon
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File $Target\$Script"
$Trigger = New-ScheduledTaskTrigger -AtLogOn 
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Hidden -DontStopIfGoingOnBatteries -Compatibility Win8
$Principal = New-ScheduledTaskPrincipal -GroupId "NT AUTHORITY\Authenticated Users"
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal
Register-ScheduledTask -InputObject $Task -TaskName "Signature, Favorites, & Sticky Notes Backup" -Force