---
title: "居住者–入侵者（攻击）"
description: "RodentFlow 的居住者–入侵者（攻击）：攻击潜伏期、次数、时长 · 追逐、压制、威胁、骑跨。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 社交行为</p>

# 居住者–入侵者（攻击）

<div class="rf-tags"><span>双鼠姿态</span><span>默认场地：饲养笼 30 × 18 cm；入侵者放入后 10 分钟</span></div>

**攻击潜伏期、次数、时长 · 追逐、压制、威胁、骑跨**

把一只陌生的 intruder 放进 resident 的饲养笼，通常观察 10 min。读数是攻击潜伏期、攻击次数和时长，以及追逐、压制、威胁姿势和骑跨等攻击相关行为；嗅探和跟随作为非攻击性社交一并给出。

## 模拟示例 {#example}

<figure>

![居住者–入侵者（攻击）模拟实验：轨迹与指标](/img/tasks/resident-intruder.zh.png)

<figcaption>入侵者放入后 8.1 s 出现首次攻击。之后 4 分钟内攻击 17 次（共 11.4 s），跟随或追逐 24.6 s，肛周嗅探 36 s。（图中用的是简化版攻击规则。）模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

攻击的特征在运动学里：resident 突然加速扑向对方（接近速度骤升），接触后两鼠高速、方向混乱地翻滚，随后 intruder 逃离或被追逐。RodentFlow 用每只鼠的颈到尾根距离作为体长，以体长为单位计算距离和相对速度，判定攻击、扭打、追逐、压制、侧身威胁、直立和骑跨；不需要标定场地。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **攻击潜伏期** | 从 intruder 放入到首次攻击的时间（s）；没有攻击时记为测试时长。 |
| **攻击次数与时长** | 两鼠贴近、高速且方向混乱的打斗片段（不区分发起者）：次数、总时长、平均时长；扭打（原地翻滚）单独给出。 |
| **其他攻击性行为** | 追逐、压制、侧身威胁、攻击性直立的总时长，与攻击本身分开。 |
| **攻击鼠百分比** | 每次测试给出“发生攻击”（0 / 1）；汇总表中一组的平均值 × 100。 |
| **社交探索** | 肛殖区嗅探、鼻–鼻接触、跟随（不能单独算作攻击）；骑跨单独统计。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 开始录像后再放入 intruder：放入前只有 resident 的画面用来自动确定谁是 resident 和放入时间。
2. 必须逐帧识别（一次扑击只有 100–200 ms），帧率 ≥ 25 fps。
3. 两只鼠毛色或体型不同、或给 intruder 做标记时，身份最可靠。
4. 回看中核对“攻击”时间轴，必要时在参数中调整阈值。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Koolhaas JM, Coppens CM, de Boer SF, Buwalda B, Meerlo P, Timmermans PJA (2013) The resident-intruder paradigm: a standardized test for aggression, violence and social stress. J Vis Exp 77:e4367. [doi:10.3791/4367](https://doi.org/10.3791/4367)
- Segalin C et al. (2021) The Mouse Action Recognition System (MARS) software pipeline for automated analysis of social behaviors in mice. eLife 10:e63720. [doi:10.7554/eLife.63720](https://doi.org/10.7554/eLife.63720)
- Hong W et al. (2015) Automated measurement of mouse social behaviors using depth sensing, video tracking, and machine learning. PNAS 112:E5351–E5360. [doi:10.1073/pnas.1515982112](https://doi.org/10.1073/pnas.1515982112)

## 同类范式 {#related}

[三箱社交](./three-chamber.md) · [社交回避测试](./social-interaction.md) · [双鼠社交互动](./dyadic-social.md) · [群体行为](./group-behavior.md)
