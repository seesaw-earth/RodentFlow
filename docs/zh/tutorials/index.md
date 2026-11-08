# 模型教程

RodentFlow 里的姿态模型是怎么做出来的：视频和标签从哪里来，如何清洗、划分、训练和测试，如何变成 Core ML 模型包，以及怎样正确引用每一个来源。教程依据原始 notebook、模型元数据和 App 源码编写。

模型文件本身、校验值和许可说明见 [Core ML 模型](../models.md)。

## 模型及其来历 {#models}

RodentFlow 的所有分析都在设备上完成。RodentFlow 2.1 内置五个神经网络模型包；质心追踪不用任何模型。四个姿态模型的输入、输出格式和六个关键点都相同，App 按动物数和*小鼠毛色*选用其中一个（[每段视频用哪个模型](../models.md#coat)）。

| | [MousePose6](./mousepose6.md) | [WhiteMousePose6](./white-mouse.md) | [MousePose6-DyadBW](./dyad-bw.md) | [MouseDetector](./tst-detector.md) |
|---|---|---|---|---|
| **识别内容** | 俯视画面中一只深色鼠的六个关键点 | 一只白鼠，同样的六个关键点 | 两只鼠，一黑一白 | 在多格悬尾视频中框出每只小鼠 |
| **训练数据** | ETH Zurich（Zenodo，CC BY 4.0）与 JAX JABS（Harvard Dataverse）的视频及随附姿态文件；来自 52 段视频的 8,840 帧 | DooM 数据集 9 个实验室的白鼠；7,586 张训练图，其中 818 帧由更大的模型标注 | DooM 10 个实验室的一黑一白和两只深色鼠组合；25,071 张训练图；另留出一个实验室 | 据 App 说明为单一装置的合成图像；数据集与 notebook 未提供，无法核查 |
| **标签** | DeepLabCut 与 JAX 网络的预测，经过过滤；不是人工标注 | 各实验室的轨迹加上 YOLO26m 教师模型，经过过滤；颈部和身体中心按规则推算 | 各实验室的轨迹；颈部和身体中心按规则推算 | 无记录 |
| **模型** | YOLO26n-pose，960 px，250 万参数 | YOLO26n-pose，960 px，250 万参数 | YOLO26s-pose，960 px，980 万参数 | YOLO11n 检测，320 px |
| **测试** | 1,350 帧：检出 94.6 % 的小鼠；其中 96.1 % 的关键点与参照标签相差不到 0.1 个体长 | 留出视频中的 740 只白鼠：检出 99.3 %；95.8 % 的关键点与轨迹相差不到 0.1 个体长 | 一黑一白留出视频：深色鼠和白鼠各找到 98.7 %；没见过的实验室：深色鼠 88.1 %，白鼠 96.2 % | 无记录 |

第五个模型包 **MousePose6-Dyad**（两只深色鼠）的介绍见[关于论文稿的博客文章](../blog/training-on-existing-tracks.md#dyad)；它的 notebook 还没有整理成教程。

**CylinderMousePoseV2**（[教程 2](./cylinder-v2.md)）已不属于 RodentFlow：RodentFlow 2.0 去掉了肢体流程，这些流程现在在 [RodentLimb](https://seesaw-earth.github.io/RodentLimb/zh/models/) 中。教程 2 保留下来，作为它如何制作的记录。

[教程 4](./app-integration.md) 讲所有姿态模型共用的导出与解码步骤。

## 这些数字说明了什么，没说明什么

- **MousePose6 的训练和测试都以模型生成的标签为参照。**参照点是各数据集随附的 DeepLabCut 和 JAX 姿态网络预测（经过过滤）。测试分数衡量的是与这些预测的一致程度，而不是与人工标注者的一致程度。
- **WhiteMousePose6 和 MousePose6-DyadBW 同样以轨迹为参照训练和测试**，轨迹来自 DooM 的各实验室。WhiteMousePose6 只在也提供了训练视频的实验室上测试。MousePose6-DyadBW 还在一个没见过的实验室上测试：在那里它找到 88.1 % 的深色鼠，低于方案要求的 95 %；两只深色鼠的模型在那里找到 98.9 %。
- **CylinderMousePoseV2 在 80 帧人工标注上测试，**来自同一实验室装置中 4 个留出的录像组。测试集很小，置信区间见教程 2。
- **训练数据以外的检验结果有好有坏。**在 CalMS21 两鼠互动的家笼视频上，MousePose6 只在 11.8 % 的帧里找到黑色 resident，白色 intruder 只有 0.3 %。在 5 段高架十字迷宫视频的预试验中，区域停留时间与基于 DeepLabCut 的参照吻合良好，而进臂次数、移动距离和伸展探察姿势（SAP）则不吻合。
- **检测器的训练数据和准确度没有记录**，在我们审阅的材料中找不到。
- **以上都不等于验证了 RodentFlow 的行为指标。**用于科研时，仍需在自己的视频上与人工评分比较。

::: warning
**MousePose6 有两个训练数据集限制商业使用。**两个 ETH Zurich 数据集为 CC BY 4.0，但 Harvard Dataverse 上的两个 JAX 数据集为 CC BY-NC-SA 4.0（非商业、相同方式共享），这限制了 MousePose6 的商业使用；见[教程 1](./mousepose6.md#sources)。Ultralytics YOLO 为 AGPL-3.0，除非使用企业许可。见[许可汇总表](./citations.md#licences)。
:::

## 按顺序读，或直接跳到需要的部分

1. **[用四个公开数据集训练 MousePose6](./mousepose6.md)**：关键点统一、左右校正、抽帧、按视频划分、训练、评估、外部检验。
2. **[把 DeepLabCut 蒸馏成 CylinderMousePoseV2](./cylinder-v2.md)**：轨迹清洗、姿态聚类、一致性过滤、两阶段训练、配对比较。
3. **[悬尾实验小鼠检测器](./tst-detector.md)**：模型包元数据记录了什么、缺了什么，以及哪些追踪方法不用神经网络。
4. **[从训练好的模型到 App 里的 Core ML](./app-integration.md)**：导出参数、元数据检查、Vision 加边缩放、用 Swift 解码输出张量。
5. **[白鼠模型 WhiteMousePose6](./white-mouse.md)**：从四个追踪点到六个点、放大和背景裁剪、用更大的模型标注更多帧、与教师模型比较。
6. **[一黑一白双鼠模型 MousePose6-DyadBW](./dyad-bw.md)**：第 1 版漏掉了什么、标注点必须在鼠身上、训练前定下的问题、三个模型的比较。
7. **[如何引用](./citations.md)**：每个模型该引用什么、完整参考文献、BibTeX、许可汇总、方法部分示例。全部参考文献也汇总在一个 BibTeX 文件里：<a href="/RodentFlow/tutorials/references.bib" download>references.bib</a>。

## 本教程的依据

页面上的每个数字都来自以下三处之一，每页都会注明出处：

1. 构建数据集、训练、评估和导出模型时使用的原始 Google Colab notebook（例如 `1012_MousePose_Dataset_Builder_v1`、`MousePose_YOLO_Train_v1`、`MousePose_iOS_Export_v1`、`Cylinder_YOLO26_Pose_Training`、`Cylinder_YOLO26_v2_DLC_Distill`、`YOLO_on_CalMS21_v1`、`RodentPose_Colab`、`WhiteMouse_n960_6kp_Train`、`DyadBW_YOLO26_Train_v2`）。
2. 每个随 App 发布的 `.mlpackage` 内部的元数据（训练命令、库版本、日期、输入输出形状）。
3. App 源码：[RodentStudio-Support 仓库](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source)中公开的版本（模型加载、解码以及各模型对应的实验流程）；按毛色选用的模型则依据 RodentFlow 2.1 的源码（`Shared/PoseEngine/PoseModels.swift`）。

同一批文件中还有若干 App 并未内置的模型 notebook（平衡木、RotaWheel、理毛片段、CalMS21 提示词实验、RodentFlow 1.x 复分析），本教程不涉及。

数据集记录、许可和文献信息于 2026 年 10 月 20 日对照 Zenodo、DataCite、Crossref 和出版商页面核对。DooM 的记录于 2026 年 11 月 7 日查询。无法确认的条目标为 <Badge type="warning" text="待核对" />。

如需引用本教程，请使用教程仓库中的 [CITATION.cff](https://github.com/seesaw-earth/RodentStudio-Tutorials/blob/main/CITATION.cff)。
