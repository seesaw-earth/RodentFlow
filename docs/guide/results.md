---
title: "Results and exports"
description: "The RodentFlow 2.1 results page and everything you can export from a session: measures, frame-by-frame data, DeepLabCut-format keypoints, behaviour segments, figures and Methods text."
---

# Results and exports

## The results page {#page}

Each session has one results page, the same on iPhone, iPad and Mac.

- **Measures.** Every measure of the task with its value and its definition, as on the [task pages](../tasks/). Change a zone, threshold or the analysis window and the values update without tracking again.
- **Figures.** The track, start and end points, and a heat map (three-chamber also shows one for the nose). The heat map can be laid over the original video frame or shown beside it. Any part of a figure can be switched off (cups, objects, maze arms, zone names, the track, the legend, the scale bar …); the choice is remembered per task, so every animal’s figure looks the same, including in exports.
- **Time course.** The main measures per time bin, saved with the session so that the Groups page can draw time courses.
- **Methods.** A paragraph describing the model, the settings and the definitions used, ready to adapt for a manuscript.
- **Notes and review status.** Notes, the review verdict and, if excluded, the reason.

## Exports {#exports}

Exported files always have English column names, whatever the interface language. On iPhone and iPad tap **Export data** and tick what you need; on the Mac use a session’s *Review & export* step, or export a whole task at once.

| Export | What it contains |
|---|---|
| **Measures** | One row per session with every measure, the animal fields, the settings and the model. |
| **Frame-by-frame CSV** | Per frame: keypoints in centimetres, speed, head direction, body heading, zones and behaviour flags (for example `on_platform`, freezing), quality flags such as `outside_arena` and `outside_arena_dist_cm`, and `recording_start`, the recording time stored in the video file, for lining data up with other devices. |
| **DeepLabCut-format keypoints** | The DeepLabCut CSV layout (`scorer`, `individuals` for two mice, `bodyparts`, `coords`), ready for tools such as Keypoint-MoSeq. A raw keypoint CSV in the earlier layout is still offered. |
| **Behaviour segments** | One row per bout: animal, behaviour key, start, end and duration in video seconds and frames, time from the analysis start, phase, day, trial, group and sex. Includes automatic behaviours, review flags (`category = qc`), stimulus periods such as CS or looming (`category = epoch`) and your manual marks (`source = manual`). Comes with a BORIS-style START/STOP event table, a metadata file with definitions and totals, and, when you marked behaviours by hand, an agreement table. |
| **Report** | The full session as JSON: settings, calibration, measures, events. |
| **Figures** | Vector PDF and PNG at 300 or 600 dpi (Mac also SVG), at journal column widths of 85, 114 or 174 mm or a custom size. |
| **Mac only** | An annotated MP4 with the keypoints drawn on the video, and quality-control images and tables. |

For whole-group exports (Prism tables, long-format tables for R and Python, statistics report), see [Comparing groups](./groups.md#export).
