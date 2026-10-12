# Anxiety & affect

Open field, elevated plus maze and light–dark box are scored from video. Marble burying and sucrose preference are entered by hand or imported.

## Open field / center {#open-field-center}

Locomotion and the avoidance of the open center of a novel arena.

**Arena.** Rectangle (four corners) or circle (center and edge). Enter the inner floor size.

**Settings**

| Setting | Default | Meaning |
|---|---|---|
| Center zone size | 50 % | Side of the concentric center square as a fraction of the arena side, so 50 % of the side is 25 % of the area. For a circle, the radius of the center circle as a fraction of the arena radius. |
| Moving threshold | 2 cm/s | Speed at or above which the animal counts as mobile |
| Minimum immobility bout | 2 s | Shortest run below the moving threshold that counts as immobility |
| Time bins | 5 min | Bin length for the per-bin series (1, 2, 5 or 10 min) |
| Zone entry criterion | 0.3 s | Time in the center before an entry counts |

**Metrics**

| Metric | Unit | Definition |
|---|---|---|
| Total distance | m | Sum of steps between consecutive detected samples |
| Mean speed | cm/s | Total distance / analyzed duration |
| Mobile time | % | Time with speed ≥ moving threshold / time with a known speed |
| Immobility | s | Sum of bouts below the moving threshold lasting at least the minimum bout |
| Center time | s, % | Time in the center zone; % of detected time |
| Center entries | count | Periphery → center transitions meeting the entry criterion |
| Latency to center | s | Time to the first center entry (analysis length if never) |
| Center distance | % | Distance traveled inside the center / total distance |
| Tracked samples | % | Samples with the animal detected / all samples |

Series: distance per bin, center time per bin.

**Tips.** Analyze a fixed length, such as the first 10 minutes, so that animals are compared over the same time. Speed is computed from positions 0.2 s apart (central difference), so tracking jitter of a few millimeters does not count as movement at the default threshold.

## Elevated plus maze {#elevated-plus-maze}

Time on the open arms relative to the closed arms.

**Arena.** Plus maze: **C** on the center and **N/E/S/W** on the arm ends. Enter **Arm length (excluding center)** and **Arm width**. N is the top of the image.

**Settings**

| Setting | Default | Meaning |
|---|---|---|
| Open arms | N–S (top/bottom) | Which pair of arms is open; the other pair is closed |
| Extra center margin | 0 cm | Enlarges the central square on each side. By default the center is the square where the arms cross (side = arm width). |
| Zone entry criterion | 0.25 s | Time in an arm before an entry counts |

**Metrics**

| Metric | Unit | Definition |
|---|---|---|
| Open-arm time | % | Open / (open + closed) arm time × 100. Center time is excluded from the denominator. |
| Open-arm entries | % | Open / (open + closed) entries × 100 |
| Open-arm time, closed-arm time, center time | s | Time in both open arms, both closed arms, and the central square |
| Open-arm entries, closed-arm entries | count | Arm entries meeting the entry criterion |
| Total arm entries | count | Open + closed entries, a locomotor index |
| Latency to open arm | s | Time to the first open-arm entry |
| Total distance | m | Sum of steps (see the caution below) |
| Tracked samples | % | |

Label: the arm sequence, e.g. `ON CE CW OS`, where O/C is open/closed and N/E/S/W is the arm.

**How arms are assigned.** Each position is mapped onto the nearest arm through the calibrated centerlines (see [maze geometry](../principles/metrics.md#maze-geometry)). The arm is then given by the direction from the center, and the center by the central square.

::: warning Total distance on the plus maze
On our validation video the plus maze filled only about half of the frame width (about 1.5 pixels per cm at analysis resolution). Times and entries matched the ground truth exactly, but total distance came out 35 % too high, because small posture changes during sniffing add up to distance. Use distance on the plus maze only to compare groups recorded the same way, or frame the maze more tightly. See [Validation](../principles/validation.md).
:::

## Light–dark box {#light-dark-box}

Time in an open, lit compartment versus a dark, enclosed one.

**Arena.** Rectangle covering the whole box, or only the light compartment if the dark one is covered and invisible.

**Settings**

| Setting | Default | Meaning |
|---|---|---|
| Light compartment | Left | Side of the light compartment in the image |
| Light compartment length | 67 % | Fraction of the calibrated length that is light. Use 100 % if only the light compartment was calibrated. |
| Count unseen samples as dark | on | Samples where the animal is not visible count as dark time (covered dark box) |
| Zone entry criterion | 0.5 s | Time in a compartment before a transition counts |

**Metrics**

| Metric | Unit | Definition |
|---|---|---|
| Light-box time | %, s | Light time / (light + dark time) × 100 |
| Dark-box time | s | Time in the dark compartment, including unseen samples if enabled |
| Transitions | count | Compartment changes meeting the entry criterion |
| Latency to dark | s | Time to the first entry into the dark compartment (0 if the animal starts there) |
| Distance in light | m | Distance traveled inside the light compartment |
| Visible samples | % | Samples with the animal visible. With a covered dark box this is about the light-box time, and no quality flag is raised. |

**Tip.** With a covered dark box, keep the default entry criterion of 0.5 s. A brief loss of detection in the light compartment is then not mistaken for a visit to the dark side.

## Marble burying {#marble-burying}

Entered by hand: count the marbles that are at least two-thirds covered by bedding at the end of the test.

| Field | Default |
|---|---|
| Marbles in cage | 20 |
| Buried (≥ 2/3 covered) | required |
| Partially buried | optional |
| Test duration | 30 min |

| Metric | Unit | Definition |
|---|---|---|
| Marbles buried | %, count | Buried / total × 100 |
| Partially buried | count | As entered |

## Sucrose preference {#sucrose-preference}

Entered by hand or imported as raw bottle weights, with one row per measurement day.

| Field | Notes |
|---|---|
| Body weight | g, optional; enables intake per kg |
| Sucrose concentration | %, default 1 |
| Per day: sucrose bottle start / end, water bottle start / end | g (≈ mL) |
| Per day: sucrose leak control, water leak control | Loss from bottles on an empty cage, subtracted from intake |
| Per day: measurement period | h, default 24 |

| Metric | Unit | Definition |
|---|---|---|
| Sucrose preference | % | Σ sucrose / (Σ sucrose + Σ water) × 100, pooled across days. Chance level is 50 %. |
| Mean daily preference | % | Average of the daily preferences |
| Sucrose, water, total intake | g/day | Intake = start − end − leak, divided by the measured days |
| Sucrose intake / BW | g/kg/day | Sucrose intake normalized to body weight |

Series: preference per day. The app flags negative intakes, which point to a weighing error, and total intake below 1 g/day, which points to a leak.

**Tip.** Swap the bottle sides between days to control for a side preference. The pooled preference weights days by intake; the mean daily preference weights each day equally.
