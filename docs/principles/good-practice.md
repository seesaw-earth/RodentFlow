# Getting results you can trust

::: info

**RodentFlow is a research aid, not a diagnostic tool.** Its measures are algorithmic estimates from landmark geometry or motion. They are only as good as your recording, calibration and thresholds, and the desktop analyzers are ports whose numerical parity with the original apps is still being verified.

:::

1.  **Validate on your own setup.** Hand-score a few videos per assay (blinded to group), compare with RodentFlow, and adjust thresholds once — before the real study. [BORIS](https://www.boris.unito.it/) is a free tool for manual scoring.
2.  **Freeze your parameters.** Use the same calibration logic, analysis window and thresholds for every animal in a study. They are recorded in every export.
3.  **Check tracking on every session** (a 100-frame check takes under a minute) and decide exclusion criteria in advance (e.g. fell off the maze, \< 80 % detection). The app lists QC warnings but never excludes automatically.
4.  **Respect the experimental unit.** n = animals, not sessions or frames ([Lazic et al. 2018](https://doi.org/10.1371/journal.pbio.2005282)). Do not pool phases.
5.  **Treat in-app statistics as preliminary** and run your pre-registered analysis on the exported `animals.csv`.
6.  **Report what you did:** app edition and version, assay, model or tracker, calibration, analysis window, thresholds, exclusions — `README_methods.txt` and the mobile “Methods description” give you a starting text. Follow the [ARRIVE 2.0 guidelines](https://arriveguidelines.org/).
7.  **Interpret with care.** “Nose near object” is a proxy for investigation; “low motion” is a proxy for freezing or immobility. Always pair anxiety-, memory- and coping-type measures with a locomotor control.
