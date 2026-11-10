---
title: "Three-chamber sociability"
description: "Three-chamber sociability in RodentFlow: Sociability and social novelty · Nose-point investigation. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · SOCIAL BEHAVIOUR</p>

# Three-chamber sociability

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 60 × 40 cm, three chambers</span></div>

**Sociability and social novelty · Nose-point investigation**

A test mouse explores three connected chambers with wire cups in the side chambers. In the sociability phase, one cup holds a stranger and the other is empty or contains an object; in social novelty, a familiar mouse is contrasted with a new stranger. Readouts include chamber dwell times and cup investigation.

## Simulated example {#example}

<figure>

![Simulated three-chamber sociability session: tracks and measures](/img/tasks/three-chamber.en.png)

<figcaption>The mouse investigates the stranger’s cup for 130.7 s and the empty cup for 50.5 s, a social preference index of 0.44. Chamber times are 289 s (stranger side), 177 s (centre) and 134 s (empty-cup side). Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Centroid tracking shows chamber position, not investigation. RodentFlow combines nose-to-cup distance and head orientation, excluding frames with the body on the cup, to approximate manually scored cup investigation.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Chamber dwell time** | Cumulative time and entries for the left, centre and right chambers based on the body centre. |
| **Investigation duration** | Nose within 2 cm of the cup perimeter, oriented toward it (±45°), with the body centre off the cup. |
| **Social preference index** | (Social − object) / (social + object), based on investigation time; novelty phase uses (novel − familiar) / (novel + familiar). |
| **Latency and bouts** | Latency to first investigation of each cup and number of investigation bouts. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate four corners and enter the three-chamber arena dimensions.
2. Drag L / R handles to the centres of the two wire cups.
3. Select the side containing the stranger (or novel stranger) in parameters.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Moy SS et al. (2004) Sociability and preference for social novelty in five inbred strains: an approach to assess autistic-like behavior in mice. Genes Brain Behav 3:287–302. [doi:10.1111/j.1601-1848.2004.00076.x](https://doi.org/10.1111/j.1601-1848.2004.00076.x)
- Yang M, Silverman JL, Crawley JN (2011) Automated three-chambered social approach task for mice. Curr Protoc Neurosci 8.26. [doi:10.1002/0471142301.ns0826s56](https://doi.org/10.1002/0471142301.ns0826s56)

## Related tasks {#related}

[Social interaction test (CSDS)](./social-interaction.md) · [Dyadic social interaction](./dyadic-social.md) · [Resident–intruder (aggression)](./resident-intruder.md) · [Group behaviour](./group-behavior.md)
