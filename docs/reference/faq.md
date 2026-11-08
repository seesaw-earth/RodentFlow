---
title: "FAQ"
description: "Answers to common questions about RodentFlow 2.1: tracking, two mice, devices, data, groups and statistics."
---

# FAQ

## Tracking {#tracking}

### Which model will my video use?

The task decides one or two animals; the *Coat colour* you choose decides the model: MousePose6 (dark), WhiteMousePose6 (white), MousePose6Dyad (two dark) or MousePose6DyadBW (one dark, one white). All four give the same six keypoints. See [Models](../models.md#coat).

### The keypoints jump to a shadow, a reflection or the wall

1. Check the **coat colour** setting: a white mouse needs *White*.
2. Keep *Track the arena only* on, and place the calibration handles on the inner floor, so that the picture outside the arena is ignored.
3. Cover fixed distractions (a reflection, a cable, the edge of the pool) with **Cover part of a video** and analyse the covered copy.
4. Improve the recording: even light, locked exposure, a floor that contrasts with the coat. See [Recording videos that track well](../guide/recording.md).

### Some points are marked “Outside the calibrated arena”

They lie beyond the arena you calibrated: often the nose during a head dip over a maze edge, which is expected, or a calibration handle placed slightly off. The flag is only a marker; the tracks and results are not changed. Check the calibration if many frames are flagged.

### The two mice swapped identities

In the review, go to a flagged moment (*Likely swap*), and if A and B are wrong from there on, tap **Swap A / B from here**; the results update at once. For future recordings, mice that differ in coat colour, size or a mark are told apart most reliably. See [Two mice, two identities](../principles/tracking.md#identity).

### Can I analyse several animals in one video?

Yes, in three ways: two mice in one arena with a two-animal task; several mice hanging side by side with [multi-chamber tail suspension](../tasks/tail-suspension.md); or several separate arenas in one picture, analysing the video once per arena with a different calibration each time.

### Can I track rats?

The pose models were trained on mice. The classic centroid method does not assume a species and tracks rats; enlarge the object and hole zones, which are set for mice.

## The app {#app}

### Does RodentFlow upload my videos?

No. There is no account and no upload; videos are analysed where they are stored. Phone-to-Mac sync uses only a folder you choose. See the [Privacy Policy](../privacy.md).

### Do I need Python, GitHub or an internet connection?

No. The models are built into the app and everything runs on the device.

### What video formats work?

MP4 and MOV with H.264 or HEVC, at any frame rate and resolution. If a file will not open, re-encode it as H.264 MP4, for example with [HandBrake](https://handbrake.fr/).

### The analysis stopped when I switched apps, or the phone got warm

Tracking saves checkpoints as it goes and continues where it stopped. When you switch apps, it first finishes saving. When the phone gets hot it slows down, and if it gets very hot it pauses and resumes by itself once it has cooled.

### Do my RodentFlow 1.x results still work?

Yes. Results, runs and manual entries made with RodentFlow 1.x open and analyse as before, and take part in group comparisons.

### Where are the cylinder, gait and single-mouse tail-suspension tasks?

They are in the separate **RodentLimb** app, with its own limb models. See the [RodentLimb site](https://seesaw-earth.github.io/RodentLimb/).

### How do I switch between English and Chinese?

The app follows the device language. On iPhone and iPad you can choose RodentFlow’s language in the Settings app; on the Mac use the language menu in the toolbar or Settings. Data and exports stay in English.

## Groups and statistics {#groups}

### n is smaller than the number of results

n counts animals. Several sessions of one animal within the chosen phase are averaged first, and excluded sessions are left out. See [Statistics](../principles/statistics.md).

### A group appears twice

Group names must be spelled the same for every animal: `WT` and `wt` are two groups. Rename the group on the animal (Mac) or in the analysis (iPhone and iPad).

### Some animals never reached the platform or never stepped down

Their latency is set to the cut-off and flagged as censored. Use the Kaplan–Meier curves and the log-rank test on the group page for these measures. See [Latencies with a cut-off](../principles/metrics.md#latency).

## Other {#other}

### How do I report a problem?

See [Support](../support.md). Include the app version, device and system version, the task, and what you did. Do not post unpublished research videos publicly.

### Can RodentFlow be used for clinical or veterinary diagnosis?

No. It is a research tool for laboratory animal studies.
