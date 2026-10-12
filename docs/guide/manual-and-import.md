# Manual entry & importing tables

Not every assay is scored from video, and not every lab scores video in RodentFlow. Values scored by hand or by another program can be entered or imported. They become the same kind of result as a tracked video and appear together with tracked results in the Groups tab.

## Entering values by hand

Choose the assay in the **New experiment** card and tap **Enter Values** (**Enter Trials** for the two-armed bandit). The form has three parts:

1. **Animal**: subject ID, group, sex, and phase, day or trial where the assay uses them.
2. **Measurements**: the raw values for this assay. Required fields are marked, and the app lists what is still missing.
3. **Result**: the derived metrics, recomputed as you type. For example, discrimination index from novel and familiar times, or sucrose preference from bottle weights.

Some assays take rows, such as one row per trial, per day, per CS or per stride. Add rows with the button below the table; the app computes the per-animal values from all rows.

| Assay | What you enter | What the app derives |
|---|---|---|
| Open field | Total distance, center time, test duration, center entries, latency | Center %, mean speed |
| Elevated plus maze | Open- and closed-arm time (required), center time, entries, distance | Open-arm time %, open-entry %, total entries |
| Light–dark box | Light time and test duration (required), transitions, latency to dark | Dark time, light time % |
| Marble burying | Marbles in cage, number buried (≥ 2/3 covered), partially buried, duration | % buried |
| Sucrose preference | Per day: bottle weights at start and end for sucrose and water, leak controls, hours. Optional body weight. | Preference (pooled and mean daily), intake per day and per kg |
| Y-maze | The arm sequence, e.g. `ABCABACB` | Entries, alternations, alternation % |
| T-maze | First choice (left/right), arm entries, choice latency | Right-choice %, total entries |
| Novel object recognition | Novel and familiar exploration time, bouts, exclusion criterion | Discrimination index, recognition index, low-exploration flag |
| Morris water maze | Per trial: escape latency, path length, swim speed. Probe: target and opposite quadrant %, crossings. | Mean of trials, % trials with platform found |
| Barnes maze | Per trial: primary latency, primary and total errors, path length. Probe: target quadrant % | Mean of trials |
| Fear conditioning | Session and baseline freezing %. Per CS: freezing during and after the CS. | Mean CS freezing, freezing per CS |
| Beam walking | Per trial: traversal time, foot slips, fell (yes/no). Beam label and width. | Mean time, slips per trial, % falls |
| Gait analysis | Per stride: side, hind and fore stride length, base width, paw overlap. Optional run duration and distance. | Means, hind-stride CV, left–right asymmetry, cadence, speed |
| Conditioned place preference | Paired and unpaired chamber time (required), neutral time, paired entries | Preference score (paired − unpaired), paired % |
| Two-armed bandit | Per trial: choice, rewarded, optional reward probabilities and reaction time | Win-stay, lose-shift, switch rate, high-value choices, Q-learning fit |

Definitions of every metric are on the [assay pages](../assays/index.md). A saved manual result can be changed later with **Edit Values** on its result screen.

## Importing a table

Tap **Import Table** in the New experiment card. In the import sheet:

1. Choose the **Assay** the table belongs to.
2. Optionally type a **Group for rows without a group column**.
3. **Choose File (CSV, TSV, JSON)**.
4. Read the preview, then tap **Import**.

**CSV Template for …** creates an empty CSV with the column names this assay expects. Fill it in a spreadsheet program and import it.

::: tip Excel and Numbers files
`.xlsx` and `.numbers` files cannot be read directly. Export the sheet as CSV first (File › Export or Save As › CSV).
:::

### Which table layouts work

The app recognizes four layouts automatically.

**1. One row per animal, one column per metric.** This is the most common layout.

```csv
Mouse ID,Genotype,Sex,Total distance (m),Center time (%),Center entries
WT01,WT,M,28.83,19.0,17
KO01,KO,F,22.10,12.4,11
```

**2. Raw measurements**, the same fields as in manual entry. One row per animal, or one row per trial, day or stride when the assay uses rows. The app computes the metrics exactly as in manual entry.

```csv
subject,group,day,sucrose_start,sucrose_end,water_start,water_end,sucrose_leak,water_leak
Con01,Control,1,185.63,180.55,193.44,193.29,0.1,0.1
Con01,Control,2,180.26,175.23,192.09,191.94,0.1,0.1
```

**3. Long format**: one row per animal and metric, with a `metric` (or `measure`, `variable`, `parameter`) column and a `value` (or `result`, `score`) column.

```csv
subject,group,metric,value
V01,Vehicle,novel_time_s,23.5
V01,Vehicle,familiar_time_s,16.4
```

**4. Trial-by-trial bandit data** with `choice` and `reward` columns, plus optional `p_left`, `p_right` and `rt`. Choices may be written `L`/`R`, `left`/`right` or `0`/`1`.

JSON files exported from RodentFlow, as a single result or a list, are imported as they are and keep their own assay. A 1.0 `summary.json` is converted too.

### How columns are matched

Column names are compared without regard to case, spaces or punctuation. `Total distance (m)`, `total_distance_m` and `distance_m` all match the same metric.

| Information | Accepted column names |
|---|---|
| Animal | `subject`, `subject_id`, `mouse`, `mouse_id`, `animal`, `animal_id`, `id`, `rat`, `name`, `编号`, `动物编号`, `小鼠编号` … |
| Group | `group`, `condition`, `genotype`, `treatment`, `cohort`, `组别`, `分组`, `处理`, `基因型` |
| Sex | `sex`, `gender`, `性别`. Values `M`/`F`, `male`/`female`, `♂`/`♀`, `雄`/`雌`. |
| Day | `day`, `session_day`, `天`, `天数` |
| Trial | `trial`, `trial_number`, `run`, `试次` |
| Phase | `phase`, `stage`, `session`, `test`, `block`, `阶段`. Values such as `probe`, `acquisition`, `pre-test` and `探索测试` are mapped to the app's phases. |
| Date | `date`, `experiment_date`, `test_date`, `日期`, `实验日期` |
| Notes | `notes`, `comment`, `备注` |
| Metrics | The metric key, the metric name, or the name with its unit, in English. When the app runs in Chinese, the Chinese names shown in the app work too, e.g. `总距离 (m)`. |

Other numeric columns are kept as *custom metrics* under their own names, so nothing is lost. They can be analyzed in the Groups tab like any other measure.

### Numbers and missing values

- Comma, semicolon and tab separators are detected from the header line.
- In semicolon-separated files, a decimal comma (`12,5`) is read as 12.5.
- Empty cells and `NA`, `NaN`, `N/A`, `-`, `null` count as missing.
- `yes`/`no` and `true`/`false` are read as 1/0, and a trailing `%` is ignored.
- Files are read as UTF-8, with a fallback to Windows encoding for older exports.

### The import preview

Before anything is saved, the preview shows:

- **Format**: which layout was recognized;
- **Records**, **Animals** and **Groups** counted;
- **Recognized columns**: each column and the metric or field it was matched to;
- **Ignored columns**: text columns that matched nothing;
- warnings, for example a missing group column;
- **First records**: the first few results as they will be saved.

If a column was not recognized, rename it in the file to the metric name shown in the app, or use the CSV template.

## Sample files

Synthetic example tables for trying the import are listed on the [Quick start](./getting-started.md#try-it-without-a-video) page.
