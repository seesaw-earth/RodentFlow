# iPhone & iPad: pose tracking

::: info
Written for RodentFlow for Mac 0.7.1 and RodentFlow for iPhone & iPad 1.0 (the pose edition, formerly RodentStudio).
:::

RodentFlow Mobile runs the same 6-keypoint RodentPose model and the 16 RodentPose assays on the device. The app has three tabs: **Home**, **Assay Library** and **Data**; settings are behind the gear icon on Home.

## Your first analysis

1.  **Home → New analysis.** Choose an assay (or tap one of the *Featured assays*; the *Assay Library* explains each assay, the keypoints it uses, its measures and references).
2.  **Import video:** *Choose video from Photos* or *Choose video from Files*. A copy is stored in the session folder for later review. While the model is still loading you can already import and calibrate.
3.  **Info:** enter the *Subject ID* (it names exported files and summary rows — set it before detection), group (previous groups appear as one-tap suggestions), sex, *Phase / condition* (tap + to add your own labels such as “Day 1” or “Baseline”; long-press to remove), day, trial and notes.
4.  **Detection settings** (also on Info): *Frame sampling* (every frame, or every 2/3/5 frames for long videos — speed and immobility use real timestamps, but use every frame for VTE and head dips), *Convert to grayscale* (recommended), *Two-mouse mode* (Dyadic Social), and the *Detection range*. Changing these later requires re-detection.
5.  **Calibrate:** drag the handles (same labels as on Mac — see [Calibrate](/mac/workflow#mac-calibrate)). A magnifier appears in the opposite top corner while you drag. Turn on *Overlay detected trajectory* after detection to check the calibration matches where the animal actually moved. VoiceOver users can nudge handles from the actions menu.
6.  **Detect:** tap *Start detection*. Keep the app in the foreground (the screen stays awake). If you switch away, detection pauses and saves progress — tap *Resume detection* when you return.
7.  **Results:** the headline measure (with a scale where meaningful, e.g. 0 = no preference), all measures, figures, detection quality and a ready-made *Methods description* you can copy. Every figure has a ••• menu: *Copy image*, *Share image…*, *Copy data (CSV, English)*.
8.  **Next animal (same assay)** starts the next session with the same assay; reuse the setup if the camera did not move.

## Review video

Open *Review video* to see the pose overlay, zones and a 2-second trail (smoothed for display only — measures are unaffected). Jump between scored behaviours with *Previous / Next event* (the behaviour legend doubles as the filter), step frame by frame, skip ±5 s, and change speed (0.25×–2×).

## Export

| Export                      | Contents                                                                                                                      |
|-----------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| Metrics summary CSV         | All metrics for this session, one per row                                                                                     |
| Frame-by-frame analysis CSV | Smoothed coordinates (cm), speed, head direction, zones and behaviour labels                                                  |
| Raw keypoints CSV           | Pixel coordinates and confidences from the model                                                                              |
| Full report JSON            | Metrics, parameters, calibration, quality and methods                                                                         |
| Summary CSV (Data tab)      | *Export summary* for all sessions or the current filter — one row per session, for group analysis in R, Python or other tools |

Exports use the system share sheet (save to Files, AirDrop to your Mac, email…). CSVs are UTF-8 with BOM so Excel opens Chinese text correctly; column names are always English.

## Managing storage

- In **Data**, swipe left or touch and hold a session to *Delete video copy* (keeps pose data and results, but review and re-detection are no longer possible) or *Delete this session* (everything, permanently).
- Session folders are visible in the Files app under *On My iPhone / iPad › RodentFlow › Sessions*: `session.json` (settings and metrics), `pose.mpt` (per-frame keypoints) and `video.*`. See [Apple: Files on iPhone](https://support.apple.com/guide/iphone/iphc61044c11/ios).
- To move exports to a Mac, use AirDrop, the Files app, or [Finder file sharing](https://support.apple.com/119585). The Mac and mobile editions currently keep separate libraries: to bring a study together, analyse the original videos on the Mac or combine exported CSVs.
