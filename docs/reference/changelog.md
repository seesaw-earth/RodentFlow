# Release notes

Releases of RodentFlow for iPhone 1.x are listed first, then the [Mac app](#mac).

## Open source (October 2026)

- The source code of RodentFlow 1.3 and this manual are published at [github.com/seesaw-earth/RodentFlow](https://github.com/seesaw-earth/RodentFlow) under the MIT License. See [Open source & building](../source.md).

## 1.3: Simplified Chinese

- The whole app is available in **English and Simplified Chinese**: screens, assay and metric names, definitions, methods notes, quality flags, statistics wording, figures and the text summary. It follows the iPhone language. **Aa › Language / 语言** opens the setting for choosing a different language for RodentFlow alone.
- Stored data are language-independent: result files, JSON keys, assay ids, phases and CSV template columns stay English, so files move freely between phones set to different languages.
- Imports accept Chinese column names (编号, 组别, 性别, 天, 试次, 阶段, 日期, 备注), and, when the app runs in Chinese, the Chinese metric names shown in the app.
- The import preview lists every recognized column.

## 1.2.1: smoother

- No more pauses when choosing a video, opening the preview, finishing an analysis or switching tabs. Copying videos, writing result files and loading checkpoints moved off the main thread, and progress updates redraw only what changed.

## 1.2: easier to use

- Larger, adjustable text (**Aa**: Small to Largest, or same as iPhone).
- A step bar (Start → Set up → Preview → Result) and a back/next bar on every workflow screen.
- A reminder to update the preview if the setup changed after it was made.
- Batch scoring: **Next Animal** keeps assay, group, phase and day; **Use Previous Setup** reuses arena, calibration and settings.
- ▲▼ navigation between results of one assay, and **Compare in Groups** from any result.
- Section chips in the Groups tab and a section menu on the setup screen.

## 1.1.1: tracking accuracy

Fixes found with synthetic videos of known ground truth:

- Frames are read on the full 0–255 gray scale, matching the background. A mouse hidden in a covered dark box is no longer "detected".
- **Resting-animal repair** of the background removes "ghosts" left by an animal that rested at one spot for much of the video.
- **Contrast-weighted centroid**: median position error fell from about 1 cm to 0.15–0.5 cm, and path length in mazes is far less inflated.
- The motion-index pixel threshold was raised from 12 to 20 gray levels, so compression flicker no longer breaks freezing bouts apart.
- Default object-interaction and Barnes hole-zone radii raised from 6 to 8 cm (body-center proxies).

## 1.1: from tracking to group statistics

- Two tabs: **Experiment** (per-animal results) and **Groups** (group comparison).
- 15 assays plus custom tables, from video, manual entry or CSV/JSON import.
- Plus-maze calibration; object, platform and target-hole markers; motion index for freezing.
- Results with editable zones and thresholds, recomputed without re-tracking.
- Statistics chosen from the design, with figures showing every animal and export to PNG and JSON.

## 1.0

- Classic-centroid tracking of open field (rectangle or circle), T-maze and Y-maze videos at 10 Hz, with preview, full analysis, recoverable checkpoints and JSON export.

## Mac app (formerly RodentStudio) {#mac}

### Release candidate 0.6.3 (build 6)

#### Release preparation

- Improved task notes, matching-task consolidation safeguards and task deletion controls.
- macOS app icon asset preparation.
- Privacy manifest and App Store release metadata draft.
- Archive-specific compatibility correction for FP16 decoding on Intel (x86_64) build targets.

::: info
**Not yet a published release:** Successful Xcode Archive, signing, App Store Connect processing and final research workflow tests are required before release.
:::

#### Model support in the inspected build

MousePose6_960_int8 and CylinderMousePoseV2 are the two integrated model families. Additional weights published separately are not evidence of integration into this build.
