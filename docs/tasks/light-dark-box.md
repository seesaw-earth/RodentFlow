---
title: "Light–dark box"
description: "Light–dark box in RodentFlow: Light-compartment time, transitions and head pokes. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · ANXIETY & RISK ASSESSMENT</p>

# Light–dark box

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: 45 × 30 cm, light side 2/3</span></div>

**Light-compartment time, transitions and head pokes**

The light–dark box has bright and dark compartments linked by a doorway, commonly tested for 5–10 min. Light-side time and transitions are measures of anxiety-like behaviour.

## Simulated example {#example}

<figure>

![Simulated light–dark box session: tracks and measures](/img/tasks/light-dark-box.en.png)

<figcaption>The mouse enters the dark side after 8.3 s and spends 22.4 % of the time on the light side, with 53 crossings and 28 head pokes from the dark side into the light. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

A head poke—nose into the light compartment while the body remains in the dark—is a risk-assessment behaviour requiring separate nose and body landmarks.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Light-side time (%)** | Fraction of time the body centre is in the light compartment. |
| **Transitions** | Number of body-centre crossings between light and dark compartments. |
| **Latency** | Time to first entry into the light and dark compartments. |
| **Head dips** | Nose enters the light compartment while body centre and tail base remain dark for ≥ 0.2 s. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate the full chamber, then set the light compartment side and fraction.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Bourin M, Hascoët M (2003) The mouse light/dark box test. Eur J Pharmacol 463:55–65. [doi:10.1016/S0014-2999(03)01274-3](https://doi.org/10.1016/S0014-2999(03)01274-3)
- Takao K, Miyakawa T (2006) Light/dark transition test for mice. J Vis Exp (1):e104. [doi:10.3791/104](https://doi.org/10.3791/104)

## Related tasks {#related}

[Open field](./open-field.md) · [Elevated plus maze](./elevated-plus-maze.md) · [Elevated zero maze](./elevated-zero-maze.md) · [Novelty-suppressed feeding](./novelty-suppressed-feeding.md) · [Visual cliff](./visual-cliff.md) · [Marble burying](./marble-burying.md)
