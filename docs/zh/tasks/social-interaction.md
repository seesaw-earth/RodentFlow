---
title: "社交回避测试"
description: "RodentFlow 的社交回避测试：慢性社会挫败后的社交回避 · SI ratio。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 社交行为</p>

# 社交回避测试

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：42 × 42 cm；每阶段 150 秒</span></div>

**慢性社会挫败后的社交回避 · SI ratio**

慢性社会挫败应激（CSDS）模型的标准读数。实验鼠在旷场中探索两次，每次 150 s：第一次网罩内为空（无目标），第二次放入陌生的攻击鼠（有目标）。比较两次在网罩周围互动区的停留时间，SI ratio < 1 通常归为易感。

## 模拟示例 {#example}

<figure>

![社交回避测试模拟实验：轨迹与指标](/img/tasks/social-interaction.zh.png)

<figcaption>互动区时间从无目标时的 38.4 s 增加到有目标时的 64.5 s，SI 比值 1.68；角落区时间从 15.9 s 降到 6.5 s。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

除了身体中心在互动区的时间，RodentFlow 还给出鼻尖在网罩附近的嗅探时间，帮助区分主动探索和路过；同一只鼠的两个阶段会自动配对，计算 SI ratio。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **互动区时间** | 身体中心在网罩周围互动区（默认 26 × 14 cm）内的时间。 |
| **角落区时间** | 身体中心在网罩对侧两个角落区（默认 9 × 9 cm）内的时间。 |
| **SI ratio** | 有目标阶段互动区时间 ÷ 无目标阶段互动区时间（同一编号自动配对）。 |
| **嗅探网罩** | 鼻尖在网罩外缘 2 cm 以内并朝向网罩的时间。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 标定旷场四角，选择网罩靠在哪面墙。
2. 无目标、有目标两个阶段分别建立分析，编号相同即可自动配对。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Golden SA, Covington HE, Berton O, Russo SJ (2011) A standardized protocol for repeated social defeat stress in mice. Nat Protoc 6:1183–1191. [doi:10.1038/nprot.2011.361](https://doi.org/10.1038/nprot.2011.361)
- Krishnan V et al. (2007) Molecular adaptations underlying susceptibility and resistance to social defeat in brain reward regions. Cell 131:391–404. [doi:10.1016/j.cell.2007.09.018](https://doi.org/10.1016/j.cell.2007.09.018)

## 同类范式 {#related}

[三箱社交](./three-chamber.md) · [双鼠社交互动](./dyadic-social.md) · [居住者–入侵者（攻击）](./resident-intruder.md) · [群体行为](./group-behavior.md)
