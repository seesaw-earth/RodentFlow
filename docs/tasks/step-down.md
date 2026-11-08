---
title: "Step-down inhibitory avoidance"
description: "Step-down inhibitory avoidance in RodentFlow: Censored step-down latency · freezing on the platform · edge head dips. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Step-down inhibitory avoidance

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 25 × 25 cm box, 7 × 7 cm platform</span></div>

**Censored step-down latency · freezing on the platform · edge head dips**

The mouse is placed on a small platform in the middle of a grid floor. In training it receives a foot shock as soon as all four paws touch the grid; after a delay (often 24 h) it is placed on the platform again and the step-down latency is measured, usually with a 180- or 300-s cut-off. A longer latency means better memory of the step-down–shock association; the test / training latency ratio can serve as a retention index.

## Simulated example {#example}

<figure>

![Simulated step-down inhibitory avoidance session: tracks and measures](/img/tasks/step-down.en.png)

<figcaption>Median step-down latency is 9 s in training; in the test 6 of 10 mice stay on the platform until the 180 s cut-off. The example test shows 7 head dips over the platform edge. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

A step-down means all four paws on the grid; by default RodentFlow approximates it as both the body centre and the tail base leaving the platform. Head dips with the body still on the platform and only the nose beyond the edge are counted separately, as risk assessment before the step-down.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Step-down latency** | Time of the first step-down from the platform by the step-down rule; without a step-down before the cut-off it is the cut-off and flagged as no step-down (right-censored), with a survival analysis on the group page. In the test phase the test / training latency ratio is also given (paired automatically by animal ID). |
| **Stepped down** | Whether the animal stepped down before the cut-off (0 / 100), plus the number of step-downs and the time on the platform. |
| **Freezing on the platform** | Percentage of the time on the platform spent freezing (same definition as fear conditioning). |
| **Edge head dips** | The nose beyond the platform edge while the body centre and tail base stay on the platform for ≥ the set time: count, count before the step-down, latency to the first dip. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate the whole box floor, drag the P handle onto the platform centre and enter the platform's width and height in the parameters.
2. Set the analysis start to the moment the mouse is placed on the platform and the analysis length to the cut-off (typically 180 or 300 s)
3. Create separate analyses for training and test; a test is paired with the training session automatically when the animal ID is the same.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Kameyama T, Nabeshima T, Kozawa T (1986) Step-down-type passive avoidance- and escape-learning method: suitability for experimental amnesia models. J Pharmacol Methods 16:39–52.
- Kaplan EL, Meier P (1958) Nonparametric estimation from incomplete observations. J Am Stat Assoc 53:457–481. [doi:10.1080/01621459.1958.10501452](https://doi.org/10.1080/01621459.1958.10501452)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Barnes maze](./barnes-maze.md) · [Morris water maze](./water-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [Y-maze spontaneous alternation](./y-maze.md) · [T-maze choice & VTE](./t-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Looming threat escape](./looming-escape.md) · [Platform-mediated avoidance](./platform-avoidance.md)
