---
title: "Morris 水迷宫"
description: "RodentFlow 的Morris 水迷宫：逃避潜伏期、路径与搜索策略 · 探索测试看平均距离与象限。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# Morris 水迷宫

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：120 cm 水池，10 cm 平台；每次 60 秒</span></div>

**逃避潜伏期、路径与搜索策略 · 探索测试看平均距离与象限**

小鼠在注满不透明水的圆形水池中游泳，借助池外的空间线索寻找水面下的隐藏平台。学习期看逃避潜伏期、路径长度和搜索策略的进步；探索测试撤去平台，看小鼠是否集中在原平台附近搜索（平均距原平台距离、目标象限时间、穿越次数）。可见平台试次用来排除视觉和运动问题。

## 模拟示例 {#example}

<figure>

![Morris 水迷宫模拟实验：轨迹与指标](/img/tasks/water-maze.zh.png)

<figcaption>60 秒探查测试中，小鼠 35.8 % 的时间在目标象限（对侧象限 14.2 %），穿越原平台区 6 次，平均距离 34.3 cm。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

与旷场相同的逐帧关键点识别，数据处理换成水迷宫的指标。身体中心比质心更稳定（不受尾巴和水花影响）；头朝向可以直接给出入水时是否朝向平台。游泳时尾根常在水下，RodentFlow 用身体中心，缺失时退回到两耳中点或鼻尖；每个试次按 Pathfinder 的规则判定搜索策略。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **逃避潜伏期** | 身体中心进入平台（半径 + 余量）并停留 ≥ 设定时长的时刻；没找到时记为试次时长。 |
| **路径与游速** | 入水到找到平台之间身体中心的路程、平均游速和路径效率（直线距离 ÷ 实际路程）。 |
| **平均距离与累计搜索误差** | 到平台中心的平均距离（Gallagher）；按 1 s 分段累加的距离减去以同样速度直线游向平台的理想值（CIPL）。 |
| **象限与平台区** | 目标、对侧和两个相邻象限的时间比例，平台区时间；探索测试另给穿越原平台次数、前 30 s 和分段的目标象限时间、搜索熵。 |
| **搜索策略** | Pathfinder 规则：直线路径、聚焦、定向、间接、链式、扫描、贴壁、随机；附认知评分（0–6）。 |
| **贴壁与漂浮** | 距池壁不超过贴壁区宽度的时间；速度 < 2 cm/s 持续 ≥ 1 s 的漂浮时间。两者都是非认知因素。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 拖动 C（中心）和 R（池壁）标定水池，输入水池内径。
2. 把 P 手柄拖到平台中心；探索测试时放在原平台位置。
3. 在参数里把“分析起点”设为小鼠入水的时刻，“分析时长”设为最长试次时间（如 60 s）
4. 水面反光、池边的实验者等固定干扰，可先用“视频遮挡”盖住再分析。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Morris R (1984) Developments of a water-maze procedure for studying spatial learning in the rat. J Neurosci Methods 11:47–60. [doi:10.1016/0165-0270(84)90007-4](https://doi.org/10.1016/0165-0270(84)90007-4)
- Vorhees CV, Williams MT (2006) Morris water maze: procedures for assessing spatial and related forms of learning and memory. Nat Protoc 1:848–858. [doi:10.1038/nprot.2006.116](https://doi.org/10.1038/nprot.2006.116)
- Gallagher M, Burwell R, Burchinal M (1993) Severity of spatial learning impairment in aging: development of a learning index for performance in the Morris water maze. Behav Neurosci 107:618–626. [doi:10.1037/0735-7044.107.4.618](https://doi.org/10.1037/0735-7044.107.4.618)
- Maei HR, Zaslavsky K, Teixeira CM, Frankland PW (2009) What is the most sensitive measure of water maze probe test performance? Front Integr Neurosci 3:4. [doi:10.3389/neuro.07.004.2009](https://doi.org/10.3389/neuro.07.004.2009)
- Maei HR et al. (2009) Development and validation of a sensitive entropy-based measure for the water maze. Front Integr Neurosci 3:33. [doi:10.3389/neuro.07.033.2009](https://doi.org/10.3389/neuro.07.033.2009)
- Cooke MB, O'Leary TP, Harris P, Ma R, Brown RE, Snyder JS (2019) Pathfinder: open source software for analyzing spatial navigation search strategies. F1000Research 8:1521. [doi:10.12688/f1000research.20352.2](https://doi.org/10.12688/f1000research.20352.2)
- Garthe A, Behr J, Kempermann G (2009) Adult-generated hippocampal neurons allow the flexible use of spatially precise learning strategies. PLoS One 4:e5464. [doi:10.1371/journal.pone.0005464](https://doi.org/10.1371/journal.pone.0005464)
- Wolfer DP, Stagljar-Bozicevic M, Errington ML, Lipp HP (1998) Spatial memory and learning in transgenic mice: fact or artifact? News Physiol Sci 13:118–123. [doi:10.1152/physiologyonline.1998.13.3.118](https://doi.org/10.1152/physiologyonline.1998.13.3.118)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Barnes 迷宫](./barnes-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [Step-down 抑制性回避](./step-down.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [Y 迷宫自发交替](./y-maze.md) · [T 迷宫 · VTE](./t-maze.md) · [恐惧条件化](./fear-conditioning.md) · [Looming 逃跑](./looming-escape.md) · [平台介导回避](./platform-avoidance.md)
