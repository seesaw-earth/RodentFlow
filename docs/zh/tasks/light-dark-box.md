---
title: "明暗箱"
description: "RodentFlow 的明暗箱：明箱时间、穿梭 + 探头风险评估。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 焦虑与风险评估</p>

# 明暗箱

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：45 × 30 cm，明室占 2/3</span></div>

**明箱时间、穿梭 + 探头风险评估**

明亮的大箱与黑暗的小箱通过小门相连，测 5–10 min。明箱时间和穿梭次数反映焦虑样行为。

## 模拟示例 {#example}

<figure>

![明暗箱模拟实验：轨迹与指标](/img/tasks/light-dark-box.zh.png)

<figcaption>小鼠 8.3 s 后首次进入暗室，22.4 % 的时间在明室，穿梭 53 次，从暗室向明室探头 28 次。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

身体留在暗箱、只把头伸进明箱的“探头”是典型的风险评估行为，需要把鼻尖和身体分开判断。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **明箱时间 %** | 身体中心在明箱内的时间比例。 |
| **穿梭次数** | 身体中心在明暗箱之间的穿越次数。 |
| **潜伏期** | 首次进入明箱、首次进入暗箱的时间。 |
| **探头** | 鼻尖进入明箱而身体中心和尾根仍在暗箱，持续 ≥ 0.2 s。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 标定整个箱体，再设置明箱所在侧和所占比例。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Bourin M, Hascoët M (2003) The mouse light/dark box test. Eur J Pharmacol 463:55–65. [doi:10.1016/S0014-2999(03)01274-3](https://doi.org/10.1016/S0014-2999(03)01274-3)
- Takao K, Miyakawa T (2006) Light/dark transition test for mice. J Vis Exp (1):e104. [doi:10.3791/104](https://doi.org/10.3791/104)

## 同类范式 {#related}

[旷场](./open-field.md) · [高架十字迷宫](./elevated-plus-maze.md) · [高架零迷宫](./elevated-zero-maze.md) · [新奇抑制摄食](./novelty-suppressed-feeding.md) · [视觉悬崖](./visual-cliff.md) · [埋珠实验](./marble-burying.md)
