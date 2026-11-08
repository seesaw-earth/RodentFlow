# 悬尾实验小鼠检测器，以及不用神经网络的追踪方法

<p class="rf-eyebrow">教程 3 · MOUSEDETECTOR</p>

第三个内置模型是用于多格悬尾视频的小型目标检测器。本页介绍模型包记录了什么、App 如何使用它，以及如何为自己的装置训练检测器。

<Badge type="info" text="YOLO11n 检测" /><Badge type="info" text="1 个类别" /><Badge type="info" text="320 px" /><Badge type="tip" text="Core ML · FP16 · NMS" />

## 检测器在 App 中做什么 {#role}

在“悬尾实验 — 多格（Tail Suspension Test — Multi-Chamber）”流程中，一段录像里有几只小鼠分别悬挂在相邻的格子中。检测器在抽取的画面上框出每只小鼠。RodentFlow 用这些框来确定格子位置（使用置信度 ≥ 0.35 的框）、预先勾选至少在两张抽样画面中出现小鼠的格子，并在扫描视频时找出每只小鼠被悬挂起来的时刻。不动时间本身由小鼠轮廓的逐帧运动计算，不是由检测器直接给出。

设置中有三种检测模式：**自动**（有模型时用 YOLO）、**YOLO 模型**和**经典方法**（每格找暗色区域）。用户导入的模型优先于内置模型，导出文件会记录实际使用的检测器。

## 模型包记录了什么 {#card}

<table class="rf-kv"> <tr><th>发布文件</th><td><code>MouseDetector.mlpackage</code>（5.14 MiB），位于 <code>TSTMulti/Models/</code></td></tr> <tr><th>描述</th><td>“Ultralytics YOLO11n model trained on …/datasets/tst_mouse/data.yaml”</td></tr> <tr><th>任务 / 类别</th><td>目标检测；<code>names = {0: 'mouse'}</code></td></tr> <tr><th>输入</th><td>320 × 320 RGB 图像，另有两个可选数值 <code>iouThreshold</code>（默认 0.7）和 <code>confidenceThreshold</code>（默认 0.25）</td></tr> <tr><th>输出</th><td>非极大值抑制后的 <code>confidence</code> 和 <code>coordinates</code>（归一化的框中心、宽、高）</td></tr> <tr><th>导出参数</th><td><code>{'batch': 1, 'quantize': 16, 'nms': True, 'dynamic': False}</code> → FP16 权重，带 NMS 阶段的 Core ML pipeline</td></tr> <tr><th>软件</th><td>Ultralytics 8.4.182、PyTorch 2.14.1（CUDA 13.0）、coremltools 9.0；导出于 2026 年 10 月 18 日</td></tr> <tr><th>许可字段</th><td>AGPL-3.0（导出时由 Ultralytics 写入）</td></tr> </table>
来源：用 coremltools 读取的模型包 Core ML 规格。有一处奇怪的地方：`confidence` 输出声明了 80 列，而类别名只有一个。App 按类别名读取结果，所以不受影响；但这提醒我们要实际检查模型包，而不是假定它的结构。

## App 如何运行它 {#integration}

与两个姿态模型不同，检测器不依赖 Vision 自带的缩放。RodentFlow 自己把每张处理后的画面（灰度、已旋正、已缩小）等比缩放并居中放在灰色（114）背景上，与 Ultralytics 训练时的做法完全一致，然后让 Vision 按原样使用这张图：

    // TSTMulti/Detection/YOLOMouseDetector.swift（有删节）
    let r = min(Double(inputW) / Double(frame.width), Double(inputH) / Double(frame.height))
    let padX = (Double(inputW) - Double(frame.width) * r) / 2
    let padY = (Double(inputH) - Double(frame.height) * r) / 2
    ctx.setFillColor(CGColor(gray: 114.0 / 255.0, alpha: 1))          // Ultralytics 的填充色
    ctx.fill(CGRect(x: 0, y: 0, width: inputW, height: inputH))
    ctx.draw(src, in: CGRect(x: padX, y: padY, width: dw, height: dh))
    request.imageCropAndScaleOption = .scaleFill                      // 已经是输入尺寸
    // NMS pipeline 以额外输入的形式接收阈值：
    vnModel.featureProvider = try? MLDictionaryFeatureProvider(dictionary: [
        "iouThreshold": MLFeatureValue(double: 0.45),
        "confidenceThreshold": MLFeatureValue(double: 0.1)])           // 设得较低，App 另有自己的最低值

框以 `VNRecognizedObjectObservation` 返回，再用 `(x − padX) / r` 映射回画面像素。同一个类也能解码不带 NMS 的原始导出并自行做 NMS，因此实验室导入哪种导出都可以。

## 为自己的装置训练检测器 {#own}

下面是能生成同类模型包的通用 Ultralytics 流程。可以用它在自己装置的图像上训练检测器。

    # data.yaml：一个类别
    #   path: /data/tst_mouse
    #   train: images/train
    #   val: images/val
    #   names: {0: mouse}
    from ultralytics import YOLO
    model = YOLO('yolo11n.pt')                                   # COCO 预训练的 YOLO11 nano 检测器
    model.train(data='data.yaml', imgsz=320, epochs=100)
    model.export(format='coreml', imgsz=320, quantize=16, nms=True)   # Ultralytics 8.4.x 的参数名

- 标注自己装置拍摄的真实画面，包括空格子、爬尾的小鼠和只露出一部分的情况。
- 按录像而不是按帧划分，并留出一部分录像做测试。
- 在留出的录像上报告精确率和召回率，再在 TST 设置中导入 `.mlpackage`。

## 不用神经网络的追踪方法 {#classic}

并非每个 RodentFlow 流程都使用训练好的模型。下面这些无需引用模型，但应在方法中说明：

- **RodentFlow 流程**（旷场、高架十字迷宫、明暗箱、Y 迷宫与 T 迷宫、新物体识别、水迷宫、Barnes 迷宫、恐惧条件、位置偏爱）使用从 RodentFlow 1.3 移植的经典单鼠追踪器：时间中值背景、绝对差、自适应阈值、连通域，再取按对比度加权的质心，以 10 Hz 采样。源码注明不使用姿态估计、光流或神经网络。
- **经典 TST 检测器**：在每个格子里找暗色区域；没有 YOLO 模型或在设置中选择它时使用。

## 需要引用什么 {#cite}

如果使用了 YOLO 检测器，请引用 Ultralytics YOLO11（软件）和注明版本的 RodentFlow，并写明导出文件中记录的检测模式。见[引用页](/zh/tutorials/citations#use-detector)。
