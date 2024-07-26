$Target = "C:\ProgramData\Scripts"
$PCFile = ((Get-Item "C:\ProgramData\Scripts\$env:COMPUTERNAME.pc" -ErrorAction SilentlyContinue).Name -replace '\.pc$', '')
$BaseDirectory = "$env:OneDriveCommercial\.DONOTDELETE"
$Bookmarks = "$env:LocalAppdata\Google\Chrome\User Data\Default\Bookmarks"
$SigSource = "$env:Appdata\Microsoft\Signatures"
$StickySource = "$env:LocalAppdata\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState"
$DefaultFox = "$env:APPDATA\Mozilla\Firefox\Profiles\"
$DefaultFoxStore = "$env:LOCALAPPDATA\Packages\Mozilla.Firefox_n80bbvh6b1yt2\LocalCache\Roaming\Mozilla\Firefox\Profiles\"
$DefaultEdge = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"

if (!($PCFile -match $env:COMPUTERNAME)) {
    #Copy
    Copy-Item -Path "$BaseDirectory\Favorites\*.*" -Destination $Bookmarks -Force
    Copy-Item -Path "$BaseDirectory\Signatures\*.*" -Destination $SigSource -Force
    Copy-Item -Path "$BaseDirectory\Sticky Notes\*.*" -Destination $StickySource -Force
    Copy-Item -Path "$BaseDirectory\Firefox Favorites\*.*" -Destination $DefaultFox -Force
    Copy-Item -Path "$BaseDirectory\Firefox Store Favorites\*.*" -Destination $DefaultFoxStore -Force
    Copy-Item -Path "$BaseDirectory\Edge Favorites\*.*" -Destination $DefaultEdge -Force

    #Rename
    Remove-Item -Path "C:\ProgramData\Scripts\*.pc" -Force
    $env:COMPUTERNAME | Out-File "$Target\$env:COMPUTERNAME.pc"
}