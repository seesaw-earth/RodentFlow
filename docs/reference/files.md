---
title: "Files and formats"
description: "The files RodentFlow reads and writes: videos, pose tracks, session settings, sync packages, tail-suspension archives and every export."
---

# Files and formats

## What RodentFlow reads {#input}

- **Videos:** MP4 and MOV with H.264 or HEVC, any frame rate and resolution. Timestamps are read from the file, so variable frame rates are handled correctly.
- **Tables** (iPhone and iPad): CSV or TSV for manual results; see [Manual entry & importing tables](../guide/manual-and-import.md).
- **Earlier data:** RodentFlow 1.x results and runs, pose analyses from before 2.0, and Mac workspaces and runs from earlier Mac versions open as they are.

## What RodentFlow keeps {#stored}

| Content | Format |
|---|---|
| Pose session | `session.json`: animal fields, calibration, settings, model, review verdict |
| Pose tracks | `pose.mpt` (identical on phone and Mac; two-animal files include identity) |
| Long recordings on the Mac, while tracking | `pose_stream.json` plus one `segment_*.csv` per 60 s of video, assembled into `pose.mpt` at the end |
| Manual scoring | `manual_annotations.json` in the session folder |
| Classic centroid | Result files and run folders as in RodentFlow 1.x |
| Tail suspension, multi-chamber | `record.json`, `measures.json` and CSV (identical on phone and Mac) |
| Sync package | `RodentFlow Sync/<device>/<id>.rfsession/` with `manifest.json` (file sizes and checksums) and the data files |

## What RodentFlow exports {#exports}

All exports use English column names and keys, whatever the interface language.

| Export | Files |
|---|---|
| Session measures | One row per session: measures, animal fields, settings, model |
| Frame-by-frame | CSV per frame: time, frame number, keypoints in cm, speed, head direction, body heading, zones, behaviour and quality flags (`outside_arena`, `outside_arena_dist_cm`), `recording_start` |
| DeepLabCut format | `*_DLC.csv` with `scorer`, `individuals` (two mice), `bodyparts`, `coords` header rows |
| Behaviour segments | `*_segments.csv`, `*_events_boris.csv`, `*_segments_metadata.json`, and `*_agreement.csv` when there are manual marks |
| Session report | Full JSON with settings, calibration, measures and events |
| Figures | PDF, PNG (300 / 600 dpi), SVG on the Mac |
| Group comparison | `figure.*`, `figure_source_data.csv`, `figure_legend.txt`, `stats_report.csv`, `methods.txt`, `prism_table.txt`, `long_format.csv`, `summary.txt`, `comparison_result.json`, `README.txt` |
| Task export (Mac) | A folder of CSV files for every session of a task, with `README_methods.txt` |
| Tail suspension | Per-chamber immobility, bouts and per-minute tables; see [Mac exports](../mac/exports.md#tst) |

See [Results and exports](../guide/results.md) and [Comparing groups](../guide/groups.md#export) for what each column means.
