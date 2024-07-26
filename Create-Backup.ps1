$BaseDirectory = "$env:OneDriveCommercial\.DONOTDELETE"

#Create Necessary Directories
$DirectoriesToCreate = @("Chrome Favorites", "Signatures", "Sticky Notes", "Firefox Favorites", "Edge Favorites", "Firefox Store Favorites")
foreach ($DirectoryName in $DirectoriesToCreate) {
    $Directory = Join-Path -Path $BaseDirectory -ChildPath $DirectoryName
    if (!(Test-Path -Path $Directory)) {
        New-Item -Path $BaseDirectory -Name $DirectoryName -ItemType Directory
    }
}

#Hardlink Files
$PCFile = ((Get-Item "C:\ProgramData\Scripts\$env:COMPUTERNAME.pc" -ErrorAction SilentlyContinue).Name -replace '\.pc$', '')

#Signatures
$SigSource = "$env:Appdata\Microsoft\Signatures"
$Signatures = Get-ChildItem $SigSource 
$OneSig = "$BaseDirectory\Signatures\"

#Chrome Favorites
$OneBook = "$BaseDirectory\Chrome Favorites\Bookmarks"
$ChromeBookmarks = "$env:LocalAppdata\Google\Chrome\User Data\Default\Bookmarks"

#Sticky Notes
$OneNotes = "$BaseDirectory\Sticky Notes\"
$StickySource = "$env:LocalAppdata\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState"
$StickyNotes = Get-ChildItem $StickySource

#Firefox
$OneFox = "$BaseDirectory\Firefox Favorites"
$DefaultFox = "$env:APPDATA\Mozilla\Firefox\Profiles\"
$Default_Release = "*.default-release"
$DefaultFoxName = (Get-ChildItem "$DefaultFox\$Default_Release" -ErrorAction SilentlyContinue | Select-Object Name).Name
$FoxPlacesName = "places.sqlite"
$FoxPlacesPath = (Get-ChildItem "$DefaultFox\$DefaultFoxName\$FoxPlacesName" -ErrorAction SilentlyContinue).FullName
$FoxFavIconsName = "favicons.sqlite"
$FoxFavIconsPath = (Get-ChildItem "$DefaultFox\$DefaultFoxName\$FoxFavIconsName" -ErrorAction SilentlyContinue).FullName

#Firefox Windows Store
$OneFoxStore = "$BaseDirectory\Firefox Store Favorites"
$DefaultFoxStore = "$env:LOCALAPPDATA\Packages\Mozilla.Firefox_n80bbvh6b1yt2\LocalCache\Roaming\Mozilla\Firefox\Profiles\"
$DefaultFoxStoreName = (Get-ChildItem "$DefaultFoxStore\$Default_Release" -ErrorAction SilentlyContinue | Select-Object Name).Name
$FoxPlacesStorePath = (Get-ChildItem "$DefaultFoxStore\$DefaultFoxStoreName\$FoxPlacesName" -ErrorAction SilentlyContinue).FullName
$FoxFavIconsStorePath = (Get-ChildItem "$DefaultFoxStore\$DefaultFoxStoreName\$FoxFavIconsName" -ErrorAction SilentlyContinue).FullName

#Edge Favorites
$OneEdge = "$BaseDirectory\Edge Favorites\Bookmarks"
$DefaultEdge = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks"

if ($PCFile -match $env:COMPUTERNAME) {
    foreach ($Signature in $Signatures) {
        #Signatures
        $SourceFile = $Signature.FullName
        $OneSigFile = $OneSig + $Signature.Name
        Copy-Item -Path $SourceFile -Destination $OneSigFile -Force
        #New-Item -ItemType HardLink -Path $OneSigFile -Value $SourceFile -ErrorAction SilentlyContinue
    }

    foreach ($StickyNote in $StickyNotes) {
        #StickyNotes
        $SourceFile = $StickyNote.FullName
        $OneNotesFile = $OneNotes + $StickyNote.Name
        Copy-Item -Path $SourceFile -Destination $OneNotesFile -Force
        #New-Item -ItemType HardLink -Path $OneNotesFile -Value $SourceFile -ErrorAction SilentlyContinue
    }

    #Chrome Bookmarks
    Copy-Item -Path $ChromeBookmarks -Destination $OneBook -Force
    #New-Item -ItemType HardLink -Path $OneBook -Value $ChromeBookmarks -ErrorAction SilentlyContinue

    #Firefox
    Copy-Item -Path $FoxPlacesPath -Destination "$OneFox\$FoxPlacesName" -Force
    Copy-Item -Path $FoxFavIconsPath -Destination "$OneFox\$FoxFavIconsName" -Force
    #New-Item -ItemType HardLink -Path "$OneFox\$FoxPlacesName" -Value $FoxPlacesPath -ErrorAction SilentlyContinue
    #New-Item -ItemType HardLink -Path "$OneFox\$FoxFavIconsName" -Value $FoxFavIconsPath -ErrorAction SilentlyContinue

    #Firefox Windows Store
    Copy-Item -Path $FoxPlacesStorePath -Destination "$OneFoxStore\$FoxPlacesName" -Force
    Copy-Item -Path $FoxFavIconsStorePath -Destination "$OneFoxStore\$FoxFavIconsName" -Force
    #New-Item -ItemType HardLink -Path "$OneFoxStore\$FoxPlacesName" -Value $FoxPlacesStorePath -ErrorAction SilentlyContinue
    #New-Item -ItemType HardLink -Path "$OneFoxStore\$FoxFavIconsName" -Value $FoxFavIconsStorePath -ErrorAction SilentlyContinue

    #Edge Bookmarks
    Copy-Item -Path $DefaultEdge -Destination $OneEdge -Force
    #New-Item -ItemType HardLink -Path $OneEdge -Value $DefaultEdge -ErrorAction SilentlyContinue

    # Define the source and target directories
    $sourceDirectory = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
    $targetDirectory = "$BaseDirectory\Edge Favorites"

    # Get all directories that start with "Profile" in the source directory
    $profileFolders = Get-ChildItem -Path $sourceDirectory -Directory -Filter "Profile*"

    # Loop through each found profile folder
    foreach ($profileFolder in $profileFolders) {
        # Construct the full path of the new folder to create in the target directory
        $newFolderPath = Join-Path -Path $targetDirectory -ChildPath $profileFolder.Name

        # Create the new folder if it doesn't exist
        if (-not (Test-Path -Path $newFolderPath)) {
            New-Item -Path $newFolderPath -ItemType Directory
        }

        # Define the source path of the Bookmarks file
        $sourceBookmarksFile = Join-Path -Path $profileFolder.FullName -ChildPath "Bookmarks"

        # Define the target path of the Bookmarks file
        $targetBookmarksFile = Join-Path -Path $newFolderPath -ChildPath "Bookmarks"

        # Copy the Bookmarks file if it exists in the source directory
        if (Test-Path -Path $sourceBookmarksFile) {
            Copy-Item -Path $sourceBookmarksFile -Destination $targetBookmarksFile -Force
        }
    }
}

#Hide Folder
$files = Get-ChildItem -Path $BaseDirectory -File -Recurse
if ($Files) {
    $folder = Get-Item -Path $BaseDirectory
    $folder.Attributes = [System.IO.FileAttributes]::Hidden
}