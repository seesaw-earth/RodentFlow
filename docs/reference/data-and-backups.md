---
title: "Where your data lives"
description: "Where RodentFlow 2.1 keeps videos, analyses and workspaces on iPhone, iPad and Mac, and how to back them up."
---

# Where your data lives

RodentFlow has no account and no server. Everything stays on your devices and in folders you choose. See the [Privacy Policy](../privacy.md).

## iPhone and iPad {#ios}

- **Pose analyses** are folders under *Files › On My iPhone/iPad › RodentFlow › Sessions*, each with its settings (`session.json`), the tracks (`pose.mpt`), the calibration frame and a copy of the video.
- **Classic centroid results** are under *RodentFlow › Results*, and their runs under *RodentFlow › Experiments*, exactly as in RodentFlow 1.x: results made with 1.x open unchanged after the update.
- **Multi-chamber tail suspension** recordings are kept as archives with their measures, in the same format as on the Mac.
- Device backups (iCloud or a computer) include app data according to your backup settings. For important studies, also export the results or turn on [Mac sync](./sync.md).

## Mac {#mac}

- **Your videos** stay where you put them and are only read. If you move or rename one, use **Locate video** to link it again.
- **The workspace** (projects, tasks, sessions, calibrations, review verdicts) and the **tracking runs** are in the app’s container:  
  `~/Library/Containers/com.ziqingshi.rodentflow/Data/Library/Application Support/RodentDesktopNative/`  
  (`workspace.json` and the `Runs` folder). In Finder use *Go › Go to Folder…* (<kbd>⇧</kbd><kbd>⌘</kbd><kbd>G</kbd>) and paste the path.
- Long recordings are written to disk while they are tracked, in one file per minute of video, and assembled into the same `pose.mpt` as on the phone when they finish.
- Analyses imported from the phone are copied into the Mac’s own storage.
- Before any automatic merge of tasks, a backup of the workspace is written next to it.

## Backing up {#backup}

Back up your video folders, the container folder above and your export folders; [Time Machine](https://support.apple.com/104984) does all three. Quit RodentFlow before copying the workspace by hand. Removing a video or deleting a task in the app does not delete source videos or tracking folders, so nothing is lost by accident.
