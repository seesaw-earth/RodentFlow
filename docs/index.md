---
layout: home
title: RodentFlow
titleTemplate: User manual

hero:
  name: RodentFlow
  text: Rodent behavior, tracked and analyzed on iPhone
  tagline: Track top-down videos, score assays by hand or import tables, and compare groups with the right statistics. Everything runs on the phone, and nothing is uploaded.
  image:
    src: /hero.png
    alt: RodentFlow app icon
  actions:
    - theme: brand
      text: Get started
      link: /guide/getting-started
    - theme: alt
      text: How tracking works
      link: /principles/tracking
    - theme: alt
      text: 中文版
      link: /zh/

features:
  - title: Video tracking on the phone
    details: Ten assays can be scored straight from a top-down video, from the open field to fear conditioning. The tracker reads the whole recording at 10 samples per second, on the device.
    link: /guide/video-analysis
    linkText: Analyze a video
  - title: Calibrated arenas and mazes
    details: Drag a few handles onto the arena corners or the maze arms. Positions are converted to centimeters, and zones, arms and quadrants follow from the calibration.
    link: /principles/metrics
    linkText: From positions to metrics
  - title: One result per animal
    details: Every video, manual entry or imported row becomes a result for one animal and one session. Zones and thresholds can be changed afterwards without tracking the video again.
    link: /guide/results
    linkText: Results
  - title: Manual entry and table import
    details: Fifteen assays, including marble burying, sucrose preference, beam walking, gait and a two-armed bandit. CSV, TSV and JSON files are accepted, with English or Chinese column names.
    link: /guide/manual-and-import
    linkText: Enter or import data
  - title: Group statistics that fit the design
    details: The animal is the unit of analysis. The test follows from the design, from Welch's t to mixed ANOVA with Greenhouse–Geisser correction, and each test was checked against SciPy.
    link: /principles/statistics
    linkText: Statistics
  - title: Private by design
    details: No account, no analytics and no network connection. Videos, results and figures stay on the iPhone and in the Files app until you share them.
    link: /privacy
    linkText: Privacy policy
---

<div class="rf-home">

<p class="rf-lang">Language: <a href="./index.html">English</a> · <a href="./zh/index.html">简体中文</a></p>

## How it works

A video becomes positions, positions become metrics for one animal, and the metrics of many animals become a group comparison. You can stop at any stage and export what you have.

<figure>

![From video to group statistics](/img/dataflow.en.png)

</figure>

## Assays

| Area | Assays | From video |
|---|---|---|
| Anxiety & affect | Open field / center, elevated plus maze, light–dark box, marble burying, sucrose preference | Open field, EPM, light–dark box |
| Learning & memory | Y-maze, T-maze, novel object recognition, Morris water maze, Barnes maze, fear conditioning | All six |
| Motor function | Beam walking, gait analysis | — (entered or imported) |
| Reward & decision | Conditioned place preference, two-armed bandit | CPP |
| Other | Any table of per-animal values | — (imported) |

## Where to start

<div class="rf-cards">
  <a href="./guide/getting-started.html"><strong>Quick start</strong><span>Score your first open-field video in about five minutes.</span></a>
  <a href="./guide/recording.html"><strong>Recording tips</strong><span>Camera position, lighting and contrast that make tracking reliable.</span></a>
  <a href="./assays/index.html"><strong>Assay reference</strong><span>Every assay, what to set, and how each metric is defined.</span></a>
  <a href="./principles/validation.html"><strong>Validation</strong><span>How close the app gets to known ground truth, and where it does not.</span></a>
</div>

</div>
