---
title: "埋珠实验"
description: "RodentFlow 的埋珠实验：埋住的珠子数（按每颗珠子被盖住的程度）· 埋珠事件 · 接近珠子。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。"
---

<p class="rf-eyebrow">实验范式 · 焦虑与风险评估</p>

# 埋珠实验

<div class="rf-tags"><span>单鼠姿态</span><span>默认场地：40 × 25 cm 笼子，4 × 5 颗珠子</span></div>

**埋住的珠子数（按每颗珠子被盖住的程度）· 埋珠事件 · 接近珠子**

约 5 cm 厚的平整垫料上排列 20 颗玻璃珠，小鼠单独待 30 min（也有 15 或 20 min），结束时数被垫料盖住（常用标准：2/3 以上）的珠子。常用于强迫样、重复性挖掘行为和抗焦虑药筛选，但它到底测什么仍有争议。RodentFlow 在视频里逐颗读取珠子被盖住的程度，结合追踪只在小鼠离开后取样，得到每颗珠子何时被埋，并给出接近珠子的次数和时间。

## 模拟示例 {#example}

<figure>

![埋珠实验模拟实验：轨迹与指标](/img/tasks/marble-burying.zh.png)

<figcaption>30 分钟后 20 颗珠子中有 8 颗算作埋住（至少盖住 2/3），10 颗至少盖住一半。模拟数据，用来说明指标的定义，不是实验结果。</figcaption>
</figure>

## 为什么用关键点 {#why}

珠子是否被盖住要在小鼠不挡住它时才看得清。RodentFlow 用小鼠的关键点（含沿身体轴推算的尾巴位置）判断哪颗珠子此刻没被挡住、小鼠已经离开至少 1 s，只用这些时刻的画面读取珠子的遮盖程度；同一组关键点还给出鼻尖接近每颗珠子的次数和时间。

## 测量指标 {#measures}

| 指标 | 定义 |
|---|---|
| **埋住的珠子** | 分析时间段结束时，可见面积被盖住 ≥ 阈值（默认 2/3）的珠子数和比例；同时给出 ≥ 1/2 和几乎全埋（≥ 95%）的数目。 |
| **遮盖程度** | 每颗珠子 c = (m − m0) ÷ (b − m0)：m 为珠子圆内平均亮度，m0 为参照帧中的值，b 为珠子外一圈垫料此刻的亮度。0 = 和开始时一样，1 = 看起来已和垫料相同。只在小鼠离开该珠子 ≥ 1 s 且没有挡住它时取样。 |
| **埋珠事件** | 小鼠离开某颗珠子后，它的遮盖程度比上一次上升 ≥ 0.2：次数、首次埋珠潜伏期、每 5 min 的埋住数曲线。 |
| **接近珠子** | 鼻尖距珠子边缘 ≤ 设定距离（默认 1 cm）的次数、时间、首次潜伏期和接近过的珠子数。 |

阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。

## 设置 {#setup}

1. 相机固定在笼子正上方，整个测试期间不要移动，光照保持不变。
2. 把 1–4 号手柄拖到四个角上珠子的中心，在参数里输入行列数和珠子直径；各珠子的圆圈应落在珠子上。
3. “分析起点”设为放入小鼠的时刻；放入前的画面最适合做参照，若没有，会用分析起点时的画面。
4. 珠子和垫料颜色反差越大越好。

各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。

## 参考文献 {#references}

- Deacon RMJ (2006) Digging and marble burying in mice: simple methods for in vivo identification of biological impacts. Nat Protoc 1:122–124. [doi:10.1038/nprot.2006.20](https://doi.org/10.1038/nprot.2006.20)
- Thomas A, Burant A, Bui N, Graham D, Yuva-Paylor LA, Paylor R (2009) Marble burying reflects a repetitive and perseverative behavior more than novelty-induced anxiety. Psychopharmacology 204:361–373. [doi:10.1007/s00213-009-1466-y](https://doi.org/10.1007/s00213-009-1466-y)
- Angoa-Pérez M, Kane MJ, Briggs DI, Francescutti DM, Kuhn DM (2013) Marble burying and nestlet shredding as tests of repetitive, compulsive-like behaviors in mice. J Vis Exp 82:50978. [doi:10.3791/50978](https://doi.org/10.3791/50978)
- Wahl L, Punt AM, Arbab T, Willuhn I, Elgersma Y, Badura A (2022) A novel automated approach for improving standardization of the marble burying test enables quantification of burying bouts and activity characteristics. eNeuro 9:ENEURO.0446-21.2022. [doi:10.1523/ENEURO.0446-21.2022](https://doi.org/10.1523/ENEURO.0446-21.2022)

## 同类范式 {#related}

[旷场](./open-field.md) · [高架十字迷宫](./elevated-plus-maze.md) · [高架零迷宫](./elevated-zero-maze.md) · [明暗箱](./light-dark-box.md) · [新奇抑制摄食](./novelty-suppressed-feeding.md) · [视觉悬崖](./visual-cliff.md)
