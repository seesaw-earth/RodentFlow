# Motor function

Beam walking and gait analysis are scored by the experimenter, live or from video, and then entered by hand or imported. RodentFlow does the averaging, the derived measures and the group statistics.

## Beam walking {#beam-walking}

Balance and coordination while crossing a narrow beam.

**Fields.** **Beam** (the label of the beam, e.g. `12 mm` or `6 mm round`) and an optional **Beam width** in mm. Then one row per trial with:

| Per trial | Notes |
|---|---|
| Traversal time | s, required |
| Foot slips | count, default 0 |
| Fell | yes / no |

Use **Day** for training days and **Beam** to keep beams apart. The Groups tab can filter by beam.

| Metric | Unit | Definition |
|---|---|---|
| Traversal time | s | Mean time to cross over the trials entered |
| Foot slips per trial | — | Mean slips per trial |
| Total foot slips | count | Sum over trials |
| Falls | % | Trials with a fall / trials × 100 |
| Trials | count | Number of trials entered |

Series: traversal time per trial.

**Import.** One row per trial with `subject, group, phase, day, trial, time_s, slips, fell`, where `phase` is the beam. The [sample file](/samples/example_beam_trials.csv) has this layout. In the Groups tab, *Across days* then gives a learning curve per beam with a mixed ANOVA.

## Gait analysis {#gait-analysis}

Footprint (ink or paint) gait analysis.

**Fields.** Optional **Run duration** (s) and **Run distance** (cm) for cadence and speed. Then one row per stride:

| Per stride | Notes |
|---|---|
| Side | —, left or right |
| Hind stride length | cm |
| Fore stride length | cm |
| Hind base width | cm |
| Fore base width | cm |
| Paw overlap | cm, distance between fore and hind prints of the same side |

Measure consecutive strides in the middle of the run and skip the first and last steps, where the animal accelerates and stops.

| Metric | Unit | Definition |
|---|---|---|
| Hind stride length, fore stride length | cm | Mean over strides |
| Hind base width, fore base width | cm | Mean over strides |
| Paw overlap | cm | Mean fore–hind print distance |
| Hind stride CV | % | SD / mean of hind stride length × 100 (variability; needs ≥ 2 strides) |
| Hind stride asymmetry | % | \|L − R\| / mean(L, R) × 100 (needs strides from both sides) |
| Cadence | strides/s | Strides entered / run duration |
| Walking speed | cm/s | Run distance / run duration |
