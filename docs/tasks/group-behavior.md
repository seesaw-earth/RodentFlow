---
title: "Group behaviour"
description: "Group behaviour in RodentFlow: 3–10 dark mice · contact, grouping, nearest-neighbour distance, rank (preview). Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · SOCIAL BEHAVIOUR</p>

# Group behaviour

<div class="rf-tags"><span>Pose · group of 3–10</span><span>Default arena: 40 × 40 cm; no calibration needed (body lengths)</span></div>

**3–10 dark mice · contact, grouping, nearest-neighbour distance, rank (preview)**

3–10 mice move freely in one arena, without marks. The readouts are group-level contact, nearest-neighbour distance, group sizes and activity, plus approach–avoid events and a hierarchy computed from them.

## Simulated example {#example}

<figure>

![Simulated group behaviour session: tracks and measures](/img/tasks/group-behavior.en.png)

<figcaption>In this simulated 10-minute session of four mice, each mouse is in contact with another for 65.4 % of the time on average, and all four form one group for 37.9 % of it (the stretches when they rest together); the mean nearest-neighbour distance is 6.4 cm. 108 approach–avoid events (27 per mouse, 8 of them chases) rank ID 2 first and ID 3 last, with normalised David’s scores of 1.93 and 1.18. The IDs never swap here; in a real video they can when mice touch. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Contact and grouping are defined from the distances between body parts; approach–avoid events need each mouse's position and direction of movement. All come from the 6 keypoints and hold up better than a centroid when mice touch.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Contact** | Fraction of time a mouse’s body is within 0.35 body lengths of another mouse’s body (mean of all mice). |
| **Nearest-neighbour distance** | Mean distance from each mouse to the nearest other mouse (body centres). |
| **Approach–avoid events** | One mouse moves toward its nearest neighbour while that neighbour moves away along the same line, lasting ≥ 0.4 s. |
| **Rank (preview)** | David’s score and Elo from approach–avoid events (the approacher wins). Identities can swap when mice touch and do not refer to specific animals. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

**Body lengths, not centimetres.** Distances and speeds are in body lengths (BL: the median nose-to-tail-base distance of all mice in the video), so the arena does not need to be calibrated. Contact means the bodies (the nose–neck–centre–tail-base line of each mouse) come within 0.35 BL; a group is a set of mice joined by contacts (de Chaumont et al. 2019).

**The approach–avoid rule in full.** Over a 0.4 s window, one mouse moves faster than 0.6 BL/s toward its nearest neighbour ahead of it (cosine > 0.8), 0.3–2.5 BL away, and that mouse moves away along the same line (cosine > 0.5), also faster than 0.6 BL/s, for at least 0.4 s. A chase is the same event at higher speed: the approacher faster than 2.7 BL/s and the other faster than 2 BL/s. The rule comes from a long-term study of rat groups ([Nagy et al. 2024](https://doi.org/10.1038/s41598-024-72437-5)), scaled to body lengths; it has not yet been checked against manual scoring in mice.

**Also in the report.** Time alone (in contact with no other mouse), group spread (mean distance to the group’s centre), the largest group and the share of time at each size, time with all mice together, the share of mice moving (faster than 0.25 BL/s), distance per mouse, contacts per minute, nose-to-nose and anogenital contact, chases, and identity-risk events (two body centres closer than 0.5 BL). For the hierarchy: a win–loss matrix, normalised David’s score and Elo per ID (Elo starts at 1000, k = 100), linearity h′, triangle transitivity, directional consistency, steepness, and how well the ranks from the first and second half of the events agree. Contact over time and nearest-neighbour distance over time are drawn as curves, and approach–avoid events, chases and moments with all mice together appear as timelines in the review.

**Why ranks are a preview.** Without physical marks, IDs can swap when mice touch, and the swaps add up: in validation videos with 7–10 mice, about one pair swapped every 1–3 minutes. IDs also do not refer to particular animals. The group-level measures (contact, nearest-neighbour distance, group sizes) are hardly affected, because a swap moves no mouse. Anything per ID (the ranks, per-pair contact) depends on the IDs staying right; to tie ranks to specific animals you need marks or RFID.

## Setting up {#setup}

1. Film from above with the whole arena in view and all mice visible; this version supports dark mice only.
2. Process every frame, at 25 fps or more.
3. A hierarchy needs enough events (at least 10 and ideally 20 per mouse), so do not make recordings too short.
4. IDs can swap when mice touch and do not refer to specific animals: tying ranks to specific animals needs physical marks or RFID.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- de Chaumont F et al. (2019) Real-time analysis of the behaviour of groups of mice via a depth-sensing camera and machine learning. Nat Biomed Eng 3:930–942. [doi:10.1038/s41551-019-0396-1](https://doi.org/10.1038/s41551-019-0396-1)
- Reinwald JR et al. Individual differences drive social hierarchies in male mouse societies. eLife 109354. [doi:10.7554/eLife.109354](https://doi.org/10.7554/eLife.109354)
- Gammell MP et al. (2003) David’s score: a more appropriate dominance ranking method than Clutton-Brock et al.’s index. Anim Behav 66:601–605. [doi:10.1006/anbe.2003.2226](https://doi.org/10.1006/anbe.2003.2226)
- Sánchez-Tójar A, Schroeder J, Farine DR (2018) A practical guide for inferring reliable dominance hierarchies and estimating their uncertainty. J Anim Ecol 87:594–608. [doi:10.1111/1365-2656.12776](https://doi.org/10.1111/1365-2656.12776)

## Related tasks {#related}

[Three-chamber sociability](./three-chamber.md) · [Social interaction test (CSDS)](./social-interaction.md) · [Dyadic social interaction](./dyadic-social.md) · [Resident–intruder (aggression)](./resident-intruder.md)
