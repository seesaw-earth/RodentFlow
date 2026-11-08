---
title: "空间探索 · 位置细胞"
description: "RodentFlow 的空间探索 · 位置细胞：占据图、覆盖度与速度 · 神经记录同步。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 空间导航与神经记录</p>

# 空间探索 · 位置细胞

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：50 × 50 cm</span></div>

**占据图、覆盖度与速度 · 神经记录同步**

位置细胞、网格细胞记录通常让动物在开放场地中觅食数十分钟。分析放电野之前要先看占据是否均匀、覆盖度是否足够，并按速度阈值（如 > 2 cm/s）去掉静止时段。

## 模拟示例 {#example}

<figure>

![空间探索 · 位置细胞模拟实验：轨迹与指标](/img/tasks/spatial-exploration.zh.png)

<figcaption>5 分钟时覆盖了 63 % 的 2.5 cm 网格，20 分钟时 86.2 %。69.4 % 的时间速度超过 2 cm/s，共走了 79.5 m。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

身体中心比质心更稳定（不受尾巴影响），同时还能得到头朝向，便于做位置 × 方向的联合分析。逐帧导出位置、速度和 HD。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **占据图** | 身体中心在每个 2.5 cm 方格中的停留时间。 |
| **覆盖度** | 停留 ≥ 0.2 s 的方格占场地方格的比例，以及随时间的增长曲线。 |
| **运动时间** | 速度 > 2 cm/s 的时间比例（放电野分析常用的速度筛选）。 |
| **路程与速度** | 总路程、平均运动速度、速度分布。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 长时间记录可在设置中选择每 2–3 帧识别一次，以节省时间。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- O'Keefe J, Dostrovsky J (1971) The hippocampus as a spatial map. Brain Res 34:171–175. [doi:10.1016/0006-8993(71)90358-1](https://doi.org/10.1016/0006-8993(71)90358-1)
- Hafting T, Fyhn M, Molden S, Moser MB, Moser EI (2005) Microstructure of a spatial map in the entorhinal cortex. Nature 436:801–806. [doi:10.1038/nature03721](https://doi.org/10.1038/nature03721)

## 同类范式 {#related}

[头朝向](./head-direction.md)
