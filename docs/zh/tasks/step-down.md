---
title: "Step-down 抑制性回避"
description: "RodentFlow 的Step-down 抑制性回避：下台潜伏期（截尾）· 平台上僵直 · 边缘探头。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# Step-down 抑制性回避

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：25 × 25 cm 箱，7 × 7 cm 平台</span></div>

**下台潜伏期（截尾）· 平台上僵直 · 边缘探头**

小鼠被放在电网中央的小平台上。训练时四爪都踏到电网即给足底电击；间隔一段时间（常为 24 h）后再放回平台，测下台潜伏期，截止时间常为 180 或 300 s。潜伏期越长，表示越记得下台与电击的关联；测试 / 训练潜伏期之比可作为记忆保持指数。

## 模拟示例 {#example}

<figure>

![Step-down 抑制性回避模拟实验：轨迹与指标](/img/tasks/step-down.zh.png)

<figcaption>训练时中位跳下潜伏期为 9 s；测试时 10 只中有 6 只在平台上待到 180 s 截止。示例测试中有 7 次平台边缘探头。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

“下台”要四爪落到电网上，RodentFlow 默认用身体中心和尾根都离开平台来近似；身体还在平台上、只把鼻尖伸出边缘的探头单独计数，作为下台前的风险评估。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **下台潜伏期** | 按下台规则首次离开平台的时间；截止前没有下台时记为截止时间并标为未下台（右删失），组间页对它做生存分析。测试阶段另给测试 / 训练潜伏期之比（同一编号自动配对）。 |
| **下台** | 截止前是否下台（0 / 100），以及下台次数和平台上的时间。 |
| **平台上僵直** | 在平台上时的僵直比例（同恐惧条件化的定义）。 |
| **边缘探头** | 身体中心和尾根仍在平台上、鼻尖伸出平台边缘，持续 ≥ 设定时长：次数、下台前次数、首次探头潜伏期。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 标定整个箱底，把 P 手柄拖到平台中心，在参数里输入平台的宽和高。
2. “分析起点”设为把小鼠放上平台的时刻，“分析时长”设为截止时间（常用 180 或 300 s）
3. 训练和测试分别建立分析，编号相同时测试会自动和训练配对。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Kameyama T, Nabeshima T, Kozawa T (1986) Step-down-type passive avoidance- and escape-learning method: suitability for experimental amnesia models. J Pharmacol Methods 16:39–52.
- Kaplan EL, Meier P (1958) Nonparametric estimation from incomplete observations. J Am Stat Assoc 53:457–481. [doi:10.1080/01621459.1958.10501452](https://doi.org/10.1080/01621459.1958.10501452)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Barnes 迷宫](./barnes-maze.md) · [Morris 水迷宫](./water-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [Y 迷宫自发交替](./y-maze.md) · [T 迷宫 · VTE](./t-maze.md) · [恐惧条件化](./fear-conditioning.md) · [Looming 逃跑](./looming-escape.md) · [平台介导回避](./platform-avoidance.md)
