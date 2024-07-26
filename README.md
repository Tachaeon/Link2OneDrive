# Link2OneDrive

Create-ScheduleTask.ps1

  What it does:
  - Creates "C:\ProgramData\Scripts" if doesn't exist.
  - Copies Create-Backup.ps1 to "C:\ProgramData\Scripts".
  - Creates a file with the name of the local machine with the extension .pc
  - Creates a System Task that runs as the Local User. ("Signature, Favorites, & Sticky Notes Backup").
  - Runs as User
  - Runs on Login

Create-Backup.ps1

  What it does:
  - Creates "$env:OneDriveCommercial\.DONOTDELETE" in the users OneDrive with "Chrome Favorites", "Signatures", "Sticky Notes", "Firefox Favorites", "Edge Favorites", "Firefox Store Favorites" subdirectories.
  - If the .pc file matches the computer name the script will:
  - Copy Outlook Signatures, Chrome Favorites, Firefox Favorites, Firefox (Windows Store) Favorites, Sticky Notes, and Edge Favorites with separate folders for profiles if it finds any.
  - Hides .DONOTDELETE folder from the user.

Restore-Backup.ps1

  What it does:
  - Copies all of the files from the .DONOTDELETE subdirectories to their respected app paths.
  - Removes *.pc from C:\ProgramData\Scripts
  - Creates a new .pc file using the new PC name.

The purpose of the .pc file is so if the user gets issued a new computer or the computer name changes, Create-Backup won't overwrite the files carried over from OneDrive.
