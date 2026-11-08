---
title: "视觉悬崖"
description: "RodentFlow 的视觉悬崖：首次选择 · 深侧时间 · 边缘探头。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 焦虑与风险评估</p>

# 视觉悬崖

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：60 × 40 cm，中间板占长度的 20 %</span></div>

**首次选择 · 深侧时间 · 边缘探头**

透明玻璃（或透明底）盖住整个场地：一侧图案紧贴玻璃下方（浅侧），另一侧图案远在下方（深侧），看起来像一个落差。小鼠从中间的平台或中性区出发，有深度知觉的小鼠多选浅侧、少去深侧。表型筛查版（JAX）在透明底的旷场里录 20 min，另报前 4 min。读数为首次选择、深 / 浅侧时间、进入深侧的潜伏期和边缘探头。

## 模拟示例 {#example}

<figure>

![视觉悬崖模拟实验：轨迹与指标](/img/tasks/visual-cliff.zh.png)

<figcaption>首次选择浅侧。10 分钟中 58.9 % 的时间在浅侧，34.4 % 在中间板，6.7 % 在深侧；向深侧边缘探头 15 次。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

所在侧按身体中心判断，可要求尾根也越过分界（卡在中间板边上时不会来回误计）。身体还在中央或浅侧、只把鼻尖伸向深侧的“边缘探头”是典型的风险评估，只有把鼻尖和身体分开判断才能计数。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **首次选择** | 离开中性区后先进入的一侧（深侧 = 100，浅侧 = 0；组平均即先选深侧的比例，组间页另给 Fisher 精确检验），以及离开中性区的潜伏期。 |
| **各侧时间** | 深侧、浅侧和中性区的时间（%）与路程；前一段时间（默认 4 min）另算。 |
| **进入深侧** | 进入次数和首次进入潜伏期；没有进入时记为截止时间并标为未进入（右删失），组间页给生存分析。 |
| **边缘探头** | 鼻尖伸进深侧，而身体中心和尾根仍在中性区或浅侧，持续 ≥ 设定时长：次数、时间、首次潜伏期。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 标定玻璃面（或透明底）四角，输入内部尺寸。
2. 在参数里选择深侧，设置中间板（中性区）的位置和宽度。
3. 把小鼠放在中间板上；“分析起点”设为放下的时刻。
4. 棋盘格背景和玻璃反光可能影响识别：先看检出率和回看。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Fox MW (1965) The visual cliff test for the study of visual depth perception in the mouse. Anim Behav 13:232–233. [doi:10.1016/0003-3472(65)90040-0](https://doi.org/10.1016/0003-3472(65)90040-0)
- Gibson EJ, Walk RD (1960) The \u{201C}visual cliff\u{201D}. Sci Am 202:64–71. [doi:10.1038/scientificamerican0460-64](https://doi.org/10.1038/scientificamerican0460-64)
- Kaplan EL, Meier P (1958) Nonparametric estimation from incomplete observations. J Am Stat Assoc 53:457–481. [doi:10.1080/01621459.1958.10501452](https://doi.org/10.1080/01621459.1958.10501452)

## 同类范式 {#related}

[旷场](./open-field.md) · [高架十字迷宫](./elevated-plus-maze.md) · [高架零迷宫](./elevated-zero-maze.md) · [明暗箱](./light-dark-box.md) · [新奇抑制摄食](./novelty-suppressed-feeding.md) · [埋珠实验](./marble-burying.md)
