---
title: "旷场"
description: "RodentFlow 的旷场：运动与焦虑样行为 · 中央区、转圈、静止。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 焦虑与风险评估</p>

# 旷场

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：40 × 40 cm</span></div>

**运动与焦虑样行为 · 中央区、转圈、静止**

最常用的自发活动与焦虑样行为测试：动物在方形或圆形场地中自由探索 5–30 min，读数包括总路程、中央区时间和进入次数。

## 模拟示例 {#example}

<figure>

![旷场模拟实验：轨迹与指标](/img/tasks/open-field.zh.png)

<figcaption>这段 10 分钟的模拟实验中，小鼠走了 45.8 m，26.9 % 的时间在中央区，进入中央区 67 次。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

用身体中心代替质心（不受尾巴影响），另外还能得到按身体轴向计的转圈数、静止时间和身体伸展程度。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **总路程与速度** | 身体中心的移动距离（m）和平均速度。 |
| **中央区** | 中央区时间 %、进入次数、首次进入潜伏期。 |
| **静止** | 关键点运动 < 1 cm/s 持续 ≥ 1 s 的时间。 |
| **转圈** | 按身体轴向累计的完整顺时针 / 逆时针转圈数。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 中央区默认为场地边长的 50%，可在参数中调整。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Prut L, Belzung C (2003) The open field as a paradigm to measure the effects of drugs on anxiety-like behaviors: a review. Eur J Pharmacol 463:3–33. [doi:10.1016/S0014-2999(03)01272-X](https://doi.org/10.1016/S0014-2999(03)01272-X)
- Seibenhener ML, Wooten MC (2015) Use of the open field maze to measure locomotor and anxiety-like behavior in mice. J Vis Exp 96:e52434. [doi:10.3791/52434](https://doi.org/10.3791/52434)

## 同类范式 {#related}

[高架十字迷宫](./elevated-plus-maze.md) · [高架零迷宫](./elevated-zero-maze.md) · [明暗箱](./light-dark-box.md) · [新奇抑制摄食](./novelty-suppressed-feeding.md) · [视觉悬崖](./visual-cliff.md) · [埋珠实验](./marble-burying.md)
