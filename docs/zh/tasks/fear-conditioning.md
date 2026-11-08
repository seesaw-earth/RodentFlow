---
title: "恐惧条件化"
description: "RodentFlow 的恐惧条件化：关键点僵直检测 · 按 CS 分段。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# 恐惧条件化

<div class="rf-tags"><span>单鼠姿态</span><span>也可用质心法</span><span>默认场地：30 × 24 cm 箱</span></div>

**关键点僵直检测 · 按 CS 分段**

声音（CS）与足底电击配对后，在相同情境或新情境中重放 CS，测量僵直（除呼吸外完全不动）所占的百分比。

## 模拟示例 {#example}

<figure>

![恐惧条件化模拟实验：轨迹与指标](/img/tasks/fear-conditioning.zh.png)

<figcaption>冻结比例：首个 CS 前 17.6 %，三个 CS 期间分别为 67.3 %、84.7 % 和 83.7 %，CS 之间 55.7 %。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

运动像素法会把呼吸、光照闪烁和相机噪声也算进去。RodentFlow 用鼻尖、两耳中点、身体中心和尾根在 0.5 s 窗口内的位移速度判断僵直，头部的小动作（嗅探、扫视）不会被误判为僵直。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **僵直** | 核心关键点 0.5 s 窗口位移速度 < 1.0 cm/s，持续 ≥ 1 s。 |
| **按 CS 分段** | 基线（首个 CS 前）、每个 CS 期间、CS 间隔的僵直百分比。 |
| **时间曲线** | 每分钟僵直百分比。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 在参数里输入 CS 开始时间（相对于视频开头）和时长。
2. 红外或灰度视频效果最好。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 质心法版本 {#classic}

这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。

## 参考文献 {#references}

- Phillips RG, LeDoux JE (1992) Differential contribution of amygdala and hippocampus to cued and contextual fear conditioning. Behav Neurosci 106:274–285. [doi:10.1037/0735-7044.106.2.274](https://doi.org/10.1037/0735-7044.106.2.274)
- Anagnostaras SG et al. (2010) Automated assessment of Pavlovian conditioned freezing and shock reactivity in mice using the Video Freeze system. Front Behav Neurosci 4:158. [doi:10.3389/fnbeh.2010.00158](https://doi.org/10.3389/fnbeh.2010.00158)
- Gabriel CJ et al. (2022) BehaviorDEPOT (freezing from keypoints). eLife 11:e74314. [doi:10.7554/eLife.74314](https://doi.org/10.7554/eLife.74314)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Barnes 迷宫](./barnes-maze.md) · [Morris 水迷宫](./water-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [Step-down 抑制性回避](./step-down.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [Y 迷宫自发交替](./y-maze.md) · [T 迷宫 · VTE](./t-maze.md) · [Looming 逃跑](./looming-escape.md) · [平台介导回避](./platform-avoidance.md)
