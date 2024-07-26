$Target = "C:\ProgramData\Scripts"
$BaseDirectory = "$env:OneDriveCommercial\.DONOTDELETE"
$Bookmarks = "$env:LocalAppdata\Google\Chrome\User Data\Default\Bookmarks"
$SigSource = "$env:Appdata\Microsoft\Signatures"
$PCFile = ((Get-Item "C:\ProgramData\Scripts\$env:COMPUTERNAME.pc" -ErrorAction SilentlyContinue).Name -replace '\.pc$', '')
$StickySource = "$env:LocalAppdata\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState"

if (!($PCFile -match $env:COMPUTERNAME)) {
    #Copy
    Copy-Item -Path "$BaseDirectory\Favorites\*.*" -Destination $Bookmarks -Force
    Copy-Item -Path "$BaseDirectory\Signatures\*.*" -Destination $SigSource -Force
    Copy-Item -Path "$BaseDirectory\Sticky_Notes\*.*" -Destination $StickySource -Force
    
    #Rename
    Remove-Item -Path "C:\ProgramData\Scripts\*.pc" -Force
    $env:COMPUTERNAME | Out-File "$Target\$env:COMPUTERNAME.pc"
}