---
title: "新奇抑制摄食"
description: "RodentFlow 的新奇抑制摄食：进食潜伏期（人工确认、截尾）· 接近食物 · 家笼摄食对照。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 焦虑与风险评估</p>

# 新奇抑制摄食

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：40 × 40 cm；截止 10 分钟</span></div>

**进食潜伏期（人工确认、截尾）· 接近食物 · 家笼摄食对照**

禁食（常为 24 h）后的小鼠被放进明亮的新环境，中央放一粒食物。新环境抑制进食，首次咬食的潜伏期反映焦虑样行为，慢性（而非急性）抗抑郁药会缩短它。截止时间常为 10 min；测试后立即测家笼 5 min 摄食量和体重下降，排除食欲差异。

## 模拟示例 {#example}

<figure>

![新奇抑制摄食模拟实验：轨迹与指标](/img/tasks/novelty-suppressed-feeding.zh.png)

<figcaption>鼻尖 35 s 时首次到达食物区，共接近 16 次。第一段符合候选进食规则的时间从 244 s 开始，在回看中在这里确认首次进食。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

标准视频追踪只知道动物在哪里，分不出“到了食物旁”和“开始吃”。RodentFlow 用鼻尖到食物的距离自动给出接近潜伏期和次数，把“鼻尖在食物区、身体几乎不动、持续数秒”标为候选进食放到回看时间轴上；首次进食由你在回看中确认，未确认的结果不进入组间统计。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **进食潜伏期** | 放入到首次咬食的时间，在回看中人工确认；截止前没吃记为截止时间并标为未进食（右删失），组间页用生存分析。未确认时不进入组间统计。 |
| **接近食物** | 鼻尖首次进入食物区（默认半径 3 cm）的潜伏期、进入次数和停留时间。 |
| **候选进食** | 鼻尖在食物区、身体中心速度 < 2 cm/s，持续 ≥ 3 s；标在回看时间轴上，供确认第一口。 |
| **饥饿对照** | 家笼 5 min 摄食量（g）与禁食引起的体重下降 %，可作为协变量。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 标定整个场地，把 F 手柄拖到食物中心。
2. “分析起点”设为放入场地的时刻，“分析时长”设为截止时间（常用 600 s）
3. 分析后在回看中按“设为首次进食”确认第一口，或“确认截止前未进食”。
4. 在参数里填写家笼 5 min 摄食量和禁食前、测试前体重，作为饥饿对照。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Samuels BA, Hen R (2011) Novelty-suppressed feeding in the mouse. In: Gould TD (ed) Mood and Anxiety Related Phenotypes in Mice II. Neuromethods 63:107–121. [doi:10.1007/978-1-61779-313-4_7](https://doi.org/10.1007/978-1-61779-313-4_7)
- Santarelli L et al. (2003) Requirement of hippocampal neurogenesis for the behavioral effects of antidepressants. Science 301:805–809. [doi:10.1126/science.1083328](https://doi.org/10.1126/science.1083328)
- Dulawa SC, Hen R (2005) Recent advances in animal models of chronic antidepressant effects: the novelty-induced hypophagia test. Neurosci Biobehav Rev 29:771–783. [doi:10.1016/j.neubiorev.2005.03.017](https://doi.org/10.1016/j.neubiorev.2005.03.017)
- Kaplan EL, Meier P (1958) Nonparametric estimation from incomplete observations. J Am Stat Assoc 53:457–481. [doi:10.1080/01621459.1958.10501452](https://doi.org/10.1080/01621459.1958.10501452)

## 同类范式 {#related}

[旷场](./open-field.md) · [高架十字迷宫](./elevated-plus-maze.md) · [高架零迷宫](./elevated-zero-maze.md) · [明暗箱](./light-dark-box.md) · [视觉悬崖](./visual-cliff.md) · [埋珠实验](./marble-burying.md)
