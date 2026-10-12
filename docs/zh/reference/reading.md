# 延伸阅读

RodentFlow 有意使用经典追踪方法：单只动物、身体中心、无需训练（[原因](../principles/tracking.md#why-a-classic-tracker)）。当实验需要更多信息时，比如身体部位、多只互动的动物，或者自动识别理毛、直立等行为，下面这些工具是目前开源领域的标准。它们输出的每只动物的数据可以导入 RodentFlow 做统计和作图（[方法](../guide/manual-and-import.md)）。

## 综述

- Luxem K, Sun JJ, Bradley SP, et al. **Open-source tools for behavioral video analysis: setup, methods, and best practices.** *eLife* 12, e79305 (2023). [doi:10.7554/eLife.79305](https://doi.org/10.7554/eLife.79305)
  一篇实用的综述，涵盖录像装置、姿态估计、行为量化，以及如何验证和报告自动分析结果。选择任何工具之前，都值得先读一读。

## 姿态估计：追踪身体部位

- Pereira TD, Tabris N, Matsliah A, et al. **SLEAP: A deep learning system for multi-animal pose tracking.** *Nature Methods* 19 (2022). [doi:10.1038/s41592-022-01426-1](https://doi.org/10.1038/s41592-022-01426-1)
- Lauer J, Zhou M, Ye S, et al. **Multi-animal pose estimation, identification and tracking with DeepLabCut.** *Nature Methods* 19 (2022). [doi:10.1038/s41592-022-01443-0](https://doi.org/10.1038/s41592-022-01443-0)
- Ye S, Filippova A, Lauer J, et al. **SuperAnimal pretrained pose estimation models for behavioral analysis.** *Nature Communications* 15, 5165 (2024). [doi:10.1038/s41467-024-48792-2](https://doi.org/10.1038/s41467-024-48792-2)
  预训练模型，包括俯视小鼠模型，只需很少甚至不需要自己标注就能使用。

## 从姿态到行为

- Weinreb C, Pearl JE, Lin S, et al. **Keypoint-MoSeq: parsing behavior by linking point tracking to pose dynamics.** *Nature Methods* 21 (2024). [doi:10.1038/s41592-024-02318-2](https://doi.org/10.1038/s41592-024-02318-2)
  从关键点追踪数据中无监督地发现行为“音节”。
- Goodwin NL, Choong JJ, Hwang S, et al. **Simple Behavioral Analysis (SimBA) as a platform for explainable machine learning in behavioral neuroscience.** *Nature Neuroscience* 27 (2024). [doi:10.1038/s41593-024-01649-9](https://doi.org/10.1038/s41593-024-01649-9)
  针对用户自定义行为的有监督分类器，并能解释每次分类的依据。

## 与 RodentFlow 的关系

| 需求 | 工具 |
|---|---|
| 单只动物的区域时间、进入次数、距离、潜伏期、僵直，在手机上完成 | 只用 RodentFlow |
| 按鼻尖计算的探索、头部朝向、直立、视频步态 | 姿态估计工具（SLEAP、DeepLabCut），再导入每只动物的数值 |
| 同一场地多只动物（社交实验） | 多动物姿态追踪工具 |
| 自动标注理毛、攻击、爬跨等行为 | 在姿态追踪基础上使用 SimBA 或 Keypoint-MoSeq |
| 以上任何数据的组间统计与作图 | 导入 RodentFlow 的组间分析 |

*本列表刻意保持简短，只收录 2022 年及以后发表的工作。*
