---
title: "Getting results you can trust"
description: "Good practice for behavioural studies with RodentFlow: check against hand scoring once, fix the settings, review sessions, count animals, report the method, and interpret measures as what they are."
---

# Getting results you can trust

RodentFlow measures behaviour with stated rules from keypoints or motion. The rules are the same for every animal and every lab, which is what makes automated scoring repeatable. These habits make the results hold up.

1. **Check once against hand scoring, before the study.** Score a few videos of each test by hand, blinded to group, in your own setup, and compare them with RodentFlow. Adjust a threshold if needed, then keep it. [BORIS](https://www.boris.unito.it/) is a free tool for hand scoring; RodentFlow’s own manual scoring in the review reports precision, recall and F1 directly. For tail suspension, *Calibrate against manual scores…* finds the threshold for you.
2. **Fix the settings.** Use the same calibration logic, analysis window, model and thresholds for every animal of a study. They are saved with every session and written into the exports.
3. **Review every session.** Play through the review, look at the flagged moments, and decide exclusion criteria in advance (for example: fell off the maze, left the arena). Excluded sessions keep their reason in the exports.
4. **Count animals, not sessions.** n is the number of animals ([Lazic et al. 2018](https://doi.org/10.1371/journal.pbio.2005282)). RodentFlow averages within the animal first and never pools phases unless asked.
5. **Report what you did.** App version, task, model or tracker, calibration, analysis window, thresholds and exclusions. The Methods text of each session and the `methods.txt` of each group export give you a starting paragraph. Follow the [ARRIVE 2.0 guidelines](https://arriveguidelines.org/).
6. **Interpret measures as what they are.** “Nose near the object and pointing at it” stands for investigation; “low motion” stands for freezing or immobility; immobility in tail suspension is a coping strategy. Pair anxiety-, memory- and coping-type measures with a locomotor control such as distance in the open field.
7. **Keep the raw data.** Keep the original videos and the frame-by-frame export with the results, so that any measure can be recomputed or checked later.

RodentFlow is a research tool for laboratory animal studies. It is not a medical or veterinary device.
