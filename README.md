# Link2OneDrive

Create-ScheduleTask.ps1:
  What it does:
  - Creates C:\ProgramData\Scripts" if doesn't exist.
  - Creates a file with the name of the local machine with the extension .pc
  - Creates a System Task that runs as the Local User. ("Signature, Favorites, & Sticky Notes Backup").
  - Runs as User
  - Runs on Login

Create-Backup.ps1:
  What it does:
  - Creates "$env:OneDriveCommercial\.DONOTDELETE" in the users OneDrive with "Chrome Favorites", "Signatures", "Sticky Notes", "Firefox Favorites", "Edge Favorites", "Firefox Store Favorites" subdirectories.
  - Copies Outlook Signatures, Chrome Favorites, Firefox Favorites, Firefox (Windows Store) Favorites, Sticky Notes, and Edge Favorites with separate folders for profiles if it finds any.
  - Hides .DONOTDELETE folder from the user.
