# V1.3 real-iPhone test checklist (Chinese)

Language (new in 1.3):
- Build and run once. On a phone set to English: everything is English as before. Aa › Language / 语言 opens RodentFlow's page in Settings; choose 简体中文 → the app restarts in Chinese.
- Go through every screen in Chinese: start screen, setup (all sections, calibration hints, analysis settings for each assay), preview, full analysis, result (metrics, Methods, parameters, sequence & labels), manual entry for each assay, import sheet, Groups tab (all designs, statistics, figure, export, text summary). Report any English text that is left (screenshot), and any text that is cut off or wraps badly.
- A result saved in English shows its metric names, phases, series and parameters in Chinese after switching (QC warnings stay in the language of the analysis).
- Export a records JSON in Chinese and import it on an English phone (and the reverse): same records, same values.
- Import `SampleData/example_open_field_chinese_headers.csv` in Chinese: 3 recognized metric columns, sex = M/F, 3 groups.
- CSV template in Chinese: English column names (same file as in English).
- Exported figure (PNG) in Chinese: Chinese title, axis and legend text render correctly.
- Switch back to English: everything English again.

---

# V1.2.1 real-iPhone test checklist

Responsiveness (new in 1.2.1) — ideally with Settings › Developer › Hang Detection on:
- Choose a large video (≥ 1 GB) from Files: the start screen stays responsive ("Reading video…") until Setup appears.
- Setup → Generate Preview → Preview: the screen appears at once; the player follows a moment later.
- During a full analysis: switch tabs, scroll, open the start screen — no stutter. At the end, the result appears without a pause.
- Type a long mouse ID / notes: characters appear without delay (setup and result screens).
- Switch to Groups repeatedly: no pause after the first time.


UI (new in 1.2):
- Aa button: every option changes the text on all screens; "Same as iPhone" follows Settings › Display › Text Size; check the setup and Groups screens at "Largest" on the smallest supported iPhone (nothing cut off, bottom bar still usable).
- Step bar: tap each available step from Start, Setup and Preview (forward and back); Setup is locked while the full analysis runs.
- "‹ Start" from Setup keeps the video; the start screen shows the Open video card; "Continue" returns to the right step; "Close Video" asks first.
- Change the calibration after a preview → orange notice and "Update Preview"; the full analysis is only offered after updating.
- After a result: "Next Animal" → choose the next video → "Use Previous Setup" appears (same assay and resolution).
- Result screen: ▲▼ move through results of the same assay (disabled with unsaved changes); "Compare in Groups" opens Groups on that assay.
- Groups: section chips scroll to each card.


0. First run the 10 synthetic test videos (`RodentFlow_TestVideos/README.md`): set up each one as described, run full analysis and compare with `expected_results.csv`. Any value outside the acceptable range is a bug — please send the video name and the result screen.


Build
1. Xcode: Product › Clean Build Folder, then build for a real iPhone (iOS 17+). Report any compiler error verbatim.

Experiment tab — video
2. Open Field: track a known video; open the result; drag the center-size slider and confirm center time changes instantly; Save; reopen the app and confirm the change persisted.
3. EPM: choose Elevated Plus Maze, calibrate C/N/E/S/W, run preview (zone label shows N/E/S/W/center), full analysis; set open arms (N–S or E–W) in Analysis settings and check open-arm % against a stopwatch on 1–2 videos.
4. Light–Dark Box: set light side and length; if the dark box is covered, confirm unseen time is counted as dark.
5. CPP: 2- and 3-chamber layouts; Pre-test and Test for the same mice; Groups › "Change between phases" gives Test − Pre-test.
6. NOR: drag A and B onto the objects during setup; after analysis drag the markers on the result plot and confirm DI updates; compare with hand scoring on 2–3 videos to choose the interaction radius.
7. MWM: drag P onto the platform; Acquisition (latency, found) and Probe (target quadrant %, crossings); enter Day/Trial; Groups › "Across days" learning curve.
8. Barnes: drag T onto the escape hole; check the hole ring overlay lines up with the holes; check primary latency / errors on 2–3 trials.
9. Fear conditioning: enter protocol (baseline, CS onsets, CS duration); check the freezing timeline; tune the threshold on 3 hand-scored clips from your own chamber.
10. Y / T maze: results match the 1.0 maze readout.
11. Pause & resume a long analysis (also after force-quit): the resumed run keeps the assay, phase and settings.
12. "Create Results" for 1.0 run folders on the home screen.

Experiment tab — manual / import
13. Manual entry for Marble Burying, Sucrose Preference (2 days), Beam Walking (3 trials), Gait (strides with sides) — preview updates while typing; decimal comma accepted.
14. Import each file in `SampleData/` with the matching assay; check the preview (recognized / ignored columns) before importing.
15. Bandit trial CSV: results show win-stay / lose-shift / α / β and the session plot.

Groups tab
16. Two groups → Welch t; three groups → ANOVA + Tukey; switch to Non-parametric → Mann–Whitney / Kruskal–Wallis + Dunn.
17. Reorder groups (first = control), toggle a group off, change colors; restart the app and confirm they are remembered.
18. Exclude a record in the Experiment tab → it disappears from the Groups analysis (note shown); "Include excluded records" brings it back.
19. Export PNG figure, statistics JSON, records JSON; copy the text summary.
20. Re-import an exported records JSON on a second device.

---

# V1.0 real-iPhone test checklist

1. Xcode: Product > Clean Build Folder.
2. Install V1.0 on the real iPhone.
3. Import a known video from Photos and one from Files.
4. Confirm video filename, creation date, resolution and source FPS appear correctly.
5. Test Open Field rectangle and circle calibration.
6. Test T-Maze J/S/L/R calibration and Y-Maze J/A/B/C calibration.
7. Generate a 10-second preview and confirm roughly 100 tracking samples are produced.
8. Confirm the tracking point follows the same selected-component centroid behavior and does not visibly lag during turns.
9. Confirm the colored preview progress bar shows percent and remaining-time estimate.
10. Run Analyze Full Video and confirm the full recording is processed at approximately 10 samples/s.
11. Confirm full-analysis progress shows percentage, samples, elapsed time and ETA.
12. For T/Y maze, confirm zone labels and arm-entry sequence are plausible.
13. Confirm there are no CSV buttons or CSV files.
14. Confirm the auto-saved run folder contains JSON files including `video_info.json`.
15. Spot-check `full_tracking.json`: timestamps, x/y cm, confidence, interpolated flag, zone and speed.
