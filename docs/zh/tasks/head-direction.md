---
title: "头朝向"
description: "RodentFlow 的头朝向：HD 细胞记录配套 · 头朝向占据与角速度。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 空间导航与神经记录</p>

# 头朝向

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：50 × 50 cm</span></div>

**HD 细胞记录配套 · 头朝向占据与角速度**

记录头朝向细胞（ADN、后下托、压后皮层等）时，需要每一帧动物头部在环境中的朝向，以及每个方向上的停留时间（占据），用来归一化调谐曲线；角速度（AHV）用于分析 AHV 细胞和调谐的速度依赖性。

## 模拟示例 {#example}

<figure>

![头朝向模拟实验：轨迹与指标](/img/tasks/head-direction.zh.png)

<figcaption>每个 6° 区间都停留了至少 1 秒（覆盖 100 %），停留分布的平均向量长度为 0.04：各个方向几乎均匀采样，正好满足调谐曲线归一化的需要。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

传统方法要在头上装两个 LED。RodentFlow 用两耳中点 → 鼻尖的向量估计头朝向（鼻尖缺失时用颈部 → 鼻尖），不需要标记物，并输出带时间戳的逐帧 HD 和 AHV，可直接与电生理或钙成像数据对齐。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **头朝向 HD** | 两耳中点 → 鼻尖向量的方向；0° = 画面右方（或提示卡方向），逆时针为正。 |
| **HD 占据** | 每 6° 一格的停留时间，用于归一化调谐曲线。 |
| **方向覆盖度** | 停留时间 ≥ 1 s 的方向格所占比例。 |
| **占据平均向量长度** | HD 占据分布的平均向量长度，越接近 0 越均匀；偏大时调谐曲线容易受采样偏差影响。 |
| **角速度 AHV** | 头朝向对时间的导数（°/s），以及顺 / 逆时针转头时间。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 可选：把 Q 手柄拖到墙上的提示卡，作为参考方向。
2. 记录系统与视频的同步偏移需自行对齐（导出 CSV 含逐帧时间戳）

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Taube JS, Muller RU, Ranck JB (1990) Head-direction cells recorded from the postsubiculum in freely moving rats. I. J Neurosci 10:420–435. [doi:10.1523/JNEUROSCI.10-02-00420.1990](https://doi.org/10.1523/JNEUROSCI.10-02-00420.1990)
- Peyrache A, Lacroix MM, Petersen PC, Buzsáki G (2015) Internally organized mechanisms of the head direction sense. Nat Neurosci 18:569–575. [doi:10.1038/nn.3968](https://doi.org/10.1038/nn.3968)
- Mathis A et al. (2018) DeepLabCut: markerless pose estimation of user-defined body parts with deep learning. Nat Neurosci 21:1281–1289. [doi:10.1038/s41593-018-0209-y](https://doi.org/10.1038/s41593-018-0209-y)

## 同类范式 {#related}

[空间探索 · 位置细胞](./spatial-exploration.md)
