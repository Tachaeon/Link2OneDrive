<#
.SYNOPSIS
    Backs up user application data to OneDrive for Business.

.DESCRIPTION
    Copies Outlook Signatures, Sticky Notes, Chrome bookmarks, Firefox bookmarks,
    Firefox Store (MSIX) bookmarks, and Edge bookmarks to the .DONOTDELETE folder
    inside $env:OneDriveCommercial.

    Runs automatically at user logon via Windows Task Scheduler (registered by
    Create-ScheduleTask_v2.ps1). Only executes if the .pc identity file in
    C:\ProgramData\Scripts matches the current computer name, preventing this
    machine from overwriting a backup while it is being restored on a new machine.

    Skips any application whose source path does not exist (e.g. Firefox not installed).

.EXAMPLE
    .\Create-Backup_v2.ps1
    Backs up all supported application data. Safe to run manually at any time.

.NOTES
    Requires OneDrive for Business to be signed in ($env:OneDriveCommercial must resolve).
    Run Create-ScheduleTask_v2.ps1 once per machine before first use.
#>

$ScriptDir     = 'C:\ProgramData\Scripts'
$BaseDirectory = "$env:OneDriveCommercial\.DONOTDELETE"

# Create backup subdirectories
foreach ($DirectoryName in @('Chrome Favorites', 'Signatures', 'Sticky Notes', 'Firefox Favorites', 'Edge Favorites', 'Firefox Store Favorites')) {
    $Directory = Join-Path $BaseDirectory $DirectoryName
    if (-not (Test-Path $Directory)) {
        New-Item -Path $Directory -ItemType Directory | Out-Null
    }
}

# Only back up when the .pc identity file matches this computer.
# A mismatch means this machine is mid-restore and should not overwrite the backup.
$PCFile = (Get-Item "$ScriptDir\$env:COMPUTERNAME.pc" -ErrorAction SilentlyContinue).BaseName
if ($PCFile -ne $env:COMPUTERNAME) { exit }

# Signatures — recurse to capture per-signature image asset subfolders
$SigSource = "$env:APPDATA\Microsoft\Signatures"
if (Test-Path $SigSource) {
    Copy-Item -Path "$SigSource\*" -Destination "$BaseDirectory\Signatures\" -Recurse -Force
}

# Sticky Notes
$StickySource = "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState"
if (Test-Path $StickySource) {
    Copy-Item -Path "$StickySource\*" -Destination "$BaseDirectory\Sticky Notes\" -Force
}

# Chrome Bookmarks
$ChromeBookmarks = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"
if (Test-Path $ChromeBookmarks) {
    Copy-Item -Path $ChromeBookmarks -Destination "$BaseDirectory\Chrome Favorites\Bookmarks" -Force
}

# Firefox (classic install) — discover default-release profile dynamically
$FoxProfileRoot = "$env:APPDATA\Mozilla\Firefox\Profiles"
$FoxProfile = Get-ChildItem "$FoxProfileRoot\*.default-release" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
if ($FoxProfile) {
    foreach ($FileName in @('places.sqlite', 'favicons.sqlite')) {
        $Src = Join-Path $FoxProfile.FullName $FileName
        if (Test-Path $Src) {
            Copy-Item -Path $Src -Destination "$BaseDirectory\Firefox Favorites\$FileName" -Force
        }
    }
}

# Firefox (Microsoft Store / MSIX install)
$FoxStoreProfileRoot = "$env:LOCALAPPDATA\Packages\Mozilla.Firefox_n80bbvh6b1yt2\LocalCache\Roaming\Mozilla\Firefox\Profiles"
$FoxStoreProfile = Get-ChildItem "$FoxStoreProfileRoot\*.default-release" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
if ($FoxStoreProfile) {
    foreach ($FileName in @('places.sqlite', 'favicons.sqlite')) {
        $Src = Join-Path $FoxStoreProfile.FullName $FileName
        if (Test-Path $Src) {
            Copy-Item -Path $Src -Destination "$BaseDirectory\Firefox Store Favorites\$FileName" -Force
        }
    }
}

# Edge — Default profile
$DefaultEdge = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"
if (Test-Path $DefaultEdge) {
    Copy-Item -Path $DefaultEdge -Destination "$BaseDirectory\Edge Favorites\Bookmarks" -Force
}

# Edge — additional named profiles (Profile 1, Profile 2, ...)
$EdgeUserData = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
foreach ($ProfileFolder in (Get-ChildItem -Path $EdgeUserData -Directory -Filter 'Profile*' -ErrorAction SilentlyContinue)) {
    $SourceFile = Join-Path $ProfileFolder.FullName 'Bookmarks'
    if (Test-Path $SourceFile) {
        $DestFolder = Join-Path "$BaseDirectory\Edge Favorites" $ProfileFolder.Name
        if (-not (Test-Path $DestFolder)) { New-Item -Path $DestFolder -ItemType Directory | Out-Null }
        Copy-Item -Path $SourceFile -Destination (Join-Path $DestFolder 'Bookmarks') -Force
    }
}

# Keep the backup folder hidden from users
$Folder = Get-Item -Path $BaseDirectory -ErrorAction SilentlyContinue
if ($Folder) { $Folder.Attributes = [System.IO.FileAttributes]::Hidden }
