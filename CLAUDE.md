# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Link2OneDrive is a PowerShell-based utility that backs up user application data (Outlook Signatures, browser bookmarks, Sticky Notes) to OneDrive, and restores them when a user migrates to a new computer.

## Script Execution

There is no build system. Scripts are run directly:

Use the **v2 scripts** for all work. The originals are kept for reference only.

| Script | When to run |
|---|---|
| `Create-ScheduleTask_v2.ps1` | Once on initial setup (requires elevation) — copies backup script to `C:\ProgramData\Scripts`, creates the `.pc` identity file, registers the Windows Scheduled Task |
| `Create-Backup_v2.ps1` | Automatically via Task Scheduler at logon; also the script deployed to `C:\ProgramData\Scripts\` |
| `Restore-Backup_v2.ps1` | Manually on a new/replacement computer to restore backed-up data |
| `Force-Backup_v2.ps1` | Manually to trigger the scheduled task immediately without waiting for logon |

To run any script directly in PowerShell:
```powershell
.\Create-ScheduleTask_v2.ps1   # initial setup
.\Force-Backup_v2.ps1          # trigger backup now
.\Restore-Backup_v2.ps1        # restore on new machine
```

## Architecture

### Computer Identity Mechanism

The central safeguard is a `.pc` file at `C:\ProgramData\Scripts\[COMPUTERNAME].pc`:

- **Backup guard**: `Create-Backup.ps1` only runs if the `.pc` filename matches `$env:COMPUTERNAME`. This prevents a new machine (which has synced OneDrive but has a different name) from overwriting the existing backup.
- **Restore guard**: `Restore-Backup.ps1` only runs if the `.pc` filename does **not** match `$env:COMPUTERNAME`. After restoring, it deletes the old `.pc` and creates a new one with the current machine name, enabling future backups from this machine.

### Backup Storage

All backups go to `$env:OneDriveCommercial\.DONOTDELETE\` with subfolders per application. This folder is hidden from users via `attrib +h`. The `.DONOTDELETE` name and hidden attribute are the only things preventing users from deleting their backups.

### Data Flow

```
New machine setup:  Create-ScheduleTask_v2.ps1 → .pc file created → Task Scheduler registered
Normal operation:   Logon → Task Scheduler → Create-Backup_v2.ps1 → copies to OneDrive/.DONOTDELETE
Migration:          OneDrive syncs to new machine → Restore-Backup_v2.ps1 → restores files → new .pc created
```

### Key Environment Variables

| Variable | Used for |
|---|---|
| `$env:OneDriveCommercial` | Root of backup destination (OneDrive for Business) |
| `$env:COMPUTERNAME` | Matched against the `.pc` identity file |
| `$env:APPDATA` | Roaming app data (Signatures, Firefox) |
| `$env:LOCALAPPDATA` | Local app data (Chrome, Edge, Sticky Notes, Firefox Store) |

### Firefox Profile Discovery

Both Firefox variants (classic and Store/MSIX) use dynamic profile discovery: `Get-ChildItem` enumerates profiles under the Firefox `Profiles\` directory and iterates each one, since profile folder names are randomly generated.

Edge bookmarks use a similar pattern to handle both the `Default` profile and numbered profiles (`Profile 1`, `Profile 2`, etc.).
