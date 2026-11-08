---
title: "版本说明"
description: "RodentFlow 2.1 和 2.0 在 iPhone、iPad 和 Mac 上的新内容。"
---

# 版本说明

## 2.1 · iOS build 21，Mac build 17 {#2-1-21}

更流畅、更不容易发热，结果不变。

- **后台保存**。识别中切到别的 App，会先把轨迹和实验写完。
- **发热时自动减负**。设备发热时识别会放慢，过热时自动暂停、降温后继续，屏幕上有提示。
- **大视频**。在 iPhone 和 iPad 上，4K 等很大的画面按较小尺寸解码，仍大于模型输入，省时也更少发热。1080p 及以下的视频读取方式完全不变。
- **回看更顺**。播放、时间轴和手动标记不再整页重绘；需要核对身份时，“从这里交换 A / B”显示在视频画面上。
- **“完成”键**。分析、标定、悬尾和组间页面的数字键盘上方都有“完成”。

## 2.1 · iOS build 20，Mac build 16 {#2-1}

- **四个新范式**：[平台介导回避](../tasks/platform-avoidance.md)、[Step-down 抑制性回避](../tasks/step-down.md)、[视觉悬崖](../tasks/visual-cliff.md)，以及从视频评分的[埋珠实验](../tasks/marble-burying.md)。
- **Looming**：冻结可以按身体速度定义（De Franceschi 等 2016），并可设置威胁区。
- **组间**：每次实验的时间进程随实验保存，可画时间进程图；是 / 否指标给出 Fisher 精确检验或卡方检验；跳台和视觉悬崖的潜伏期做生存分析。
- **导出**：新增 `recording_start`，即视频文件中记录的录制时间，便于与其他设备的数据对齐。

## 2.0 {#2-0}

RodentFlow 2.0 把 iPhone 版 RodentFlow、姿态版和 Mac 版合成一个 App，用于 iPhone、iPad 和 Mac。

- **一个 App 四种测量方式**：单鼠姿态、带身份的双鼠姿态、质心法（RodentFlow 1.x 的追踪方法，原样保留；1.x 的结果照常打开）和多格悬尾，手机和 Mac 都能用。
- **小鼠毛色**：白鼠用 WhiteMousePose6，一黑一白用 MousePose6DyadBW。每个导出文件都写明所用模型。
- **新范式**：高架零迷宫、新奇抑制摄食、被动回避、位置偏好（RTPP / CPP），以及姿态版 Morris 水迷宫（Pathfinder 搜索策略、平均距离、探查测试指标）。
- **组间**：双因素方差分析（Type III）、ANCOVA、前提检查、带 95 % CI 的效应量、Kaplan–Meier 曲线与 log-rank 检验；手机和 Mac 都有组间分析。
- **图**：矢量 PDF、300 / 600 dpi PNG、Mac 上的 SVG；期刊栏宽；点、柱、箱线和小提琴样式；共用色标的任务图集；每张图附源数据和图注草稿。
- **导出**：带 BORIS 形式事件表的行为片段、手机上的 DeepLabCut 格式关键点、Prism 表、长格式表、统计报告和方法学段落。
- **回看**：手动标记，并与自动判定比较精确率、召回率和 F1；标出超出标定范围的点；双鼠骨架蓝红两色。
- **只识别场地范围**、识别中定期保存进度、**视频遮挡**，以及叠加在原始画面上的热图。
- **手机到 Mac 同步**：通过你选择的文件夹，并检查 Mac 重新计算的数值是否与手机一致。
- **Mac** 可以追踪两只鼠，长录像边读边存，暂停或崩溃后接着继续。
- 四肢范式（圆筒、步态、单鼠悬尾）移到了单独的 [RodentLimb](https://seesaw-earth.github.io/RodentLimb/zh/) App。

## 更早的版本 {#earlier}

iPhone 版 RodentFlow 1.x 和 0.7 及以前的 Mac 版的版本说明保留在[旧版本](../archive/reference/changelog.md)里。
