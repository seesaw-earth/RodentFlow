# Task pages and their figures

These scripts build the [task pages](../../docs/tasks/) of the manual and the figures on them.

| Script | What it does |
|---|---|
| `catalog.py` | Reads the app's paradigm catalog (`Shared/PoseEngine/Paradigms.swift` and `EnglishTranslations.json` of the app source) into `data/catalog.json`: summary, why keypoints help, set-up steps, measures and references, in English and Chinese. |
| `simlib.py`, `sim_a.py`, `sim_b.py`, `sim_c.py` | Simulated sessions, one per task: a model mouse is moved through the arena, the measures are computed with simplified versions of the app's definitions, and an English and a Chinese figure are drawn. |
| `run_figs.py` | Renders every figure into `docs/public/img/tasks/` and writes the computed values to `values.json`. |
| `gen_tasks.py` | Writes `docs/tasks/*.md`, `docs/zh/tasks/*.md` and, with the extra argument `reading`, `docs/reference/reading.md` from the catalog and the values. `tail-suspension.md` is written by hand. |
| `home_tasks.py` | Writes the task strip in the hero and the task library section of both home pages (`docs/public/index.html`, `docs/public/zh/index.html`), between the `TASK-STRIP` and `TASKS` markers. |
| `fix_cjk_bold.py` | Moves Chinese punctuation outside `**bold**` so CommonMark closes it (`**帧率：**大多数` → `**帧率**：大多数`). |
| `perf_figs.py` | Draws the speed, accuracy and identity charts of *Speed and accuracy* into `docs/public/img/perf/`. |

```bash
pip install numpy matplotlib pillow          # fonts: Inter and Noto Sans CJK SC
THUMB_DIR=../../docs/public/img/tasks/thumbs python3 run_figs.py ../../docs/public/img/tasks   # figures + card thumbnails
mv ../../docs/public/img/tasks/values.json data/values.json
python3 gen_tasks.py ../../docs data/catalog.json data/values.json
python3 gen_tasks.py ../../docs data/catalog.json data/values.json reading
python3 home_tasks.py ../../docs data/catalog.json
python3 perf_figs.py ../../docs/public/img/perf
```

The simulations are fixed by their random seeds, so the figures and values are reproducible. They illustrate how each measure is defined; they are not data.
