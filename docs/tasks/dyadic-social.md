---
title: "Dyadic social interaction"
description: "Dyadic social interaction in RodentFlow: Two freely moving mice · Nose-to-nose, anogenital sniffing, following. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · SOCIAL BEHAVIOUR</p>

# Dyadic social interaction

<div class="rf-tags"><span>Pose · two animals</span><span>Default arena: 40 × 40 cm</span></div>

**Two freely moving mice · Nose-to-nose, anogenital sniffing, following**

Two freely moving mice interact in one arena, for example in juvenile social interactions, nonaggressive resident–intruder behaviour or male–female interaction. Readouts include sniffing and following bouts and duration.

## Simulated example {#example}

<figure>

![Simulated dyadic social interaction session: tracks and measures](/img/tasks/dyadic-social.en.png)

<figcaption>Over 5 minutes the pair spends 16.7 s nose to nose. A sniffs B’s anogenital region for 20.5 s and B sniffs A’s for 12.9 s; A follows B for 16.2 s and B follows A for 16.1 s. The mean distance between them is 11.1 cm. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Social contacts are defined using landmark distances: nose-to-nose, nose-to-tail-base (anogenital) and nose-to-body. These cannot be distinguished from centroids alone.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Nose-to-nose contact** | Distance between noses < 2.5 cm. |
| **Anogenital sniffing** | Nose-to-tail-base distance < 2.5 cm, reported separately for A→B and B→A. |
| **Body sniffing** | Nose-to-partner body centre < 3 cm, excluding the two categories above. |
| **Following** | Distance < 15 cm; both speeds > 5 cm/s; follower oriented toward partner (±45°) for ≥ 0.5 s. |
| **Inter-animal distance** | Mean body-centre distance and time spent within 10 cm. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Identity is most reliable when the mice differ in fur colour, size or marks; for mice of the same colour, consistent differences in body length while walking and in activity are also used, but marking them (marker-pen stripes on the tail or a dyed patch on the back) remains the most reliable.
2. Two-mouse detection is enabled automatically; detecting every frame is recommended.
3. In the review, check “Likely swap” first, then step through “Check identity”; if A / B are wrong, tap “Swap A / B from here”.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Segalin C et al. (2021) The Mouse Action Recognition System (MARS) software pipeline for automated analysis of social behaviors in mice. eLife 10:e63720. [doi:10.7554/eLife.63720](https://doi.org/10.7554/eLife.63720)
- Hong W et al. (2015) Automated measurement of mouse social behaviors using depth sensing, video tracking, and machine learning. PNAS 112:E5351–E5360. [doi:10.1073/pnas.1515982112](https://doi.org/10.1073/pnas.1515982112)

## Related tasks {#related}

[Three-chamber sociability](./three-chamber.md) · [Social interaction test (CSDS)](./social-interaction.md) · [Resident–intruder (aggression)](./resident-intruder.md) · [Group behaviour](./group-behavior.md)
