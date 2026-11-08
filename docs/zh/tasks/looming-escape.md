---
title: "Looming 逃跑"
description: "RodentFlow 的Looming 逃跑：头顶扩张黑影 → 逃回巢穴或僵直。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 学习、记忆与恐惧</p>

# Looming 逃跑

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：48 × 48 cm，带庇护所</span></div>

**头顶扩张黑影 → 逃回巢穴或僵直**

动物头顶的屏幕呈现快速扩大的黑色圆盘（模拟俯冲的捕食者），小鼠通常在一秒内逃回庇护所或原地僵直。读数是反应潜伏期、是否逃回巢穴、逃跑速度和僵直。

## 模拟示例 {#example}

<figure>

![Looming 逃跑模拟实验：轨迹与指标](/img/tasks/looming-escape.zh.png)

<figcaption>5 次刺激中有 4 次逃回庇护所，反应潜伏期中位数 0.27 s；另一次以冻结结束。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

刺激出现时的头朝向和到巢穴的方向决定了逃跑路径，是这个范式的重要协变量。RodentFlow 给出每次刺激时头部与巢穴方向的夹角。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **反应潜伏期** | 刺激后速度首次超过 max(4 × 基线速度, 15 cm/s) 的时间。 |
| **逃跑** | 有反应且在 10 s 内回到巢穴区。 |
| **僵直** | 刺激后 10 s 内的僵直时长（同恐惧条件化的定义）。 |
| **朝向与距离** | 刺激时头朝向与巢穴方向的夹角、到巢穴的距离。 |
| **僵直定义与威胁区** | 僵直可用运动指数（同恐惧条件化），或按 De Franceschi 等（2016）用身体速度 < 2 cm/s 持续 ≥ 0.5 s；可选的威胁区给出区内时间，并在逐帧数据中标记。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 把 S 手柄拖到巢穴（庇护所）中心。
2. 输入每次刺激出现的时间（相对于视频开头）
3. 需要威胁区（刺激下方的区域）时在参数里打开，再把 T 手柄拖到区域中心。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Yilmaz M, Meister M (2013) Rapid innate defensive responses of mice to looming visual stimuli. Curr Biol 23:2011–2015. [doi:10.1016/j.cub.2013.08.015](https://doi.org/10.1016/j.cub.2013.08.015)
- Vale R, Evans DA, Branco T (2017) Rapid spatial learning controls instinctive defensive behavior in mice. Curr Biol 27:1342–1349. [doi:10.1016/j.cub.2017.03.031](https://doi.org/10.1016/j.cub.2017.03.031)
- De Franceschi G, Vivattanasarn T, Saleem AB, Solomon SG (2016) Vision guides selection of freeze or flight defense strategies in mice. Curr Biol 26:2150–2154. [doi:10.1016/j.cub.2016.06.006](https://doi.org/10.1016/j.cub.2016.06.006)

## 同类范式 {#related}

[新物体识别](./novel-object-recognition.md) · [Barnes 迷宫](./barnes-maze.md) · [Morris 水迷宫](./water-maze.md) · [被动回避（穿梭箱）](./passive-avoidance.md) · [Step-down 抑制性回避](./step-down.md) · [位置偏好（RTPP / CPP）](./place-preference.md) · [Y 迷宫自发交替](./y-maze.md) · [T 迷宫 · VTE](./t-maze.md) · [恐惧条件化](./fear-conditioning.md) · [平台介导回避](./platform-avoidance.md)
