---
title: "Marble burying"
description: "Marble burying in RodentFlow: Marbles buried (from how much each marble is covered) · burying events · marble approaches. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · ANXIETY & RISK ASSESSMENT</p>

# Marble burying

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 40 × 25 cm cage, 4 × 5 marbles</span></div>

**Marbles buried (from how much each marble is covered) · burying events · marble approaches**

Twenty glass marbles are laid out on about 5 cm of flattened bedding and the mouse is left alone for 30 min (15 or 20 min in some protocols); at the end the marbles buried by bedding are counted (usual criterion: ≥ 2/3 covered). It is widely used to study compulsive-like and repetitive digging behaviour and to screen anxiolytic drugs, but what it actually measures is still debated. RodentFlow reads from the video how much each marble is covered, sampling only after the mouse has left it (using the tracking), so it gives when each marble was buried, plus the number and duration of marble approaches.

## Simulated example {#example}

<figure>

![Simulated marble burying session: tracks and measures](/img/tasks/marble-burying.en.png)

<figcaption>After 30 minutes 8 of the 20 marbles count as buried (at least two-thirds covered); 10 are at least half covered. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Whether a marble is covered can only be seen while the mouse is not blocking it. RodentFlow uses the mouse's keypoints (including the tail position extrapolated along the body axis) to tell which marbles are not blocked at a given moment and have been left by the mouse for at least 1 s, and reads the marbles' covered fraction only from those frames; the same keypoints also give the number and duration of nose approaches to each marble.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Marbles buried** | Number and percentage of marbles with ≥ the threshold (2/3 by default) of their visible area covered at the end of the analysis window; the numbers ≥ 1/2 covered and almost fully buried (≥ 95%) are also given. |
| **Covered fraction** | Per marble, c = (m − m0) ÷ (b − m0): m is the mean brightness inside the marble's circle, m0 its value in the reference frame and b the current brightness of a ring of bedding around the marble. 0 = as at the start, 1 = looks the same as the bedding. Sampled only when the mouse has been away from the marble for ≥ 1 s and is not blocking it. |
| **Burying events** | After the mouse leaves a marble, its covered fraction has risen by ≥ 0.2 since the previous reading: count, latency to the first buried marble, and a curve of the number buried every 5 min. |
| **Approaching marbles** | Nose within the set distance of a marble's edge (1 cm by default): count, time, latency to the first approach and the number of marbles approached. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Fix the camera directly above the cage, do not move it during the test, and keep the lighting constant.
2. Drag handles 1–4 onto the centres of the four corner marbles, and enter the numbers of rows and columns and the marble diameter in the parameters; each marble's circle should sit on the marble.
3. Set the analysis start to the moment the mouse is put in; footage from before that makes the best reference, otherwise the frames at the analysis start are used.
4. The stronger the colour contrast between marbles and bedding, the better.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Deacon RMJ (2006) Digging and marble burying in mice: simple methods for in vivo identification of biological impacts. Nat Protoc 1:122–124. [doi:10.1038/nprot.2006.20](https://doi.org/10.1038/nprot.2006.20)
- Thomas A, Burant A, Bui N, Graham D, Yuva-Paylor LA, Paylor R (2009) Marble burying reflects a repetitive and perseverative behavior more than novelty-induced anxiety. Psychopharmacology 204:361–373. [doi:10.1007/s00213-009-1466-y](https://doi.org/10.1007/s00213-009-1466-y)
- Angoa-Pérez M, Kane MJ, Briggs DI, Francescutti DM, Kuhn DM (2013) Marble burying and nestlet shredding as tests of repetitive, compulsive-like behaviors in mice. J Vis Exp 82:50978. [doi:10.3791/50978](https://doi.org/10.3791/50978)
- Wahl L, Punt AM, Arbab T, Willuhn I, Elgersma Y, Badura A (2022) A novel automated approach for improving standardization of the marble burying test enables quantification of burying bouts and activity characteristics. eNeuro 9:ENEURO.0446-21.2022. [doi:10.1523/ENEURO.0446-21.2022](https://doi.org/10.1523/ENEURO.0446-21.2022)

## Related tasks {#related}

[Open field](./open-field.md) · [Elevated plus maze](./elevated-plus-maze.md) · [Elevated zero maze](./elevated-zero-maze.md) · [Light–dark box](./light-dark-box.md) · [Novelty-suppressed feeding](./novelty-suppressed-feeding.md) · [Visual cliff](./visual-cliff.md)
