---
description: RodentFlow 的单只白鼠模型 WhiteMousePose6 如何用 DooM 的追踪轨迹和一个更大的教师模型训练，以及它与留出视频轨迹的一致程度。
---

# 用追踪轨迹和更大的模型训练白鼠姿态模型

<p class="rf-eyebrow">教程 5 · WHITEMOUSEPOSE6_960_INT8</p>

单只小鼠的*小鼠毛色*设为**白色**时，RodentFlow 使用 WhiteMousePose6。它和 [MousePose6](./mousepose6.md) 的大小、输入、输出和六个关键点都相同，所以 App 运行它的方式完全一样。它的训练数据来自 DooM 数据集中的白鼠：各实验室自己的姿态轨迹，再加上一个更大的 YOLO 模型标注的额外帧。

<Badge type="info" text="YOLO26n-pose" /><Badge type="info" text="6 个关键点" /><Badge type="info" text="960 px" /><Badge type="tip" text="Core ML · 8 位权重" />

## 模型卡 {#card}

<table class="rf-kv">
<tr><th>发布文件</th><td><code>WhiteMousePose6_960_int8.mlpackage</code>（2.76 MiB）；RodentFlow 2.0 起内置于 Mac、iPhone 和 iPad</td></tr>
<tr><th>任务</th><td>单一类别 <code>white_mouse</code>；六个关键点，顺序与 App 相同：<code>nose</code>、<code>left_ear</code>、<code>right_ear</code>、<code>neck</code>、<code>body_center</code>、<code>tail_base</code></td></tr>
<tr><th>初始权重</th><td>Ultralytics <code>yolo26n-pose.pt</code>（在 COCO 关键点上预训练）；六个关键点的姿态输出头重新初始化</td></tr>
<tr><th>参数量</th><td>2,522,145；每帧（960 px）16.0 GFLOPs</td></tr>
<tr><th>输入 / 输出</th><td>960 × 960 RGB 图像 → 端到端（免 NMS）输出头给出形状为 (1, 300, 24) 的张量，与 MousePose6 相同</td></tr>
<tr><th>训练数据</th><td>7,586 张训练图：由 DooM 生成的四点白鼠数据集中的 5,899 帧（9 个实验室有白鼠，另有 4 个实验室只提供深色鼠图像）、690 张放大裁剪图、179 张背景裁剪图，以及 818 帧由更大模型标注的图</td></tr>
<tr><th>标签</th><td>DooM 各实验室的姿态轨迹（鼻尖、两耳、尾根），颈部和身体中心按同一条规则推算；另有 YOLO26m 教师模型的预测，经过过滤。<strong>不是人工标注。</strong></td></tr>
<tr><th>软件</th><td>Ultralytics 8.4.203、PyTorch 2.14.1（CUDA 13.0）、Python 3.13；Google Colab 上一块 NVIDIA RTX PRO 6000 Blackwell GPU</td></tr>
<tr><th>训练运行</th><td><code>n960_6kp_v1</code>，150 个 epoch；checkpoint SHA-256 <code>5399e7fd…e0d0de</code></td></tr>
<tr><th>导出</th><td>Core ML ML Program，coremltools 9.0，<code>quantize=8</code>，<code>nms=False</code>；2026 年 11 月 6 日</td></tr>
<tr><th>模型包里的许可字段</th><td>AGPL-3.0（导出时由 Ultralytics 写入；见<a href="/RodentFlow/zh/tutorials/citations.html#licences">许可</a>）</td></tr>
</table>

来源：模型包元数据；notebook `WhiteMouse_n960_6kp_Train`；App 源码（`Shared/PoseEngine/PoseModels.swift`）。

## 数据：DooM 中的白鼠 {#data}

*Days of our Mice*（DooM）收集了 15 个实验室的俯视双鼠互动视频，每段都附有该实验室自己的姿态轨迹和逐帧行为标注（[Marks 等 2026](./citations.md#r-doom)；数据集在 EMBER-DANDI，[dandiset 000564](./citations.md#r-doom-data)）。实验室用代号表示，如 *SparklingTapir*。

训练 notebook 的起点是一个由更早的 notebook 从 DooM 生成的四点白鼠数据集（“数据集 A”：鼻尖、左耳、右耳、尾根），已经**按视频**划分好训练、验证和测试集。那个更早的 notebook 以及它训练的教师模型不在本页审阅的材料中；下面写的是训练 notebook 中能看到的内容。

| 实验室 | 训练图（白鼠只数） | 验证 | 测试 |
|---|---|---|---|
| DeliriousFly | 624（624） | 78 | 78 |
| InvincibleJellyfish | 600（600） | 73 | 75 |
| JovialSwallow | 610（610） | 80 | 80 |
| LyricalHare | 609（609） | 84 | 84 |
| PleasantMeerkat | 640（1,280） | 64 | 64 |
| ReflectiveManatee | 624（624） | 78 | 78 |
| SparklingTapir | 608（608） | 72 | 68 |
| TranquilPanther | 699（639） | 77 | 77 |
| UppityFerret | 606（606） | 78 | 78 |
| CautiousGiraffe、ElegantMink、GroovyShrew、NiftyGoldfinch | 279（无） | 33 | 33 |
| **合计** | **5,899（6,200）** | **717** | **715** |

9 个实验室提供白鼠；PleasantMeerkat 的图里有两只白鼠。最后 4 个实验室只拍了深色鼠：它们的图里没有白鼠，用来教模型**不要**把深色鼠或场地报成白鼠。标签是各实验室追踪器的输出，在生成数据集 A 时经过过滤，不是人工标注。

## 第 1 步 · 从四个点到 App 的六个点 {#keypoints}

App 的模型输出六个点，数据集 A 只有四个。缺的两个点由其他点推算，所有实验室用同一条规则：

- **颈部** = E + a·(E − 鼻尖) + b·(尾根 − E)，E 为两耳中点。两耳置信度不都够时，颈部 = 鼻尖 + c·(尾根 − 鼻尖)。
- **身体中心** = 颈部和尾根的中点，与 MousePose6 的定义相同。不使用部分实验室自己追踪的身体中心点，因为它们的定义互不相同。

a、b 在 DooM 中追踪了颈部点的 6 个实验室上拟合（33,402 帧，先去掉追踪错误）：**a = 0.127，b = 0.057，c = 0.308**。按实验室留一验证，推算的颈部与各实验室追踪的颈部之间的误差（单位：体长 L，鼻尖到尾根）如下：

| 留出的实验室 | 帧数 | 用两耳的规则 | 不用两耳 | 直接用两耳中点 |
|---|---|---|---|---|
| InvincibleJellyfish | 7,085 | 0.024 | 0.123 | 0.081 |
| JovialSwallow | 6,477 | 0.121 | 0.123 | 0.147 |
| TranquilPanther | 6,472 | 0.029 | 0.097 | 0.059 |
| CautiousGiraffe | 6,588 | 0.035 | 0.094 | 0.066 |
| ElegantMink | 6,426 | 0.016 | 0.106 | 0.077 |
| AdaptableSnail | 354 | 0.132 | 0.225 | 0.094 |

这条规则与大多数实验室的颈部很接近（0.016–0.035 L），但与 JovialSwallow 和 AdaptableSnail 的颈部不接近，它们的颈部点位置不同。同一条规则（存为 `rodentflow.label_neck_rule`）也用于[一黑一白双鼠模型](./dyad-bw.md)，所以两个模型放置颈部和身体中心的方式相同。

## 第 2 步 · 放大裁剪、背景裁剪和灰度 {#augment}

- **放大裁剪。**一半只有一只白鼠的训练图，会再生成一张以小鼠为中心附近的正方形裁剪图，大小使小鼠约占边长的 19 %（体长 ÷ 0.19，再乘 0.8–1.25，中心随机偏移最多 ±20 %）。对 PleasantMeerkat 等小鼠较小的实验室，这让模型看到更大的小鼠。验证集和测试集各生成一张不带随机的裁剪图（`val_app`、`test_app`），只用于评估。这些裁剪是为一个开发版本的“放大跟随”模式设计的；**RodentFlow 2.1 不做放大跟随**：它和其他姿态模型一样，把标定的场地区域交给这个模型。
- **背景裁剪。**一半只有深色鼠的图也随机裁一张，让模型在放大的画面里同样把深色鼠和场地当作背景。
- **灰度。**一半训练图转为灰度，因为 App 默认先把画面转成灰度再识别。

每个随机选择都由图片名决定，重新生成数据集时得到相同的图。

## 第 3 步 · 用更大的模型标注更多帧 {#teacher}

一个更大的 YOLO26m-pose 模型（约 2,100 万参数，640 px，与数据集 A 相同的四个点），在更早的 notebook 中训练，**只在训练视频上**标注新帧：307 段视频，每段 12 帧，与数据集 A 已有的帧至少相隔 1 秒。每帧先裁剪到该视频轨迹覆盖的范围，去掉侧视画面和旁边的笼子。

教师模型分两遍标注：先在整张图上以 1,280 px 运行，再在每只小鼠周围的正方形裁剪图上以 640 px 运行，关键点取第二遍的结果。只有以下规则全部满足的帧才保留：

| 规则 | 原因 |
|---|---|
| 找到的白鼠数（置信度 > 0.5）等于 DooM 元数据中的白鼠数，且没有其他 > 0.3 的框 | 漏标的白鼠会被学成背景；多出的框可能是深色鼠 |
| 四个关键点的置信度都 ≥ 0.6 | |
| 骨架像一只鼠：两耳在头侧、分开、离体轴不远；左耳在动物自己的左边 | 与数据集 A 的检查相同 |
| 体长在该视频中位数的 0.6–1.6 倍 | 去掉只框住半只鼠或框住两只鼠的情况 |

尝试了 3,684 帧，**保留 818 帧（22 %）**。丢弃最多的原因是数量不符（2,746），其次是骨架（52）、关键点置信度（40）、二次定位失败（21）和体长（7）。

## 第 4 步 · 训练集 {#dataset}

| 划分 | 数据集 A | 放大裁剪 | 背景裁剪 | 教师标注 | 合计 |
|---|---|---|---|---|---|
| 训练 | 5,899 | 690 | 179 | 818 | 7,586 |
| 验证 | 717 | 175 | — | — | 892 |
| 测试 | 715 | 154 | — | — | 869 |

验证和测试视频从未向训练提供教师标注帧或裁剪图。训练图中体长中位数为图片长边的 0.190，存入模型包的 `rodentflow.body_fraction`。

## 第 5 步 · 训练 {#train}

<table class="rf-kv">
<tr><th>网络</th><td>YOLO26n-pose，960 px，与 MousePose6 的大小和输入相同</td></tr>
<tr><th>训练安排</th><td>150 个 epoch（早停耐心 30；150 个全部跑完），batch 由 AutoBatch 决定，优化器 <code>auto</code>，余弦学习率，最后 15 个 epoch 关闭 mosaic，随机种子 2026，确定性模式</td></tr>
<tr><th>数据增强</th><td>左右和上下翻转（概率各 0.5，同时交换左右耳），缩放 0.5，平移 0.1；不旋转（会让框变松），不做 mixup（会把深色鼠和白鼠叠在一起）；颜色只做亮度增强（<code>hsv_v</code> 0.4）</td></tr>
<tr><th>早停依据</th><td>验证视频及其裁剪图</td></tr>
</table>

在 892 张验证图（917 只小鼠）上，最佳 checkpoint 的框 mAP50 为 0.994、mAP50-95 为 0.790，姿态 mAP50 为 0.933、mAP50-95 为 0.610。

## 第 6 步 · 在留出视频上评估 {#eval}

测试图来自从未用于训练、早停或任何选择的视频。它们与训练视频来自**相同的实验室**；这次测试没有包含没见过的实验室。标签是各实验室的轨迹，所以分数衡量的是与这些追踪器的一致程度。学生模型（960 px）和教师模型（640 px）在同样的图上运行。

| 测试集 | 模型 | 小鼠数 | 检出 | PCK@0.05 L | PCK@0.1 L | PCK@0.2 L | 颈部误差 | 身体中心误差 |
|---|---|---|---|---|---|---|---|---|
| 测试图 | **WhiteMousePose6** | 740 | **99.3 %** | 0.818 | **0.958** | 0.985 | 0.022 L | 0.019 L |
| | 教师（YOLO26m，640） | 740 | 73.1 % | 0.621 | 0.867 | 0.962 | 0.037 L | 0.030 L |
| 放大裁剪的测试图 | **WhiteMousePose6** | 154 | **98.7 %** | 0.758 | **0.916** | 0.977 | 0.026 L | 0.029 L |
| | 教师 | 154 | 79.2 % | 0.574 | 0.857 | 0.949 | 0.038 L | 0.043 L |

*检出*：标注的白鼠中被检测框（IoU ≥ 0.5）配上的比例。*PCK@α*：已检出小鼠的四个追踪关键点中，误差在 α 个体长以内的比例。颈部和身体中心误差是相对同样推算的点的中位数。

各实验室测试图的 PCK@0.1 L：DeliriousFly 0.925、InvincibleJellyfish 0.980、JovialSwallow 0.972、LyricalHare 0.943、PleasantMeerkat 0.978、ReflectiveManatee 0.981、SparklingTapir 0.915、TranquilPanther 0.982、UppityFerret 0.932。

在 33 张只有深色鼠的测试图上，两个模型都没有报出白鼠（置信度 > 0.5）。

两个模型各用自己的输入尺寸运行：学生模型 960 px，教师模型 640 px。

## 第 7 步 · 导出 {#export}

```python
# 摘自 WhiteMouse_n960_6kp_Train 第 7 节（导出在单独的进程中运行，使用 numpy 2.3.5）
path = YOLO(best_pt).export(format="coreml", imgsz=960, quantize=8, nms=False, batch=1)
m = ct.models.MLModel(path, skip_model_load=True)
m.user_defined_metadata.update({
    "rodentflow.layout": "white6",
    "rodentflow.keypoints": "nose,left_ear,right_ear,neck,body_center,tail_base",
    "rodentflow.body_fraction": "0.19046",
    "rodentflow.label_neck_rule": '{"a": 0.12747, "b": 0.05716, "c": 0.30763}',
    "rodentflow.teacher_sha256": "...", "rodentflow.checkpoint_sha256": "...",
    "rodentflow.train_imgsz": "960", "rodentflow.epochs_run": "150", "rodentflow.exported": "..."})
m.save("WhiteMousePose6_960_int8.mlpackage")
```

notebook 检查模型包只有一个 960 × 960 图像输入和一个 (1, 300, 24) float32 输出，并检查每个元数据项都已写入。它还写出 24 张测试输入及其 PyTorch 预测，以及一个在 Mac 上运行 Core ML 模型包并比较结果的脚本（`verify_on_mac.py`）。检查方法见[教程 4](./app-integration.md#parity)。

## 在 App 中 {#app}

- 单只小鼠选**小鼠毛色：白色**（iPhone 和 iPad：选好范式后选择，或在“信息”页的识别设置中修改；Mac：在每段视频标定的识别设置中）。改毛色需要重新识别。
- 模型得到的画面与 MousePose6 相同：标定的场地区域，默认转为灰度，由 Vision 等比缩放补边到 960 × 960。解码、清洗和分析完全相同。
- 模型缺失或加载失败时，这段视频不会被识别；App 不会改用别的模型。
- Methods 文字、单次 JSON 和组间长格式表都写明所用模型。各组用了不同模型时（例如 C57BL/6 用 MousePose6，BALB/c 用 WhiteMousePose6），组间页会提示：模型之间漏检多少的差别会和品系差别混在一起。

## 适用范围与许可 {#limits}

- 标签是 DooM 各实验室的轨迹，所以测试分数给出的是在同样 9 个实验室的留出视频上与这些轨迹的一致程度。
- 颈部由双耳和身体按固定规则推算，与 MousePose6-DyadBW 相同。
- 训练视频来自 DooM 数据集，其使用条款见 EMBER 记录（见[许可汇总](./citations.md#licences)）。

## 引用 {#cite}

注明版本的 RodentFlow、Ultralytics YOLO26，以及 DooM 数据集和论文；见[如何引用](./citations.md#use-white)。
