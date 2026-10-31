# RodentFlow for Mac

::: info
Written for RodentFlow for Mac 0.7.1 and RodentFlow for iPhone & iPad 1.0 (the pose edition, formerly RodentStudio).
:::

The Mac app is built for whole studies: many animals, groups, repeated sessions, statistics and bulk export. It runs the pose models (RodentPose and RodentLimb), classic centroid tracking and multi-chamber tail suspension. Start with the [Quick start](./quick-start.md), then use the pages in this section as reference. To choose between the Mac and the iPhone or iPad, see [Which edition do I need?](../guide/editions.md)

## Five ideas that make everything easier {#concepts}

- **1. One video = one session of one animal.** Every video belongs to exactly one animal and has a **recording date** and a **session number** (1, 2, 3 … the animal’s 1st, 2nd, 3rd session in this task). On Mac, these three fields are required before analysis.
- **2. The hierarchy is the data.** **Project → Task → Group → Animal → Session.** A *task* is one behavioural test (e.g. “Open Field – cohort 3”). Groups (WT, KO, Vehicle…) are optional and belong to the *animal*, so changing an animal’s group or sex changes it for all its sessions in that task.
- **3. The task decides the method.** You never pick a model. Choosing the task chooses the calibration, the analysis method and the model (6-keypoint pose, 7-keypoint limb pose, classic centroid tracking, or multi-chamber silhouette scoring).
- **4. Tracking once, scoring many times.** Tracking (the slow part) runs once. Zones, thresholds and the analysis window are applied afterwards, so you can adjust them and the results update **without re-tracking**. Source videos are only read, never changed.
- **5. n = animals.** For summaries and statistics, an animal’s included sessions within a phase are averaged first, so **n is the number of animals** — never sessions or frames. Different phases (e.g. training vs test) are never pooled unless you explicitly ask.
