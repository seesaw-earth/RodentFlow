---
title: "Quick start on Windows"
description: "Ten steps from a new task to exported results in RodentFlow for Windows."
---

# Quick start on Windows (10 steps)

1.  **Install and open RodentFlow** from the [Microsoft Store](https://apps.microsoft.com/detail/9n4hx4cvmzf8). To switch between English and 中文, use the language menu in the window.
2.  **Create a task:** click **New task…**, give it a name (for example “Open field, cohort 1”), choose the test and click **Create**. One task is one behavioural test of one batch of animals.
3.  **Add videos:** with the task selected, click **Add videos…** above the session list and choose the files. For each video fill in the **animal ID**, the **recording date** and the **session number** (required); group and sex are optional. *Group for all new animals* and *Use the first date for all* fill a whole column. RodentFlow reads the date from the file name when it can; a date taken from the file's creation date is marked so that you check it. Click **Add**.
4.  **Open a session** from the list. A session has four steps along the top: **Session info → Calibrate → Results → Review**.
5.  **Calibrate:** drag the handles onto the arena and onto the task's markers (cups, objects, arms, platform …). The zones are drawn as the analysis will count them. Enter the real size of the arena in centimetres, check the **Task settings** and the **Analysis window**, and under **Recognition** choose the *Coat colour*. If the camera did not move between videos, click **Use this setup for all sessions of the task…**
6.  **Analyse:** click **Analyse**. The progress, the time left and the live frame are shown; **Stop** pauses, and the next **Analyse** continues where it stopped. To run every calibrated session one after another, click **Analyse all ready** above the session list.
7.  **Read the results:** the **Results** step shows the task's measures, figures and a Methods paragraph. If you change zones, thresholds or the analysis window afterwards, click **Update results**: the saved tracking is scored again without tracking the video again.
8.  **Check the tracking:** in **Review**, play the video with the skeleton drawn on it (space bar; ← and → step one frame) and go through the moments on the timeline. For two mice, **Swap A / B from this frame** fixes an identity swap. Then set **Tracking check** to *Checked: the tracking is right* or *Checked: the tracking has problems*.
9.  **Compare groups:** click the task in the sidebar to open its page with the **Group comparison** of all its sessions. Choose the design and the measure; RodentFlow draws every animal and shows the test it used and its result, as described in [Comparing groups](../guide/groups.md).
10. **Export:** every figure has a menu to save it as PNG (300 or 600 dpi), vector PDF, SVG or CSV; the group comparison also saves a statistics table and one row per animal (CSV, for Prism or R). **Open the result folder** shows the session's files in File Explorer, and **Make a review video** writes the video with the keypoints drawn on it.

::: tip
Calibrate and check the first animal of a batch carefully, then copy its setup to the other sessions. The settings each session uses are saved with it, so results can always be traced back to them.
:::

::: info Graphics card or processor
Under **Recognition › Run the model on**, *Automatic* times the graphics card and the processor once for each model and keeps the faster. Choose *Processor (CPU)* if a graphics driver gives you trouble.
:::
