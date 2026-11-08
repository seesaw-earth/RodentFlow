---
title: "Social interaction test (CSDS)"
description: "Social interaction test (CSDS) in RodentFlow: Social avoidance after chronic social defeat · SI ratio. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · SOCIAL BEHAVIOUR</p>

# Social interaction test (CSDS)

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 42 × 42 cm; 150 s per phase</span></div>

**Social avoidance after chronic social defeat · SI ratio**

A standard readout for chronic social defeat stress (CSDS). The mouse explores an open arena in two 150 s trials: first with an empty enclosure, then with an unfamiliar aggressor behind it. Interaction-zone dwell time is compared; SI ratio < 1 is commonly used as a susceptibility cutoff.

## Simulated example {#example}

<figure>

![Simulated social interaction test (csds) session: tracks and measures](/img/tasks/social-interaction.en.png)

<figcaption>Interaction-zone time rises from 38.4 s without a target to 64.5 s with one, an SI ratio of 1.68; corner time falls from 15.9 s to 6.5 s. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Beyond body-centre dwell time in the interaction zone, RodentFlow estimates nose-based enclosure investigation to help distinguish active approach from passing. Two phases with the same subject ID are paired for SI ratio.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Interaction-zone time** | Time the body centre spends in the interaction zone around the enclosure (default 26 × 14 cm). |
| **Corner-zone time** | Time spent in two opposite corner zones (default 9 × 9 cm each). |
| **SI ratio** | Interaction-zone time with target / without target (sessions with matching subject IDs are paired). |
| **Sniffing the enclosure** | Time with the nose within 2 cm of the enclosure edge and facing it. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate the open-field corners and specify the enclosure wall.
2. Analyse target-absent and target-present phases separately under the same subject ID to pair results automatically.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Golden SA, Covington HE, Berton O, Russo SJ (2011) A standardized protocol for repeated social defeat stress in mice. Nat Protoc 6:1183–1191. [doi:10.1038/nprot.2011.361](https://doi.org/10.1038/nprot.2011.361)
- Krishnan V et al. (2007) Molecular adaptations underlying susceptibility and resistance to social defeat in brain reward regions. Cell 131:391–404. [doi:10.1016/j.cell.2007.09.018](https://doi.org/10.1016/j.cell.2007.09.018)

## Related tasks {#related}

[Three-chamber sociability](./three-chamber.md) · [Dyadic social interaction](./dyadic-social.md) · [Resident–intruder (aggression)](./resident-intruder.md)
