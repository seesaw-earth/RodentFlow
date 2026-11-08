---
title: "新物体识别"
description: "RodentFlow 的新物体识别：鼻尖距离 + 朝向判定探索 · 辨别指数。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# 新物体识别

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：40 × 40 cm，物体半径 2.5 cm</span></div>

**鼻尖距离 + 朝向判定探索 · 辨别指数**

训练期探索两个相同物体，间隔一段时间后把其中一个换成新物体。啮齿类天生偏好新物体，辨别指数 DI 反映识别记忆。移动物体位置即为物体位置记忆（OLM）。

## 模拟示例 {#example}

<figure>

![新物体识别模拟实验：轨迹与指标](/img/tasks/novel-object-recognition.zh.png)

<figcaption>10 分钟内小鼠探索新物体 55.2 s、熟悉物体 22.9 s：DI 0.41，RI 70.7 %。累计探索在 123 s 时达到 20 s，此时 DI 为 0.38。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

公认的“探索”定义是鼻尖距物体 ≤ 2 cm 且头朝向物体，爬到物体上或背对物体坐着都不算。质心半径法会把路过和坐在旁边也算进去。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **探索时间** | 鼻尖在物体外缘 2 cm 以内、头朝向物体（±45°），且身体中心不在物体上。 |
| **辨别指数 DI** | (新 − 旧) ÷ (新 + 旧)；训练阶段为 (B − A) ÷ (B + A)，用来检查位置偏好。 |
| **识别指数 RI** | 新 ÷ (新 + 旧) × 100%。 |
| **20 s 标准** | 累计探索达到 20 s 的时间，以及达到时的 DI。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 把 A / B 手柄拖到两个物体中心，设置物体半径。
2. 测试阶段选择哪个是新物体。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Ennaceur A, Delacour J (1988) A new one-trial test for neurobiological studies of memory in rats. 1: Behavioral data. Behav Brain Res 31:47–59. [doi:10.1016/0166-4328(88)90157-X](https://doi.org/10.1016/0166-4328(88)90157-X)
- Leger M et al. (2013) Object recognition test in mice. Nat Protoc 8:2531–2537. [doi:10.1038/nprot.2013.155](https://doi.org/10.1038/nprot.2013.155)
- Gabriel CJ et al. (2022) BehaviorDEPOT is a simple, flexible tool for automated behavioral detection based on markerless pose tracking. eLife 11:e74314. [doi:10.7554/eLife.74314](https://doi.org/10.7554/eLife.74314)

## 同类范式 {#related}

[Barnes 迷宫](./barnes-maze.md) · [Morris 水迷宫](./water-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [Step-down 抑制性回避](./step-down.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [Y 迷宫自发交替](./y-maze.md) · [T 迷宫 · VTE](./t-maze.md) · [恐惧条件化](./fear-conditioning.md) · [Looming 逃跑](./looming-escape.md) · [平台介导回避](./platform-avoidance.md)
