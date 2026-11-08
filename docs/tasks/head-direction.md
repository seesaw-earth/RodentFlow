---
title: "Head direction"
description: "Head direction in RodentFlow: Head-direction physiology · Direction occupancy and angular velocity. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · NAVIGATION & NEURAL RECORDING</p>

# Head direction

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 50 × 50 cm</span></div>

**Head-direction physiology · Direction occupancy and angular velocity**

Recording head-direction cells (e.g., ADN, postsubiculum, retrosplenial cortex) requires framewise head orientation and directional occupancy to normalize tuning curves. Angular head velocity (AHV) supports AHV-cell analyses and speed-dependent tuning studies.

## Simulated example {#example}

<figure>

![Simulated head direction session: tracks and measures](/img/tasks/head-direction.en.png)

<figcaption>Every 6° bin is visited for at least a second (coverage 100 %), and the occupancy mean vector length is 0.04: the mouse sampled all directions nearly evenly, which is what normalising a tuning curve needs. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Traditional head-direction tracking may use two LEDs on the head. RodentFlow estimates direction from the ear midpoint → nose vector (fallback neck → nose) without markers, and exports timestamped HD and angular head velocity for alignment with electrophysiology or calcium imaging.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Head direction (HD)** | Direction of the ear-midpoint-to-nose vector; 0° is image right (or cue direction), counterclockwise positive. |
| **HD occupancy** | Dwell time in 6° direction bins for tuning-curve normalisation. |
| **Directional coverage** | Fraction of direction bins with dwell time ≥ 1 s. |
| **Occupancy mean-vector length** | Mean vector length of head-direction occupancy; values nearer zero indicate more uniform sampling. |
| **Angular head velocity (AHV)** | Derivative of head direction over time (°/s) and duration of clockwise/counterclockwise turning. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Optional: drag Q to a wall-mounted cue card to set the direction reference.
2. Align any recording-to-video timestamp offset yourself; CSV exports include frame timestamps.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Taube JS, Muller RU, Ranck JB (1990) Head-direction cells recorded from the postsubiculum in freely moving rats. I. J Neurosci 10:420–435. [doi:10.1523/JNEUROSCI.10-02-00420.1990](https://doi.org/10.1523/JNEUROSCI.10-02-00420.1990)
- Peyrache A, Lacroix MM, Petersen PC, Buzsáki G (2015) Internally organized mechanisms of the head direction sense. Nat Neurosci 18:569–575. [doi:10.1038/nn.3968](https://doi.org/10.1038/nn.3968)
- Mathis A et al. (2018) DeepLabCut: markerless pose estimation of user-defined body parts with deep learning. Nat Neurosci 21:1281–1289. [doi:10.1038/s41593-018-0209-y](https://doi.org/10.1038/s41593-018-0209-y)

## Related tasks {#related}

[Spatial exploration (place / grid cells)](./spatial-exploration.md)
