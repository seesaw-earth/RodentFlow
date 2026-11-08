---
title: "Morris water maze"
description: "Morris water maze in RodentFlow: Escape latency, path and search strategy · mean proximity and quadrants in the probe. Design, why keypoints help, measures, a simulated example and references."
---

<p class="rf-eyebrow">TASK · LEARNING, MEMORY & FEAR</p>

# Morris water maze

<div class="rf-tags"><span>Pose · one animal</span><span>Also: classic centroid</span><span>Default arena: 120 cm pool, 10 cm platform; 60 s trials</span></div>

**Escape latency, path and search strategy · mean proximity and quadrants in the probe**

The mouse swims in a circular pool of opaque water and uses distal room cues to find a hidden platform below the surface. Acquisition is followed by the escape latency, path length and search strategy; in the probe test the platform is removed and the search near its former location is measured (mean proximity, target quadrant time, crossings). Visible-platform trials rule out visual or motor problems.

## Simulated example {#example}

<figure>

![Simulated morris water maze session: tracks and measures](/img/tasks/water-maze.en.png)

<figcaption>In the 60-second probe the mouse spends 35.8 % of the time in the target quadrant (14.2 % in the opposite one), crosses the former platform zone 6 times and stays 34.3 cm from it on average. Simulated data, made to show how the measures are defined; not a result.</figcaption>
</figure>

## Why keypoints {#why}

The same frame-by-frame keypoint tracking as the open field, with water-maze data processing. The body centre is steadier than a centroid (not moved by the tail or splashes), and head direction shows directly whether the mouse faces the platform after release. The tail base is often under water while swimming, so RodentFlow uses the body centre and falls back to the ear midpoint or nose; each trial gets a Pathfinder-style strategy call.

## What RodentFlow measures {#measures}

| Measure | Definition |
|---|---|
| **Escape latency** | When the body centre enters the platform (radius + margin) and stays for the set time; the trial length if the platform is not found. |
| **Path and swim speed** | Body-centre path from release to the platform, mean swim speed and path efficiency (straight-line distance ÷ actual path). |
| **Mean proximity and cumulative search error** | Mean distance to the platform centre (Gallagher); the sum of 1-s distances minus the ideal straight swim at the same speed (CIPL). |
| **Quadrants and platform zone** | Time in the target, opposite and two adjacent quadrants and in the platform zone; the probe test adds crossings, target quadrant time in the first 30 s and per bin, and the search entropy. |
| **Search strategy** | Pathfinder rules: direct path, focal, directed, indirect, chaining, scanning, thigmotaxis, random; with a cognitive score (0–6). |
| **Thigmotaxis and floating** | Time within the thigmotaxis zone width of the wall; floating = speed < 2 cm/s for ≥ 1 s. Both are non-cognitive factors. |

Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.

## Setting up {#setup}

1. Drag C (centre) and R (wall) to calibrate the pool and enter its inner diameter.
2. Drag the P handle onto the platform centre; in the probe test, onto the former platform location.
3. In the parameters, set the analysis start to the moment of release and the analysis length to the maximum trial time (e.g. 60 s)
4. Fixed distractions such as reflections on the water or the experimenter at the pool edge can be covered first with “Cover part of a video”.

The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).

## Classic centroid version {#classic}

This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).

## References {#references}

- Morris R (1984) Developments of a water-maze procedure for studying spatial learning in the rat. J Neurosci Methods 11:47–60. [doi:10.1016/0165-0270(84)90007-4](https://doi.org/10.1016/0165-0270(84)90007-4)
- Vorhees CV, Williams MT (2006) Morris water maze: procedures for assessing spatial and related forms of learning and memory. Nat Protoc 1:848–858. [doi:10.1038/nprot.2006.116](https://doi.org/10.1038/nprot.2006.116)
- Gallagher M, Burwell R, Burchinal M (1993) Severity of spatial learning impairment in aging: development of a learning index for performance in the Morris water maze. Behav Neurosci 107:618–626. [doi:10.1037/0735-7044.107.4.618](https://doi.org/10.1037/0735-7044.107.4.618)
- Maei HR, Zaslavsky K, Teixeira CM, Frankland PW (2009) What is the most sensitive measure of water maze probe test performance? Front Integr Neurosci 3:4. [doi:10.3389/neuro.07.004.2009](https://doi.org/10.3389/neuro.07.004.2009)
- Maei HR et al. (2009) Development and validation of a sensitive entropy-based measure for the water maze. Front Integr Neurosci 3:33. [doi:10.3389/neuro.07.033.2009](https://doi.org/10.3389/neuro.07.033.2009)
- Cooke MB, O'Leary TP, Harris P, Ma R, Brown RE, Snyder JS (2019) Pathfinder: open source software for analyzing spatial navigation search strategies. F1000Research 8:1521. [doi:10.12688/f1000research.20352.2](https://doi.org/10.12688/f1000research.20352.2)
- Garthe A, Behr J, Kempermann G (2009) Adult-generated hippocampal neurons allow the flexible use of spatially precise learning strategies. PLoS One 4:e5464. [doi:10.1371/journal.pone.0005464](https://doi.org/10.1371/journal.pone.0005464)
- Wolfer DP, Stagljar-Bozicevic M, Errington ML, Lipp HP (1998) Spatial memory and learning in transgenic mice: fact or artifact? News Physiol Sci 13:118–123. [doi:10.1152/physiologyonline.1998.13.3.118](https://doi.org/10.1152/physiologyonline.1998.13.3.118)

## Related tasks {#related}

[Novel object recognition](./novel-object-recognition.md) · [Barnes maze](./barnes-maze.md) · [Passive avoidance (step-through)](./passive-avoidance.md) · [Step-down inhibitory avoidance](./step-down.md) · [Place preference (RTPP / CPP)](./place-preference.md) · [Y-maze spontaneous alternation](./y-maze.md) · [T-maze choice & VTE](./t-maze.md) · [Fear conditioning](./fear-conditioning.md) · [Looming threat escape](./looming-escape.md) · [Platform-mediated avoidance](./platform-avoidance.md)
