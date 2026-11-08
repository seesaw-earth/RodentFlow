# Model tutorials

How the pose models inside RodentFlow were made: where the videos and labels came from, how they were cleaned, split, trained and tested, how they became Core ML packages, and how to cite every source correctly. The tutorials were written from the original notebooks, the model metadata and the app source.

The model files themselves, with checksums and licence notes, are on [Core ML models](../models.md).

## The models and where they came from {#models}

RodentFlow runs every analysis on the device. Five neural-network packages ship inside RodentFlow 2.1; the centroid tracker uses none. The four pose models share one input, one output layout and the same six keypoints, and the app picks one by the number of animals and their *Coat colour* ([which model a video uses](../models.md#coat)).

| | [MousePose6](./mousepose6.md) | [WhiteMousePose6](./white-mouse.md) | [MousePose6-DyadBW](./dyad-bw.md) | [MouseDetector](./tst-detector.md) |
|---|---|---|---|---|
| **Finds** | One dark mouse, six keypoints, top view | One white mouse, the same six keypoints | Two mice, one dark and one white | A box around each mouse in multi-chamber tail suspension |
| **Training data** | ETH Zurich (Zenodo, CC BY 4.0) and JAX JABS (Harvard Dataverse) videos with their released pose files; 8,840 frames from 52 videos | White mice from 9 laboratories of the DooM dataset; 7,586 training images, including 818 frames labelled by a larger model | Dark–white and dark–dark pairs from 10 DooM laboratories; 25,071 training images; one more laboratory held out | Synthetic images from one rig, according to the app; dataset and notebook not available for review |
| **Labels** | DeepLabCut and JAX-network predictions, filtered; not human annotation | Laboratories' tracks plus a YOLO26m teacher, filtered; neck and body centre by rule | Laboratories' tracks; neck and body centre by rule | Not documented |
| **Model** | YOLO26n-pose, 960 px, 2.5 M parameters | YOLO26n-pose, 960 px, 2.5 M parameters | YOLO26s-pose, 960 px, 9.8 M parameters | YOLO11n detect, 320 px |
| **Test** | 1,350 frames: 94.6 % of mice detected; 96.1 % of their points within 0.1 body length of the reference labels | 740 white mice in held-out videos: 99.3 % detected; 95.8 % of points within 0.1 body length of the tracks | Held-out dark–white videos: 98.7 % of dark and of white mice found; unseen laboratory: 88.1 % of dark, 96.2 % of white | Not documented |

The fifth package, **MousePose6-Dyad** (two dark mice), is described in the [blog post on the manuscript](../blog/training-on-existing-tracks.md#dyad); its notebooks have not yet been turned into a tutorial.

**CylinderMousePoseV2** ([tutorial 2](./cylinder-v2.md)) is no longer in RodentFlow: RodentFlow 2.0 removed the limb workflows, which now live in [RodentLimb](https://seesaw-earth.github.io/RodentLimb/models/). Tutorial 2 stays as the record of how it was made.

[Tutorial 4](./app-integration.md) covers the export and decoding steps that all the pose models share.

## What the numbers do and do not show

- **MousePose6 was trained and tested against model-generated labels.** The reference points are the DeepLabCut and JAX pose-network predictions released with each dataset, after filtering. Its test scores measure agreement with those predictions, not with human annotators.
- **WhiteMousePose6 and MousePose6-DyadBW were also trained and tested against tracks**, from the DooM laboratories. WhiteMousePose6 was tested only on laboratories that also supplied training videos. MousePose6-DyadBW was also tested on one laboratory it had never seen, where it found 88.1 % of the dark mice, below the 95 % its plan required; the two-dark-mice model found 98.9 % there.
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
5. **[WhiteMousePose6 for white mice](./white-mouse.md)**: four tracked points to six, zoomed and background crops, a larger model labelling more frames, comparison with the teacher.
6. **[MousePose6-DyadBW for one dark and one white mouse](./dyad-bw.md)**: what version 1 missed, labels that must sit on a mouse, questions fixed before training, three models compared.
7. **[How to cite](./citations.md)**: what to cite for each model, full references, BibTeX, licence table, example methods text. All references are also in one BibTeX file, <a href="/RodentFlow/tutorials/references.bib" download>references.bib</a>.

## Sources for these pages

Every number on these pages comes from one of three places, and each page says which:

1. The original Google Colab notebooks used to build the datasets, train, evaluate and export the models (for example `1012_MousePose_Dataset_Builder_v1`, `MousePose_YOLO_Train_v1`, `MousePose_iOS_Export_v1`, `Cylinder_YOLO26_Pose_Training`, `Cylinder_YOLO26_v2_DLC_Distill`, `YOLO_on_CalMS21_v1`, `RodentPose_Colab`, `WhiteMouse_n960_6kp_Train`, `DyadBW_YOLO26_Train_v2`).
2. The metadata stored inside each shipped `.mlpackage` (training command, library versions, dates, input and output shapes).
3. The app source: the version published in the [RodentStudio-Support repository](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source) (model loading, decoding and the assays that use each model) and, for the coat-colour models, the RodentFlow 2.1 source (`Shared/PoseEngine/PoseModels.swift`).

The same archive also holds notebooks for models that the app does not ship (balance beam, RotaWheel, grooming clips, CalMS21 prompt experiments, RodentFlow 1.x re-analyses). They are not covered here.

Dataset records, licences and bibliographic details were checked against Zenodo, DataCite, Crossref and the publishers' pages on 20 October 2026. The DooM records were looked up on 7 November 2026. Items we could not confirm are labelled <Badge type="warning" text="To verify" />.

To cite these tutorials, use the [CITATION.cff](https://github.com/seesaw-earth/RodentStudio-Tutorials/blob/main/CITATION.cff) file in the tutorials repository.
