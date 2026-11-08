---
title: "Place preference (RTPP / CPP)"
description: "Place preference (RTPP / CPP) in RodentFlow: Paired side time and preference score · automatic pre / post pairing. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Place preference (RTPP / CPP)

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: 50 × 25 cm, divider at the middle</span></div>

**Paired side time and preference score · automatic pre / post pairing**

Real-time place preference (RTPP): the animal moves freely between two sides and is stimulated (e.g. optogenetically) whenever it is on one of them; preference for or avoidance of that side is measured. Conditioned place preference (CPP): pre-test → conditioning that pairs one side with a drug or reward → post-test, comparing paired-side time between post- and pre-test.

## Simulated example {#example}

<figure>

![Simulated place preference (rtpp / cpp) session: tracks and measures](/img/tasks/place-preference.en.png)

<figcaption>Paired-side time rises from 436 s in the pre-test to 520 s in the post-test (mean of 8 mice): a CPP score of +84 s. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

The side is judged by the body centre, optionally also requiring the tail base across the divider, so an animal in the doorway is not counted as crossing back and forth; a post-test is paired with the same animal's pre-test automatically and gives the CPP score directly.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Paired side time** | Time with the body centre on the paired / stimulated side (s, %), and on the unpaired side and in the middle zone. |
| **Preference score and index** | Paired − unpaired side (s); preference index = (paired − unpaired) ÷ (paired + unpaired). |
| **CPP score** | Post-test paired side time − pre-test paired side time (paired automatically by animal ID). |
| **Crossings and time course** | Crossings between the sides, latency to the paired side, paired side time per bin. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate the whole apparatus and choose the paired / stimulated side and the divider position in the parameters.
2. With a middle compartment, turn on “Middle zone” in the parameters and set its width.
3. CPP: create separate pre-test and post-test analyses; the same animal ID pairs them automatically.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Tzschentke TM (2007) Measuring reward with the conditioned place preference (CPP) paradigm: update of the last decade. Addict Biol 12:227–462. [doi:10.1111/j.1369-1600.2007.00070.x](https://doi.org/10.1111/j.1369-1600.2007.00070.x)
- Stamatakis AM, Stuber GD (2012) Activation of lateral habenula inputs to the ventral midbrain promotes behavioral avoidance. Nat Neurosci 15:1105–1107. [doi:10.1038/nn.3145](https://doi.org/10.1038/nn.3145)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Barnes maze](./barnes-maze.md) · [Morris water maze](./water-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Step-down inhibitory avoidance](./step-down.md) · [Y-maze spontaneous alternation](./y-maze.md) · [T-maze choice & VTE](./t-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Looming threat escape](./looming-escape.md) · [Platform-mediated avoidance](./platform-avoidance.md)
