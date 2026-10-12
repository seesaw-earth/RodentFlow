# 开源与构建

RodentFlow 以 **[MIT 许可证](https://github.com/seesaw-earth/RodentFlow/blob/main/LICENSE)开源**。完整的 App（追踪器、指标、统计、导入和界面）和这本手册都在同一个公开仓库里：

<p class="rf-repo"><a href="https://github.com/seesaw-earth/RodentFlow">github.com/seesaw-earth/RodentFlow</a></p>

## 开源对你意味着什么

- **能看到每个数值究竟怎么算出来。** 本手册描述了方法，代码则是最终依据，任何人都可以查看。
- **能核实隐私承诺。** App 不包含任何联网代码，这一点不需要只听我们说。
- **可以按需修改。** 你可以修改 App，比如加入实验室常用的范式，并按 MIT 许可证的条款分享你的版本。
- **公开报告和修复问题。** 欢迎提交 issue 和 pull request。

## 代码在哪里

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

## 从源码构建

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

## 参与贡献

- **问题与提问**：[提交 issue](https://github.com/seesaw-earth/RodentFlow/issues)，需要提供哪些信息见[支持](./support.md)。
- **代码**：先阅读 [CONTRIBUTING.md](https://github.com/seesaw-earth/RodentFlow/blob/main/CONTRIBUTING.md)，然后提交 pull request。
- **本手册**：每一页底部都有“在 GitHub 上编辑此页”的链接。手册源文件在 [`docs/`](https://github.com/seesaw-earth/RodentFlow/tree/main/docs) 文件夹中，每页都有中英文两个版本。

## 引用

如果 RodentFlow 对你发表的工作有贡献，请引用这个软件及所用版本。仓库中有 [`CITATION.cff`](https://github.com/seesaw-earth/RodentFlow/blob/main/CITATION.cff) 文件，GitHub 页面上的 **Cite this repository** 按钮会给出 APA 和 BibTeX 格式。例如：

> Shi, Z. (2026). *RodentFlow: rodent behavior tracking and analysis on iPhone* (Version 1.3) [Computer software]. https://github.com/seesaw-earth/RodentFlow

每条结果的具体参数列在结果页的 **方法** 中，检验描述在组间分析的统计卡片上，这两部分都应写进论文的方法部分。

## 许可证

MIT 许可证，© 2026 Ziqing Shi。在保留版权声明和许可声明的前提下，你可以使用、复制、修改和分发本软件，包括用于商业用途。本软件不提供任何担保。完整条款见 [`LICENSE`](https://github.com/seesaw-earth/RodentFlow/blob/main/LICENSE)。
