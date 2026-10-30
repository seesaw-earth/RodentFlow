# 如何引用数据、论文和软件

<p class="rf-eyebrow">参考</p>

每个模型需要引用什么、完整参考文献、许可汇总、BibTeX 和方法部分示例。所有信息已于 2026 年 10 月 20 日对照 Zenodo、DataCite、Crossref 和出版商页面核对。

## 引用数据的三条规则 {#principles}

1.  **用 DOI 引用数据集本身，**放进参考文献；同时引用数据集作者要求引用的论文。数据集和论文是两项独立的成果。
2.  **引用软件时写明版本。**如 “Ultralytics YOLO26”“RodentFlow 0.7.1”“coremltools 9.0”：不同版本的结果可能不同。
3.  **说明做了哪些改动、标签从哪里来。**CC BY 4.0 要求署名、给出许可链接并注明改动。这里的标签是由 DeepLabCut 和 JAX 网络的预测统一、过滤而来，应如实写明，不要让读者以为是人工标注。

## 使用了 MousePose6（RodentPose 流程） {#use-mousepose6}

| 引用                                                  | 原因                                        | 文献                                        |
|-------------------------------------------------------|---------------------------------------------|---------------------------------------------|
| RodentFlow（注明版本）                              | 运行模型并计算指标的软件                    | [\[S1\]](#r-rodentstudio)                   |
| Ultralytics YOLO26                                    | 模型结构、预训练权重、训练和导出代码        | [\[S2\]](#r-yolo26)                         |
| ETH 旷场数据集与 ETH 埋珠 / 明暗箱 / 恐惧条件箱数据集 | 训练视频和 DeepLabCut 姿态文件（CC BY 4.0） | [\[D1\]](#r-vz2023)、[\[D2\]](#r-vz2024d)   |
| BehaviorFlow 论文                                     | 介绍 ETH 录像及其姿态估计                   | [\[P1\]](#r-vz2024)                         |
| JAX 品系调查与 BxD 数据集                             | 训练视频和 JAX 姿态文件                     | [\[D3\]](#r-jabs-ss)、[\[D4\]](#r-jabs-bxd) |
| JABS 论文与 JAX 姿态网络论文                          | 介绍 JAX 数据集及生成关键点的网络           | [\[P2\]](#r-jabs)、[\[P3\]](#r-sheppard)    |
| DeepLabCut                                            | ETH 的标签是 DeepLabCut 预测                | [\[P4\]](#r-mathis)、[\[P5\]](#r-nath)      |
| COCO（建议）                                          | 初始权重在 COCO 关键点上预训练              | [\[P6\]](#r-coco)                           |

品系调查数据集把 Geuther 等 2019 [\[P7\]](#r-geuther2019) 列为相关论文，引用 \[D3\] 时应一并引用；BxD 数据集没有列出相关论文。品系调查的文件按使用它们的 JAX 研究打了标签（如 Gait、Grooming、JABS600、JABS1200），其中 Geuther 等 2021 [\[P8\]](#r-geuther2021) 是理毛研究。Dataverse 自己给出的推荐引用格式：

    Kumar, Vivek; Brian Geuther; Sean Deats, 2024, "The Jackson Laboratory (JAX) - Kumar Lab Mouse Strain Survey of Behavior in the Open Field Arena (Video Dataset)", https://doi.org/10.7910/DVN/SAPNJG, Harvard Dataverse, V1, UNF:6:OiPvgrf6RjsZOSxB9/nVEA== [fileUNF]

    Kumar, Vivek; Deats, Sean, 2025, "The Jackson Laboratory (JAX) - Kumar Lab Mouse BxD Survey of Behavior in the Open Field Arena (Video Dataset)", https://doi.org/10.7910/DVN/RQYI04, Harvard Dataverse, V1, UNF:6:r9GfOhUT7LK/e1KHwwhuHQ== [fileUNF]

## 使用了 CylinderMousePoseV2（RodentLimb 流程） {#use-cylinder}

| 引用                     | 原因                                 | 文献                                       |
|--------------------------|--------------------------------------|--------------------------------------------|
| RodentFlow（注明版本） | 运行模型和 RodentLimb 分析器         | [\[S1\]](#r-rodentstudio)                  |
| Ultralytics YOLO26       | 模型结构、预训练权重、训练和导出代码 | [\[S2\]](#r-yolo26)                        |
| DeepLabCut               | 生成了 20,000 帧训练标签的教师模型   | [\[P4\]](#r-mathis)、[\[P5\]](#r-nath)     |
| 实验室的圆筒实验录像     | 训练数据；如已发表请引用该数据集     | <Badge type="warning" text="发表后补充" /> |
| COCO（建议）             | 初始权重的预训练数据                 | [\[P6\]](#r-coco)                          |

## 使用了 TST 检测器 {#use-detector}

引用 RodentFlow [\[S1\]](#r-rodentstudio) 和 Ultralytics YOLO11 [\[S3\]](#r-yolo11)，并说明使用的是 YOLO 检测器还是经典检测器（RodentFlow 的导出文件会记录）。RodentFlow 流程不需要引用模型；在方法中描述经典追踪器并引用 RodentFlow 即可。

## 引用本教程中的检验 {#use-checks}

- CalMS21 零样本测试：CalMS21 数据集 [\[D5\]](#r-calms-data) 和论文 [\[P9\]](#r-calms)；MARS 关键点来自 MARS [\[P10\]](#r-mars)。
- 高架十字迷宫预试验：Sturman 等 2020 [\[P11\]](#r-sturman) 及视频记录 [\[D6\]](#r-sturman-data)；如使用了 DLCAnalyzer 的脚本，再引用 [\[S5\]](#r-dlcanalyzer)。
- PhysioNet 演示视频（圆筒 v1）：该数据集 [\[D7\]](#r-physionet-data)，并按 PhysioNet 的要求引用平台论文 [\[P12\]](#r-physionet)。
- 导出为 Core ML：coremltools [\[S4\]](#r-coremltools)。

## 方法部分示例 {#methods}

请按实际做法修改，方括号内的内容全部替换。英文版示例见[英文页](/tutorials/citations#methods)。

::: info

*姿态估计。*使用 RodentFlow \[版本\] \[S1\] 通过 Core ML 在本机运行 MousePose6 模型（`MousePose6_960_int8`，8 位权重的 YOLO26n-pose 网络 \[S2\]），逐帧估计六个身体关键点（鼻尖、左耳、右耳、颈部、身体中心和尾根）。该模型在四个公开俯视数据集 \[D1–D4\] 的 36 段视频共 6,140 帧上训练，标签来自这些数据集随附的 DeepLabCut \[P4, P5\] 与 JAX 姿态网络 \[P3\] 预测，经统一关键点定义和质量过滤后使用；因此标签由模型生成，而非人工标注。在同一批数据集的留出视频上，该模型检出 94.6 % 的小鼠，已检出小鼠的关键点中有 96.1 % 与参照标签相差不到 0.1 个体长。我们在自己的录像中每段随机抽取 \[数量\] 帧检查了关键点位置［，并将得到的指标与 \[数量\] 段视频的盲法人工评分进行了比较］。

:::

## 参考文献 {#refs}

文献条目保持原文，便于直接用于论文。

### 软件

- <span id="r-rodentstudio"></span><Badge type="info" text="S1" />Shi, Z. (2026). *RodentFlow* (Version \[used\]) \[Computer software\]. <https://github.com/seesaw-earth/RodentStudio-Support>. Source licence: AGPL-3.0.
- <span id="r-yolo26"></span><Badge type="info" text="S2" />Jocher, G., Qiu, J., Liu, M., Lyu, S., Akyon, F. C., & Kalfaoglu, M. E. (2026). Ultralytics YOLO26: Unified real-time end-to-end vision models. *arXiv*, 2606.03748. <https://doi.org/10.48550/arXiv.2606.03748>. Software: <https://github.com/ultralytics/ultralytics> (AGPL-3.0 or Ultralytics Enterprise licence).
- <span id="r-yolo11"></span><Badge type="info" text="S3" />Jocher, G., & Qiu, J. (2024). *Ultralytics YOLO11* (Version 11.0.0) \[Computer software\]. <https://github.com/ultralytics/ultralytics>. AGPL-3.0.
- <span id="r-coremltools"></span><Badge type="info" text="S4" />Apple Inc. (2025). *coremltools* (Version 9.0) \[Computer software\]. <https://github.com/apple/coremltools>. BSD-3-Clause.
- <span id="r-dlcanalyzer"></span><Badge type="info" text="S5" />ETHZ-INS. *DLCAnalyzer* \[Computer software\]. <https://github.com/ETHZ-INS/DLCAnalyzer>. GPL-3.0.

### 数据集

- <span id="r-vz2023"></span><Badge type="info" text="D1" />von Ziegler, L. M., Roessler, F. K., Sturman, O., & Bohacek, J. (2023). *Raw video and pose estimation data of top view open field mouse behavior recordings of acute and chronic stress models* \[Data set\]. Zenodo. <https://doi.org/10.5281/zenodo.8186065>. CC BY 4.0.
- <span id="r-vz2024d"></span><Badge type="info" text="D2" />von Ziegler, L., Roessler, F. K., Sturman, O., Waag, R., & Bohacek, J. (2024). *Additional raw video and pose estimation data of top view mouse behavior recordings (marble burying test, light-dark box, fear conditioning box) of acute and chronic stress models* \[Data set\]. Zenodo. <https://doi.org/10.5281/zenodo.11235068>. CC BY 4.0.
- <span id="r-jabs-ss"></span><Badge type="info" text="D3" />Kumar, V., Geuther, B., & Deats, S. (2024). *The Jackson Laboratory (JAX) - Kumar Lab Mouse Strain Survey of Behavior in the Open Field Arena (Video Dataset)* (V1) \[Data set\]. Harvard Dataverse. <https://doi.org/10.7910/DVN/SAPNJG>. UNF:6:OiPvgrf6RjsZOSxB9/nVEA== \[fileUNF\]. CC BY-NC-SA 4.0。数据集页面显示为 1.2 版，其推荐引用格式写作 “V1”。
- <span id="r-jabs-bxd"></span><Badge type="info" text="D4" />Kumar, V., & Deats, S. (2025). *The Jackson Laboratory (JAX) - Kumar Lab Mouse BxD Survey of Behavior in the Open Field Arena (Video Dataset)* (V1) \[Data set\]. Harvard Dataverse. <https://doi.org/10.7910/DVN/RQYI04>. UNF:6:r9GfOhUT7LK/e1KHwwhuHQ== \[fileUNF\]. CC BY-NC-SA 4.0。1.0 版。
- <span id="r-calms-data"></span><Badge type="info" text="D5" />Sun, J. J., Karigo, T., Anderson, D. J., Perona, P., Yue, Y., & Kennedy, A. (2021). *Caltech Mouse Social Interactions (CalMS21) Dataset* (Version 1.0) \[Data set\]. CaltechDATA. <https://doi.org/10.22002/D1.1991>. CC BY 4.0.
- <span id="r-sturman-data"></span><Badge type="info" text="D6" />von Ziegler, L., Sturman, O., & Bohacek, J. (2020). *Videos for deeplabcut, noldus ethovision X14 and TSE multi conditioning systems comparisons* \[Data set\]. Zenodo. <https://doi.org/10.5281/zenodo.3608658>. CC BY 4.0.
- <span id="r-physionet-data"></span><Badge type="info" text="D7" />Jiang, Y., Venkitaraman, S., Jung, H. R., Blackwood, S., Lee, J., Jadav, A. A., Lee, D., Kamal, A., & Landsness, E. C. (2026). *Longitudinal Cylinder Rearing Behavioral Data in a Mouse Stroke Model Across Multiple Drug Treatments* (Version 1.0.0) \[Data set\]. PhysioNet. <https://doi.org/10.13026/8bnm-6e37>. ODC-By 1.0.

### 论文

- <span id="r-vz2024"></span><Badge type="info" text="P1" />von Ziegler, L. M., Roessler, F. K., Sturman, O., Waag, R., Privitera, M., Duss, S. N., O'Connor, E. C., & Bohacek, J. (2024). Analysis of behavioral flow resolves latent phenotypes. *Nature Methods*, 21(12), 2376–2387. <https://doi.org/10.1038/s41592-024-02500-6>
- <span id="r-jabs"></span><Badge type="info" text="P2" />Choudhary, A., Geuther, B. Q., Sproule, T. J., Beane, G., Kohar, V., Trapszo, J., & Kumar, V. (2026). JAX Animal Behavior System (JABS), a genetics-informed, end-to-end advanced behavioral phenotyping platform for the laboratory mouse. *eLife*, 14, RP107259. <https://doi.org/10.7554/eLife.107259>
- <span id="r-sheppard"></span><Badge type="info" text="P3" />Sheppard, K., Gardin, J., Sabnis, G. S., Peer, A., Darrell, M., Deats, S., Geuther, B., Lutz, C. M., & Kumar, V. (2022). Stride-level analysis of mouse open field behavior using deep-learning-based pose estimation. *Cell Reports*, 38(2), 110231. <https://doi.org/10.1016/j.celrep.2021.110231>
- <span id="r-mathis"></span><Badge type="info" text="P4" />Mathis, A., Mamidanna, P., Cury, K. M., Abe, T., Murthy, V. N., Mathis, M. W., & Bethge, M. (2018). DeepLabCut: Markerless pose estimation of user-defined body parts with deep learning. *Nature Neuroscience*, 21(9), 1281–1289. <https://doi.org/10.1038/s41593-018-0209-y>
- <span id="r-nath"></span><Badge type="info" text="P5" />Nath, T., Mathis, A., Chen, A. C., Patel, A., Bethge, M., & Mathis, M. W. (2019). Using DeepLabCut for 3D markerless pose estimation across species and behaviors. *Nature Protocols*, 14(7), 2152–2176. <https://doi.org/10.1038/s41596-019-0176-0>
- <span id="r-coco"></span><Badge type="info" text="P6" />Lin, T.-Y., Maire, M., Belongie, S., Hays, J., Perona, P., Ramanan, D., Dollár, P., & Zitnick, C. L. (2014). Microsoft COCO: Common objects in context. In *Computer Vision – ECCV 2014* (Lecture Notes in Computer Science, Vol. 8693, pp. 740–755). Springer. <https://doi.org/10.1007/978-3-319-10602-1_48>
- <span id="r-geuther2019"></span><Badge type="info" text="P7" />Geuther, B. Q., Deats, S. P., Fox, K. J., Murray, S. A., Braun, R. E., White, J. K., Chesler, E. J., Lutz, C. M., & Kumar, V. (2019). Robust mouse tracking in complex environments using neural networks. *Communications Biology*, 2, 124. <https://doi.org/10.1038/s42003-019-0362-1>
- <span id="r-geuther2021"></span><Badge type="info" text="P8" />Geuther, B. Q., Peer, A., He, H., Sabnis, G., Philip, V. M., & Kumar, V. (2021). Action detection using a neural network elucidates the genetics of mouse grooming behavior. *eLife*, 10, e63207. <https://doi.org/10.7554/eLife.63207>
- <span id="r-calms"></span><Badge type="info" text="P9" />Sun, J. J., Karigo, T., Chakraborty, D., Mohanty, S. P., Wild, B., Sun, Q., Chen, C., Anderson, D. J., Perona, P., Yue, Y., & Kennedy, A. (2021). The Multi-Agent Behavior Dataset: Mouse dyadic social interactions. *Proceedings of the Neural Information Processing Systems Track on Datasets and Benchmarks*. [arXiv:2104.02710](https://arxiv.org/abs/2104.02710)
- <span id="r-mars"></span><Badge type="info" text="P10" />Segalin, C., Williams, J., Karigo, T., Hui, M., Zelikowsky, M., Sun, J. J., Perona, P., Anderson, D. J., & Kennedy, A. (2021). The Mouse Action Recognition System (MARS) software pipeline for automated analysis of social behaviors in mice. *eLife*, 10, e63720. <https://doi.org/10.7554/eLife.63720>
- <span id="r-sturman"></span><Badge type="info" text="P11" />Sturman, O., von Ziegler, L., Schläppi, C., Akyol, F., Privitera, M., Slominski, D., Grimm, C., Thieren, L., Zerbi, V., Grewe, B., & Bohacek, J. (2020). Deep learning-based behavioral analysis reaches human accuracy and is capable of outperforming commercial solutions. *Neuropsychopharmacology*, 45(11), 1942–1952. <https://doi.org/10.1038/s41386-020-0776-y>
- <span id="r-physionet"></span><Badge type="info" text="P12" />Pollard, T., Moody, B. E., Lehman, L. H., Gow, B. J., Fernandes, C., Xie, C., Johnson, A., Mark, R. G., & Heldt, T. (2026). PhysioNet as a global platform for biomedical research. *Nature Health*. <https://doi.org/10.1038/s44360-026-00096-z>

## 许可汇总 {#licences}

| 资源                                             | 许可或条款                                 | 在这里意味着什么                                                                                                                                                                                             |
|--------------------------------------------------|--------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ETH 数据集 \[D1\]、\[D2\]、\[D6\]                | CC BY 4.0                                  | 允许再利用（包括派生的标签和模型），需署名、给出许可链接并注明改动。                                                                                                                                         |
| JAX 数据集 \[D3\]、\[D4\]                        | CC BY-NC-SA 4.0                            | 须署名、仅限非商业使用、改编作品须以相同许可共享。MousePose6 有 3,500 张训练图来自这两个数据集，除非 JAX 另行授权，应把 MousePose6 视为仅限非商业使用；见[教程 1](/zh/tutorials/mousepose6#sources)。 |
| JAX 姿态模型及其训练数据（Zenodo 记录 6380163）  | “Other (Non-Commercial)”                   | 适用于该发布本身。MousePose6 使用的是 \[D3\]、\[D4\] 随附的关键点文件，而不是这个发布；那些文件本身是 CC BY-NC-SA 4.0。                                                                                      |
| CalMS21 \[D5\]                                   | CC BY 4.0                                  | 只用于外部检验。                                                                                                                                                                                             |
| PhysioNet 数据集 \[D7\]                          | Open Data Commons Attribution（ODC-By）1.0 | 需署名；只用于演示视频。                                                                                                                                                                                     |
| Ultralytics YOLO 代码和预训练权重 \[S2\]、\[S3\] | AGPL-3.0，或 Ultralytics 企业许可          | Ultralytics 声明 AGPL 条款延伸到用其代码训练的模型；闭源分发需要企业许可。                                                                                                                                   |
| coremltools \[S4\]                               | BSD-3-Clause                               | 宽松许可。                                                                                                                                                                                                   |
| DLCAnalyzer \[S5\]                               | GPL-3.0                                    | 只用于评估预试验。                                                                                                                                                                                           |
| RodentFlow 源码 \[S1\]                         | AGPL-3.0                                   | App 在应用商店分发时的许可另行设定，见支持网站的法律页面。                                                                                                                                                   |

本表汇总各方的许可声明，不构成法律意见。

## BibTeX {#bibtex}

全部条目见 <a href="/RodentFlow/tutorials/references.bib" download>references.bib</a>，键名与下面一致。

    @misc{shi2026rodentstudio,
      author = {Shi, Ziqing}, title = {RodentFlow}, year = {2026}, note = {Version [used]. AGPL-3.0},
      url = {https://github.com/seesaw-earth/RodentStudio-Support}}
    @article{jocher2026yolo26,
      author = {Jocher, Glenn and Qiu, Jing and Liu, Mengyu and Lyu, Shuai and Akyon, Fatih Cagatay and Kalfaoglu, Muhammet Esat},
      title = {Ultralytics {YOLO26}: Unified Real-Time End-to-End Vision Models}, journal = {arXiv preprint arXiv:2606.03748},
      year = {2026}, doi = {10.48550/arXiv.2606.03748}}
    @misc{vonziegler2023oft,
      author = {von Ziegler, Lukas M. and Roessler, Fabienne K. and Sturman, Oliver and Bohacek, Johannes},
      title = {Raw video and pose estimation data of top view open field mouse behavior recordings of acute and chronic stress models},
      publisher = {Zenodo}, year = {2023}, doi = {10.5281/zenodo.8186065}}
    …  (references.bib 共 24 条)

## 待解决的问题 {#open}

- 若要商业使用 MousePose6，需要 JAX 的许可，或改用不含 \[D3\]、\[D4\] 的重新训练模型。
- 训练 CylinderMousePoseV2 所用的实验室圆筒录像是否已经或将要公开。
- 内置 TST 检测器的训练数据、参数和评估。
