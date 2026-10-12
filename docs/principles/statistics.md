# Statistics

The Groups tab chooses a test from three things: the **design** (what one data point is), the **number of groups**, and **parametric or non-parametric**. This page lists every combination and explains the choices.

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

## How the numbers were verified

The statistics engine ([`StatsEngine.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/StatsEngine.swift); test selection in [`GroupAnalysis.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/GroupAnalysis.swift)) is written from scratch in Swift, so it runs on the phone without any library. It includes the t, F, χ² and normal distributions, the studentized range distribution for Tukey's test (following the algorithm used in R), exact distributions for Mann–Whitney and Wilcoxon, and Greenhouse–Geisser ε. Each test was compared with established Python implementations (SciPy, pingouin, scikit-posthocs): Welch, Student, paired and one-sample t; exact and asymptotic Mann–Whitney; Wilcoxon; one-way ANOVA; Tukey; Kruskal–Wallis; Dunn; mixed and repeated-measures ANOVA with Greenhouse–Geisser; and Friedman. All **1,059 checks** agreed.

## A methods paragraph you can adapt

> Behavior was analyzed with RodentFlow 1.3 (iPhone). The animal's body center was tracked at 10 Hz by background subtraction (temporal-median background, adaptive threshold, contrast-weighted centroid) and converted to centimeters using a perspective-corrected arena calibration. Zone entries required a stay of 0.3 s. Values from repeated sessions were averaged per animal (n = animals). Groups were compared with a one-way ANOVA followed by Tukey–Kramer HSD (two-tailed, α = 0.05). Data are shown as mean ± SEM with individual animals.

Adjust the assay-specific parts. The exact parameters of each result are listed under **Methods** on its result screen, and the test statement is on the statistics card.
