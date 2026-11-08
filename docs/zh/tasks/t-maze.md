---
title: "T 迷宫 · VTE"
description: "RodentFlow 的T 迷宫 · VTE：选择点头部扫视（替代性试错）。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# T 迷宫 · VTE

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：臂长 30 cm、宽 8 cm</span></div>

**选择点头部扫视（替代性试错）**

动物在选择点停下，头部在两侧之间来回摆动，称为替代性试错（VTE），反映决策时的权衡。经典量化方法是通过选择点时朝向的累计绝对变化 IdPhi，并在每次会话内做 z 标准化。

## 模拟示例 {#example}

<figure>

![T 迷宫 · VTE模拟实验：轨迹与指标](/img/tasks/t-maze.zh.png)

<figcaption>16 次经过中有 4 次 zIdPhi ≥ 0.5，判为 VTE；它们的平均 IdPhi 为 483°，直接通过时为 144°。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

VTE 本质是头部扫视。RodentFlow 直接用头朝向计算 IdPhi，同时给出基于运动轨迹方向的 IdPhi 作为对照，并统计左右选择与交替。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **IdPhi** | 每次从起始臂经过选择点进入左 / 右臂期间，头朝向变化绝对值的累计（°）。 |
| **zIdPhi 与 VTE** | 会话内 z 标准化；zIdPhi ≥ 0.5 记为 VTE（阈值可调）。 |
| **选择** | 左 / 右选择、连续选择的交替率、选择点停留时间。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. J 为选择点，S 为起始臂末端，L / R 为左右臂末端。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Redish AD (2016) Vicarious trial and error. Nat Rev Neurosci 17:147–159. [doi:10.1038/nrn.2015.30](https://doi.org/10.1038/nrn.2015.30)
- Deacon RMJ, Rawlins JNP (2006) T-maze alternation in the rodent. Nat Protoc 1:7–12. [doi:10.1038/nprot.2006.2](https://doi.org/10.1038/nprot.2006.2)
- Gabriel CJ et al. (2022) BehaviorDEPOT (VTE module). eLife 11:e74314. [doi:10.7554/eLife.74314](https://doi.org/10.7554/eLife.74314)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Barnes 迷宫](./barnes-maze.md) · [Morris 水迷宫](./water-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [Step-down 抑制性回避](./step-down.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [Y 迷宫自发交替](./y-maze.md) · [恐惧条件化](./fear-conditioning.md) · [Looming 逃跑](./looming-escape.md) · [平台介导回避](./platform-avoidance.md)
