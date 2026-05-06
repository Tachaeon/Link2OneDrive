# Link2OneDrive

Backs up user application data to OneDrive for Business and restores it when a user moves to a new computer.

## Scripts

Use the **v2** scripts for all new deployments. The originals are kept for reference.

### Create-ScheduleTask_v2.ps1 — run once per machine (requires elevation)

- Creates `C:\ProgramData\Scripts` if it does not exist
- Copies `Create-Backup_v2.ps1` to that directory
- Creates a `.pc` identity file named after the current computer
- Registers the scheduled task **"Signature, Favorites, & Sticky Notes Backup"** to run at every user logon, hidden, under `NT AUTHORITY\Authenticated Users`

### Create-Backup_v2.ps1 — runs automatically at logon

- Creates `$env:OneDriveCommercial\.DONOTDELETE` with subdirectories for each app
- Backs up: Outlook Signatures (including image asset subfolders), Sticky Notes, Chrome bookmarks, Firefox bookmarks, Firefox Store (MSIX) bookmarks, and Edge bookmarks (Default profile + named profiles)
- Only runs if the `.pc` identity file matches the current computer name — prevents overwriting the backup while a restore is in progress on a new machine
- Silently skips any application that is not installed
- Hides the `.DONOTDELETE` folder from users

### Restore-Backup_v2.ps1 — run manually on a new or replacement computer

- Only runs if the `.pc` identity file does **not** match the current computer name
- Restores all backed-up data to their original application paths
- Firefox files are restored into the active `*.default-release` profile (Firefox must have been launched once before running this script)
- Edge named profiles are only restored if Edge has already created those profile folders on the new machine
- Removes the old `.pc` file and writes a new one for the current computer, enabling backups from this machine going forward

### Force-Backup_v2.ps1

- Starts the scheduled task immediately without waiting for a logon event
- Prints a warning if the task has not been registered yet

---

> **How the `.pc` file works:** `C:\ProgramData\Scripts\[COMPUTERNAME].pc` acts as a machine identity token. The backup script only runs when the filename matches the current computer; the restore script only runs when it does not. After a restore, the file is rewritten with the new computer name so future logons trigger backups instead.
