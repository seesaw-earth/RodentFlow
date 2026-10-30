# The tail-suspension mouse detector, and the trackers that use no neural network

<p class="rf-eyebrow">TUTORIAL 3 · MOUSEDETECTOR</p>

The third bundled model is a small object detector for multi-chamber tail-suspension videos. Its training is the least documented of the three, so this page separates what the package itself records from what is missing.

<Badge type="info" text="YOLO11n detect" /><Badge type="info" text="1 class" /><Badge type="info" text="320 px" /><Badge type="tip" text="Core ML · FP16 · NMS" /><Badge type="warning" text="Provenance incomplete" />

## What the detector does in the app {#role}

In the *Tail Suspension Test — Multi-Chamber* workflow, one recording shows several mice hanging in neighbouring chambers. The detector finds a box around each mouse in sampled frames. RodentFlow uses those boxes to locate the chambers (from boxes with confidence ≥ 0.35), to pre-select the chambers in which a mouse was seen in at least two sampled frames and, while scanning the video, to find the moment each mouse is suspended. Immobility itself is scored from frame-to-frame motion of the mouse's outline, not by the detector.

The settings offer three detector modes: **Automatic** (YOLO when a model is available), **YOLO model**, and **Classical** (a dark blob per chamber). A model the user imports takes precedence over the bundled one, and the exports record which detector was actually used.

## What the package records {#card}

<table class="rf-kv"> <tr><th>Shipped file</th><td><code>MouseDetector.mlpackage</code> (5.14 MiB), in <code>TSTMulti/Models/</code></td></tr> <tr><th>Description</th><td>“Ultralytics YOLO11n model trained on …/datasets/tst_mouse/data.yaml”</td></tr> <tr><th>Task / classes</th><td>Object detection; <code>names = {0: 'mouse'}</code></td></tr> <tr><th>Input</th><td>320 × 320 RGB image, plus two optional numbers, <code>iouThreshold</code> (default 0.7) and <code>confidenceThreshold</code> (default 0.25)</td></tr> <tr><th>Outputs</th><td><code>confidence</code> and <code>coordinates</code> (normalized box centre, width, height) after non-maximum suppression</td></tr> <tr><th>Export settings</th><td><code>{'batch': 1, 'quantize': 16, 'nms': True, 'dynamic': False}</code> → FP16 weights, Core ML pipeline with an NMS stage</td></tr> <tr><th>Software</th><td>Ultralytics 8.4.182, PyTorch 2.14.1 (CUDA 13.0), coremltools 9.0; exported 18 October 2026</td></tr> <tr><th>Licence field</th><td>AGPL-3.0 (written by Ultralytics on export)</td></tr> </table>
Source: the package's Core ML specification, read with coremltools. Note one oddity: the `confidence` output declares 80 columns although only one class is named. The app reads results by label name, so this does not affect it, but it is a reminder to inspect a package rather than assume its layout.

## What is not documented {#missing}

::: warning
**Treat this model as unvalidated.** The app's settings say the bundled starter model “was trained on synthetic images from one rig”. The dataset (`tst_mouse`), the image generator, the training settings and any evaluation are not in the notebooks or source we reviewed. The settings text also mentions fine-tuning scripts in a `yolo/` folder; that folder is not in the public source tree.
:::

Until these are published, do not report the detector's accuracy, and check on your own videos that the chambers and suspension onsets it finds are correct. RodentFlow's TST notes also state that the immobility thresholds and segmentation have not been validated against blinded human scoring.

## How the app runs it {#integration}

Unlike the two pose models, the detector does not rely on Vision's own resizing. RodentFlow letterboxes each processed (grey, oriented, downscaled) frame itself, centred on a grey (114) background exactly as Ultralytics does during training, and then asks Vision to use the image as is:

    // TSTMulti/Detection/YOLOMouseDetector.swift (condensed)
    let r = min(Double(inputW) / Double(frame.width), Double(inputH) / Double(frame.height))
    let padX = (Double(inputW) - Double(frame.width) * r) / 2
    let padY = (Double(inputH) - Double(frame.height) * r) / 2
    ctx.setFillColor(CGColor(gray: 114.0 / 255.0, alpha: 1))          // Ultralytics' padding colour
    ctx.fill(CGRect(x: 0, y: 0, width: inputW, height: inputH))
    ctx.draw(src, in: CGRect(x: padX, y: padY, width: dw, height: dh))
    request.imageCropAndScaleOption = .scaleFill                      // already the exact input size
    // NMS pipelines take their thresholds as extra inputs:
    vnModel.featureProvider = try? MLDictionaryFeatureProvider(dictionary: [
        "iouThreshold": MLFeatureValue(double: 0.45),
        "confidenceThreshold": MLFeatureValue(double: 0.1)])           // low; the app applies its own minimum

Boxes come back as `VNRecognizedObjectObservation`s and are mapped to frame pixels with `(x − padX) / r`. The same class also decodes raw (non-NMS) exports and runs its own NMS, so a lab can import either kind of export.

## Training a detector for your rig {#own}

The recipe below is the generic Ultralytics workflow that produces a package of the same kind. It is *not* the documented recipe of the bundled model, which is unknown.

    # data.yaml: one class
    #   path: /data/tst_mouse
    #   train: images/train
    #   val: images/val
    #   names: {0: mouse}
    from ultralytics import YOLO
    model = YOLO('yolo11n.pt')                                   # COCO-pretrained YOLO11 nano detector
    model.train(data='data.yaml', imgsz=320, epochs=100)
    model.export(format='coreml', imgsz=320, quantize=16, nms=True)   # Ultralytics 8.4.x argument names

- Label real frames from your rig, including empty chambers, climbing mice and partial views.
- Split by recording, not by frame, and keep some recordings for testing.
- Report precision and recall on those held-out recordings, then import the `.mlpackage` in the TST settings.

## Trackers without a neural network {#classic}

Not every RodentFlow workflow uses a trained model. These need no model citation, but should be described in methods:

- **RodentFlow workflows** (open field, EPM, light–dark box, Y- and T-maze, NOR, water maze, Barnes maze, fear conditioning, place preference) use a classical single-mouse tracker ported from RodentFlow 1.3. Its pipeline is a temporal-median background, absolute difference, adaptive threshold, connected components and a contrast-weighted centroid, sampled at 10 Hz. The source states that no pose estimation, optical flow or neural network is used.
- **Classical TST detector**: finds the dark blob in each chamber, used when no YOLO model is available or when chosen in settings.

## What to cite {#cite}

If the YOLO detector was used, cite Ultralytics YOLO11 (software) and RodentFlow with its version, and state the detector mode recorded in the export. See the [citation page](/tutorials/citations#use-detector).
