# Open source & building

RodentFlow is **open source under the [MIT License](https://github.com/seesaw-earth/RodentFlow/blob/main/LICENSE)**. The complete app (tracker, metrics, statistics, import and interface) and this manual are in one public repository:

<p class="rf-repo"><a href="https://github.com/seesaw-earth/RodentFlow">github.com/seesaw-earth/RodentFlow</a></p>

## What this means for you

- **See exactly how every number is computed.** This manual describes the methods. The code is the final word, and anyone can read it.
- **Check the privacy promise.** The app contains no network code. You do not have to take our word for it.
- **Adapt it.** You may modify the app, for example to add an assay your lab uses, and share your version under the terms of the MIT License.
- **Report and fix problems in the open.** Issues and pull requests are welcome.

## Where things are in the code

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

## Build from source

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

## Contribute

- **Problems and questions**: [open an issue](https://github.com/seesaw-earth/RodentFlow/issues). See [Support](./support.md) for what to include.
- **Code**: read [CONTRIBUTING.md](https://github.com/seesaw-earth/RodentFlow/blob/main/CONTRIBUTING.md) and open a pull request.
- **This manual**: every page has an *Edit this page on GitHub* link at the bottom. The manual's source is in the [`docs/`](https://github.com/seesaw-earth/RodentFlow/tree/main/docs) folder, with an English and a Chinese version of each page.

## Cite

If RodentFlow contributes to published work, please cite the software and the version you used. The repository has a [`CITATION.cff`](https://github.com/seesaw-earth/RodentFlow/blob/main/CITATION.cff) file, so GitHub's **Cite this repository** button gives APA and BibTeX entries. For example:

> Shi, Z. (2026). *RodentFlow: rodent behavior tracking and analysis on iPhone* (Version 1.3) [Computer software]. https://github.com/seesaw-earth/RodentFlow

The exact parameters of each result are listed under **Methods** on its result screen, and the test statement is on the Groups statistics card. Both belong in a methods section.

## License

MIT License, © 2026 Ziqing Shi. You may use, copy, modify and distribute the software, including commercially, provided the copyright and license notice are kept. The software is provided without warranty. The full text is in [`LICENSE`](https://github.com/seesaw-earth/RodentFlow/blob/main/LICENSE).
