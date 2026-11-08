---
title: "Tail suspension, multi-chamber"
description: "Multi-chamber tail suspension in RodentFlow: several mice in one recording, each timed from its own suspension; immobility in minutes 2–6, bouts and mobility intensity."
---

<p class="rf-eyebrow">TASK · MOTOR FUNCTION & COPING</p>

# Tail suspension, multi-chamber

<div class="rf-tags"><span>Multi-chamber</span><span>iPhone, iPad and Mac</span><span>Standard window: 6 min</span></div>

**Several mice hanging side by side in one recording · immobility in minutes 2–6**

In the tail suspension test a mouse is hung by the tail for six minutes, out of reach of any surface. Periods of struggling alternate with periods of hanging still; the time spent immobile is the classic readout. RodentFlow scores **several mice filmed side by side in one recording**: it finds the chambers, finds the moment every mouse is hung, measures motion in each chamber, and saves each chamber as an ordinary one-animal session, so groups, comparisons and exports work as for any other task.

## Simulated example {#example}

<figure>

![Simulated tail suspension recording with four chambers: motion traces and immobility](/img/tasks/tail-suspension.en.png)

<figcaption>Four mice scored from one recording. Immobility in minutes 2–6 is 164, 101, 207 and 157 s. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## How it scores {#measures}

| Measure | Definition |
|---|---|
| **Immobility, minutes 2–6 (★)** | The primary measure: time immobile from the 2nd to the 6th minute after this mouse was hung. Minutes 0–2, 0–6 and the whole recording are reported too. |
| **Motion** | Pixel change inside a fixed motion box around each mouse, after aligning frames to cancel passive swinging, so swinging is not counted as movement. Two outline-based measures are available for comparison. |
| **Immobile** | Motion below the threshold (2 % of the mouse’s area by default) for at least 1 s. |
| **Bouts and latency** | Latency to the first immobility bout; number, mean and longest bout; immobility per minute. |
| **Mobility intensity** | Mean motion while mobile: how vigorously the mouse struggles. |

- **Each mouse is timed from its own suspension**, so mice hung a few seconds apart are scored over the same windows.
- Frames without a mouse (taken down, climbing, out of view) count as “no mouse”, not as immobility, and the immobility percentage uses only frames with a mouse. Chambers with more than 10 % “no mouse” frames are flagged for review.

## Setting up {#setup}

1. Film the mice from the front, all chambers in view, with even light and a plain background that contrasts with the coat.
2. Choose **Tail suspension, multi-chamber** in the task library (on the Mac: *TST · Multi-Chamber*) and add the recording.
3. **Chambers:** chambers are detected automatically (if not, the image is split evenly into six). Set the number of chambers, drag the handles onto the walls between chambers, and tap or click a chamber to include or skip it.
4. **Key frame:** the first moment every selected chamber has had a mouse for the set time. Let the scan finish so that each motion box covers the full range of movement. Fine-tune with ±0.25 s / ±1 s, and drag the handles so the analysed band covers every mouse with a little room above.
5. **Results & animals:** one row per chamber with immobility and the animal fields. Enter the recording date once, then animal ID, group, sex and session number; untick empty chambers. Save.
6. Review each mouse against the recording and mark it *Scoring looks right* or *Problems found*.

To change settings later, open any session from the recording and choose **Adjust settings and analyse again**. Threshold, minimum bout and windows update at once; chambers, band or start need a new analysis.

::: tip Calibrate the threshold for your rig
The 2 % threshold is a starting value. Hand-score two or three videos with different amounts of immobility (for example in [BORIS](https://www.boris.unito.it/)), then in *Results & animals* use **Calibrate against manual scores…**: enter the hand-scored seconds for minutes 2–6, find the best threshold and apply it. Use the same threshold for the whole study.
:::

## Reading the results {#interpretation}

Immobility is best described as a **passive coping strategy**. Sedation or stimulation, motor ability, body weight, sex, strain and tail discomfort all influence it, so read it alongside a locomotor control, for example open-field distance in the same mice.

## References {#references}

- Steru L, Chermat R, Thierry B, Simon P (1985) The tail suspension test: a new method for screening antidepressants in mice. Psychopharmacology 85:367–370. [doi:10.1007/BF00428203](https://doi.org/10.1007/BF00428203)
- Can A, Dao DT, Terrillion CE, Piantadosi SC, Bhat S, Gould TD (2012) The tail suspension test. J Vis Exp 59:e3769. [doi:10.3791/3769](https://doi.org/10.3791/3769)
- Commons KG, Cholanians AB, Babb JA, Ehlinger DG (2017) The rodent forced swim test measures stress-coping strategy, not depression-like behavior. ACS Chem Neurosci 8:955–960. [doi:10.1021/acschemneuro.7b00042](https://doi.org/10.1021/acschemneuro.7b00042)

## Related tasks {#related}

[Rotation](./rotation.md) · [Open field](./open-field.md)
