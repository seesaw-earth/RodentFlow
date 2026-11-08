---
title: "Y 迷宫自发交替"
description: "RodentFlow 的Y 迷宫自发交替：工作记忆 · 交替率与探头未进入。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# Y 迷宫自发交替

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：臂长 35 cm、宽 5 cm</span></div>

**工作记忆 · 交替率与探头未进入**

三条臂互成 120°，动物自由探索约 8 min。连续三次进入三条不同的臂记为一次交替，交替率 = 交替次数 ÷（总进入次数 − 2）。

## 模拟示例 {#example}

<figure>

![Y 迷宫自发交替模拟实验：轨迹与指标](/img/tasks/y-maze.zh.png)

<figcaption>30 次进臂中，28 组相邻三次进臂里有 19 组是三个不同的臂：自发交替 67.9 %。另有 2 次鼻尖进了臂、身体却转回。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

标准规定四爪都进入臂才算一次进入。RodentFlow 默认要求身体中心和尾根都在臂内（近似四爪进入），并单独统计“只探头、未进入”。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **交替率** | 连续三次进入三条不同臂的次数 ÷（总进入次数 − 2）。 |
| **进入次数** | 默认身体中心和尾根都在臂内才算一次进入。 |
| **探头未进入** | 鼻尖进入某臂但身体没有进入就退回。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. J 为三臂交汇中心，A / B / C 为三个臂末端。
2. 输入臂长和臂宽（cm）

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Hughes RN (2004) The value of spontaneous alternation behavior (SAB) as a test of retention in pharmacological investigations of memory. Neurosci Biobehav Rev 28:497–505. [doi:10.1016/j.neubiorev.2004.06.006](https://doi.org/10.1016/j.neubiorev.2004.06.006)
- Kraeuter AK, Guest PC, Sarnyai Z (2019) The Y-maze for assessment of spatial working and reference memory in mice. Methods Mol Biol 1916:105–111. [doi:10.1007/978-1-4939-8994-2_10](https://doi.org/10.1007/978-1-4939-8994-2_10)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Barnes 迷宫](./barnes-maze.md) · [Morris 水迷宫](./water-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [Step-down 抑制性回避](./step-down.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [T 迷宫 · VTE](./t-maze.md) · [恐惧条件化](./fear-conditioning.md) · [Looming 逃跑](./looming-escape.md) · [平台介导回避](./platform-avoidance.md)
