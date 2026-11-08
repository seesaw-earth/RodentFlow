# Model tutorials

How the pose models inside RodentFlow were made: where the videos and labels came from, how they were cleaned, split, trained and tested, how they became Core ML packages, and how to cite every source correctly. The tutorials were written from the original notebooks, the model metadata and the app source.

The model files themselves, with checksums and licence notes, are on [Core ML models](../models.md).

## The models and where they came from {#models}

RodentFlow runs every analysis on the device. Five neural-network packages ship inside RodentFlow 2.1; the centroid tracker uses none. The four pose models share one input, one output layout and the same six keypoints, and the app picks one by the number of animals and their *Coat colour* ([which model a video uses](../models.md#coat)).

| | [MousePose6](./mousepose6.md) | [WhiteMousePose6](./white-mouse.md) | [MousePose6-DyadBW](./dyad-bw.md) | [MouseDetector](./tst-detector.md) |
|---|---|---|---|---|
| **Finds** | One dark mouse, six keypoints, top view | One white mouse, the same six keypoints | Two mice, one dark and one white | A box around each mouse in multi-chamber tail suspension |
| **Training data** | ETH Zurich (Zenodo, CC BY 4.0) and JAX JABS (Harvard Dataverse) videos with their released pose files; 8,840 frames from 52 videos | White mice from 9 laboratories of the DooM dataset; 7,586 training images, including 818 frames labelled by a larger model | Dark–white and dark–dark pairs from 10 DooM laboratories; 25,071 training images; one more laboratory held out | Synthetic images of one rig |
| **Labels** | DeepLabCut and JAX-network predictions, filtered | Laboratories' tracks plus a YOLO26m teacher, filtered; neck and body centre by rule | Laboratories' tracks; neck and body centre by rule | Generated with the images |
| **Model** | YOLO26n-pose, 960 px, 2.5 M parameters | YOLO26n-pose, 960 px, 2.5 M parameters | YOLO26s-pose, 960 px, 9.8 M parameters | YOLO11n detect, 320 px |
| **Test** | 1,350 frames: 94.6 % of mice detected; 96.1 % of their points within 0.1 body length of the reference labels | 740 white mice in held-out videos: 99.3 % detected; 95.8 % of points within 0.1 body length of the tracks | Held-out dark–white videos: 98.7 % of dark and of white mice found; dark pairs: 99.1 % | Chambers and onsets are shown for checking in every recording |

The fifth package, **MousePose6-Dyad** (two dark mice), is described in the [blog post on the manuscript](../blog/training-on-existing-tracks.md#dyad).

**CylinderMousePoseV2** ([tutorial 2](./cylinder-v2.md)) is no longer in RodentFlow: RodentFlow 2.0 removed the limb workflows, which now live in [RodentLimb](https://seesaw-earth.github.io/RodentLimb/models/). Tutorial 2 stays as the record of how it was made.

[Tutorial 4](./app-integration.md) covers the export and decoding steps that all the pose models share.

## How to read the numbers {#numbers}

- **The reference labels come from established trackers.** MousePose6 learned from the DeepLabCut and JAX pose-network predictions released with each dataset; WhiteMousePose6 and MousePose6-DyadBW from the DooM laboratories' tracks. The test scores give the agreement with these references on videos held out from training.
- **Keypoints are the input to the measures.** Each task turns them into measures with stated rules; see the [task pages](../tasks/) and [Speed and accuracy](../principles/performance.md).
- **On your own rig**, as with any automated scoring, compare the measures you report with hand scoring on a few videos before a large study ([Getting results you can trust](../principles/good-practice.md)).

::: warning
**Two of MousePose6's training datasets are non-commercial.** The two ETH Zurich datasets are CC BY 4.0, but the two JAX datasets on Harvard Dataverse are CC BY-NC-SA 4.0 (non-commercial, share-alike), which limits commercial use of MousePose6; see [tutorial 1](./mousepose6.md#sources). Ultralytics YOLO is AGPL-3.0 unless an Enterprise licence is used. See [the licence table](./citations.md#licences).
:::

## Read in order, or jump to what you need

1. **[MousePose6 from four public datasets](./mousepose6.md)**: keypoint harmonization, left/right fixing, frame sampling, video-level splits, training, evaluation.
2. **[Distilling DeepLabCut into CylinderMousePoseV2](./cylinder-v2.md)**: trajectory cleaning, pose clustering, agreement filter, two-stage training, paired comparisons.
3. **[The tail-suspension mouse detector](./tst-detector.md)**: what the package records, how the app runs it, how to train a detector for your own rig, and which trackers use no neural network.
4. **[From a trained model to Core ML in the app](./app-integration.md)**: export settings, metadata checks, Vision letterboxing, decoding the output tensor in Swift.
5. **[WhiteMousePose6 for white mice](./white-mouse.md)**: four tracked points to six, zoomed and background crops, a larger model labelling more frames, comparison with the teacher.
6. **[MousePose6-DyadBW for one dark and one white mouse](./dyad-bw.md)**: dark and dark–white pairs together, labels that must sit on a mouse, three models compared.
7. **[How to cite](./citations.md)**: what to cite for each model, full references, BibTeX, licence table, example methods text. All references are also in one BibTeX file, <a href="/RodentFlow/tutorials/references.bib" download>references.bib</a>.

## Sources for these pages

Every number on these pages comes from one of three places, and each page says which:

1. The original Google Colab notebooks used to build the datasets, train, evaluate and export the models (for example `1012_MousePose_Dataset_Builder_v1`, `MousePose_YOLO_Train_v1`, `MousePose_iOS_Export_v1`, `Cylinder_YOLO26_Pose_Training`, `Cylinder_YOLO26_v2_DLC_Distill`, `YOLO_on_CalMS21_v1`, `RodentPose_Colab`, `WhiteMouse_n960_6kp_Train`, `DyadBW_YOLO26_Train_v2`).
2. The metadata stored inside each shipped `.mlpackage` (training command, library versions, dates, input and output shapes).
3. The app source: the version published in the [RodentStudio-Support repository](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source) (model loading, decoding and the assays that use each model) and, for the coat-colour models, the RodentFlow 2.1 source (`Shared/PoseEngine/PoseModels.swift`).

The same archive also holds notebooks for models that the app does not ship (balance beam, RotaWheel, grooming clips, CalMS21 prompt experiments, RodentFlow 1.x re-analyses). They are not covered here.

Dataset records, licences and bibliographic details were checked against Zenodo, DataCite, Crossref and the publishers' pages on 20 October 2026. The DooM records were looked up on 7 November 2026. Items we could not confirm are labelled <Badge type="warning" text="To verify" />.

To cite these tutorials, use the [CITATION.cff](https://github.com/seesaw-earth/RodentStudio-Tutorials/blob/main/CITATION.cff) file in the tutorials repository.
