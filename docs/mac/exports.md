# Exports explained (Mac)

All exports use **English column names and identifiers**, whatever the interface language, and keep your original IDs. Text you typed (animal IDs, group names, notes, exclusion reasons) is exported as typed — type it in English if you need an all-English dataset. Each export creates a **new folder** inside the folder you choose, so nothing is overwritten.

## Task-level and group-level export

Task page → *Export* → **Export task data…**, or group page → **Export group data…**

| File                  | Contents                                                                                                                                                                                             | Use it for                          |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------|
| `sessions.csv`        | One row per session: task, animal, group, sex, date, session number, phase/day/trial, exclusion and reason, status, tracking check, QC warnings, analysis window, primary measure, video file, notes | Audit trail, linking back to videos |
| `metrics_long.csv`    | One row per session × measure (key, English name, unit, value, primary?)                                                                                                                             | Tidy data for R / pandas            |
| `metrics_wide.csv`    | One row per session, one column per measure                                                                                                                                                          | Excel, quick plotting               |
| `animals.csv`         | Per animal × phase: mean of included sessions, count, session numbers and dates                                                                                                                      | **Statistics (n = animals)**        |
| `group_summary.csv`   | Per phase × group × measure: n, mean, SD, SEM, median, quartiles, min, max                                                                                                                           | Tables in papers                    |
| `timecourse_long.csv` | Session × time bin (e.g. TST minutes)                                                                                                                                                                | Repeated-measures / mixed models    |
| `README_methods.txt`  | How the numbers were obtained, counts, exclusions with reasons, warnings                                                                                                                             | Methods section, reviewers          |

## Frame-by-frame tracking (DeepLabCut-style)

Task or group page → **Export frame data…** (runs in the background; about 1 MB per minute of video per session).

- **RodentPose / RodentLimb:** `frames/<animal>_<date>_S<n>_DLC.csv` in DeepLabCut format (three header rows: scorer / bodyparts / coords; x, y, likelihood per keypoint) plus `…_frames.csv` with video time, frame number, in-window flag, detection confidence and inference-failure flag.
- **RodentFlow:** `…_centroid.csv` (image and arena coordinates in px, normalised units and cm; confidence, interpolation flag, zone, motion index), a one-point DLC file, and `…_maze_events.csv` where applicable.
- `frames_index.csv` and `frames_metadata.json` list every session, model, keypoint names, frame counts, analysis window and any read errors.
- Conventions: upright image pixels, origin top-left, x right, y down (as DLC). Missing keypoints have empty x/y and likelihood 0. `inference_failed = 1` means the model did not run — not the same as “no animal in view”.

<!-- -->

    # Python / pandas
    import pandas as pd
    df = pd.read_csv("frames/M01_2026-10-17_S1_DLC.csv", header=[0, 1, 2], index_col=0)

These files work with downstream tools such as [DeepLabCut](https://deeplabcut.github.io/DeepLabCut/) analysis utilities, [SimBA](https://github.com/sgoldenlab/simba), [B-SOiD](https://github.com/YttriLab/B-SOID) and [keypoint-MoSeq](https://keypoint-moseq.readthedocs.io/).

## TST multi-chamber files

Included automatically in task/group exports, or via **Export TST data only (JSON + CSV)…**

| File                                                          | Contents                                                                                                                                                       |
|---------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `tst_animals.csv`                                             | Per animal: mean of included sessions — **use this for statistics**                                                                                            |
| `tst_sessions.csv`                                            | Per session: identity, timing (hung at, key frame, window, recorded fraction), all measures, QC and method settings                                            |
| `tst_minutes_long.csv`                                        | Session × minute after suspension, with completeness flags                                                                                                     |
| `tst_bouts.csv`                                               | Every immobility bout (start, end, duration; from suspension and in video time)                                                                                |
| `tst_frames_long.csv`, `tst_motion_1s.csv`, `tst_frames.json` | The per-frame motion signal itself (scored value, raw value, threshold, immobile, no-mouse) — re-score with any criterion or compare with manual frame scoring |
| `tst_export.json`, `tst_data_dictionary.csv`                  | Everything above in one structured file, plus the meaning and unit of every column                                                                             |

If recordings in one task used different measures or thresholds, the JSON notes warn you that the values are not directly comparable.

::: tip

**Opening CSVs in Excel:** files are UTF-8. If Chinese text in your own notes looks garbled, import via *Data › From Text/CSV* and choose UTF-8 (in Numbers, simply open the file). Measure names use plain ASCII hyphens (e.g. `min 2-6`) to avoid this problem in column headers.

:::
