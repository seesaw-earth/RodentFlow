# Core ML models

The pose workflows run small neural networks with Apple's Core ML, on the Mac, iPhone or iPad itself. The models are bundled inside the app, so you never need to download them to analyse a video. They are published so that you can inspect them, reuse them in your own projects and cite them. Centroid tracking uses no model at all.

The [tutorials](./tutorials/) explain where each model's data and labels came from, how it was trained and tested, and how the app runs it.

## The models

| Model | What it finds | Used by | Package |
|---|---|---|---|
| **[MousePose6_<wbr>960_<wbr>int8](./tutorials/mousepose6.md)** | One mouse per frame, top view; six keypoints: nose, left ear, right ear, neck, body centre, tail base | RodentPose workflows on Mac, iPhone and iPad | YOLO26n-pose · 960 px · 8-bit weights · 2.76 MiB |
| **[CylinderMousePoseV2](./tutorials/cylinder-v2.md)** | Seven keypoints: four paws, tail base, nose, mouth | RodentLimb workflows on Mac: cylinder test, tail suspension (one mouse), gait | YOLO26s-pose · 640 px · FP32 · 37.67 MiB |
| **[MouseDetector](./tutorials/tst-detector.md)** | A box around each mouse | Multi-chamber tail suspension on Mac | YOLO11n detect · 320 px · FP16 · 5.14 MiB |
| **JABS_<wbr>YOLO26s_<wbr>MousePose12_<wbr>640_<wbr>FP16** | Twelve keypoints (JABS keypoint set) | Published in the models repository; not part of the reviewed Mac release candidate 0.6.3 | YOLO26s-pose · 640 px · FP16 · 19.46 MiB |

How a model package is loaded, fed and decoded inside the app is covered in [4 · Core ML in the app](./tutorials/app-integration.md).

## Download

The packages are in [**seesaw-earth/RodentStudio-CoreML-Models**](https://github.com/seesaw-earth/RodentStudio-CoreML-Models). The weights are stored with [Git LFS](https://git-lfs.com/), so install it before cloning:

```bash
git lfs install
git clone https://github.com/seesaw-earth/RodentStudio-CoreML-Models.git
```

Keep each `.mlpackage` folder intact when you copy it into an Xcode project. If a `weight.bin` file is only a few hundred bytes, it is an LFS pointer: run `git lfs pull`.

The MouseDetector package ships with the Mac source code, in [`source/macOS/…/TSTMulti/Models`](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source). The app source also contains MousePose6 and CylinderMousePoseV2, so building the apps does not need the models repository.

## Checksums

SHA-256 of each `weight.bin`, to check that you have the same weights as the app:

| Model | SHA-256 of `weight.bin` |
|---|---|
| MousePose6_960_int8 | `dc8c871e36ebe623d4051cb3afbc043d25b3eaa1ebcc312c518d9809a084d7e3` |
| CylinderMousePoseV2 | `1cb12c30ea2ff907e57d6f756be95e1f25fc667a71fa8cf07d1b9448a202840c` |
| MouseDetector | `0151d83baec0ad13b63e61ade80e822fabd01cb82eb6d728816893667c0c968b` |
| JABS_YOLO26s_MousePose12_640_FP16 | `3205b4236cba83cd17130de8496349b6fc7b8f2e9a5994c10103e69843df0047` |

## Licences and reuse {#licences}

- The model weights are published with the project author's authorization. That statement does not verify the licences of the upstream pretrained weights or the training data.
- The packages were trained and exported with Ultralytics YOLO, which is AGPL-3.0 unless an Ultralytics Enterprise licence is used; the licence field written into the packages on export reads AGPL-3.0.
- Two of MousePose6's four training datasets (the JAX datasets on Harvard Dataverse) are CC BY-NC-SA 4.0, which limits commercial use. The two ETH Zurich datasets are CC BY 4.0.
- A model being available in a public repository does not by itself grant a right to commercial redistribution.

The [licence summary](./tutorials/citations.md#licences) lists every dataset, paper and software package with its licence, and [How to cite](./tutorials/citations.md) says what to cite when you use each model.

::: warning Validate on your own videos
Test scores in the tutorials describe agreement with the reference labels of each test set. They are not a validation of the behavioural measures. Before relying on a model for a study, compare its output with manual scoring on your own recordings.
:::
