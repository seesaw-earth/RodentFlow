# Mac: the full workflow

## The window {#mac-window}

One window, three columns:

- **Sidebar** (left) with three sections:
  - **Tasks** — each task; expand it to see its groups. Numbers show how many sessions each holds.
  - **Smart lists** — sessions from every task that need attention: *All sessions*, *To analyse*, *To review*, *Missing info* (no animal ID, date or session number), *Excluded*, and *Not in a task* (old imports, only shown when present).
  - **Tools** — advanced utilities (see [Smart lists & Tools](#mac-tools)).
- **Middle list** — the animals and sessions of the selected task or group (sectioned by group), or the sessions of a smart list. Search by animal, group or date at the top. Click empty space to return to the task/group overview.
- **Detail** (right) — a task or group overview, an animal page, or a session’s four steps.

<kbd>⌘</kbd><kbd>1</kbd> Tasks · <kbd>⌘</kbd><kbd>2</kbd> All sessions · <kbd>⌘</kbd><kbd>3</kbd> Tools. Hide the sidebar with the toolbar button. Make text bigger or smaller with <kbd>⌘</kbd><kbd>+</kbd> / <kbd>⌘</kbd><kbd>−</kbd> (or Settings › Text size: Compact, Standard, Large, Extra large).

## Create and manage tasks {#mac-task}

**New task…** opens “What are you measuring?”. Tasks are grouped into families; each row shows how it is measured:

| Family | Method | Tasks |
|---|---|---|
| **Pose · one animal** | Core ML pose model (MousePose6, or WhiteMousePose6 for a white mouse), 6 keypoints (nose, both ears, neck, body centre, tail base), every frame | 24 tasks from anxiety to memory and navigation — see [Tasks](/tasks/) |
| **Pose · two animals** | Core ML two-mouse model (MousePose6Dyad, or MousePose6DyadBW for one dark and one white mouse), identity A / B over the whole video | Dyadic social interaction, resident–intruder |
| **Classic centroid** | Centroid tracking at 10 Hz (background subtraction, no neural network) | 10 video tests — see [Classic centroid](/guide/video-analysis#classic) |
| **TST · Multi-Chamber** | Chamber detection, key frame, per-chamber motion | Several mice in one recording — see [Tail suspension, multi-chamber](/tasks/tail-suspension) |

::: info

**Same test with two methods?** Open field, EPM, light–dark box, NOR, Y-maze, T-maze, water maze, Barnes maze, fear conditioning and place preference can be analysed with pose or with classic centroid. Choose **pose** for head direction, nose-based object or social investigation, head dips, stretch-attend posture and the full set of measures; choose **classic centroid** to continue a study begun with RodentFlow 1.x. Use one method consistently within a study, because the two measure from different points of the body.

:::

**Task notes:** right-click a task → *Add / edit note…* (e.g. “Cohort 3, 10 mg/kg”). The note is shown under the task name and exported.

**Same-name tasks:** tasks with the same name, the same assay and the same note (including both empty) are merged automatically, so re-creating “Open Field” does not split your data. Need two separate tasks with the same name? Right-click → *Create task with another note…*. A merge that would create conflicting session numbers or contradictory group/sex is never done automatically, and the workspace is backed up first.

**Delete a task:** right-click → *Delete task…*. This removes the task and its session records from the project (pause any running analysis first). Your video files and saved tracking folders are kept, but the deletion cannot be undone in the app.

## Add videos {#mac-import}

Select a task (or a group or animal inside it — the group/animal is then pre-filled) and click **+ Add videos…** (<kbd>⌘</kbd><kbd>O</kbd>), or drag video files onto the sidebar or middle list. The import sheet shows one row per video:

| Column        | What to enter                                                                                                                                            |
|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| Animal ID \*  | Unique within the task, e.g. `M01`. Pre-filled from the file name.                                                                                       |
| Group         | Optional (WT, KO, Vehicle…). For an animal that already has sessions, its group is kept.                                                                 |
| Sex           | Optional; belongs to the animal.                                                                        |
| Date \*       | Recording date. Pre-filled from the file name, otherwise the file’s creation date (check it!). *Use the first date for all* copies the first row’s date. |
| Session \# \* | The animal’s n-th session in this task. Filled automatically with the next free number.                                                                  |
| Phase         | For tasks with fixed phases (e.g. NOR Training / Test).                                                                                                  |

Rows with problems turn red (missing ID, session number already used, the same animal + session twice) and **Import** stays disabled until they are fixed. Duplicates are refused on purpose: they would silently corrupt statistics.

## Step ① Session info {#mac-info}

- **Animal, group, sex** — group and sex apply to all sessions of the animal in this task; typing an existing animal ID moves the session to that animal.
- **Recording date, session number** — required.
- **Phase / Day / Trial** — shown when the assay uses them (e.g. Barnes maze acquisition days and trials). Phases are never pooled in summaries.
- **Notes** — dose, treatment, anything unusual (use the task note for information about a whole batch).
- **Exclude from group summaries** — with a reason (exported). The session keeps its own results but leaves animal means, group statistics and comparisons. Decide exclusion rules *before* looking at results.

Sessions without animal ID, date or session number show an orange mark and appear in *Missing info*; they cannot be analysed until completed.

## Step ② Calibrate {#mac-calibrate}

Calibration tells the app where the arena is, how big it is in centimetres, where objects or zones are, and which part of the video to score.

1.  **Pick a calibration frame** with the time slider (a frame where the arena edges are clearly visible and not hidden by a hand).
2.  **Choose the arena type** if the assay offers several (rectangle, circle, plus/Y/T maze, or “No calibration (pixels)” for pose-only work).
3.  **Drag the handles.** A 3× magnifier appears while dragging. For precision, click a handle and use the **arrow keys** (hold <kbd>⇧</kbd> for bigger steps).
4.  **Enter the real dimensions** (inner width/height, diameter, arm length/width). The panel shows the resulting scale (≈ pixels/cm) — a quick sanity check.
5.  **Set assay parameters** (zone sizes, which object is novel, CS onset times…) and the **analysis window** (start and duration; 0 = to the end).
6.  **Save for this video** (<kbd>⌘</kbd><kbd>S</kbd>); later changes save automatically. **Use for all videos of this task…** copies it to every video — only if the camera did not move.

### Handle colours and labels

| Arena / marker           | Handles                  | Where to put them                                                                                                                                                  |
|--------------------------|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Rectangle                | Yellow `1–4`             | Inner floor corners: top-left, top-right, bottom-right, bottom-left. Coordinates are perspective-corrected.                                                        |
| Circle                   | `C`, `R`                 | C at the centre (drag to move the circle), R on the inner wall.                                                                                                    |
| Plus maze                | `C N E S W`              | C at the centre, N/E/S/W at the arm tips (N = top of image). Choose the open-arm axis in the parameters; cyan marks open arms.                                     |
| Y-maze                   | `J A B C`                | J at the junction, A/B/C at the three arm tips.                                                                                                                    |
| T-maze                   | `J S L R`                | J at the choice point, S at the start-arm end, L/R at the left/right arm ends.                                                                                     |
| Three-chamber            | Purple `L R`, cyan `L R` | Purple = the two centre-chamber dividers (move independently); cyan = the centres of the two wire cups.                                                            |
| Objects (NOR)            | `A B`                    | Centres of the two objects; set the object radius and which is novel.                                                                                              |
| Barnes maze              | `T`                      | The target (escape) hole; other holes are spaced evenly from the hole count.                                                                                       |
| Water maze (RodentFlow)  | `P`                      | The platform centre.                                                                                                                                               |
| Looming / Head direction | `S` / `Q`                | S on the shelter centre; Q on a wall cue card (optional 0° reference).                                                                                             |

::: info

**Calibrate before tracking.** Pose tasks track only the calibrated arena plus a margin (*Track the arena only*, on by default), and classic centroid maps the mouse into the calibrated arena. Zones and handles can be adjusted afterwards and the results update without tracking again; if the calibration is moved outside the tracked region, the app asks you to track again.

:::

## Step ③ Analyse {#mac-analyse}

- **Analyse this video** (<kbd>⌘</kbd><kbd>R</kbd>). If another video is running, the button reads *Add to queue*. Videos run one after another.
- The page shows progress, video time, an **estimated remaining time** and a live tracking preview (about once per second).
- **Pause** keeps finished parts; **Resume** continues where it stopped — even after quitting the app. Long videos are processed in segments on disk, so memory use stays bounded.
- On the same page, the *All animals of this task* card → **Analyse remaining videos (n)** queues everything that is ready; *Pause all* stops the queue. Videos still missing info or calibration (RodentFlow) are listed and skipped.
- **Analyse again…** keeps the previous run on disk; review then uses the new run (re-check tracking afterwards).

## Step ④ Review & export {#mac-review}

### Results tab

The assay’s original measures and figures for this session, with the primary measure highlighted, the analysis window in use, and the phase. Change the window, zones or parameters in *Calibrate* — results recompute without re-tracking. **Export results and figures…** writes this session’s metrics, methods and (optionally) the PNG figures into a new folder.

### Frame review & export: the tracking check

You do not need to watch the whole video. A short, systematic check catches most problems:

1.  Choose a **check range** (default frames 0–99) or a preset: *Start, Middle, End, Random*.
2.  Press **Play** (<kbd>⌥</kbd><kbd>P</kbd>) at *Every frame*, 0.25×, 0.5×, 1× or 2×, or step with <kbd>⌥</kbd><kbd>←</kbd> / <kbd>⌥</kbd><kbd>→</kbd>. The orange line shows the preceding 2 s of movement.
3.  Press <kbd>⌥</kbd><kbd>F</kbd> (*Wrong tracking here*) on frames where points are clearly wrong.
4.  Record the **Result** (*Not checked*, *Tracking OK* or *Tracking problems*) and notes. They are saved with the session and exported.
5.  Click **Next session to check →** (or *Next session →* at the top right).

A problem verdict does *not* exclude a session automatically — you decide according to your pre-specified criteria. If a decoded frame does not match the tracking timestamp, the overlay is hidden rather than shown in the wrong place.

### Tracking events, figures and raw files (pose tasks)

- **Tracking QC events** group consecutive frames with *Inference failed*, *No detection* or *Low confidence*. These are quality flags, not behaviours; a clean video can legitimately have none. Click an event to jump to it; mark it *Accepted* or *Flagged*.
- Pick a **figure frame range** (inclusive, zero-based) and tick what to export: raw keypoints CSV, QC-screened CSV, frame/segment QC CSV, provenance JSON, trajectory and confidence PNGs and an annotated screenshot. **Export selected files and figures…** (<kbd>⌘</kbd><kbd>E</kbd>). Figures are drawn from saved tracking; models are never re-run here.
- **Annotated MP4** is optional: the app benchmarks and estimates the time before you confirm. Models are not re-run.
- RodentFlow sessions export their 10 Hz centroid samples (CSV) and the tracking check (JSON) from the same tab.

## Task, group and animal pages {#mac-overviews}

- **Task page:** a table of every session (animal, group, date, session, phase, analysis status, primary measure, tracking check, included). Double-click to open; select several and right-click to exclude/include with one reason. Tabs: *Sessions*, *Compare groups*, *Export*.
- **Group page:** its animals, a descriptive summary per phase (mean of each animal, n = animals), group-level export, and *Rename group* (applies to all animals of that group in the task).
- **Animal page:** its sessions, one measure across session numbers (excluded sessions in grey), and rename / change group / sex. Renaming to an existing ID merges the animals only if their session numbers do not clash.

When you open these pages, any missing or outdated session results are computed in the background (progress at the top, with *Stop*). Results are cached next to each run and recomputed automatically if anything they depend on changes.

## Smart lists & Tools {#mac-tools}

**All sessions** (<kbd>⌘</kbd><kbd>2</kbd>) is a single table of every session in the project with its calibration, analysis and tracking-check status — handy for a final completeness check. Right-click to open a session in its task or remove it from the project (the file itself is never deleted).

**Tools** (<kbd>⌘</kbd><kbd>3</kbd>) are for checks and troubleshooting, not for experiments: *Models* (what is bundled), *Manual tracking*, *Long-video tracking* into a folder you choose, *Review manual results*, *Cover part of a video*, *Locate video*, *Task catalog*, and the *Legacy project inspector* (reads old `.rodentproj` files without changing them). Results made in Tools are not linked to a task or animal.

