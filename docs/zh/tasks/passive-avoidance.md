---
title: "被动回避（穿梭箱）"
description: "RodentFlow 的被动回避（穿梭箱）：进入暗室潜伏期（截尾）· 反向探头风险评估。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# 被动回避（穿梭箱）

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：40 × 20 cm，两室等大；截止 300 秒</span></div>

**进入暗室潜伏期（截尾）· 反向探头风险评估**

明暗两室之间有门。训练时小鼠一进入暗室就给足底电击；间隔一段时间（常为 24 h）后再放回明室，测进入暗室的潜伏期，截止时间常为 300 s。潜伏期越长，表示越记得暗室与电击的关联。

## 模拟示例 {#example}

<figure>

![被动回避（穿梭箱）模拟实验：轨迹与指标](/img/tasks/passive-avoidance.zh.png)

<figcaption>训练时进入暗室的中位潜伏期为 22 s。测试日 10 只中有 6 只到 300 s 截止时仍在明室；它们作为删失值保留，而不是被剔除。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

身体留在明室、只把鼻尖伸进暗室再退回，是测试期典型的风险评估，只有把鼻尖和身体分开判断才能计数。进入暗室可按身体中心、身体中心 + 尾根（近似四爪进入）或鼻尖判定。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **进入暗室潜伏期** | 按进入规则首次进入暗室的时间；截止前没有进入时记为截止时间并标为未进入（右删失），组间页对它做生存分析。 |
| **进入暗室** | 截止前是否进入（0 / 100），组平均即进入的比例。 |
| **暗室时间与进入次数** | 按同一进入规则统计。 |
| **反向探头** | 鼻尖伸进暗室而身体中心和尾根仍在明室，持续 ≥ 设定时长：次数、进入前次数、首次探头潜伏期。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 标定整个箱体，再设置明室所在侧和所占比例。
2. 把“分析起点”设为放入明室（或开门）的时刻，“分析时长”设为截止时间（常用 300 s）
3. 训练和测试分别建立分析；组间页对潜伏期自动给出生存分析。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Jarvik ME, Kopp R (1967) An improved one-trial passive avoidance learning situation. Psychol Rep 21:221–224.
- Kaplan EL, Meier P (1958) Nonparametric estimation from incomplete observations. J Am Stat Assoc 53:457–481. [doi:10.1080/01621459.1958.10501452](https://doi.org/10.1080/01621459.1958.10501452)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Barnes 迷宫](./barnes-maze.md) · [Morris 水迷宫](./water-maze.md) · [Step-down 抑制性回避](./step-down.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [Y 迷宫自发交替](./y-maze.md) · [T 迷宫 · VTE](./t-maze.md) · [恐惧条件化](./fear-conditioning.md) · [Looming 逃跑](./looming-escape.md) · [平台介导回避](./platform-avoidance.md)
