---
title: "Fear conditioning"
description: "Fear conditioning in RodentFlow: Keypoint-based freezing · Segmented by CS. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Fear conditioning

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: 30 × 24 cm chamber</span></div>

**Keypoint-based freezing · Segmented by CS**

Following pairing of an auditory conditioned stimulus (CS) with footshock, the CS is replayed in the original or a new context to quantify freezing (immobility except breathing).

## Simulated example {#example}

<figure>

![Simulated fear conditioning session: tracks and measures](/img/tasks/fear-conditioning.en.png)

<figcaption>Freezing is 17.6 % before the first CS, 67.3 %, 84.7 % and 83.7 % during the three CSs, and 55.7 % between them. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Pixel-motion methods may be confounded by breathing, flicker and camera noise. RodentFlow uses displacement speeds of nose, ear midpoint, body centre and tail base in a 0.5 s window; small head movements can prevent false freezing calls.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Freezing** | Core keypoint displacement speed < 1.0 cm/s in a 0.5 s window for ≥ 1 s. |
| **Segment by CS** | Freezing percentages before first CS, during each CS, and between CS events. |
| **Time course** | Freezing fraction per minute. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Enter CS onset times (relative to video start) and durations.
2. Infrared or grayscale recordings work best.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Phillips RG, LeDoux JE (1992) Differential contribution of amygdala and hippocampus to cued and contextual fear conditioning. Behav Neurosci 106:274–285. [doi:10.1037/0735-7044.106.2.274](https://doi.org/10.1037/0735-7044.106.2.274)
- Anagnostaras SG et al. (2010) Automated assessment of Pavlovian conditioned freezing and shock reactivity in mice using the Video Freeze system. Front Behav Neurosci 4:158. [doi:10.3389/fnbeh.2010.00158](https://doi.org/10.3389/fnbeh.2010.00158)
- Gabriel CJ et al. (2022) BehaviorDEPOT (freezing from keypoints). eLife 11:e74314. [doi:10.7554/eLife.74314](https://doi.org/10.7554/eLife.74314)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Barnes maze](./barnes-maze.md) · [Morris water maze](./water-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Step-down inhibitory avoidance](./step-down.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [Y-maze spontaneous alternation](./y-maze.md) · [T-maze choice & VTE](./t-maze.md) · [Looming threat escape](./looming-escape.md) · [Platform-mediated avoidance](./platform-avoidance.md)
