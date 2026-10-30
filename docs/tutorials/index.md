# Model tutorials

How the pose models inside RodentFlow were made: where the videos and labels came from, how they were cleaned, split, trained and tested, how they became Core ML packages, and how to cite every source correctly. The tutorials were written from the original notebooks, the model metadata and the app source.

The model files themselves, with checksums and licence notes, are on [Core ML models](../models.md).

## Three models, three different origins

RodentFlow runs every analysis on the device. Three neural-network packages ship inside the app; the centroid tracker uses none.

| | [MousePose6_960_int8](./mousepose6.md) | [CylinderMousePoseV2](./cylinder-v2.md) | [MouseDetector](./tst-detector.md) |
|---|---|---|---|
| **Finds** | One mouse per frame and six body points in top-view arenas | Paws, nose, mouth and tail base of a mouse rearing in a cylinder | A box around each mouse in multi-chamber tail-suspension videos |
| **Training data** | ETH Zurich (Zenodo, CC BY 4.0) and JAX JABS (Harvard Dataverse) videos with their released pose files; 8,840 frames from 52 videos | A lab DeepLabCut project: 543 human-labelled frames plus 20,000 cleaned DeepLabCut frames | Synthetic images from one rig, according to the app; dataset and notebook not available for review |
| **Labels** | DeepLabCut and JAX-network predictions, filtered; not human annotation | Human labels plus a DeepLabCut teacher | Not documented |
| **Model** | YOLO26n-pose, 960 px, 2.5 M parameters | YOLO26s-pose, 640 px, 9.8 M parameters | YOLO11n detect, 320 px |
| **Export** | Core ML, 8-bit weights, end-to-end head, 2.76 MiB | Core ML, full precision (FP32), raw head, 37.67 MiB | Core ML, FP16, built-in NMS, 5.14 MiB |
| **Test** | 1,350 frames: 94.6 % of mice detected; 96.1 % of their points within 0.1 body length of the reference labels | 80 human-labelled frames from held-out recordings; mean error 0.035 body length | Not documented |
| **In the app** | RodentPose workflows: open field, EPM, light–dark box, mazes, social tests… | RodentLimb workflows: cylinder test (also offered for limb tail suspension and gait) | Multi-chamber tail suspension; a classical detector is the fallback |

The fourth tutorial, [From a trained model to Core ML in the app](./app-integration.md), covers the export and decoding steps that all three models share.

## What the numbers do and do not show

- **MousePose6 was trained and tested against model-generated labels.** The reference points are the DeepLabCut and JAX pose-network predictions released with each dataset, after filtering. Its test scores measure agreement with those predictions, not with human annotators.
- **CylinderMousePoseV2 was tested on 80 human-labelled frames** from four held-out recording groups of one lab's setup. That is a small test set; the confidence intervals are reported in tutorial 2.
- **Checks outside the training data were mixed.** On CalMS21 home-cage videos with two interacting mice, MousePose6 found the resident mouse in 11.8 % of frames and the white intruder in 0.3 %. In a five-video elevated-plus-maze pilot, time-in-zone measures agreed well with a DeepLabCut-based reference, while arm entries, distance travelled and stretched-attend postures did not.
- **The detector's training data and accuracy are not documented** in the materials reviewed for these pages.
- **None of this is a validation of RodentFlow's behavioural measures.** Scientific use still needs human-scored comparison on your own videos.

::: warning
**Two of MousePose6's training datasets are non-commercial.** The two ETH Zurich datasets are CC BY 4.0, but the two JAX datasets on Harvard Dataverse are CC BY-NC-SA 4.0 (non-commercial, share-alike), which limits commercial use of MousePose6; see [tutorial 1](./mousepose6.md#sources). Ultralytics YOLO is AGPL-3.0 unless an Enterprise licence is used. See [the licence table](./citations.md#licences).
:::

## Read in order, or jump to what you need

1. **[MousePose6 from four public datasets](./mousepose6.md)**: keypoint harmonization, left/right fixing, frame sampling, video-level splits, training, evaluation, external checks.
2. **[Distilling DeepLabCut into CylinderMousePoseV2](./cylinder-v2.md)**: trajectory cleaning, pose clustering, agreement filter, two-stage training, paired comparisons.
3. **[The tail-suspension mouse detector](./tst-detector.md)**: what the package metadata says, what is missing, and which trackers use no neural network.
4. **[From a trained model to Core ML in the app](./app-integration.md)**: export settings, metadata checks, Vision letterboxing, decoding the output tensor in Swift.
5. **[How to cite](./citations.md)**: what to cite for each model, full references, BibTeX, licence table, example methods text. All references are also in one BibTeX file, <a href="/RodentFlow/tutorials/references.bib" download>references.bib</a>.

## Sources for these pages

Every number on these pages comes from one of three places, and each page says which:

1. The original Google Colab notebooks used to build the datasets, train, evaluate and export the models (for example `1012_MousePose_Dataset_Builder_v1`, `MousePose_YOLO_Train_v1`, `MousePose_iOS_Export_v1`, `Cylinder_YOLO26_Pose_Training`, `Cylinder_YOLO26_v2_DLC_Distill`, `YOLO_on_CalMS21_v1`, `RodentPose_Colab`).
2. The metadata stored inside each shipped `.mlpackage` (training command, library versions, dates, input and output shapes).
3. The app source published in the [RodentStudio-Support repository](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source) (model loading, decoding and the assays that use each model).

The same archive also holds notebooks for models that the app does not ship (balance beam, RotaWheel, grooming clips, CalMS21 prompt experiments, RodentFlow 1.x re-analyses). They are not covered here.

Dataset records, licences and bibliographic details were checked against Zenodo, DataCite, Crossref and the publishers' pages on 20 October 2026. Items we could not confirm are labelled <Badge type="warning" text="To verify" />.

To cite these tutorials, use the [CITATION.cff](https://github.com/seesaw-earth/RodentStudio-Tutorials/blob/main/CITATION.cff) file in the tutorials repository.
