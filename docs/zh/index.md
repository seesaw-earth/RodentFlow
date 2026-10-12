---
layout: home
title: RodentFlow
titleTemplate: 使用手册

hero:
  name: RodentFlow
  text: 在 iPhone 上追踪和分析啮齿类动物行为
  tagline: 追踪俯拍视频、手动录入评分或导入表格，再用合适的统计方法做组间比较。所有计算都在手机上完成，不上传任何数据。
  image:
    src: /hero.png
    alt: RodentFlow 图标
  actions:
    - theme: brand
      text: 快速上手
      link: /zh/guide/getting-started
    - theme: alt
      text: 追踪原理
      link: /zh/principles/tracking
    - theme: alt
      text: GitHub 源代码
      link: https://github.com/seesaw-earth/RodentFlow
    - theme: alt
      text: English
      link: /

features:
  - title: 在手机上追踪视频
    details: 从旷场到恐惧条件化，十种实验范式可以直接用俯拍视频打分。追踪器在手机上以每秒 10 个采样点读完整段视频。
    link: /zh/guide/video-analysis
    linkText: 分析视频
  - title: 校准后的场地和迷宫
    details: 把几个手柄拖到场地四角或迷宫各臂上，位置就换算成厘米，区域、臂和象限都由校准自动得出。
    link: /zh/principles/metrics
    linkText: 从位置到指标
  - title: 每只动物一条结果
    details: 每段视频、每次手动录入、表格里的每一行，都成为一只动物、一个实验阶段的一条结果。区域和阈值在分析后仍可修改，不需要重新追踪视频。
    link: /zh/guide/results
    linkText: 结果页
  - title: 手动录入与表格导入
    details: 共 15 种实验范式，包括埋珠实验、糖水偏好、平衡木、步态分析和双臂老虎机任务。支持 CSV、TSV 和 JSON，列名用中文或英文都可以。
    link: /zh/guide/manual-and-import
    linkText: 录入或导入数据
  - title: 按实验设计选择统计方法
    details: 以动物为分析单位，根据设计自动选择检验，从 Welch t 检验到带 Greenhouse–Geisser 校正的混合方差分析，每种检验都与 SciPy 逐一核对过。
    link: /zh/principles/statistics
    linkText: 统计方法
  - title: 数据只在手机上，代码完全开源
    details: 不需要账号，没有统计分析 SDK，不联网。视频、结果和图表都保存在 iPhone 上，由你决定是否分享。全部源代码以 MIT 许可证公开。
    link: /zh/source
    linkText: 源代码
---

<div class="rf-home">

<p class="rf-lang">语言：<a href="../index.html">English</a> · <a href="./index.html">简体中文</a></p>

## 工作流程

视频变成位置，位置变成一只动物的指标，许多动物的指标再变成组间比较。每一步都可以停下来，导出当前的数据。

<figure>

![从视频到组间统计](/img/dataflow.zh.png)

</figure>

## 实验范式

| 类别 | 实验范式 | 可用视频追踪 |
|---|---|---|
| 焦虑与情绪 | 旷场 / 中央区、高架十字迷宫、明暗箱、埋珠实验、糖水偏好 | 旷场、高架十字迷宫、明暗箱 |
| 学习与记忆 | Y 迷宫、T 迷宫、新物体识别、Morris 水迷宫、Barnes 迷宫、恐惧条件化 | 全部六种 |
| 运动功能 | 平衡木、步态分析 | —（手动录入或导入） |
| 奖赏与决策 | 条件性位置偏好、双臂老虎机任务 | 条件性位置偏好 |
| 其他 | 任意“每只动物一行”的数据表 | —（导入） |

## 开源

RodentFlow 以 MIT 许可证开源。追踪器、每一个指标、统计引擎和这本手册都在同一个公开仓库里：你可以查看每个数值究竟怎么算出来，自己构建 App，或者按实验室的需要修改。

<p class="rf-repo"><a href="https://github.com/seesaw-earth/RodentFlow">github.com/seesaw-earth/RodentFlow</a></p>

## 从哪里开始

<div class="rf-cards">
  <a href="./guide/getting-started.html"><strong>快速上手</strong><span>大约五分钟完成第一段旷场视频的分析。</span></a>
  <a href="./guide/recording.html"><strong>拍摄建议</strong><span>相机位置、照明和对比度，决定了追踪是否可靠。</span></a>
  <a href="./assays/index.html"><strong>实验范式参考</strong><span>每种范式要设置什么，每个指标怎么定义。</span></a>
  <a href="./principles/validation.html"><strong>验证</strong><span>和已知真实值相比 App 有多准，哪里还不够准。</span></a>
</div>

</div>
