---
title: "Speed and accuracy"
description: "How fast RodentFlow tracks on iPhone, iPad and Mac, how accurate its four pose models are on held-out test images, and how well it keeps two mice apart."
---

# Speed and accuracy

All tracking runs on the iPhone, iPad or Mac itself, with the Core ML models built into the app. This page collects the measured speed of the tracking path, the accuracy of the four pose models on held-out test images, and how well identities are kept in two-mouse recordings.

## Speed {#speed}

<figure>

![Pose tracking speed on four Apple devices](/img/perf/speed.en.png)

<figcaption>Single-mouse pose tracking on a 30-second, 1280 × 960 maze clip at 25 frames per second, timed with the app’s full tracking path: video decoding, letterboxing, the Core ML model and choosing the best candidate.</figcaption>
</figure>

- Every device tested tracks **2.5 to 4.4 times faster than real time**: a 10-minute video takes 2.3 to 4 minutes.
- The two-mouse model runs **1.8 to 3.3 times faster than real time** on two-mouse clips.
- Most of the time per frame is spent decoding and preparing the image; the network itself takes 5.8 ms per frame on a MacBook Air M4 and 11.2 ms on a MacBook Pro M2.
- Long recordings can be tracked on every 2nd or 3rd frame, which roughly halves or thirds the time.
- Tracking saves checkpoints as it goes. On iPhone and iPad it slows itself down when the device gets hot and pauses and resumes on its own if it gets very hot; switching to another app first finishes saving.

## Keypoint accuracy {#accuracy}

<figure>

![Detection rate and keypoint accuracy of the four pose models](/img/perf/accuracy.en.png)

<figcaption>Blue: share of labelled mice the model found. Orange: share of keypoints placed within a tenth of the mouse’s nose-to-tail-base length of the reference (PCK@0.1 L). For MousePose6DyadBW the orange value is the mean of the dark and the white mouse.</figcaption>
</figure>

| Model | Test images | Mice detected | PCK@0.1 L | Details |
|---|---|---|---|---|
| **MousePose6** · one dark mouse | 1,350 mice from four public datasets | 94.6 % | 96.1 % (median error 1.2 px) | [Tutorial 1](../tutorials/mousepose6.md) |
| **WhiteMousePose6** · one white mouse | 740 mice from held-out videos of nine laboratories | 99.3 % | 95.8 % | [Tutorial 5](../tutorials/white-mouse.md) |
| **MousePose6Dyad** · two dark mice | 2,280 mice from held-out two-mouse videos | 99.5 % | 94.7 % | [Blog](../blog/training-on-existing-tracks.md#dyad) |
| **MousePose6DyadBW** · one dark, one white | Held-out dark–white videos, 2,079 mice of each coat | 98.7 % (both coats) | 94.6 % dark · 93.3 % white | [Tutorial 6](../tutorials/dyad-bw.md) |

Test images come from videos that were not used for training. All four models share the same six keypoints (nose, both ears, neck, body centre, tail base), so every task works with whichever model the coat colour calls for; see [Models](../models.md#coat).

## Two mice, two identities {#identity}

<figure>

![Share of frames with the correct identity in five simulated scenarios](/img/perf/identity.en.png)

<figcaption>Simulated 10-minute recordings, 8 per scenario. Blue: identities assigned automatically. Violet: after checking the moments the app flags and swapping A and B where needed.</figcaption>
</figure>

RodentFlow reads the whole recording before assigning identities: it finds the stretches where identity is certain, links them by motion and body axis, and learns from that video whether the two mice differ in coat, a mark or body length. When they do, about **98 % of frames** are right without any correction. When two mice look alike, the app points to the moments worth checking; a few taps bring look-alike pairs to **97–98 %**. For the most reliable identity, use mice that differ in coat colour or give one of them a mark (see [Dyadic social interaction](../tasks/dyadic-social.md#setup)).

## From keypoints to measures {#measures}

Each task turns keypoints into measures with stated rules: which keypoint, which distance, which angle and for how long. The [task pages](../tasks/) give every rule with a simulated example, and [How tracking works](./tracking.md) explains the steps from video to clean tracks. As with any automated scoring, compare a few of your own videos with hand scoring before a large study, and use the same settings for the whole study.
