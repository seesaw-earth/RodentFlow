---
title: "Phone to Mac sync"
description: "Send analyses from RodentFlow on iPhone or iPad to the Mac automatically through a folder you choose, with a check that the Mac reproduces the phone’s numbers."
---

# Phone to Mac sync

Analyses finished on an iPhone or iPad can appear on the Mac by themselves, filed under the right task, group and animal. The two apps exchange them through a folder you choose, usually in iCloud Drive; nothing passes through any other server.

## Set it up {#setup}

1. **iPhone or iPad:** Settings › **Mac sync** › **Choose sync folder…**. A new folder in iCloud Drive, for example `RodentFlow`, works well. Optionally also write a copy of each video (videos can be large).
2. **Mac:** Settings (<kbd>⌘</kbd><kbd>,</kbd>) › **Phone data** › choose the same folder (the folder itself or the `RodentFlow Sync` folder inside it).

## What happens {#how}

- Each time the phone finishes an analysis, or you change its calibration, settings, animal ID or group, it writes a sync package for that analysis.
- The Mac looks for new packages when it starts, every 30 seconds, when you switch back to it, and when you click *Check now*. It checks the size and checksum of every file, waits for packages that are still syncing, and does not import damaged ones.
- Each analysis is copied into the Mac’s own storage and filed by task → group → animal → session (date and session number). A newer version from the phone **updates the same session in place**, keeping your review notes. A session you delete on the Mac is not imported again unless the phone changes it.
- The Mac **recomputes** each imported analysis with the same code and shows on the results page whether it matches the phone (“matches the results on the phone, n measures compared”) or lists the measures that differ.
- Imported sessions are marked *From phone* in the sidebar.

## What is included {#contents}

| Analysis | Package contents |
|---|---|
| Pose | Settings (`session.json`), tracks (`pose.mpt`) and the calibration frame |
| Classic centroid | The tracked samples, the arena setup and the calibration frame |
| Tail suspension, multi-chamber | The full recording archive, the same format as on the Mac |

Without a video copy, an imported session cannot be re-calibrated on the Mac; its results, figures and exports are complete. Turn on the video copy on the phone when you need that.
