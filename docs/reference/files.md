# Files & data

RodentFlow keeps its data in two places: the app's **Documents** folder, which you can see in the Files app, and a private support folder. Nothing is stored anywhere else.

## In the Files app

Open *Files › On My iPhone › RodentFlow*.

```text
RodentFlow/
├── Results/
│   ├── open_field/
│   │   └── 3F2A…C1.json          one file per result
│   ├── elevated_plus_maze/
│   └── …                         one folder per assay
└── Experiments/
    └── 2026-03-14_101502_WT01_rectangle_a1b2c3/
        ├── full_tracking.json    every 10 Hz sample
        ├── preview_tracking.json the 10-second preview
        ├── summary.json          totals of the run
        ├── metadata.json         assay, arena, calibration, settings, identity
        ├── video_info.json       source file name, duration, resolution, fps, dates
        ├── maze_events.json      arm entries (T- and Y-maze)
        └── result.json           copy of the result made from this run
```

- **Results/** holds one JSON file per result, in a folder named after the assay id. This is the library shown in the app. Copying these files to another iPhone, or importing an exported bundle there, moves the results.
- **Experiments/** holds one *run folder* per analyzed video, named *date_time_mouse_arena_code*. The source video is **not** copied into the run folder, to save space. Keep your original videos.

## The tracking file

`full_tracking.json` contains one entry per 10 Hz sample:

| Field | Meaning |
|---|---|
| `frameIndex` | Sample number |
| `videoTimeSeconds` | Time of the frame in the video |
| `clipTimeSeconds` | Time from the start of the analysis |
| `xCentimeters`, `yCentimeters` | Position in arena centimeters (origin at the top-left of the arena; for mazes, of the maze's bounding box) |
| `arenaXNormalized`, `arenaYNormalized` | Position as a fraction of the arena (0–1) |
| `imageXNormalized`, `imageYNormalized` | Position as a fraction of the video frame (0–1) |
| `interpolated` | `true` when the animal was **not** detected and the last position was held |
| `confidence` | 0–1 score of the chosen candidate |
| `zone` | Maze zone (`center`, `A`/`B`/`C`, `left`/`right`/`start`, `N`/`E`/`S`/`W`) or `arena` |
| `motionIndex` | Fraction of arena pixels that changed by ≥ 20 gray levels since the previous sample |
| `blobAreaFraction` | Size of the tracked body as a fraction of the arena |

These files are plain JSON. R (`jsonlite`), Python (`json`, `pandas`), MATLAB (`jsondecode`) and most other tools read them directly, so you can compute measures the app does not provide.

## The result file

Each result is one JSON object with:

- identity: `id`, `assay`, `subjectID`, `group`, `sex`, `phase`, `day`, `trial`, `experimentDate`;
- `source`: `video`, `manual` or `imported`;
- `metrics`: metric key → value, e.g. `"center_time_pct": 22.4`;
- `series`, `labels`: time series and text results;
- `parameters`: everything the metrics depended on;
- `qcFlags`, `excluded`, `exclusionReason`, `notes`;
- `zoneConfig` (video results), `manualInput` (manual results), and `runFolderName` (link to the run folder).

Keys, assay ids and phase names are always English, whatever the app language, so files are interchangeable between phones set to different languages. Unknown or missing keys are tolerated when reading, so files from older or newer versions open.

## Exports

| From | Export | Format |
|---|---|---|
| Result screen › share | Share result (JSON); Share tracking folder | JSON; folder |
| After full analysis | Share Run Folder; single JSON files | folder; JSON |
| Groups › export menu | Figure (PNG); Statistics (JSON); All *assay* records (JSON); Copy text summary | PNG; JSON; JSON bundle; text |
| Import sheet | CSV Template for *assay* | CSV |

## Private app data

The following are kept in the app's private support folder and managed automatically:

- the working copy of an open video (deleted when you close the video or tap **Next Animal**);
- checkpoints of a running analysis (deleted when it finishes or you start over);
- the group order, colors and inclusion choices of the Groups tab.

## Backup and moving to a new phone

The Documents folder is included in your normal iPhone backup (iCloud or computer). To move results deliberately, export **All … records (JSON)** for each assay from the Groups tab and import the file on the other phone, or copy the `Results` folder with the Files app.

## Deleting data

- Delete a single result on its result screen, or swipe it away in **All results**. The run folder stays.
- Delete run folders or result files in the Files app.
- Deleting the app deletes all of its data on the phone.
