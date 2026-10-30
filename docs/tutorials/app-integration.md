# Turning a trained YOLO model into on-device Core ML

<p class="rf-eyebrow">TUTORIAL 4 · FROM .PT TO THE APP</p>

All three models reach RodentFlow the same way: an Ultralytics export to Core ML, a check of what was exported, a Vision request in Swift and a small decoder that maps the output tensor back to video pixels. This page walks through each step with the app's own code.

## The path from weights to measurements {#flow}

1.  **best.pt**PyTorch weights from training
2.  **Export**`format='coreml'`, input size, precision, NMS
3.  **Inspect**Metadata, input/output shapes, weight hash
4.  **Xcode**`.mlpackage` compiled to `.mlmodelc`
5.  **Vision + decoder**Letterbox in, keypoints out, mapped to frame pixels
6.  **Analysis**Pose track → assay measures → review → export

## Step 1 · Export {#export}

Ultralytics converts the PyTorch model with Apple's coremltools. Exporting works on Linux (both pose models were exported in Google Colab); running a Core ML model needs macOS or iOS.

| Model               | Export call                                                 | Result                                                        |
|---------------------|-------------------------------------------------------------|---------------------------------------------------------------|
| MousePose6          | `export(format='coreml', imgsz=960, quantize=8, nms=False)` | 8-bit weights, end-to-end head, output (1, 300, 24), 2.76 MiB |
| CylinderMousePoseV2 | `export(format='coreml', imgsz=640)`                        | FP32, raw head, output (1, 26, 8400), 37.67 MiB               |
| MouseDetector       | recorded args: `quantize=16, nms=True`, `imgsz=320`         | FP16 pipeline with NMS stage, 5.14 MiB                        |

    pip install "ultralytics[export-coreml]>=8.4.142"     # Core ML export needs numpy ≤ 2.3.5

    from ultralytics import YOLO
    YOLO('best_mousepose.pt').export(format='coreml', imgsz=960, quantize=8, nms=False)

- **Input size** must match the size the model was validated at; the decoder in the app hard-codes it (960 or 640).
- **Precision:** 8-bit weights shrink MousePose6 to under 3 MiB. Compression can shift keypoints slightly, which is why [step 7](#parity) exists.
- **NMS:** YOLO26 pose models have an end-to-end head that needs no NMS. The detector was exported as a pipeline that includes NMS, so Vision returns finished boxes.

## Step 2 · Inspect what you exported {#inspect}

Every Ultralytics export writes the training data path, library versions, input size, keypoint names and export arguments into the package. Reading them back is the quickest way to know which model an app really contains.

    import coremltools as ct
    m = ct.models.MLModel('MousePose6_960_int8.mlpackage', skip_model_load=True)   # works on Linux too
    print(m.short_description)        # 'Ultralytics YOLO26n-pose model trained on …/dataset_local.yaml'
    md = m.user_defined_metadata
    print(md['imgsz'], md['kpt_shape'], md['kpt_names'], md['names'], md['args'], md['end2end'])
    spec = m.get_spec()
    for o in spec.description.output:
        print(o.name, list(o.type.multiArrayType.shape))   # [1, 300, 24]

| Field                   | MousePose6_960_int8 | CylinderMousePoseV2 | MouseDetector               |
|-------------------------|---------------------|---------------------|-----------------------------|
| Model                   | YOLO26n-pose        | YOLO26s-pose        | YOLO11n                     |
| `imgsz`                 | 960 × 960           | 640 × 640           | 320 × 320                   |
| Head / `end2end`        | Pose26 / True       | Pose26 / False      | Detect / False              |
| Output                  | (1, 300, 24)        | (1, 26, 8400)       | `confidence`, `coordinates` |
| Ultralytics             | 8.4.176             | 8.4.177             | 8.4.182                     |
| Exported                | 2026-10-13          | 2026-10-14          | 2026-10-18                  |
| SHA-256 of `weight.bin` | `dc8c871e…d7e3`     | `1cb12c30…840c`     | `0151d83b…968b`             |

The full hashes are in [`MODEL_MANIFEST.md`](https://github.com/seesaw-earth/RodentStudio-Support/blob/main/source/MODEL_MANIFEST.md). The weights are stored with Git LFS, so after cloning the source run `git lfs pull`, then check:

    shasum -a 256 RodentFlow/Resources/Models/MousePose6_960_int8.mlpackage/Data/com.apple.CoreML/weights/weight.bin
    # dc8c871e36ebe623d4051cb3afbc043d25b3eaa1ebcc312c518d9809a084d7e3

## Step 3 · Add the package to Xcode {#xcode}

Add the `.mlpackage` to the app target. Xcode compiles it to `.mlmodelc` at build time and generates a Swift class, but RodentFlow loads the compiled model by name so that a missing model produces a clear message instead of a build error:

    // Core/NativeModelCatalog.swift
    enum PoseModelKind: String { case mousePose = "MousePose6_960_int8", cylinderV2 = "CylinderMousePoseV2" }

    static func load(_ kind: PoseModelKind) throws -> MLModel {
        guard let url = Bundle.main.url(forResource: kind.rawValue, withExtension: "mlmodelc") else {
            throw NSError(domain: "RodentDesktopNative", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Model \(kind.rawValue) is not installed."])
        }
        let config = MLModelConfiguration()
        config.computeUnits = .all          // the iOS app uses .cpuAndNeuralEngine, like the Ultralytics iOS package
        return try MLModel(contentsOf: url, configuration: config)
    }

## Step 4 · Run a frame through Vision {#vision}

Training images were letterboxed: scaled to fit the square input with the aspect ratio kept, then padded. Vision's `.scaleFit` option does the same for pose models, and the decoder undoes it.

    // Core/NativeVideoTrackingEngine.swift (condensed)
    let request = VNCoreMLRequest(model: try VNCoreMLModel(for: model))
    request.imageCropAndScaleOption = .scaleFit          // keep aspect ratio, pad to the square input
    try VNImageRequestHandler(cvPixelBuffer: frame, orientation: .up, options: [:]).perform([request])
    let tensor = (request.results ?? [])
        .compactMap { $0 as? VNCoreMLFeatureValueObservation }
        .compactMap { $0.featureValue.multiArrayValue }.first

The app wraps this in a small class that, after an isolated Vision error, rebuilds the request and retries the same frame once. It never switches to another model or compute unit.

## Step 5 · Decode the output tensor {#decode}

The two pose models return differently shaped tensors, so the decoder needs to know which one it has:

| Model                     | Shape         | One candidate                                                  | Keypoints start at |
|---------------------------|---------------|----------------------------------------------------------------|--------------------|
| MousePose6 (end-to-end)   | (1, 300, 24)  | `x1, y1, x2, y2, score, class`, then 6 × `(x, y, conf)`        | index 6            |
| CylinderMousePoseV2 (raw) | (1, 26, 8400) | `cx, cy, w, h, score`, then 7 × `(x, y, conf)`; channels first | index 5            |

Both analyses assume one mouse, so the decoder keeps the single highest-scoring candidate above 0.25 instead of running NMS. For MousePose6 it looks only at the first 30 candidates that pass the threshold, matching the behaviour of the Ultralytics iOS package used by the iPhone app. Coordinates are then mapped from the padded square back to the video frame:

    // NativePoseDecoder.decode (condensed)
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
        let x = (value(best!, start + 3*k)     - padX) / scale    // back to frame pixels
        let y = (value(best!, start + 3*k + 1) - padY) / scale
        let p =  value(best!, start + 3*k + 2)                    // keypoint confidence, clamped to 0…1
        // points that fall outside the frame are stored as missing
    }

The real accessor reads the tensor through its strides, accepts either axis order, and handles FP16, FP32 and FP64 outputs, so the same code works for both packages. If the tensor has neither 24 nor 26 features it stops with an error rather than guessing.

## Step 6 · From keypoints to measurements {#measure}

Each frame yields a list of points with confidences. RodentFlow stores them as a pose track with the video timestamps, then runs the analysis code ported from the iOS apps: RodentPose 1.0 analyzers for MousePose6 and RodentLimb 1.1.2 analyzers for CylinderMousePoseV2. Settings that change results are kept with each analysis. For the RodentLimb workflows, for example, the app writes a methods paragraph that names the model and states the keypoint confidence threshold below which points count as missing, the longest gap that is linearly interpolated, and the median and moving-average smoothing applied before measures are computed. In normal workflows the model is not a user choice; each assay uses the model it was designed for.

## Step 7 · Check parity before trusting the app {#parity}

Export, compression and a different resizing path can each move keypoints. Before relying on a new or changed package, run the same held-out images through the PyTorch weights and the Core ML package and compare. The MousePose6 export notebook prepared exactly this check:

    # on a Mac, inside the validation pack produced by MousePose_iOS_Export_v1
    python3 -m venv .venv && source .venv/bin/activate
    pip install "ultralytics[export-coreml]>=8.4.142"
    python validate_on_mac.py      # detection rate, PCK@0.1L and median error for .pt, FP16 and INT8 on 300 test images

- Confirm input size, keypoint names and order, and output shape against the metadata (step 2).
- Compare per-point error between `.pt` and Core ML on the same images; agree on a tolerance in advance (the notebook used about one PCK point).
- Open a few videos in RodentFlow's review view and check the overlaid points, especially left/right.
- Record the package hash with your results.

::: warning
**Not yet documented.** The results of `validate_on_mac.py` for the shipped MousePose6 package are not in the materials reviewed for these tutorials.
:::

## Licensing when you ship a model {#licence}

Ultralytics distributes YOLO under AGPL-3.0, with an Enterprise licence for closed-source use. Its licence page says the AGPL terms cover models produced by its training code, and that an Enterprise licence is needed to use YOLO without open-sourcing the whole project. RodentFlow's source is published under AGPL-3.0, and the iOS app also uses the AGPL-3.0 Ultralytics iOS package. Dataset terms are separate from software terms, and two of MousePose6's training datasets are CC BY-NC-SA 4.0 (non-commercial): see the [licence table](/tutorials/citations#licences). This is a summary, not legal advice.
