---
title: "Pose only"
description: "Pose only in RodentFlow: Six framewise keypoints and kinematics · Custom analysis. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · GENERAL</p>

# Pose only

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: any arena</span></div>

**Six framewise keypoints and kinematics · Custom analysis**

Exports framewise keypoints and derived kinematics (speed, head direction, body axis, etc.) without assay-specific analysis, for custom workflows such as Keypoint-MoSeq, B-SOiD or SimBA.

## Simulated example {#example}

<figure>

![Simulated pose only session: tracks and measures](/img/tasks/pose-only.en.png)

<figcaption>Each frame gives six keypoints with a confidence each; the export adds smoothed coordinates, speed, head direction, body heading, the head–body angle and body length. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Retain raw framewise keypoints (pixel coordinates and confidence) alongside calibrated centimetre coordinates and derived features.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Framewise keypoints** | Pixel coordinates and confidence for six keypoints (backward-compatible CSV schema). |
| **Kinematics** | Smoothed coordinates, speed, head direction, body heading, head–body angle and body length. |
| **Quality** | Detection rate and mean confidence for each keypoint. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Without calibration, coordinates are pixels; calibration also provides centimetre coordinates.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Mathis A et al. (2018) DeepLabCut. Nat Neurosci 21:1281–1289. [doi:10.1038/s41593-018-0209-y](https://doi.org/10.1038/s41593-018-0209-y)
- Pereira TD et al. (2022) SLEAP: a deep learning system for multi-animal pose tracking. Nat Methods 19:486–495. [doi:10.1038/s41592-022-01426-1](https://doi.org/10.1038/s41592-022-01426-1)
- Weinreb C et al. (2024) Keypoint-MoSeq: parsing behavior by linking point tracking to pose dynamics. Nat Methods 21:1329–1339. [doi:10.1038/s41592-024-02318-2](https://doi.org/10.1038/s41592-024-02318-2)
