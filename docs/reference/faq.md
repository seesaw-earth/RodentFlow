# FAQ & troubleshooting

## Tracking

### The dot jumps to a shadow, a reflection or the wall

The tracker follows whatever differs most from the empty arena and looks like a body. Things to try, in this order:

1. **Calibration.** Put the handles on the *inner floor* boundary, not on the top of the walls. Everything outside the calibrated area is ignored, so a tight calibration excludes wall reflections.
2. **Light.** Moving shadows (the experimenter, a door) and glare on acrylic or water are the usual culprits. Use diffuse light and keep people out of the camera's view.
3. **Preview window.** Check the preview at a moment where the problem happens (move **Start** there) to see whether it is occasional or constant.

If the problem occurs only at the start or end of the video, for example when the animal is put in, skip that time with **Start after** or **Length** in the analysis window.

### "Mouse detected in only …% of samples"

Some samples found no candidate that looked like the animal. Common reasons:

- **Low contrast**: a gray animal on a gray floor, or an animal in a dark corner. Improve the contrast when recording.
- **Hidden periods**: under a lid, inside a shelter, in the covered dark box. Expected in some assays.
- **Long resting at one spot** in a short video, combined with poor contrast. See the next question.

Undetected samples are left out of zone times and distance, so a result with 85 % tracking is often still usable. Open the result, look at the path, and decide by your own criteria whether to exclude it.

### The dot sits on an empty spot while the animal is elsewhere

That is a "ghost": the animal rested at that spot in more than half of the background frames and became part of the background. The tracker repairs this automatically in most cases ([how](../principles/tracking.md#resting-animal-repair)). If it still happens, the repair could not find frames where the spot was empty. This occurs when the animal sat there in almost the whole video. Analyzing a longer recording, or one that includes more movement, gives the background better frames.

### Total distance looks too high

Distance adds up small steps, so tracking jitter adds a little to the true path: +1–2 % in an arena that fills the frame. When the arena is small in the picture (few pixels per cm), posture changes during sniffing add more. On a plus maze filling half the frame width we measured +35 %. Frame the arena tightly. Times and entries are much less sensitive than distance.

### Can I track rats?

Yes. The tracker does not assume a mouse, and the size it prefers (about 1.2 % of the arena) is a broad preference, not a limit. Two settings are tuned for mice and should be enlarged for rats: the **interaction radius** in object recognition and the **hole zone radius** in the Barnes maze. Also review the moving threshold in the open field.

### Can I analyze several animals in one video?

Not in the same arena. If several separate arenas are visible, analyze the video once per arena, each time calibrating a different arena. Each analysis looks only inside its calibration.

## Assay-specific

### Freezing is clearly too high or too low

The threshold depends on the camera, the light and the bedding. Open a result, change **Freezing threshold** in Analysis settings and watch the freezing bouts in the trace update. Compare with your hand scoring of a few videos and use the best-matching threshold for all animals. Also check for:

- a light cue switched on at CS onset, which shows a spike of "motion" in the trace;
- automatic exposure on the camera (lock it when recording);
- the protocol start and CS onsets, which must be in seconds from the protocol start.

### Object recognition: total exploration is low

Check that markers **A** and **B** are on the object centers. Drag them on the result screen; the numbers update immediately. Then check the **interaction radius**: the body center is about 4–5 cm behind the nose, so the radius should be about the object radius plus 5 cm (default 8 cm).

### Water maze: latency equals the trial maximum although the mouse found the platform

- Is **P** on the platform center? Drag it on the result screen.
- Is the **platform zone radius** large enough for the platform (default 6 cm)?
- Does **Must stay on platform** (default 1 s) fit your protocol?
- Is **Trial start in video** set to the moment the mouse is released?

### Barnes maze: the target hole is never visited

Check that **T** is on the target hole and that **Holes** matches your maze. The hole zone (default 8 cm) must reach the body center during a poke, because the head is inside the hole.

### Y-maze: alternation cannot be computed

At least three arm entries are needed. If the animal clearly visited the arms, check the J/A/B/C handles in the preview, where the zone label should change as the animal enters each arm, and the arm width.

## The app

### The analysis paused when I switched apps

That is by design. iOS does not allow long video processing in the background, so the app saves a checkpoint and pauses. Return to the app and tap **Resume Analysis**. If iOS closed the app in the meantime, the start screen offers to resume.

### I cannot choose a new video

A full analysis is running. Pause it with **Pause & Save**, or wait until it finishes. Only one video is open at a time.

### Choosing a video from Photos takes long

If the video is stored in iCloud, it is downloaded first. Large videos from Files are copied into the app in the background; the screen stays responsive meanwhile.

## Groups and statistics

### A group appears twice, or animals are missing

Group names must be spelled identically: `WT`, `wt` and `WT ` are three groups. Correct the **Group** field in each result's Details. Also check the **phase filter** and whether animals were marked **excluded**.

### n is smaller than the number of results

Several results of one animal (same subject ID and group) are averaged into one value, so n counts animals. Filter by phase or day to analyze one session.

### "No test result"

Each group needs at least two animals with values that differ. Identical values give no variability to test.

## Import

### My columns were not recognized

Rename them to the metric names shown in the app, e.g. `Center time (%)`, or download the **CSV Template** for the assay from the import sheet. Excel and Numbers files must be saved as CSV first. Columns that are numeric but unrecognized are still imported as custom metrics.

## Display and language

### How do I switch between English and Chinese?

Tap **Aa › Language / 语言**. It opens RodentFlow's page in the iPhone Settings, where you choose the language for this app alone. iOS restarts the app after the change, and a running analysis is paused and saved first. Data and files are the same in both languages.

### The text is too small or too large

**Aa** offers five sizes from Small to Largest, or "Same as iPhone".

---

Still stuck? See [Support](../support.md).
