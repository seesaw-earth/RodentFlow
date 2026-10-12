# RodentFlow 1.3 — build notes

## Version
- MARKETING_VERSION 1.3, CURRENT_PROJECT_VERSION 6.
- Project: `knownRegions = (en, Base, "zh-Hans")`, `LOCALIZATION_PREFERS_STRING_CATALOGS = YES`, `SWIFT_EMIT_LOC_STRINGS = YES` (unchanged), development region `en`.

## New files
- `RodentFlow/Localizable.xcstrings` — String Catalog, source language English, Simplified Chinese (`zh-Hans`) translations; registered in the Resources build phase. All entries are `extractionState: manual`, so Xcode never marks them stale; Xcode may add a few untranslated entries for SwiftUI literals that contain only numbers or placeholders (marked "Don't translate" where predictable).
- `Tools/localization/` — `check_catalog.py` reports interface text that is not translatable, keys missing from the catalog and placeholder mismatches (`python3 Tools/localization/check_catalog.py` from the project folder; Python 3 only, no Xcode needed).
- `SampleData/example_open_field_chinese_headers.csv`.
- `LOCALIZATION.md`.

## How text is localized (no change to tracking, metrics or statistics)
- SwiftUI literals (`Text("Save")`, `Button("Cancel")`, `Label("…", systemImage:)`, `.navigationTitle("…")`, Charts `.value("Group", …)`) are looked up by SwiftUI.
- Everything else goes through `loc(_:)` / `locf(_:_:)` (defined at the top of `AssayCatalog.swift`; `NSLocalizedString` underneath, so the English key is the fallback): assay, metric, field and phase names, definitions, Methods notes, QC flags, parameter values, import messages, error descriptions, statistics test names and method summaries, notices.
- Interpolated interface strings were rewritten as explicit format keys (`locf("%ld samples", n)`), so every key in the catalog is exactly what the app looks up at run time.
- Shared components translate the `String` titles they receive (`SectionCard`, `KeyValueRow`, `MessageBanner`, `MetricTile`, `FlagList`, `OptionalNumberField`, `FlowAction`, `JumpSection`, and the private row helpers of Setup / Preview / Groups / zone settings).
- Stored values stay English: `AssayKind.shortName` (file names) vs `displayShortName`, `englishName` vs `displayName`; `phases` vs `AssayKind.phaseTitle(_:)`; `ManualSchema.rowName` vs `displayRowName` and the row-wording helpers; choice options ("Left" / "Right") are stored as indices and shown with `loc`; series names, parameter and label values are stored in English and translated when shown (`locKey(_:)` for parameter keys).
- Import matching uses both the English and the localized names (`MetricDefinition.englishName`, `ManualField.englishLabel`), plus Chinese aliases for the subject / group / sex / day / trial / phase / date / notes columns and 雄 / 雌 for sex.
- `loc(_:context:)` gives one English word different translations where needed: the tab names ("Experiment" → 实验, "Groups" → 组间分析, while the "Groups" card and the experiment-info section use 组别 / 实验信息), the bandit source "Trials" and the setup "Imported" date.
- Language button: `TextSizeMenu` opens `UIApplication.openSettingsURLString` (the app's own Settings page, where iOS shows the per-app language once the bundle contains more than one localization).

## Verification for 1.3 (Linux, Swift 5.10 with SwiftUI/UIKit stubs)
- Type check of all sources: no errors (except the expected `@main` artifact of the stub setup).
- Integration, engine and statistics tests: all pass, output identical to 1.2.1 (`NSLocalizedString` returns the English key on Linux).
- Tracker check on the synthetic videos (open field, fear cue test, Y-maze): results identical to 1.2.1.
- Same tests with every lookup answered from the catalog's Chinese translations: no crash or placeholder error in any formatted message; Chinese notes, method summaries and QC flags appear as expected (only the tests that compare English sentences differ).
- Bilingual import: English headers, Chinese headers, Chinese sex / phase values, raw sucrose fields, in both languages.
- Catalog: 989 keys used in code, all translated; placeholders (%@, %ld, %.1f, %%) identical and in the same order in every translation; no accidental printf sequences ("% o" etc.) in keys or translations.

# RodentFlow 1.2.1 — build notes

## Version
- MARKETING_VERSION 1.2.1, CURRENT_PROJECT_VERSION 5.

## Responsiveness changes since 1.2 (no change to tracking or statistics)
- `RodentFlowApp` owns `AppState` with `@State` (created once); `ContentView` takes it as a plain `let`, so no view above the screens observes it. In 1.2 every AppState change (e.g. each progress update) rebuilt the root, both tabs and the `AppNavigator` environment value.
- `AppState.importVideo` — video copy in `Task.detached`; Photos temp copies are moved, not copied. `runFullVideoAnalysis` — recovery record creation / resume snapshot loading, all JSON exports and run-folder archiving, and checkpoint cleanup in `Task.detached`. `reset` and video replacement delete files in the background. Analyzer progress throttled with `ProgressThrottle` (≤ 5 updates/s).
- `PreviewView` — the player is created in `.task` after a short delay via `PreviewPlayerController.make` (asset loaded with `load(.isPlayable, .duration)`); the time-dependent overlay is a separate view observing the controller; time observer at 15 Hz.
- `ResultDetailView` — plots in an `Equatable` subview (`TrackingVisuals`, `.equatable()`), freezing trace and windowing computed there; tracking-folder check done once at load.
- `SetupView` — calibration image in an `Equatable` subview (`CalibrationCanvas`).
- `GroupAnalysisViewModel` — `update(records:)` returns early for unchanged records; `run()` skips repeating the same request on the same records.

## How to look for remaining hangs
- On the iPhone: Settings › Developer › Hang Detection (development builds).
- Xcode: Product › Profile › "Time Profiler" or "SwiftUI" template — both include the Hangs instrument; select a hang to see the main-thread stack.
- Scheme › Run › Diagnostics › Thread Performance Checker.

# RodentFlow 1.2 — build notes

## Version
- MARKETING_VERSION 1.2, CURRENT_PROJECT_VERSION 5.
- Build 5: the tab navigator is one long-lived object (no environment churn → screens don't re-render on every progress update), and the text-size modifier uses a single code path (switching to/from "Same as iPhone" no longer rebuilds the screens).

## Changes since 1.1.1 (user interface only — tracking and statistics are unchanged)
- New files (registered in the project): `AppTypography.swift` (scaled `appFont` modifier based on `@ScaledMetric`, `AppTextSize` setting, `TextSizeMenu`), `FlowNavigation.swift` (`WorkflowStepBar`, `FlowNavigationBar`, `SectionJumpBar` / `SectionJumpMenu`, `AppNavigator` environment value for tab switching).
- `ContentView` — tab selection and Groups assay request; `AppNavigator` in the environment; text size applied with `AppTextSizeModifier` (in-app setting or system, capped at xxxLarge).
- `AppState` — workflow helpers (`isStepAvailable`, `isStepDone`, `go(to:)`, `continueStep`, `workflowStatusText`), preview fingerprint (`setupSignature`, `isPreviewStale`), `startNextAnimal`, reusable previous setup; a newly imported or resumed video now replaces (and deletes the copy of) a video that was still open.
- `HomeView`, `SetupView`, `PreviewView`, `ResultDetailView`, `GroupAnalysisView` — step bar, back/next bar, confirmations before closing a video, result browsing (▲▼), cross-tab buttons, section jumps.
- All hard-coded `.font(.system(size:))` in screens and sheets replaced by `.appFont(size + ~1.5)`; chart internals, the exported figure, calibration handles and the tracking overlay keep fixed sizes.
- `PrivacyInfo.xcprivacy` — declares UserDefaults (reason CA92.1) for the text-size preference (`@AppStorage`).

## Verification for 1.2
- Full app type-check against the SwiftUI / UIKit / AVFoundation API stubs (extended for ScaledMetric, ViewModifier, AppStorage, EnvironmentKey, ScrollViewReader, labelStyle with iOS 17 signatures). Engine, statistics, tracker and integration tests re-run unchanged.
- **Not compiled with Xcode and not run on a device** — please build on a Mac; layout at the largest text sizes should be checked on a small iPhone.

# RodentFlow 1.1.1 — build notes

## Version
- MARKETING_VERSION 1.1.1, CURRENT_PROJECT_VERSION 3.

## Changes since 1.1
- `NativeMouseTracker` — full-range conversion of AVAssetReader video-range frames (`videoToFullRange`, applied in `fillGrayscale` when the buffer is `420YpCbCr8BiPlanarVideoRange`); `residentRobustBackground` (ghost detection + repair, exposed as `backgroundRepairedFraction`); contrast-weighted centroid; `motionPixelThreshold` 20, `motionIndexVersion` `frame_difference_v2_fullrange_arena_pixels_delta20_10hz`.
- `ResultModels` — NOR `objectZoneRadiusCM` default 8 cm; Barnes `targetRadiusCM` default 8 cm.
- `ZoneParameterEditor` — captions for the NOR and Barnes radii.
- `AssayEngine` — `motion_pixel_delta` parameter text.

## Verification for 1.1.1 (Linux, Swift 5.10)
- 10 synthetic MP4 test videos (open field, EPM, light–dark, 3-chamber CPP, NOR, MWM acquisition + probe, Barnes, fear cue test, Y-maze) decoded the way iOS reads them (10 Hz, 192×108 video-range Y; 21-frame full-range background) and run through the real `NativeMouseTracker` + `AssayEngine`. All headline metrics agree with independently computed ground truth (see the test-video package README). The EPM path length remains +35% (low resolution in a small maze); everything else is within a few percent or exact.
- New background-repair unit tests (resident dark mouse, resident white mouse, moving mouse, minority rest with reflections, always-still mouse); previous tracker checks, engine scenario tests and integration tests re-run and pass; full app type-check against the API stubs.
- **Not compiled with Xcode** — please build on a Mac and report any compiler message.

# RodentFlow 1.1 — build notes

## Version
- MARKETING_VERSION 1.1, CURRENT_PROJECT_VERSION 2. Bundle ID, signing, privacy manifest unchanged (no new required-reason APIs; no UserDefaults, no file-timestamp APIs).

## New source files (registered in the project)
- Engine (Foundation only): `StatsEngine`, `AssayCatalog`, `ResultModels`, `AssayEngine`, `ManualAssays`, `GroupAnalysis`, `DataImport`, `ResultsStore`, `ArenaMapping`
- State: `ResultsLibrary`, `GroupAnalysisViewModel`
- UI: `UIComponents`, `ManualEntryView`, `ImportSheet`, `AssayVisuals`, `ZoneParameterEditor`, `ResultDetailView`, `GroupChartView`, `GroupAnalysisView`

## Modified files
- `ContentView` — TabView (Experiment / Groups).
- `HomeView` — assay picker, video / manual / import entry points, results list, re-analysis of 1.0 run folders.
- `SetupView` — assay & arena card, sex / phase / day / trial, plus-maze dimensions, analysis settings.
- `ArenaCalibrationView` — plus-maze handles (C/N/E/S/W), object A/B, platform P, target hole T, quadrant / hole-ring / zone previews.
- `PreviewView` — assay result summary and link after full analysis.
- `AppState` — assay context (persisted in recovery records), result creation after full analysis.
- `TrackingModels` — `.plusMaze`, calibration points + markers with tolerant decoding, optional `motionIndex` / `blobAreaFraction` on `TrackingPoint`, `markersCM` on `FullAnalysisResult`.
- `NativeMouseTracker` — plus-maze geometry, motion index, `arenaPoint(rawNormalized:)`.
- `FullVideoAnalyzer` / `PreviewAnalyzer` — plus-maze parameters, marker conversion.
- `ExportService` — motion fields in tracking JSON; `assay` and `motionIndexVersion` in metadata.json.

## Verification done before handoff (Linux, Swift 5.10)
- Statistics engine compiled and compared with SciPy / pingouin / scikit-posthocs: 1,059 / 1,059 checks match.
- Assay computations: scenario tests with known answers for every video assay and the manual assays; Q-learning recovers simulated α/β.
- Group analysis: ANOVA, Tukey, Kruskal–Wallis, Dunn, mixed ANOVA results match references; every design exports to JSON.
- Import: all CSV templates re-import; the six `SampleData` files import and analyze.
- Real tracker run on synthetic frames: plus-maze zones and cm mapping, motion index, marker mapping.
- End-to-end persistence: 1.0 run folders → re-analysis → zone edits → reload → Groups view model.
- All app Swift files type-checked against SwiftUI / Charts / UIKit / AVFoundation API stubs (validated on the unmodified 1.0 code). **Not compiled with Xcode** — build on a Mac and report any compiler message.

---

# RodentFlow 1.0 — build notes (original)

## Changes

- Added T-Maze and Y-Maze arena calibration and zone logic.
- Kept the classic selected-component centroid tracker.
- Reduced temporal smoothing to 90% current / 10% previous to reduce positional lag.
- Preview and full-video analysis both run at 10 Hz.
- Energy optimization: tracking frames are 192 px on the longest side; background frames are generated at the same working resolution.
- Energy optimization: diff/threshold/majority/connected-component work is restricted to the calibrated arena ROI (+2 px padding).
- Energy optimization: grayscale, diff, binary, visited, and component-queue buffers are reused throughout an analysis rather than reallocated per frame.
- Full-video analysis still reads the complete recording sequentially and uses original AVFoundation timestamps.
- Added colored progress bars with percentage, sample count, elapsed time, and ETA.
- Removed all CSV output and UI references.
- All exports are JSON.
- Full analyses are automatically stored in a dedicated experiment folder.
- Each folder includes `video_info.json` describing the corresponding source video without duplicating the large video file.
- iOS Files access remains enabled through `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace`.

## Tracking metadata

`trackingVersion = classic_centroid_v0.1_10hz_smoothing_90_10`

`positionDefinition = centroid_of_selected_foreground_component`

`samplingPolicy = 10_hz_using_original_video_presentation_timestamps`
