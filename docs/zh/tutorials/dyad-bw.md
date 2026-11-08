---
description: RodentFlow 的一黑一白双鼠模型 MousePose6-DyadBW 如何用 DooM 各实验室的一黑一白和两只深色鼠组合训练，以及与两只深色鼠模型的比较。
---

# 一黑一白两只小鼠的双鼠模型

<p class="rf-eyebrow">教程 6 · MOUSEPOSE6DYADBW_960_INT8 · 第 2 版</p>

两只小鼠的*小鼠毛色*设为**一黑一白**时（例如黑色 resident 和白色 intruder），RodentFlow 使用 MousePose6-DyadBW。它是一个单独的模型：两只深色鼠用的 MousePose6-Dyad 保持不变。它的输出与 App 的其他姿态模型一致，用 DooM 视频训练，每帧两只鼠都有标注。随 App 发布的是第 2 版：第 1 版在一个没见过的实验室里漏检深色鼠，于是重新训练。

<Badge type="info" text="YOLO26s-pose" /><Badge type="info" text="6 个关键点 × 2 只鼠" /><Badge type="info" text="960 px" /><Badge type="tip" text="Core ML · 8 位权重" />

## 模型卡 {#card}

<table class="rf-kv">
<tr><th>发布文件</th><td><code>MousePose6DyadBW_960_int8.mlpackage</code>（9.66 MiB）；元数据 <code>rodentflow.version = v2</code>；RodentFlow 2.0 起内置于 Mac、iPhone 和 iPad</td></tr>
<tr><th>任务</th><td>单一类别 <code>mouse</code>，每帧最多两只；每只六个关键点：<code>nose</code>、<code>left_ear</code>、<code>right_ear</code>、<code>neck</code>、<code>body_center</code>、<code>tail_base</code></td></tr>
<tr><th>初始权重</th><td>Ultralytics <code>yolo26s-pose.pt</code>（在 COCO 关键点上预训练），与 MousePose6-Dyad 相同</td></tr>
<tr><th>参数量</th><td>9,753,237</td></tr>
<tr><th>输入 / 输出</th><td>960 × 960 RGB 图像 → 端到端输出头给出形状为 (1, 300, 24) 的张量</td></tr>
<tr><th>训练数据</th><td>DooM 中 10 个实验室的视频：7 个实验室的一黑一白组合，4 个实验室的两只深色鼠组合（TranquilPanther 两种都有）；训练图 25,071 张，验证图 3,101 张。另一个实验室 InvincibleJellyfish 留作测试。</td></tr>
<tr><th>标签</th><td>各实验室姿态轨迹中的鼻尖、两耳和尾根；颈部和身体中心按同一条规则推算。每帧每只鼠都有标注。<strong>不是人工标注。</strong></td></tr>
<tr><th>软件</th><td>Ultralytics 8.4.204、PyTorch 2.14.1（CUDA 13.0）、Python 3.13；Google Colab 上一块 NVIDIA RTX PRO 6000 Blackwell GPU</td></tr>
<tr><th>训练运行</th><td><code>dyad_bw_s960_v2</code>，80 个 epoch，2.6 小时；checkpoint SHA-256 <code>1c5082e7…922b37</code></td></tr>
<tr><th>导出</th><td>Core ML ML Program，coremltools 9.0，<code>quantize=8</code>，<code>nms=False</code>；2026 年 11 月 7 日</td></tr>
<tr><th>模型包里的许可字段</th><td>AGPL-3.0（导出时由 Ultralytics 写入；见<a href="/RodentFlow/zh/tutorials/citations.html#licences">许可</a>）</td></tr>
</table>

来源：模型包元数据；notebook `DyadBW_YOLO26_Train_v2`（包括其中引用的第 1 版结果）；App 源码。

## 为什么要单独的模型 {#why}

两只深色鼠的模型 MousePose6-Dyad（见[博客](../blog/training-on-existing-tracks.md#dyad)）很难找到白鼠。在下面的一黑一白留出测试图上，它找到了 96.3 % 的深色鼠，但白鼠只有 54.8 %，并在 38.2 % 的图里把两只鼠框成一只。用一黑一白的组合训练可以解决这个问题，但修改 MousePose6-Dyad 会改变所有深色鼠研究的结果，所以一黑一白模型单独存在，按毛色选用。

## 第 2 版 {#v1}

第 1 版（运行 `20261107_031448`）用 7 个实验室的一黑一白组合训练，这些视频都在浅色垫料上拍摄。为了同样覆盖深色垫料上的深色鼠，第 2 版改了四点：

第 2 版改了四处：

1. **加入两只深色鼠的组合**，来自 MousePose6-Dyad 训练用的实验室（CautiousGiraffe、ElegantMink（含棕色 129 小鼠）、NiftyGoldfinch，以及 TranquilPanther 的深色鼠组合），每个实验室约 2,500 张图。它们的划分沿用 DooM 自己的划分：DooM 的测试视频只进测试集，每段 20 张。
2. **一黑一白部分不变**：同样的视频、划分、帧和图，所以第 2 版的测试集就是第 1 版的测试集。
3. **标注点要在鼠身上**（新检查，见[第 2 步](#label-check)）。
4. **固定 batch 大小**（40），控制显存用量。

## 数据 {#data}

所有视频都来自 DooM（[数据集](./citations.md#r-doom-data)、[论文](./citations.md#r-doom)）。DooM 的元数据给出每只鼠的毛色或品系；毛色写白色或白化，或者没有毛色时品系为 BALB/c、CD-1、CFW、Swiss、ICR 或 NMRI，就算白鼠。共使用 473 段视频（80.8 GB）：

| 实验室 | 用途 | 一黑一白视频 | 两只深色鼠视频（其中 DooM 测试视频） | 每段取图数 |
|---|---|---|---|---|
| SparklingTapir | 训练 | 94 | — | 32 |
| JovialSwallow | 训练 | 77 | — | 39 |
| LyricalHare | 训练 | 37 | — | 81 |
| DeliriousFly | 训练 | 30 | — | 100 |
| ReflectiveManatee | 训练 | 30 | — | 100 |
| UppityFerret | 训练 | 30 | — | 100 |
| TranquilPanther | 训练 | 11 | 24（7） | 273 / 147 |
| CautiousGiraffe | 训练 | — | 32（22） | 250 |
| ElegantMink | 训练 | — | 26（7） | 132 |
| NiftyGoldfinch | 训练 | — | 32（21） | 227 |
| InvincibleJellyfish | **没见过的实验室（测试）** | 50 | — | 30 |

DooM 测试划分中的两只深色鼠视频每段取 20 张，只进测试集。

## 第 1 步 · 从轨迹到标签 {#labels}

转换脚本（`bw_dyad_build.py`，随结果一起保存）对每段视频执行以下规则：

- **裁剪到追踪范围。**每帧裁剪到所有追踪点覆盖的范围，去掉拼接的侧视画面、旁边的笼子和空白边缘。
- **核心点来自追踪器。**鼻尖、左耳、右耳和尾根来自实验室的轨迹。颈部和身体中心用**与白鼠模型相同的规则**推算（颈部由两耳中点、鼻尖和尾根推出，a = 0.127，b = 0.057；身体中心 = 颈部和尾根的中点）。在 5 个同时追踪了颈部的实验室里，推算的颈部与追踪的颈部相差 0.016–0.034 L（每个实验室一个汇总值）。
- **按视频检查左右。**用俯视几何规则检查两耳（左耳在动物头轴的左侧）。整段反了的视频会被交换；个别反了的帧被丢弃。InvincibleJellyfish 的 50 段视频全部反了，已交换。
- **质量过滤。**两只鼠都必须四个追踪点齐全、体长在该鼠中位数的 0.45–1.8 倍、骨架合理且左耳在左边、与前后帧之间没有跳变、两只没有重叠成一只；否则整帧不用。
- **每只鼠都标注。**没有标注的鼠会被学成背景。
- **贴身接触。**约一半的帧在两鼠相距不到一个体长时选取；贴在一起（不到 0.5 L）的帧权重更高。
- **每只鼠的毛色。**按身体亮度把每只标注的鼠标为白鼠或深色鼠，用于按毛色评估。
- **灰度。**训练和验证图一半存为灰度；测试图保留彩色，评估时两种都跑。

## 第 2 步 · 标注点要在鼠身上 {#label-check}

每只标注的鼠必须满足以下任意一条：相对视频的中位背景在动（中位差 ≥ 6，且 ≥ 整张图差异的 3 倍），或与周围一圈明显不同（中位亮度差 ≥ 8）。门槛有意放低，以免误删静止、对比度低的深色鼠（深色垫料上不动的黑鼠），这正是第 2 版要学的。训练和验证集中，不合格的图被移走；一段视频超过 30 % 不合格时，整段不用。测试集中不合格的图只标记、不删除，免得删掉的正好是难的帧。

| 实验室 | 训练 / 验证中移走 | 整段不用的视频 | 测试中标记（保留） |
|---|---|---|---|
| ElegantMink | 174 | 1 | 10 |
| LyricalHare | 193 | 0 | 16 |
| ReflectiveManatee | 63 | 0 | 15 |
| SparklingTapir | 32 | 0 | 2 |
| TranquilPanther | 75 | 0 | 3 |
| UppityFerret | 203 | 2 | 0 |
| NiftyGoldfinch | 2 | 0 | 2 |
| CautiousGiraffe、DeliriousFly、JovialSwallow、InvincibleJellyfish | 0 | 0 | 2 |
| **合计** | **742** | **3** | **50** |

第 1 版发现的两段 UppityFerret 视频整段不用（100 张中分别有 64 和 74 张不合格），另有一段 ElegantMink 视频（132 张中 63 张不合格）。

## 第 3 步 · 划分 {#split}

- **一黑一白视频：**在每个实验室内按视频分为训练 / 验证 / 测试 80 / 10 / 10 %，顺序与白鼠数据集相同，所以同一段视频在两个数据集中属于同一个划分。
- **两只深色鼠视频：**DooM 的测试视频进测试集；其余视频的 10 % 进验证集。
- **InvincibleJellyfish：**只用于测试。

| 实验室 | 组合 | 训练 | 验证 | 测试 | 没见过的实验室 |
|---|---|---|---|---|---|
| SparklingTapir | 一黑一白 | 2,405 | 282 | 288 | |
| JovialSwallow | 一黑一白 | 2,376 | 312 | 312 | |
| LyricalHare | 一黑一白 | 2,166 | 314 | 324 | |
| DeliriousFly | 一黑一白 | 2,400 | 300 | 300 | |
| ReflectiveManatee | 一黑一白 | 2,342 | 295 | 300 | |
| UppityFerret | 一黑一白 | 2,198 | 299 | 300 | |
| TranquilPanther | 一黑一白 | 2,389 | 266 | 273 | |
| TranquilPanther | 两只深色 | 2,205 | 294 | 140 | |
| CautiousGiraffe | 两只深色 | 2,250 | 250 | 440 | |
| ElegantMink | 两只深色 | 2,072 | 262 | 140 | |
| NiftyGoldfinch | 两只深色 | 2,268 | 227 | 420 | |
| InvincibleJellyfish | 一黑一白 | | | | 1,500 |
| **合计** | | **25,071** | **3,101** | **3,237** | **1,500** |

32,909 张图中，16,409 张两鼠相距不到一个体长，2,657 张贴在一起。

## 第 4 步 · 训练 {#train}

<table class="rf-kv">
<tr><th>网络</th><td>YOLO26s-pose，960 px，与 MousePose6-Dyad 和第 1 版相同</td></tr>
<tr><th>训练安排</th><td>80 个 epoch（耐心 20；80 个全部跑完），batch 40，优化器 <code>auto</code>，余弦学习率，最后 15 个 epoch 关闭 mosaic，随机种子 2026，确定性模式；2.6 小时，显存峰值 42.4 GB</td></tr>
<tr><th>数据增强</th><td>左右和上下翻转（概率各 0.5，同时交换左右耳），缩放 0.5，平移 0.1；不旋转（会让框变松，两只鼠的框重叠更多），不做 mixup（会把两张图的鼠叠在一起）；颜色只做亮度增强（<code>hsv_v</code> 0.4）</td></tr>
<tr><th>早停依据</th><td>验证图，一黑一白和两只深色鼠合在一起</td></tr>
</table>

在 3,101 张验证图（6,202 只鼠）上，最终 checkpoint 的框 mAP50 为 0.993、mAP50-95 为 0.833，姿态 mAP50 为 0.941、mAP50-95 为 0.731。

## 第 5 步 · 结果 {#results}

三个模型都按 App 的方式运行：灰度，等比缩放补边到 960 × 960，置信度高于 0.25。一只标注的鼠被检测配上就算**找到**（按鼻尖、两耳和尾根的平均误差做 Hungarian 匹配，误差小于 0.5 L）。距离：*分开* ≥ 1 L，*靠近* 0.5–1 L，*贴在一起* < 0.5 L。95 % 置信区间按视频重抽 1,000 次得到。标签是轨迹，所以这些数字衡量的是与各实验室追踪器的一致程度。

### 找到的鼠 {#found}

| 测试集 | 鼠数 | 第 2 版 | 第 1 版 | MousePose6-Dyad |
|---|---|---|---|---|
| 一黑一白留出视频：**深色鼠** | 2,079 | **98.7 %**（97.8–99.5） | 98.7 % | 96.3 % |
| 一黑一白留出视频：**白鼠** | 2,079 | **98.7 %**（97.6–99.4） | 98.5 % | 54.8 % |
| 两只深色鼠，DooM 测试视频 | 2,280 | **99.1 %**（98.6–99.5） | 94.3 % | 99.5 % |
| 没见过的实验室：**深色鼠** | 1,500 | **88.1 %**（84.1–91.9） | 56.4 % | 98.9 % |
| 没见过的实验室：**白鼠** | 1,500 | **96.2 %**（94.9–97.4） | 97.7 % | 77.4 % |

两鼠贴在一起时，第 2 版在一黑一白测试中找到 96.0 % 的深色鼠和 94.5 % 的白鼠，在没见过的实验室中找到 83.0 % 的深色鼠和 81.9 % 的白鼠。

### 一张图里的两只鼠 {#both}

| 测试集 | 图数 | 两只都找到：第 2 版 | 第 1 版 | Dyad | 合并成一个框：第 2 版 | Dyad |
|---|---|---|---|---|---|---|
| 一黑一白留出视频 | 2,097 | **97.4 %** | 97.4 % | 53.7 % | 2.0 % | 38.2 % |
| 两只深色鼠 | 1,140 | **98.2 %** | 89.3 % | 98.9 % | 1.0 % | 0.1 % |
| 没见过的实验室 | 1,500 | **84.9 %** | 54.9 % | 76.6 % | 14.3 % | 22.3 % |

两鼠贴在一起时，第 2 版在一黑一白测试图中有 90.0 % 两只都找到，在没见过的实验室中为 67.2 %。两只都找到时，较亮的框就是白鼠：一黑一白测试图中为 99.9 %，没见过的实验室中全部正确。

### 关键点 {#keypoints}

已检出鼠的四个追踪关键点中误差在 0.1 个体长以内的比例（PCK@0.1），以及推算的身体中心的误差中位数：

| 测试集 | 毛色 | 第 2 版 PCK@0.1 | 第 1 版 | Dyad | 身体中心：第 2 版 | Dyad |
|---|---|---|---|---|---|---|
| 一黑一白留出视频 | 深色 | 94.6 % | 94.7 % | 85.9 % | 0.014 L | 0.274 L |
| | 白色 | 93.3 % | 93.0 % | 61.4 % | 0.019 L | 0.291 L |
| 没见过的实验室 | 深色 | 96.4 % | 95.5 % | 95.2 % | 0.016 L | 0.254 L |
| | 白色 | 94.7 % | 93.9 % | 63.6 % | 0.021 L | 0.310 L |
| 两只深色鼠 | 深色 | 96.1 % | 91.5 % | 94.7 % | 0.016 L | 0.272 L |

MousePose6-Dyad 的身体中心误差大，是定义不同，而不是不准：它学的是某一个实验室的身体中心，约在鼻尖后 0.4 L（[博客](../blog/training-on-existing-tracks.md#dyad-data)），而第 2 版和 MousePose6、WhiteMousePose6 一样，用颈部和尾根的中点。**因此基于身体中心的指标在单鼠模型与一黑一白模型之间可以比较，但不能与 MousePose6-Dyad 比较。**

## 第 6 步 · 导出 {#export}

导出设置与另一个双鼠模型相同：8 位权重，端到端输出头（`nms=False`），输入 960 × 960，并检查输出是一个 (1, 300, 24) 的 float32 数组。元数据记录了关键点、颈部规则、训练用的实验室（`rodentflow.training_labs`）、留出的实验室（`rodentflow.holdout_labs = InvincibleJellyfish`）、`rodentflow.body_center = midpoint of neck and tail base`、checkpoint 的 SHA-256 和 `rodentflow.version = v2`。文件名与第 1 版相同，所以新模型包会替换它。

与白鼠模型一样，notebook 写出 24 张测试输入、PyTorch 预测和 `verify_on_mac.py` 脚本；用来把 Core ML 模型包与这些预测比较（[教程 4](./app-integration.md#parity)）。

## 在 App 中 {#app}

- 双鼠任务（双鼠社交互动、resident–intruder）选**小鼠毛色：一黑一白**。两只鼠的默认值是*两只都是深色*，使用 MousePose6-Dyad。
- 识别、A / B 身份和分析与 MousePose6-Dyad 相同。Methods 文字按每段视频记录的毛色写明 A、B 中哪只是深色鼠，分不清时给出提示。
- 检出率按毛色分开检查：深色鼠检出不到 80 % 时，App 提示可能是深色垫料上漏检，可以改用*两只都是深色*重跑对比；白鼠不到 80 % 时，提示检查贴身片段。

## 适用范围与许可 {#limits}

- 标签是 DooM 各实验室的轨迹，所以测试分数给出的是与这些轨迹的一致程度。
- App 会按毛色报告检出率；深色鼠在少于 80 % 的帧中被找到时，会建议另用*两只深色*分析同一段视频作对照。
- 身体中心相关指标可以与 MousePose6 和 WhiteMousePose6 比较（颈部与尾根的中点），但不能与 MousePose6-Dyad 比较。
- 训练视频来自 DooM 数据集，其使用条款见 EMBER 记录（见[许可汇总](./citations.md#licences)）。

## 引用 {#cite}

注明版本的 RodentFlow、Ultralytics YOLO26，以及 DooM 数据集和论文；见[如何引用](./citations.md#use-dyad-bw)。
