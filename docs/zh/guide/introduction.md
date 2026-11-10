---
title: "RodentFlow 能做什么"
description: "RodentFlow 在 iPhone、iPad 和 Mac 上把实验小鼠的视频变成行为指标：六点姿态、双鼠身份、经典质心追踪和多格悬尾。"
---

# RodentFlow 能做什么

RodentFlow 在 iPhone、iPad 或 Mac 上把**实验小鼠的视频变成行为指标**。选好测试，在一帧画面上标出场地，App 就会追踪动物、给这次实验评分，再做组间统计并生成可直接用于论文的图。不需要账号，也不上传：视频和结果都留在你的设备上。

<a class="rf-promo rf-promo-wide" href="../tasks/"><span class="rf-promo-thumbs"><img src="/img/tasks/thumbs/elevated-plus-maze.zh.png" alt="" loading="lazy"><img src="/img/tasks/thumbs/three-chamber.zh.png" alt="" loading="lazy"><img src="/img/tasks/thumbs/water-maze.zh.png" alt="" loading="lazy"><img src="/img/tasks/thumbs/dyadic-social.zh.png" alt="" loading="lazy"><img src="/img/tasks/thumbs/y-maze.zh.png" alt="" loading="lazy"><img src="/img/tasks/thumbs/fear-conditioning.zh.png" alt="" loading="lazy"></span><strong>28 个实验范式，逐一讲透 →</strong><span>实验设计、为什么用关键点、每个指标背后的规则、模拟示例和相关文献。</span></a>

## 一个 App，四种测量方式 {#methods}

选择的范式决定视频怎么追踪。你不需要选模型；姿态范式只需说明小鼠的毛色。

| 方法 | 追踪什么 | 用于 |
|---|---|---|
| **单鼠姿态** | 每帧 6 个关键点：鼻尖、双耳、颈部、身体中心和尾根。深色鼠用 MousePose6，白鼠用 WhiteMousePose6。 | 24 个范式，从旷场、高架迷宫到物体识别、水迷宫、恐惧条件化和头朝向 |
| **双鼠姿态** | 两只小鼠各 6 个关键点，整段视频保持 A / B 身份。两只深色鼠用 MousePose6Dyad，一黑一白用 MousePose6DyadBW。 | 双鼠社交互动和居住者–入侵者攻击 |
| **质心法** | 背景减除得到 10 Hz 的身体质心，不用模型，即 RodentFlow 1.x 的追踪方法。 | 10 个以区域和路径为主的测试：旷场、高架十字迷宫、明暗箱、Y / T 迷宫、物体识别、水迷宫、Barnes 迷宫、恐惧条件化、位置偏好 |
| **多格同步** | 并排拍摄的多只小鼠，逐格测量运动。 | 悬尾实验 |

在 iPhone 和 iPad 上还可以**手动录入数值或导入表格**（埋珠、糖水偏好、平衡木、步态、双臂老虎机或自定义指标），与其他结果一起分析。所有测试见[实验范式](../tasks/)。

## 从视频到图 {#workflow}

1. **选范式**，姿态范式再选毛色。
2. **标定**：在一帧画面上把几个手柄拖到场地、杯子、迷宫臂或平台上，输入实际尺寸（厘米）。
3. **追踪**：App 在本机读取视频，只分析场地范围，边做边保存进度。
4. **回看**：播放带追踪点的视频，下面是每种评分行为的时间轴。需要看一眼的时刻（身份、离开场地）会被标出。
5. **看结果**：每个指标都附定义，另有轨迹图、热图和时间进程。
6. **组间比较**：App 按实验设计推荐检验方法，画出每只动物，并导出图、统计结果、源数据和方法学段落。

## iPhone、iPad 与 Mac {#devices}

三者运行同一套分析代码，同一段视频、同样的标定和设置得到同样的数值。iPhone 和 iPad 适合在实验台边使用；Mac 适合组织整个研究（项目、任务、组、动物、实验），也擅长处理长录像。手机上完成的分析可以自动送到 Mac：见[手机到 Mac 同步](../reference/sync.md)。

## 接下来 {#next}

<div class="rf-cards">
  <a href="./getting-started.html"><strong>快速上手</strong><span>十分钟完成第一次分析。</span></a>
  <a href="./recording.html"><strong>拍摄</strong><span>相机、光线和场地，让追踪更干净。</span></a>
  <a href="../tasks/"><strong>实验范式</strong><span>每个测试的设计、指标、模拟示例和文献。</span></a>
  <a href="../principles/performance.html"><strong>速度与精度</strong><span>追踪有多快、有多准。</span></a>
</div>
