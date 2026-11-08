---
title: "From tracks to measures"
description: "The common rules RodentFlow uses to turn clean keypoint tracks into measures: analysis window, zones and entry rules, investigation, head dips, freezing, turns, latencies with a cut-off, and two-animal contacts."
---

# From tracks to measures

Each task turns the clean tracks into its own measures; the [task pages](../tasks/) define every one of them with a simulated example. Underneath, the tasks share a small set of rules, collected here. Every threshold is a default you can change in the analysis parameters, and the values used are saved with the session and written into the Methods text.

## Time {#time}

- **Analysis window.** Measures are computed between the analysis start and the end of the analysis length (for example from placing the mouse to a 300 s cut-off). Time outside the window is ignored.
- **Duration of a sample.** Each sample counts for the time until the next one, so times are correct whether every frame or every 2nd or 3rd frame was tracked.
- **Time bins.** The main measures are also computed per bin (1, 5 or 15 minutes, or as set) for the time course.

## Zones and entries {#zones}

A zone is a region of the arena: a chamber, an arm, the centre, the light side, a platform, a quadrant. **Time in a zone** is the time the reference point spends inside it. An **entry** is counted with one of three rules, chosen per task:

| Rule | The animal is in the zone when … | Typical use |
|---|---|---|
| **Body** | the body centre is in it | Open-field centre, place-preference sides |
| **Full** | the body centre **and** the tail base are in it (close to “all four paws”) | Maze arms, passive avoidance, step-down, visual cliff, zero-maze segments |
| **Nose** | the nose is in it | Food zone, reward port, hole pokes |

For maze arms and zero-maze segments the entry has hysteresis: the animal stays in a zone until it meets the rule for another one, so brief tracking noise at a border does not create extra entries.

## Nose and head {#nose}

- **Investigation** of a cup or object: the nose within 2 cm of its edge, the head pointing at it within ±45°, and the body centre not on it (so climbing on the object is not counted as exploring it).
- **Head dips** and **pokes**: the nose beyond an edge (an open arm, the platform, the light side, the deep side) for at least 0.2 s while the body centre and tail base stay behind it.
- **Head direction**: the direction from the ear midpoint to the nose; 0° is image right (or the cue card), counter-clockwise positive.
- **Stretch-attend posture**: body length at least 1.2 × the session median while the body centre moves slower than 5 cm/s, for at least 0.5 s.

## Movement {#movement}

- **Distance and speed** come from the body centre after cleaning. *Moving* means faster than 2 cm/s.
- **Freezing and immobility**: the motion index (displacement of the core keypoints over 0.5 s) below 1 cm/s for at least 1 s. Looming can instead use body speed below 2 cm/s for at least 0.5 s (De Franceschi et al. 2016).
- **Turns**: full 360° turns of the body axis, clockwise and counter-clockwise counted separately; a reversal of more than 90° starts the count again.

## Latencies with a cut-off {#latency}

Many tests end at a fixed time: the water-maze trial, passive avoidance, step-down, novelty-suppressed feeding. When the event has not happened by the cut-off, the latency is set to the cut-off and **flagged as censored**. The group page then adds Kaplan–Meier curves and a log-rank test, which use those animals correctly instead of treating the cut-off as a real latency. A matching yes/no measure (entered: 0 or 100) gives the percentage of animals per group.

## Two animals {#two}

With two mice, contacts are measured between keypoints of A and B: nose to nose within 2.5 cm, nose to the partner’s tail base (anogenital sniffing) within 2.5 cm, nose to the partner’s body centre within 3 cm. **Following** needs the two within 15 cm, both moving faster than 5 cm/s, and the follower pointing at the other within ±45° for at least 0.5 s. Aggression measures use distances and speeds in body lengths, so they suit mice of any size.

## One value per animal {#animal}

In group comparisons the experimental unit is the **animal**. An animal’s sessions within the chosen phase are averaged first, so n is the number of animals, never sessions or frames. Phases (training and test, pre- and post-test) are never pooled unless you choose to.
