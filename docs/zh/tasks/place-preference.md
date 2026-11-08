---
title: "位置偏好（RTPP / CPP）"
description: "RodentFlow 的位置偏好（RTPP / CPP）：配对侧时间与偏好分数 · 前后测自动配对。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# 位置偏好（RTPP / CPP）

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：50 × 25 cm，隔板在中间</span></div>

**配对侧时间与偏好分数 · 前后测自动配对**

实时位置偏好（RTPP）：动物在两侧之间自由活动，进入其中一侧即给予刺激（如光遗传），测对该侧的偏好或回避。条件性位置偏好（CPP）：前测 → 一侧与药物或奖赏配对的条件化 → 后测，比较后测与前测在配对侧的时间。

## 模拟示例 {#example}

<figure>

![位置偏好（RTPP / CPP）模拟实验：轨迹与指标](/img/tasks/place-preference.zh.png)

<figcaption>配对侧时间从前测的 436 s 增加到后测的 520 s（8 只均值）：CPP 分数 +84 s。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

所在侧按身体中心判断，可要求尾根也越过分界线，卡在门口时不会来回误计穿越；后测自动与同一只动物的前测配对，直接给出 CPP 分数。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **配对侧时间** | 身体中心在配对 / 刺激侧的时间（s、%），以及非配对侧和中间区的时间。 |
| **偏好分数与指数** | 配对侧 − 非配对侧（s）；偏好指数 = (配对 − 非配对) ÷ (配对 + 非配对)。 |
| **CPP 分数** | 后测配对侧时间 − 前测配对侧时间（同一编号自动配对）。 |
| **穿越与时间曲线** | 两侧之间的穿越次数、首次进入配对侧潜伏期、分段配对侧时间。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 标定整个装置，在参数里选择配对 / 刺激侧和分界位置。
2. 两侧之间有中间区时，在参数里打开“中间区”并设置宽度。
3. CPP：前测和后测分别建立分析，动物编号相同即自动配对。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Tzschentke TM (2007) Measuring reward with the conditioned place preference (CPP) paradigm: update of the last decade. Addict Biol 12:227–462. [doi:10.1111/j.1369-1600.2007.00070.x](https://doi.org/10.1111/j.1369-1600.2007.00070.x)
- Stamatakis AM, Stuber GD (2012) Activation of lateral habenula inputs to the ventral midbrain promotes behavioral avoidance. Nat Neurosci 15:1105–1107. [doi:10.1038/nn.3145](https://doi.org/10.1038/nn.3145)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Barnes 迷宫](./barnes-maze.md) · [Morris 水迷宫](./water-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [Step-down 抑制性回避](./step-down.md) · [Y 迷宫自发交替](./y-maze.md) · [T 迷宫 · VTE](./t-maze.md) · [恐惧条件化](./fear-conditioning.md) · [Looming 逃跑](./looming-escape.md) · [平台介导回避](./platform-avoidance.md)
