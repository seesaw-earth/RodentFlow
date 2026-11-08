---
title: "Y-maze spontaneous alternation"
description: "Y-maze spontaneous alternation in RodentFlow: Working memory · Alternation and partial entries. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Y-maze spontaneous alternation

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: arms 35 × 5 cm</span></div>

**Working memory · Alternation and partial entries**

Three arms meet at 120°. The animal explores freely for about 8 minutes. Visiting all three arms in three successive entries counts as an alternation; alternation rate is alternations / (entries − 2).

## Simulated example {#example}

<figure>

![Simulated y-maze spontaneous alternation session: tracks and measures](/img/tasks/y-maze.en.png)

<figcaption>Of 30 arm entries, 19 of the 28 overlapping triplets visit three different arms: 67.9 % alternation. Twice the nose entered an arm and the body turned back. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Many scoring protocols require all four paws inside an arm to count an entry. RodentFlow approximates this using body centre and tail base, and separately reports head-only entries.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Alternation rate** | Number of three-entry sequences visiting distinct arms / (total entries − 2). |
| **Entries** | By default an entry requires both body centre and tail base to be inside the arm. |
| **Head entry without body entry** | Nose enters an arm but the body turns back before entry. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. J marks the junction; A / B / C mark the three arm tips.
2. Enter arm length and width (cm).

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Hughes RN (2004) The value of spontaneous alternation behavior (SAB) as a test of retention in pharmacological investigations of memory. Neurosci Biobehav Rev 28:497–505. [doi:10.1016/j.neubiorev.2004.06.006](https://doi.org/10.1016/j.neubiorev.2004.06.006)
- Kraeuter AK, Guest PC, Sarnyai Z (2019) The Y-maze for assessment of spatial working and reference memory in mice. Methods Mol Biol 1916:105–111. [doi:10.1007/978-1-4939-8994-2_10](https://doi.org/10.1007/978-1-4939-8994-2_10)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Barnes maze](./barnes-maze.md) · [Morris water maze](./water-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Step-down inhibitory avoidance](./step-down.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [T-maze choice & VTE](./t-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Looming threat escape](./looming-escape.md) · [Platform-mediated avoidance](./platform-avoidance.md)
