---
title: "Analysing a video"
description: "The RodentFlow 2.1 analysis flow on iPhone, iPad and Mac: task and coat colour, animal information, calibration, tracking, review, identity checks, manual scoring, and the classic centroid method."
---

# Analysing a video

Every video task follows the same path: **task → animal → calibration → tracking → review → results**. This page describes each step; the [task pages](../tasks/) add what is specific to each test.

## 1 · Task, video and coat colour {#start}

- **iPhone and iPad:** choose the test in the **Assay Library** (or **New analysis** on Home), then the video from Photos or Files. A covered copy made with *Cover part of a video* can be used straight away.
- **Mac:** create a task with **New task…**, then drag videos onto it. One video is one session of one animal.

For pose tasks choose the **coat colour**: *Dark* (the default) or *White* for one-animal tasks; *Two dark mice* or *One dark, one white* for two-animal tasks. The coat colour picks the model; all four models give the same six keypoints and are analysed the same way. The model used is written into every export. See [Models](../models.md#coat).

## 2 · Animal information {#animal}

| Field | Notes |
|---|---|
| **Animal ID** | Use the same ID for every session of an animal. In group comparisons an animal’s sessions of one phase are averaged first, so *n* is the number of animals. |
| **Group** | For example `WT`, `KO`, `Vehicle`. Spelling must match across animals. Names like `WT-Veh` can later be split into two factors (genotype × treatment). |
| **Sex** | Used as a second factor or a filter in group comparisons. |
| **Phase, day, trial** | Shown for tasks that have them: training and test, acquisition and probe, pre-test and post-test, days of a learning curve. Pre- and post-tests of the same animal are paired automatically. |
| **Date** | Taken from the video when it has one; you can change it. |

## 3 · Calibration {#calibration}

On one frame, drag the labelled handles onto the arena and enter its real size in centimetres. A magnifier appears while you drag.

| Arena | Handles |
|---|---|
| Box (open field, light–dark, place preference, fear chamber …) | **1–4** on the inside corners of the floor. Positions are corrected for perspective, so a slightly oblique camera is fine. |
| Circle (water maze, Barnes maze, zero maze) | **C** on the centre, **R** on the wall or edge. |
| Plus, Y- and T-maze | The junction and the end of each arm. |
| Task objects | Cups (**L**, **R**), objects (**A**, **B**), the platform (**P**), the shelter (**S**), the food (**F**), the target hole (**T**), corner marbles (**1–4**), a cue card (**Q**) … each named on the screen and on the task page. |

The analysis settings sit with the calibration:

- **Track the arena only** (on by default): only the arena, plus a margin of 5, 12 or 25 %, is given to the model; the rest of the picture is ignored. If you later drag the calibration outside the tracked region, the app asks you to track again.
- **Analysis start and length**: for example from the moment the mouse is placed to the cut-off of the test. **Time bin** sets the time-course bins.
- **Frames**: every frame, or every 2nd or 3rd frame for long recordings. Fast behaviours (lunges, head scanning) need every frame.
- **Task parameters**: zone sizes, thresholds, which side is paired or deep, the CS or stimulus times. Defaults follow the literature and are listed on each task page.

On the Mac, **Use for all videos of this task…** applies one calibration to every video filmed from the same camera position, and new videos of a task start from the previous calibration, so later animals usually need only a quick check.

## 4 · Tracking {#tracking}

Tap **Start detection** (Mac: **Analyse this video**). The video is read on the device, frame by frame. Tracking saves checkpoints as it goes, so an interrupted analysis continues where it stopped; on the Mac, long recordings are written to disk every few seconds and several videos can queue while you calibrate or review others. Tracking (the slow part) runs once: zones, thresholds and the analysis window can be changed afterwards and the results update **without tracking again**.

## 5 · Review {#review}

The review plays the video with the keypoints drawn on the animal (two mice: **A** blue, **B** red) and a timeline with one row per scored behaviour: entries, investigation, head dips, freezing, attacks and so on. Tap a bar to jump to it.

- **Flags.** Moments to check are marked on the timeline: *Outside the calibrated arena* (the point lies beyond the arena; the frame-by-frame data mark it too), and, with two mice, *Likely swap* and moments where the identity should be checked.
- **Identity.** If A and B are swapped from some frame on, tap **Swap A / B from here**; the results are recalculated at once.
- **Manual scoring.** Mark behaviours yourself with *start* and *end* while watching, for one of the app’s behaviours or one you name (for example “grooming”). For behaviours the app also scores, it reports precision, recall, F1 and onset error against your marks within the stretch you reviewed. Manual marks are exported with the behaviour segments.
- **Excluding a session.** Mark a session as excluded with a reason; the reason is exported, and the session stays out of group statistics.

## 6 · Results and exports {#results}

Each session’s results page lists every measure with its definition, draws the track and heat map, and shows the time course. Exports are described in [Results and exports](./results.md).

## Covering part of a video {#cover}

**Cover part of a video** (Home, or *Cover part of the video…* during an analysis; on the Mac in Tools or a session’s right-click menu) paints fixed shapes over parts of the picture that would distract the tracker: a reflection, a cable, the experimenter at the edge of the pool. Shapes can be rectangles, rounded rectangles, ellipses or polygons, in a colour you choose or sampled from around them. The video is processed once when you save, as a copy with the same timestamps, resolution, orientation and recording date; the original is not changed.

## Classic centroid {#classic}

The classic centroid method is the tracker of RodentFlow 1.x, kept unchanged: it learns the empty arena from frames across the video, subtracts it, and follows the **centre of the body at 10 samples per second**, with no neural network. It covers ten tests: open field, elevated plus maze, light–dark box, Y-maze, T-maze, novel object recognition, Morris water maze, Barnes maze, fear conditioning and conditioned place preference. Results made with RodentFlow 1.x open and analyse as before.

Choose it in the Assay Library under **Classic centroid** (each test there also links to its pose version). The flow is the same: set up the arena shape and size, check a 10-second preview, place the handles, run the full analysis, and read the results. Because it follows the body centre, measures that need the nose or head (object investigation, head dips, head direction) come from the pose version; use one method consistently within a study. The detailed 1.x description is kept in [Older versions](../archive/guide/video-analysis.md).

## Multi-chamber tail suspension {#tst}

Several mice hanging side by side in one recording are scored by their own workflow: see [Tail suspension, multi-chamber](../tasks/tail-suspension.md).
