# Core ML 模型

姿态流程用 Apple 的 Core ML 在 Mac、iPhone 或 iPad 本机运行小型神经网络。模型已经内置在 App 中，分析视频时不需要另外下载。在这里公开说明它们，是为了让你可以查看、在自己的项目里复用，以及引用。质心追踪完全不使用模型。

[教程](./tutorials/)讲解了每个模型的数据和标签从哪里来、如何训练和测试，以及 App 如何运行它。

## RodentFlow 中的模型 {#models}

| 模型 | 识别内容 | 何时使用 | 模型包 |
|---|---|---|---|
| **[MousePose6_<wbr>960_<wbr>int8](./tutorials/mousepose6.md)** | 俯视画面中每帧一只小鼠；六个关键点：鼻尖、左耳、右耳、颈部、身体中心、尾根 | 单鼠姿态流程，*小鼠毛色：深色*（默认） | YOLO26n-pose · 960 px · 8 位权重 · 2.76 MiB |
| **[WhiteMousePose6_<wbr>960_<wbr>int8](./tutorials/white-mouse.md)** | 一只白鼠；同样的六个关键点 | 单鼠姿态流程，*小鼠毛色：白色* | YOLO26n-pose · 960 px · 8 位权重 · 2.76 MiB |
| **[MousePose6Dyad_<wbr>960_<wbr>int8](./blog/training-on-existing-tracks.md#dyad)** | 每帧两只小鼠；每只同样的六个关键点 | 双鼠社交互动和 resident–intruder，*小鼠毛色：两只都是深色*（默认） | YOLO26s-pose · 960 px · 8 位权重 · 9.66 MiB |
| **[MousePose6DyadBW_<wbr>960_<wbr>int8](./tutorials/dyad-bw.md)** | 两只小鼠，一黑一白；每只同样的六个关键点 | 同样的双鼠流程，*小鼠毛色：一黑一白* | YOLO26s-pose · 960 px · 8 位权重 · 9.66 MiB |
| **[MouseDetector](./tutorials/tst-detector.md)** | 框出每只小鼠 | 多格悬尾实验 | YOLO11n 检测 · 320 px · FP16 · 5.14 MiB |

四个姿态模型的输入（960 × 960 图像）、输出格式（端到端输出头给出的 1 × 300 × 24 张量）和六个关键点及其顺序都相同。App 对它们的输出用同样的方式追踪、清洗和分析；只换模型文件。

App 如何加载模型包、送入图像并解码输出，见 [4 · App 里的 Core ML](./tutorials/app-integration.md)。

## 每段视频用哪个模型 {#coat}

任务决定追踪几只动物；*小鼠毛色*设置决定用哪个模型：

| 动物数（由任务决定） | 小鼠毛色 | 模型 |
|---|---|---|
| 1 | 深色（默认） | MousePose6 |
| 1 | 白色 | WhiteMousePose6 |
| 2 | 两只都是深色（默认） | MousePose6Dyad |
| 2 | 一黑一白 | MousePose6DyadBW |

- 在 iPhone 和 iPad 上，选好范式后选择毛色，或在“信息”页的识别设置中修改；在 Mac 上，在每段视频标定的识别设置中选择。改毛色需要重新识别。
- **不会悄悄换模型**。某段视频需要的模型缺失或加载失败时，这段视频不会被识别，App 会说明原因。
- Methods 文字、单次 JSON 和组间长格式表（`model` 列）写明每段视频用的模型。各组用了不同模型时，组间页会提示：模型之间的差别会和组间差别混在一起。
- 没有记录毛色的数据（较早版本保存的）一律按*深色*读入，也就是它们当时用的模型。

::: warning 双鼠数据中的身体中心
MousePose6、WhiteMousePose6 和 MousePose6DyadBW 把身体中心放在颈部和尾根的中点。MousePose6Dyad 学到的是另一种定义，约在鼻尖后 0.4 个体长。因此基于身体中心的指标在 MousePose6Dyad 与其他三个模型之间不能互换；见[教程 6](./tutorials/dyad-bw.md#keypoints)。
:::

## 不再属于 RodentFlow 的模型 {#former}

- **[CylinderMousePoseV2](./tutorials/cylinder-v2.md)**（四爪、鼻尖、嘴和尾根）曾用于早期 Mac App 的肢体流程。RodentFlow 2.0 去掉了这些流程；肢体模型和流程现在属于 **RodentLimb**，其网站记录了[目前的肢体模型](https://seesaw-earth.github.io/RodentLimb/zh/models/)。这篇教程保留在这里，作为这个模型如何制作的记录。
- **JABS_YOLO26s_MousePose12_640_FP16**（十二个关键点，JABS 关键点方案）发布在模型仓库中，但从未内置在 App 中。

## 下载 {#download}

MousePose6、CylinderMousePoseV2 和 JABS 模型在 [**seesaw-earth/RodentStudio-CoreML-Models**](https://github.com/seesaw-earth/RodentStudio-CoreML-Models) 中。权重用 [Git LFS](https://git-lfs.com/) 存储，克隆前请先安装：

```bash
git lfs install
git clone https://github.com/seesaw-earth/RodentStudio-CoreML-Models.git
```

把 `.mlpackage` 复制进 Xcode 工程时请保持整个文件夹完整。如果某个 `weight.bin` 只有几百字节，它是 LFS 指针文件：运行 `git lfs pull`。

WhiteMousePose6、MousePose6Dyad 和 MousePose6DyadBW 内置在 App 中。MouseDetector 模型包随 Mac 源码发布，位于 [`source/macOS/…/TSTMulti/Models`](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source)。

## 校验值 {#checksums}

每个 `weight.bin` 的 SHA-256，用来确认你拿到的权重与 App 中的相同：

| 模型 | `weight.bin` 的 SHA-256 |
|---|---|
| MousePose6_960_int8 | `dc8c871e36ebe623d4051cb3afbc043d25b3eaa1ebcc312c518d9809a084d7e3` |
| WhiteMousePose6_960_int8 | `b00dbda7e52a8d5b911a9839031d0ac9ac054fec90684e70d5f2ff94e2aa86ab` |
| MousePose6Dyad_960_int8 | `adc22fd3546cda6ab9a44ba99712d9ce1c30aa2ee405dc3d5363aad82093a228` |
| MousePose6DyadBW_960_int8（第 2 版） | `89aff42ec2f7faee8733d9d91e83cb2be25ef9241ec0ef6284820f6db7875ec3` |
| MouseDetector | `0151d83baec0ad13b63e61ade80e822fabd01cb82eb6d728816893667c0c968b` |
| CylinderMousePoseV2 | `1cb12c30ea2ff907e57d6f756be95e1f25fc667a71fa8cf07d1b9448a202840c` |
| JABS_YOLO26s_MousePose12_640_FP16 | `3205b4236cba83cd17130de8496349b6fc7b8f2e9a5994c10103e69843df0047` |

## 许可与复用 {#licences}

- 模型权重经项目作者授权公开。这一声明并不核实上游预训练权重或训练数据的许可。
- 模型包用 Ultralytics YOLO 训练和导出；除非使用 Ultralytics 企业许可，其许可为 AGPL-3.0，导出时写入模型包的许可字段为 AGPL-3.0。
- MousePose6 的四个训练数据集中，两个（Harvard Dataverse 上的 JAX 数据集）为 CC BY-NC-SA 4.0，限制商业使用；两个 ETH Zurich 数据集为 CC BY 4.0。
- WhiteMousePose6、MousePose6Dyad 和 MousePose6DyadBW 用 DooM 数据集（EMBER-DANDI dandiset 000564）的视频和轨迹训练。它的使用条款见 [EMBER 记录](https://dandi.emberarchive.org/dandiset/000564)；再分发或商业使用之前请查看。
- 模型放在公开仓库中，本身并不意味着可以商业再分发。

[许可汇总表](./tutorials/citations.md#licences)列出了每个数据集、论文和软件包的许可，[如何引用](./tutorials/citations.md)说明了使用各模型时应引用什么。

::: warning 请在自己的视频上验证
教程中的测试分数描述的是与各测试集参照标签（大多是其他追踪器的输出）的一致程度，并不是对行为指标的验证。在研究中依赖某个模型之前，请在自己的录像上把它的输出与人工评分比较。
:::
