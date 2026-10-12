# Full-analysis interruption protection

This build keeps the existing 10 Hz classic-centroid tracking and final JSON exports, and adds recoverable long-video analysis.

## What changed

- Imported source videos are copied to `Application Support/RodentFlow/ImportedVideos` instead of the system temporary directory while the experiment is active.
- Source copies are excluded from device backup and are deleted on normal reset when no recovery session needs them.
- Full analysis writes an atomic checkpoint approximately every 300 samples (~30 seconds at 10 Hz).
- Checkpoints are independent JSON chunks under `Application Support/RodentFlow/ActiveAnalysis/<run-id>/checkpoints`.
- Each checkpoint stores the tracking samples in that chunk plus the minimal temporal tracker state (`previous centroid`, `previous blob area`) and the next 10 Hz target timestamp.
- `run_state.json` is also atomic. Resume scans checkpoint chunks directly, so a completed chunk can still be recovered if the app dies before `run_state.json` is refreshed.
- `Pause & Save` cancels only after the analyzer flushes the current in-memory tail to a checkpoint.
- Entering the background automatically uses the same pause-and-save path. A short UIKit background task is requested only to finish the checkpoint write.
- On relaunch, the Home screen detects the newest unfinished run and offers **Resume Analysis** or **Delete**.
- On the original Preview screen, a paused run offers **Resume Analysis** or **Start Over**.
- Recovery files are removed only after `full_tracking.json`, `summary.json`, metadata/video-info JSON, optional maze-events JSON, and the experiment archive folder are all written successfully.

## Failure window

During normal foreground analysis, an abrupt process/power loss can discard at most the uncheckpointed tail (about 30 seconds). User pause and app-background transitions force an immediate checkpoint, so their expected loss window is much smaller.

## Suggested device tests

1. Analyze a 10+ minute video; confirm checkpoint count grows roughly every 30 seconds.
2. Tap **Pause & Save** around 40–70%; confirm Resume continues from the saved percentage and sample count.
3. During analysis, switch to another app; confirm analysis pauses and shows a resumable checkpoint when returning.
4. Force-quit after at least one checkpoint, relaunch, and use **Resume Analysis**.
5. Compare resumed output with an uninterrupted run from the same video; sample count/timestamps and trajectory should remain continuous around the resume boundary.
6. Finish a run and confirm `ActiveAnalysis/<run-id>` is removed while the final experiment folder remains.
