---
title: "Statistics"
description: "Which statistical test RodentFlow 2.1 uses for each design, why, and how to read the result: Welch, Mann–Whitney, ANOVA with Tukey–Kramer, Kruskal–Wallis with Dunn, mixed ANOVA, two-way ANOVA, ANCOVA, survival analysis and effect sizes."
---

# Statistics

The group page (Groups on iPhone and iPad, Compare groups on the Mac) chooses a test from three things: the **design** (what one data point is), the **number of groups**, and **parametric or non-parametric**. This page lists every combination and explains the choices.

## The unit of analysis is the animal

Each animal contributes **one value per level** of the design. When an animal has several results, such as trials within a day, repeated sessions or several phases pooled together, they are **averaged within the animal** first, and the app says so in the notes. n in every test and figure is the number of animals.

Testing trials as if they were independent animals (pseudoreplication) makes p values far too small. Averaging within animals avoids that. For learning curves, the *Across days* design keeps the day structure as a repeated factor instead of discarding it.

## Which test is used

### Compare groups, and change between phases

*Change between phases* first computes each animal's difference (To − From) and then proceeds exactly like *Compare groups*.

| Groups | Parametric | Non-parametric |
|---|---|---|
| 2 | **Welch's t-test** (two-tailed), mean difference with 95 % CI, **Hedges' g** | **Mann–Whitney U** (exact p without ties and with n ≤ 20 per group, otherwise normal approximation with tie and continuity correction), **rank-biserial r** |
| ≥ 3, all pairs | **One-way ANOVA** (η²) + **Tukey–Kramer HSD** | **Kruskal–Wallis** (η²<sub>H</sub>) + **Dunn's test**, Holm-adjusted |
| ≥ 3, vs. first group | One-way ANOVA + **Welch's t** of each group vs the first, Holm-adjusted | Kruskal–Wallis + Dunn's test vs the first group, Holm-adjusted |
| per group vs chance (optional) | **One-sample t** (Cohen's d) | **Wilcoxon signed-rank** (exact without ties and with n ≤ 30), matched-pairs r |

### Across days and time course

Animals form the rows and the levels (days, time bins, CS, trials) the columns.

| Groups | Parametric | Non-parametric |
|---|---|---|
| 1 | **One-way repeated-measures ANOVA** with Greenhouse–Geisser correction | **Friedman test** (Kendall's W) |
| ≥ 2 | **Two-way mixed ANOVA**: group (between) × level (within, Greenhouse–Geisser-corrected), with partial η² | Per-level Mann–Whitney tests, Holm-adjusted (no omnibus test) |
| post hoc, ≥ 2 groups | Group differences at each level: Welch's t, Holm-adjusted across all comparisons | Mann–Whitney, Holm-adjusted |

The mixed ANOVA needs complete data. Animals missing a level are left out of the ANOVA, with a note, but are still drawn in the figure.

### Paired measures

| | Parametric | Non-parametric |
|---|---|---|
| Within each group | **Paired t-test** (Cohen's d<sub>z</sub>) | **Wilcoxon signed-rank** |
| Between groups | Mixed ANOVA group × measure. The **interaction** tests whether the within-animal difference differs between groups. | Mann–Whitney (2 groups) or Kruskal–Wallis (≥ 3) on the within-animal differences |

### Two factors {#two-way}

With a second factor (sex, or group names split into two factors such as genotype × treatment), the app runs a **two-way ANOVA with Type III sums of squares**, which stays correct when the groups are unequal in size. It reports both main effects and the interaction (partial η²), **simple effects** using the pooled error of the full model, and pairwise comparisons Holm-adjusted within each comparison, each with a 95 % CI.

### A covariate {#ancova}

**ANCOVA** adjusts the group comparison for another measure of the same animal, such as home-cage food intake in novelty-suppressed feeding or swim speed in the water maze. It gives the adjusted group effect, the covariate slope, adjusted means ± SE with 95 % CI and Holm-adjusted pairwise differences. It also checks that the slope is the same in every group (group × covariate) and points out when the covariate itself differs between groups.

### Latencies with a cut-off {#survival}

For latencies where some animals never reach the event before the cut-off (water-maze escape, passive avoidance, step-down, visual cliff, novelty-suppressed feeding, attack latency), the page adds **Kaplan–Meier curves** (censored animals marked +) with the number of events, the median latency per group and a **log-rank test** (χ², df = groups − 1). Bars and t-tests enter censored latencies at the cut-off, so with censored data the log-rank test is the one to report. Each animal must contribute one record; filter to one phase, day or trial first.

### Yes/no measures {#proportions}

Measures that are 0 or 100 per animal (stepped down, entered the dark side, chose the deep side first, attacked) are also compared as proportions with **Fisher’s exact test** (two-sided) or a **chi-square test** of independence.

## Assumption checks {#assumptions}

Each comparison shows a **Shapiro–Wilk** test per group and on the model residuals, and a **Brown–Forsythe** test for equal variances. They are advice: the app suggests whether a parametric or non-parametric test fits better, but does not switch tests on its own. With fewer than 8 animals per group it notes that these checks have little power.

## Effect sizes {#effect-sizes}

Every test comes with an effect size and its 95 % CI: Hedges’ g and the mean difference (Welch CI) for two groups; r = Z/√N, the rank-biserial correlation and the Hodges–Lehmann shift for Mann–Whitney; η², ω² and the difference of every pair of means (Tukey simultaneous or unadjusted intervals) for several groups; the mean difference and d<sub>z</sub> for paired data; partial η² for two-way ANOVA and ANCOVA.

## Why these choices

- **Welch rather than Student's t.** Welch's test does not assume equal variances. When the variances are equal it loses almost nothing, and when they differ it keeps the false-positive rate where it should be. It is a sensible default for small animal groups.
- **Tukey–Kramer for all pairs.** It controls the family-wise error rate across all pairwise comparisons and handles unequal group sizes. **Holm** is used where there is no single-step method, for comparisons against a control and for Dunn's test. It is uniformly more powerful than Bonferroni.
- **Greenhouse–Geisser.** Repeated measures over days rarely have equal variances and covariances (sphericity). The correction scales the degrees of freedom by ε, which is reported, so the p value stays valid.
- **Effect sizes** come with every test, because with n = 6–12 per group a p value alone says little about how large an effect is.
- **Two-tailed tests** throughout. A one-tailed test is a decision that has to be made before seeing the data, so it is not offered as a switch.

## Reading the statistics card

A two-group example:

> *Two-tailed Welch's t-test (unequal variances).*
> t(13.4) = 2.71, p = 0.017, Hedges' g = 1.31
> Mean difference (WT − KO) = 4.8, 95 % CI [1.0, 8.6].

The card then lists pairwise comparisons with adjusted p and stars (* < 0.05, ** < 0.01, *** < 0.001, **** < 0.0001), and descriptive statistics per group: n, mean ± SEM, SD, median and quartiles. p values below 0.0001 are shown as "p < 0.0001".

If a group has fewer than two animals, or all of its values are identical, no test can be computed, and the card says so instead of showing a misleading result.
