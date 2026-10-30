# 我该用哪个版本？

::: info
本页根据 Mac 版 RodentFlow 0.7.1 和 iPhone、iPad 版 RodentFlow 1.0（姿态版，原名 RodentStudio）编写。
:::

RodentFlow 在你自己的设备上分析**你自己拍摄（或有权使用）的实验啮齿类视频**。无需注册账号，也不会上传：视频、追踪数据和结果都留在你的 Mac、iPhone 或 iPad 上（详见[隐私政策](/zh/privacy)）。它有两个版本，科研计算逻辑相同，但面向的工作场景不同。

|          | RodentFlow（Mac 版）                                                            | RodentFlow Mobile（iPhone / iPad）                                |
|----------|---------------------------------------------------------------------------------|-------------------------------------------------------------------|
| 适合     | 完整课题：多只动物、多个分组、多次实验、统计和批量导出                          | 单段视频快速分析、在实验台旁检查录像、教学演示                    |
| 系统要求 | macOS 14 Sonoma 或更新（推荐 Apple 芯片）                                       | iOS / iPadOS 17 或更新                                            |
| 分析模块 | RodentPose（16 个范式）、RodentLimb（3 个）、RodentFlow（10 个）、多格 TST      | RodentPose（16 个范式）                                           |
| 数据组织 | 项目 → 任务 → 分组 → 小鼠 → 实验                                                | 每段视频一次分析，含编号、组别、阶段、天、试次                    |
| 组间统计 | 内置“组间比较”（t 检验、方差分析、混合方差分析、非参数检验）                    | 导出汇总表后在其他软件中分析                                      |
| 导出     | 实验 / 分组 / 任务级表格、图表、方法说明、DeepLabCut 格式逐帧数据、TST 专用文件 | 指标汇总 CSV、逐帧分析 CSV、原始关键点 CSV、完整报告 JSON、汇总表 |

## 查看你的设备 {#check-device}

- 我的 Mac 是哪个 macOS？[Apple：查看你的 Mac 正在使用哪个 macOS](https://support.apple.com/zh-cn/109033)
- Apple 芯片还是 Intel？[Apple：搭载 Apple 芯片的 Mac 电脑](https://support.apple.com/zh-cn/116943)。两者都在支持范围内；Apple 芯片运行 Core ML 模型快得多，长视频会更快完成。
- 我的 iPhone / iPad 是哪个系统版本？[Apple：查找 iPhone 或 iPad 上的软件版本](https://support.apple.com/zh-cn/109065)

## 获取 App {#get-app}

RodentFlow 已在 [App Store](https://apps.apple.com/app/id6818278240) 上架。Mac 版的公开测试版可通过 [TestFlight](https://testflight.apple.com/join/dU24jGY7) 安装。请勿相信其他网站提供的下载链接。希望自行编译的研究者可参阅[从源码编译](/zh/source#build)。分析视频**不需要** Python、GitHub 账号或联网——模型已经内置在 App 中。
