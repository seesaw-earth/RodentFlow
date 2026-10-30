# Building a top-view mouse pose model from four public datasets

<p class="rf-eyebrow">TUTORIAL 1 · MOUSEPOSE6_960_INT8</p>

MousePose6 powers RodentFlow's RodentPose workflows. It was trained only on openly published videos, using the pose tracks that the dataset authors released alongside them as labels.

<Badge type="info" text="YOLO26n-pose" /><Badge type="info" text="6 keypoints" /><Badge type="info" text="960 px" /><Badge type="tip" text="Core ML · 8-bit weights" />

## Model card {#card}

<table class="rf-kv"> <tr><th>Shipped file</th><td><code>MousePose6_960_int8.mlpackage</code> (2.76 MiB)</td></tr> <tr><th>Task</th><td>One class, <code>mouse</code>; six keypoints in this order: <code>nose</code>, <code>left_ear</code>, <code>right_ear</code>, <code>neck</code>, <code>body_center</code>, <code>tail_base</code></td></tr> <tr><th>Starting weights</th><td>Ultralytics <code>yolo26n-pose.pt</code> (YOLO26 nano pose, pretrained by Ultralytics on COCO keypoints)</td></tr> <tr><th>Size</th><td>2,522,145 parameters</td></tr> <tr><th>Input / output</th><td>960 × 960 RGB image → tensor of shape (1, 300, 24) from the end-to-end (NMS-free) head</td></tr> <tr><th>Training data</th><td>8,840 images from 52 videos in four public datasets (6,140 train / 1,350 val / 1,350 test)</td></tr> <tr><th>Labels</th><td>Pose predictions released with the datasets (DeepLabCut for ETH; JAX's pose network for JABS), quality-filtered. <strong>Not human annotation.</strong></td></tr> <tr><th>Software</th><td>Ultralytics 8.4.176, PyTorch 2.11.0 (CUDA 13.0), Python 3.13; one NVIDIA RTX PRO 6000 Blackwell GPU in Google Colab</td></tr> <tr><th>Export</th><td>Core ML ML Program, coremltools 9.0, <code>quantize=8</code>, <code>nms=False</code>; package dated 13 October 2026</td></tr> <tr><th>Licence field in the package</th><td>AGPL-3.0 (written by Ultralytics on export; see <a href="/RodentFlow/tutorials/citations.html#licences">licences</a>)</td></tr> </table>
Sources: package metadata; notebooks `1012_MousePose_Dataset_Builder_v1`, `MousePose_YOLO_Train_v1`, `MousePose_iOS_Export_v1`.

## The four data sources {#sources}

All four datasets publish top-view videos of single mice together with pose files. The builder notebook downloaded a subset of videos from each, read the pose files and turned them into YOLO labels.

| Source                                                                                                                          | Record                                                                     | Pose files released with it                      | Licence         | Videos | Train / val / test images |
|---------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------|--------------------------------------------------|-----------------|--------|---------------------------|
| ETH Zurich BehaviorFlow — open field [\[D1\]](/tutorials/citations#r-vz2023)                                             | Zenodo [10.5281/zenodo.8186065](https://doi.org/10.5281/zenodo.8186065)    | DeepLabCut, 13 points                            | CC BY 4.0       | 20     | 1,680 / 360 / 360         |
| ETH Zurich BehaviorFlow — marble burying, light–dark box, fear-conditioning box [\[D2\]](/tutorials/citations#r-vz2024d) | Zenodo [10.5281/zenodo.11235068](https://doi.org/10.5281/zenodo.11235068)  | DeepLabCut, 13 points                            | CC BY 4.0       | 12     | 960 / 240 / 240           |
| JAX Kumar Lab strain survey, open field [\[D3\]](/tutorials/citations#r-jabs-ss)                                         | Harvard Dataverse [10.7910/DVN/SAPNJG](https://doi.org/10.7910/DVN/SAPNJG) | JAX pose network, 12 points (`*_pose_est_v6.h5`) | CC BY-NC-SA 4.0 | 12     | 2,000 / 500 / 500         |
| JAX Kumar Lab BxD survey, open field [\[D4\]](/tutorials/citations#r-jabs-bxd)                                           | Harvard Dataverse [10.7910/DVN/RQYI04](https://doi.org/10.7910/DVN/RQYI04) | JAX pose network, 12 points (`*_pose_est_v6.h5`) | CC BY-NC-SA 4.0 | 8      | 1,500 / 250 / 250         |
| Total                                                                                                                           |                                                                            |                                                  |                 | 52     | 6,140 / 1,350 / 1,350     |

Each image contains one mouse. The JABS videos were sampled at 250 frames per video and the ETH videos at 120.

The ETH recordings and their DeepLabCut tracks are described in von Ziegler et al. 2024 (*Nature Methods*), the analysis framework that the datasets were released for. The JAX videos come from the JAX Animal Behavior System (JABS); their keypoints were produced by JAX's HRNet-based pose network (Sheppard et al. 2022) and are described with the datasets in Choudhary et al. 2026 (*eLife*). Full references are on the [citation page](/tutorials/citations).

::: info
**A fifth source was planned but not used.** The builder also listed the elevated-plus-maze videos of Sturman et al. 2020 (Zenodo 3608657). Every download attempt returned HTTP 404 during the build, so those videos are *not* in the training set. Some of them were later used for an external pilot check ([below](#external)).
:::
::: warning
**The two JAX datasets are CC BY-NC-SA 4.0: non-commercial, share-alike.** Both Harvard Dataverse records (strain survey version 1.2, BxD version 1.0, viewed 20 October 2026) carry this licence: credit the authors, no commercial use, and adaptations must be shared under the same licence. 3,500 of MousePose6's 6,140 training images, with their keypoints, come from these two datasets. Whether trained weights legally count as an adaptation is not settled, but the cautious reading is that MousePose6 should not be used or distributed commercially, and that frames or labels derived from these datasets may only be redistributed under CC BY-NC-SA 4.0. That also sits uneasily with the AGPL-3.0 licence written into the model package, which permits commercial use. Before any commercial distribution of RodentFlow with this model, ask JAX (Kumar Lab) for permission, or retrain on the CC BY 4.0 ETH data alone (2,640 training images). This is not legal advice.
:::

## Step 1 · A shared keypoint set {#keypoints}

The two labs use different keypoint schemes: JAX's network predicts 12 points, the ETH DeepLabCut models 13. Training on the union would leave half of the points unlabelled in half of the images, so the builder kept only points that every source provides (schema `core6`) and dropped tail mid and tip points everywhere.

| core6 point   | JAX JABS (12 points)                                              | ETH DeepLabCut (13 points)                                                        |
|---------------|-------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| `nose`        | `nose`                                                            | `nose`                                                                            |
| `left_ear`    | `left_ear`                                                        | `earl`                                                                            |
| `right_ear`   | `right_ear`                                                       | `earr`                                                                            |
| `neck`        | `base_neck`                                                       | `neck`                                                                            |
| `body_center` | Derived the same way for both: midpoint of `neck` and `tail_base` |                                                                                   |
| `tail_base`   | `base_tail`                                                       | `tailbase`                                                                        |
| *dropped*     | four paws, `center_spine`, `mid_tail`, `tip_tail`                 | `headcentre`, `bodycentre`, `bcl`, `bcr`, `hipl`, `hipr`, `tailcentre`, `tailtip` |

Why derive `body_center`? The sources place their body-centre points differently, so copying them would teach the model a compromise position. A geometric definition is identical everywhere. Its confidence is the lower of the two parent points.

    # condensed from 1012_MousePose_Dataset_Builder_v1, sections 2 and 5
    # JABS pose_est_v6.h5 stores points as (y, x); flip them to (x, y)
    xy = pts[..., ::-1].astype(np.float32)

    # body_center: identical definition for every source
    X[..., BODY_CENTER, :] = (X[..., NECK, :] + X[..., TAIL_BASE, :]) / 2
    C[..., BODY_CENTER]    = np.minimum(C[..., NECK], C[..., TAIL_BASE])

## Step 2 · One meaning of “left” {#leftright}

Labs differ in whether “left” means the animal's left or the left of the image, and a mirrored convention silently breaks horizontal-flip augmentation. The builder therefore re-labelled the ears in every frame by top-view geometry: with the head axis running from neck to nose, the ear on the animal's left side (non-mirrored camera) is `left_ear`.

    def cross2(a, b):
        return a[..., 0] * b[..., 1] - a[..., 1] * b[..., 0]

    head = X[..., NOSE, :] - X[..., NECK, :]            # head axis, neck → nose
    body = X[..., NECK, :] - X[..., TAIL_BASE, :]
    cr = cross2(head, X[..., L_EAR, :] - X[..., R_EAR, :])
    checkable = (C[..., L_EAR] >= thr) & (C[..., R_EAR] >= thr) & (np.abs(cr) > 0.02 * np.sum(body**2, -1))
    wrong = checkable & (cr > 0)                        # convention: cross product < 0 for a correct pair
    xa, xb = X[..., L_EAR, :].copy(), X[..., R_EAR, :].copy()
    X[..., L_EAR, :] = np.where(wrong[..., None], xb, xa)   # swap (confidences are swapped the same way)
    X[..., R_EAR, :] = np.where(wrong[..., None], xa, xb)

The notebook reports how often each source already matched the convention. In the first JABS strain-survey video, for example, 98.8 % of 98,672 checkable frames matched and 1,218 frames were swapped. The resulting `flip_idx` is `[0, 2, 1, 3, 4, 5]`: a horizontal flip exchanges the two ears and leaves the other points in place.

## Step 3 · Quality filter and boxes {#filter}

Because the labels are predictions, the builder removed frames where the prediction looked unreliable. A mouse instance was accepted only if all of the following held:

- nose, neck, body_center and tail_base were above the confidence threshold (0.3 for JABS, 0.6 for ETH) and inside the image;
- body length (nose to tail_base) was between 0.35 and 1.6 times the video's median, which keeps rearing postures;
- neither the nose nor the body centre jumped more than half a median body length from the previous or next frame.

If any mouse in a frame failed, the whole frame was skipped, so no image contains an unlabelled animal. Points below the threshold were written as not visible.

Every source got the same box definition: a rectangle along the nose–tail_base axis, extended 10 % of body length in front of the nose and 5 % behind the tail base, 22 % of body length to each side, then made axis-aligned together with the visible keypoints.

    L = np.linalg.norm(nose - tail_base); u = (nose - tail_base) / L; n = np.array([-u[1], u[0]])
    front, back = nose + 0.10 * L * u, tail_base - 0.05 * L * u
    corners = np.array([front + 0.22*L*n, front - 0.22*L*n, back + 0.22*L*n, back - 0.22*L*n])
    pts = np.vstack([corners, visible_keypoints])
    x0, y0 = np.clip(pts.min(0), 0, [W, H]); x1, y1 = np.clip(pts.max(0), 0, [W, H])

## Step 4 · Sampling diverse frames {#sampling}

Consecutive video frames are nearly identical, and resting mice dominate long recordings. The builder considered every third frame (skipping the first and last 30), described each accepted frame by its body-centred, rotation-aligned pose plus its position in the arena, clustered these descriptions with mini-batch k-means, and took one frame per cluster, at least 15 frames apart. This gave 250 frames per JABS video and 120 per ETH video.

## Step 5 · Splitting by video {#split}

Within each source, whole videos were assigned to train, validation and test in a 70 / 15 / 15 ratio (random seed 2026). Frames from one video never appear in two splits, so test scores are not inflated by near-duplicate frames. The resulting `dataset.yaml`:

    names: {0: mouse}
    kpt_shape: [6, 3]
    flip_idx: [0, 2, 1, 3, 4, 5]
    kpt_names: {0: [nose, left_ear, right_ear, neck, body_center, tail_base]}
    kpt_oks_sigmas: [0.035, 0.035, 0.035, 0.05, 0.07, 0.05]

The OKS sigmas set how strictly each point is scored by the pose mAP metric (smaller is stricter); the sharply defined head points get the smallest values.

## Step 6 · Training {#train}

    from ultralytics import YOLO
    model = YOLO('yolo26n-pose.pt')                  # COCO-pretrained YOLO26 nano pose model
    model.train(data='dataset.yaml', imgsz=960, epochs=120, patience=30, batch=-1, seed=2026,
                fliplr=0.5, flipud=0.5, degrees=0.0, mosaic=1.0, close_mosaic=10,
                hsv_h=0.0, hsv_s=0.3, hsv_v=0.4, scale=0.5, translate=0.1)

The augmentation choices follow from the data, as the notebook explains:

- horizontal and vertical flips, because a top view has no preferred orientation (flips swap the ears through `flip_idx`);
- no rotation, because rotating enlarges the axis-aligned boxes and adds box noise;
- no hue change and only mild saturation and brightness changes, because the data mix infrared greyscale and colour videos;
- `scale=0.5`, because arena sizes and therefore mouse sizes differ a lot between labs;
- mosaic switched off for the last 10 epochs.

All 120 epochs completed. The weights with the best validation fitness (`best.pt`) were copied to `best_mousepose.pt`, which is the file exported for the app. A second run with `mosaic=0.2` was trained as an ablation; it is not the shipped model.

## Step 7 · Evaluation {#eval}

Two kinds of metrics were computed on the held-out splits. Keep in mind that the reference points are filtered model predictions, not human labels.

### Ultralytics metrics

| Split                     | Box mAP50 | Box mAP50-95 | Pose mAP50 | Pose mAP50-95 |
|---------------------------|-----------|--------------|------------|---------------|
| Validation (1,350 images) | 0.942     | 0.798        | 0.859      | 0.665         |
| Test (1,350 images)       | 0.965     | 0.827        | 0.901      | 0.697         |

### Per-source error on the test split

For each reference mouse, the predicted box with the highest overlap was matched if IoU ≥ 0.5 (prediction confidence threshold 0.25). For matched mice the notebook measured each point's distance to the reference in pixels and as a fraction of the reference body length *L* (nose to tail_base). PCK@*t*L is the share of visible points within *t* × *L*. Missed mice are counted in the detection rate but not in the error and PCK columns.

| Source            | Mice  | Detected | Median error | PCK@0.05L | PCK@0.1L | PCK@0.2L | Ears swapped |
|-------------------|-------|----------|--------------|-----------|----------|----------|--------------|
| ETH MB / LDB / FC | 240   | 1.000    | 1.55 px      | 0.847     | 0.973    | 0.995    | 0.000        |
| ETH open field    | 360   | 1.000    | 1.19 px      | 0.925     | 0.994    | 0.999    | 0.000        |
| JAX BxD           | 250   | 1.000    | 0.86 px      | 0.911     | 0.979    | 0.991    | 0.016        |
| JAX strain survey | 500   | 0.854    | 1.20 px      | 0.772     | 0.915    | 0.983    | 0.016        |
| All               | 1,350 | 0.946    | 1.17 px      | 0.857     | 0.961    | 0.991    | 0.009        |

Source: `MousePose_YOLO_Train_v1`, section 5. False detections with confidence above 0.5 were 0.001 per image overall.

The JAX strain-survey videos stand out: 14.6 % of their reference mice had no matching box. A miss here means no predicted box reached IoU 0.5 with the reference box; the notebook does not break down why those misses happened, so treat strain-survey-like videos with extra care.

Speed on the training GPU (PyTorch, batch 1) was 3.2 ms of inference and about 210 frames per second end to end. That figure says nothing about speed on a Mac.

## Step 8 · Input size and export {#export}

The export notebook first compared 640 and 960 px input with the PyTorch weights on the test split. Its rule was to choose 640 px if it lost no more than one percentage point of detection rate and PCK@0.1L.

| Input size | Detected | PCK@0.1L | Median error |
|------------|----------|----------|--------------|
| 640 px     | 0.931    | 0.950    | 1.24 px      |
| 960 px     | 0.946    | 0.961    | 1.17 px      |

640 px lost 1.5 points of detection and 1.1 points of PCK, so 960 px was kept. The export itself is one call:

    pip install "ultralytics[export-coreml]>=8.4.142"     # needs numpy ≤ 2.3.5; the run used numpy 2.1.3

    from ultralytics import YOLO
    YOLO('best_mousepose.pt').export(format='coreml', imgsz=960, quantize=8, nms=False)   # INT8
    YOLO('best_mousepose.pt').export(format='coreml', imgsz=960, quantize=16, nms=False)  # FP16 alternative

The saved run of the export notebook used a forced size of 640 px; the package that ships is 960 px and dated 13 October 2026, so it was produced by the same call at 960 px. The notebook also built a Mac validation pack (300 test images, `validate_on_mac.py`) to compare the `.pt`, FP16 and INT8 versions on macOS, with the rule “use INT8 if it loses less than about one PCK point”. **The results of that comparison are not in the materials we reviewed**, so the agreement between the shipped INT8 package and the PyTorch weights is not documented here. [Tutorial 4](/tutorials/app-integration#parity) shows how to run that check.

## Checks outside the training data {#external}

### CalMS21: two interacting mice in a home cage

The PyTorch weights were run without fine-tuning on 2,867 frames (every 15th frame) from 8 videos of the CalMS21 *training* set, and compared with the MARS keypoints distributed with CalMS21, mapped to the same six points. CalMS21 differs from the training data in almost every way: two mice, frequent close contact, a white intruder, bedding in the background.

| Mouse            | Detected | Median error (detected) | PCK@0.2L (detected) |
|------------------|----------|-------------------------|---------------------|
| Resident (black) | 0.118    | 30.7 px                 | 0.575               |
| Intruder (white) | 0.003    | 67.8 px                 | 0.146               |

Conclusion from the notebook: the model is not usable for this kind of video without new training data. MARS keypoints are themselves model output, so these numbers show disagreement, not which side is wrong.

### Elevated plus maze: a five-video pilot

A pilot ran the PyTorch weights on 5 human-scored elevated-plus-maze videos from Sturman et al. 2020, computed maze measures with RodentPose's analysis code, and compared them with the same measures from the DeepLabCut-based reference.

| Measure                           | ICC(A,1) | Pearson r |
|-----------------------------------|----------|-----------|
| Time in closed arms               | 0.90     | 0.96      |
| Time in centre                    | 0.89     | 0.97      |
| Head-dip time                     | 0.91     | 0.98      |
| Head dips (count)                 | 0.81     | 0.96      |
| Open-arm time (%)                 | 0.74     | 0.83      |
| Open-arm entries                  | 0.19     | 0.41      |
| Distance travelled                | 0.08     | 0.53      |
| Stretched-attend postures (count) | −0.02    | −0.11     |

n = 5 videos. With five videos the uncertainty of each coefficient is very large; the notebook itself calls this a pilot for checking the data mapping and scripts, not a result.

## Limitations {#limits}

- More than half of the training images come from CC BY-NC-SA 4.0 datasets, which restricts commercial use (see [data sources](#sources)).
- Labels and test references are model predictions. Systematic errors shared by DeepLabCut, JAX's network and MousePose6 would not show up in these scores.
- One mouse per image, top view, open-field-like arenas from two labs. Other arenas, cameras, coat colours, bedding or multiple animals are outside the training data, and the CalMS21 check shows how badly that can go.
- Detection was weaker on the JAX strain-survey videos (0.854).
- The agreement of the shipped INT8 Core ML package with the PyTorch weights is not documented.
- Good keypoint accuracy does not by itself make a behavioural measure valid; validate the measures you report against human scoring.

## What to cite {#cite}

If you publish results computed with MousePose6, cite RodentFlow (with its version), Ultralytics YOLO26, the four datasets, the papers that describe them, and DeepLabCut, whose predictions form the ETH labels. The [citation page](/tutorials/citations#use-mousepose6) lists the exact references and gives an example methods paragraph.
