---
title: "Novelty-suppressed feeding"
description: "Novelty-suppressed feeding in RodentFlow: Latency to feed (confirmed, censored) · approach · home-cage control. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · ANXIETY & RISK ASSESSMENT</p>

# Novelty-suppressed feeding

<div class="rf-tags"><span>Pose · one animal</span><span>Default arena: 40 × 40 cm; 10 min cut-off</span></div>

**Latency to feed (confirmed, censored) · approach · home-cage control**

After food deprivation (usually 24 h) the mouse is placed in a brightly lit novel arena with a pellet in the centre. Novelty suppresses feeding; the latency to the first bite reflects anxiety-like behaviour and is shortened by chronic (not acute) antidepressants. The cut-off is usually 10 min; home-cage food intake over 5 min right after the test and the weight loss rule out appetite differences.

## Simulated example {#example}

<figure>

![Simulated novelty-suppressed feeding session: tracks and measures](/img/tasks/novelty-suppressed-feeding.en.png)

<figcaption>The nose first reaches the food zone after 35 s and returns 16 times in all. The first stretch that meets the candidate-feeding rule starts at 244 s; in the review you confirm the first bite there. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Standard video tracking only knows where the animal is and cannot tell reaching the food from eating it. RodentFlow measures the approach from the nose–food distance, marks “nose at the food, body almost still for a few seconds” as candidate feeding on the review timeline, and lets you confirm the first bite in the review; unconfirmed results do not enter group statistics.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Latency to feed** | Time from placement to the first bite, confirmed by hand in the review; no bite before the cut-off is set to the cut-off and flagged as not eaten (right-censored), analysed with survival analysis on the group page. Unconfirmed sessions do not enter group statistics. |
| **Approach to the food** | Latency of the first nose entry into the food zone (radius 3 cm by default), number of entries and time there. |
| **Candidate feeding** | Nose in the food zone with body-centre speed < 2 cm/s for ≥ 3 s; marked on the review timeline to find the first bite. |
| **Hunger control** | Home-cage food in 5 min (g) and weight loss from the fast (%), usable as covariates. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Calibrate the whole arena and drag the F handle onto the food.
2. Set the analysis start to the moment the mouse is placed in the arena and the length to the cut-off (typically 600 s)
3. After the analysis, confirm the first bite in the review (“Set as first bite”) or “No feeding before the cut-off”.
4. Enter the 5-min home-cage food intake and the weights before the fast and on the test day in the parameters as the hunger control.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Samuels BA, Hen R (2011) Novelty-suppressed feeding in the mouse. In: Gould TD (ed) Mood and Anxiety Related Phenotypes in Mice II. Neuromethods 63:107–121. [doi:10.1007/978-1-61779-313-4_7](https://doi.org/10.1007/978-1-61779-313-4_7)
- Santarelli L et al. (2003) Requirement of hippocampal neurogenesis for the behavioral effects of antidepressants. Science 301:805–809. [doi:10.1126/science.1083328](https://doi.org/10.1126/science.1083328)
- Dulawa SC, Hen R (2005) Recent advances in animal models of chronic antidepressant effects: the novelty-induced hypophagia test. Neurosci Biobehav Rev 29:771–783. [doi:10.1016/j.neubiorev.2005.03.017](https://doi.org/10.1016/j.neubiorev.2005.03.017)
- Kaplan EL, Meier P (1958) Nonparametric estimation from incomplete observations. J Am Stat Assoc 53:457–481. [doi:10.1080/01621459.1958.10501452](https://doi.org/10.1080/01621459.1958.10501452)

## Related tasks {#related}

[Open field](./open-field.md) · [Elevated plus maze](./elevated-plus-maze.md) · [Elevated zero maze](./elevated-zero-maze.md) · [Light–dark box](./light-dark-box.md) · [Visual cliff](./visual-cliff.md) · [Marble burying](./marble-burying.md)
