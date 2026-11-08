---
title: "双鼠社交互动"
description: "RodentFlow 的双鼠社交互动：两只自由活动小鼠 · 鼻对鼻、肛殖区嗅探、跟随。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 社交行为</p>

# 双鼠社交互动

<div class="rf-tags"><span>双鼠姿态</span><span>默认场地：40 × 40 cm</span></div>

**两只自由活动小鼠 · 鼻对鼻、肛殖区嗅探、跟随**

两只小鼠在同一场地自由互动，例如青少年社交、居住者-入侵者测试中的非攻击部分、雌雄互动。读数是各类嗅探与跟随行为的时间和次数。

## 模拟示例 {#example}

<figure>

![双鼠社交互动模拟实验：轨迹与指标](/img/tasks/dyadic-social.zh.png)

<figcaption>5 分钟内两只鼠鼻对鼻 16.7 s；A 嗅 B 的肛周 20.5 s，B 嗅 A 的 12.9 s；A 跟随 B 16.2 s，B 跟随 A 16.1 s。平均间距 11.1 cm。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

社交接触由身体部位之间的距离定义：鼻尖–鼻尖、鼻尖–尾根（肛殖区）、鼻尖–身体。这需要每只鼠的多个关键点，用质心无法区分。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **鼻–鼻接触** | 两只鼠鼻尖距离 < 2.5 cm。 |
| **肛殖区嗅探** | 一只鼠的鼻尖到另一只鼠尾根 < 2.5 cm（A→B、B→A 分开统计）。 |
| **身体嗅探** | 鼻尖到对方身体中心 < 3 cm，且不属于上面两类。 |
| **跟随** | 间距 < 15 cm，两鼠速度都 > 5 cm/s，跟随者朝向对方（±45°）且持续 ≥ 0.5 s。 |
| **间距** | 身体中心距离的平均值，以及 < 10 cm 的近距离时间。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 两只鼠毛色、体型或标记不同时，身份判定最可靠；体色相同时，行走时体长和活动量的稳定差异也会被利用，但最可靠的仍是做标记（尾部记号笔条纹或背部染色）
2. 识别时会自动开启双鼠模式，建议逐帧识别。
3. 在回看中先看“疑似交换”，再按“身份待核对”逐个检查，A / B 不对时点“从这里交换 A / B”。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Segalin C et al. (2021) The Mouse Action Recognition System (MARS) software pipeline for automated analysis of social behaviors in mice. eLife 10:e63720. [doi:10.7554/eLife.63720](https://doi.org/10.7554/eLife.63720)
- Hong W et al. (2015) Automated measurement of mouse social behaviors using depth sensing, video tracking, and machine learning. PNAS 112:E5351–E5360. [doi:10.1073/pnas.1515982112](https://doi.org/10.1073/pnas.1515982112)

## 同类范式 {#related}

[三箱社交](./three-chamber.md) · [社交回避测试](./social-interaction.md) · [居住者–入侵者（攻击）](./resident-intruder.md)
