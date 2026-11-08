---
title: "数据存放位置与备份"
description: "RodentFlow 在 iPhone、iPad 和 Mac 上把视频、分析和工作区存在哪里，以及如何备份。"
---

# 数据存放位置与备份

RodentFlow 没有账号，也没有服务器。所有数据都留在你的设备和你选择的文件夹里。见[隐私政策](../privacy.md)。

## iPhone 与 iPad {#ios}

- **姿态分析**是“文件 › 我的 iPhone/iPad › RodentFlow › Sessions”下的文件夹，每个都包含设置（`session.json`）、轨迹（`pose.mpt`）、标定帧和视频副本。
- **质心法结果**在“RodentFlow › Results”下，运行文件在“RodentFlow › Experiments”下，与 RodentFlow 1.x 完全相同：用 1.x 做的结果升级后照常打开。
- **多格悬尾**录像以存档形式保存，带有各项指标，格式与 Mac 相同。
- 设备备份（iCloud 或电脑）会按你的备份设置包含 App 数据。重要的研究还请导出结果，或打开 [Mac 同步](./sync.md)。

## Mac {#mac}

- **你的视频**留在原处，只读不改。移动或改名后，用**定位视频**重新关联。
- **工作区**（项目、任务、实验、标定、复核结论）和**追踪运行文件**在 App 的容器里：  
  `~/Library/Containers/com.ziqingshi.rodentflow/Data/Library/Application Support/RodentDesktopNative/`  
  （`workspace.json` 和 `Runs` 文件夹）。在“访达”中用“前往 › 前往文件夹…”（<kbd>⇧</kbd><kbd>⌘</kbd><kbd>G</kbd>）粘贴这个路径。
- 长录像在追踪过程中就写入磁盘，每分钟视频一个文件，完成后组装成与手机相同的 `pose.mpt`。
- 从手机导入的分析会复制到 Mac 自己的存储里。
- 自动合并任务之前，会在工作区旁边写一份备份。

## 备份 {#backup}

请备份视频文件夹、上面的容器文件夹和导出文件夹；[时间机器](https://support.apple.com/zh-cn/104984)可以一次备份这三者。手动复制工作区之前请先退出 RodentFlow。在 App 里移除视频或删除任务不会删除源视频或追踪文件夹，所以不会误删数据。
