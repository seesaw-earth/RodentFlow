---
title: "文件与格式"
description: "RodentFlow 读取和写出的文件：视频、姿态轨迹、实验设置、同步包、悬尾存档以及各种导出。"
---

# 文件与格式

## RodentFlow 读取什么 {#input}

- **视频**：MP4 和 MOV（H.264 或 HEVC），任意帧率和分辨率。时间戳从文件读取，可变帧率也能正确处理。
- **表格**（iPhone 和 iPad）：手动结果用 CSV 或 TSV；见[手动录入与导入表格](../guide/manual-and-import.md)。
- **以前的数据**：RodentFlow 1.x 的结果和运行文件、2.0 之前的姿态分析，以及早期 Mac 版本的工作区和运行文件都可以直接打开。

## RodentFlow 保存什么 {#stored}

| 内容 | 格式 |
|---|---|
| 姿态实验 | `session.json`：动物信息、标定、设置、模型、复核结论 |
| 姿态轨迹 | `pose.mpt`（手机与 Mac 相同；双鼠文件含身份信息） |
| Mac 上追踪中的长录像 | `pose_stream.json`，加上每 60 秒视频一个 `segment_*.csv`，完成后组装成 `pose.mpt` |
| 手动标记 | 实验文件夹中的 `manual_annotations.json` |
| 质心法 | 与 RodentFlow 1.x 相同的结果文件和运行文件夹 |
| 多格悬尾 | `record.json`、`measures.json` 和 CSV（手机与 Mac 相同） |
| 同步包 | `RodentFlow Sync/<设备>/<id>.rfsession/`，含 `manifest.json`（文件大小和校验值）和数据文件 |

## RodentFlow 导出什么 {#exports}

所有导出都使用英文列名和键名，不受界面语言影响。

| 导出 | 文件 |
|---|---|
| 实验指标 | 每次实验一行：指标、动物信息、设置、模型 |
| 逐帧数据 | 每帧一行的 CSV：时间、帧号、关键点（cm）、速度、头朝向、身体朝向、区域、行为和质量标记（`outside_arena`、`outside_arena_dist_cm`）、`recording_start` |
| DeepLabCut 格式 | `*_DLC.csv`，表头行为 `scorer`、`individuals`（双鼠）、`bodyparts`、`coords` |
| 行为片段 | `*_segments.csv`、`*_events_boris.csv`、`*_segments_metadata.json`，有手动标记时还有 `*_agreement.csv` |
| 实验报告 | 完整 JSON：设置、标定、指标和事件 |
| 图 | PDF、PNG（300 / 600 dpi），Mac 另有 SVG |
| 组间比较 | `figure.*`、`figure_source_data.csv`、`figure_legend.txt`、`stats_report.csv`、`methods.txt`、`prism_table.txt`、`long_format.csv`、`summary.txt`、`comparison_result.json`、`README.txt` |
| 任务导出（Mac） | 一个任务所有实验的 CSV 文件夹，附 `README_methods.txt` |
| 多格悬尾 | 每格不动时间、片段和每分钟表格；见 [Mac 导出](../mac/exports.md#tst) |

每列的含义见[结果与导出](../guide/results.md)和[组间比较](../guide/groups.md#export)。
