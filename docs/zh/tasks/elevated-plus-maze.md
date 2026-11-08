---
title: "高架十字迷宫"
description: "RodentFlow 的高架十字迷宫：开放臂探索 + 探头 + 伸展评估姿势。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 焦虑与风险评估</p>

# 高架十字迷宫

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：臂长 30 cm、宽 5 cm；5 分钟</span></div>

**开放臂探索 + 探头 + 伸展评估姿势**

两条开放臂与两条闭合臂交叉的高架迷宫，通常测 5 min。开放臂时间和进入次数比例越低，焦虑样行为越强。

## 模拟示例 {#example}

<figure>

![高架十字迷宫模拟实验：轨迹与指标](/img/tasks/elevated-plus-maze.zh.png)

<figcaption>开放臂时间占臂上时间的 32.5 %（开放臂 93 s，闭合臂 194 s）；40 次进臂中有 18 次进入开放臂，开放臂边缘头探 8 次。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

风险评估行为——探头（头伸出开放臂边缘向下看）和伸展评估姿势（身体拉长、后肢不动地向前探）——能提供开放臂时间之外的信息，但只能靠鼻尖位置和身体长度来判断。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **开放臂时间 %** | 开放臂时间 ÷（开放臂 + 闭合臂时间）。 |
| **开放臂进入 %** | 开放臂进入 ÷ 总进入；默认身体中心和尾根都进入臂才算。 |
| **探头** | 鼻尖伸出开放臂边缘且身体仍在迷宫上（≥ 0.2 s）；身体在中央区或闭合臂时为受保护探头。 |
| **伸展评估姿势 SAP** | 身体长度 ≥ 中位数的 1.2 倍且身体中心速度 < 5 cm/s，持续 ≥ 0.5 s。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 依次拖动 C（中心）和 N / E / S / W 四个臂末端。
2. 选择开放臂方向（南北或东西）
3. 四周留出空间，让探头时鼻尖仍在画面内。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Pellow S, Chopin P, File SE, Briley M (1985) Validation of open:closed arm entries in an elevated plus-maze as a measure of anxiety in the rat. J Neurosci Methods 14:149–167. [doi:10.1016/0165-0270(85)90031-7](https://doi.org/10.1016/0165-0270(85)90031-7)
- Walf AA, Frye CA (2007) The use of the elevated plus maze as an assay of anxiety-related behavior in rodents. Nat Protoc 2:322–328. [doi:10.1038/nprot.2007.44](https://doi.org/10.1038/nprot.2007.44)
- Holly KS, Orndorff CO, Murray TA (2016) MATSAP: an automated analysis of stretch-attend posture in rodent behavioral experiments. Sci Rep 6:31286. [doi:10.1038/srep31286](https://doi.org/10.1038/srep31286)

## 同类范式 {#related}

[旷场](./open-field.md) · [高架零迷宫](./elevated-zero-maze.md) · [明暗箱](./light-dark-box.md) · [新奇抑制摄食](./novelty-suppressed-feeding.md) · [视觉悬崖](./visual-cliff.md) · [埋珠实验](./marble-burying.md)
