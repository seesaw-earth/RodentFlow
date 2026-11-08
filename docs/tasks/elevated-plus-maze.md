---
title: "Elevated plus maze"
description: "Elevated plus maze in RodentFlow: Open-arm exploration, head dips and stretch-attend posture. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · ANXIETY & RISK ASSESSMENT</p>

# Elevated plus maze

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: arms 30 × 5 cm; 5 min</span></div>

**Open-arm exploration, head dips and stretch-attend posture**

An elevated maze with two open and two closed arms, commonly tested for 5 min. Reduced open-arm time and entry fractions are often interpreted as more anxiety-like behaviour.

## Simulated example {#example}

<figure>

![Simulated elevated plus maze session: tracks and measures](/img/tasks/elevated-plus-maze.en.png)

<figcaption>Open-arm time is 32.5 % of the time on the arms (93 s open, 194 s closed); 18 of 40 arm entries are into an open arm, and there are 8 head dips over the open-arm edges. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Risk-assessment behaviours such as head dips and stretch-attend posture may provide information beyond open-arm time. Estimating them requires nose location and body length rather than centroid position alone.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Open-arm time (%)** | Time in open arms / time in open plus closed arms. |
| **Open-arm entries (%)** | Open-arm entries / total entries; by default body centre and tail base must enter an arm. |
| **Head dips** | Nose beyond the open-arm edge while body remains on the maze (≥ 0.2 s); protected when body is in the centre or closed arm. |
| **Stretch-attend posture (SAP)** | Body length ≥ 1.2× median and body-centre speed < 5 cm/s for ≥ 0.5 s. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Place C at the centre and N / E / S / W at the four arm tips.
2. Select the open-arm axis (north–south or east–west).
3. Leave enough margin so the nose remains visible during head dips.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Pellow S, Chopin P, File SE, Briley M (1985) Validation of open:closed arm entries in an elevated plus-maze as a measure of anxiety in the rat. J Neurosci Methods 14:149–167. [doi:10.1016/0165-0270(85)90031-7](https://doi.org/10.1016/0165-0270(85)90031-7)
- Walf AA, Frye CA (2007) The use of the elevated plus maze as an assay of anxiety-related behavior in rodents. Nat Protoc 2:322–328. [doi:10.1038/nprot.2007.44](https://doi.org/10.1038/nprot.2007.44)
- Holly KS, Orndorff CO, Murray TA (2016) MATSAP: an automated analysis of stretch-attend posture in rodent behavioral experiments. Sci Rep 6:31286. [doi:10.1038/srep31286](https://doi.org/10.1038/srep31286)

## Related tasks {#related}

[Open field](./open-field.md) · [Elevated zero maze](./elevated-zero-maze.md) · [Light–dark box](./light-dark-box.md) · [Novelty-suppressed feeding](./novelty-suppressed-feeding.md) · [Visual cliff](./visual-cliff.md) · [Marble burying](./marble-burying.md)
