---
title: Training small pose models on tracks that already exist
description: How the RodentFlow and RodentLimb models were trained without new manual labels, what the manuscript (v0.13) shows about them, and what has not yet been validated.
outline: [2, 3]
image: /img/blog/2026-11-manuscript/og-card.png
---

# Training small pose models on tracks that already exist

<p class="rf-eyebrow">BLOG · 4 NOVEMBER 2026 · FROM THE RODENTFLOW MANUSCRIPT, VERSION 0.13</p>

We are preparing a manuscript on RodentFlow and its companion app RodentLimb for bioRxiv. This post walks through what it reports. Most of the space goes to the models: which data and labels each one learned from, how it was trained, and how far it has been tested. All numbers come from version 0.13 of the manuscript. We will link the preprint here once it is posted. Click any figure to open it at full size.

::: tip In brief
- **Two apps, offline.** RodentFlow runs pose estimation, frame review, assay analysis and animal-level group statistics on a Mac, iPhone or iPad, with no account or network. It has 31 analysis workflows covering 21 assays. RodentLimb, for analyses that need the paws, adds seven workflows and four more assays.
- **No new manual labels.** Four models were trained on tracks and labels that already existed: the pose files released with public datasets, a laboratory's own DeepLabCut project, and the public training set of a DeepLabCut model.
- **Single mouse, top view.** MousePose6 detected 94.7 % of mice in held-out videos, and 95.9 % of its keypoints lay within 0.1 body lengths of the trackers that produced its labels.
- **Two mice, top view.** MousePose6-Dyad found both mice in 99.3 % of close-proximity validation frames. In a laboratory it had never seen, it placed 93.8 % of keypoints within 0.2 body lengths of human annotators (single annotators: 97.0 %), but it detected only 67.1 % of the intruders.
- **Paws.** Cleaned DeepLabCut tracks lowered the limb model's keypoint error against human labels by 31 %.
- **Near-infrared, from below.** On an unfamiliar rig, this model returned a frozen skeleton with keypoint confidence near 0.99. Confidence did not reveal the failure; how stable the skeleton stayed over the video did.
- **Speed.** The single-mouse model ran 2.5–4.4 times faster than real time on two MacBooks, an iPad and an iPhone.
- **Not yet validated.** Apart from the aggression workflow, no assay measure has been compared with human scoring. Distance, speed and entry counts from the pose workflows are experimental.
:::

## What the two apps do {#apps}

A user imports videos, calibrates the arena by dragging handles onto it and entering its real size, runs tracking, reviews the result and exports tables. Choosing the assay chooses the calibration geometry, the tracker and the analyser. Videos are read in place and never modified.

The manuscript groups the workflows into families by **what each analysis is computed from**:

| Family | What it uses | Workflows |
|---|---|---|
| Top-view keypoints | Six keypoints seen from above (MousePose6; MousePose6-Dyad for two mice) and zones from the arena calibration | 16 in RodentFlow (Mac, iPhone, iPad), plus resident–intruder aggression on iPhone and iPad |
| Limb keypoints: limb measures | Paws, tail base and nose; measures computed from keypoint kinematics | Gait, cylinder test and tail suspension, in RodentFlow (Mac) and RodentLimb |
| Limb keypoints: behaviour scoring | The same keypoints; behaviours marked as events with keypoint rules | Itch (scratching), spontaneous pain (formalin, capsaicin), self-grooming and seizure scoring, in RodentLimb |
| Centroid position | A classical tracker sampled at 10 Hz, no neural network | 10 in RodentFlow (Mac) |
| Detection and silhouette motion | A detector finds the mouse in each chamber; immobility comes from pixel and silhouette change | Multi-chamber tail suspension, RodentFlow (Mac) |

Three design choices are meant to make results checkable:

1. **Track once, re-score freely.** Tracks are stored, so zones, thresholds and analysis windows can be changed without re-tracking. Each session's cached measures are keyed by a SHA-256 hash of the analyser version, assay, video, tracking run, model, phase and the complete calibration and parameter set, so any change forces recomputation.
2. **A review step for every session.** A sample of frames (100 by default) is shown with the keypoints overlaid. Flags and a verdict are stored and exported with the results.
3. **The animal is the unit.** Sessions are averaged within an animal before group statistics, phases are not pooled unless the user chooses to (with a warning), and excluding a session requires a reason, which is exported.

## Let existing tracks do the labelling {#idea}

Labelling frames, training a large network and tracking millions of frames are expensive, and for many datasets they have already been done. The manuscript asks whether those existing tracks, once audited and cleaned, can supervise small models that run on a laptop or phone.

| Model | Network and size in the app | Learned from |
|---|---|---|
| **MousePose6**<br>RodentFlow: Mac, iPhone, iPad | YOLO26n-pose · 960 px · 6 keypoints<br>2.52 M parameters · 2.76 MiB (8-bit) | Pose files released with four public datasets (DeepLabCut; JAX pose network) |
| **MousePose6-Dyad**<br>RodentFlow: iPhone, iPad (dyadic social, resident–intruder) | YOLO26s-pose · 960 px · 6 keypoints<br>9.75 M · 9.66 MiB (8-bit) | Tracks from four laboratories in the DooM dataset (DeepLabCut, SLEAP) |
| **Limb model** (CylinderMousePoseV2)<br>RodentFlow: Mac limb workflows; RodentLimb | YOLO26s-pose · 640 px · 7 keypoints<br>9.78 M · 37.67 MiB (32-bit); 18.9 MiB (16-bit, RodentLimb) | Our laboratory's DeepLabCut project: human labels plus cleaned tracks |
| **Near-infrared model** (PalmReaderPose8)<br>RodentLimb | YOLO26s-pose · 640 px · 8 keypoints<br>9.83 M · 9.7 MiB (8-bit palettized) | Human labels of a public DeepLabCut training set (palmreader-500) |

All four started from COCO-pretrained Ultralytics weights and were trained on one NVIDIA RTX PRO 6000 Blackwell GPU. The models then run in the apps as Core ML packages. The accuracies below were measured with the PyTorch weights before export; agreement of the exported packages is covered under [speed](#speed).

**How errors are expressed.** Keypoint errors are given in body lengths (L): the distance from nose to tail base in the reference. "Within 0.1 L" means within a tenth of that distance; for a mouse 50 px long, that is 5 px.

## 1 · MousePose6: pooling public tracks from two institutes {#mousepose6}

### The data {#mp6-data}

Four public top-view datasets publish videos together with pose files. Two come from ETH Zurich (an open-field dataset, and a marble-burying, light–dark-box and fear-conditioning dataset), tracked with DeepLabCut at 13 points. Two come from The Jackson Laboratory (a strain survey and a BxD survey), tracked with the JAX pose network at 12 points. From these, 8,840 frames from 52 videos were split **by video** into 6,140 training, 1,350 validation and 1,350 test frames, so that near-identical frames of one video never appear on both sides of a split.

Only the six keypoints shared by all sources were kept: nose, left ear, right ear, neck, body centre and tail base. Because the sources place the body centre differently, it was recomputed in every source as the midpoint of neck and tail base. A median of 94.4 % of frames per video passed the quality filters (confident core points inside the image, a plausible body length and no large jumps between neighbouring frames).

### Harmonising conventions {#mp6-harmonise}

Pooling labels from different laboratories means checking that they mean the same thing. Two checks mattered most:

- **Left and right.** With "left" defined as the animal's own left in a non-mirrored top view, the per-video median fraction of frames following this convention was 0.990, 0.976, 0.983 and 0.991 in the four sources. Frames that the geometric rule (the side of the head axis, from neck to nose, on which each ear lies) identified as following the opposite convention were relabelled frame by frame. The MARS keypoints distributed with CalMS21, read in the order its documentation gives, followed the opposite convention in essentially every frame; we used them only for testing. On the MARS human pose annotations, the geometric rule agreed with the annotators' left and right ears in 99.4 % of mice. A consistent left/right mapping matters because flip augmentation relies on it.
- **Where the points sit.** In body-length coordinates, the labelled neck lay 0.27–0.31 L behind the nose depending on the source, a spread of about 4.5 % of body length. Whatever its cause, it limits how closely one model can agree with every source at once.

Mice were small in the ETH open-field videos: at 640-px model input, the 10th percentile of the longest side of the mouse's bounding box was 36.5 px, below the 40 px we set as a minimum, against 54.7 px at 960 px. The model was therefore trained at 960 px.

<figure>

[![Figure 2: four panels on the single-mouse training data](/img/blog/2026-11-manuscript/fig2-harmonising-public-tracks.png)](/img/blog/2026-11-manuscript/fig2-harmonising-public-tracks.png)

<figcaption><strong>Manuscript Fig. 2 · Harmonising public single-mouse tracking data.</strong> (a) Frames per source and split. (b) Per-video fraction of frames whose ear labels follow the animal-left convention, before correction; CalMS21 (MARS keypoints) is shown for comparison and was not used for training. (c) Mean pose per source in body-length coordinates (nose at 0, tail base at 1), with the neck position of each source. (d) 10th percentile of mouse size at 640-px (open) and 960-px (filled) input; the line marks 40 px.</figcaption>
</figure>

### Training recipe {#mp6-recipe}

<table class="rf-kv">
<tr><th>Network</th><td>YOLO26n-pose, COCO-pretrained; Ultralytics 8.4.176</td></tr>
<tr><th>Schedule</th><td>120 epochs (patience 30; all epochs completed), 960 × 960 px, automatic batch size, seed 2026</td></tr>
<tr><th>Augmentation</th><td>Horizontal and vertical flips (probability 0.5 each), no rotation, scale 0.5, translation 0.1, saturation 0.3, value 0.4, no hue change; mosaic switched off for the last 10 epochs</td></tr>
<tr><th>Left/right under flips</th><td>In this Ultralytics version the keypoint flip index is applied after vertical as well as horizontal flips (checked in the source), so both flips keep the anatomical convention. The flip index is <code>[0, 2, 1, 3, 4, 5]</code>: only the ears swap.</td></tr>
<tr><th>Hardware</th><td>One NVIDIA RTX PRO 6000 Blackwell GPU; PyTorch 2.11.0, CUDA 13.0, Python 3.13</td></tr>
<tr><th>Export</th><td>coremltools 9.0, ML Program, 8-bit weights, end-to-end head (300 candidates, no non-maximum suppression)</td></tr>
</table>

### Results on held-out videos {#mp6-results}

On 1,350 test frames from eight videos not used for training:

- **94.7 % of mice detected** at the app's confidence threshold (95 % CI 85.6–100 %, bootstrap over videos).
- **Median keypoint error 1.17 px (0.022 L)** relative to the source-tracker labels.
- Among detected mice, **85.6 %** of keypoints lay within 0.05 L and **95.9 %** within 0.1 L. Counting every keypoint of a missed mouse as a failure, 90.9 % lay within 0.1 L.
- Performance was uniform except for one video: one of the two JAX strain-survey test videos (a 129P3/J mouse) was detected in 71.6 % of frames; every other test video reached 100 %.
- The same weights at 640-px input lowered detection to 93.2 %, with the largest loss in the strain survey.

<figure>

[![Figure 3: five panels on MousePose6 test results](/img/blog/2026-11-manuscript/fig3-mousepose6-held-out.png)](/img/blog/2026-11-manuscript/fig3-mousepose6-held-out.png)

<figcaption><strong>Manuscript Fig. 3 · MousePose6 reproduces the source trackers on held-out videos.</strong> 1,350 test frames from eight videos; reference, the source-tracker labels. (a) Fraction of keypoints within a distance threshold, among detected mice. (b) Mice detected, with 95 % CI by bootstrap over videos. (c) Median error per keypoint and source. (d) Keypoints within 0.1 L with missed mice counted as failures, at 640-px and 960-px input. (e) Detection rate per test video.</figcaption>
</figure>

::: warning What these numbers do and do not show
They measure agreement with the trackers that produced the labels, on videos from the same laboratories and rigs. They do not measure accuracy against human annotation or on new rigs, and errors shared by the source tracker and the model are invisible to them.

Agreement of keypoints also does not make assay measures correct. In a pilot on five elevated-plus-maze videos, time-based measures computed from the pose tracks agreed with those from DeepLabCut tracks (ICC 0.74–0.91), but distance travelled was on average 2.8 times the DeepLabCut-based value. A stage-by-stage audit traced much of this to trajectory cleaning: the jump filter rejected positions far from the last accepted point, and interpolation then drew a straight path through them. Until this step has been revised and validated, distance, speed and entry counts from the pose workflows are experimental.
:::

## 2 · MousePose6-Dyad: two mice in close proximity {#dyad}

### Why a second model {#dyad-why}

The single-mouse model does not transfer to interacting pairs. On the 70 resident–intruder videos of the CalMS21 training split (33,883 frames), it detected the black resident in 10.5 % and the white intruder in 0.3 % of frames, and found both in fewer than 0.01 %.

### The data {#dyad-data}

The DooM (Days of our Mice) dataset collects top-view videos of interacting mice from several laboratories, each with its own DeepLabCut or SLEAP tracks. Of five laboratories considered, four supplied usable tracks; GroovyShrew was excluded because only three of the six keypoints could be mapped. The training set has **25,000 frames from 125 videos**: 13,000 training frames from 65 videos and 12,000 validation frames from the 60 videos in the dataset's own test split. Every mouse is labelled in every frame, half of the frames were chosen in close proximity (centroids less than one body length apart), and half were stored in grayscale.

The label audit found two problems that this model, as trained, did not correct:

- **Mixed ears in one laboratory.** Ear labels followed the animal-left convention in three laboratories (per-video medians 0.997–1.000) but were mixed within videos in TranquilPanther (median 0.709), the largest contributor of training frames (5,000 of 13,000). No left/right harmonisation was applied to this set.
- **A different body centre.** Only NiftyGoldfinch labels a body centre, at 0.41 L behind the nose. The model learned that definition: it places the body centre at a median of 0.39 of the nose–tail-base distance from the nose, against 0.63 for the single-mouse model. **Measures based on the body centre are therefore not interchangeable between the app's single- and two-mouse modes.**

### Training recipe {#dyad-recipe}

<table class="rf-kv">
<tr><th>Network</th><td>YOLO26s-pose, COCO-pretrained; Ultralytics 8.4.184</td></tr>
<tr><th>Schedule</th><td>60 epochs, 960 px, batch 32, patience 25</td></tr>
<tr><th>Augmentation</th><td>Horizontal flips (probability 0.5, exchanging left and right keypoints), no vertical flips, rotation up to 180°, scale 0.4, saturation 0.5; mosaic switched off for the last 10 epochs; half of the images in grayscale</td></tr>
<tr><th>Unlabelled points</th><td>Keypoints a laboratory does not annotate were written as not visible. In this Ultralytics version they are excluded from the keypoint-location losses but remain "not visible" targets for the keypoint-confidence output, so the model learned to report low confidence for them.</td></tr>
<tr><th>Export</th><td>As MousePose6: 8-bit weights, end-to-end head</td></tr>
</table>

### Results {#dyad-results}

On the 12,000 validation frames, a proximity-enriched sample from the contributing laboratories:

- Both mice found in **99.8 %** of frames when apart and **99.3 %** in close proximity, against 26.2 % and 14.1 % for the single-mouse model.
- In close proximity, the single-mouse model merged the pair into one box in 77.6 % of frames; the two-mouse model in 0.4 %.
- Median keypoint error relative to the laboratories' trackers: 0.030 L apart and 0.034 L in close proximity (0.015–0.049 L across laboratories).

CalMS21 comes from a laboratory, cage and camera the model had never seen. There it detected the black resident in **98.3 %** of frames and the white intruder in **67.1 %**. Finding both fell from 77.1 % when the mice were more than one body length apart to 16.3 % when their centroids were less than 0.5 L apart. Because the intruder was also the lighter mouse, coat colour is confounded here with social role, behaviour and occlusion.

<figure>

[![Figure 4: eight panels on the two-mouse model](/img/blog/2026-11-manuscript/fig4-two-mouse-model.png)](/img/blog/2026-11-manuscript/fig4-two-mouse-model.png)

<figcaption><strong>Manuscript Fig. 4 · A two-mouse model for social assays.</strong> (a) DooM training data per laboratory and split; one laboratory excluded. (b) Validation frames with both mice found, single- versus two-mouse model, apart versus close proximity (error bars, 95 % CI over videos). (c) Failure modes in close proximity. (d) Median keypoint error per laboratory relative to its tracker. (e) CalMS21 (unseen laboratory): resident and intruder detected. (f) CalMS21 frames with both mice found, by distance between the mice. (g, h) Identity agreement and swaps per minute with the app's identity rule (blue) or confidence ordering (grey).</figcaption>
</figure>

### Against human annotators {#dyad-human}

The MARS pose dataset provides 15,000 frames from the CalMS21 apparatus in which five annotators each placed the nose, ears, neck, hips and tail of both mice; the model had not been trained on any of them. On 14,996 frames, **94.0 %** of the five annotated keypoints of detected mice lay within 0.2 L of the annotators' median (77.1 % within 0.1 L; median error 0.050 L, 9.4 px). Measured against the median of the *other* annotators on the same frames, single annotators placed 97.0 % and the model 93.8 % of keypoints within 0.2 L. The model matched the annotators at the tail base and fell furthest behind at the ears (66–68 % within 0.1 L, against 87 %).

<figure>

[![Supplementary Figure S9: three panels comparing the two-mouse model with human annotators](/img/blog/2026-11-manuscript/figS9-two-mouse-vs-human.png)](/img/blog/2026-11-manuscript/figS9-two-mouse-vs-human.png)

<figcaption><strong>Manuscript Fig. S9 · Two-mouse model against human pose annotation</strong> (14,996 MARS frames from the CalMS21 laboratory). (a) Resident and intruder detected, by distance between the mice. (b) Keypoints within 0.1 L of the median of the other annotators, for single annotators (open) and the model (filled). (c) Cumulative keypoint error for annotators (grey) and the model (blue), apart (solid) or close (dashed).</figcaption>
</figure>

### Keeping identities {#dyad-identity}

::: info Which version this describes
This section describes the identity rule of the release evaluated in the manuscript. RodentFlow 2.0 replaces it with a method that reads the whole recording, described on the <a href="/RodentFlow/#identity" target="_self">home page</a>. That method is not part of the manuscript and is not evaluated here.
:::

The evaluated release assigns identities frame by frame, matching the two highest-scoring detections to each animal's last known keypoint centroid. Re-implemented line by line from the app source and run on every frame, this rule kept identities consistent in a median of **98.1 %** of scored frames in eight DooM videos (0.70 swaps per minute) and **75.7 %** in eight CalMS21 videos (2.77 swaps per minute). Ordering detections by confidence alone gave 56.5 % and 62.1 %, with 163 and 132 swaps per minute. Most swaps happened near close proximity. Scored frames covered a median of 98.2 % of DooM frames but only 73.1 % of CalMS21 frames, and the DooM references are the laboratories' own tracks, so these numbers describe agreement with a reference rather than accuracy against ground truth.

### Scoring aggression on the phone {#aggression}

The iPhone and iPad edition uses the two-mouse model for a resident–intruder workflow that scores attacks, chases, keep-downs, threat postures, mounting, sniffing and following from keypoint kinematics. Its thresholds were set by hand, without reference to CalMS21. On the 70 annotated CalMS21 training videos (4.7 h, one expert annotator), with the two-mouse model's detections as input:

- It found **78 %** of annotated attack bouts (85 % of those lasting 1 s or longer), and rule attack time ranked the 18 videos with attacks as the annotation did (**Spearman's ρ 0.92**).
- It is not specific: **frame precision for attack was 0.24**. Frames scored as attack were most often annotated as investigation, the rules scored some attack time in 50 of the 52 videos without annotated attacks, and the latency to the first attack did not agree with the annotation (ICC 0.02).
- Mounting time per video agreed closely with the annotation when both mice were tracked (**ICC 0.97** with the MARS keypoints as input), but the two-mouse model rarely detects an intruder lying beneath the resident and found only 13 % of mounting frames.

## 3 · The limb model: a laboratory's DeepLabCut project, cleaned {#limb}

The cylinder test scores forelimb use during rearing and needs the four paws, which top-view models do not track. Our laboratory had a DeepLabCut project for it: a ResNet-50 model with seven keypoints (four paws, tail base, nose and mouth), 743 human-labelled frames from 38 recording groups, and tracks for 519 recordings. The human frames were split **by recording group** into training (543 frames, 28 groups), validation (120, 6) and test (80, 4). Excluding the recordings in the validation and test groups, and one video that could not be opened, left 509 recordings and **34,292,020 tracked frames** for pseudo-labelling.

The detailed walk-through, with code, is in [Tutorial 2](../tutorials/cylinder-v2.md). The pipeline has three stages:

1. **Clean the trajectories.** A common likelihood rule (five or more points with likelihood ≥ 0.95) would have accepted 95.7 % of frames. The cleaning rules judge each frame in the context of its trajectory: a frame is dropped for any point of ambiguous likelihood (0.5–0.95), fewer than four visible points, a point far from its 7-frame rolling median, left and right paws that cross together to the wrong sides of the body axis, an implausible nose–mouth distance or body length, or a confident point outside the image. They kept **71.0 %** of frames, and flagged 405,948 frames that the likelihood rule had accepted. These flags mark likely errors; they were not verified frame by frame.
2. **Balance the poses.** From 752,692 spaced candidate frames, sampling evenly across 61 pose groups (60 clusters of body-aligned poses and one group of frames without a body axis) raised the share of rearing or otherwise foreshortened poses from **0.70 % to 3.95 %**.
3. **Ask for a second opinion.** A model trained on the human labels only (M0) predicted the 26,000-frame pool. Frames where M0 confidently disagreed with DeepLabCut by more than 0.25 L were rejected (903 frames), and **20,000 pseudo-labels from 506 recordings** were selected.

### Training recipe {#limb-recipe}

All stages used YOLO26s-pose with Ultralytics 8.4.177 at 640 px, batch 16, AdamW (initial learning rate 10⁻³, cosine schedule), seed 42 with deterministic training, mosaic probability 0.5, horizontal flips (probability 0.5, exchanging left and right paws), no vertical flips, rotation ±10°, translation 0.06 and scale 0.25.

| Stage | Starting point | Training data | Epochs |
|---|---|---|---|
| **M0** | COCO-pretrained | 543 human-labelled frames | 150 (patience 40) |
| **A** (shipped) | COCO-pretrained | 20,000 pseudo-labels + the human frames twice (21,086 images) | up to 60 (patience 20; best validation epoch 40) |
| **B** | Model A | Human frames, learning rate 2 × 10⁻⁴, no warm-up | up to 60 (patience 25; stopped after 30) |

The default pose metric saturates with seven keypoints, so the checkpoint kept from each stage was chosen by keypoint error on the human-labelled validation frames. Model A was exported to Core ML at 32-bit precision with a raw output head (CylinderMousePoseV2, for RodentFlow) and, from the same checkpoint, with 16-bit weights (CylinderPose7_FP16_640, for RodentLimb).

### Results {#limb-results}

On the 80 human-labelled test frames from four held-out recording groups, adding the pseudo-labels (model A):

- reduced the mean per-frame keypoint error from **0.050 L to 0.035 L, a 31 % reduction** (paired difference −0.016 L, 95 % CI −0.019 to −0.012);
- raised the fraction of keypoints within 0.05 L from **0.76 to 0.92**;
- halved the 90th percentile of keypoint error, from **12.9 to 6.6 px**.

Fine-tuning A on the human labels afterwards (model B) changed nothing. The DeepLabCut teacher itself scored better (0.021 L on the 60 test frames it could be matched to), but it was probably trained on some or all of the human labels, possibly including the test frames, which favours it in this comparison. Paw swaps fell on the same 5 of 80 test frames for M0, A and B; in each, fore and hind paws were swapped together, as if the whole body were mirrored, which points to a left/right convention difference in the labels of two recordings rather than a model error. The labels were not changed, so the errors above include these frames.

<figure>

[![Figure 5: eight panels on the limb-model pipeline and results](/img/blog/2026-11-manuscript/fig5-limb-model-from-dlc.png)](/img/blog/2026-11-manuscript/fig5-limb-model-from-dlc.png)

<figcaption><strong>Manuscript Fig. 5 · Turning a laboratory's DeepLabCut project into an on-device limb model.</strong> (a) From tracked frames to pseudo-labels (log scale). (b) Share of frames per pose cluster before and after balancing. (c) Frames flagged by each cleaning rule. (d) Disagreement between M0 and DeepLabCut; frames right of 0.25 L were rejected. (e) Paired differences in per-frame error. (f) Per-frame error by model; v1, previous model; DLC*, teacher, possibly trained on the test labels. (g) PCK curves. (h) Test frames with a left/right paw swap: the same five frames in every model.</figcaption>
</figure>

::: info How far this goes
The 80 test frames come from four recording groups on one rig, and each model was trained once. The confidence intervals resample frames, which are not independent, so they understate the uncertainty. The comparison measures the effect of the whole procedure in this run; it does not separate the contributions of cleaning, pose balancing and the amount of added data.
:::

## 4 · The near-infrared model, and a failure that confidence did not reveal {#nir}

### Data and training {#nir-training}

RodentLimb also ships a model for video filmed from below in dark chambers under near-infrared light. It was trained on human labels alone, from palmreader-500: the public training set of a DeepLabCut model released with Barkai et al. (2025), recorded through a glass floor under 850 nm light on the type of platform introduced with PalmReader. Of the project's nine keypoints we kept all but the tail tip. After dropping 64 frames with fewer than six labelled points or duplicated pixels, **409 frames from 15 recordings** were split by recording into 319 training, 53 validation and 37 test frames.

<table class="rf-kv">
<tr><th>Network</th><td>YOLO26s-pose, COCO-pretrained; Ultralytics 8.4.198</td></tr>
<tr><th>Schedule</th><td>640 px, batch 16, AdamW (initial learning rate 10⁻³, cosine schedule to 5 %), seed 42, deterministic; up to 200 epochs (patience 40; stopped after 108); best checkpoint on the validation frames</td></tr>
<tr><th>Augmentation</th><td>Rotation ±25°, translation 0.1, scale 0.25, brightness 0.15. No flips, because the left/right convention of the paw labels had not been verified; no mosaic, mixup or colour changes</td></tr>
<tr><th>Export</th><td>coremltools 9.0, ML Program, 8-bit palettized weights with 16-bit computation, raw output head (PalmReaderPose8_640_W8A16)</td></tr>
</table>

On the 37 test frames, **every mouse was detected**, the median keypoint error was **9.8 px** (90th percentile 24.4 px), and **77.1 %** of keypoints lay within 0.1 L of the labels (42.3 % within 0.05 L). These figures rest on two test recordings and one annotator.

### Transfer to two public datasets {#nir-transfer}

With no further near-infrared keypoint labels, we looked at transfer on two bottom-view datasets distributed with DeepEthogram, using measures that need no labels:

- **Mouse-Ventral1** was recorded on a PalmReader device and shares authors with the training set, so it tests new sessions on the same kind of rig. After contrast equalisation, the model found the mouse in a median of **99.3 %** of frames per video.
- **Mouse-Ventral2** comes from a different device, lit by infrared only and with a much brighter background. Given its original frames, the model reported a mouse in 71–100 % of sampled frames, depending on the scale, but in most videos it placed **the same skeleton in the same corner of the image in every frame.**

That frozen output passed the checks tracking pipelines usually rely on. Keypoint confidence was near 0.99, as high as when the model really tracked the mouse (0.92–0.99). The skeleton was anatomically plausible. It contained no jumps: jump filters look for too much movement, and this failure produced too little. Inverting the grey levels of Mouse-Ventral1 frames produced the same failure.

What exposed it was **the stability of the output over the video**. The interquartile range of the body length was 1.3 % of its median, against 51–54 % when the model tracked the mouse, and the body centre barely moved. A criterion on these two quantities flagged most Mouse-Ventral2 videos given the original frames, and none in either dataset with the input chosen for it. Darkening the background and shrinking the frame to 0.6 of its size, chosen from a grid of 20 input transformations without reference to any labels, restored tracking: the mouse was found in a median of **96.9 %** of frames per video (61 % in the worst), although keypoints were often misplaced when the mouse was curled.

<figure>

[![Supplementary Figure S10: grid of input transformations for the two DeepEthogram datasets](/img/blog/2026-11-manuscript/figS10-near-infrared-input.png)](/img/blog/2026-11-manuscript/figS10-near-infrared-input.png)

<figcaption><strong>Manuscript Fig. S10 · Choosing the input transformation for the near-infrared model on DeepEthogram videos.</strong> For each input transformation and frame scale: large number, share of sampled frames passing geometric plausibility checks; "det", share with a detection; hatched, frozen skeleton in most videos; outlined, the input used.</figcaption>
</figure>

::: warning Use the near-infrared model only on rigs like its training rig
Without keypoint labels, the model's accuracy on these datasets is unknown. The stability criterion was defined after the failure had been seen, so its sensitivity and false-alarm rate on other data remain to be measured. Neither app yet transforms its input or applies the criterion. If you track video from a new rig, plot the body length and body-centre position over the video: a skeleton that never changes is a failure, however confident it looks.
:::

## Training at a glance {#training}

| | MousePose6 | MousePose6-Dyad | Limb model (A) | Near-infrared |
|---|---|---|---|---|
| Network | YOLO26n-pose | YOLO26s-pose | YOLO26s-pose | YOLO26s-pose |
| Ultralytics | 8.4.176 | 8.4.184 | 8.4.177 | 8.4.198 |
| Input · keypoints | 960 px · 6 | 960 px · 6 | 640 px · 7 | 640 px · 8 |
| Labels | Source trackers (DeepLabCut; JAX pose network) | Laboratories' trackers (DeepLabCut; SLEAP) | Cleaned DeepLabCut tracks + human labels | Human labels (one annotator) |
| Training images | 6,140 | 13,000 | 21,086 | 319 |
| Split unit | Video | Video (DooM's own split) | Recording group | Recording |
| Epochs | 120 | 60 | ≤ 60 (best 40) | ≤ 200 (stopped 108) |
| Flips | Horizontal + vertical | Horizontal | Horizontal | None |
| Rotation | None | Up to 180° | ±10° | ±25° |
| Core ML weights | 8-bit | 8-bit | 32-bit (16-bit in RodentLimb) | 8-bit palettized, 16-bit compute |

The training curves of the three models in RodentFlow:

<figure>

[![Supplementary Figure S5a: training and validation loss and validation mAP for three models](/img/blog/2026-11-manuscript/figS5a-training-curves.png)](/img/blog/2026-11-manuscript/figS5a-training-curves.png)

<figcaption><strong>Manuscript Fig. S5a · Training curves of the shipped models.</strong> Training and validation pose loss, and validation pose mAP50-95. The mAP uses Ultralytics' default keypoint sigmas; it saturates and is not used to compare models.</figcaption>
</figure>

## Speed on Apple devices {#speed}

We timed the Core ML packages with programs that reproduce the Mac edition's tracking path (decoding with AVFoundation, letterboxing by Vision, Core ML and selection of the highest-scoring candidate) on the same 30-s clips. On a 1280 × 960 maze clip, the single-mouse model processed:

| Device | Compute units | Frames per second | × real time |
|---|---|---|---|
| MacBook Air (15-inch, M4, 2025) | All | 109 | 4.4 |
| MacBook Pro (13-inch, M2, 2022) | All | 62 | 2.5 |
| iPhone 17 Pro Max | CPU + Neural Engine | 89 | 3.6 |
| iPad Pro 12.9-inch (M2) | CPU + Neural Engine | 75 | 3.0 |

The two-mouse model ran 1.8–3.3 times real time on two-mouse clips (decoding only the highest-scoring candidate). The 32-bit limb model about kept pace with 60-frames-per-second cylinder video on the Macs; it cannot use the Neural Engine. Most of the time per frame was spent outside the network: on the Macs, the single-mouse network itself took 5.8 ms (M4) and 11.2 ms (M2) per frame.

<figure>

[![Supplementary Figure S7: speed on four Apple devices and Core ML versus PyTorch agreement](/img/blog/2026-11-manuscript/figS7-apple-device-speed.png)](/img/blog/2026-11-manuscript/figS7-apple-device-speed.png)

<figcaption><strong>Manuscript Fig. S7 · Inference speed and output agreement on Apple devices.</strong> (a) Frames per second of the tracking path on four devices; dashed lines, recording frame rate. (b) Latency of the two top-view networks alone, by compute units. (c) Distance between Core ML and PyTorch keypoints on the MacBook Air.</figcaption>
</figure>

Two caveats. First, agreement of the exported packages with their PyTorch weights was tested on one clip per model: the limb model agreed to a median of 0.90 px, whereas the 8-bit single-mouse model placed 83.5 % of keypoints within 0.1 L of PyTorch in frames both detected (93.0 % when both chose the same candidate) and chose a different candidate in 10.7 % of frames of the maze video. The two-mouse model and RodentLimb's two packages have not been tested. Second, on one NVIDIA A100 the PyTorch single-mouse model was 5.1–7.0 times faster than SuperAnimal-TopViewMouse and a DeepLabCut 3 ResNet-50 network on the 1280 × 960 maze video, largely because it resizes every frame to 960 px; on the same video downscaled to 640 × 480 it was only 1.2 times faster than DeepLabCut 3.

## What has and has not been validated {#validation}

| Question | Status in the manuscript |
|---|---|
| Do single-mouse keypoints agree with the trackers that produced the labels? | **Shown** on held-out videos from the training datasets |
| Does the two-mouse model separate mice in close proximity? | **Shown** in the training laboratories (proximity-enriched sample) |
| Does it work in an unseen laboratory? | **Partly**: resident 98.3 %, intruder 67.1 % on CalMS21; poor in mounting and attack |
| Are top-view keypoints accurate against human annotators? | **Partly**: two-mouse model 93.8 % within 0.2 L (annotators 97.0 %), one laboratory; single-mouse model not measured |
| Are limb keypoints accurate against human labels? | **Shown for one rig**, 80 test frames, one training run |
| Are near-infrared keypoints accurate against human labels? | **Partly**: 77.1 % within 0.1 L on two test recordings, one annotator |
| Do assay measures agree with human scoring? | **Partly** for resident–intruder aggression; **not measured** for the other 30 RodentFlow workflows or the RodentLimb workflows |
| Do RodentLimb's behaviour-scoring rules (itch, pain, grooming, seizure) agree with human scoring? | **No.** They were developed on simulated keypoint tracks. In an exploratory test on DeepEthogram videos, the default scratching rules reached a frame-level F1 below 0.05 (second annotator: 0.86 and 0.67) |
| Do distance, speed and entries agree with a reference? | **No**: distance 2.8 times the reference in a five-video pilot; experimental |
| Do the models generalise to other rigs, strains, coat colours or bedding? | **Largely unknown** |

The apps therefore suit studies that use the outputs validated here, or that validate the measures they need on their own recordings. They are not yet suited to studies that rely on distance or speed, on the unvalidated behaviour modules, or on rigs unlike those the models were trained on. Whichever you use, compare the app's output with manual scoring on some of your own videos first.

## Models, code and tutorials {#resources}

- **Models:** MousePose6, CylinderMousePoseV2 and the multi-chamber detector are on the [models page](../models.md), with SHA-256 checksums and licence notes. MousePose6-Dyad and RodentLimb's two packages ship inside the apps and are not yet in the public models repository.
- **Tutorials:** how [MousePose6](../tutorials/mousepose6.md) and [CylinderMousePoseV2](../tutorials/cylinder-v2.md) were built, step by step, and how the app [runs a Core ML model](../tutorials/app-integration.md).
- **Source code:** the RodentFlow apps for macOS and iOS/iPadOS, under AGPL-3.0: see [Source code](../source.md).
- **Notebooks:** the dataset-building, training and figure notebooks will be released with the preprint.
- **Citing:** until the preprint is posted, see [How to cite](../tutorials/citations.md).

## Data and references {#references}

Training data: ETH Zurich BehaviorFlow open field ([10.5281/zenodo.8186065](https://doi.org/10.5281/zenodo.8186065)) and marble burying, light–dark box and fear conditioning ([10.5281/zenodo.11235068](https://doi.org/10.5281/zenodo.11235068)), described in von Ziegler et al. 2024, *Nat Methods* ([10.1038/s41592-024-02500-6](https://doi.org/10.1038/s41592-024-02500-6)); JAX strain survey ([10.7910/DVN/SAPNJG](https://doi.org/10.7910/DVN/SAPNJG)) and BxD survey ([10.7910/DVN/RQYI04](https://doi.org/10.7910/DVN/RQYI04)), described in Choudhary et al. 2026, *eLife* ([10.7554/eLife.107259](https://doi.org/10.7554/eLife.107259)); DooM, EMBER-DANDI dandiset [000564](https://dandi.emberarchive.org/dandiset/000564), described in Marks et al. 2026, *bioRxiv* ([10.64898/2026.10.18.758876](https://doi.org/10.64898/2026.10.18.758876)); palmreader-500, released with Barkai et al. 2025, *Cell Rep Methods* ([10.1016/j.crmeth.2025.101145](https://doi.org/10.1016/j.crmeth.2025.101145)).

Test data: CalMS21 ([10.22002/D1.1991](https://doi.org/10.22002/D1.1991); Sun et al. 2021, [arXiv:2104.02710](https://arxiv.org/abs/2104.02710)); MARS pose annotations ([10.22002/D1.2011](https://doi.org/10.22002/D1.2011); Segalin et al. 2021, *eLife*, [10.7554/eLife.63720](https://doi.org/10.7554/eLife.63720)); DeepEthogram Mouse-Ventral1 and Mouse-Ventral2 (Bohnslav et al. 2021, *eLife*, [10.7554/eLife.63377](https://doi.org/10.7554/eLife.63377)); elevated-plus-maze videos of Sturman et al. 2020, *Neuropsychopharmacology* ([10.1038/s41386-020-0776-y](https://doi.org/10.1038/s41386-020-0776-y)).

Methods and tools: PalmReader (Zhang et al. 2022, *Pain*, [10.1097/j.pain.0000000000002680](https://doi.org/10.1097/j.pain.0000000000002680)); DeepLabCut (Mathis et al. 2018, *Nat Neurosci*, [10.1038/s41593-018-0209-y](https://doi.org/10.1038/s41593-018-0209-y)); SuperAnimal (Ye et al. 2024, *Nat Commun*, [10.1038/s41467-024-48792-2](https://doi.org/10.1038/s41467-024-48792-2)); Ultralytics YOLO26 ([arXiv:2606.03748](https://doi.org/10.48550/arXiv.2606.03748)); coremltools 9.0.

We thank the authors of these datasets for releasing their videos, tracks and labels; this work would not exist without them.
