<#
.SYNOPSIS
    Immediately triggers the Link2OneDrive backup without waiting for logon.

.DESCRIPTION
    Starts the "Signature, Favorites, & Sticky Notes Backup" scheduled task on demand.
    Useful for forcing a backup before shutting down or for verifying the task works
    after running Create-ScheduleTask_v2.ps1.

.EXAMPLE
    .\Force-Backup_v2.ps1

.NOTES
    The scheduled task must have been registered first by Create-ScheduleTask_v2.ps1.
#>

$TaskName = 'Signature, Favorites, & Sticky Notes Backup'
$Task     = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($Task) {
    $Task | Start-ScheduledTask
} else {
    Write-Warning "Scheduled task '$TaskName' not found. Run Create-ScheduleTask_v2.ps1 first."
}
