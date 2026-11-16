---
title: "RodentFlow for Windows"
description: "RodentFlow on a Windows PC: install it from the Microsoft Store, what it needs, what it does, how it differs from the Mac and where it keeps your data."
---

# RodentFlow for Windows

RodentFlow for Windows brings pose tracking and behaviour analysis to Windows PCs. It is built for whole studies, like the Mac app: tasks, groups, animals and sessions, a queue of videos, review, results and group statistics. Start with the [Quick start on Windows](./quick-start.md).

<div class="rf-cards">
  <a href="https://apps.microsoft.com/detail/9n4hx4cvmzf8"><strong>Microsoft Store</strong><span>Get RodentFlow for Windows.</span></a>
  <a href="./quick-start.html"><strong>Quick start</strong><span>From a new task to exported results.</span></a>
  <a href="https://github.com/seesaw-earth/RodentFlow-Windows"><strong>Source code</strong><span>The Windows app on GitHub, AGPL-3.0.</span></a>
</div>

## Install {#install}

1. Open the [RodentFlow page in the Microsoft Store](https://apps.microsoft.com/detail/9n4hx4cvmzf8) and choose **Get** (or **Install**). The app is free.
2. Open **RodentFlow** from the Start menu.

That is all: the pose models and the video reader (FFmpeg) are inside the app. You do not need Python, a GitHub account, a separate download or an internet connection to analyse a video. The Microsoft Store keeps the app up to date. Please do not trust download links from other sites.

## What it needs {#requirements}

| Item | Requirement |
|---|---|
| **System** | Windows 10 version 1809 or later, or Windows 11; 64-bit (x64) |
| **Graphics** | Any graphics card with DirectX 12 is used when it is faster; without one, the processor runs the models |
| **Videos** | Common video files such as MP4 and MOV; each frame's own timestamp is read, so variable frame rates are handled |
| **Languages** | English and Simplified Chinese. Data and exports are always saved in English |

To check your version of Windows, see Microsoft's [Which version of Windows operating system am I running?](https://support.microsoft.com/en-us/windows/which-version-of-windows-operating-system-am-i-running-628bec99-476a-2c13-5296-9dd081cdd808)

## What it does {#features}

- **Workspace** as on the Mac: task → group → animal → session. Add many videos at once, fill in each session's details, and analyse every ready session in a queue.
- **Calibration for every pose task** (27 tasks): drag the arena (rectangle, circle, plus, Y or T maze) and the task's markers (cups, objects, platform, target hole, shelter, food, marble grid …) onto a video frame. The zones are drawn as the analysis counts them, with the task's settings beside them.
- **Results** with the same cards, figures and Methods text as the Mac app. Every figure exports as PNG (300 or 600 dpi), vector PDF, SVG or CSV.
- **Review**: the skeleton on the video, a timeline of moments to check, swapping the identities of two mice from one frame or over a range, and confirming the first bite in novelty-suppressed feeding. A review video with the keypoints drawn on it can be written for any session.
- **Paired phases** (social interaction ratio, place-preference score, step-down ratio) and **marble burying**, with each marble read from the video.
- **Group comparison** with the same statistics, publication figures and per-animal CSV tables as the other apps.
- **Graphics card or processor.** For each model, RodentFlow times both once and keeps the faster; you can also choose one yourself.

## How it relates to the Mac {#mac}

The Windows app is compiled from the **same analysis code** as the iPhone, iPad and Mac apps: keypoint decoding, identity tracking, zones, the rules of every task, the statistics and the figures. What differs is the layer underneath:

| | Mac, iPhone and iPad | Windows |
|---|---|---|
| Reading video | AVFoundation | FFmpeg, with each frame's own timestamp |
| Running the models | Core ML packages (8-bit weights) | 32-bit ONNX exports of the same model checkpoints, with ONNX Runtime and DirectML |
| Interface | SwiftUI | WinUI 3 |

Because the model files and the video reader differ, keypoints can differ slightly between a Mac and a PC for the same video. **Results from the Windows app have not yet been compared with the Mac app on the same videos.** Until that comparison is published here, check the first sessions of a study in **Review** before relying on the numbers, as you would on any new setup.

Not available on Windows yet: classic centroid tracking, multi-chamber tail suspension, manual entry and table import, and phone sync. For these, use the [iPhone, iPad or Mac](../guide/editions.md).

## Where your data lives {#data}

- **Your videos** stay where they are and are only read. If you move one, use **Locate the video…** on its session.
- **The workspace** (tasks, sessions, the details you entered, calibrations) and the settings are in your Windows user profile, in `%LOCALAPPDATA%\RodentFlow` (for the Microsoft Store version, Windows may keep them in the app's own folder under `%LOCALAPPDATA%\Packages`).
- **Tracking runs and results** go to `Documents\RodentFlow`, one folder per task and session. **Open the result folder** shows a session's folder in File Explorer.
- Removing a session or a task in the app does not delete videos or result folders.

Back up `Documents\RodentFlow` and your export folders, for example with Windows Backup or OneDrive. See also the [Privacy policy](../privacy.md).

## Source code {#source}

RodentFlow for Windows is open source under the GNU Affero General Public License v3.0: [seesaw-earth/RodentFlow-Windows](https://github.com/seesaw-earth/RodentFlow-Windows). Problems and questions about the Windows app go to its [issue tracker](https://github.com/seesaw-earth/RodentFlow-Windows/issues); see [Support](../support.md).
