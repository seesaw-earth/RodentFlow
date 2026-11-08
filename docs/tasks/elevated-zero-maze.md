---
title: "Elevated zero maze"
description: "Elevated zero maze in RodentFlow: Open-segment time + inner / outer head dips + closed-segment peeks and stretched attend. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · ANXIETY & RISK ASSESSMENT</p>

# Elevated zero maze

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 60 cm outer diameter, 5 cm track; 5 min</span></div>

**Open-segment time + inner / outer head dips + closed-segment peeks and stretched attend**

An elevated ring divided into four equal segments: two opposite closed segments with walls and two open ones without. There is no centre zone as in the plus maze, so the animal can explore without interruption; usually 5 min. Less open-segment time and fewer head dips, and more stretched-attend postures from the closed segments, indicate more anxiety-like behaviour; repeated tests are more consistent than in the plus maze.

## Simulated example {#example}

<figure>

![Simulated elevated zero maze session: tracks and measures](/img/tasks/elevated-zero-maze.en.png)

<figcaption>The mouse spends 47.9 % of the 5 minutes on the open segments, with 7 head dips over the outer edge and 4 over the inner edge. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

The segment is judged by the angle of the body centre, optionally also requiring the tail base (≈ four-paw entry). Head dips need the nose beyond the inner or outer edge while the body stays in an open segment; closed-segment peeks are the nose reaching into an open segment while the body and tail base stay closed; stretched attend uses the nose–tail-base length. All of these need the nose and the body judged separately, which a centroid cannot do.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Open-segment time %** | Share of the analysis time in the open segments; entries by the body centre (by default with the tail base). |
| **Entries and transitions** | Open / closed segment entries, share of open entries, latency to the first open entry, open–closed transitions. |
| **Head dips** | Body centre in an open segment and the nose ≥ 1 cm beyond the inner or outer edge for ≥ 0.2 s; inner and outer counted separately. |
| **Closed-segment peeks** | Body centre and tail base in a closed segment with the nose across the boundary in an open segment for ≥ 0.2 s, then withdrawn (an immediate entry is not counted). |
| **Stretch-attend posture (SAP)** | Body length ≥ 1.2 × median with body-centre speed < 5 cm/s for ≥ 0.5 s; also counted from a closed segment toward an open one. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Drag C (centre) and R (outer edge) to calibrate the ring; enter the outer diameter and the track width.
2. Drag the O handle onto the middle of either open segment to orient the four segments.
3. Place the mouse at an open–closed boundary facing the closed segment; the analysis length is typically 300 s.
4. Leave room around the maze so that the nose stays in the image during head dips.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Shepherd JK, Grewal SS, Fletcher A, Bill DJ, Dourish CT (1994) Behavioural and pharmacological characterisation of the elevated \u{201C}zero-maze\u{201D} as an animal model of anxiety. Psychopharmacology 116:56–64. [doi:10.1007/BF02244871](https://doi.org/10.1007/BF02244871)
- Braun AA, Skelton MR, Vorhees CV, Williams MT (2011) Comparison of the elevated plus and elevated zero mazes in treated and untreated male Sprague-Dawley rats: effects of anxiolytic and anxiogenic agents. Pharmacol Biochem Behav 97:406–415. [doi:10.1016/j.pbb.2010.09.013](https://doi.org/10.1016/j.pbb.2010.09.013)
- Tucker LB, McCabe JT (2017) Behavior of male and female C57BL/6J mice is more consistent with repeated trials in the elevated zero maze than in the elevated plus maze. Front Behav Neurosci 11:13. [doi:10.3389/fnbeh.2017.00013](https://doi.org/10.3389/fnbeh.2017.00013)
- Holly KS, Orndorff CO, Murray TA (2016) MATSAP: an automated analysis of stretch-attend posture in rodent behavioral experiments. Sci Rep 6:31286. [doi:10.1038/srep31286](https://doi.org/10.1038/srep31286)

## Related tasks {#related}

[Open field](./open-field.md) · [Elevated plus maze](./elevated-plus-maze.md) · [Light–dark box](./light-dark-box.md) · [Novelty-suppressed feeding](./novelty-suppressed-feeding.md) · [Visual cliff](./visual-cliff.md) · [Marble burying](./marble-burying.md)
