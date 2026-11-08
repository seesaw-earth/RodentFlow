---
title: "Looming threat escape"
description: "Looming threat escape in RodentFlow: Overhead expanding shadow → Escape or freezing. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Looming threat escape

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 48 × 48 cm with a shelter</span></div>

**Overhead expanding shadow → Escape or freezing**

A rapidly expanding dark disk overhead mimics an approaching predator and can evoke rapid shelter-directed escape or freezing. Metrics include response latency, shelter return, escape speed and freezing.

## Simulated example {#example}

<figure>

![Simulated looming threat escape session: tracks and measures](/img/tasks/looming-escape.en.png)

<figcaption>4 of 5 stimuli trigger an escape to the shelter, with a median response latency of 0.27 s; one trial ends in freezing instead. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Head direction relative to shelter at stimulus onset can influence escape paths. RodentFlow reports the head-to-shelter angle for each stimulus.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Response latency** | Time until speed first exceeds max(4× baseline speed, 15 cm/s) after stimulus. |
| **Escape** | Behavioural response followed by return to shelter within 10 s. |
| **Freezing** | Freezing duration during 10 s after stimulus (same definition as fear conditioning). |
| **Direction and distance** | Angle between head direction and shelter direction at stimulation, plus distance to shelter. |
| **Freezing definition and threat zone** | Freezing can use the motion index (as in fear conditioning) or, following De Franceschi et al. (2016), body speed < 2 cm/s for ≥ 0.5 s; the optional threat zone gives the time spent in it and is flagged in the frame-by-frame data. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Drag S to the centre of the shelter.
2. Enter each stimulus onset time relative to video start.
3. For a threat zone (the area under the stimulus), turn it on in the parameters and drag the T handle onto its centre.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Yilmaz M, Meister M (2013) Rapid innate defensive responses of mice to looming visual stimuli. Curr Biol 23:2011–2015. [doi:10.1016/j.cub.2013.08.015](https://doi.org/10.1016/j.cub.2013.08.015)
- Vale R, Evans DA, Branco T (2017) Rapid spatial learning controls instinctive defensive behavior in mice. Curr Biol 27:1342–1349. [doi:10.1016/j.cub.2017.03.031](https://doi.org/10.1016/j.cub.2017.03.031)
- De Franceschi G, Vivattanasarn T, Saleem AB, Solomon SG (2016) Vision guides selection of freeze or flight defense strategies in mice. Curr Biol 26:2150–2154. [doi:10.1016/j.cub.2016.06.006](https://doi.org/10.1016/j.cub.2016.06.006)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Barnes maze](./barnes-maze.md) · [Morris water maze](./water-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Step-down inhibitory avoidance](./step-down.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [Y-maze spontaneous alternation](./y-maze.md) · [T-maze choice & VTE](./t-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Platform-mediated avoidance](./platform-avoidance.md)
