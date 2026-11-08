---
title: "iPhone、iPad 与 Mac"
description: "RodentFlow 2.1 在 iPhone、iPad 和 Mac 上分别能做什么、需要什么系统，以及如何获取。"
---

# iPhone、iPad 与 Mac

RodentFlow 是同一个 App，用于 iPhone、iPad 和 Mac。三者运行同一套分析代码：同一段视频、同样的标定和设置，在每台设备上得到同样的数值。区别在于组织工作的方式。

|  | iPhone 与 iPad | Mac |
|---|---|---|
| **适合** | 在实验台边分析视频、实验后马上检查录像、教学 | 整个研究：很多动物、分组、多次实验、长录像 |
| **方法** | 姿态（单鼠和双鼠）、质心法、多格悬尾、手动录入和导入表格 | 姿态（单鼠和双鼠）、质心法、多格悬尾 |
| **组织方式** | 每次分析带动物编号、组别、性别、阶段、天和次 | 项目 → 任务 → 组 → 动物 → 实验 |
| **组间统计** | 内置（“组间”标签页） | 内置（组间比较） |
| **导出** | 指标、逐帧数据、DeepLabCut 格式关键点、行为片段、图、统计、方法学文字 | 同上，可一次导出整个任务，另有标注 MP4 和质控文件 |
| **系统要求** | iOS / iPadOS 17 或更高 | macOS 14 Sonoma 或更高；Apple 芯片运行模型最快 |

两者可以一起用：iPhone 或 iPad 上完成的分析可以写进你选的文件夹（例如 iCloud 云盘），Mac 自动导入，并检查 Mac 重新计算的数值是否与手机一致。见[手机到 Mac 同步](../reference/sync.md)。

## 获取 RodentFlow {#get-app}

RodentFlow 在 [App Store](https://apps.apple.com/app/id6818278240) 上。请不要相信其他网站的下载链接。分析视频不需要 Python、GitHub 账号或网络连接：模型都内置在 App 里。

## 查看设备信息 {#check-device}

- [查看 Mac 的 macOS 版本](https://support.apple.com/zh-cn/109033)，以及是否为 [Apple 芯片](https://support.apple.com/zh-cn/116943)。
- [查看 iPhone 或 iPad 的软件版本](https://support.apple.com/zh-cn/109065)。

## 语言 {#language}

App 有英文和简体中文界面，跟随设备语言；在 iPhone 和 iPad 上可以在“设置”App 里单独选择 RodentFlow 的语言。数据和导出文件始终以英文保存，不受界面语言影响。
