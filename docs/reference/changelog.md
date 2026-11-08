---
title: "Release notes"
description: "What is new in RodentFlow 2.1 and 2.0 for iPhone, iPad and Mac."
---

# Release notes

## 2.1 · iOS build 21, Mac build 17 {#2-1-21}

Smoother and cooler, with the same results.

- **Saving in the background.** Switching away during tracking first finishes writing the tracks and the session.
- **Pacing when the phone gets hot.** Tracking slows down when the device is hot and pauses and resumes by itself when it is very hot, with a note on the screen.
- **Large videos.** On iPhone and iPad, 4K and other very large frames are decoded at a reduced size that is still larger than the model input, which saves time and heat. Videos up to 1080p are read exactly as before.
- **Smoother review.** Playback, the timeline and manual scoring respond without redrawing the whole page; *Swap A / B from here* sits on the video when an identity check is flagged.
- **A Done key** above the number pad on every analysis, calibration, tail-suspension and group screen.

## 2.1 · iOS build 20, Mac build 16 {#2-1}

- **Four new tasks:** [platform-mediated avoidance](../tasks/platform-avoidance.md), [step-down inhibitory avoidance](../tasks/step-down.md), [visual cliff](../tasks/visual-cliff.md) and [marble burying](../tasks/marble-burying.md) scored from video.
- **Looming:** freezing can be defined by body speed (De Franceschi et al. 2016), and an optional threat zone.
- **Groups:** each session’s time course is saved for time-course plots; Fisher’s exact or chi-square tests for yes/no measures; survival analysis for step-down and visual-cliff latencies.
- **Exports:** `recording_start`, the recording time stored in the video file, for lining data up with other devices.

## 2.0 {#2-0}

RodentFlow 2.0 brings RodentFlow for iPhone, the pose edition and the Mac app together in one app for iPhone, iPad and Mac.

- **Four ways to measure** in one app: one-animal pose, two-animal pose with identity, classic centroid (the RodentFlow 1.x tracker, unchanged; 1.x results open as before) and multi-chamber tail suspension, on phone and Mac.
- **Coat colour:** WhiteMousePose6 for a white mouse and MousePose6DyadBW for one dark and one white mouse. Every export names the model used.
- **New tasks:** elevated zero maze, novelty-suppressed feeding, passive avoidance, place preference (RTPP / CPP), and the Morris water maze with pose (Pathfinder search strategies, mean proximity, probe measures).
- **Groups:** two-way ANOVA (Type III), ANCOVA, assumption checks, effect sizes with 95 % CI, Kaplan–Meier curves with log-rank tests; groups on the phone as well as the Mac.
- **Figures:** vector PDF, PNG at 300 / 600 dpi, SVG on the Mac; journal column widths; dot, bar, box and violin styles; task atlases with one shared colour scale; source data and a draft legend with every figure.
- **Exports:** behaviour segments with BORIS-style events, DeepLabCut-format keypoints on the phone, Prism tables, long-format tables, a statistics report and a Methods paragraph.
- **Review:** manual scoring with precision, recall and F1 against the automatic scoring; points outside the calibrated arena flagged; two-mouse skeletons in blue and red.
- **Track the arena only**, checkpoints during tracking, **Cover part of a video**, and heat maps over the original frame.
- **Phone to Mac sync** through a folder you choose, with a check that the Mac reproduces the phone’s numbers.
- **The Mac** tracks two mice, writes long recordings to disk as it goes and resumes after a pause or a crash.
- The limb tasks (cylinder, gait, single-mouse tail suspension) moved to the separate [RodentLimb](https://seesaw-earth.github.io/RodentLimb/) app.

## Earlier versions {#earlier}

Release notes for RodentFlow 1.x for iPhone and RodentFlow for Mac up to 0.7 are kept in [Older versions](../archive/reference/changelog.md).
