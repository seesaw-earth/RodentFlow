---
title: "Comparing groups"
description: "Group comparisons in RodentFlow on iPhone, iPad and Mac: designs, which test is used, survival curves for censored latencies, figures and exports."
---

# Comparing groups

Open **Groups** on iPhone or iPad, or **Compare groups** on a Mac task. Both use the same code, so the same sessions give the same statistics. Results from pose, classic centroid, multi-chamber tail suspension and manual entry all take part.

## 1 · Choose what to compare {#choose}

1. **Task and measure.** Every measure of the task is offered, with its unit.
2. **Design.**

| Design | Use it for |
|---|---|
| **Compare groups** | One value per animal, groups side by side (the usual case) |
| **Across days** / **Across sessions** | Learning curves: the same animals on several days or sessions |
| **Time course** | The measure per time bin within a session |
| **Change between phases** | The per-animal difference between two phases, for example test − pre-test (CPP score, step-down test vs training) |
| **Paired measures** | Two measures of the same animal, for example novel vs familiar object |

3. **Filters.** Phase, day, trial or session number, and sex. Phases are never pooled unless you choose to.
4. **Second factor** (optional). Sex, or group names split at a separator: `WT-Veh`, `WT-Drug`, `KO-Veh`, `KO-Drug` become genotype × treatment.
5. **Covariate** (optional). Another measure of the same animal, such as home-cage food intake in novelty-suppressed feeding or swim speed in the water maze.

## 2 · Read the result {#result}

- **n is the number of animals.** Several sessions of one animal within the chosen phase are averaged first. Excluded sessions are left out.
- **The test fits the design**: Welch’s t-test or Mann–Whitney for two groups; one-way ANOVA with Tukey–Kramer, or Kruskal–Wallis with Dunn–Holm, for three or more; paired t-test or Wilcoxon within animals; mixed ANOVA with Greenhouse–Geisser correction across days or sessions; two-way ANOVA (Type III) with a second factor; ANCOVA with a covariate. Each comes with an effect size and its 95 % confidence interval. [Statistics](../principles/statistics.md) gives the details.
- **Assumption checks** (Shapiro–Wilk per group and on the residuals, Brown–Forsythe for equal variances) are shown as advice; the app does not switch tests on its own.
- **Latencies with a cut-off** (water-maze escape, passive avoidance, step-down, visual cliff, novelty-suppressed feeding, attack latency) also get **Kaplan–Meier curves and a log-rank test**, which treat animals that never reached the event correctly.
- **Yes/no measures** (stepped down, entered the dark side, chose the deep side first, attacked) also get **Fisher’s exact test** or a chi-square test.

## 3 · Figure {#figure}

The figure on screen is the figure you export. Choose dots with the mean, bars with dots, box plots with dots or violins with dots; error bars as SEM, SD or 95 % CI; significance brackets with stars or exact p values; a fixed y range; and a greyscale mode for print. Every animal is shown. Sizes follow journal columns (85, 114 or 174 mm) with one font size for the whole figure.

For pose tasks, **Export task atlas** draws every animal’s track and heat map as multi-panel figures, one row per group, with **one shared colour scale** and a colour bar, plus an average heat map per group.

## 4 · Export {#export}

A group export is a folder of English files:

| File | Contents |
|---|---|
| `figure.pdf` / `.svg` / `_300dpi.png` | The figure |
| `figure_source_data.csv` | One row per animal, plus n, mean, SD, SEM, error-bar ends, median and quartiles per group |
| `figure_legend.txt` | A draft legend: plot type, error bars, n per group, test, statistic, p, effect size, star levels |
| `stats_report.csv` | One row per test, term, pairwise comparison, effect size and assumption check |
| `methods.txt` | A Methods paragraph for the statistics |
| `prism_table.txt` | Ready to paste into GraphPad Prism (column or grouped tables) |
| `long_format.csv` | One row per animal with group, factors, sex and covariate, for R or Python |
| `summary.txt`, `comparison_result.json`, `README.txt` | Summary, the full result, and a description of the files |
