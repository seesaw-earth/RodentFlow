# Before you record: pose, limb and Mac assays

Most “the software got it wrong” problems are really recording problems. Ten minutes setting up the camera saves hours of re-analysis.

## Camera and lighting checklist

1.  **Fix the camera.** Use a tripod or mount; do not zoom, pan or bump it during a batch. If the camera never moves, you can calibrate once and reuse it for every video.
2.  **Film from directly overhead** for open-field-type and maze assays, with the **whole arena** in view and a little margin (on the elevated plus maze, leave room so the nose stays visible during head dips).
3.  **Even, diffuse light** without hard shadows or reflections on the floor. Grayscale or infrared video works well; for pose assays the app converts to grayscale by default.
4.  **Contrast:** a dark mouse on a light floor (or the reverse) tracks best.
5.  **Frame rate:** 25–30 fps is fine for most assays. For gait, use **≥ 60 fps** from below a transparent walkway. Fast head movements (VTE, head dips) benefit from analysing every frame.
6.  **One animal per video**, except the [multi-chamber TST](/mac/tst) workflow (several mice hanging side by side). The Dyadic Social assay tracks two mice on iPhone/iPad; the Mac currently tracks a single animal for that assay.

## Assay-specific camera views

- **Tail suspension (RodentLimb, one mouse):** film the hanging mouse from the front or back so both hind paws are visible; start recording at suspension; a standard test lasts 6 min.
- **TST multi-chamber:** a fixed camera facing the front of the rig with every chamber in view; lock exposure so brightness does not flicker; use climb-stoppers for strains that climb (e.g. C57BL/6).
- **Cylinder test:** a bottom view through a transparent floor works best; a side view also works with a floor line. 5–10 min per mouse.
- **Gait:** bottom (ventral) view of a straight walkway; place a ruler in view once to calibrate centimetres.
- **Rotation:** if you film through a transparent floor, turn on “Recorded from below (mirrored image)” in the parameters.

## File format and naming

- Use ordinary **MP4 or MOV** files (H.264 or HEVC). If a file will not open, re-encode it as H.264 MP4, for example with the free [HandBrake](https://handbrake.fr/).
- **Name files as `AnimalID_YYYY-MM-DD`**, e.g. `M01_2026-10-17.mp4`. The Mac app reads the date from the file name (`2026-10-17`, `2026_10_17`, `2026.10.17` or `20261017`) and uses the rest of the name as the animal ID, so the import form fills itself in. Without a date in the name it falls back to the file’s creation date and asks you to check.
- **Keep the originals where they are.** On Mac, the app reads your videos in place and never modifies them; if you later move or rename a file, the app can no longer open it. Put videos in their final folder (and back them up) *before* importing. Multi-chamber TST recordings and iPhone/iPad imports are copied into the app instead.
- **Only use videos you are allowed to use**, and follow your institution’s data policy for unpublished recordings.
