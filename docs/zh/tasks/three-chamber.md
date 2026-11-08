---
title: "三箱社交"
description: "RodentFlow 的三箱社交：社交偏好与社交新颖性 · 鼻尖嗅探判定。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 社交行为</p>

# 三箱社交

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：60 × 40 cm，三个箱室</span></div>

**社交偏好与社交新颖性 · 鼻尖嗅探判定**

实验鼠在三个相连的箱室中自由探索，两侧各放一个铁丝杯。社交偏好阶段一侧杯内是陌生鼠，另一侧为空杯或物体；社交新颖性阶段一侧是熟悉鼠，另一侧换成新的陌生鼠。经典读数是各箱室的停留时间和对两个杯子的嗅探时间。

## 模拟示例 {#example}

<figure>

![三箱社交模拟实验：轨迹与指标](/img/tasks/three-chamber.zh.png)

<figcaption>小鼠嗅探陌生鼠杯子 130.7 s、空杯 50.5 s，社交指数 0.44。三个箱室的停留时间分别是 289 s（陌生鼠侧）、177 s（中间）和 134 s（空杯侧）。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

质心追踪只能判断动物在哪个箱室。真正的社交接触是鼻尖贴近杯子并朝向它。RodentFlow 用鼻尖到杯子的距离加头朝向判定嗅探，并排除爬到杯子上的帧，更接近人工计分。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **箱室停留时间** | 身体中心所在箱室（左 / 中 / 右）的累计时间与进入次数。 |
| **嗅探时间** | 鼻尖在杯子外缘 2 cm 以内、头朝向杯子（±45°），且身体中心不在杯子上。 |
| **社交指数** | (社交 − 物体) ÷ (社交 + 物体)，按嗅探时间计算；新颖性阶段为 (新 − 熟悉) ÷ (新 + 熟悉)。 |
| **潜伏期与次数** | 首次嗅探每个杯子的时间、嗅探回合数。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 标定四个角点并输入三箱内部尺寸。
2. 把 L / R 手柄拖到两个铁丝杯的中心。
3. 在参数里选择陌生鼠（或新陌生鼠）所在的一侧。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Moy SS et al. (2004) Sociability and preference for social novelty in five inbred strains: an approach to assess autistic-like behavior in mice. Genes Brain Behav 3:287–302. [doi:10.1111/j.1601-1848.2004.00076.x](https://doi.org/10.1111/j.1601-1848.2004.00076.x)
- Yang M, Silverman JL, Crawley JN (2011) Automated three-chambered social approach task for mice. Curr Protoc Neurosci 8.26. [doi:10.1002/0471142301.ns0826s56](https://doi.org/10.1002/0471142301.ns0826s56)

## 同类范式 {#related}

[社交回避测试](./social-interaction.md) · [双鼠社交互动](./dyadic-social.md) · [居住者–入侵者（攻击）](./resident-intruder.md)
