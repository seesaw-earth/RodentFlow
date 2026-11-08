---
title: "高架零迷宫"
description: "RodentFlow 的高架零迷宫：开放段时间 + 内外缘头探 + 闭合段探出与伸展评估。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 焦虑与风险评估</p>

# 高架零迷宫

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：外径 60 cm，跑道宽 5 cm；5 分钟</span></div>

**开放段时间 + 内外缘头探 + 闭合段探出与伸展评估**

环形高架平台分成四段等长的区段：两段相对的闭合段有墙，两段开放段没有墙。没有高架十字迷宫的中央区，动物可以不间断地绕圈探索，常测 5 min。开放段时间比例和头探越少、闭合段内的伸展评估越多，焦虑样行为越强；重复测试时比高架十字迷宫更稳定。

## 模拟示例 {#example}

<figure>

![高架零迷宫模拟实验：轨迹与指标](/img/tasks/elevated-zero-maze.zh.png)

<figcaption>5 分钟中有 47.9 % 的时间在开放段，外缘头探 7 次，内缘 4 次。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

所在段按身体中心的方位角判断，可要求尾根也进入（近似四爪进入）。头探要求鼻尖越出跑道内缘或外缘而身体留在开放段；闭合段探出是身体和尾根留在闭合段、只把鼻尖伸进开放段；伸展评估姿势用鼻尖–尾根长度。这些都要把鼻尖和身体分开判断，质心法做不到。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **开放段时间 %** | 开放段时间占分析时间的比例；进入按身体中心（默认加尾根）判断。 |
| **进入与转换** | 开放段 / 闭合段进入次数、开放段进入比例、首次进入开放段潜伏期、开闭段转换次数。 |
| **头探** | 身体中心在开放段，鼻尖越出跑道内缘或外缘 ≥ 1 cm，持续 ≥ 0.2 s；内缘、外缘分别计数。 |
| **闭合段探出** | 身体中心和尾根在闭合段，鼻尖越过边界进入开放段，持续 ≥ 0.2 s，随后退回（紧接着进入开放段的不计）。 |
| **伸展评估姿势 SAP** | 身体长度 ≥ 中位数的 1.2 倍且身体中心速度 < 5 cm/s，持续 ≥ 0.5 s；另给在闭合段朝向开放段的次数。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 拖动 C（中心）和 R（外缘）标定圆环，输入外径和跑道宽度。
2. 把 O 手柄拖到任一开放段的中点，确定四段的方向。
3. 放入时把小鼠放在开闭段交界处、面朝闭合段；“分析时长”常用 300 s。
4. 四周留出空间，让头探时鼻尖仍在画面内。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Shepherd JK, Grewal SS, Fletcher A, Bill DJ, Dourish CT (1994) Behavioural and pharmacological characterisation of the elevated \u{201C}zero-maze\u{201D} as an animal model of anxiety. Psychopharmacology 116:56–64. [doi:10.1007/BF02244871](https://doi.org/10.1007/BF02244871)
- Braun AA, Skelton MR, Vorhees CV, Williams MT (2011) Comparison of the elevated plus and elevated zero mazes in treated and untreated male Sprague-Dawley rats: effects of anxiolytic and anxiogenic agents. Pharmacol Biochem Behav 97:406–415. [doi:10.1016/j.pbb.2010.09.013](https://doi.org/10.1016/j.pbb.2010.09.013)
- Tucker LB, McCabe JT (2017) Behavior of male and female C57BL/6J mice is more consistent with repeated trials in the elevated zero maze than in the elevated plus maze. Front Behav Neurosci 11:13. [doi:10.3389/fnbeh.2017.00013](https://doi.org/10.3389/fnbeh.2017.00013)
- Holly KS, Orndorff CO, Murray TA (2016) MATSAP: an automated analysis of stretch-attend posture in rodent behavioral experiments. Sci Rep 6:31286. [doi:10.1038/srep31286](https://doi.org/10.1038/srep31286)

## 同类范式 {#related}

[旷场](./open-field.md) · [高架十字迷宫](./elevated-plus-maze.md) · [明暗箱](./light-dark-box.md) · [新奇抑制摄食](./novelty-suppressed-feeding.md) · [视觉悬崖](./visual-cliff.md) · [埋珠实验](./marble-burying.md)
