---
title: "Spatial exploration (place / grid cells)"
description: "Spatial exploration (place / grid cells) in RodentFlow: Occupancy, coverage and speed · Neural recording alignment. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · NAVIGATION & NEURAL RECORDING</p>

# Spatial exploration (place / grid cells)

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 50 × 50 cm</span></div>

**Occupancy, coverage and speed · Neural recording alignment**

Place-cell and grid-cell experiments often record animals for tens of minutes in open arenas. Before estimating firing fields, inspect occupancy uniformity and coverage and remove immobile periods using a speed threshold such as > 2 cm/s.

## Simulated example {#example}

<figure>

![Simulated spatial exploration (place / grid cells) session: tracks and measures](/img/tasks/spatial-exploration.en.png)

<figcaption>Coverage reaches 63 % of the 2.5 cm bins after 5 minutes and 86.2 % after 20. The mouse moves faster than 2 cm/s for 69.4 % of the time and covers 79.5 m. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Body-centre position is less sensitive to tail movements than an image centroid. Together with head direction, it supports position × direction analyses and framewise export of position, speed and HD.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Occupancy map** | Body-centre dwell time in each 2.5 cm spatial bin. |
| **Coverage** | Fraction of spatial bins with ≥ 0.2 s occupancy, plus its growth over time. |
| **Movement time** | Fraction of time at > 2 cm/s (a common velocity filter for place-field analysis). |
| **Distance and speed** | Total path length, mean movement speed and speed distribution. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. For long recordings, process every 2nd or 3rd frame to save time.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- O'Keefe J, Dostrovsky J (1971) The hippocampus as a spatial map. Brain Res 34:171–175. [doi:10.1016/0006-8993(71)90358-1](https://doi.org/10.1016/0006-8993(71)90358-1)
- Hafting T, Fyhn M, Molden S, Moser MB, Moser EI (2005) Microstructure of a spatial map in the entorhinal cortex. Nature 436:801–806. [doi:10.1038/nature03721](https://doi.org/10.1038/nature03721)

## Related tasks {#related}

[Head direction](./head-direction.md)
