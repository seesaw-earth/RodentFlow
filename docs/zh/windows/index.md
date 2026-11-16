---
title: "Windows 版 RodentFlow"
description: "在 Windows 电脑上使用 RodentFlow：从 Microsoft Store 安装、系统要求、功能、和 Mac 版的关系，以及数据存放位置。"
---

# Windows 版 RodentFlow

Windows 版 RodentFlow 把姿态追踪和行为分析带到 Windows 电脑上。它和 Mac 版一样面向完整的研究：任务、分组、小鼠和实验，视频排队分析，复核、结果和组间统计。先看 [Windows 快速上手](./quick-start.md)。

<div class="rf-cards">
  <a href="https://apps.microsoft.com/detail/9n4hx4cvmzf8"><strong>Microsoft Store</strong><span>获取 Windows 版 RodentFlow。</span></a>
  <a href="./quick-start.html"><strong>快速上手</strong><span>从新建任务到导出结果。</span></a>
  <a href="https://github.com/seesaw-earth/RodentFlow-Windows"><strong>源代码</strong><span>GitHub 上的 Windows 版，AGPL-3.0。</span></a>
</div>

## 安装 {#install}

1. 打开 [Microsoft Store 中的 RodentFlow 页面](https://apps.microsoft.com/detail/9n4hx4cvmzf8)，点 **获取**（或 **安装**）。App 免费。
2. 从开始菜单打开 **RodentFlow**。

这样就可以了：姿态模型和视频读取组件（FFmpeg）都已包含在 App 里。分析视频不需要 Python、GitHub 账号、另外下载任何东西，也不需要联网。Microsoft Store 会自动更新 App。请不要相信其他网站的下载链接。

## 系统要求 {#requirements}

| 项目 | 要求 |
|---|---|
| **系统** | Windows 10 1809 或更高版本，或 Windows 11；64 位（x64） |
| **显卡** | 支持 DirectX 12 的显卡在更快时会被使用；没有显卡时由处理器运行模型 |
| **视频** | MP4、MOV 等常见视频文件；逐帧读取每一帧自己的时间戳，所以可变帧率也能正确处理 |
| **语言** | 英文和简体中文。数据和导出文件始终是英文 |

查看你的 Windows 版本，见 Microsoft 的[我运行的是哪个版本的 Windows 操作系统？](https://support.microsoft.com/zh-cn/windows/which-version-of-windows-operating-system-am-i-running-628bec99-476a-2c13-5296-9dd081cdd808)

## 能做什么 {#features}

- **工作区**和 Mac 一样：任务 → 组 → 小鼠 → 实验。一次添加多个视频，填写每次实验的信息，把所有可以分析的实验排队分析。
- **所有姿态范式都能标定**（27 个）：在一帧画面上拖动场地（矩形、圆形、十字、Y 或 T 迷宫）和该范式的标记（杯子、物体、平台、目标洞、庇护所、食物、珠子网格……）。区域按分析实际计数的方式画出来，旁边是该范式的参数。
- **结果页**的卡片、图和 Methods 文字与 Mac 版相同。每张图都可以导出为 PNG（300 或 600 dpi）、矢量 PDF、SVG 或 CSV。
- **复核**：视频上画出骨架，时间轴列出需要检查的时刻，可以从某一帧起或在一段范围内交换两只小鼠的身份，新奇抑制摄食可以确认首次进食。任何一次实验都可以生成画有关键点的复核视频。
- **配对阶段**（社交回避比值、位置偏好分数、step-down 比值）和**埋珠**（逐个读取视频中的珠子）。
- **组间比较**：统计方法、出版级图和每只小鼠一行的 CSV 表与其他平台相同。
- **显卡或处理器**：每个模型第一次运行时，RodentFlow 在两者上各测一次，用更快的那个；也可以自己指定。

## 和 Mac 版的关系 {#mac}

Windows 版和 iPhone、iPad、Mac 版由**同一套分析代码**编译而成：关键点解码、身份追踪、区域、每个范式的规则、统计和图。不同的是下面这一层：

| | Mac、iPhone 和 iPad | Windows |
|---|---|---|
| 读取视频 | AVFoundation | FFmpeg，读取每一帧自己的时间戳 |
| 运行模型 | Core ML 包（8 位权重） | 同一批模型 checkpoint 导出的 32 位 ONNX，用 ONNX Runtime 和 DirectML 运行 |
| 界面 | SwiftUI | WinUI 3 |

因为模型文件和视频读取方式不同，同一段视频在 Mac 和 Windows 上的关键点可能略有差别。**Windows 版的结果还没有在同一批视频上和 Mac 版做过比较。** 在比较结果发布到这里之前，请像对待任何新设置一样，先在**复核**里检查一项研究的前几次实验，再使用这些数字。

Windows 版暂时还没有：经典质心追踪、多格悬尾、手动录入和导入表格、手机同步。需要这些功能请用 [iPhone、iPad 或 Mac](../guide/editions.md)。

## 数据存放在哪里 {#data}

- **你的视频**留在原处，只读取不修改。移动了视频的话，在该实验里用 **重新指定视频…**。
- **工作区**（任务、实验、你填写的信息、标定）和设置保存在 Windows 用户目录的 `%LOCALAPPDATA%\RodentFlow` 中（Microsoft Store 版中，Windows 可能把它们放在 `%LOCALAPPDATA%\Packages` 下 App 自己的文件夹里）。
- **追踪记录和结果**保存在 `文档\RodentFlow`，每个任务、每次实验一个文件夹。**打开结果文件夹** 会在文件资源管理器中显示该实验的文件夹。
- 在 App 中移除实验或任务，不会删除视频和结果文件夹。

请备份 `文档\RodentFlow` 和你的导出文件夹，例如用 Windows 备份或 OneDrive。另见[隐私政策](../privacy.md)。

## 源代码 {#source}

Windows 版 RodentFlow 以 GNU Affero 通用公共许可证 v3.0 开源：[seesaw-earth/RodentFlow-Windows](https://github.com/seesaw-earth/RodentFlow-Windows)。关于 Windows 版的问题请提交到它的 [issue 页面](https://github.com/seesaw-earth/RodentFlow-Windows/issues)，见[支持](../support.md)。
