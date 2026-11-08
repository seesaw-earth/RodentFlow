---
title: "Novel object recognition"
description: "Novel object recognition in RodentFlow: Nose distance and orientation · Discrimination index. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Novel object recognition

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: 40 × 40 cm, object radius 2.5 cm</span></div>

**Nose distance and orientation · Discrimination index**

In training, animals investigate two identical objects; after a delay, one is replaced with a novel object. Novelty preference is summarized by the discrimination index (DI). Changing an object's position instead tests object-location memory (OLM).

## Simulated example {#example}

<figure>

![Simulated novel object recognition session: tracks and measures](/img/tasks/novel-object-recognition.en.png)

<figcaption>Over 10 minutes the mouse investigates the novel object for 55.2 s and the familiar one for 22.9 s: DI 0.41, RI 70.7 %. Total investigation reaches 20 s at 123 s, where DI is 0.38. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

A common operational definition of object investigation requires the nose to be within 2 cm of the object and facing it, excluding climbing or sitting beside it. A centroid-radius approach can overcount passing or nearby inactivity.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Investigation time** | Nose within 2 cm of the object edge, oriented toward it (±45°), with body centre off the object. |
| **Discrimination index (DI)** | (Novel − familiar) / (novel + familiar); the training phase uses (B − A) / (B + A) for side bias. |
| **Recognition index (RI)** | Novel / (novel + familiar) × 100%. |
| **20 s criterion** | Time to 20 s cumulative investigation and DI at that point. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Drag A / B handles to object centres and set the object radius.
2. Specify which object is novel in the test phase.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Ennaceur A, Delacour J (1988) A new one-trial test for neurobiological studies of memory in rats. 1: Behavioral data. Behav Brain Res 31:47–59. [doi:10.1016/0166-4328(88)90157-X](https://doi.org/10.1016/0166-4328(88)90157-X)
- Leger M et al. (2013) Object recognition test in mice. Nat Protoc 8:2531–2537. [doi:10.1038/nprot.2013.155](https://doi.org/10.1038/nprot.2013.155)
- Gabriel CJ et al. (2022) BehaviorDEPOT is a simple, flexible tool for automated behavioral detection based on markerless pose tracking. eLife 11:e74314. [doi:10.7554/eLife.74314](https://doi.org/10.7554/eLife.74314)

## Related tasks {#related}

[Barnes maze](./barnes-maze.md) · [Morris water maze](./water-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Step-down inhibitory avoidance](./step-down.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [Y-maze spontaneous alternation](./y-maze.md) · [T-maze choice & VTE](./t-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Looming threat escape](./looming-escape.md) · [Platform-mediated avoidance](./platform-avoidance.md)
