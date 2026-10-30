# Group comparison & statistics (Mac)

Open a task and choose **Compare groups**. Pick a *Design*, *Measure*, *Phase*, which sessions (*All sessions (averaged per animal)* or *Session n only*), *Statistics* (parametric / non-parametric) and *Comparisons* (all pairs / vs. first group).

| Design                | Value per animal                                                         | Tests (2 groups · ≥ 3 groups)                                                                                                      |
|-----------------------|--------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| Compare groups        | Mean of its included sessions                                            | Welch t (with 95 % CI) or Mann–Whitney U · one-way ANOVA + Tukey–Kramer, or vs first group with Holm; Kruskal–Wallis + Dunn (Holm) |
| Across sessions       | One value per session number                                             | Two-way mixed ANOVA (group × session, Greenhouse–Geisser) + per-session group tests, Holm-corrected                                |
| Across days           | Trials averaged within each day (learning curves)                        | As above                                                                                                                           |
| Time course           | Series within a session (time bins, CS presentations, TST minutes)       | As above                                                                                                                           |
| Paired measures       | Two measures of the same animal (novel vs familiar, open vs closed arms) | Within groups: paired t / Wilcoxon; between groups: interaction or difference tests                                                |
| Change between phases | Phase B − phase A per animal (e.g. test − pre-test)                      | As “Compare groups”                                                                                                                |

- **Control group first:** groups that look like controls (WT, Control, Vehicle, Saline, Sham) are placed first; reorder, recolour or leave out groups in the list — settings are saved per task.
- **Reference value:** for measures with a natural “no preference” value (DI = 0, recognition index = 50 %, target quadrant = 25 %), tick *Test each group against the reference value*.
- **Options:** *Show individual animals*; *Include excluded sessions* (for a sensitivity look only).
- **Export this comparison…** writes the figure (PNG), a methods-and-results summary (TXT), the full result (JSON) and the per-animal values (CSV).

::: warning

**These are preliminary statistics** for exploring data: there is no correction across measures, designs or repeated looks at the data. Groups with fewer than 2 animals get no test (with the reason shown). Confirm with a pre-specified analysis before reporting — the exported `animals.csv` and `comparison_animal_values.csv` are ready for R, Python or [GraphPad Prism](https://www.graphpad.com/).

:::
