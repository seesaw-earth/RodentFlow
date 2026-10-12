# Changelog

Release notes of the RodentFlow iPhone app, newest first. The user-facing summary is also on the manual site: https://seesaw-earth.github.io/RodentFlow/reference/changelog.html

## 1.3

### What's new in 1.3 (简体中文 / Simplified Chinese)

RodentFlow now runs in **English or Simplified Chinese** from the same project and the same app build.

- **Which language is used:** the app follows the iPhone language (Settings › General › Language & Region). On a phone set to 简体中文 it opens in Chinese, otherwise in English. A different language can be chosen for RodentFlow alone in **Settings › Apps › RodentFlow › Language** (iOS 18; on iOS 17: Settings › RodentFlow › Preferred Language). The **Aa** menu has a **Language / 语言** button that opens that page. iOS restarts the app after a language change; an analysis that is running is paused and saved, as when leaving the app.
- **What is translated:** all screens, buttons and messages, assay and metric names, metric definitions and Methods notes, QC warnings, statistics wording (test names, method summaries, notes), chart labels, the exported figure and the copied text summary — about 1,000 strings in `RodentFlow/Localizable.xcstrings` (Xcode String Catalog).
- **What stays the same in both languages:** stored and exported data. Result files, CSV templates and column names, JSON keys, assay ids, phases ("Probe", "Test" …), metric keys and parameter keys are English, so files made on an English phone open on a Chinese phone and vice versa. Text written into a file at the moment it is created (QC warnings, statistics notes, exported figure, PNG / JSON file names that contain a measure name) is in the language that was active then.
- **Chinese table headers:** imports also accept Chinese column names — 编号 / 动物编号 (subject), 组别 / 分组 (group), 性别 (sex, 雄 / 雌), 天 (day), 试次 (trial), 阶段 (phase), 日期, 备注 — in either language. When the app runs in Chinese, metric and raw-field headers can also be the Chinese names shown in the app (e.g. 总距离 (m), 中央区时间 (%)); English names are always accepted. Example: `SampleData/example_open_field_chinese_headers.csv`.
- Phases typed in Chinese in an imported table (e.g. 探索测试) are stored as the English phase ("Probe").
- Small fixes found during the translation work: the import preview now lists every recognized column; row buttons in manual entry read "Add day / Add trial / Add CS …".

Terminology used in Chinese: 旷场, 高架十字迷宫, 明暗箱, 埋珠实验, 糖水偏好, Y 迷宫, T 迷宫, 新物体识别, Morris 水迷宫, Barnes 迷宫, 恐惧条件化, 平衡木, 步态分析, 条件性位置偏好, 双臂老虎机任务; 僵直, 潜伏期, 进臂, 开放臂 / 闭合臂, 目标象限, 自发交替率, 辨别指数; statistics names keep the usual form (Welch t 检验, Mann–Whitney U 检验, 单因素方差分析, Tukey–Kramer HSD, Greenhouse–Geisser 校正, Hedges' g).

See [`dev-notes/LOCALIZATION.md`](dev-notes/LOCALIZATION.md) for how the translation is organized and how to add or change text.

## 1.2.1

### What's new in 1.2.1 (smoother screen changes)

Freezes at screen changes came from work on the main thread (the thread that draws the screen and handles taps) and from redrawing more than necessary. Apple's guideline: main-thread work in response to a tap should stay under ~100 ms, or the app feels unresponsive.

- **Choosing a video:** the copy of the video into the app is made in the background (it blocked the screen for seconds with large files from Files / iCloud). Videos from Photos are moved instead of copied a second time.
- **Opening the preview:** the video player is created after the screen has appeared, from an asset loaded asynchronously; only the tracking overlay redraws during playback (15 Hz instead of 30 Hz).
- **End of the full analysis:** writing the JSON files and the run folder, and cleaning up checkpoints, run in the background. Starting or resuming an analysis reads and writes the recovery files in the background too.
- **During the analysis:** progress is published at most 5 times per second, and the top-level view no longer observes the app state, so a progress update redraws only the visible screen (not both tabs).
- **Closing a video / Next animal:** the imported video copy is deleted in the background.
- **Typing:** typing in the setup form or the result details no longer redraws the calibration image or the tracking plots on every keystroke.
- **Groups tab:** statistics are recomputed only when the data or the analysis choices change, not every time the tab is opened.

## 1.2

### What's new in 1.2 (easier to use)

- **Larger, adjustable text.** All text uses a type scale about 1.5 pt larger than before and now follows the text size. The **Aa** button (start screen, setup, preview, Groups) offers Small · Standard · Large · Extra large · Largest, or "Same as iPhone".
- **Step bar for the video workflow.** Start → Set up → Preview → Result is shown at the top of every workflow screen. Completed steps show a check mark; any step that is already possible can be tapped to jump there, forward or back.
- **Back / Next bar.** The same bar at the bottom of every workflow screen: "‹ Start" / "Generate Preview ›" on the setup, "‹ Setup" / "Analyze Full Video ›" → "Result ›" on the preview. Going back to the start screen no longer discards the video; an "Open video" card lets you continue or close it (with confirmation).
- **Stale-preview guard.** If arena, calibration or preview window change after a preview, the app says so and offers "Update Preview" before the full analysis.
- **Batch scoring.** After a result: "Next Animal" keeps assay, group, phase and day, and the next video's setup offers "Use Previous Setup" (arena, calibration, analysis settings) when the assay and video resolution match.
- **Results.** ▲▼ buttons move through all results of the same assay; "Compare in Groups" opens the Groups tab on that assay.
- **Groups tab.** Section chips (Assay · Analysis · Groups · Figure · Statistics) jump to each card; the empty state links back to the Experiment tab.
- **Setup.** A section menu jumps to Video, Experiment, Arena, Settings, Preview window or Calibration.

## 1.1.1

### What's new in 1.1.1 (tracking fixes found with synthetic ground-truth videos)

- **Full-range frames.** Full-video analysis read frames as video-range luma (16–235) while the background came from full-range images (0–255). Every floor pixel was off by ~0.14·gray − 16 levels; a mouse hidden in a covered dark box was still "detected" in every sample. Frames are now expanded to full range.
- **Resting-mouse background repair.** A mouse that sits at one spot in most of the 21 background samples (long closed-arm sitting in the EPM, long freezing, long platform stay) used to become part of the median background; the empty floor there then appeared as a stationary "ghost" that was tracked instead of the mouse. The tracker now finds such ghosts (same place in ≥ 2 samples, each time with an opposite-polarity blob elsewhere, background standing out from the surrounding floor) and rebuilds the background there from the samples in which the spot was empty.
- **Contrast-weighted centroid.** The tracking point is the blob centroid weighted by the background difference. The thin tail flickering in and out of the binary mask at 192-px analysis resolution had pulled the unweighted centroid ~1 cm backwards and added jitter; median tracking error on the test videos fell from ~1 cm to 0.15–0.5 cm, and maze path length is far less inflated.
- **Motion index pixel threshold 12 → 20** (full-range gray levels). Compression flicker on a perfectly still mouse (12–24 levels) had broken freezing bouts into pieces.
- **NOR interaction radius and Barnes hole-zone radius default 6 → 8 cm** (body-centroid proxies; captions explain why).
- Synthetic test videos with frame-by-frame ground truth were used to find these issues; the comparison is published on the manual site (https://seesaw-earth.github.io/RodentFlow/principles/validation.html).

## 1.1

Complete iPhone Xcode project for rodent behavior tracking **and** result processing.

### What's new in 1.1

Two tabs:

- **Experiment** — single-experiment processing. Pick an assay, then analyze a video, enter values by hand, or import a table. Every analysis becomes a per-animal **result record** (subject, group, sex, phase, day, trial, metrics, time series, parameters, QC flags) stored in `Documents/Results`. The result screen shows metrics, trajectory + zones, occupancy heatmap, freezing timeline or bandit choice curve, and lets you change zones / thresholds afterwards with instant re-computation (no re-tracking).
- **Groups** — compare control vs experimental groups (or more). Trials are averaged within animal (n = animals), the test is chosen from the design (Welch t / Mann–Whitney, ANOVA + Tukey / Kruskal–Wallis + Dunn, mixed ANOVA with Greenhouse–Geisser for days / time bins, paired tests, one-sample vs chance), and a publication-style figure is drawn (bar/box/mean ± SEM with individual animals, learning curves, paired lines, significance brackets). Export PNG, statistics JSON, records JSON or a text summary.

Assays (data sources):

| Assay | Video | Manual | CSV |
|---|---|---|---|
| Open Field / Center | ✓ (rect / circle) | ✓ | ✓ |
| Elevated Plus Maze | ✓ (new plus-maze calibration) | ✓ | ✓ |
| Light–Dark Box | ✓ | ✓ | ✓ |
| Conditioned Place Preference | ✓ (2 or 3 chambers) | ✓ | ✓ |
| Novel Object Recognition | ✓ (object markers A/B) | ✓ | ✓ |
| Morris Water Maze | ✓ (platform marker) | ✓ | ✓ |
| Barnes Maze | ✓ (target-hole marker) | ✓ | ✓ |
| Fear Conditioning | ✓ (new motion index → freezing) | ✓ | ✓ |
| Y-Maze / T-Maze | ✓ | ✓ | ✓ |
| Marble Burying, Sucrose Preference, Beam Walking, Gait | — | ✓ | ✓ |
| Two-Armed Bandit | — | trials | ✓ (trial CSV) |
| Other / custom table | — | — | ✓ |

See [`dev-notes/DATA_PROCESSING_DESIGN_1.1.md`](dev-notes/DATA_PROCESSING_DESIGN_1.1.md) (Chinese) for metric definitions, statistics and import formats, and `SampleData/` for synthetic example CSVs.

Tracker changes in 1.1 were additive (10 Hz sampling and 90/10 smoothing unchanged; 1.1.1 changes the centroid weighting and background, see above). 1.1 adds (a) a plus-maze geometry, (b) a per-sample frame-difference motion index and blob area (written to `full_tracking.json` as `motionIndex` / `blobAreaFraction`), and (c) conversion of calibration markers to arena centimeters with the same mapping as the mouse.

---

## 1.0 (original notes)

Complete iPhone Xcode project for lightweight rodent tracking from existing videos.

### Assays / arena types

- Open Field — rectangle
- Open Field — circle
- T-Maze
- Y-Maze

T-Maze calibration uses four centerline points: J (junction), S (start-arm end), L and R (choice-arm ends), plus arm dimensions in centimeters.

Y-Maze calibration uses J (junction) and A/B/C arm endpoints, plus arm length and width.

### Tracking rule

The detector remains the simple classic-centroid tracker:

1. Fixed temporal-median background from sparse frames across the recording.
2. Grayscale absolute difference inside the calibrated arena/maze mask.
3. Adaptive threshold + very light cleanup.
4. Connected foreground components.
5. Select the most mouse-like component using area, temporal continuity, size continuity, contrast and fill.
6. Tracking point = ordinary centroid of that selected foreground component.
7. Very light temporal smoothing: 90% current centroid + 10% previous point.

No tail-specific processing, pose model, YOLO, optical flow or VLM is used.

### Sampling

- 10-second preview: 10 Hz.
- Full-video analysis: the complete recording from start to finish at 10 Hz.
- Both use original media presentation timestamps.
- Preview and full analysis use the same tracker.
- Working tracking resolution is 192 px on the longest side. The tracker scans only a padded arena ROI and reuses its working buffers to reduce full-video CPU/memory churn.

### Progress UI

Preview and full analysis show:

- colored progress bar
- percent complete
- processed / estimated samples
- elapsed time
- dynamically estimated remaining time

### JSON only

There is no CSV export in this build.

After a full analysis the app automatically creates a run folder in its Documents area containing:

- `preview_tracking.json`
- `full_tracking.json`
- `summary.json`
- `metadata.json`
- `video_info.json`
- `maze_events.json` for T-Maze / Y-Maze

`video_info.json` stores the original filename, source, duration, resolution, nominal source FPS, creation date and experiment identity. The source video itself is not duplicated into the run folder, avoiding large storage duplication.

The app enables iOS file sharing / document access, so the experiment folder can be accessed from Files and shared from the result screen.

### Device configuration

- iPhone only
- iOS 17.0+
- designed for iPhone 13-class hardware and newer
- generated launch screen enabled for modern full-screen iPhone layout

Open `RodentFlow.xcodeproj`, select your signing Team, choose your iPhone, and Run (see the README for building from source).
