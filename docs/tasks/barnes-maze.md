---
title: "Barnes maze"
description: "Barnes maze in RodentFlow: Nose-based hole investigation · Errors, latency and path. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Barnes maze

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: 92 cm platform, 20 holes</span></div>

**Nose-based hole investigation · Errors, latency and path**

The Barnes maze has a ring of holes, with an escape box under the target hole. Animals learn its location using distal spatial cues. Metrics include target latency, errors, path length and target-quadrant time in probe trials.

## Simulated example {#example}

<figure>

![Simulated barnes maze session: tracks and measures](/img/tasks/barnes-maze.en.png)

<figcaption>Mean latency to the escape hole falls from 114 s on day 1 to 12 s on day 4, and errors before finding it from 9 to 1.3. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

In the Barnes maze, an error is a nose probe into a non-target hole. This is a nose-specific behaviour that centroid tracking cannot reliably count.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **First latency** | Time until the nose first enters the target hole. |
| **Errors** | Nose probes into non-target holes; initial errors precede target discovery and total errors cover the full session. |
| **Path length** | Body-centre path length before first target-hole discovery. |
| **Target quadrant** | Fraction of time in the ±45° sector centred on the target hole (probe trial). |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate the platform with C (centre) and R (edge).
2. Place T at the target hole; other holes are placed evenly according to the hole count.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Barnes CA (1979) Memory deficits associated with senescence: a neurophysiological and behavioral study in the rat. J Comp Physiol Psychol 93:74–104. [doi:10.1037/h0077579](https://doi.org/10.1037/h0077579)
- Pitts MW (2018) Barnes maze procedure for spatial learning and memory in mice. Bio-protocol 8:e2744. [doi:10.21769/BioProtoc.2744](https://doi.org/10.21769/BioProtoc.2744)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Morris water maze](./water-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Step-down inhibitory avoidance](./step-down.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [Y-maze spontaneous alternation](./y-maze.md) · [T-maze choice & VTE](./t-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Looming threat escape](./looming-escape.md) · [Platform-mediated avoidance](./platform-avoidance.md)
