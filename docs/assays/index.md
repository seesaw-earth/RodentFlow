# Assays

RodentFlow knows 15 assays plus a custom table. For each assay it knows the arena, the phases, the zones and settings, the metrics with their definitions, the natural within-animal comparison and the chance level of a measure, where one exists. This page is the overview; the four category pages give the details.

| Assay | Category | From video | Phases | Main measure |
|---|---|---|---|---|
| [Open field / center](./anxiety.md#open-field-center) | Anxiety & affect | Rectangle or circle | — | Total distance; center time % |
| [Elevated plus maze](./anxiety.md#elevated-plus-maze) | Anxiety & affect | Plus maze | — | Open-arm time % |
| [Light–dark box](./anxiety.md#light-dark-box) | Anxiety & affect | Rectangle | — | Light-box time % |
| [Marble burying](./anxiety.md#marble-burying) | Anxiety & affect | — | — | Marbles buried % |
| [Sucrose preference](./anxiety.md#sucrose-preference) | Anxiety & affect | — | — | Sucrose preference % |
| [Y-maze](./memory.md#y-maze) | Learning & memory | Y-maze | — | Spontaneous alternation % |
| [T-maze](./memory.md#t-maze) | Learning & memory | T-maze | — | Right first choice % |
| [Novel object recognition](./memory.md#novel-object-recognition) | Learning & memory | Rectangle or circle | Training, Test | Discrimination index |
| [Morris water maze](./memory.md#morris-water-maze) | Learning & memory | Circle | Acquisition, Probe | Escape latency; target quadrant % |
| [Barnes maze](./memory.md#barnes-maze) | Learning & memory | Circle | Acquisition, Probe | Primary latency; target quadrant % |
| [Fear conditioning](./memory.md#fear-conditioning) | Learning & memory | Rectangle | Training, Context test, Cue test | Freezing %; CS freezing % |
| [Beam walking](./motor.md#beam-walking) | Motor function | — | Beam (free text) | Traversal time |
| [Gait analysis](./motor.md#gait-analysis) | Motor function | — | — | Hind stride length |
| [Conditioned place preference](./reward.md#conditioned-place-preference) | Reward & decision | Rectangle | Pre-test, Conditioning, Test | Preference score |
| [Two-armed bandit](./reward.md#two-armed-bandit) | Reward & decision | — | Session / block (free text) | High-value choices % |
| Other / custom table | Other | — | free text | Any imported column |

Every assay can also be entered by hand or imported from a table ([how](../guide/manual-and-import.md)).

## Zones at a glance

<figure>

![Zones of the video assays](/img/zones.en.png)

<figcaption>Zones are defined in arena centimeters after calibration, and every one can be changed on the result screen after tracking. The sizes shown are the defaults: center 50 % of each side, light compartment 2/3 of the box, a 20 % neutral chamber when CPP is set to 3 chambers (the default is 2 chambers split at 50 %), object radius 8 cm, platform radius 6 cm, wall zone 10 cm, and 20 Barnes holes.</figcaption>
</figure>

## Rules shared by all video assays

These rules are explained in [From positions to metrics](../principles/metrics.md).

- **Sampling.** Positions are sampled 10 times per second, and each sample stands for the time until the next one.
- **Time in a zone** counts only samples where the animal was detected. Percentages of zone time use the detected time as the denominator, unless stated otherwise.
- **An entry** into a zone is counted only after the animal has stayed in it for the *entry criterion*: 0.3 s by default, 0.25 s in the plus maze and the T- and Y-mazes, 0.5 s in the light–dark box and CPP, 0.2 s in the Barnes maze. Being in a zone at the start of the analysis is not an entry.
- **A latency** is the time from the start of the analysis window to the first entry. It is the window length if the animal never enters, and 0 if it starts in the zone.
- **Distance** adds up the steps between consecutive detected samples, so gaps in detection add no distance.
- **The analysis window** (*Start after*, *Length*) restricts every metric to part of the video, e.g. the first 5 minutes.
- **Tracked samples %** is the share of samples in which the animal was found. Results below 90 % carry a quality flag. The light–dark box, fear conditioning and the Barnes maze are exempt because the animal is expected to be hidden at times there.
