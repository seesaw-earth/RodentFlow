# Core ML 模型

姿态流程用 Apple 的 Core ML 在 Mac、iPhone 或 iPad 本机运行小型神经网络。模型已经内置在 App 中，分析视频时不需要另外下载。公开它们，是为了让你可以查看、在自己的项目里复用，以及引用。质心追踪完全不使用模型。

[教程](./tutorials/)讲解了每个模型的数据和标签从哪里来、如何训练和测试，以及 App 如何运行它。

## 模型一览

| 模型 | 识别内容 | 使用它的流程 | 模型包 |
|---|---|---|---|
| **[MousePose6_<wbr>960_<wbr>int8](./tutorials/mousepose6.md)** | 俯视画面中每帧一只小鼠；六个关键点：鼻尖、左耳、右耳、颈部、身体中心、尾根 | Mac、iPhone 和 iPad 上的 RodentPose 流程 | YOLO26n-pose · 960 px · 8 位权重 · 2.76 MiB |
| **[CylinderMousePoseV2](./tutorials/cylinder-v2.md)** | 七个关键点：四爪、尾根、鼻尖、嘴 | Mac 上的 RodentLimb 流程：圆筒实验、单鼠悬尾、步态 | YOLO26s-pose · 640 px · FP32 · 37.67 MiB |
| **[MouseDetector](./tutorials/tst-detector.md)** | 框出每只小鼠 | Mac 上的多格悬尾实验 | YOLO11n 检测 · 320 px · FP16 · 5.14 MiB |
| **JABS_<wbr>YOLO26s_<wbr>MousePose12_<wbr>640_<wbr>FP16** | 十二个关键点（JABS 关键点方案） | 已发布在模型仓库中；不在审阅过的 Mac 候选版 0.6.3 里 | YOLO26s-pose · 640 px · FP16 · 19.46 MiB |

App 如何加载模型包、送入图像并解码输出，见 [4 · App 里的 Core ML](./tutorials/app-integration.md)。

## 下载

模型包在 [**seesaw-earth/RodentStudio-CoreML-Models**](https://github.com/seesaw-earth/RodentStudio-CoreML-Models) 中。权重用 [Git LFS](https://git-lfs.com/) 存储，克隆前请先安装：

```bash
git lfs install
git clone https://github.com/seesaw-earth/RodentStudio-CoreML-Models.git
```

把 `.mlpackage` 复制进 Xcode 工程时，请保持整个文件夹完整。如果某个 `weight.bin` 只有几百字节，那是 LFS 指针文件：运行 `git lfs pull`。

MouseDetector 模型包随 Mac 版源代码一起发布，位于 [`source/macOS/…/TSTMulti/Models`](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source)。App 源代码中也包含 MousePose6 和 CylinderMousePoseV2，所以编译 App 不需要模型仓库。

## 校验值

每个 `weight.bin` 的 SHA-256，可用来确认你拿到的权重与 App 中的相同：

| 模型 | `weight.bin` 的 SHA-256 |
|---|---|
| MousePose6_960_int8 | `dc8c871e36ebe623d4051cb3afbc043d25b3eaa1ebcc312c518d9809a084d7e3` |
| CylinderMousePoseV2 | `1cb12c30ea2ff907e57d6f756be95e1f25fc667a71fa8cf07d1b9448a202840c` |
| MouseDetector | `0151d83baec0ad13b63e61ade80e822fabd01cb82eb6d728816893667c0c968b` |
| JABS_YOLO26s_MousePose12_640_FP16 | `3205b4236cba83cd17130de8496349b6fc7b8f2e9a5994c10103e69843df0047` |

## 许可与复用 {#licences}

- 模型权重经项目作者授权发布。这一声明并不核实上游预训练权重或训练数据的许可。
- 这些模型用 Ultralytics YOLO 训练和导出。除非使用 Ultralytics 企业许可，Ultralytics YOLO 采用 AGPL-3.0；导出时写入模型包的许可字段为 AGPL-3.0。
- MousePose6 的四个训练数据集中，有两个（Harvard Dataverse 上的 JAX 数据集）为 CC BY-NC-SA 4.0，限制商业使用；两个 ETH Zurich 数据集为 CC BY 4.0。
- 模型放在公开仓库里，并不等于获得了商业再分发的权利。

[许可汇总](./tutorials/citations.md#licences)列出了每个数据集、论文和软件包的许可；[如何引用](./tutorials/citations.md)说明了使用每个模型时该引用什么。

::: warning 请在自己的视频上验证
教程中的测试分数衡量的是与各测试集参照标签的一致程度，不等于验证了行为指标。在研究中依赖某个模型之前，请在你自己的录像上与人工评分比较。
:::
