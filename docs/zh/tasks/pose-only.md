---
title: "仅导出姿态"
description: "RodentFlow 的仅导出姿态：逐帧 6 个关键点 + 运动学 · 自定义分析。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 通用</p>

# 仅导出姿态

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：任意场地</span></div>

**逐帧 6 个关键点 + 运动学 · 自定义分析**

不做范式分析，只输出逐帧关键点和派生运动学（速度、头朝向、身体轴向等），用于自己的分析流程（如 Keypoint-MoSeq、B-SOiD、SimBA）。

## 模拟示例 {#example}

<figure>

![仅导出姿态模拟实验：轨迹与指标](/img/tasks/pose-only.zh.png)

<figcaption>每帧 6 个关键点，各带置信度；导出时再加上平滑后的坐标、速度、头朝向、身体朝向、头–身夹角和体长。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

保留原始逐帧关键点（像素坐标、置信度），同时附带标定后的厘米坐标和派生特征。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **逐帧关键点** | 6 个关键点的像素坐标与置信度（与旧版 CSV 格式一致）。 |
| **运动学** | 平滑后的坐标、速度、头朝向、身体轴向、头–身夹角、身体长度。 |
| **质量** | 检出率、各关键点平均置信度。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 不标定时坐标为像素；标定后额外输出厘米坐标。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Mathis A et al. (2018) DeepLabCut. Nat Neurosci 21:1281–1289. [doi:10.1038/s41593-018-0209-y](https://doi.org/10.1038/s41593-018-0209-y)
- Pereira TD et al. (2022) SLEAP: a deep learning system for multi-animal pose tracking. Nat Methods 19:486–495. [doi:10.1038/s41592-022-01426-1](https://doi.org/10.1038/s41592-022-01426-1)
- Weinreb C et al. (2024) Keypoint-MoSeq: parsing behavior by linking point tracking to pose dynamics. Nat Methods 21:1329–1339. [doi:10.1038/s41592-024-02318-2](https://doi.org/10.1038/s41592-024-02318-2)
