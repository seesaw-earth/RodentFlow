---
title: "What RodentFlow does"
description: "RodentFlow 2.1 turns videos of laboratory mice into behavioural measures on iPhone, iPad and Mac: six-keypoint pose, two-mouse identity, classic centroid tracking and multi-chamber tail suspension."
---

# What RodentFlow does

RodentFlow turns **videos of laboratory mice into behavioural measures**, on an iPhone, iPad or Mac. Choose the test, mark the arena on one frame, and the app tracks the animal, scores the session, and compares groups with statistics and publication-ready figures. There is no account and no upload: videos and results stay on your device.

## One app, four ways to measure {#methods}

The task you choose decides how the video is tracked. You never pick a model; for pose tasks you only say what colour the mice are.

| Method | What it tracks | Used for |
|---|---|---|
| **Pose · one animal** | Six keypoints on every frame: nose, both ears, neck, body centre and tail base. MousePose6 for a dark mouse, WhiteMousePose6 for a white one. | 24 tasks, from open field and elevated mazes to object recognition, water maze, fear conditioning and head direction |
| **Pose · two animals** | The same six keypoints for two mice, with identity A and B kept across the whole video. MousePose6Dyad for two dark mice, MousePose6DyadBW for one dark and one white. | Dyadic social interaction and resident–intruder aggression |
| **Classic centroid** | The body centroid at 10 Hz by background subtraction, with no model: the tracker of RodentFlow 1.x. | Ten tests with zone and path measures: open field, elevated plus maze, light–dark box, Y- and T-maze, object recognition, water maze, Barnes maze, fear conditioning, place preference |
| **Multi-chamber** | Several mice filmed side by side; motion in each chamber. | Tail suspension |

On iPhone and iPad you can also **enter values by hand or import a table** (marble burying, sucrose preference, beam walking, gait, two-armed bandit or your own measures), and analyse them with the rest. See all tests on the [Tasks](../tasks/) page.

## From video to figure {#workflow}

1. **Choose the task** and, for pose tasks, the coat colour.
2. **Calibrate**: drag a few handles onto the arena, the cups, the maze arms or the platform on one frame, and enter its size in centimetres.
3. **Track**: the app reads the video on the device. Only the arena is analysed, and progress is saved as it goes.
4. **Review**: play the video with the tracked points drawn on it and a timeline of every scored behaviour. Moments that need a look (identity, leaving the arena) are flagged.
5. **Read the results**: every measure with its definition, figures of the track and heat map, and a time course.
6. **Compare groups**: the app suggests a test for the design, draws every animal, and exports the figure, statistics, source data and a Methods paragraph.

## iPhone, iPad and Mac {#devices}

All three run the same analysis code, so the same video, calibration and settings give the same numbers. The iPhone and iPad are convenient at the bench; the Mac organises whole studies (project, task, group, animal, session) and handles long recordings. Analyses done on the phone can be sent to the Mac automatically: see [Phone to Mac sync](../reference/sync.md).

## Where to go next {#next}

<div class="rf-cards">
  <a href="./getting-started.html"><strong>Quick start</strong><span>Your first analysis in ten minutes.</span></a>
  <a href="./recording.html"><strong>Recording</strong><span>Camera, light and arena for clean tracking.</span></a>
  <a href="../tasks/"><strong>Tasks</strong><span>Every test: design, measures, simulated example, references.</span></a>
  <a href="../principles/performance.html"><strong>Speed and accuracy</strong><span>How fast and how accurate the tracking is.</span></a>
</div>
