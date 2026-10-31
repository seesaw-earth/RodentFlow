# How to cite the data, papers and software

<p class="rf-eyebrow">REFERENCE</p>

What to cite for each model, the full reference list, a licence summary, BibTeX and an example methods paragraph. Details were checked against Zenodo, DataCite, Crossref and publisher pages on 20 October 2026.

## Three rules for citing data {#principles}

1.  **Cite the dataset itself, by its DOI,** in the reference list, and also the paper its authors ask you to cite. A dataset and its paper are separate works.
2.  **Cite software with its version.** “Ultralytics YOLO26”, “RodentFlow 0.7.1”, “coremltools 9.0”: results can change between versions.
3.  **Say what you changed and where labels came from.** CC BY 4.0 requires credit, a link to the licence and an indication of changes. Here the labels were harmonized and filtered from DeepLabCut and JAX-network predictions; write that, rather than implying human annotation.

## If you used MousePose6 (RodentPose workflows) {#use-mousepose6}

| Cite                                                 | Why                                                                     | Reference                                   |
|------------------------------------------------------|-------------------------------------------------------------------------|---------------------------------------------|
| RodentFlow, with version                           | The software that ran the model and computed your measures              | [\[S1\]](#r-rodentstudio)                   |
| Ultralytics YOLO26                                   | Model architecture, pretrained weights, training and export code        | [\[S2\]](#r-yolo26)                         |
| ETH open-field dataset and ETH MB / LDB / FC dataset | Training videos and DeepLabCut pose files (CC BY 4.0)                   | [\[D1\]](#r-vz2023), [\[D2\]](#r-vz2024d)   |
| BehaviorFlow paper                                   | Describes the ETH recordings and their pose estimation                  | [\[P1\]](#r-vz2024)                         |
| JAX strain-survey and BxD datasets                   | Training videos and JAX pose files                                      | [\[D3\]](#r-jabs-ss), [\[D4\]](#r-jabs-bxd) |
| JABS paper and the JAX pose-network paper            | Describe the JAX datasets and the network that produced their keypoints | [\[P2\]](#r-jabs), [\[P3\]](#r-sheppard)    |
| DeepLabCut                                           | The ETH labels are DeepLabCut predictions                               | [\[P4\]](#r-mathis), [\[P5\]](#r-nath)      |
| COCO (recommended)                                   | The starting weights were pretrained on COCO keypoints                  | [\[P6\]](#r-coco)                           |

The strain-survey record names Geuther et al. 2019 [\[P7\]](#r-geuther2019) as its related publication, so cite it together with \[D3\]. The BxD record lists none. The strain-survey files are tagged by the JAX studies that used them (for example Gait, Grooming, JABS600, JABS1200); Geuther et al. 2021 [\[P8\]](#r-geuther2021) is the grooming study. Dataverse's own suggested citations are:

    Kumar, Vivek; Brian Geuther; Sean Deats, 2024, "The Jackson Laboratory (JAX) - Kumar Lab Mouse Strain Survey of Behavior in the Open Field Arena (Video Dataset)", https://doi.org/10.7910/DVN/SAPNJG, Harvard Dataverse, V1, UNF:6:OiPvgrf6RjsZOSxB9/nVEA== [fileUNF]

    Kumar, Vivek; Deats, Sean, 2025, "The Jackson Laboratory (JAX) - Kumar Lab Mouse BxD Survey of Behavior in the Open Field Arena (Video Dataset)", https://doi.org/10.7910/DVN/RQYI04, Harvard Dataverse, V1, UNF:6:r9GfOhUT7LK/e1KHwwhuHQ== [fileUNF]

## If you used CylinderMousePoseV2 (RodentLimb workflows) {#use-cylinder}

| Cite                          | Why                                                              | Reference                                           |
|-------------------------------|------------------------------------------------------------------|-----------------------------------------------------|
| RodentFlow, with version    | Ran the model and the RodentLimb analyzers                       | [\[S1\]](#r-rodentstudio)                           |
| Ultralytics YOLO26            | Model architecture, pretrained weights, training and export code | [\[S2\]](#r-yolo26)                                 |
| DeepLabCut                    | The teacher model that produced 20,000 of the training labels    | [\[P4\]](#r-mathis), [\[P5\]](#r-nath)              |
| The lab's cylinder recordings | Training data; cite the dataset if it is published               | <Badge type="warning" text="To add if published" /> |
| COCO (recommended)            | Pretraining of the starting weights                              | [\[P6\]](#r-coco)                                   |

## If you used the TST detector {#use-detector}

Cite RodentFlow [\[S1\]](#r-rodentstudio) and Ultralytics YOLO11 [\[S3\]](#r-yolo11), and report whether the YOLO or the classical detector was used (RodentFlow's exports record this). For RodentFlow workflows, no model citation is needed; describe the classical tracker and cite RodentFlow.

## If you cite the checks in these tutorials {#use-checks}

- CalMS21 zero-shot test: the CalMS21 dataset [\[D5\]](#r-calms-data) and paper [\[P9\]](#r-calms); the MARS keypoints come from MARS [\[P10\]](#r-mars).
- Elevated-plus-maze pilot: Sturman et al. 2020 [\[P11\]](#r-sturman) and the video record [\[D6\]](#r-sturman-data); DLCAnalyzer [\[S5\]](#r-dlcanalyzer) if you used its scripts.
- PhysioNet demonstration video (cylinder v1): the dataset [\[D7\]](#r-physionet-data) and, as PhysioNet asks, the PhysioNet platform paper [\[P12\]](#r-physionet).
- Exporting to Core ML: coremltools [\[S4\]](#r-coremltools).

## Example methods paragraph {#methods}

Adapt this to what you actually did; replace everything in square brackets.

::: info

*Pose estimation.* Six body keypoints (nose, left ear, right ear, neck, body centre and tail base) were estimated in every frame with the MousePose6 model (`MousePose6_960_int8`, a YOLO26n-pose network \[S2\] with 8-bit weights) run on-device through Core ML in RodentFlow \[version\] \[S1\]. The model was trained on 6,140 frames from 36 videos of four public top-view datasets \[D1–D4\], using as labels the DeepLabCut \[P4, P5\] and JAX pose-network \[P3\] predictions released with those datasets after harmonizing them to a common keypoint set and filtering them for quality; the labels are therefore model-derived rather than human annotations. On held-out videos from the same datasets it detected 94.6 % of mice, and 96.1 % of the keypoints of detected mice lay within 0.1 body lengths of the reference labels. We checked keypoint placement on \[number\] randomly chosen frames per video from our own recordings \[and compared the derived measures with blinded manual scoring of \[number\] videos\].

:::

## Reference list {#refs}

### Software

- <span id="r-rodentstudio"></span><Badge type="info" text="S1" />Shi, Z. (2026). *RodentFlow* (Version \[used\]) \[Computer software\]. <https://github.com/seesaw-earth/RodentStudio-Support>. Source licence: AGPL-3.0.
- <span id="r-yolo26"></span><Badge type="info" text="S2" />Jocher, G., Qiu, J., Liu, M., Lyu, S., Akyon, F. C., & Kalfaoglu, M. E. (2026). Ultralytics YOLO26: Unified real-time end-to-end vision models. *arXiv*, 2606.03748. <https://doi.org/10.48550/arXiv.2606.03748>. Software: <https://github.com/ultralytics/ultralytics> (AGPL-3.0 or Ultralytics Enterprise licence).
- <span id="r-yolo11"></span><Badge type="info" text="S3" />Jocher, G., & Qiu, J. (2024). *Ultralytics YOLO11* (Version 11.0.0) \[Computer software\]. <https://github.com/ultralytics/ultralytics>. AGPL-3.0.
- <span id="r-coremltools"></span><Badge type="info" text="S4" />Apple Inc. (2025). *coremltools* (Version 9.0) \[Computer software\]. <https://github.com/apple/coremltools>. BSD-3-Clause.
- <span id="r-dlcanalyzer"></span><Badge type="info" text="S5" />ETHZ-INS. *DLCAnalyzer* \[Computer software\]. <https://github.com/ETHZ-INS/DLCAnalyzer>. GPL-3.0.

### Datasets

- <span id="r-vz2023"></span><Badge type="info" text="D1" />von Ziegler, L. M., Roessler, F. K., Sturman, O., & Bohacek, J. (2023). *Raw video and pose estimation data of top view open field mouse behavior recordings of acute and chronic stress models* \[Data set\]. Zenodo. <https://doi.org/10.5281/zenodo.8186065>. CC BY 4.0.
- <span id="r-vz2024d"></span><Badge type="info" text="D2" />von Ziegler, L., Roessler, F. K., Sturman, O., Waag, R., & Bohacek, J. (2024). *Additional raw video and pose estimation data of top view mouse behavior recordings (marble burying test, light-dark box, fear conditioning box) of acute and chronic stress models* \[Data set\]. Zenodo. <https://doi.org/10.5281/zenodo.11235068>. CC BY 4.0.
- <span id="r-jabs-ss"></span><Badge type="info" text="D3" />Kumar, V., Geuther, B., & Deats, S. (2024). *The Jackson Laboratory (JAX) - Kumar Lab Mouse Strain Survey of Behavior in the Open Field Arena (Video Dataset)* (V1) \[Data set\]. Harvard Dataverse. <https://doi.org/10.7910/DVN/SAPNJG>. UNF:6:OiPvgrf6RjsZOSxB9/nVEA== \[fileUNF\]. CC BY-NC-SA 4.0. The dataset page showed version 1.2; its suggested citation reads “V1”.
- <span id="r-jabs-bxd"></span><Badge type="info" text="D4" />Kumar, V., & Deats, S. (2025). *The Jackson Laboratory (JAX) - Kumar Lab Mouse BxD Survey of Behavior in the Open Field Arena (Video Dataset)* (V1) \[Data set\]. Harvard Dataverse. <https://doi.org/10.7910/DVN/RQYI04>. UNF:6:r9GfOhUT7LK/e1KHwwhuHQ== \[fileUNF\]. CC BY-NC-SA 4.0. Version 1.0.
- <span id="r-calms-data"></span><Badge type="info" text="D5" />Sun, J. J., Karigo, T., Anderson, D. J., Perona, P., Yue, Y., & Kennedy, A. (2021). *Caltech Mouse Social Interactions (CalMS21) Dataset* (Version 1.0) \[Data set\]. CaltechDATA. <https://doi.org/10.22002/D1.1991>. CC BY 4.0.
- <span id="r-sturman-data"></span><Badge type="info" text="D6" />von Ziegler, L., Sturman, O., & Bohacek, J. (2020). *Videos for deeplabcut, noldus ethovision X14 and TSE multi conditioning systems comparisons* \[Data set\]. Zenodo. <https://doi.org/10.5281/zenodo.3608658>. CC BY 4.0.
- <span id="r-physionet-data"></span><Badge type="info" text="D7" />Jiang, Y., Venkitaraman, S., Jung, H. R., Blackwood, S., Lee, J., Jadav, A. A., Lee, D., Kamal, A., & Landsness, E. C. (2026). *Longitudinal Cylinder Rearing Behavioral Data in a Mouse Stroke Model Across Multiple Drug Treatments* (Version 1.0.0) \[Data set\]. PhysioNet. <https://doi.org/10.13026/8bnm-6e37>. ODC-By 1.0.

### Papers

- <span id="r-vz2024"></span><Badge type="info" text="P1" />von Ziegler, L. M., Roessler, F. K., Sturman, O., Waag, R., Privitera, M., Duss, S. N., O'Connor, E. C., & Bohacek, J. (2024). Analysis of behavioral flow resolves latent phenotypes. *Nature Methods*, 21(12), 2376–2387. <https://doi.org/10.1038/s41592-024-02500-6>
- <span id="r-jabs"></span><Badge type="info" text="P2" />Choudhary, A., Geuther, B. Q., Sproule, T. J., Beane, G., Kohar, V., Trapszo, J., & Kumar, V. (2026). JAX Animal Behavior System (JABS), a genetics-informed, end-to-end advanced behavioral phenotyping platform for the laboratory mouse. *eLife*, 14, RP107259. <https://doi.org/10.7554/eLife.107259>
- <span id="r-sheppard"></span><Badge type="info" text="P3" />Sheppard, K., Gardin, J., Sabnis, G. S., Peer, A., Darrell, M., Deats, S., Geuther, B., Lutz, C. M., & Kumar, V. (2022). Stride-level analysis of mouse open field behavior using deep-learning-based pose estimation. *Cell Reports*, 38(2), 110231. <https://doi.org/10.1016/j.celrep.2021.110231>
- <span id="r-mathis"></span><Badge type="info" text="P4" />Mathis, A., Mamidanna, P., Cury, K. M., Abe, T., Murthy, V. N., Mathis, M. W., & Bethge, M. (2018). DeepLabCut: Markerless pose estimation of user-defined body parts with deep learning. *Nature Neuroscience*, 21(9), 1281–1289. <https://doi.org/10.1038/s41593-018-0209-y>
- <span id="r-nath"></span><Badge type="info" text="P5" />Nath, T., Mathis, A., Chen, A. C., Patel, A., Bethge, M., & Mathis, M. W. (2019). Using DeepLabCut for 3D markerless pose estimation across species and behaviors. *Nature Protocols*, 14(7), 2152–2176. <https://doi.org/10.1038/s41596-019-0176-0>
- <span id="r-coco"></span><Badge type="info" text="P6" />Lin, T.-Y., Maire, M., Belongie, S., Hays, J., Perona, P., Ramanan, D., Dollár, P., & Zitnick, C. L. (2014). Microsoft COCO: Common objects in context. In *Computer Vision – ECCV 2014* (Lecture Notes in Computer Science, Vol. 8693, pp. 740–755). Springer. <https://doi.org/10.1007/978-3-319-10602-1_48>
- <span id="r-geuther2019"></span><Badge type="info" text="P7" />Geuther, B. Q., Deats, S. P., Fox, K. J., Murray, S. A., Braun, R. E., White, J. K., Chesler, E. J., Lutz, C. M., & Kumar, V. (2019). Robust mouse tracking in complex environments using neural networks. *Communications Biology*, 2, 124. <https://doi.org/10.1038/s42003-019-0362-1>
- <span id="r-geuther2021"></span><Badge type="info" text="P8" />Geuther, B. Q., Peer, A., He, H., Sabnis, G., Philip, V. M., & Kumar, V. (2021). Action detection using a neural network elucidates the genetics of mouse grooming behavior. *eLife*, 10, e63207. <https://doi.org/10.7554/eLife.63207>
- <span id="r-calms"></span><Badge type="info" text="P9" />Sun, J. J., Karigo, T., Chakraborty, D., Mohanty, S. P., Wild, B., Sun, Q., Chen, C., Anderson, D. J., Perona, P., Yue, Y., & Kennedy, A. (2021). The Multi-Agent Behavior Dataset: Mouse dyadic social interactions. *Proceedings of the Neural Information Processing Systems Track on Datasets and Benchmarks*. [arXiv:2104.02710](https://arxiv.org/abs/2104.02710)
- <span id="r-mars"></span><Badge type="info" text="P10" />Segalin, C., Williams, J., Karigo, T., Hui, M., Zelikowsky, M., Sun, J. J., Perona, P., Anderson, D. J., & Kennedy, A. (2021). The Mouse Action Recognition System (MARS) software pipeline for automated analysis of social behaviors in mice. *eLife*, 10, e63720. <https://doi.org/10.7554/eLife.63720>
- <span id="r-sturman"></span><Badge type="info" text="P11" />Sturman, O., von Ziegler, L., Schläppi, C., Akyol, F., Privitera, M., Slominski, D., Grimm, C., Thieren, L., Zerbi, V., Grewe, B., & Bohacek, J. (2020). Deep learning-based behavioral analysis reaches human accuracy and is capable of outperforming commercial solutions. *Neuropsychopharmacology*, 45(11), 1942–1952. <https://doi.org/10.1038/s41386-020-0776-y>
- <span id="r-physionet"></span><Badge type="info" text="P12" />Pollard, T., Moody, B. E., Lehman, L. H., Gow, B. J., Fernandes, C., Xie, C., Johnson, A., Mark, R. G., & Heldt, T. (2026). PhysioNet as a global platform for biomedical research. *Nature Health*. <https://doi.org/10.1038/s44360-026-00096-z>

## Licence summary {#licences}

| Resource                                                     | Licence or terms                            | What it means here                                                                                                                                                                                                                                               |
|--------------------------------------------------------------|---------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ETH datasets \[D1\], \[D2\], \[D6\]                          | CC BY 4.0                                   | Reuse, including derived labels and models, is allowed with attribution, a licence link and a note of changes.                                                                                                                                                   |
| JAX datasets \[D3\], \[D4\]                                  | CC BY-NC-SA 4.0                             | Attribution, non-commercial use only, adaptations under the same licence. 3,500 MousePose6 training images come from these datasets, so treat MousePose6 as non-commercial unless JAX grants permission; see [tutorial 1](/tutorials/mousepose6#sources). |
| JAX pose model and its training data (Zenodo record 6380163) | “Other (Non-Commercial)”                    | Applies to that release itself. MousePose6 used the keypoint files shipped with \[D3\] and \[D4\], not this release; those files are themselves CC BY-NC-SA 4.0.                                                                                                 |
| CalMS21 \[D5\]                                               | CC BY 4.0                                   | Used only for an external check.                                                                                                                                                                                                                                 |
| PhysioNet dataset \[D7\]                                     | Open Data Commons Attribution (ODC-By) 1.0  | Attribution required; used only for a demonstration video.                                                                                                                                                                                                       |
| Ultralytics YOLO code and pretrained weights \[S2\], \[S3\]  | AGPL-3.0, or Ultralytics Enterprise licence | Ultralytics states that the AGPL terms extend to models trained with its code; closed-source distribution needs an Enterprise licence.                                                                                                                           |
| coremltools \[S4\]                                           | BSD-3-Clause                                | Permissive.                                                                                                                                                                                                                                                      |
| DLCAnalyzer \[S5\]                                           | GPL-3.0                                     | Used only in the evaluation pilot.                                                                                                                                                                                                                               |
| RodentFlow source \[S1\]                                   | AGPL-3.0                                    | The app's licence for store distribution is set separately; see the support site's legal page.                                                                                                                                                                   |

This table summarises licence statements; it is not legal advice.

## BibTeX {#bibtex}

All entries are in <a href="/RodentFlow/tutorials/references.bib" download>references.bib</a>. The keys are the same as below.

    @misc{shi2026rodentstudio,
      author = {Shi, Ziqing}, title = {RodentFlow}, year = {2026}, note = {Version [used]. AGPL-3.0},
      url = {https://github.com/seesaw-earth/RodentStudio-Support}}
    @article{jocher2026yolo26,
      author = {Jocher, Glenn and Qiu, Jing and Liu, Mengyu and Lyu, Shuai and Akyon, Fatih Cagatay and Kalfaoglu, Muhammet Esat},
      title = {Ultralytics {YOLO26}: Unified Real-Time End-to-End Vision Models}, journal = {arXiv preprint arXiv:2606.03748},
      year = {2026}, doi = {10.48550/arXiv.2606.03748}}
    @misc{vonziegler2023oft,
      author = {von Ziegler, Lukas M. and Roessler, Fabienne K. and Sturman, Oliver and Bohacek, Johannes},
      title = {Raw video and pose estimation data of top view open field mouse behavior recordings of acute and chronic stress models},
      publisher = {Zenodo}, year = {2023}, doi = {10.5281/zenodo.8186065}}
    …  (references.bib has all 24 entries)

## Open questions {#open}

- Permission from JAX for any commercial use of MousePose6, or a retrained model without \[D3\] and \[D4\].
- Whether the lab's cylinder recordings used for CylinderMousePoseV2 are, or will be, published.
- Training data, settings and evaluation of the bundled TST detector.
