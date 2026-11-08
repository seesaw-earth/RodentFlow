---
title: "Barnes 迷宫"
description: "RodentFlow 的Barnes 迷宫：以鼻尖探洞计错误数 · 潜伏期与路径。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# Barnes 迷宫

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：92 cm 平台，20 个洞</span></div>

**以鼻尖探洞计错误数 · 潜伏期与路径**

圆形平台边缘有一圈洞，只有目标洞下有逃逸箱。动物借助墙上的空间线索学习目标位置。读数为找到目标洞的潜伏期、错误数和路径长度；探索测试中看目标象限时间。

## 模拟示例 {#example}

<figure>

![Barnes 迷宫模拟实验：轨迹与指标](/img/tasks/barnes-maze.zh.png)

<figcaption>到达逃生洞的平均潜伏期从第 1 天的 114 s 降到第 4 天的 12 s，找到之前的错误次数从 9 降到 1.3。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

Barnes 迷宫的“错误”定义是把鼻子探进非目标洞，这是鼻尖行为，质心追踪无法计数。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **首次潜伏期** | 鼻尖首次探入目标洞的时间。 |
| **错误数** | 鼻尖探入非目标洞的次数：首次找到目标前的为首次错误，全程的为总错误。 |
| **路径长度** | 首次找到目标洞之前身体中心的移动距离。 |
| **目标象限** | 以目标洞为中心 ±45° 扇区内的时间比例（探索测试）。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 拖动 C（中心）和 R（边缘）标定平台。
2. 把 T 手柄拖到目标洞中心；其余洞按数量均匀排列。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Barnes CA (1979) Memory deficits associated with senescence: a neurophysiological and behavioral study in the rat. J Comp Physiol Psychol 93:74–104. [doi:10.1037/h0077579](https://doi.org/10.1037/h0077579)
- Pitts MW (2018) Barnes maze procedure for spatial learning and memory in mice. Bio-protocol 8:e2744. [doi:10.21769/BioProtoc.2744](https://doi.org/10.21769/BioProtoc.2744)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Morris 水迷宫](./water-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [Step-down 抑制性回避](./step-down.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [Y 迷宫自发交替](./y-maze.md) · [T 迷宫 · VTE](./t-maze.md) · [恐惧条件化](./fear-conditioning.md) · [Looming 逃跑](./looming-escape.md) · [平台介导回避](./platform-avoidance.md)
