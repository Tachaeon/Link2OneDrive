<#
.SYNOPSIS
    Registers the Link2OneDrive backup scheduled task on this machine.

.DESCRIPTION
    Creates C:\ProgramData\Scripts if it does not exist, copies Create-Backup_v2.ps1
    to that directory, writes the .pc identity file for this computer, and registers
    a Windows Scheduled Task that runs the backup script silently at every user logon.

    Run this script once per machine during initial setup. Requires elevation (local
    administrator rights) to register the scheduled task.

.EXAMPLE
    # Run once in an elevated PowerShell session:
    .\Create-ScheduleTask_v2.ps1

.NOTES
    The task runs under NT AUTHORITY\Authenticated Users so it fires for any user
    that logs on. If the machine is re-imaged, re-run this script.
    To trigger the backup immediately without logging off, use Force-Backup_v2.ps1.
#>

$Target     = 'C:\ProgramData\Scripts'
$ScriptName = 'Create-Backup_v2.ps1'

if (-not (Test-Path $Target)) {
    New-Item -Path $Target -ItemType Directory | Out-Null
}

Copy-Item -Path ".\$ScriptName" -Destination $Target -Force

$env:COMPUTERNAME | Out-File (Join-Path $Target "$env:COMPUTERNAME.pc")

$Action    = New-ScheduledTaskAction -Execute 'powershell.exe' `
               -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File `"$Target\$ScriptName`""
$Trigger   = New-ScheduledTaskTrigger -AtLogOn
$Settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Hidden -DontStopIfGoingOnBatteries -Compatibility Win8
$Principal = New-ScheduledTaskPrincipal -GroupId 'NT AUTHORITY\Authenticated Users'
$Task      = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal

Register-ScheduledTask -InputObject $Task -TaskName 'Signature, Favorites, & Sticky Notes Backup' -Force
