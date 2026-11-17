# Source code

RodentFlow's code, its Core ML models, the model tutorials and this manual are all public on GitHub. The repositories that hold the Mac and pose-tracking code still carry the earlier project name, **RodentStudio**.

| Repository | What it contains | Licence |
|---|---|---|
| [**seesaw-earth/RodentFlow**](https://github.com/seesaw-earth/RodentFlow) | RodentFlow for iPhone 1.x: centroid tracker, metrics, statistics, manual entry and table import. Also the source of this website, in [`docs/`](https://github.com/seesaw-earth/RodentFlow/tree/main/docs). | [MIT](https://github.com/seesaw-earth/RodentFlow/blob/main/LICENSE) |
| [**seesaw-earth/RodentStudio-Support › source**](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source) | **RodentFlow 2.1** for Mac and for iPhone & iPad; the released version is tagged [`v2.1`](https://github.com/seesaw-earth/RodentStudio-Support/tree/v2.1/source). The two Xcode projects (`source/macOS/RodentFlow-2.1`, `source/iOS/RodentFlow-2.1`), the shared analysis engine in `Shared/` (pose workflows, classic centroid tracking, multi-chamber tail suspension, statistics and exports), the Core ML models and the engine's tests. The earlier sources (RodentStudio 0.7.1 for Mac and RodentPose for iPhone & iPad) are kept beside them. | AGPL-3.0 (a licence file in each project) |
| [**seesaw-earth/RodentFlow-Windows**](https://github.com/seesaw-earth/RodentFlow-Windows) | [RodentFlow for Windows](./windows/): the RodentFlow analysis engine compiled for Windows, the C# host (FFmpeg video reading, ONNX Runtime, WinUI 3 window), a command-line tool, the model export notebook, and the [privacy policy](https://github.com/seesaw-earth/RodentFlow-Windows/blob/main/PRIVACY.md) and third-party notices of the Windows app. | [AGPL-3.0](https://github.com/seesaw-earth/RodentFlow-Windows/blob/main/LICENSE) |
| [**seesaw-earth/RodentStudio-CoreML-Models**](https://github.com/seesaw-earth/RodentStudio-CoreML-Models) | The Core ML model packages, with weights in Git LFS. | See [Core ML models](./models.md#licences) |
| [**seesaw-earth/RodentStudio-Tutorials**](https://github.com/seesaw-earth/RodentStudio-Tutorials) | The original source of the [model tutorials](./tutorials/), `references.bib` and `CITATION.cff`. | See the repository |

::: warning Two licences
The iPhone 1.x code is MIT-licensed. The Mac and pose-tracking code is AGPL-3.0, and the Ultralytics YOLO models it runs carry AGPL-3.0 as well. Check the `LICENSE`, `THIRD_PARTY_NOTICES` and `MODEL_PROVENANCE` files of the code you reuse, and the [licence summary](./tutorials/citations.md#licences) for the models and their training data.
:::

## What open source means for you

- **See exactly how every number is computed.** This manual describes the methods. The code is the final word, and anyone can read it.
- **Check the privacy promise.** You can confirm in the code that the apps do not upload your data. You do not have to take our word for it.
- **Adapt it.** You may modify the apps, for example to add an assay your lab uses, and share your version under the terms of the licence that applies.
- **Report and fix problems in the open.** Issues and pull requests are welcome.

## RodentFlow 2.1: where things are in the code {#code-2-1}

Paths are relative to `source/macOS/RodentFlow-2.1/Shared/`; the iPhone & iPad project holds an identical copy. RodentFlow for Windows compiles the same engine files, byte for byte, from [`engine/Sources/RodentFlowABI/Shared`](https://github.com/seesaw-earth/RodentFlow-Windows/tree/main/engine/Sources/RodentFlowABI/Shared).

| Topic | Source file |
|---|---|
| One frame through the pose model: upright, arena crop, greyscale, letterbox | [`Vision/PoseVision.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Vision/PoseVision.swift), [`Tracking/ArenaROI.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Tracking/ArenaROI.swift) |
| Decoding the model output into keypoints | [`PoseEngine/PoseDecoding.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/PoseDecoding.swift) |
| Which model a run uses | [`PoseEngine/PoseModels.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/PoseModels.swift) |
| Cleaning keypoint tracks: confidence, jumps, gaps, smoothing | [`PoseEngine/Kinematics.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/Kinematics.swift) |
| Two-animal identity: online tracker and whole-video resolver | [`PoseEngine/IdentityTracking.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/IdentityTracking.swift) |
| Groups of 3–10 mice: pose suppression and the fixed-number tracker | [`PoseEngine/GroupTracking.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/GroupTracking.swift) |
| Group measures and dominance hierarchy | [`PoseEngine/AnalyzersGroup.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/AnalyzersGroup.swift), [`PoseEngine/GroupHierarchy.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/GroupHierarchy.swift) |
| Resident–intruder rules | [`PoseEngine/AnalyzersAggression.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/AnalyzersAggression.swift) |
| Statistical tests and group comparison | [`Groups/StatsEngine.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Groups/StatsEngine.swift), [`Groups/GroupAnalysis.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Groups/GroupAnalysis.swift), [`Groups/Survival.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Groups/Survival.swift) |

The engine's tests are in `tools/tests/`; `tools/run_shared_tests.sh` compiles the engine with each test and runs it, on macOS or Linux, with only `swiftc`.

## RodentFlow for iPhone 1.x: where things are in the code

| Topic | Manual page | Source file |
|---|---|---|
| Background, threshold, candidate scoring, centroid, motion index | [Tracking](./principles/tracking.md) | [`NativeMouseTracker.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/NativeMouseTracker.swift) |
| Reading the whole video at 10 Hz, checkpoints | [Analyzing a video](./guide/video-analysis.md) | [`FullVideoAnalyzer.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/FullVideoAnalyzer.swift) |
| Zones, entries, distance, freezing and all video metrics | [From positions to metrics](./principles/metrics.md) | [`AssayEngine.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/AssayEngine.swift) |
| Assays, metric definitions, phases | [Assays](./assays/index.md) | [`AssayCatalog.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/AssayCatalog.swift) |
| Default zones and thresholds | [Assays](./assays/index.md) | [`ResultModels.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/ResultModels.swift) (`ZoneConfig`) |
| Manual entry, two-armed bandit and Q-learning | [Manual entry & import](./guide/manual-and-import.md) | [`ManualAssays.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/ManualAssays.swift) |
| Statistical tests | [Statistics](./principles/statistics.md) | [`StatsEngine.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/StatsEngine.swift) |
| Which test for which design | [Group analysis](./guide/groups.md) | [`GroupAnalysis.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/GroupAnalysis.swift) |
| Table import and column matching | [Manual entry & import](./guide/manual-and-import.md) | [`DataImport.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/DataImport.swift) |
| English and Chinese text | — | [`Localizable.xcstrings`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/Localizable.xcstrings) |

## Build RodentFlow for iPhone 1.x

You need a Mac with **Xcode 15 or later** and an iPhone with **iOS 17 or later**. There are no third-party dependencies.

```bash
git clone https://github.com/seesaw-earth/RodentFlow.git
cd RodentFlow
open RodentFlow.xcodeproj
```

In Xcode:

1. Select the **RodentFlow** target › **Signing & Capabilities**, and choose your own **Team**. A free Apple ID is enough to run the app on your own iPhone.
2. Change the **Bundle Identifier** to one of your own, e.g. `com.yourname.rodentflow`. The identifier in the project belongs to the published app.
3. Connect your iPhone, choose it as the run destination and press **Run** (⌘R).

## Build the Mac and iPhone & iPad pose editions {#build}

The [source code](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source) for both editions is public under AGPL-3.0. You need a Mac with [Xcode](https://developer.apple.com/xcode/) and [Git LFS](https://git-lfs.com/) (the Core ML weights are stored with LFS).

```bash
git clone https://github.com/seesaw-earth/RodentStudio-Support.git
cd RodentStudio-Support
git lfs install
git lfs pull                       # fetch the real model weights

git checkout v2.1                   # the released version (optional)

# Mac edition
open source/macOS/RodentFlow-2.1/macOS/RodentFlow-macOS/RodentFlow.xcodeproj
# iPhone / iPad edition
open source/iOS/RodentFlow-2.1/iOS/RodentFlow-iOS/RodentFlow.xcodeproj
```

Both projects compile the shared engine from `../../Shared`, so keep the folder layout as it is. The earlier projects (`source/macOS/RodentStudio-0.7.1`, `source/iOS/RodentStudio-Mobile-iOS`) remain in the repository for reference.

1.  In Xcode, select the target → *Signing & Capabilities* → choose your own team (change the bundle identifier if needed).
2.  Mac: choose *My Mac*, then *Product › Build* (<kbd>⌘</kbd><kbd>B</kbd>) and *Run* (<kbd>⌘</kbd><kbd>R</kbd>). iPhone/iPad: choose your device (iOS 17+) — see [Apple: Running your app on a device](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device).
3.  If the build complains about a model, check that the `.mlpackage` folders contain real `weight.bin` files (not small LFS pointer files). The [Core ML models repository](https://github.com/seesaw-earth/RodentStudio-CoreML-Models) is a developer resource; app users never need it.

A source checkout is not a signed release and has not necessarily passed final testing. Please test with your own videos before relying on it.

## Build RodentFlow for Windows {#build-windows}

The [RodentFlow-Windows README](https://github.com/seesaw-earth/RodentFlow-Windows#building) lists what you need (Swift for Windows, Visual Studio's C++ tools, the .NET 8 SDK and FFmpeg) and the build commands for the engine, the window and the command-line tool. The ONNX model files are not in the repository; the [export notebook](https://github.com/seesaw-earth/RodentFlow-Windows/tree/main/notebooks) makes them from the model checkpoints. A source build is not the signed Microsoft Store release; test it with your own videos before relying on it.

## Contribute

- **Problems and questions**: [open an issue](https://github.com/seesaw-earth/RodentFlow/issues), or for the Windows app [in RodentFlow-Windows](https://github.com/seesaw-earth/RodentFlow-Windows/issues). See [Support](./support.md) for what to include.
- **Code**: read [CONTRIBUTING.md](https://github.com/seesaw-earth/RodentFlow/blob/main/CONTRIBUTING.md) and open a pull request.
- **This manual**: every page has an *Edit this page on GitHub* link at the bottom. The manual's source is in the [`docs/`](https://github.com/seesaw-earth/RodentFlow/tree/main/docs) folder, with an English and a Chinese version of each page.

## Cite

If RodentFlow contributes to published work, please cite the software and the version you used:

```bibtex
@software{shi2026rodentflow,
  author  = {Shi, Ziqing},
  title   = {RodentFlow: On-device pose tracking and behavior analysis for rodents},
  version = {2.1},
  year    = {2026},
  url     = {https://seesaw-earth.github.io/RodentFlow/}
}
```

For RodentFlow for iPhone 1.x, the repository has a [`CITATION.cff`](https://github.com/seesaw-earth/RodentFlow/blob/main/CITATION.cff) file, so GitHub's **Cite this repository** button gives APA and BibTeX entries. If you used a pose model, also cite the model's data and software; [How to cite](./tutorials/citations.md) lists what to cite for each model.

The exact parameters of each result are listed under **Methods** on its result screen, and the test statement is on the statistics card. Both belong in a methods section.

## Licences

- **RodentFlow for iPhone 1.x** ([RodentFlow](https://github.com/seesaw-earth/RodentFlow)): MIT License, © 2026 Ziqing Shi. You may use, copy, modify and distribute the software, including commercially, provided the copyright and licence notice are kept. The full text is in [`LICENSE`](https://github.com/seesaw-earth/RodentFlow/blob/main/LICENSE).
- **Mac and pose-tracking code** ([RodentStudio-Support › source](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source)): AGPL-3.0. Each Xcode project contains its own licence text.
- **RodentFlow for Windows** ([RodentFlow-Windows](https://github.com/seesaw-earth/RodentFlow-Windows)): AGPL-3.0-only, © 2026 Ziqing Shi. Its third-party components (FFmpeg, ONNX Runtime with DirectML, Windows App SDK, Win2D) are listed in [`THIRD_PARTY_NOTICES.md`](https://github.com/seesaw-earth/RodentFlow-Windows/blob/main/THIRD_PARTY_NOTICES.md).
- **Models and training data** have their own terms; see [Core ML models](./models.md#licences).

The software is provided without warranty. See also [Legal & notices](./legal.md).
