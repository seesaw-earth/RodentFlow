---
title: "T-maze choice & VTE"
description: "T-maze choice & VTE in RodentFlow: Head scanning at the decision point (VTE). Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# T-maze choice & VTE

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: arms 30 × 8 cm</span></div>

**Head scanning at the decision point (VTE)**

At choice points, animals sometimes pause and scan between alternatives, a behaviour known as vicarious trial and error (VTE). A common measure is IdPhi, the cumulative absolute change in orientation during the choice, z-scored within a session.

## Simulated example {#example}

<figure>

![Simulated t-maze choice & vte session: tracks and measures](/img/tasks/t-maze.en.png)

<figcaption>4 of 16 passes have zIdPhi ≥ 0.5 and are classed as VTE; their mean IdPhi is 483°, against 144° for direct passes. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

VTE involves head scanning. RodentFlow computes IdPhi from head direction and provides a trajectory-based IdPhi for comparison, together with left/right choices and alternation.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **IdPhi** | Cumulative absolute change in head direction (°) while passing the decision point into left or right arm. |
| **zIdPhi and VTE** | Within-session z-scoring; zIdPhi ≥ 0.5 is classified as VTE (adjustable). |
| **Choice** | Left/right choice, alternation rate and time spent at the choice point. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. J marks the choice point, S the start arm, and L / R the left and right arms.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Redish AD (2016) Vicarious trial and error. Nat Rev Neurosci 17:147–159. [doi:10.1038/nrn.2015.30](https://doi.org/10.1038/nrn.2015.30)
- Deacon RMJ, Rawlins JNP (2006) T-maze alternation in the rodent. Nat Protoc 1:7–12. [doi:10.1038/nprot.2006.2](https://doi.org/10.1038/nprot.2006.2)
- Gabriel CJ et al. (2022) BehaviorDEPOT (VTE module). eLife 11:e74314. [doi:10.7554/eLife.74314](https://doi.org/10.7554/eLife.74314)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Barnes maze](./barnes-maze.md) · [Morris water maze](./water-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Step-down inhibitory avoidance](./step-down.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [Y-maze spontaneous alternation](./y-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Looming threat escape](./looming-escape.md) · [Platform-mediated avoidance](./platform-avoidance.md)
