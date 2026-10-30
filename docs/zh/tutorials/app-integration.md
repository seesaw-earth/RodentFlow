# 把训练好的 YOLO 模型变成设备端的 Core ML

<p class="rf-eyebrow">教程 4 · 从 .PT 到 APP</p>

三个模型进入 RodentFlow 的路径相同：用 Ultralytics 导出为 Core ML，检查导出的内容，在 Swift 中发起 Vision 请求，再用一个小解码器把输出张量映射回视频像素。本页用 App 自己的代码逐步讲解。

## 从权重到指标的路径 {#flow}

1.  **best.pt**训练得到的 PyTorch 权重
2.  **导出**`format='coreml'`、输入尺寸、精度、NMS
3.  **检查**元数据、输入输出形状、权重哈希
4.  **Xcode**`.mlpackage` 编译成 `.mlmodelc`
5.  **Vision + 解码器**加边缩放输入，输出关键点并映射回画面像素
6.  **分析**姿态轨迹 → 实验指标 → 复核 → 导出

## 第 1 步 · 导出 {#export}

Ultralytics 借助 Apple 的 coremltools 转换 PyTorch 模型。导出可以在 Linux 上完成（两个姿态模型都是在 Google Colab 中导出的）；运行 Core ML 模型则需要 macOS 或 iOS。

| 模型                | 导出调用                                                    | 结果                                                |
|---------------------|-------------------------------------------------------------|-----------------------------------------------------|
| MousePose6          | `export(format='coreml', imgsz=960, quantize=8, nms=False)` | 8 位权重，端到端输出头，输出 (1, 300, 24)，2.76 MiB |
| CylinderMousePoseV2 | `export(format='coreml', imgsz=640)`                        | FP32，原始输出头，输出 (1, 26, 8400)，37.67 MiB     |
| MouseDetector       | 记录的参数：`quantize=16, nms=True`，`imgsz=320`            | 带 NMS 阶段的 FP16 pipeline，5.14 MiB               |

    pip install "ultralytics[export-coreml]>=8.4.142"     # Core ML 导出需要 numpy ≤ 2.3.5

    from ultralytics import YOLO
    YOLO('best_mousepose.pt').export(format='coreml', imgsz=960, quantize=8, nms=False)

- **输入尺寸**必须与模型验证时的尺寸一致；App 的解码器写死了这个值（960 或 640）。
- **精度：**8 位权重让 MousePose6 小于 3 MiB。压缩可能让关键点略有偏移，所以才有[第 7 步](#parity)。
- **NMS：**YOLO26 姿态模型有端到端输出头，不需要 NMS。检测器导出为包含 NMS 的 pipeline，Vision 直接返回最终的框。

## 第 2 步 · 检查导出的内容 {#inspect}

每次 Ultralytics 导出都会把训练数据路径、库版本、输入尺寸、关键点名称和导出参数写进模型包。读回这些信息，是确认 App 里究竟装了哪个模型的最快方法。

    import coremltools as ct
    m = ct.models.MLModel('MousePose6_960_int8.mlpackage', skip_model_load=True)   # Linux 上也能运行
    print(m.short_description)        # 'Ultralytics YOLO26n-pose model trained on …/dataset_local.yaml'
    md = m.user_defined_metadata
    print(md['imgsz'], md['kpt_shape'], md['kpt_names'], md['names'], md['args'], md['end2end'])
    spec = m.get_spec()
    for o in spec.description.output:
        print(o.name, list(o.type.multiArrayType.shape))   # [1, 300, 24]

| 字段                    | MousePose6_960_int8 | CylinderMousePoseV2 | MouseDetector               |
|-------------------------|---------------------|---------------------|-----------------------------|
| 模型                    | YOLO26n-pose        | YOLO26s-pose        | YOLO11n                     |
| `imgsz`                 | 960 × 960           | 640 × 640           | 320 × 320                   |
| 输出头 / `end2end`      | Pose26 / True       | Pose26 / False      | Detect / False              |
| 输出                    | (1, 300, 24)        | (1, 26, 8400)       | `confidence`、`coordinates` |
| Ultralytics             | 8.4.176             | 8.4.177             | 8.4.182                     |
| 导出日期                | 2026-10-13          | 2026-10-14          | 2026-10-18                  |
| `weight.bin` 的 SHA-256 | `dc8c871e…d7e3`     | `1cb12c30…840c`     | `0151d83b…968b`             |

完整哈希见 [`MODEL_MANIFEST.md`](https://github.com/seesaw-earth/RodentStudio-Support/blob/main/source/MODEL_MANIFEST.md)。权重用 Git LFS 存储，克隆源码后先运行 `git lfs pull`，再检查：

    shasum -a 256 RodentFlow/Resources/Models/MousePose6_960_int8.mlpackage/Data/com.apple.CoreML/weights/weight.bin
    # dc8c871e36ebe623d4051cb3afbc043d25b3eaa1ebcc312c518d9809a084d7e3

## 第 3 步 · 把模型包加入 Xcode {#xcode}

把 `.mlpackage` 加入 App target。Xcode 在构建时把它编译为 `.mlmodelc` 并生成 Swift 类，但 RodentFlow 按名称加载编译后的模型，这样缺少模型时给出清楚的提示，而不是构建失败：

    // Core/NativeModelCatalog.swift
    enum PoseModelKind: String { case mousePose = "MousePose6_960_int8", cylinderV2 = "CylinderMousePoseV2" }

    static func load(_ kind: PoseModelKind) throws -> MLModel {
        guard let url = Bundle.main.url(forResource: kind.rawValue, withExtension: "mlmodelc") else {
            throw NSError(domain: "RodentDesktopNative", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Model \(kind.rawValue) is not installed."])
        }
        let config = MLModelConfiguration()
        config.computeUnits = .all          // iOS App 与 Ultralytics iOS 包一样使用 .cpuAndNeuralEngine
        return try MLModel(contentsOf: url, configuration: config)
    }

## 第 4 步 · 用 Vision 处理一帧 {#vision}

训练图像经过了“加边缩放”（letterbox）：保持宽高比缩放到方形输入内，再填充边缘。Vision 的 `.scaleFit` 选项对姿态模型做同样的处理，解码器再把它还原。

    // Core/NativeVideoTrackingEngine.swift（有删节）
    let request = VNCoreMLRequest(model: try VNCoreMLModel(for: model))
    request.imageCropAndScaleOption = .scaleFit          // 保持宽高比，填充到方形输入
    try VNImageRequestHandler(cvPixelBuffer: frame, orientation: .up, options: [:]).perform([request])
    let tensor = (request.results ?? [])
        .compactMap { $0 as? VNCoreMLFeatureValueObservation }
        .compactMap { $0.featureValue.multiArrayValue }.first

App 把这段代码包在一个小类里：遇到偶发的 Vision 错误时，重建请求并对同一帧重试一次。它从不换用别的模型或计算单元。

## 第 5 步 · 解码输出张量 {#decode}

两个姿态模型输出的张量形状不同，解码器必须知道面对的是哪一个：

| 模型                        | 形状          | 一个候选的内容                                             | 关键点起始位置 |
|-----------------------------|---------------|------------------------------------------------------------|----------------|
| MousePose6（端到端）        | (1, 300, 24)  | `x1, y1, x2, y2, score, class`，然后是 6 × `(x, y, conf)`  | 第 6 位        |
| CylinderMousePoseV2（原始） | (1, 26, 8400) | `cx, cy, w, h, score`，然后是 7 × `(x, y, conf)`；通道在前 | 第 5 位        |

两种分析都假定只有一只小鼠，所以解码器不做 NMS，而是保留得分最高且大于 0.25 的那个候选。对 MousePose6 只看前 30 个通过阈值的候选，与 iPhone App 所用 Ultralytics iOS 包的行为一致。然后把坐标从填充后的方形映射回视频画面：

    // NativePoseDecoder.decode（有删节）
    let size  = kind == .mousePose ? 960.0 : 640.0
    let scale = min(size / Double(imageWidth), size / Double(imageHeight))
    let padX  = (size - Double(imageWidth)  * scale) / 2
    let padY  = (size - Double(imageHeight) * scale) / 2
    var best: Int? = nil, bestScore = 0.25, passed = 0
    for i in 0..<candidates {
        let c = value(i, 4)
        guard c.isFinite, c > 0.25 else { continue }
        if c > bestScore { best = i; bestScore = c }
        if kind == .mousePose { passed += 1; if passed == 30 { break } }
    }
    let start = kind == .mousePose ? 6 : 5
    for k in 0..<(kind == .mousePose ? 6 : 7) {
        let x = (value(best!, start + 3*k)     - padX) / scale    // 回到画面像素
        let y = (value(best!, start + 3*k + 1) - padY) / scale
        let p =  value(best!, start + 3*k + 2)                    // 关键点置信度，截断到 0…1
        // 落在画面外的点记为缺失
    }

实际的读取器按张量的 stride 访问数据，两种轴顺序都能处理，也支持 FP16、FP32 和 FP64 输出，所以同一段代码适用于两个模型包。如果张量的特征数既不是 24 也不是 26，它会报错而不是去猜。

## 第 6 步 · 从关键点到指标 {#measure}

每一帧得到一组带置信度的点。RodentFlow 把它们连同视频时间戳存成姿态轨迹，再运行从 iOS App 移植的分析代码：MousePose6 对应 RodentPose 1.0 分析器，CylinderMousePoseV2 对应 RodentLimb 1.1.2 分析器。影响结果的设置会随每次分析一起保存。例如在 RodentLimb 流程中，App 会生成一段方法说明，写明所用模型、低于多少置信度的点视为缺失、最长多少的缺口做线性插值，以及计算指标前所做的中值滤波和滑动平均。在常规流程中模型不由用户选择，每个实验使用为它设计的模型。

## 第 7 步 · 先核对一致性，再信任 App {#parity}

导出、压缩和不同的缩放路径都可能让关键点移动。在依赖一个新的或改动过的模型包之前，用同一批留出图像分别跑 PyTorch 权重和 Core ML 模型包并比较。MousePose6 的导出 notebook 正是为此准备了检查工具：

    # 在 Mac 上，进入 MousePose_iOS_Export_v1 生成的验证包目录
    python3 -m venv .venv && source .venv/bin/activate
    pip install "ultralytics[export-coreml]>=8.4.142"
    python validate_on_mac.py      # 在 300 张测试图上给出 .pt、FP16、INT8 的检出率、PCK@0.1L 和中位误差

- 对照元数据（第 2 步）确认输入尺寸、关键点名称与顺序、输出形状。
- 在同一批图像上比较 `.pt` 与 Core ML 的逐点误差；事先定好容差（notebook 用的是约 1 个 PCK 百分点）。
- 在 RodentFlow 的复核视图中打开几段视频，检查叠加的点，尤其是左右。
- 把模型包哈希和结果一起记录。

::: warning
**尚无记录。**发布的 MousePose6 模型包的 `validate_on_mac.py` 结果不在本教程审阅的材料中。
:::

## 发布模型时的许可问题 {#licence}

Ultralytics 以 AGPL-3.0 发布 YOLO，闭源使用需另购企业许可。其许可页面说明，AGPL 条款覆盖用其训练代码产生的模型；不想开源整个项目时需要企业许可。RodentFlow 的源码以 AGPL-3.0 发布，iOS App 还使用了 AGPL-3.0 的 Ultralytics iOS 包。数据集条款与软件条款是两回事，而且 MousePose6 有两个训练数据集为 CC BY-NC-SA 4.0（非商业），见[许可汇总表](/zh/tutorials/citations#licences)。以上只是概述，不构成法律意见。
