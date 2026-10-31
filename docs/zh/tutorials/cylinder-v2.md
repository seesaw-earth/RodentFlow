# 把实验室的 DeepLabCut 模型蒸馏成快速的 YOLO 姿态模型

<p class="rf-eyebrow">教程 2 · CYLINDERMOUSEPOSEV2</p>

CylinderMousePoseV2 在圆筒实验中追踪小鼠的四爪、鼻、嘴和尾根，供 RodentFlow 的 RodentLimb 流程使用。它的训练数据是几百帧人工标注加上两万帧经过仔细清洗的 DeepLabCut 预测。

<Badge type="info" text="YOLO26s-pose" /><Badge type="info" text="7 个关键点" /><Badge type="info" text="640 px" /><Badge type="tip" text="Core ML · FP32" />

## 模型卡 {#card}

<table class="rf-kv"> <tr><th>发布文件</th><td><code>CylinderMousePoseV2.mlpackage</code>（37.67 MiB）；元数据版本 2.0</td></tr> <tr><th>关键点（输出顺序）</th><td><code>L_fore_paw</code>、<code>L_hind_paw</code>、<code>R_fore_paw</code>、<code>R_hind_paw</code>、<code>tail_base</code>、<code>nose</code>、<code>mouth</code>，与实验室 DeepLabCut 的 <code>config.yaml</code> 顺序一致；<code>flip_idx</code> = <code>[2, 3, 0, 1, 4, 5, 6]</code></td></tr> <tr><th>初始权重</th><td>Ultralytics <code>yolo26s-pose.pt</code>（COCO 预训练）；9,783,360 个参数</td></tr> <tr><th>输入 / 输出</th><td>640 × 640 RGB → 原始输出头张量 (1, 26, 8400)；模型内不含 NMS</td></tr> <tr><th>训练数据</th><td>实验室的圆筒实验录像：543 帧人工标注（使用两次）+ 来自 506 段录像的 20,000 帧清洗后 DeepLabCut 伪标签</td></tr> <tr><th>教师模型</th><td>DeepLabCut ResNet-50 模型 <code>DLC_resnet50_cylinder_DLCJan2shuffle1_44000</code></td></tr> <tr><th>软件</th><td>Ultralytics 8.4.177、PyTorch 2.11.0、coremltools 9.0；运行编号 <code>20261014_1156_dlc_distill</code></td></tr> <tr><th>精度</th><td>FP32（导出时未量化）</td></tr> <tr><th>模型包里记录的测试误差</th><td><code>test_err_body_length</code>：“0.035 (v1-style manual-only baseline 0.050)”</td></tr> </table>
来源：模型包元数据；notebook `Cylinder_YOLO26_v2_DLC_Distill` 与 `Cylinder_YOLO26_Pose_Training`（v1）；App 源码 `Analysis/PoseTypes.swift`。

## 为什么要蒸馏 DeepLabCut？ {#why}

实验室已经有一个分析过数百段圆筒视频的 DeepLabCut 模型。DeepLabCut 的关键点准确、贴合本项目，但它的 ResNet-50 网络和 Python 运行环境放不进离线 Mac App；YOLO26 姿态模型则可以顺利导出为 Core ML。蒸馏就是把 DeepLabCut 已经追踪过的大量视频变成小模型的训练数据。需要控制两个风险：学生模型可能照搬教师的错误；大量简单、重复的帧可能淹没困难姿势。下面每一步都针对其中之一。

## 实验室的 DeepLabCut 项目 {#data}

- **人工标注：**DeepLabCut 项目 38 个 `labeled-data` 文件夹中共 743 帧。
- **教师预测：**每段分析过的视频有一个 DeepLabCut `.h5` 轨迹文件。把每段录像与其 `downsized_` 副本合并后共有 524 段不同录像，其中 519 段有上述 scorer 的轨迹。视频帧率 60 fps。
- **数据存放位置：**实验室在 Google Drive 上的项目。本教程无法确定这些录像是否已公开；如已发表（例如作为带 DOI 的数据集），请引用该数据集。

## 第 1 步 · 无泄漏的划分 {#split}

划分只在有人工标注的录像组上进行，保证每一帧测试图都是学生模型从未见过的录像中的人工标注。同一录像的原始版和 `downsized_` 版算作一组。

| 划分 | 人工标注帧 | 录像组 | 用途                                               |
|------|------------|--------|----------------------------------------------------|
| 训练 | 543        | 28     | M0、阶段 A（×2）、阶段 B                           |
| 验证 | 120        | 6      | 在 `best.pt` 与 `last.pt` 之间选择，并选出最终模型 |
| 测试 | 80         | 4      | 只用于报告结果                                     |

DeepLabCut 伪标签只取自验证组和测试组以外的录像。第 1 版曾把 `downsized_` 副本当作单独录像；v2 notebook 发现 v1 有 39 帧训练图来自 v1 的验证或测试录像，v2 的分组消除了这一泄漏。

## 第 2 步 · 清洗 DLC 轨迹 {#clean}

第 1 版只要 7 个点中至少 5 个的 likelihood ≥ 0.95 就接受一帧，95.7 % 的帧都能通过。第 2 版结合整条轨迹判断每一帧，任何一条不满足就丢弃：

| 规则     | 设置                                                                                                                        |
|----------|-----------------------------------------------------------------------------------------------------------------------------|
| 可见性   | likelihood ≥ 0.95 → 可见；\< 0.50 → 遮挡；只要有一个点落在两者之间就丢弃整帧，避免模型学到错误的“不可见”信号                |
| 点数     | 至少 4 个可见点                                                                                                             |
| 时序跳点 | 某可见点偏离其 7 帧滚动中值超过 0.15 个中位体长                                                                             |
| 左右互换 | 左、右爪同时跑到尾根→鼻体轴的另一侧（相对于该视频中的通常位置；边距 0.05 体长；体长 \< 0.5 倍中位数时，如直立，不做此检验） |
| 几何     | 鼻—嘴距离 ≤ 0.35 体长；体长为视频中位数的 0.30–1.60 倍；高置信点在画面内                                                    |

在 34,292,020 帧 DeepLabCut 结果中，v1 规则会接受 32,827,454 帧（95.7 %），v2 规则保留 24,362,080 帧（71.0 %）。

## 第 3 步 · 选出 20,000 帧 {#select}

1.  候选：清洗后相互间隔至少 10 帧，每段视频最多 1,500 帧 → 752,692 个候选。
2.  姿态描述：以尾根为原点、按体轴旋转、再除以该视频中位体长，这样直立（短缩）姿势与四足着地姿势仍能区分。
3.  聚类：k-means 分成 60 个姿态簇，另加一组缺少鼻或尾根的帧。
4.  均衡抽取：每簇配额相同，在视频之间轮流取帧，每段视频最多 120 帧，多抽 30 % → 来自 506 段录像的 26,000 帧候选池。

notebook 还检查了按帧号跳读与顺序读取得到的画面是否一致，因为 DeepLabCut 的帧号是按顺序解码计数的。检查通过，因此使用跳读。

## 第 4 步 · 第二意见：一致性过滤 {#agree}

只用人工标注训练的 YOLO 模型（下文的 M0）独立于 DeepLabCut。它对候选池中每一帧做预测。只要 M0 对某个点有把握（置信度 ≥ 0.5）且该点与 DeepLabCut 相距超过 0.25 个体长，这一帧就被剔除并列入人工复核清单。M0 处理不了的帧*保留*，以免过滤后偏向简单姿势。共剔除 903 帧，留下 20,000 帧伪标签。

标签按 YOLO 姿态格式写出，检测框规则与 v1 相同：可见关键点的外包框，每个方向向外扩展“图像尺寸的 5.5 %”与“关键点跨度的 30 %”中较大者。

## 第 5 步 · 三个训练阶段 {#train}

| 阶段              | 起点              | 训练数据                                         | 轮数（patience） | 学习率           |
|-------------------|-------------------|--------------------------------------------------|------------------|------------------|
| M0 · 仅人工       | `yolo26s-pose.pt` | 543 帧人工标注                                   | 150（40）        | 1e-3             |
| A · 伪标签 + 人工 | `yolo26s-pose.pt` | 20,000 帧伪标签 + 543 帧人工 × 2（共 21,086 条） | 60（20）         | 1e-3             |
| B · 人工微调      | 阶段 A            | 543 帧人工标注                                   | 60（25）         | 2e-4，无 warm-up |

    COMMON_TRAIN = dict(imgsz=640, batch=16, seed=42, deterministic=True, optimizer='AdamW', cos_lr=True,
                        mosaic=0.5, mixup=0.0, fliplr=0.5, flipud=0.0, degrees=10.0, translate=0.06, scale=0.25)
    model = YOLO('yolo26s-pose.pt')
    model.train(data='data_stageA_pseudo_plus_manual.yaml', epochs=60, patience=20, lr0=1e-3, **COMMON_TRAIN)

7 个点配合 Ultralytics 默认的 OKS sigma 时，姿态 mAP50-95 已在 0.92–0.96 左右，区分不出模型好坏。因此每个阶段结束后，notebook 按验证帧上的平均关键点误差在 `best.pt` 与 `last.pt` 之间选择，最终模型也按同样方式选出。阶段 A 的验证误差最低（0.0339 体长；B 为 0.0343，M0 为 0.0503），成为 CylinderMousePoseV2。

## 第 6 步 · 用人工标注评估 {#eval}

所有误差都以人工标注为参照，并除以体长（人工标注的鼻—尾根距离）。*帧误差*是一帧内各点误差的平均；漏检的小鼠按 1 个体长计。PCK@*t* 是误差不超过 *t* 个体长的点所占比例。左右互换率是“把预测的左右爪对调后反而更接近人工标注”的帧所占比例。95 % 置信区间来自 2,000 次 bootstrap 重抽样。

| 模型（测试集）       | 帧数 | 帧误差 \[95 % CI\]      | 中位误差 | 第 90 百分位 | PCK@0.05 | PCK@0.1 | 前爪 / 后爪左右互换 |
|----------------------|------|-------------------------|----------|--------------|----------|---------|---------------------|
| M0 · 仅人工          | 80   | 0.0502 \[0.040, 0.062\] | 4.29 px  | 12.93 px     | 0.762    | 0.919   | 6.3 % / 6.4 %       |
| A · 发布版本         | 80   | 0.0346 \[0.025, 0.046\] | 2.76 px  | 6.60 px      | 0.919    | 0.956   | 6.3 % / 6.4 %       |
| B · 人工微调         | 80   | 0.0349 \[0.026, 0.047\] | 3.11 px  | 6.40 px      | 0.923    | 0.958   | 6.3 % / 6.4 %       |
| DLC 教师（仅供参考） | 60   | 0.0211 \[0.018, 0.024\] | 2.70 px  | 5.03 px      | 0.965    | 0.995   | 1.7 % / 0.0 %       |

所有模型在每一帧测试图中都检出了小鼠。DeepLabCut 只能在 80 帧中的 60 帧上比较（能对应上视频版本和帧号的那些）。

**在同一批 80 帧测试图上的配对比较**（帧误差之差，单位为体长，bootstrap 95 % CI）：

- A − M0 = −0.0156 \[−0.019, −0.012\]：DeepLabCut 伪标签明显有帮助。
- B − A = +0.0003 \[−0.001, 0.001\]：再用人工标注微调没有可测的差别。
- B − DLC 教师 = +0.0112 \[0.004, 0.021\]（60 帧）：教师在这些帧上仍更准，但 DeepLabCut 很可能训练时就见过这些人工标注帧，所以它的数字偏乐观。

爪子左右互换率在 M0、A、B 之间没有变化（前爪 6.3 %，后爪 6.4 %）。蒸馏没有解决这个问题；对于肢体使用不对称性这类指标，它比平均误差更重要。

## 第 7 步 · 导出 {#export}

    import json
    from ultralytics import YOLO
    import coremltools as ct

    # 先把 .pt 复制为 CylinderMousePoseV2.pt，导出的模型包就会同名
    exported = YOLO('CylinderMousePoseV2.pt').export(format='coreml', imgsz=640)   # FP32，原始输出头，无 NMS

    m = ct.models.MLModel(exported, skip_model_load=True)     # 只改元数据
    m.short_description = ('Cylinder mouse pose v2: YOLO26s-pose, DLC-distilled '
                           '(20k cleaned pseudo-labels + 543 manual), 7 keypoints')
    m.version = '2.0'
    m.author = 'Cylinder YOLO26 v2 pipeline'
    m.user_defined_metadata.update({
        'keypoints': json.dumps(['L_fore_paw', 'L_hind_paw', 'R_fore_paw', 'R_hind_paw', 'tail_base', 'nose', 'mouth']),
        'input_size': '640',
        'output_shape': '(1, 26, 8400)  # 4 box + 1 conf + 7x3 keypoints',
        'source_run': '20261014_1156_dlc_distill',
        'test_err_body_length': '0.035 (v1-style manual-only baseline 0.050)',
    })
    m.save('CylinderMousePoseV2_final.mlpackage')    # 之后改名回 CylinderMousePoseV2.mlpackage

摘自 `Cylinder_YOLO26_v2_DLC_Distill` 最后的导出单元（Ultralytics 8.4.177，coremltools ≥ 9.0）。发布的模型包没有量化，所以比 MousePose6 大约 14 倍。把训练运行编号和测试误差写进模型包是个好习惯：以后任何人都能查出 App 里装的是哪个模型。

notebook 还导出了 200 帧供人工复核（主动学习）：M0 与 DeepLabCut 分歧最大的帧，以及每种剔除原因的示例。修正后它们可以作为新的*训练*标注，但不能作为测试标注，因为同一录像的其他帧已经在训练集里。

## 第 1 版及改动 {#v1}

第 1 版（`Cylinder_YOLO26_Pose_Training`）使用相同的网络和训练设置，训练 150 轮，训练图 2,715 张：543 帧人工标注加上约每秒 1 帧抽取的 2,172 帧 DeepLabCut 结果（至少 5 个点的 likelihood ≥ 0.95）。验证（120）和测试（80）帧都是人工标注。第 2 版改了四件事：无泄漏分组、基于轨迹的清洗、按姿态均衡抽样、独立的一致性过滤；并把 Ultralytics mAP 换成按体长归一化的误差和配对置信区间。v1 模型还在一个公开的 PhysioNet 圆筒直立数据集中的一段视频上做过定性演示；该数据集没有用于训练。

## 局限 {#limits}

- 一个实验室、一套装置、一种相机设置。其他圆筒、光照、帧率或品系都未经测试。
- 测试集只有来自 4 个录像组的 80 帧，置信区间相应较宽。
- 约 6 % 的测试帧左右爪互换。报告不对称性之前请复核爪子身份。
- 伪标签继承了 DeepLabCut 的系统性偏差；一致性过滤只能去掉明显的分歧。
- RodentFlow 也把这个模型用于基于肢体的悬尾和步态流程。这些视频不在训练数据中，使用前需验证。
- 这里没有报告由模型得出的圆筒实验评分（例如爪触壁）与人工评分的比较。

## 需要引用什么 {#cite}

请引用 RodentFlow（注明版本）、Ultralytics YOLO26、作为教师模型的 DeepLabCut（Mathis 等 2018；Nath 等 2019），以及实验室录像（如已发表）。见[引用页](/zh/tutorials/citations#use-cylinder)。
