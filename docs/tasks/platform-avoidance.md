---
title: "Platform-mediated avoidance"
description: "Platform-mediated avoidance in RodentFlow: Time on the platform · latency to the platform · freezing on / off the platform. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Platform-mediated avoidance

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 30 × 25 cm, 10 × 10 cm platform</span></div>

**Time on the platform · latency to the platform · freezing on / off the platform**

The mouse first learns that a tone predicts a foot shock, then learns to step onto a safe platform in one corner of the arena to avoid the shock (delivered in the last 2 s of the tone); getting onto the platform before the shock and staying there until it ends is a successful avoidance, at the cost of leaving the reward port. Tones, shocks and rewards are controlled and logged by their own devices; RodentFlow provides what the tracking can measure: time on the platform, platform entries and latency, freezing on and off the platform, and a frame-by-frame “on the platform” flag, so you can cut each trial yourself with the tone times from the device log.

## Simulated example {#example}

<figure>

![Simulated platform-mediated avoidance session: tracks and measures](/img/tasks/platform-avoidance.en.png)

<figcaption>Time on the platform during the tone rises from 3.7 % in trial 1 to 75.3 % in trial 9 as the mouse learns to avoid the shock at the end of the tone. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

In the literature, “on the platform” usually means at least two paws on the platform. RodentFlow can judge it by the body centre, nose + neck (approximating both forepaws) or body centre + tail base (approximating all four paws); freezing uses a motion index over several keypoints, so small head movements are not counted as movement.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Platform time** | Time on the platform by the on-platform rule (s, %), platform entries, latency to the first entry and mean duration per visit. |
| **Freezing** | Motion index below the threshold for ≥ the minimum duration (as in fear conditioning); freezing percentages on and off the platform are also given. |
| **Reward-port zone** | Time and entries with the nose within the reward-port radius (optional). |
| **Binned time course** | Percentage of time on the platform and freezing per time bin; the group page can plot the time course. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate the four corners of the arena and enter the inside dimensions.
2. Drag the P handle onto the platform centre and enter the platform's width and height in the parameters.
3. For a reward-port zone, turn it on in the parameters and drag the R handle onto the reward port.
4. The on_platform and freezing columns of the frame-by-frame CSV are in video time; cut each trial yourself with the tone times from the device log.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Bravo-Rivera C, Roman-Ortiz C, Brignoni-Perez E, Sotres-Bayon F, Quirk GJ (2014) Neural structures mediating expression and extinction of platform-mediated avoidance. J Neurosci 34:9736–9742. [doi:10.1523/JNEUROSCI.0191-14.2014](https://doi.org/10.1523/JNEUROSCI.0191-14.2014)
- Diehl MM, Iravedra-Garcia JM, Morán-Sierra J, Rojas-Bowe G, Gonzalez-Diaz FN, Valentín-Valentín VP, Quirk GJ (2020) Divergent projections of the prelimbic cortex bidirectionally regulate active avoidance. eLife 9:e59281. [doi:10.7554/eLife.59281](https://doi.org/10.7554/eLife.59281)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Barnes maze](./barnes-maze.md) · [Morris water maze](./water-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Step-down inhibitory avoidance](./step-down.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [Y-maze spontaneous alternation](./y-maze.md) · [T-maze choice & VTE](./t-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Looming threat escape](./looming-escape.md)
