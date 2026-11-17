# 源代码

RodentFlow 的代码、Core ML 模型、模型教程和这本手册都公开在 GitHub 上。存放 Mac 版和姿态追踪代码的仓库仍沿用项目原来的名字 **RodentStudio**。

| 仓库 | 内容 | 许可证 |
|---|---|---|
| [**seesaw-earth/RodentFlow**](https://github.com/seesaw-earth/RodentFlow) | iPhone 版 RodentFlow 1.x：质心追踪器、指标、统计、手动录入和表格导入。本网站的源文件也在这里的 [`docs/`](https://github.com/seesaw-earth/RodentFlow/tree/main/docs) 中。 | [MIT](https://github.com/seesaw-earth/RodentFlow/blob/main/LICENSE) |
| [**seesaw-earth/RodentStudio-Support › source**](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source) | Mac 版和 iPhone、iPad 版 **RodentFlow 2.1**，发布的版本打了标签 [`v2.1`](https://github.com/seesaw-earth/RodentStudio-Support/tree/v2.1/source)。包括两个 Xcode 工程（`source/macOS/RodentFlow-2.1`、`source/iOS/RodentFlow-2.1`）、`Shared/` 里的共享分析引擎（姿态流程、经典质心追踪、多格悬尾实验、统计与导出）、Core ML 模型和引擎的测试。早先的源代码（Mac 版 RodentStudio 0.7.1、iPhone 和 iPad 版 RodentPose）保留在旁边。 | AGPL-3.0（每个工程内附许可证文件） |
| [**seesaw-earth/RodentFlow-Windows**](https://github.com/seesaw-earth/RodentFlow-Windows) | [Windows 版 RodentFlow](./windows/)：编译到 Windows 上的 RodentFlow 分析引擎、C# 宿主（FFmpeg 读视频、ONNX Runtime、WinUI 3 窗口）、命令行工具、模型导出 notebook，以及 Windows App 的[隐私政策](https://github.com/seesaw-earth/RodentFlow-Windows/blob/main/PRIVACY.md)和第三方声明。 | [AGPL-3.0](https://github.com/seesaw-earth/RodentFlow-Windows/blob/main/LICENSE) |
| [**seesaw-earth/RodentStudio-CoreML-Models**](https://github.com/seesaw-earth/RodentStudio-CoreML-Models) | Core ML 模型包，权重用 Git LFS 存储。 | 见 [Core ML 模型](./models.md#licences) |
| [**seesaw-earth/RodentStudio-Tutorials**](https://github.com/seesaw-earth/RodentStudio-Tutorials) | [模型教程](./tutorials/)的原始文件、`references.bib` 和 `CITATION.cff`。 | 见仓库 |

::: warning 两种许可证
iPhone 1.x 的代码采用 MIT 许可证。Mac 版和姿态追踪代码采用 AGPL-3.0，它所运行的 Ultralytics YOLO 模型也带有 AGPL-3.0。复用代码前请查看对应的 `LICENSE`、`THIRD_PARTY_NOTICES` 和 `MODEL_PROVENANCE` 文件；模型及其训练数据的条款见[许可汇总](./tutorials/citations.md#licences)。
:::

## 开源对你意味着什么

- **能看到每个数值究竟怎么算出来。** 本手册描述了方法，代码则是最终依据，任何人都可以查看。
- **能核实隐私承诺。** 你可以在代码中确认 App 不会上传你的数据，不需要只听我们说。
- **可以按需修改。** 你可以修改 App，比如加入实验室常用的范式，并按相应许可证的条款分享你的版本。
- **公开报告和修复问题。** 欢迎提交 issue 和 pull request。

## RodentFlow 2.1：代码在哪里 {#code-2-1}

路径都相对于 `source/macOS/RodentFlow-2.1/Shared/`；iPhone、iPad 工程里有一份完全相同的副本。Windows 版 RodentFlow 编译的是同一批引擎文件，逐字节相同，位于 [`engine/Sources/RodentFlowABI/Shared`](https://github.com/seesaw-earth/RodentFlow-Windows/tree/main/engine/Sources/RodentFlowABI/Shared)。

| 内容 | 源文件 |
|---|---|
| 一帧画面如何进入姿态模型：转正、场地裁剪、灰度、letterbox | [`Vision/PoseVision.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Vision/PoseVision.swift)、[`Tracking/ArenaROI.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Tracking/ArenaROI.swift) |
| 把模型输出解码成关键点 | [`PoseEngine/PoseDecoding.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/PoseDecoding.swift) |
| 一次分析用哪个模型 | [`PoseEngine/PoseModels.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/PoseModels.swift) |
| 清理关键点轨迹：置信度、跳点、缺口、平滑 | [`PoseEngine/Kinematics.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/Kinematics.swift) |
| 两只动物的身份：逐帧追踪器和整段视频的身份校正 | [`PoseEngine/IdentityTracking.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/IdentityTracking.swift) |
| 3–10 只的群体：姿态去重和已知只数的追踪器 | [`PoseEngine/GroupTracking.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/GroupTracking.swift) |
| 群体指标和等级关系 | [`PoseEngine/AnalyzersGroup.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/AnalyzersGroup.swift)、[`PoseEngine/GroupHierarchy.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/GroupHierarchy.swift) |
| 居留者–入侵者实验的规则 | [`PoseEngine/AnalyzersAggression.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/PoseEngine/AnalyzersAggression.swift) |
| 统计检验和组间比较 | [`Groups/StatsEngine.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Groups/StatsEngine.swift)、[`Groups/GroupAnalysis.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Groups/GroupAnalysis.swift)、[`Groups/Survival.swift`](https://github.com/seesaw-earth/RodentStudio-Support/blob/v2.1/source/macOS/RodentFlow-2.1/Shared/Groups/Survival.swift) |

引擎的测试在 `tools/tests/`；`tools/run_shared_tests.sh` 把引擎和每个测试一起编译并运行，macOS 或 Linux 都可以，只需要 `swiftc`。

## iPhone 版 RodentFlow 1.x：代码在哪里

| 主题 | 手册页面 | 源文件 |
|---|---|---|
| 背景、阈值、候选打分、质心、运动指数 | [追踪原理](./principles/tracking.md) | [`NativeMouseTracker.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/NativeMouseTracker.swift) |
| 以 10 Hz 读取整段视频、检查点 | [分析一段视频](./guide/video-analysis.md) | [`FullVideoAnalyzer.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/FullVideoAnalyzer.swift) |
| 区域、进入、距离、僵直及所有视频指标 | [从位置到指标](./principles/metrics.md) | [`AssayEngine.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/AssayEngine.swift) |
| 实验范式、指标定义、阶段 | [实验范式](./assays/index.md) | [`AssayCatalog.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/AssayCatalog.swift) |
| 区域和阈值的默认值 | [实验范式](./assays/index.md) | [`ResultModels.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/ResultModels.swift)（`ZoneConfig`） |
| 手动录入、双臂老虎机与 Q-learning | [手动录入与导入表格](./guide/manual-and-import.md) | [`ManualAssays.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/ManualAssays.swift) |
| 统计检验 | [统计方法](./principles/statistics.md) | [`StatsEngine.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/StatsEngine.swift) |
| 不同设计用哪种检验 | [组间分析](./guide/groups.md) | [`GroupAnalysis.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/GroupAnalysis.swift) |
| 表格导入与列名匹配 | [手动录入与导入表格](./guide/manual-and-import.md) | [`DataImport.swift`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/DataImport.swift) |
| 中英文界面文字 | — | [`Localizable.xcstrings`](https://github.com/seesaw-earth/RodentFlow/blob/main/RodentFlow/Localizable.xcstrings) |

## 编译 iPhone 版 RodentFlow 1.x

需要一台装有 **Xcode 15 或更高版本**的 Mac，以及一台 **iOS 17 或更高版本**的 iPhone。没有第三方依赖。

```bash
git clone https://github.com/seesaw-earth/RodentFlow.git
cd RodentFlow
open RodentFlow.xcodeproj
```

在 Xcode 中：

1. 选中 **RodentFlow** target › **Signing & Capabilities**，选择你自己的 **Team**。用免费的 Apple ID 就可以在自己的 iPhone 上运行。
2. 把 **Bundle Identifier** 改成你自己的，如 `com.yourname.rodentflow`。工程中原有的标识符属于已发布的 App。
3. 连接 iPhone，选它作为运行目标，按 **Run**（⌘R）。

## 编译 Mac 版与 iPhone、iPad 姿态版 {#build}

两个版本的[源代码](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source)均以 AGPL-3.0 公开。你需要一台装有 [Xcode](https://developer.apple.com/cn/xcode/) 的 Mac，以及 [Git LFS](https://git-lfs.com/)（Core ML 模型权重用 LFS 存储）。

```bash
git clone https://github.com/seesaw-earth/RodentStudio-Support.git
cd RodentStudio-Support
git lfs install
git lfs pull                       # 拉取真实的模型权重

git checkout v2.1                   # 切到发布的版本（可选）

# Mac 版
open source/macOS/RodentFlow-2.1/macOS/RodentFlow-macOS/RodentFlow.xcodeproj
# iPhone / iPad 版
open source/iOS/RodentFlow-2.1/iOS/RodentFlow-iOS/RodentFlow.xcodeproj
```

两个工程都从 `../../Shared` 编译共享引擎，所以请保持文件夹结构不变。早先的工程（`source/macOS/RodentStudio-0.7.1`、`source/iOS/RodentStudio-Mobile-iOS`）仍留在仓库里备查。

1.  在 Xcode 中选择 target → *Signing & Capabilities* → 选择你自己的开发团队（必要时修改 Bundle ID）。
2.  Mac：选择 *My Mac*，然后 *Product › Build*（<kbd>⌘</kbd><kbd>B</kbd>）和 *Run*（<kbd>⌘</kbd><kbd>R</kbd>）。iPhone/iPad：选择你的设备（iOS 17+）——参见 [Apple：在设备上运行 App](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)。
3.  如果编译时提示模型问题，请检查 `.mlpackage` 文件夹中的 `weight.bin` 是真实文件（而不是很小的 LFS 指针文件）。[Core ML 模型仓库](https://github.com/seesaw-earth/RodentStudio-CoreML-Models)是开发者资源，普通用户无需使用。

源码检出不等于签名发布版，也不一定通过了最终测试。正式使用前请先用你自己的视频测试。

## 编译 Windows 版 RodentFlow {#build-windows}

[RodentFlow-Windows 的 README](https://github.com/seesaw-earth/RodentFlow-Windows#building) 列出了需要的工具（Swift for Windows、Visual Studio 的 C++ 组件、.NET 8 SDK 和 FFmpeg），以及编译引擎、窗口和命令行工具的命令；更详细的中文说明见仓库里的 [README_CN.md](https://github.com/seesaw-earth/RodentFlow-Windows/blob/main/README_CN.md)。ONNX 模型文件不在仓库里，[导出 notebook](https://github.com/seesaw-earth/RodentFlow-Windows/tree/main/notebooks) 可以从模型 checkpoint 生成它们。自己编译的版本不是 Microsoft Store 上签名发布的版本，使用前请先用自己的视频测试。

## 参与贡献

- **问题与提问**：[提交 issue](https://github.com/seesaw-earth/RodentFlow/issues)（Windows 版请到 [RodentFlow-Windows](https://github.com/seesaw-earth/RodentFlow-Windows/issues)），需要提供哪些信息见[支持](./support.md)。
- **代码**：先阅读 [CONTRIBUTING.md](https://github.com/seesaw-earth/RodentFlow/blob/main/CONTRIBUTING.md)，然后提交 pull request。
- **本手册**：每一页底部都有“在 GitHub 上编辑此页”的链接。手册源文件在 [`docs/`](https://github.com/seesaw-earth/RodentFlow/tree/main/docs) 文件夹中，每页都有中英文两个版本。

## 引用

如果 RodentFlow 对你发表的工作有贡献，请引用这个软件及所用版本：

```bibtex
@software{shi2026rodentflow,
  author  = {Shi, Ziqing},
  title   = {RodentFlow: On-device pose tracking and behavior analysis for rodents},
  version = {2.1},
  year    = {2026},
  url     = {https://seesaw-earth.github.io/RodentFlow/}
}
```

iPhone 版 RodentFlow 1.x 的仓库中有 [`CITATION.cff`](https://github.com/seesaw-earth/RodentFlow/blob/main/CITATION.cff) 文件，GitHub 页面上的 **Cite this repository** 按钮会给出 APA 和 BibTeX 格式。如果用了姿态模型，还应引用模型的数据和软件；每个模型该引用什么，见[如何引用](./tutorials/citations.md)。

每条结果的具体参数列在结果页的 **方法** 中，检验描述在统计卡片上，这两部分都应写进论文的方法部分。

## 许可证

- **iPhone 版 RodentFlow 1.x**（[RodentFlow](https://github.com/seesaw-earth/RodentFlow)）：MIT 许可证，© 2026 Ziqing Shi。在保留版权声明和许可声明的前提下，你可以使用、复制、修改和分发本软件，包括用于商业用途。完整条款见 [`LICENSE`](https://github.com/seesaw-earth/RodentFlow/blob/main/LICENSE)。
- **Mac 版与姿态追踪代码**（[RodentStudio-Support › source](https://github.com/seesaw-earth/RodentStudio-Support/tree/main/source)）：AGPL-3.0。每个 Xcode 工程都附有许可证全文。
- **Windows 版 RodentFlow**（[RodentFlow-Windows](https://github.com/seesaw-earth/RodentFlow-Windows)）：AGPL-3.0-only，© 2026 Ziqing Shi。它用到的第三方组件（FFmpeg、带 DirectML 的 ONNX Runtime、Windows App SDK、Win2D）列在 [`THIRD_PARTY_NOTICES.md`](https://github.com/seesaw-earth/RodentFlow-Windows/blob/main/THIRD_PARTY_NOTICES.md) 中。
- **模型和训练数据**有各自的条款，见 [Core ML 模型](./models.md#licences)。

本软件不提供任何担保。另见[法律与声明](./legal.md)。
