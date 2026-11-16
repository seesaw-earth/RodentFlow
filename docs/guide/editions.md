---
title: "iPhone, iPad, Mac and Windows"
description: "What RodentFlow does on iPhone, iPad, Mac and Windows, what each needs, and how to get it."
---

# iPhone, iPad, Mac and Windows

RodentFlow is one app for iPhone, iPad and Mac, and a separate app for Windows. All of them run the same analysis code. On Apple devices the same video, calibration and settings give the same numbers on every device. The Windows app runs its models as ONNX files instead of Core ML packages, and its results have not yet been compared with the Mac's (see [RodentFlow for Windows](../windows/index.md#mac)). The devices differ in how you organise the work.

<div class="rf-editions">

|  | iPhone and iPad | Mac | Windows |
|---|---|---|---|
| **Good for** | Analysing a video at the bench, checking a recording right after the test, teaching | Whole studies: many animals, groups, repeated sessions, long recordings | Whole studies on a Windows PC |
| **Methods** | Pose (one and two animals), classic centroid, multi-chamber tail suspension, manual entry and table import | Pose (one and two animals), classic centroid, multi-chamber tail suspension | Pose (one and two animals) |
| **Organisation** | Each analysis carries animal ID, group, sex, phase, day and trial | Project → task → group → animal → session | Task → group → animal → session |
| **Groups and statistics** | Built in (Groups tab) | Built in (Compare groups) | Built in (Group comparison) |
| **Exports** | Measures, frame-by-frame data, DeepLabCut-format keypoints, behaviour segments, figures, statistics, Methods text | The same, for a whole task at once, plus annotated MP4 and quality-control files | Figures (PNG, PDF, SVG, CSV), statistics, one row per animal, Methods text, annotated MP4 |
| **Requires** | iOS / iPadOS 17 or later | macOS 14 Sonoma or later; Apple silicon runs the models fastest | Windows 10 version 1809 or later, or Windows 11, 64-bit; a DirectX 12 graphics card is used when it is faster |

</div>

On Apple devices you can use both: analyses finished on the iPhone or iPad can be written to a folder you choose (for example in iCloud Drive) and imported by the Mac automatically, with a check that the Mac reproduces the phone’s numbers. See [Phone to Mac sync](../reference/sync.md).

## Getting RodentFlow {#get-app}

RodentFlow for iPhone, iPad and Mac is on the [App Store](https://apps.apple.com/app/id6818278240). RodentFlow for Windows is in the [Microsoft Store](https://apps.microsoft.com/detail/9n4hx4cvmzf8). Please do not trust download links from other sites. You do not need Python, a GitHub account or an internet connection to analyse a video: the models are built into the apps.

## Check your device {#check-device}

- [Find out which macOS your Mac is using](https://support.apple.com/109033) and whether it has [Apple silicon](https://support.apple.com/116943).
- [Find the software version on your iPhone or iPad](https://support.apple.com/109065).
- [Find out which version of Windows your PC is running](https://support.microsoft.com/en-us/windows/which-version-of-windows-operating-system-am-i-running-628bec99-476a-2c13-5296-9dd081cdd808).

## Language {#language}

The app is in English and Simplified Chinese and follows the device language; on iPhone and iPad you can choose RodentFlow’s language in the Settings app, and on Windows in the language menu in the window. Data and exports are always saved in English, whatever the interface language.
