---
title: "Open field"
description: "Open field in RodentFlow: Locomotion and anxiety-like behaviour · Centre, turning, immobility. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · ANXIETY & RISK ASSESSMENT</p>

# Open field

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: 40 × 40 cm</span></div>

**Locomotion and anxiety-like behaviour · Centre, turning, immobility**

The open-field test is a widely used measure of spontaneous locomotion and anxiety-like behaviour. The mouse freely explores a square or circular arena for 5–30 min; readouts include total distance, centre time and centre entries.

## Simulated example {#example}

<figure>

![Simulated open field session: tracks and measures](/img/tasks/open-field.en.png)

<figcaption>In this simulated 10-minute session the mouse travels 45.8 m and spends 26.9 % of the time in the centre, entering it 67 times. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Using the body centre reduces tail-related centroid bias, while body heading and length enable rotations, immobility and elongation estimates.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Distance and speed** | Body-centre path length (m) and mean speed. |
| **Centre zone** | Percent centre time, entries and first-entry latency. |
| **Immobility** | Duration of keypoint movement < 1 cm/s sustained for ≥ 1 s. |
| **Circling** | Full clockwise / counterclockwise rotations accumulated from body orientation. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. The default centre region spans 50% of the arena side length; adjust in parameters.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Prut L, Belzung C (2003) The open field as a paradigm to measure the effects of drugs on anxiety-like behaviors: a review. Eur J Pharmacol 463:3–33. [doi:10.1016/S0014-2999(03)01272-X](https://doi.org/10.1016/S0014-2999(03)01272-X)
- Seibenhener ML, Wooten MC (2015) Use of the open field maze to measure locomotor and anxiety-like behavior in mice. J Vis Exp 96:e52434. [doi:10.3791/52434](https://doi.org/10.3791/52434)

## Related tasks {#related}

[Elevated plus maze](./elevated-plus-maze.md) · [Elevated zero maze](./elevated-zero-maze.md) · [Light–dark box](./light-dark-box.md) · [Novelty-suppressed feeding](./novelty-suppressed-feeding.md) · [Visual cliff](./visual-cliff.md) · [Marble burying](./marble-burying.md)
