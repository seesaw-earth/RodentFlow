# Results

Every analysis ends as a **result**: one animal in one session, meaning one phase, day or trial. A result holds the animal's details, the metrics, any time series, the parameters used, quality flags and, for videos, a link to the tracking data. Results are what the Groups tab analyzes.

## Finding results

The **Results** card on the Experiment tab shows the number of saved results and the most recent ones. **All results** opens the full list:

- search by subject, group or phase;
- filter by assay with the menu at the top right;
- swipe or open a result to delete it.

Results are also stored as files in *Files › On My iPhone › RodentFlow › Results*, one folder per assay. See [Files & data](../reference/files.md).

## The result screen

Cards from top to bottom:

### Header and navigation

The title is the subject ID. **▲ ▼** step to the previous or next result of the same assay, which is handy for checking a whole batch. The share menu offers **Share result (JSON)** and, for videos, **Share tracking folder**.

Quality flags appear at the top when something deserves a look, for example:

- *Mouse detected in only 72% of samples — check the tracking preview.* This appears when fewer than 90 % of samples are detected. It is not shown for the light–dark box, fear conditioning or the Barnes maze, where the animal is expected to be hidden at times.
- *Low exploration: 6.2 s total (criterion 10 s).* (novel object recognition)
- *Platform not reached within 60 s (latency set to the trial maximum).* (water maze)
- *Target hole not visited within the trial.* (Barnes maze)
- *Fewer than 3 arm entries — alternation cannot be computed.* (Y-maze)

A flag is a prompt to check, not an exclusion. You decide whether to exclude the animal (see Details below).

### Results

All metrics of the assay with their units. The [assay pages](../assays/index.md) define each one.

### Arena (or Freezing)

For video results, the tracked path is drawn on the arena with its zones. **Plot** switches between **Path** and **Heatmap**; the heatmap shows the time spent at each position.

Assays with markers show them as draggable points:

| Marker | Assay | Meaning |
|---|---|---|
| **A**, **B** | Novel object recognition | Object centers |
| **P** | Morris water maze | Platform center |
| **T** | Barnes maze | Target hole |

Drag a marker onto the true position and the metrics update immediately. **Save** keeps the change.

For fear conditioning, this card shows the motion trace with freezing bouts, baseline and CS periods instead (see [Freezing](../principles/metrics.md#freezing)).

### Series

Some results include a series, which can be analyzed as a time course in the Groups tab:

- open field: distance and center time per time bin;
- fear conditioning: freezing per CS and per time bin;
- water maze (manual): latency per trial;
- beam walking: traversal time per trial;
- sucrose preference: preference per day;
- two-armed bandit: choice around reversals, and the session choice plot.

### Sequence & labels

Text results: the arm sequence in the Y-maze (`ABCACB…`), T-maze and plus maze, the hole visits and search strategy in the Barnes maze, and the first choice in the T-maze.

### Entered values

For manual and imported raw values: what was entered. **Edit Values** reopens the form.

### Analysis settings

For video results: the same zone and threshold settings as on the setup screen. Changing them recomputes every metric from the saved positions at once. The video is not needed and is not tracked again. Typical uses:

- check how sensitive the center time is to the size of the center zone;
- correct the open-arm axis of the plus maze if it was set wrongly;
- enter the CS onsets of a fear session after the analysis;
- shorten the analysis window to the first 5 minutes.

The settings are stored per result. To apply the same change to many animals, change each result, or set it before analyzing the next videos.

### Details

**Subject ID**, **Group**, **Sex**, **Phase**, **Day**, **Trial**, **Date** and **Notes** can all be edited, for example to fix a typo in a group name. The card also shows the source (video, manual or imported), file, run folder, and the creation and last-update times.

**Exclude from group analysis** keeps the result but leaves it out of statistics and figures, with a **Reason** you type, e.g. *fell off the maze* or *tracking lost*. Excluded results can be shown again in the Groups tab with **Include excluded records**. This is safer than deleting the result.

### Methods

**How these numbers are computed** gives the method statement for the assay, the definition of every metric shown, and the parameters used: center fraction, entry criterion, freezing threshold, analysis window, and so on. Copy it into the methods section of a paper or a lab notebook.

### Saving, reverting and deleting

Edits to details, settings or markers are first kept as a draft. A bar shows **Unsaved changes** with **Revert** and **Save**.

**Delete Result** removes the result from the library. For video results, the tracking files in the run folder are kept. The start screen then counts the folder as a tracking run without a result, and **Create Results** can rebuild the result from it. Settings and markers return to their defaults, so check them.
