# Multi-chamber tail suspension (TST)

This workflow scores **several mice hanging side by side in one recording**. It finds the chambers, finds the moment every mouse is hung (the *key frame*), measures motion per chamber, and then saves each chamber as an ordinary session of one animal — so groups, comparisons and exports work exactly like any other task. (For one mouse per video with paw keypoints, clasping and tail climbing, use the RodentLimb *Tail suspension* task instead.)

## Step by step

1.  **Create the task** “TST · Multi-Chamber”, then click **Add TST recording…** (<kbd>⌘</kbd><kbd>O</kbd>) or drop the video on the sidebar. Recordings are analysed one at a time. The analysis window has a step bar — **Video › Chambers › Key frame › Results & animals** — with the picture on the left, settings on the right, and *Back* / *Cancel* (<kbd>Esc</kbd>) / next (<kbd>Return</kbd>) at the bottom.
2.  **Chambers:** chambers are detected automatically (if not, the image is split evenly into 6). Set the *Number of chambers*, drag the white handles onto the walls between chambers, and click a chamber to include or skip it. Chambers where a mouse was seen are pre-selected. Then **Find key frame →** (or *Set start by hand…* for a video already trimmed to start after all mice are hung).
3.  **Key frame:** the first moment every selected chamber has had a mouse for the set time. You can use it as soon as it is found (*Use key frame now →*), but letting the scan finish gives each chamber’s motion box the full range of movement and shows when mice are taken down. Fine-tune with ±0.25 s / ±1 s or by clicking the timeline. Drag the yellow handles so the *analysed band* covers every mouse with a little room above. Then **Analyse →**.
4.  **Results & animals:** one row per chamber with immobility and the animal fields. Enter the recording date once; fill animal ID, group, sex, session number; untick empty or unusable chambers (no session is created). Only real conflicts are marked in red. Click **Save n sessions**.
5.  The animals appear in the sidebar and the first one opens in *Review & export*: open the original recording, check that chamber, choose *Scoring looks right* / *Problems found* (saved immediately) and exclude with a reason if needed.

## How it scores

- **Each mouse is timed from its own suspension.** Standard test window: 6 min. The **primary measure (★) is immobility in minutes 2–6**; minutes 0–2, 0–6 and the whole recording are reported too, with latency to first bout, number/mean/longest bouts, immobility per minute and *mobility intensity* (mean motion while mobile — how vigorously it struggles).
- The default measure is **pixel change in a fixed motion box** around each mouse, after aligning frames to cancel passive swinging (so swinging is not counted as movement). Two outline-based measures are available for comparison.
- By default the analysis runs from the key frame to the end of the video; turn on *Stop after a set duration* for a fixed protocol length. Frames without a mouse (taken down, climbing, out of view) count as “no mouse”, not as immobility, and the immobility % uses only frames with a mouse.
- Chambers with more than 10 % “no mouse” frames are flagged for review. A warning appears if less than the full 6 min was recorded after a mouse was hung.

::: warning

**Calibrate the threshold for your rig.** Automatic TST scoring has not been validated against blinded manual scoring, and the default threshold (2 % of body) is a starting value. Hand-score 2–3 videos with different levels of immobility (for example in [BORIS](https://www.boris.unito.it/)), then in *Results & animals* use **Calibrate against manual scores…**: enter the hand-scored seconds (minutes 2–6), click *Find the best threshold*, and apply it. Use the same threshold for the whole study.

:::

## Changing settings later

Open any TST session and choose **Adjust settings and analyse again…** (also in the session’s right-click menu). The recording reopens with its chambers, start and settings. Threshold, minimum bout and windows change instantly; chambers, band or start need a new analysis. **Update sessions** updates the existing sessions in place (IDs are kept; review verdicts are cleared because the numbers changed; notes are kept), adds newly ticked chambers and removes un-ticked ones (you are told how many first).

## Interpreting TST results

Immobility is best described as a **passive coping strategy**, not as “depression-like” behaviour. Sedation or stimulation, motor ability, body weight, sex, strain and tail discomfort all influence it, so pair it with a locomotor control (e.g. open-field distance in the same mice). See [Can et al. 2012](https://doi.org/10.3791/3769) and [Commons et al. 2017](https://doi.org/10.1021/acschemneuro.7b00042).
