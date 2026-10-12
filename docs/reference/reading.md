# Further reading

RodentFlow deliberately uses a classic tracker: one animal, body center, no training ([why](../principles/tracking.md#why-a-classic-tracker)). When an experiment needs more, such as body parts, several interacting animals, or automatic classification of behaviors like grooming or rearing, the tools below are the current open-source standard. Their per-animal outputs can be imported into RodentFlow for statistics and figures ([how](../guide/manual-and-import.md)).

## Overview

- Luxem K, Sun JJ, Bradley SP, et al. **Open-source tools for behavioral video analysis: setup, methods, and best practices.** *eLife* 12, e79305 (2023). [doi:10.7554/eLife.79305](https://doi.org/10.7554/eLife.79305)
  A practical review covering recording setups, pose estimation, behavior quantification, and how to validate and report automated analyses. A good first read before choosing any tool.

## Pose estimation: tracking body parts

- Pereira TD, Tabris N, Matsliah A, et al. **SLEAP: A deep learning system for multi-animal pose tracking.** *Nature Methods* 19 (2022). [doi:10.1038/s41592-022-01426-1](https://doi.org/10.1038/s41592-022-01426-1)
- Lauer J, Zhou M, Ye S, et al. **Multi-animal pose estimation, identification and tracking with DeepLabCut.** *Nature Methods* 19 (2022). [doi:10.1038/s41592-022-01443-0](https://doi.org/10.1038/s41592-022-01443-0)
- Ye S, Filippova A, Lauer J, et al. **SuperAnimal pretrained pose estimation models for behavioral analysis.** *Nature Communications* 15, 5165 (2024). [doi:10.1038/s41467-024-48792-2](https://doi.org/10.1038/s41467-024-48792-2)
  Pretrained models, including a top-view mouse model, that can be used with little or no labeling of your own frames.

## From poses to behaviors

- Weinreb C, Pearl JE, Lin S, et al. **Keypoint-MoSeq: parsing behavior by linking point tracking to pose dynamics.** *Nature Methods* 21 (2024). [doi:10.1038/s41592-024-02318-2](https://doi.org/10.1038/s41592-024-02318-2)
  Unsupervised discovery of behavioral "syllables" from keypoint tracking.
- Goodwin NL, Choong JJ, Hwang S, et al. **Simple Behavioral Analysis (SimBA) as a platform for explainable machine learning in behavioral neuroscience.** *Nature Neuroscience* 27 (2024). [doi:10.1038/s41593-024-01649-9](https://doi.org/10.1038/s41593-024-01649-9)
  Supervised classifiers for user-defined behaviors, with explanations of what drives each classification.

## How these relate to RodentFlow

| Need | Use |
|---|---|
| Zone times, entries, distance, latencies, freezing for one animal, on the phone | RodentFlow alone |
| Nose-based exploration, head direction, rearing, gait from video | A pose estimator (SLEAP, DeepLabCut), then import per-animal values |
| Several animals in one arena (social tests) | A multi-animal pose tracker |
| Automatic labels for grooming, attack, mounting … | SimBA or Keypoint-MoSeq on top of pose tracking |
| Group statistics and figures for any of the above | Import into RodentFlow's Groups tab |

*This list is deliberately short and limited to work published from 2022 on.*
