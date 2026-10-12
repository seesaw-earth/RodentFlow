# What is RodentFlow?

RodentFlow is an iPhone app for rodent behavior experiments. It covers the path from a recorded session to a group comparison:

1. **Track** a top-down video of one animal and convert its position to centimeters inside a calibrated arena or maze.
2. **Score** the session. Zone times, entries, distance, latencies, freezing and other assay-specific metrics are computed from the positions.
3. **Collect** one result per animal and session. Results can also come from values scored by hand or from a table exported by another program.
4. **Compare** groups. The app picks a test that fits the design, draws a figure with every animal shown, and exports the figure, the statistics and the data.

Everything runs on the phone. There is no account, no server and no upload. See the [privacy policy](../privacy.md).

RodentFlow is **open source** under the MIT License. The app's source code and this manual are public at [github.com/seesaw-earth/RodentFlow](https://github.com/seesaw-earth/RodentFlow); see [Open source & building](../source.md).

## Two tabs

| Tab | What you do there |
|---|---|
| **Experiment** | Start a new experiment: pick the assay, then analyze a video, enter values or import a table. The **Results** card lists everything saved so far. |
| **Groups** | Choose an assay and a measure, set the design, and read the statistics and figure for all saved results of that assay. |

## Three ways to get data in

| Source | Use it when | Assays |
|---|---|---|
| **Video tracking** | You have a top-down recording of a single animal | Open field, elevated plus maze, light–dark box, Y-maze, T-maze, novel object recognition, Morris water maze, Barnes maze, fear conditioning, conditioned place preference |
| **Manual entry** | You scored the session by hand (stopwatch, counts, weights) | All 15 assays |
| **Table import** | Values come from a spreadsheet or another tracker (ANY-maze, EthoVision, DeepLabCut post-processing …) | All 15 assays, plus any custom table |

All three produce the same kind of result. Video, manual and imported results of the same assay can be analyzed together in the Groups tab.

## What the tracker measures, and what it does not

RodentFlow uses a classic, transparent tracker: background subtraction followed by the centroid of the animal's body. [Tracking](../principles/tracking.md) explains every step. This choice has consequences that are worth knowing before you start.

- **One animal per arena.** Each analysis follows one animal inside the calibrated arena. Several arenas filmed side by side can be analyzed one after the other, with one calibration each.
- **Body center, not nose.** The tracking point is the center of the body. Assays that are usually scored by nose position, namely novel object exploration and Barnes hole pokes, use a zone around the object or hole that is large enough for the body center. The [assay pages](../assays/memory.md) explain how to set it.
- **Top-down view.** Positions are converted to centimeters on the floor plane, which assumes the camera looks down on the arena.
- **No pose or behavior classification.** Rearing, grooming or sniffing are not detected. Freezing is measured from frame-to-frame pixel change, which is the standard automated approach for freezing.

If you need body-part tracking or several interacting animals, deep-learning pose estimators are the right tool; [Further reading](../reference/reading.md) lists recent ones. Their per-animal output can then be imported into RodentFlow for statistics.

## Requirements

- iPhone with iOS 17 or later.
- English or Simplified Chinese. The app follows the iPhone language. To choose a different language for RodentFlow only, tap **Aa › Language / 语言**, which opens the app's page in Settings.
- Text size: **Aa** offers Small to Largest, or "Same as iPhone".

## How this manual is organized

- **Getting started** — a [five-minute walkthrough](./getting-started.md) and [recording advice](./recording.md).
- **Using the app** — each screen in order: [video analysis](./video-analysis.md), [manual entry and import](./manual-and-import.md), [results](./results.md), [group analysis](./groups.md).
- **Assays** — what to set and how every metric is defined, [assay by assay](../assays/index.md).
- **How it works** — [tracking](../principles/tracking.md), [metrics](../principles/metrics.md), [statistics](../principles/statistics.md) and [validation](../principles/validation.md) against ground-truth videos.
- **Reference** — [files](../reference/files.md), [FAQ](../reference/faq.md), [further reading](../reference/reading.md) and [release notes](../reference/changelog.md).
