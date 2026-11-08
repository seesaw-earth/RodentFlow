---
description: How WhiteMousePose6, RodentFlow's model for a single white mouse, was trained from DooM tracks and a larger teacher model, and how well it agrees with held-out tracks.
---

# A white-mouse pose model taught by tracks and a larger model

<p class="rf-eyebrow">TUTORIAL 5 · WHITEMOUSEPOSE6_960_INT8</p>

WhiteMousePose6 is the model RodentFlow uses when the *Coat colour* of a single mouse is set to **White**. It has the same size, input, output and six keypoints as [MousePose6](./mousepose6.md), so the app runs it exactly the same way. It learned from white mice in the DooM dataset: the laboratories' own pose tracks, plus extra frames labelled by a larger YOLO model.

<Badge type="info" text="YOLO26n-pose" /><Badge type="info" text="6 keypoints" /><Badge type="info" text="960 px" /><Badge type="tip" text="Core ML · 8-bit weights" />

## Model card {#card}

<table class="rf-kv">
<tr><th>Shipped file</th><td><code>WhiteMousePose6_960_int8.mlpackage</code> (2.76 MiB); in RodentFlow 2.0 and later, on Mac, iPhone and iPad</td></tr>
<tr><th>Task</th><td>One class, <code>white_mouse</code>; six keypoints in the app's order: <code>nose</code>, <code>left_ear</code>, <code>right_ear</code>, <code>neck</code>, <code>body_center</code>, <code>tail_base</code></td></tr>
<tr><th>Starting weights</th><td>Ultralytics <code>yolo26n-pose.pt</code> (pretrained on COCO keypoints); new pose head for six keypoints</td></tr>
<tr><th>Size</th><td>2,522,145 parameters; 16.0 GFLOPs per 960-px frame</td></tr>
<tr><th>Input / output</th><td>960 × 960 RGB image → tensor of shape (1, 300, 24) from the end-to-end (NMS-free) head, as MousePose6</td></tr>
<tr><th>Training data</th><td>7,586 training images: 5,899 frames of a four-point white-mouse dataset built from DooM (9 laboratories with white mice, 4 more contributing images of dark mice only), 690 zoomed crops, 179 background crops and 818 frames labelled by a larger model</td></tr>
<tr><th>Labels</th><td>The DooM laboratories' pose tracks (nose, ears, tail base), with neck and body centre derived by one rule; plus predictions of a YOLO26m teacher, filtered. <strong>Not human annotation.</strong></td></tr>
<tr><th>Software</th><td>Ultralytics 8.4.203, PyTorch 2.14.1 (CUDA 13.0), Python 3.13; one NVIDIA RTX PRO 6000 Blackwell GPU in Google Colab</td></tr>
<tr><th>Training run</th><td><code>n960_6kp_v1</code>, 150 epochs; checkpoint SHA-256 <code>5399e7fd…e0d0de</code></td></tr>
<tr><th>Export</th><td>Core ML ML Program, coremltools 9.0, <code>quantize=8</code>, <code>nms=False</code>; 6 November 2026</td></tr>
<tr><th>Licence field in the package</th><td>AGPL-3.0 (written by Ultralytics on export; see <a href="/RodentFlow/tutorials/citations.html#licences">licences</a>)</td></tr>
</table>

Sources: package metadata; notebook `WhiteMouse_n960_6kp_Train`; app source (`Shared/PoseEngine/PoseModels.swift`).

## The data: white mice in DooM {#data}

*Days of our Mice* (DooM) collects top-view videos of interacting mice from 15 laboratories, each with that laboratory's own pose tracks and frame-by-frame behaviour annotations ([Marks et al. 2026](./citations.md#r-doom); dataset on EMBER-DANDI, [dandiset 000564](./citations.md#r-doom-data)). The laboratories are identified by code names such as *SparklingTapir*.

The training notebook starts from a four-point white-mouse dataset (“dataset A”: nose, left ear, right ear, tail base) that an earlier notebook built from DooM, already split **by video** into train, validation and test. That earlier notebook, and the teacher model it trained, are not part of the material reviewed for this page; what follows is what the training notebook shows about them.

| Laboratory | Train images (white mice) | Validation | Test |
|---|---|---|---|
| DeliriousFly | 624 (624) | 78 | 78 |
| InvincibleJellyfish | 600 (600) | 73 | 75 |
| JovialSwallow | 610 (610) | 80 | 80 |
| LyricalHare | 609 (609) | 84 | 84 |
| PleasantMeerkat | 640 (1,280) | 64 | 64 |
| ReflectiveManatee | 624 (624) | 78 | 78 |
| SparklingTapir | 608 (608) | 72 | 68 |
| TranquilPanther | 699 (639) | 77 | 77 |
| UppityFerret | 606 (606) | 78 | 78 |
| CautiousGiraffe, ElegantMink, GroovyShrew, NiftyGoldfinch | 279 (none) | 33 | 33 |
| **Total** | **5,899 (6,200)** | **717** | **715** |

Nine laboratories contribute white mice; PleasantMeerkat images show two white mice. The last four laboratories filmed dark mice only: their images contain no white mouse and teach the model **not** to report a dark mouse or the arena as a white mouse. Labels are the laboratories' tracker outputs, filtered when dataset A was built; they are not human annotation.

## Step 1 · From four points to the app's six {#keypoints}

The app's models output six points; dataset A has four. The two missing points are derived from the others with one rule for every laboratory:

- **Neck** = E + a·(E − nose) + b·(tail base − E), where E is the midpoint of the ears. When the ears are not both confident, neck = nose + c·(tail base − nose).
- **Body centre** = midpoint of neck and tail base, the same definition as MousePose6. The body-centre points that some laboratories track are not used, because their definitions differ.

a and b were fitted on the six DooM laboratories that track a neck point (33,402 frames), after removing tracking errors: **a = 0.127, b = 0.057, c = 0.308**. A leave-one-laboratory-out check gives the error of the derived neck against each laboratory's tracked neck, in body lengths (L, nose to tail base):

| Laboratory left out | Frames | Rule with ears | Without ears | Ear midpoint as neck |
|---|---|---|---|---|
| InvincibleJellyfish | 7,085 | 0.024 | 0.123 | 0.081 |
| JovialSwallow | 6,477 | 0.121 | 0.123 | 0.147 |
| TranquilPanther | 6,472 | 0.029 | 0.097 | 0.059 |
| CautiousGiraffe | 6,588 | 0.035 | 0.094 | 0.066 |
| ElegantMink | 6,426 | 0.016 | 0.106 | 0.077 |
| AdaptableSnail | 354 | 0.132 | 0.225 | 0.094 |

The rule is close to most laboratories' neck (0.016–0.035 L) but not to JovialSwallow's or AdaptableSnail's, whose neck points sit elsewhere. The same rule (stored as `rodentflow.label_neck_rule`) is used for the [dark–white two-mouse model](./dyad-bw.md), so the two models place neck and body centre the same way.

## Step 2 · Zoomed crops, background crops and grayscale {#augment}

- **Zoomed crops.** For half of the training images with one white mouse, a square crop centred near the mouse was added, sized so that the mouse covers about 19 % of the crop side (body length ÷ 0.19, × 0.8–1.25, centre shifted up to ±20 %). In laboratories with small mice, such as PleasantMeerkat, this shows the model larger mice. Validation and test sets got one unjittered crop per image (`val_app`, `test_app`), used only for evaluation. The crops were designed for a zoom-and-follow mode of a development build; **RodentFlow 2.1 does not zoom**: it gives this model the calibrated arena region, like every other pose model.
- **Background crops.** Half of the dark-mouse-only images also got a random crop, so that zoomed views of dark mice and arenas are also seen as background.
- **Grayscale.** Half of the training images were converted to grayscale, because the app converts frames to grayscale before tracking by default.

Every random choice is seeded by the image name, so rebuilding the dataset gives the same images.

## Step 3 · A larger model labels more frames {#teacher}

A larger YOLO26m-pose model (about 21 M parameters, 640 px, the same four points as dataset A), trained in an earlier notebook, labelled new frames from the **training videos only**: 12 frames per video, at least 1 s away from frames already in dataset A, from 307 videos. Each frame was cropped to the range of the video's tracks, to remove side views and neighbouring cages.

The teacher worked in two passes: first on the whole frame at 1,280 px, then on a square crop around each mouse at 640 px, keeping the keypoints of the second pass. A frame was kept only if every rule below held:

| Rule | Why |
|---|---|
| The number of white mice found (confidence > 0.5) equals the number in the DooM metadata, with no other box above 0.3 | A missed white mouse would be learned as background; an extra box may be a dark mouse |
| All four keypoints have confidence ≥ 0.6 | |
| The skeleton looks like a mouse: ears on the head side, apart and near the body axis; left ear on the animal's left | The same check as dataset A |
| Body length 0.6–1.6 × the video's median | Removes boxes around half a mouse or two mice |

Of 3,684 frames tried, **818 (22 %) were kept**. Most rejections were count mismatches (2,746), then skeleton (52), keypoint confidence (40), crop refinement (21) and body length (7).

## Step 4 · The training set {#dataset}

| Split | Dataset A | Zoomed crops | Background crops | Teacher frames | Total images |
|---|---|---|---|---|---|
| Train | 5,899 | 690 | 179 | 818 | 7,586 |
| Validation | 717 | 175 | — | — | 892 |
| Test | 715 | 154 | — | — | 869 |

Validation and test videos never contributed teacher frames or crops to training. Across the training images, the median body length is 0.190 of the image's longer side, stored in the package as `rodentflow.body_fraction`.

## Step 5 · Training {#train}

<table class="rf-kv">
<tr><th>Network</th><td>YOLO26n-pose at 960 px, the same size and input as MousePose6</td></tr>
<tr><th>Schedule</th><td>150 epochs (early-stopping patience 30; all 150 ran), batch chosen by AutoBatch, optimizer <code>auto</code>, cosine learning rate, mosaic switched off for the last 15 epochs, seed 2026, deterministic</td></tr>
<tr><th>Augmentation</th><td>Horizontal and vertical flips (probability 0.5 each, exchanging left and right ears), scale 0.5, translation 0.1; no rotation (it loosens boxes), no mixup (it would overlay dark and white mice); brightness only (<code>hsv_v</code> 0.4)</td></tr>
<tr><th>Early stopping</th><td>On the validation videos and their crops</td></tr>
</table>

On the 892 validation images (917 mice) the best checkpoint reached box mAP50 0.994 and mAP50-95 0.790, and pose mAP50 0.933 and mAP50-95 0.610.

## Step 6 · Evaluation on held-out videos {#eval}

The test images come from videos that were never used for training, early stopping or any choice. They come from the **same laboratories** as the training videos; there was no unseen laboratory in this test. The labels are the laboratories' tracks, so the scores measure agreement with those trackers. The student (960 px) and its teacher (640 px) were run on the same images.

| Test set | Model | Mice | Detected | PCK@0.05 L | PCK@0.1 L | PCK@0.2 L | Neck error | Body-centre error |
|---|---|---|---|---|---|---|---|---|
| Test images | **WhiteMousePose6** | 740 | **99.3 %** | 0.818 | **0.958** | 0.985 | 0.022 L | 0.019 L |
| | Teacher (YOLO26m, 640) | 740 | 73.1 % | 0.621 | 0.867 | 0.962 | 0.037 L | 0.030 L |
| Zoomed test crops | **WhiteMousePose6** | 154 | **98.7 %** | 0.758 | **0.916** | 0.977 | 0.026 L | 0.029 L |
| | Teacher | 154 | 79.2 % | 0.574 | 0.857 | 0.949 | 0.038 L | 0.043 L |

*Detected*: share of labelled white mice matched by a detection with box IoU ≥ 0.5. *PCK@α*: share of the four tracked keypoints of detected mice within α body lengths. Neck and body-centre errors are medians against the same derived points.

PCK@0.1 L by laboratory, test images: DeliriousFly 0.925, InvincibleJellyfish 0.980, JovialSwallow 0.972, LyricalHare 0.943, PleasantMeerkat 0.978, ReflectiveManatee 0.981, SparklingTapir 0.915, TranquilPanther 0.982, UppityFerret 0.932.

Neither model reported a white mouse (confidence > 0.5) in any of the 33 test images that show only dark mice.

Each model ran at its own input size: the student at 960 px, the teacher at 640 px.

## Step 7 · Export {#export}

```python
# condensed from WhiteMouse_n960_6kp_Train, section 7 (export runs in a separate process with numpy 2.3.5)
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

The notebook checks that the package has one 960 × 960 image input and one (1, 300, 24) float32 output, and that every metadata key was written. It also writes 24 test inputs and the PyTorch predictions for them, with a script (`verify_on_mac.py`) that runs the Core ML package on a Mac and compares. **The result of that comparison has not been reported**, so agreement between the shipped 8-bit package and the PyTorch weights is not documented here; [tutorial 4](./app-integration.md#parity) explains the check.

## In the app {#app}

- Choose **Coat colour: White** for a single mouse (iPhone and iPad: after choosing the paradigm, or in the detection settings on the Info page; Mac: in the detection settings of the calibration). Changing the coat colour means tracking again.
- The model gets the same frames as MousePose6: the calibrated arena region, converted to grayscale by default, letterboxed to 960 × 960 by Vision. Decoding, cleaning and analysis are identical.
- If the model is missing or fails to load, the video is not tracked; the app does not fall back to another model.
- Methods text, single-session JSON and the group long-format table name the model. When groups were tracked with different models (for example C57BL/6 with MousePose6 and BALB/c with WhiteMousePose6), the group page warns that differences in missed detections between models are mixed with strain differences.
- Two white mice in one video are not supported yet.

## Limitations {#limits}

- **Labels come from trackers**, and the test measures agreement with them. No human-labelled test was run for this model.
- **No unseen laboratory was tested.** All test videos come from laboratories that also supplied training videos.
- **No check on users' own videos** was run in the reviewed notebook (its optional own-video comparison was empty).
- The teacher model and dataset A were built in earlier notebooks that were not reviewed for this page.
- Core ML parity with the PyTorch weights has not been reported.
- The neck is derived by rule. Its error against a laboratory's own neck point ranges from 0.016 to 0.132 L.
- The DooM dataset licence still has to be confirmed on its EMBER record; see [licences](./citations.md#licences).

## What to cite {#cite}

RodentFlow with its version, Ultralytics YOLO26, and the DooM dataset and paper; see [How to cite](./citations.md#use-white).
