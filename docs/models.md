# Core ML models

The pose workflows run small neural networks with Apple's Core ML, on the Mac, iPhone or iPad itself. The models are bundled inside the app, so you never need to download them to analyse a video. They are documented here so that you can inspect them, reuse them in your own projects and cite them. Centroid tracking uses no model at all.

The [tutorials](./tutorials/) explain where each model's data and labels came from, how it was trained and tested, and how the app runs it.

## The models in RodentFlow {#models}

| Model | What it finds | Used when | Package |
|---|---|---|---|
| **[MousePose6_<wbr>960_<wbr>int8](./tutorials/mousepose6.md)** | One mouse per frame, top view; six keypoints: nose, left ear, right ear, neck, body centre, tail base | One-animal pose workflows, *Coat colour: Dark* (the default) | YOLO26n-pose · 960 px · 8-bit weights · 2.76 MiB |
| **[WhiteMousePose6_<wbr>960_<wbr>int8](./tutorials/white-mouse.md)** | One white mouse; the same six keypoints | One-animal pose workflows, *Coat colour: White* | YOLO26n-pose · 960 px · 8-bit weights · 2.76 MiB |
| **[MousePose6Dyad_<wbr>960_<wbr>int8](./blog/training-on-existing-tracks.md#dyad)** | Two mice per frame; the same six keypoints each | Dyadic social interaction and resident–intruder, *Coat colour: Two dark mice* (the default) | YOLO26s-pose · 960 px · 8-bit weights · 9.66 MiB |
| **[MousePose6DyadBW_<wbr>960_<wbr>int8](./tutorials/dyad-bw.md)** | Two mice, one dark and one white; the same six keypoints each | The same two-animal workflows, *Coat colour: One dark, one white* | YOLO26s-pose · 960 px · 8-bit weights · 9.66 MiB |
| **[MouseDetector](./tutorials/tst-detector.md)** | A box around each mouse | Multi-chamber tail suspension | YOLO11n detect · 320 px · FP16 · 5.14 MiB |

The four pose models share one input (960 × 960 image), one output layout (a 1 × 300 × 24 tensor from an end-to-end head) and the same six keypoints in the same order. The app tracks, cleans and analyses their output the same way; only the model file changes.

How a model package is loaded, fed and decoded inside the app is covered in [4 · Core ML in the app](./tutorials/app-integration.md).

## Which model a video uses {#coat}

The task decides how many animals are tracked; the *Coat colour* setting decides which model:

| Animals (set by the task) | Coat colour | Model |
|---|---|---|
| 1 | Dark (default) | MousePose6 |
| 1 | White | WhiteMousePose6 |
| 2 | Two dark mice (default) | MousePose6Dyad |
| 2 | One dark, one white | MousePose6DyadBW |

- On iPhone and iPad, choose the coat colour after choosing the paradigm, or change it in the detection settings on the Info page. On the Mac, it is in the detection settings of each video's calibration. Changing it means tracking again.
- **No silent fallback.** If the model a video needs is missing or fails to load, that video is not tracked, and the app says why.
- The Methods text, single-session JSON and the group long-format table (`model` column) name the model each video used. When groups were tracked with different models, the group page warns that differences between models are mixed with group differences.
- Data saved without a coat colour (earlier versions) are read as *Dark*, which is the model they were tracked with.

::: warning Body centre in two-mouse data
MousePose6, WhiteMousePose6 and MousePose6DyadBW place the body centre at the midpoint of neck and tail base. MousePose6Dyad learned a different definition, about 0.4 body lengths behind the nose. Measures based on the body centre are therefore not interchangeable between MousePose6Dyad and the other three models; see [tutorial 6](./tutorials/dyad-bw.md#keypoints).
:::

## Models no longer in RodentFlow {#former}

- **[CylinderMousePoseV2](./tutorials/cylinder-v2.md)** (paws, nose, mouth and tail base) ran the limb workflows of the earlier Mac app. RodentFlow 2.0 removed those workflows; the limb model and workflows are now in **RodentLimb**, whose site documents the [current limb models](https://seesaw-earth.github.io/RodentLimb/models/). The tutorial stays here as the record of how the model was made.
- **JABS_YOLO26s_MousePose12_640_FP16** (twelve keypoints, JABS keypoint set) is published in the models repository but has never been part of the app.

## Download {#download}

MousePose6, CylinderMousePoseV2 and the JABS model are in [**seesaw-earth/RodentStudio-CoreML-Models**](https://github.com/seesaw-earth/RodentStudio-CoreML-Models). The weights are stored with [Git LFS](https://git-lfs.com/), so install it before cloning:

```bash
git lfs install
git clone https://github.com/seesaw-earth/RodentStudio-CoreML-Models.git
```

Keep each `.mlpackage` folder intact when you copy it into an Xcode project. If a `weight.bin` file is only a few hundred bytes, it is an LFS pointer: run `git lfs pull`.

WhiteMousePose6, MousePose6Dyad and MousePose6DyadBW ship inside the app. The MouseDetector package ships with the Mac source code, in [`source/macOS/…/TSTMulti/Models`](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source).

## Checksums {#checksums}

SHA-256 of each `weight.bin`, to check that you have the same weights as the app:

| Model | SHA-256 of `weight.bin` |
|---|---|
| MousePose6_960_int8 | `dc8c871e36ebe623d4051cb3afbc043d25b3eaa1ebcc312c518d9809a084d7e3` |
| WhiteMousePose6_960_int8 | `b00dbda7e52a8d5b911a9839031d0ac9ac054fec90684e70d5f2ff94e2aa86ab` |
| MousePose6Dyad_960_int8 | `adc22fd3546cda6ab9a44ba99712d9ce1c30aa2ee405dc3d5363aad82093a228` |
| MousePose6DyadBW_960_int8 (version 2) | `89aff42ec2f7faee8733d9d91e83cb2be25ef9241ec0ef6284820f6db7875ec3` |
| MouseDetector | `0151d83baec0ad13b63e61ade80e822fabd01cb82eb6d728816893667c0c968b` |
| CylinderMousePoseV2 | `1cb12c30ea2ff907e57d6f756be95e1f25fc667a71fa8cf07d1b9448a202840c` |
| JABS_YOLO26s_MousePose12_640_FP16 | `3205b4236cba83cd17130de8496349b6fc7b8f2e9a5994c10103e69843df0047` |

## Licences and reuse {#licences}

- The model weights are published with the project author's authorization. That statement does not verify the licences of the upstream pretrained weights or the training data.
- The packages were trained and exported with Ultralytics YOLO, which is AGPL-3.0 unless an Ultralytics Enterprise licence is used; the licence field written into the packages on export reads AGPL-3.0.
- Two of MousePose6's four training datasets (the JAX datasets on Harvard Dataverse) are CC BY-NC-SA 4.0, which limits commercial use. The two ETH Zurich datasets are CC BY 4.0.
- WhiteMousePose6, MousePose6Dyad and MousePose6DyadBW were trained on videos and tracks from the DooM dataset (EMBER-DANDI dandiset 000564). Its terms of use are given on the [EMBER record](https://dandi.emberarchive.org/dandiset/000564); check them before any redistribution or commercial use.
- A model being available in a public repository does not by itself grant a right to commercial redistribution.

The [licence summary](./tutorials/citations.md#licences) lists every dataset, paper and software package with its licence, and [How to cite](./tutorials/citations.md) says what to cite when you use each model.

::: warning Validate on your own videos
Test scores in the tutorials describe agreement with the reference labels of each test set, mostly other trackers' outputs. They are not a validation of the behavioural measures. Before relying on a model for a study, compare its output with manual scoring on your own recordings.
:::
