---
title: "Resident–intruder (aggression)"
description: "Resident–intruder (aggression) in RodentFlow: Attack latency, bouts, duration · chasing, keep down, threat, mounting. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · SOCIAL BEHAVIOUR</p>

# Resident–intruder (aggression)

<div class="rf-tags"><span>Pose · two animals</span><span>Default arena: home cage 30 × 18 cm; 10 min from the intruder’s entry</span></div>

**Attack latency, bouts, duration · chasing, keep down, threat, mounting**

An unfamiliar intruder is placed into the resident's home cage, usually for 10 min. Readouts are attack latency, attack bouts and duration, and aggression-related behaviours such as chasing, keep down, threat postures and mounting; sniffing and following are reported as non-aggressive social behaviour.

## Simulated example {#example}

<figure>

![Simulated resident–intruder (aggression) session: tracks and measures](/img/tasks/resident-intruder.en.png)

<figcaption>The first attack comes 8.1 s after the intruder is put in. Over the next four minutes there are 17 attack bouts (11.4 s in all), 24.6 s of following or chasing and 36 s of anogenital sniffing. (The figure uses a simplified version of the attack rule.) Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

Attacks have a kinematic signature: the resident suddenly accelerates toward the other mouse (approach speed jumps), the pair then tumbles fast and in changing directions, and the intruder flees or is chased. RodentFlow uses each mouse's neck → tail base distance as its body length, computes distances and relative speed in body lengths, and scores attacks, clinch, chasing, keep down, lateral threat, upright postures and mounting; no arena calibration is needed.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Attack latency** | Time from the intruder's introduction to the first attack (s); the test duration when there was no attack. |
| **Attack bouts and duration** | Episodes where the mice are in contact and move fast in changing directions (initiator not judged): count, total and mean duration; clinch (rolling in place) reported separately. |
| **Other aggressive behaviour** | Total duration of chasing, keep down, lateral threat and aggressive upright, separate from attacks. |
| **Percentage of attacking mice** | Each test reports “Attack occurred” (0 / 1); the group mean × 100 in the summary table. |
| **Social investigation** | Anogenital sniffing, nose-to-nose contact, following (not counted as aggression on their own); mounting is counted separately. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Start recording before introducing the intruder: footage with only the resident is used to identify the resident and the introduction time automatically.
2. Detect every frame (a lunge lasts only 100–200 ms), at ≥ 25 fps.
3. Identity is most reliable when the mice differ in coat or size, or when the intruder is marked.
4. In the review, check the “Attack” timeline; adjust the thresholds in the parameters if needed.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## References {#references}

- Koolhaas JM, Coppens CM, de Boer SF, Buwalda B, Meerlo P, Timmermans PJA (2013) The resident-intruder paradigm: a standardized test for aggression, violence and social stress. J Vis Exp 77:e4367. [doi:10.3791/4367](https://doi.org/10.3791/4367)
- Segalin C et al. (2021) The Mouse Action Recognition System (MARS) software pipeline for automated analysis of social behaviors in mice. eLife 10:e63720. [doi:10.7554/eLife.63720](https://doi.org/10.7554/eLife.63720)
- Hong W et al. (2015) Automated measurement of mouse social behaviors using depth sensing, video tracking, and machine learning. PNAS 112:E5351–E5360. [doi:10.1073/pnas.1515982112](https://doi.org/10.1073/pnas.1515982112)

## Related tasks {#related}

[Three-chamber sociability](./three-chamber.md) · [Social interaction test (CSDS)](./social-interaction.md) · [Dyadic social interaction](./dyadic-social.md)
