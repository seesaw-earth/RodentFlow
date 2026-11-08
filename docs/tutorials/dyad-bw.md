---
description: How MousePose6-DyadBW, RodentFlow's model for one dark and one white mouse, was rebuilt after version 1 missed dark mice, with the questions fixed before training and the results.
---

# A two-mouse model for one dark and one white mouse

<p class="rf-eyebrow">TUTORIAL 6 · MOUSEPOSE6DYADBW_960_INT8 · VERSION 2</p>

MousePose6-DyadBW is the model RodentFlow uses for two mice when the *Coat colour* is set to **One dark, one white**, for example a black resident and a white intruder. It is a separate model: the two-dark-mice model MousePose6-Dyad is unchanged. Its outputs match the app's other pose models, and it was trained on DooM videos with both mice labelled in every frame. Version 2, the one that ships, was retrained after version 1 missed dark mice in a laboratory it had not seen.

<Badge type="info" text="YOLO26s-pose" /><Badge type="info" text="6 keypoints × 2 mice" /><Badge type="info" text="960 px" /><Badge type="tip" text="Core ML · 8-bit weights" />

## Model card {#card}

<table class="rf-kv">
<tr><th>Shipped file</th><td><code>MousePose6DyadBW_960_int8.mlpackage</code> (9.66 MiB); metadata <code>rodentflow.version = v2</code>; in RodentFlow 2.0 and later, on Mac, iPhone and iPad</td></tr>
<tr><th>Task</th><td>One class, <code>mouse</code>, up to two per frame; six keypoints each: <code>nose</code>, <code>left_ear</code>, <code>right_ear</code>, <code>neck</code>, <code>body_center</code>, <code>tail_base</code></td></tr>
<tr><th>Starting weights</th><td>Ultralytics <code>yolo26s-pose.pt</code> (pretrained on COCO keypoints), as MousePose6-Dyad</td></tr>
<tr><th>Size</th><td>9,753,237 parameters</td></tr>
<tr><th>Input / output</th><td>960 × 960 RGB image → tensor of shape (1, 300, 24), end-to-end head</td></tr>
<tr><th>Training data</th><td>DooM videos from 10 laboratories: dark–white pairs from 7, pairs of dark mice from 4 (TranquilPanther has both); 25,071 training and 3,101 validation images. A further laboratory, InvincibleJellyfish, was held out for testing.</td></tr>
<tr><th>Labels</th><td>Each laboratory's pose tracks for nose, ears and tail base; neck and body centre derived by one rule. Every mouse in every frame is labelled. <strong>Not human annotation.</strong></td></tr>
<tr><th>Software</th><td>Ultralytics 8.4.204, PyTorch 2.14.1 (CUDA 13.0), Python 3.13; one NVIDIA RTX PRO 6000 Blackwell GPU in Google Colab</td></tr>
<tr><th>Training run</th><td><code>dyad_bw_s960_v2</code>, 80 epochs, 2.6 h; checkpoint SHA-256 <code>1c5082e7…922b37</code></td></tr>
<tr><th>Export</th><td>Core ML ML Program, coremltools 9.0, <code>quantize=8</code>, <code>nms=False</code>; 7 November 2026</td></tr>
<tr><th>Licence field in the package</th><td>AGPL-3.0 (written by Ultralytics on export; see <a href="/RodentFlow/tutorials/citations.html#licences">licences</a>)</td></tr>
</table>

Sources: package metadata; notebook `DyadBW_YOLO26_Train_v2`, including the version-1 results it quotes; app source.

## Why a separate model {#why}

The two-dark-mice model MousePose6-Dyad (described in the [blog](../blog/training-on-existing-tracks.md#dyad)) finds white mice poorly. On the held-out dark–white test images below, it found 96.3 % of the dark mice but only 54.8 % of the white mice, and merged the pair into one box in 38.2 % of images. A model trained on dark–white pairs solves that, but changing MousePose6-Dyad would change results for every dark-pair study, so the dark–white model is separate and chosen by coat colour.

## Version 1 and what went wrong {#v1}

Version 1 (run `20261107_031448`) was trained on dark–white pairs from seven laboratories. On their held-out videos it found 98.5 % of white and 98.7 % of dark mice. In the held-out laboratory, InvincibleJellyfish, it found 97.7 % of white mice but only **56.4 % of dark mice**: in 19 of the 50 videos it found almost none, while in 24 it found more than 90 %. In the failing videos the dark mouse was very dark and the bedding was dark and granular. All dark mice in the seven training laboratories were on light bedding; the laboratories with dark-mouse pairs that MousePose6-Dyad had learned from covered that kind of image. Two UppityFerret training videos also had tracks out of step with the video, putting about 160 labels on empty bedding.

Version 2 changed four things:

1. **Pairs of dark mice added** from the laboratories MousePose6-Dyad was trained on (CautiousGiraffe, ElegantMink including brown 129 mice, NiftyGoldfinch, and TranquilPanther's dark pairs), about 2,500 images per laboratory. Their split follows DooM's own: DooM test videos go only to the test set, 20 images each.
2. **The dark–white part is unchanged**: the same videos, splits, frames and images as version 1, so version 2's test is version 1's test.
3. **Labels must sit on a mouse** (a new check, [Step 2](#label-check)).
4. **Fixed batch size** (40) to stay within GPU memory.

## The data {#data}

All videos come from DooM ([dataset](./citations.md#r-doom-data), [paper](./citations.md#r-doom)). The DooM metadata give each mouse's coat colour or strain; a mouse counts as white when its colour says white or albino, or, without a colour, when its strain is BALB/c, CD-1, CFW, Swiss, ICR or NMRI. 473 videos (80.8 GB) were used:

| Laboratory | Role | Dark–white videos | Dark-pair videos (of them DooM test) | Images per video |
|---|---|---|---|---|
| SparklingTapir | Training | 94 | — | 32 |
| JovialSwallow | Training | 77 | — | 39 |
| LyricalHare | Training | 37 | — | 81 |
| DeliriousFly | Training | 30 | — | 100 |
| ReflectiveManatee | Training | 30 | — | 100 |
| UppityFerret | Training | 30 | — | 100 |
| TranquilPanther | Training | 11 | 24 (7) | 273 / 147 |
| CautiousGiraffe | Training | — | 32 (22) | 250 |
| ElegantMink | Training | — | 26 (7) | 132 |
| NiftyGoldfinch | Training | — | 32 (21) | 227 |
| InvincibleJellyfish | **Unseen-laboratory test** | 50 | — | 30 |

Dark-pair videos in DooM's test split contribute 20 images each, to the test set only.

## Step 1 · From tracks to labels {#labels}

The conversion script (`bw_dyad_build.py`, saved with the results) applies these rules to every video:

- **Crop to the tracked region.** Each frame is cropped to the range of all tracked points, which removes stitched side views, neighbouring cages and empty borders.
- **Core points from the tracker.** Nose, left ear, right ear and tail base come from the laboratory's tracks. Neck and body centre are derived with the **same rule as the white-mouse model** (neck from the ear midpoint, nose and tail base, a = 0.127, b = 0.057; body centre = midpoint of neck and tail base). In the five laboratories that also track a neck, the derived neck differed from the tracked one by 0.016–0.034 L (one summary value per laboratory).
- **Left and right per video.** Ears are checked with the top-view geometry rule (the left ear lies on the animal's left of the head axis). A video whose ears are reversed throughout is swapped; single reversed frames are dropped. All 50 InvincibleJellyfish videos were reversed and swapped.
- **Quality filter.** Both mice must have all four tracked points, a body length 0.45–1.8 × that mouse's median, a plausible skeleton with the left ear on the left, no jump from neighbouring frames, and must not overlap into one; otherwise the frame is not used.
- **Every mouse labelled.** An unlabelled mouse would be learned as background.
- **Close contact.** About half of the frames are chosen with the mice less than one body length apart, and frames with the mice touching (under 0.5 L) get a higher weight.
- **Coat per mouse.** Each labelled mouse is marked white or dark from its body brightness, for the evaluation by coat.
- **Grayscale.** Half of the training and validation images are stored in grayscale; test images are kept in colour and evaluated both ways.

## Step 2 · Labels must sit on a mouse {#label-check}

Each labelled mouse must either move against the video's median background (median difference ≥ 6 and ≥ 3 × the image's overall difference) or differ clearly from its surroundings (median brightness difference ≥ 8). The thresholds are low on purpose, so that a still, low-contrast dark mouse on dark bedding, the case version 2 has to learn, is not removed. In training and validation sets, failing images are removed, and a video loses all its images when more than 30 % fail. In test sets, failing images are only flagged and kept, so that hard frames are not removed from the test.

| Laboratory | Removed from train / val | Videos dropped | Flagged in test (kept) |
|---|---|---|---|
| ElegantMink | 174 | 1 | 10 |
| LyricalHare | 193 | 0 | 16 |
| ReflectiveManatee | 63 | 0 | 15 |
| SparklingTapir | 32 | 0 | 2 |
| TranquilPanther | 75 | 0 | 3 |
| UppityFerret | 203 | 2 | 0 |
| NiftyGoldfinch | 2 | 0 | 2 |
| CautiousGiraffe, DeliriousFly, JovialSwallow, InvincibleJellyfish | 0 | 0 | 2 |
| **Total** | **742** | **3** | **50** |

The two UppityFerret videos found in version 1 were dropped completely (64 and 74 of 100 images failed), as was one ElegantMink video (63 of 132).

## Step 3 · Splits {#split}

- **Dark–white videos:** within each laboratory, by video, 80 / 10 / 10 % for train / validation / test, with the same order as the white-mouse dataset, so a video keeps its split across both datasets.
- **Dark-pair videos:** DooM's test videos go to the test set; 10 % of the others go to validation.
- **InvincibleJellyfish:** test only.

| Laboratory | Pair | Train | Validation | Test | Unseen-lab test |
|---|---|---|---|---|---|
| SparklingTapir | Dark–white | 2,405 | 282 | 288 | |
| JovialSwallow | Dark–white | 2,376 | 312 | 312 | |
| LyricalHare | Dark–white | 2,166 | 314 | 324 | |
| DeliriousFly | Dark–white | 2,400 | 300 | 300 | |
| ReflectiveManatee | Dark–white | 2,342 | 295 | 300 | |
| UppityFerret | Dark–white | 2,198 | 299 | 300 | |
| TranquilPanther | Dark–white | 2,389 | 266 | 273 | |
| TranquilPanther | Dark pair | 2,205 | 294 | 140 | |
| CautiousGiraffe | Dark pair | 2,250 | 250 | 440 | |
| ElegantMink | Dark pair | 2,072 | 262 | 140 | |
| NiftyGoldfinch | Dark pair | 2,268 | 227 | 420 | |
| InvincibleJellyfish | Dark–white | | | | 1,500 |
| **Total** | | **25,071** | **3,101** | **3,237** | **1,500** |

Of the 32,909 images, 16,409 show the mice less than one body length apart and 2,657 touching.

## Step 4 · Questions fixed before training {#plan}

Before training, four questions and their criteria were saved to `analysis_plan.json` (7 November 2026, 14:06 UTC). Evaluation reads the file and never changes it.

1. **Primary.** In the unseen laboratory, does version 2 find the dark mice? Criterion: at least 95 % found, and at most 2 of the 50 videos with fewer than 20 % found.
2. On the dark–white test set, is version 2 no worse than version 1? Criterion: within 1 percentage point.
3. On the dark-pair test set, is version 2 no worse than MousePose6-Dyad? Criterion: within 1 percentage point.
4. On the MARS human pose annotations, how often does each model find the white intruder and the black resident?

## Step 5 · Training {#train}

<table class="rf-kv">
<tr><th>Network</th><td>YOLO26s-pose at 960 px, as MousePose6-Dyad and version 1</td></tr>
<tr><th>Schedule</th><td>80 epochs (patience 20; all 80 ran), batch 40, optimizer <code>auto</code>, cosine learning rate, mosaic switched off for the last 15 epochs, seed 2026, deterministic; 2.6 hours, 42.4 GB peak GPU memory</td></tr>
<tr><th>Augmentation</th><td>Horizontal and vertical flips (probability 0.5 each, exchanging left and right ears), scale 0.5, translation 0.1; no rotation (it loosens boxes and makes the two boxes overlap more), no mixup (it would overlay mice from two images); brightness only (<code>hsv_v</code> 0.4)</td></tr>
<tr><th>Early stopping</th><td>On the validation images, dark–white and dark pairs together</td></tr>
</table>

On the 3,101 validation images (6,202 mice) the final checkpoint reached box mAP50 0.993 and mAP50-95 0.833, and pose mAP50 0.941 and mAP50-95 0.731.

## Step 6 · Results {#results}

All three models were run the way the app runs them: grayscale, letterboxed into 960 × 960, confidence above 0.25. A labelled mouse counts as **found** when a detection is matched to it (Hungarian matching on the mean error of nose, ears and tail base, below 0.5 L). Distances: *apart* ≥ 1 L, *near* 0.5–1 L, *touching* < 0.5 L. 95 % confidence intervals come from 1,000 bootstrap resamples of videos. The labels are tracks, so these numbers measure agreement with the laboratories' trackers.

### Mice found {#found}

| Test set | Mice | Version 2 | Version 1 | MousePose6-Dyad |
|---|---|---|---|---|
| Dark–white, held-out videos: **dark** | 2,079 | **98.7 %** (97.8–99.5) | 98.7 % | 96.3 % |
| Dark–white, held-out videos: **white** | 2,079 | **98.7 %** (97.6–99.4) | 98.5 % | 54.8 % |
| Dark pairs, DooM test videos | 2,280 | **99.1 %** (98.6–99.5) | 94.3 % | 99.5 % |
| Unseen laboratory: **dark** | 1,500 | **88.1 %** (84.1–91.9) | 56.4 % | 98.9 % |
| Unseen laboratory: **white** | 1,500 | **96.2 %** (94.9–97.4) | 97.7 % | 77.4 % |

When the mice were touching, version 2 found 96.0 % of dark and 94.5 % of white mice in the dark–white test, and 83.0 % of dark and 81.9 % of white mice in the unseen laboratory.

### Both mice in one image {#both}

| Test set | Images | Both found: v2 | v1 | Dyad | Merged into one box: v2 | Dyad |
|---|---|---|---|---|---|---|
| Dark–white, held-out videos | 2,097 | **97.4 %** | 97.4 % | 53.7 % | 2.0 % | 38.2 % |
| Dark pairs | 1,140 | **98.2 %** | 89.3 % | 98.9 % | 1.0 % | 0.1 % |
| Unseen laboratory | 1,500 | **84.9 %** | 54.9 % | 76.6 % | 14.3 % | 22.3 % |

With the mice touching, version 2 found both in 90.0 % of dark–white test images and 67.2 % of unseen-laboratory images. When both were found, the brighter box was the white mouse in 99.9 % of dark–white test images and in all unseen-laboratory images.

### Keypoints {#keypoints}

Share of the four tracked keypoints of detected mice within 0.1 body lengths (PCK@0.1), and median error of the derived body centre:

| Test set | Coat | v2 PCK@0.1 | v1 | Dyad | Body centre: v2 | Dyad |
|---|---|---|---|---|---|---|
| Dark–white, held-out videos | Dark | 94.6 % | 94.7 % | 85.9 % | 0.014 L | 0.274 L |
| | White | 93.3 % | 93.0 % | 61.4 % | 0.019 L | 0.291 L |
| Unseen laboratory | Dark | 96.4 % | 95.5 % | 95.2 % | 0.016 L | 0.254 L |
| | White | 94.7 % | 93.9 % | 63.6 % | 0.021 L | 0.310 L |
| Dark pairs | Dark | 96.1 % | 91.5 % | 94.7 % | 0.016 L | 0.272 L |

MousePose6-Dyad's large body-centre error is a difference of definition, not of accuracy: it learned one laboratory's body centre, about 0.4 L behind the nose ([blog](../blog/training-on-existing-tracks.md#dyad-data)), while version 2 uses the midpoint of neck and tail base, like MousePose6 and WhiteMousePose6. **Body-centre measures are therefore comparable between the single-mouse models and the dark–white model, but not with MousePose6-Dyad.**

### Answers to the four questions {#answers}

1. **Not met.** Version 2 found 88.1 % of the dark mice in the unseen laboratory, up from 56.4 % but below the 95 % criterion, and below MousePose6-Dyad's 98.9 %. The number of videos below 20 % is not in the saved notebook.
2. **Met.** On the dark–white test, version 2 found 98.7 % of dark and 98.7 % of white mice, against 98.7 % and 98.5 % for version 1.
3. **Met.** On the dark-pair test, version 2 found 99.1 %, within 1 point of MousePose6-Dyad's 99.5 %.
4. **Not reported.** The MARS evaluation cell has no saved output in the notebook.

Caution: TranquilPanther's dark–white test videos may have been in MousePose6-Dyad's training set, which would favour that model on those images.

## Step 7 · Export {#export}

The export matches the other two-mouse model: 8-bit weights, end-to-end head (`nms=False`), 960 × 960 input, checked for one (1, 300, 24) float32 output. The metadata record the keypoints, the neck rule, the training laboratories (`rodentflow.training_labs`), the held-out laboratory (`rodentflow.holdout_labs = InvincibleJellyfish`), `rodentflow.body_center = midpoint of neck and tail base`, the checkpoint's SHA-256 and `rodentflow.version = v2`. The file name is the same as version 1's, so the new package replaces it.

As for the white-mouse model, the notebook writes 24 test inputs with PyTorch predictions and a `verify_on_mac.py` script; according to the app's release notes, **that Core ML check had not yet been run** for version 2.

## In the app {#app}

- Choose **Coat colour: One dark, one white** for a two-mouse task (dyadic social interaction, resident–intruder). The default for two mice is *Two dark mice*, which uses MousePose6-Dyad. Two white mice are not supported yet.
- Tracking, A / B identity and analysis are the same as with MousePose6-Dyad. The Methods text states which of A and B is the dark mouse, from each video's recorded coat colours, and warns when they cannot be told apart.
- Detection rates are checked by coat: when the dark mouse is found in fewer than 80 % of frames, the app suggests that it may be missed on dark bedding and that you can re-run with *Two dark mice* to compare; when the white mouse is below 80 %, it suggests checking close-contact stretches.

## Limitations {#limits}

- **Dark mice on dark bedding in an unseen laboratory remain the weak point** (88.1 % found). Check detection rates by coat on your own videos, and compare with *Two dark mice* when the dark mouse is often missed.
- **Labels come from trackers**; no human-labelled result is reported for this model yet.
- **One unseen laboratory** was tested.
- **Touching mice** are harder: version 2 found both mice in 67.2 % of touching images in the unseen laboratory.
- Core ML parity with the PyTorch weights has not been reported.
- The DooM dataset licence still has to be confirmed on its EMBER record; see [licences](./citations.md#licences).

## What to cite {#cite}

RodentFlow with its version, Ultralytics YOLO26, and the DooM dataset and paper; see [How to cite](./citations.md#use-dyad-bw).
