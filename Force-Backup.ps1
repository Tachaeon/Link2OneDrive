$Task = Get-ScheduledTask -TaskName "Signature, Favorites, & Sticky Notes Backup"

#Start Backup
if ($Task) {
    $Task | Start-ScheduledTask
}