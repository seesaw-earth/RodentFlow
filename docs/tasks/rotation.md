---
title: "Rotation (unilateral lesion)"
description: "Rotation (unilateral lesion) in RodentFlow: Unilateral lesion models · Ipsilateral / contralateral full turns. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · MOTOR FUNCTION & COPING</p>

# Rotation (unilateral lesion)

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 30 cm bowl; 5-min bins</span></div>

**Unilateral lesion models · Ipsilateral / contralateral full turns**

After a unilateral lesion or another one-sided manipulation, animals often turn preferentially toward one side. Full ipsilateral and contralateral turns are counted from the body axis; net rotations quantify the left–right asymmetry or compare experimental conditions.

## Simulated example {#example}

<figure>

![Simulated rotation (unilateral lesion) session: tracks and measures](/img/tasks/rotation.en.png)

<figcaption>A left-lesioned mouse makes 217 ipsilateral and 10 contralateral full turns in 60 minutes: net 207 turns, 3.45 per minute, highest in minutes 20–25. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Counting rotations needs body heading (tail base → neck). RodentFlow accumulates complete 360° turns, including small in-place turns, without a rotometer.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Full turns** | One complete 360° turn from body heading; clockwise and counterclockwise counted separately, restarting after > 90° reversal. |
| **Ipsilateral / contralateral** | Adjusted for lesion side; overhead video counterclockwise corresponds to animal left turns. |
| **Net rotation** | Ipsilateral − contralateral rotations, net turns per minute and binned trends. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Set the lesion side; enable “Filmed from below” if recorded through a transparent floor.
2. Report results in 5-minute bins.
3. Add experimental conditions as your own labels with + on the Info step.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Pycock CJ (1980) Turning behaviour in animals. Neuroscience 5:461–514.
