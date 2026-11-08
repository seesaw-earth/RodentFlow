# RodentFlow for Mac

The Mac app is built for whole studies: many animals, groups, repeated sessions, statistics and bulk export. It runs one- and two-animal pose tracking, classic centroid tracking and multi-chamber tail suspension, with the same analysis code as the iPhone and iPad, and imports analyses made on the phone automatically ([Phone to Mac sync](../reference/sync.md)). Long recordings are written to disk while they are tracked, so a pause, a quit or a crash loses only the last few seconds. Start with the [Quick start](./quick-start.md), then use the pages in this section as reference. To compare the Mac with the iPhone and iPad, see [iPhone, iPad and Mac](../guide/editions.md).

## Five ideas that make everything easier {#concepts}

- **1. One video = one session of one animal.** Every video belongs to exactly one animal and has a **recording date** and a **session number** (1, 2, 3 … the animal’s 1st, 2nd, 3rd session in this task). On Mac, these three fields are required before analysis.
- **2. The hierarchy is the data.** **Project → Task → Group → Animal → Session.** A *task* is one behavioural test (e.g. “Open Field – cohort 3”). Groups (WT, KO, Vehicle…) are optional and belong to the *animal*, so changing an animal’s group or sex changes it for all its sessions in that task.
- **3. The task decides the method.** You never pick a model. Choosing the task chooses the calibration, the analysis method and the number of animals (one- or two-animal pose, classic centroid tracking, or multi-chamber motion scoring); for pose tasks, the *Coat colour* in the detection settings picks the model.
- **4. Tracking once, scoring many times.** Tracking (the slow part) runs once. Zones, thresholds and the analysis window are applied afterwards, so you can adjust them and the results update **without re-tracking**. Source videos are only read, never changed.
- **5. n = animals.** For summaries and statistics, an animal’s included sessions within a phase are averaged first, so **n is the number of animals** — never sessions or frames. Different phases (e.g. training vs test) are never pooled unless you explicitly ask.
