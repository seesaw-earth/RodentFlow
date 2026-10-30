# Distilling a lab DeepLabCut model into a fast YOLO pose model

<p class="rf-eyebrow">TUTORIAL 2 · CYLINDERMOUSEPOSEV2</p>

CylinderMousePoseV2 tracks the paws, nose, mouth and tail base of a mouse in the cylinder test for RodentFlow's RodentLimb workflows. It learned from a few hundred human-labelled frames and twenty thousand carefully cleaned DeepLabCut predictions.

<Badge type="info" text="YOLO26s-pose" /><Badge type="info" text="7 keypoints" /><Badge type="info" text="640 px" /><Badge type="tip" text="Core ML · FP32" />

## Model card {#card}

<table class="rf-kv"> <tr><th>Shipped file</th><td><code>CylinderMousePoseV2.mlpackage</code> (37.67 MiB); metadata version 2.0</td></tr> <tr><th>Keypoints (output order)</th><td><code>L_fore_paw</code>, <code>L_hind_paw</code>, <code>R_fore_paw</code>, <code>R_hind_paw</code>, <code>tail_base</code>, <code>nose</code>, <code>mouth</code> — the order of the lab's DeepLabCut <code>config.yaml</code>; <code>flip_idx</code> = <code>[2, 3, 0, 1, 4, 5, 6]</code></td></tr> <tr><th>Starting weights</th><td>Ultralytics <code>yolo26s-pose.pt</code> (COCO-pretrained); 9,783,360 parameters</td></tr> <tr><th>Input / output</th><td>640 × 640 RGB → raw head tensor (1, 26, 8400); no NMS in the model</td></tr> <tr><th>Training data</th><td>The lab's cylinder recordings: 543 human-labelled frames (used twice) + 20,000 cleaned DeepLabCut pseudo-labels from 506 recordings</td></tr> <tr><th>Teacher</th><td>DeepLabCut ResNet-50 model <code>DLC_resnet50_cylinder_DLCJan2shuffle1_44000</code></td></tr> <tr><th>Software</th><td>Ultralytics 8.4.177, PyTorch 2.11.0, coremltools 9.0; run <code>20261014_1156_dlc_distill</code></td></tr> <tr><th>Precision</th><td>FP32 (exported without quantization)</td></tr> <tr><th>Recorded test error</th><td><code>test_err_body_length</code>: “0.035 (v1-style manual-only baseline 0.050)”</td></tr> </table>
Sources: package metadata; notebooks `Cylinder_YOLO26_v2_DLC_Distill` and `Cylinder_YOLO26_Pose_Training` (v1); app source `Analysis/PoseTypes.swift`.

## Why distil DeepLabCut? {#why}

The lab already had a DeepLabCut model that analysed hundreds of cylinder videos. DeepLabCut gives accurate, project-specific keypoints, but its ResNet-50 network and Python stack do not fit an offline Mac app. A YOLO26 pose model exports cleanly to Core ML. Distillation turns the many videos DeepLabCut has already tracked into training data for the smaller model, with two risks to manage: the student can copy the teacher's mistakes, and a large pool of easy, repetitive frames can drown out the hard poses. Every step below addresses one of these.

## The lab's DeepLabCut project {#data}

- **Human labels:** 743 labelled frames in 38 `labeled-data` folders of the DeepLabCut project.
- **Teacher predictions:** one DeepLabCut `.h5` track per analysed video. After merging each recording with its `downsized_` copy there were 524 distinct recordings; 519 had tracks from the scorer named above. Videos were recorded at 60 fps.
- **Where the data live:** in the lab's own project on Google Drive. These pages do not establish whether the recordings are publicly available; if they are published (for example as a dataset with a DOI), cite that dataset.

## Step 1 · Splits without leakage {#split}

Splits were made only over human-labelled recording groups, so that every test frame is a human label from a recording the student never saw. Original and `downsized_` versions of a recording count as one group.

| Split      | Human-labelled frames | Recording groups | Used for                                                           |
|------------|-----------------------|------------------|--------------------------------------------------------------------|
| Train      | 543                   | 28               | M0, stage A (×2), stage B                                          |
| Validation | 120                   | 6                | Choosing between `best.pt` and `last.pt`, choosing the final model |
| Test       | 80                    | 4                | Reported results only                                              |

DeepLabCut pseudo-labels were drawn only from recordings outside the validation and test groups. Version 1 had grouped `downsized_` copies separately; the v2 notebook found that 39 v1 training frames came from v1 validation or test recordings, and v2's grouping removes that leak.

## Step 2 · Cleaning DLC trajectories {#clean}

Version 1 accepted a DeepLabCut frame when at least 5 of 7 points had likelihood ≥ 0.95; that let through 95.7 % of all frames. Version 2 judges each frame in the context of the whole trajectory and drops it if any rule fails:

| Rule            | Setting                                                                                                                                                                                                  |
|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Visibility      | Likelihood ≥ 0.95 → visible; \< 0.50 → occluded; any point in between → drop the frame, so the model never learns a wrong “not visible” signal                                                           |
| Enough points   | At least 4 visible points                                                                                                                                                                                |
| Temporal jumps  | A visible point more than 0.15 median body lengths from its 7-frame rolling median                                                                                                                       |
| Left/right swap | Left and right paws both on the opposite side of the tail_base→nose axis from where they usually are in that video (margin 0.05 body length; not tested when body length \< 0.5 × median, as in rearing) |
| Geometry        | Nose–mouth distance ≤ 0.35 body length; body length 0.30–1.60 × the video median; confident points inside the frame                                                                                      |

Of 34,292,020 DeepLabCut frames, the v1 rule would accept 32,827,454 (95.7 %); the v2 rules kept 24,362,080 (71.0 %).

## Step 3 · Choosing 20,000 frames {#select}

1.  Candidates: cleaned frames at least 10 frames apart, at most 1,500 per video → 752,692 candidates.
2.  Pose description: points relative to the tail base, rotated to the body axis and divided by the video's median body length, so rearing (short) and four-paw postures stay distinct.
3.  Clustering: k-means with 60 pose clusters, plus one group for frames missing the nose or tail base.
4.  Balanced draw: the same quota from every cluster, round-robin across videos, at most 120 frames per video, oversampled by 30 % → a pool of 26,000 frames from 506 recordings.

The notebook also checked that seeking to a frame number in the video returns the same image as reading sequentially, because DeepLabCut frame numbers count sequentially decoded frames. The check passed and seeking was used.

## Step 4 · A second opinion: the agreement filter {#agree}

A YOLO model trained only on the human labels (M0, below) is independent of DeepLabCut. It predicted every frame in the pool. Wherever M0 was confident about a point (confidence ≥ 0.5) and that point was more than 0.25 body lengths from DeepLabCut's, the frame was rejected and listed for human review. Frames M0 could not handle were *kept*, so the filter does not bias the set towards easy poses. 903 frames were rejected and 20,000 pseudo-labels remained.

Labels were written in YOLO pose format with the same box rule as v1: the envelope of the visible keypoints, padded by the larger of 5.5 % of the image size and 30 % of the keypoint extent on each axis.

## Step 5 · Three training stages {#train}

| Stage                | Starts from       | Training data                                                | Epochs (patience) | Learning rate    |
|----------------------|-------------------|--------------------------------------------------------------|-------------------|------------------|
| M0 · manual only     | `yolo26s-pose.pt` | 543 human frames                                             | 150 (40)          | 1e-3             |
| A · pseudo + manual  | `yolo26s-pose.pt` | 20,000 pseudo-labels + 543 human frames × 2 (21,086 entries) | 60 (20)           | 1e-3             |
| B · manual fine-tune | stage A           | 543 human frames                                             | 60 (25)           | 2e-4, no warm-up |

    COMMON_TRAIN = dict(imgsz=640, batch=16, seed=42, deterministic=True, optimizer='AdamW', cos_lr=True,
                        mosaic=0.5, mixup=0.0, fliplr=0.5, flipud=0.0, degrees=10.0, translate=0.06, scale=0.25)
    model = YOLO('yolo26s-pose.pt')
    model.train(data='data_stageA_pseudo_plus_manual.yaml', epochs=60, patience=20, lr0=1e-3, **COMMON_TRAIN)

With seven points and Ultralytics' default OKS sigmas, pose mAP50-95 was already about 0.92–0.96 and could not separate models, so after each stage the notebook chose between `best.pt` and `last.pt` by mean keypoint error on the validation frames, and chose the final model the same way. Stage A had the lowest validation error (0.0339 body lengths, against 0.0343 for B and 0.0503 for M0) and became CylinderMousePoseV2.

## Step 6 · Evaluation on human labels {#eval}

All errors are measured against human labels and divided by the body length (the human nose–tail_base distance). *Frame error* is the mean over a frame's points; a missed mouse would count as one body length. PCK@*t* is the share of points within *t* body lengths. The L-R swap rate is the share of frames in which the predicted left and right paws match the human labels better when exchanged. 95 % confidence intervals come from 2,000 bootstrap resamples.

| Model (test split)           | Frames | Frame error \[95 % CI\] | Median error | 90th pct. | PCK@0.05 | PCK@0.1 | Fore / hind L-R swap |
|------------------------------|--------|-------------------------|--------------|-----------|----------|---------|----------------------|
| M0 · manual only             | 80     | 0.0502 \[0.040, 0.062\] | 4.29 px      | 12.93 px  | 0.762    | 0.919   | 6.3 % / 6.4 %        |
| A · shipped                  | 80     | 0.0346 \[0.025, 0.046\] | 2.76 px      | 6.60 px   | 0.919    | 0.956   | 6.3 % / 6.4 %        |
| B · manual fine-tune         | 80     | 0.0349 \[0.026, 0.047\] | 3.11 px      | 6.40 px   | 0.923    | 0.958   | 6.3 % / 6.4 %        |
| DLC teacher (reference only) | 60     | 0.0211 \[0.018, 0.024\] | 2.70 px      | 5.03 px   | 0.965    | 0.995   | 1.7 % / 0.0 %        |

All models detected the mouse in every test frame. DeepLabCut could be compared on 60 of the 80 test frames (those whose video version and frame index could be matched).

**Paired comparisons on the same 80 test frames** (difference in frame error, body lengths, bootstrap 95 % CI):

- A − M0 = −0.0156 \[−0.019, −0.012\]: the DeepLabCut pseudo-labels clearly helped.
- B − A = +0.0003 \[−0.001, 0.001\]: fine-tuning on human labels made no measurable difference.
- B − DLC teacher = +0.0112 \[0.004, 0.021\] on 60 frames: the teacher is still more accurate on these frames, but DeepLabCut was probably trained on these very human-labelled frames, so its numbers are optimistic.

The paw left/right swap rate did not change between M0, A and B (6.3 % fore, 6.4 % hind). Distillation did not fix it, and for limb-use asymmetry measures it matters more than average error.

## Step 7 · Export {#export}

    import json
    from ultralytics import YOLO
    import coremltools as ct

    # the .pt is first copied to CylinderMousePoseV2.pt so the package gets that name
    exported = YOLO('CylinderMousePoseV2.pt').export(format='coreml', imgsz=640)   # FP32, raw head, no NMS

    m = ct.models.MLModel(exported, skip_model_load=True)     # edit metadata only
    m.short_description = ('Cylinder mouse pose v2: YOLO26s-pose, DLC-distilled '
                           '(20k cleaned pseudo-labels + 543 manual), 7 keypoints')
    m.version = '2.0'
    m.author = 'Cylinder YOLO26 v2 pipeline'
    m.user_defined_metadata.update({
        'keypoints': json.dumps(['L_fore_paw', 'L_hind_paw', 'R_fore_paw', 'R_hind_paw', 'tail_base', 'nose', 'mouth']),
        'input_size': '640',
        'output_shape': '(1, 26, 8400)  # 4 box + 1 conf + 7x3 keypoints',
        'source_run': '20261014_1156_dlc_distill',
        'test_err_body_length': '0.035 (v1-style manual-only baseline 0.050)',
    })
    m.save('CylinderMousePoseV2_final.mlpackage')    # then renamed back to CylinderMousePoseV2.mlpackage

Condensed from the last export cell of `Cylinder_YOLO26_v2_DLC_Distill` (run with Ultralytics 8.4.177 and coremltools ≥ 9.0). The shipped package was not quantized, which is why it is about 14 times larger than MousePose6. Writing the training run and test error into the package is a good habit: anyone can later check which model an app contains.

The notebook also exported 200 frames for human review (active learning): the frames where M0 and DeepLabCut disagreed most, plus examples of each rejection reason. Corrected, they can become new *training* labels, not test labels, because other frames of the same recordings are already in training.

## Version 1 and what changed {#v1}

Version 1 (`Cylinder_YOLO26_Pose_Training`) used the same architecture and training settings for 150 epochs, with 2,715 training images: the 543 human frames plus 2,172 DeepLabCut frames sampled at about one per second (likelihood ≥ 0.95 for at least 5 points). Validation (120) and test (80) frames were human labels. Version 2 changed four things: leak-free grouping, trajectory-based cleaning, pose-balanced sampling, and an independent agreement filter, and it replaced Ultralytics mAP with body-length-normalised errors and paired confidence intervals. The v1 model was also run on one video from a public PhysioNet cylinder-rearing dataset as a qualitative demonstration; that dataset was not used for training.

## Limitations {#limits}

- One lab, one rig, one camera setup. Other cylinders, lighting, frame rates or strains are untested.
- The test set is 80 frames from 4 recording groups; the confidence intervals are correspondingly wide.
- About 6 % of test frames have left/right paws swapped. Review paw identity before reporting asymmetry.
- Pseudo-labels inherit DeepLabCut's systematic biases; the agreement filter only removes clear disagreements.
- RodentFlow also offers this model for its limb-based tail-suspension and gait workflows. Those videos are outside its training data; validate before use.
- No comparison of derived cylinder-test scores (such as paw contacts) with human scoring is reported here.

## What to cite {#cite}

Cite RodentFlow (with version), Ultralytics YOLO26, DeepLabCut (Mathis et al. 2018; Nath et al. 2019) for the teacher model, and the lab's recordings if they are published. See the [citation page](/tutorials/citations#use-cylinder).
