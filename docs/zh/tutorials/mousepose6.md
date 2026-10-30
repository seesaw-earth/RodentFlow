# 用四个公开数据集训练俯视小鼠姿态模型

<p class="rf-eyebrow">教程 1 · MOUSEPOSE6_960_INT8</p>

MousePose6 是 RodentFlow 中 RodentPose 流程使用的模型。它只用公开发表的视频训练，标签来自数据集作者随视频一起发布的姿态轨迹。

<Badge type="info" text="YOLO26n-pose" /><Badge type="info" text="6 个关键点" /><Badge type="info" text="960 px" /><Badge type="tip" text="Core ML · 8 位权重" />

## 模型卡 {#card}

<table class="rf-kv"> <tr><th>发布文件</th><td><code>MousePose6_960_int8.mlpackage</code>（2.76 MiB）</td></tr> <tr><th>任务</th><td>单一类别 <code>mouse</code>；六个关键点，顺序为 <code>nose</code>、<code>left_ear</code>、<code>right_ear</code>、<code>neck</code>、<code>body_center</code>、<code>tail_base</code></td></tr> <tr><th>初始权重</th><td>Ultralytics <code>yolo26n-pose.pt</code>（YOLO26 nano 姿态模型，由 Ultralytics 在 COCO 关键点上预训练）</td></tr> <tr><th>参数量</th><td>2,522,145</td></tr> <tr><th>输入 / 输出</th><td>960 × 960 RGB 图像 → 端到端（免 NMS）输出头给出形状为 (1, 300, 24) 的张量</td></tr> <tr><th>训练数据</th><td>四个公开数据集中 52 段视频的 8,840 张图（训练 6,140 / 验证 1,350 / 测试 1,350）</td></tr> <tr><th>标签</th><td>数据集随附的姿态预测（ETH 为 DeepLabCut，JABS 为 JAX 姿态网络），经过质量过滤。<strong>不是人工标注。</strong></td></tr> <tr><th>软件</th><td>Ultralytics 8.4.176、PyTorch 2.11.0（CUDA 13.0）、Python 3.13；Google Colab 上一块 NVIDIA RTX PRO 6000 Blackwell GPU</td></tr> <tr><th>导出</th><td>Core ML ML Program，coremltools 9.0，<code>quantize=8</code>，<code>nms=False</code>；模型包日期 2026 年 10 月 13 日</td></tr> <tr><th>模型包里的许可字段</th><td>AGPL-3.0（导出时由 Ultralytics 写入；见<a href="/RodentFlow/zh/tutorials/citations.html#licences">许可</a>）</td></tr> </table>
来源：模型包元数据；notebook `1012_MousePose_Dataset_Builder_v1`、`MousePose_YOLO_Train_v1`、`MousePose_iOS_Export_v1`。

## 四个数据来源 {#sources}

四个数据集都发布了单只小鼠的俯视视频和对应的姿态文件。构建数据集的 notebook 从每个数据集中下载一部分视频，读取姿态文件，再转换成 YOLO 标签。

| 来源                                                                                                 | 记录                                                                       | 随附姿态文件                              | 许可            | 视频 | 训练 / 验证 / 测试图像 |
|------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------|-------------------------------------------|-----------------|------|------------------------|
| ETH Zurich BehaviorFlow：旷场 [\[D1\]](/zh/tutorials/citations#r-vz2023)                      | Zenodo [10.5281/zenodo.8186065](https://doi.org/10.5281/zenodo.8186065)    | DeepLabCut，13 点                         | CC BY 4.0       | 20   | 1,680 / 360 / 360      |
| ETH Zurich BehaviorFlow：埋珠、明暗箱、恐惧条件箱 [\[D2\]](/zh/tutorials/citations#r-vz2024d) | Zenodo [10.5281/zenodo.11235068](https://doi.org/10.5281/zenodo.11235068)  | DeepLabCut，13 点                         | CC BY 4.0       | 12   | 960 / 240 / 240        |
| JAX Kumar 实验室品系调查，旷场 [\[D3\]](/zh/tutorials/citations#r-jabs-ss)                    | Harvard Dataverse [10.7910/DVN/SAPNJG](https://doi.org/10.7910/DVN/SAPNJG) | JAX 姿态网络，12 点（`*_pose_est_v6.h5`） | CC BY-NC-SA 4.0 | 12   | 2,000 / 500 / 500      |
| JAX Kumar 实验室 BxD 调查，旷场 [\[D4\]](/zh/tutorials/citations#r-jabs-bxd)                  | Harvard Dataverse [10.7910/DVN/RQYI04](https://doi.org/10.7910/DVN/RQYI04) | JAX 姿态网络，12 点（`*_pose_est_v6.h5`） | CC BY-NC-SA 4.0 | 8    | 1,500 / 250 / 250      |
| 合计                                                                                                 |                                                                            |                                           |                 | 52   | 6,140 / 1,350 / 1,350  |

每张图中只有一只小鼠。JABS 视频每段取 250 帧，ETH 视频每段取 120 帧。

ETH 的录像及其 DeepLabCut 轨迹见 von Ziegler 等 2024 年发表在 *Nature Methods* 上的论文，数据集正是为该分析框架发布的。JAX 视频来自 JAX 动物行为系统（JABS），关键点由 JAX 基于 HRNet 的姿态网络生成（Sheppard 等 2022），数据集在 Choudhary 等 2026（*eLife*）中有介绍。完整文献见[引用页](/zh/tutorials/citations)。

::: info
**计划中的第五个来源没有用上。**构建脚本还列出了 Sturman 等 2020 的高架十字迷宫视频（Zenodo 3608657），但构建时每次下载都返回 HTTP 404，所以这些视频*不在*训练集中。其中一部分后来被用于一次外部预试验（见[下文](#external)）。
:::
::: warning
**两个 JAX 数据集为 CC BY-NC-SA 4.0：非商业、相同方式共享。**两个 Harvard Dataverse 记录（品系调查 1.2 版、BxD 1.0 版，2026 年 10 月 20 日查看）都采用这一许可：须署名、不得商业使用、改编作品须以相同许可共享。MousePose6 的 6,140 张训练图中有 3,500 张（连同关键点）来自这两个数据集。训练出的权重在法律上是否算“改编作品”尚无定论，但稳妥的理解是：MousePose6 不应用于商业用途或商业分发；由这些数据集得到的帧或标签只能以 CC BY-NC-SA 4.0 再分发。这也与模型包里写入的允许商业使用的 AGPL-3.0 许可不太协调。在任何商业分发带有该模型的 RodentFlow 之前，请先征得 JAX（Kumar 实验室）的许可，或只用 CC BY 4.0 的 ETH 数据（2,640 张训练图）重新训练。以上不构成法律意见。
:::

## 第 1 步 · 统一关键点 {#keypoints}

两个实验室使用不同的关键点方案：JAX 网络预测 12 个点，ETH 的 DeepLabCut 模型预测 13 个点。如果取并集训练，一半图像会缺一半的点，所以只保留每个来源都有的点（方案 `core6`），尾巴中段和尾尖一律去掉。

| core6 点      | JAX JABS（12 点）                              | ETH DeepLabCut（13 点）                                                           |
|---------------|------------------------------------------------|-----------------------------------------------------------------------------------|
| `nose`        | `nose`                                         | `nose`                                                                            |
| `left_ear`    | `left_ear`                                     | `earl`                                                                            |
| `right_ear`   | `right_ear`                                    | `earr`                                                                            |
| `neck`        | `base_neck`                                    | `neck`                                                                            |
| `body_center` | 两者统一推导：`neck` 与 `tail_base` 的中点     |                                                                                   |
| `tail_base`   | `base_tail`                                    | `tailbase`                                                                        |
| *舍弃*        | 四只爪、`center_spine`、`mid_tail`、`tip_tail` | `headcentre`、`bodycentre`、`bcl`、`bcr`、`hipl`、`hipr`、`tailcentre`、`tailtip` |

为什么要推导 `body_center`？各来源的身体中心点位置定义不同，直接照搬会让模型学到一个折中位置。几何定义在所有来源中完全一致。推导点的置信度取两个来源点中较低的一个。

    # 摘自 1012_MousePose_Dataset_Builder_v1 第 2、5 节（有删节）
    # JABS 的 pose_est_v6.h5 按 (y, x) 存储，需翻转成 (x, y)
    xy = pts[..., ::-1].astype(np.float32)

    # body_center：所有来源同一定义
    X[..., BODY_CENTER, :] = (X[..., NECK, :] + X[..., TAIL_BASE, :]) / 2
    C[..., BODY_CENTER]    = np.minimum(C[..., NECK], C[..., TAIL_BASE])

## 第 2 步 · 统一“左”的含义 {#leftright}

不同实验室的“左”可能指动物的左，也可能指画面的左；一旦约定相反，水平翻转增强就会悄悄出错。因此构建脚本按俯视几何逐帧重新标注两只耳朵：以颈→鼻为头部轴，位于动物左侧的耳朵（相机不镜像时）记为 `left_ear`。

    def cross2(a, b):
        return a[..., 0] * b[..., 1] - a[..., 1] * b[..., 0]

    head = X[..., NOSE, :] - X[..., NECK, :]            # 头部轴，颈 → 鼻
    body = X[..., NECK, :] - X[..., TAIL_BASE, :]
    cr = cross2(head, X[..., L_EAR, :] - X[..., R_EAR, :])
    checkable = (C[..., L_EAR] >= thr) & (C[..., R_EAR] >= thr) & (np.abs(cr) > 0.02 * np.sum(body**2, -1))
    wrong = checkable & (cr > 0)                        # 约定：正确的一对叉积 < 0
    xa, xb = X[..., L_EAR, :].copy(), X[..., R_EAR, :].copy()
    X[..., L_EAR, :] = np.where(wrong[..., None], xb, xa)   # 交换（置信度同样交换）
    X[..., R_EAR, :] = np.where(wrong[..., None], xa, xb)

notebook 会报告每个来源原本符合该约定的比例。例如第一段 JABS 品系调查视频中，98,672 个可检验帧里有 98.8 % 原本一致，1,218 帧被交换。由此得到的 `flip_idx` 为 `[0, 2, 1, 3, 4, 5]`：水平翻转时交换两只耳朵，其他点不变。

## 第 3 步 · 质量过滤与检测框 {#filter}

标签本身是模型预测，所以要去掉预测看起来不可靠的帧。一只小鼠只有同时满足以下条件才被接受：

- 鼻、颈、身体中心和尾根的置信度高于阈值（JABS 为 0.3，ETH 为 0.6），且都在画面内；
- 体长（鼻到尾根）在该视频中位体长的 0.35–1.6 倍之间，以保留直立姿势；
- 鼻尖和身体中心与前一帧、后一帧相比的跳变都不超过半个中位体长。

只要一帧里有任何一只小鼠不合格，整帧都不用，这样不会出现“有鼠但没标”的图像。低于阈值的点记为不可见。

所有来源使用同一个检测框定义：沿鼻—尾根轴的矩形，鼻前延伸 10 % 体长、尾根后延伸 5 %，两侧各 22 % 体长，再与可见关键点一起取轴对齐外接框。

    L = np.linalg.norm(nose - tail_base); u = (nose - tail_base) / L; n = np.array([-u[1], u[0]])
    front, back = nose + 0.10 * L * u, tail_base - 0.05 * L * u
    corners = np.array([front + 0.22*L*n, front - 0.22*L*n, back + 0.22*L*n, back - 0.22*L*n])
    pts = np.vstack([corners, visible_keypoints])
    x0, y0 = np.clip(pts.min(0), 0, [W, H]); x1, y1 = np.clip(pts.max(0), 0, [W, H])

## 第 4 步 · 按姿态多样性抽帧 {#sampling}

相邻帧几乎一样，长录像里静止的小鼠又占多数。构建脚本每隔 3 帧取一个候选（跳过开头和结尾各 30 帧），把每个合格帧描述为“以身体为中心、按朝向旋转对齐的姿态 + 在场地中的位置”，用 mini-batch k-means 聚类，每簇取一帧，相互至少间隔 15 帧。结果是每段 JABS 视频 250 帧、每段 ETH 视频 120 帧。

## 第 5 步 · 按视频划分 {#split}

在每个来源内部，以整段视频为单位按 70 / 15 / 15 分到训练、验证和测试（随机种子 2026）。同一视频的帧不会出现在两个划分中，测试分数不会被近乎重复的帧抬高。生成的 `dataset.yaml`：

    names: {0: mouse}
    kpt_shape: [6, 3]
    flip_idx: [0, 2, 1, 3, 4, 5]
    kpt_names: {0: [nose, left_ear, right_ear, neck, body_center, tail_base]}
    kpt_oks_sigmas: [0.035, 0.035, 0.035, 0.05, 0.07, 0.05]

OKS sigma 决定姿态 mAP 对每个点的严格程度（越小越严）；位置明确的头部点取最小值。

## 第 6 步 · 训练 {#train}

    from ultralytics import YOLO
    model = YOLO('yolo26n-pose.pt')                  # COCO 预训练的 YOLO26 nano 姿态模型
    model.train(data='dataset.yaml', imgsz=960, epochs=120, patience=30, batch=-1, seed=2026,
                fliplr=0.5, flipud=0.5, degrees=0.0, mosaic=1.0, close_mosaic=10,
                hsv_h=0.0, hsv_s=0.3, hsv_v=0.4, scale=0.5, translate=0.1)

notebook 对数据增强的选择做了说明：

- 左右、上下翻转，因为俯视画面没有固定朝向（翻转时通过 `flip_idx` 交换两耳）；
- 不旋转，因为旋转会把轴对齐框撑大，引入框噪声；
- 不改色相，只轻微改变饱和度和亮度，因为数据里既有红外灰度视频也有彩色视频；
- `scale=0.5`，因为各实验室的场地尺寸、进而小鼠大小差别很大；
- 最后 10 轮关闭 mosaic。

120 轮全部完成。验证集综合指标最好的权重（`best.pt`）被复制为 `best_mousepose.pt`，这就是导出给 App 的文件。另有一次 `mosaic=0.2` 的消融训练，它不是发布的模型。

## 第 7 步 · 评估 {#eval}

在留出的划分上计算了两类指标。请记住：参照点是过滤后的模型预测，不是人工标注。

### Ultralytics 指标

| 划分             | 框 mAP50 | 框 mAP50-95 | 姿态 mAP50 | 姿态 mAP50-95 |
|------------------|----------|-------------|------------|---------------|
| 验证（1,350 张） | 0.942    | 0.798       | 0.859      | 0.665         |
| 测试（1,350 张） | 0.965    | 0.827       | 0.901      | 0.697         |

### 测试集上按来源的误差

对每只参照小鼠，取与其重叠最大的预测框，IoU ≥ 0.5 才算匹配（预测置信度阈值 0.25）。对匹配上的小鼠，notebook 计算每个点到参照点的像素距离，以及除以参照体长 *L*（鼻到尾根）后的相对误差。PCK@*t*L 是误差不超过 *t* × *L* 的可见点所占比例。漏检的小鼠计入检出率，但不计入误差和 PCK。

| 来源                           | 小鼠数 | 检出率 | 中位误差 | PCK@0.05L | PCK@0.1L | PCK@0.2L | 左右耳颠倒 |
|--------------------------------|--------|--------|----------|-----------|----------|----------|------------|
| ETH 埋珠 / 明暗箱 / 恐惧条件箱 | 240    | 1.000  | 1.55 px  | 0.847     | 0.973    | 0.995    | 0.000      |
| ETH 旷场                       | 360    | 1.000  | 1.19 px  | 0.925     | 0.994    | 0.999    | 0.000      |
| JAX BxD                        | 250    | 1.000  | 0.86 px  | 0.911     | 0.979    | 0.991    | 0.016      |
| JAX 品系调查                   | 500    | 0.854  | 1.20 px  | 0.772     | 0.915    | 0.983    | 0.016      |
| 全部                           | 1,350  | 0.946  | 1.17 px  | 0.857     | 0.961    | 0.991    | 0.009      |

来源：`MousePose_YOLO_Train_v1` 第 5 节。置信度高于 0.5 的误检总体为每张图 0.001 个。

JAX 品系调查视频明显偏弱：14.6 % 的参照小鼠没有匹配的预测框。这里的“漏检”指没有预测框与参照框达到 IoU 0.5；notebook 没有进一步分析原因，因此对类似品系调查的视频要格外小心。

在训练用 GPU 上（PyTorch，batch 1）推理耗时 3.2 ms，端到端约每秒 210 帧。这个数字不代表在 Mac 上的速度。

## 第 8 步 · 输入尺寸与导出 {#export}

导出 notebook 先用 PyTorch 权重在测试集上比较 640 与 960 px 输入。规则是：若 640 px 的检出率和 PCK@0.1L 下降都不超过 1 个百分点，就用 640 px。

| 输入尺寸 | 检出率 | PCK@0.1L | 中位误差 |
|----------|--------|----------|----------|
| 640 px   | 0.931  | 0.950    | 1.24 px  |
| 960 px   | 0.946  | 0.961    | 1.17 px  |

640 px 检出率下降 1.5 个百分点、PCK 下降 1.1 个百分点，因此保留 960 px。导出本身只需一行：

    pip install "ultralytics[export-coreml]>=8.4.142"     # 需要 numpy ≤ 2.3.5；本次运行用的是 numpy 2.1.3

    from ultralytics import YOLO
    YOLO('best_mousepose.pt').export(format='coreml', imgsz=960, quantize=8, nms=False)   # INT8
    YOLO('best_mousepose.pt').export(format='coreml', imgsz=960, quantize=16, nms=False)  # 备选 FP16

导出 notebook 保存下来的那次运行强制使用了 640 px；而发布的模型包是 960 px、日期为 2026 年 10 月 13 日，所以它是用同一调用在 960 px 下生成的。该 notebook 还生成了一个 Mac 验证包（300 张测试图和 `validate_on_mac.py`），用于在 macOS 上比较 `.pt`、FP16 和 INT8，规则是“INT8 的 PCK 下降少于约 1 个百分点就用 INT8”。**这次比较的结果不在我们审阅的材料中**，所以发布的 INT8 模型包与 PyTorch 权重的一致性在这里没有记录。[教程 4](/zh/tutorials/app-integration#parity) 介绍了如何完成这项检查。

## 训练数据以外的检验 {#external}

### CalMS21：家笼中两只互动的小鼠

不做微调，直接用 PyTorch 权重处理 CalMS21 *训练集*中 8 段视频的 2,867 帧（每 15 帧取 1 帧），并与 CalMS21 随附的 MARS 关键点比较（映射到相同的 6 个点）。CalMS21 几乎在每个方面都不同于训练数据：两只小鼠、频繁贴身接触、白色 intruder、垫料背景。

| 小鼠           | 检出率 | 中位误差（已检出） | PCK@0.2L（已检出） |
|----------------|--------|--------------------|--------------------|
| Resident（黑） | 0.118  | 30.7 px            | 0.575              |
| Intruder（白） | 0.003  | 67.8 px            | 0.146              |

notebook 的结论：没有新的训练数据，该模型不能用于这类视频。MARS 关键点本身也是模型输出，所以这些数字只说明两者不一致，不说明谁错。

### 高架十字迷宫：5 段视频的预试验

一次预试验用 PyTorch 权重处理了 Sturman 等 2020 中 5 段有人工评分的高架十字迷宫视频，用 RodentPose 的分析代码计算迷宫指标，再与基于 DeepLabCut 的参照计算出的同一指标比较。

| 指标                      | ICC(A,1) | Pearson r |
|---------------------------|----------|-----------|
| 闭臂停留时间              | 0.90     | 0.96      |
| 中央区停留时间            | 0.89     | 0.97      |
| 探头时间                  | 0.91     | 0.98      |
| 探头次数                  | 0.81     | 0.96      |
| 开臂停留时间（%）         | 0.74     | 0.83      |
| 进入开臂次数              | 0.19     | 0.41      |
| 移动距离                  | 0.08     | 0.53      |
| 伸展探察姿势（SAP，次数） | −0.02    | −0.11     |

n = 5 段视频。只有 5 段视频时，每个系数的不确定性都非常大；notebook 自己也说明这是检查数据映射和脚本的预试验，不是结论。

## 局限 {#limits}

- 一半以上的训练图来自 CC BY-NC-SA 4.0 数据集，商业使用受限（见[数据来源](#sources)）。
- 训练标签和测试参照都是模型预测。DeepLabCut、JAX 网络和 MousePose6 共有的系统性误差不会体现在这些分数里。
- 每张图一只小鼠、俯视、来自两个实验室的类旷场场地。其他场地、相机、毛色、垫料或多只动物都在训练数据之外，CalMS21 的检验说明了后果可能有多严重。
- 在 JAX 品系调查视频上检出率较低（0.854）。
- 发布的 INT8 Core ML 模型包与 PyTorch 权重的一致性没有记录。
- 关键点准确不等于行为指标有效；论文中报告的指标需要与人工评分比较验证。

## 需要引用什么 {#cite}

如果发表用 MousePose6 计算的结果，请引用 RodentFlow（注明版本）、Ultralytics YOLO26、四个数据集、介绍这些数据集的论文，以及 DeepLabCut（ETH 的标签是 DeepLabCut 预测）。[引用页](/zh/tutorials/citations#use-mousepose6)列出了具体文献，并给出方法部分的示例段落。
