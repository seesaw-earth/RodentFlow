---
title: "Visual cliff"
description: "Visual cliff in RodentFlow: First choice · time on the deep side · edge head dips. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · ANXIETY & RISK ASSESSMENT</p>

# Visual cliff

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 60 × 40 cm, centre board 20 % of the length</span></div>

**First choice · time on the deep side · edge head dips**

A sheet of clear glass (or a clear floor) covers the whole arena: on one side a patterned surface lies directly under the glass (shallow side), on the other it lies far below (deep side), so there appears to be a drop. The mouse starts from a centre board or neutral zone in the middle; mice with depth perception mostly choose the shallow side and avoid the deep side. The phenotyping version (JAX) records 20 min in an open field with a clear floor and also reports the first 4 min. Readouts are the first choice, time on the deep / shallow side, the latency to enter the deep side and edge head dips.

## Simulated example {#example}

<figure>

![Simulated visual cliff session: tracks and measures](/img/tasks/visual-cliff.en.png)

<figcaption>The first choice is the shallow side. Over 10 minutes the mouse spends 58.9 % of the time on the shallow side, 34.4 % on the centre board and 6.7 % on the deep side, with 15 head dips over the deep edge. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

The side is judged by the body centre, optionally also requiring the tail base across the boundary (so a mouse sitting on the edge of the centre board is not counted as switching back and forth). An “edge head dip”—the body still in the middle or on the shallow side and only the nose reaching over the deep side—is typical risk assessment, and it can only be counted when the nose and the body are judged separately.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **First choice** | The side entered first after leaving the neutral zone (deep side = 100, shallow side = 0; the group mean is the percentage choosing the deep side first, and the group page adds a Fisher's exact test), and the latency to leave the neutral zone. |
| **Time per side** | Time (%) and distance on the deep side, on the shallow side and in the neutral zone; an early window (4 min by default) is reported separately. |
| **Entered the deep side** | Number of entries and latency to the first entry; without an entry the latency is the cut-off and flagged as not entered (right-censored), with a survival analysis on the group page. |
| **Edge head dips** | The nose over the deep side while the body centre and tail base stay in the neutral zone or on the shallow side for ≥ the set time: count, time, latency to the first dip. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate the four corners of the glass (or clear floor) and enter the inside dimensions.
2. Choose the deep side in the parameters and set the position and width of the centre board (neutral zone)
3. Place the mouse on the centre board; set the analysis start to the moment it is put down.
4. A checkerboard background and reflections on the glass can affect detection: check the detection rate and the review first.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Fox MW (1965) The visual cliff test for the study of visual depth perception in the mouse. Anim Behav 13:232–233. [doi:10.1016/0003-3472(65)90040-0](https://doi.org/10.1016/0003-3472(65)90040-0)
- Gibson EJ, Walk RD (1960) The \u{201C}visual cliff\u{201D}. Sci Am 202:64–71. [doi:10.1038/scientificamerican0460-64](https://doi.org/10.1038/scientificamerican0460-64)
- Kaplan EL, Meier P (1958) Nonparametric estimation from incomplete observations. J Am Stat Assoc 53:457–481. [doi:10.1080/01621459.1958.10501452](https://doi.org/10.1080/01621459.1958.10501452)

## Related tasks {#related}

[Open field](./open-field.md) · [Elevated plus maze](./elevated-plus-maze.md) · [Elevated zero maze](./elevated-zero-maze.md) · [Light–dark box](./light-dark-box.md) · [Novelty-suppressed feeding](./novelty-suppressed-feeding.md) · [Marble burying](./marble-burying.md)
