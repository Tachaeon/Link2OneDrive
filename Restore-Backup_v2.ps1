<#
.SYNOPSIS
    Restores backed-up application data from OneDrive to a new or replacement computer.

.DESCRIPTION
    Copies Outlook Signatures, Sticky Notes, Chrome bookmarks, Firefox bookmarks,
    Firefox Store (MSIX) bookmarks, and Edge bookmarks from the .DONOTDELETE backup
    folder in OneDrive back to their original application paths.

    Only executes when the .pc identity file in C:\ProgramData\Scripts does NOT match
    the current computer name, indicating this is a new or replacement machine.
    After restoring, deletes the old .pc file and writes a new one for this computer
    so future logons trigger backups instead of restores.

    Silently skips any item whose backup or destination path does not exist.

.EXAMPLE
    .\Restore-Backup_v2.ps1
    Run after OneDrive for Business has fully synced on the new machine.

.NOTES
    Firefox restores target the active *.default-release profile. Firefox must have
    been launched at least once on the new machine before running this script so that
    the profile directory exists.
    Edge named profiles (Profile 1, Profile 2, etc.) are only restored if Edge has
    already created those profile directories on the new machine.
#>

$ScriptDir     = 'C:\ProgramData\Scripts'
$BaseDirectory = "$env:OneDriveCommercial\.DONOTDELETE"

# Only restore when this machine does not match the stored identity.
# A match means this is the original machine — no restore needed.
$PCFile = (Get-Item "$ScriptDir\$env:COMPUTERNAME.pc" -ErrorAction SilentlyContinue).BaseName
if ($PCFile -eq $env:COMPUTERNAME) { exit }

# Signatures
$SigDest = "$env:APPDATA\Microsoft\Signatures"
if (Test-Path "$BaseDirectory\Signatures") {
    if (-not (Test-Path $SigDest)) { New-Item -Path $SigDest -ItemType Directory | Out-Null }
    Copy-Item -Path "$BaseDirectory\Signatures\*" -Destination $SigDest -Recurse -Force
}

# Sticky Notes
$StickyDest = "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState"
if ((Test-Path "$BaseDirectory\Sticky Notes") -and (Test-Path $StickyDest)) {
    Copy-Item -Path "$BaseDirectory\Sticky Notes\*" -Destination $StickyDest -Force
}

# Chrome Bookmarks
$ChromeBackup = "$BaseDirectory\Chrome Favorites\Bookmarks"
$ChromeDest   = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
if ((Test-Path $ChromeBackup) -and (Test-Path (Split-Path $ChromeDest))) {
    Copy-Item -Path $ChromeBackup -Destination $ChromeDest -Force
}

# Firefox (classic install) — restore into active default-release profile
$FoxProfileRoot = "$env:APPDATA\Mozilla\Firefox\Profiles"
$FoxProfile = Get-ChildItem "$FoxProfileRoot\*.default-release" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
if ($FoxProfile) {
    foreach ($FileName in @('places.sqlite', 'favicons.sqlite')) {
        $Src = "$BaseDirectory\Firefox Favorites\$FileName"
        if (Test-Path $Src) {
            Copy-Item -Path $Src -Destination (Join-Path $FoxProfile.FullName $FileName) -Force
        }
    }
}

# Firefox (Microsoft Store / MSIX install)
$FoxStoreProfileRoot = "$env:LOCALAPPDATA\Packages\Mozilla.Firefox_n80bbvh6b1yt2\LocalCache\Roaming\Mozilla\Firefox\Profiles"
$FoxStoreProfile = Get-ChildItem "$FoxStoreProfileRoot\*.default-release" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
if ($FoxStoreProfile) {
    foreach ($FileName in @('places.sqlite', 'favicons.sqlite')) {
        $Src = "$BaseDirectory\Firefox Store Favorites\$FileName"
        if (Test-Path $Src) {
            Copy-Item -Path $Src -Destination (Join-Path $FoxStoreProfile.FullName $FileName) -Force
        }
    }
}

# Edge — Default profile
$EdgeDefaultBackup = "$BaseDirectory\Edge Favorites\Bookmarks"
$EdgeDefaultDest   = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"
if ((Test-Path $EdgeDefaultBackup) -and (Test-Path (Split-Path $EdgeDefaultDest))) {
    Copy-Item -Path $EdgeDefaultBackup -Destination $EdgeDefaultDest -Force
}

# Edge — additional named profiles — only restores if Edge already created the profile folder
$EdgeUserData = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
foreach ($BackupProfile in (Get-ChildItem -Path "$BaseDirectory\Edge Favorites" -Directory -ErrorAction SilentlyContinue)) {
    $BackupFile = Join-Path $BackupProfile.FullName 'Bookmarks'
    $DestFolder = Join-Path $EdgeUserData $BackupProfile.Name
    if ((Test-Path $BackupFile) -and (Test-Path $DestFolder)) {
        Copy-Item -Path $BackupFile -Destination (Join-Path $DestFolder 'Bookmarks') -Force
    }
}

# Update identity file so this machine backs up on future logons
Remove-Item -Path "$ScriptDir\*.pc" -Force -ErrorAction SilentlyContinue
$env:COMPUTERNAME | Out-File "$ScriptDir\$env:COMPUTERNAME.pc"
