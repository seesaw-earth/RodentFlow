---
title: "Passive avoidance (step-through)"
description: "Passive avoidance (step-through) in RodentFlow: Censored latency to the dark side · reverse-probe risk assessment. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Passive avoidance (step-through)

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 40 × 20 cm, equal compartments; 300 s cut-off</span></div>

**Censored latency to the dark side · reverse-probe risk assessment**

A light and a dark compartment are joined by a door. In training the mouse receives a foot shock as soon as it enters the dark side; after a delay (often 24 h) it is placed in the light side again and the latency to enter the dark side is measured, usually with a 300-s cut-off. A longer latency means better memory of the dark side–shock association.

## Simulated example {#example}

<figure>

![Simulated passive avoidance (step-through) session: tracks and measures](/img/tasks/passive-avoidance.en.png)

<figcaption>In training the median latency to enter the dark side is 22 s. On the test day 6 of 10 mice are still on the light side at the 300 s cut-off; they are kept as censored values, not dropped. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Keeping the body in the light side and only poking the nose into the dark side is typical risk assessment in the test; it can only be counted when the nose and the body are judged separately. Entry can be judged by the body centre, body centre + tail base (approximately four-paw entry) or the nose.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Latency to enter the dark side** | Time of the first entry into the dark side by the entry rule; without an entry before the cut-off it is the cut-off and flagged as not entered (right-censored), with a survival analysis on the group page. |
| **Entered the dark side** | Whether the animal entered before the cut-off (0 / 100); the group mean is the percentage that entered. |
| **Dark side time and entries** | Counted with the same entry rule. |
| **Reverse probe** | The nose in the dark side while the body centre and tail base stay in the light for ≥ the set time: count, count before entry, latency to the first probe. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate the whole box, then set the side and share of the light compartment.
2. Set the analysis start to the moment the mouse is placed in the light side (or the door opens), and the analysis length to the cut-off (typically 300 s)
3. Create separate analyses for training and test; the group page adds a survival analysis of the latency.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Jarvik ME, Kopp R (1967) An improved one-trial passive avoidance learning situation. Psychol Rep 21:221–224.
- Kaplan EL, Meier P (1958) Nonparametric estimation from incomplete observations. J Am Stat Assoc 53:457–481. [doi:10.1080/01621459.1958.10501452](https://doi.org/10.1080/01621459.1958.10501452)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Barnes maze](./barnes-maze.md) · [Morris water maze](./water-maze.md) · [Step-down inhibitory avoidance](./step-down.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [Y-maze spontaneous alternation](./y-maze.md) · [T-maze choice & VTE](./t-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Looming threat escape](./looming-escape.md) · [Platform-mediated avoidance](./platform-avoidance.md)
