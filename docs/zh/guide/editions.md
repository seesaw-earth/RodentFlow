---
title: "iPhone、iPad、Mac 与 Windows"
description: "RodentFlow 在 iPhone、iPad、Mac 和 Windows 上分别能做什么、需要什么系统，以及如何获取。"
---

# iPhone、iPad、Mac 与 Windows

RodentFlow 在 iPhone、iPad 和 Mac 上是同一个 App，在 Windows 上是另一个 App。它们都运行同一套分析代码。在 Apple 设备上，同一段视频、同样的标定和设置，在每台设备上得到同样的数值。Windows 版用 ONNX 文件而不是 Core ML 包运行模型，它的结果还没有和 Mac 版比较过（见 [Windows 版 RodentFlow](../windows/index.md#mac)）。各设备的区别在于组织工作的方式。

<div class="rf-editions">

|  | iPhone 与 iPad | Mac | Windows |
|---|---|---|---|
| **适合** | 在实验台边分析视频、实验后马上检查录像、教学 | 整个研究：很多动物、分组、多次实验、长录像 | 在 Windows 电脑上做整个研究 |
| **方法** | 姿态（单鼠和双鼠）、质心法、多格悬尾、手动录入和导入表格 | 姿态（单鼠和双鼠）、质心法、多格悬尾 | 姿态（单鼠和双鼠） |
| **组织方式** | 每次分析带动物编号、组别、性别、阶段、天和次 | 项目 → 任务 → 组 → 动物 → 实验 | 任务 → 组 → 动物 → 实验 |
| **组间统计** | 内置（“组间”标签页） | 内置（组间比较） | 内置（组间比较） |
| **导出** | 指标、逐帧数据、DeepLabCut 格式关键点、行为片段、图、统计、方法学文字 | 同上，可一次导出整个任务，另有标注 MP4 和质控文件 | 图（PNG、PDF、SVG、CSV）、统计、每只动物一行的数据、方法学文字、标注 MP4 |
| **系统要求** | iOS / iPadOS 17 或更高 | macOS 14 Sonoma 或更高；Apple 芯片运行模型最快 | Windows 10 1809 或更高版本，或 Windows 11，64 位；支持 DirectX 12 的显卡在更快时会被使用 |

</div>

在 Apple 设备上两者可以一起用：iPhone 或 iPad 上完成的分析可以写进你选的文件夹（例如 iCloud 云盘），Mac 自动导入，并检查 Mac 重新计算的数值是否与手机一致。见[手机到 Mac 同步](../reference/sync.md)。

## 获取 RodentFlow {#get-app}

iPhone、iPad 和 Mac 版 RodentFlow 在 [App Store](https://apps.apple.com/app/id6818278240) 上；Windows 版在 [Microsoft Store](https://apps.microsoft.com/detail/9n4hx4cvmzf8) 上。请不要相信其他网站的下载链接。分析视频不需要 Python、GitHub 账号或网络连接：模型都内置在 App 里。

## 查看设备信息 {#check-device}

- [查看 Mac 的 macOS 版本](https://support.apple.com/zh-cn/109033)，以及是否为 [Apple 芯片](https://support.apple.com/zh-cn/116943)。
- [查看 iPhone 或 iPad 的软件版本](https://support.apple.com/zh-cn/109065)。
- [查看电脑运行的 Windows 版本](https://support.microsoft.com/zh-cn/windows/which-version-of-windows-operating-system-am-i-running-628bec99-476a-2c13-5296-9dd081cdd808)。

## 语言 {#language}

App 有英文和简体中文界面，跟随设备语言；在 iPhone 和 iPad 上可以在“设置”App 里单独选择 RodentFlow 的语言，在 Windows 上用窗口里的语言菜单。数据和导出文件始终以英文保存，不受界面语言影响。
