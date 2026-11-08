---
title: "平台介导回避"
description: "RodentFlow 的平台介导回避：平台时间 · 上平台潜伏期 · 平台上 / 外僵直。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# 平台介导回避

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：30 × 25 cm，10 × 10 cm 平台</span></div>

**平台时间 · 上平台潜伏期 · 平台上 / 外僵直**

小鼠先学会声音预示足底电击，再学会走到场地一角的安全平台上躲开电击（电击在声音的最后 2 s）；在电击前上平台并待到电击结束即成功回避，代价是离开奖励口。声音、电击和奖励由各自的设备控制和记录；RodentFlow 给出追踪能算的部分：平台时间、上平台次数和潜伏期、平台上和平台外的僵直，以及逐帧的“在平台上”标记，可按设备记录的声音时间自行切分每个试次。

## 模拟示例 {#example}

<figure>

![平台介导回避模拟实验：轨迹与指标](/img/tasks/platform-avoidance.zh.png)

<figcaption>随着小鼠学会回避声音结束时的电击，声音期间在平台上的时间从第 1 次的 3.7 % 增加到第 9 次的 75.3 %。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

文献中“在平台上”常按至少两爪在平台上计。RodentFlow 可按身体中心、鼻尖 + 颈部（近似两前爪）或身体中心 + 尾根（近似四爪）判断；僵直用多个关键点的运动指数，头部的小动作不会被当成运动。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **平台时间** | 按上平台规则在平台上的时间（s、%），上平台次数、首次上平台潜伏期、平均每次停留时长。 |
| **僵直** | 运动指数低于阈值并持续 ≥ 最短时长（同恐惧条件化）；另给平台上和平台外各自的僵直比例。 |
| **奖励口区** | 鼻尖在奖励口半径内的时间和次数（可选）。 |
| **分段曲线** | 每段时间的平台时间 % 和僵直 %，组间页可做时间进程。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 标定场地四角，输入内部尺寸。
2. 把 P 手柄拖到平台中心，在参数里输入平台的宽和高。
3. 需要奖励口区时在参数里打开，再把 R 手柄拖到奖励口。
4. 逐帧 CSV 的 on_platform、freezing 列用视频时间，可按设备记录的声音时间自行切分每个试次。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Bravo-Rivera C, Roman-Ortiz C, Brignoni-Perez E, Sotres-Bayon F, Quirk GJ (2014) Neural structures mediating expression and extinction of platform-mediated avoidance. J Neurosci 34:9736–9742. [doi:10.1523/JNEUROSCI.0191-14.2014](https://doi.org/10.1523/JNEUROSCI.0191-14.2014)
- Diehl MM, Iravedra-Garcia JM, Morán-Sierra J, Rojas-Bowe G, Gonzalez-Diaz FN, Valentín-Valentín VP, Quirk GJ (2020) Divergent projections of the prelimbic cortex bidirectionally regulate active avoidance. eLife 9:e59281. [doi:10.7554/eLife.59281](https://doi.org/10.7554/eLife.59281)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Barnes 迷宫](./barnes-maze.md) · [Morris 水迷宫](./water-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [Step-down 抑制性回避](./step-down.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [Y 迷宫自发交替](./y-maze.md) · [T 迷宫 · VTE](./t-maze.md) · [恐惧条件化](./fear-conditioning.md) · [Looming 逃跑](./looming-escape.md)
