---
title: "iPhone, iPad and Mac"
description: "What RodentFlow does on iPhone, iPad and Mac, what each needs, and how to get it."
---

# iPhone, iPad and Mac

RodentFlow is one app for iPhone, iPad and Mac. All three run the same analysis code: the same video, calibration and settings give the same numbers on every device. They differ in how you organise the work.

|  | iPhone and iPad | Mac |
|---|---|---|
| **Good for** | Analysing a video at the bench, checking a recording right after the test, teaching | Whole studies: many animals, groups, repeated sessions, long recordings |
| **Methods** | Pose (one and two animals), classic centroid, multi-chamber tail suspension, manual entry and table import | Pose (one and two animals), classic centroid, multi-chamber tail suspension |
| **Organisation** | Each analysis carries animal ID, group, sex, phase, day and trial | Project → task → group → animal → session |
| **Groups and statistics** | Built in (Groups tab) | Built in (Compare groups) |
| **Exports** | Measures, frame-by-frame data, DeepLabCut-format keypoints, behaviour segments, figures, statistics, Methods text | The same, for a whole task at once, plus annotated MP4 and quality-control files |
| **Requires** | iOS / iPadOS 17 or later | macOS 14 Sonoma or later; Apple silicon runs the models fastest |

You can use both: analyses finished on the iPhone or iPad can be written to a folder you choose (for example in iCloud Drive) and imported by the Mac automatically, with a check that the Mac reproduces the phone’s numbers. See [Phone to Mac sync](../reference/sync.md).

## Getting RodentFlow {#get-app}

RodentFlow is on the [App Store](https://apps.apple.com/app/id6818278240). Please do not trust download links from other sites. You do not need Python, a GitHub account or an internet connection to analyse a video: the models are built into the app.

## Check your device {#check-device}

- [Find out which macOS your Mac is using](https://support.apple.com/109033) and whether it has [Apple silicon](https://support.apple.com/116943).
- [Find the software version on your iPhone or iPad](https://support.apple.com/109065).

## Language {#language}

The app is in English and Simplified Chinese and follows the device language; on iPhone and iPad you can choose RodentFlow’s language in the Settings app. Data and exports are always saved in English, whatever the interface language.
