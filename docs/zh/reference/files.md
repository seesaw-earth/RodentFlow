# 文件与数据

RodentFlow 的数据只存在两个地方：App 的 **Documents** 文件夹（在“文件”App 里可以看到），以及一个私有的支持文件夹。除此之外不会存到任何地方。

## 在“文件”App 中

打开 *文件 › 我的 iPhone › RodentFlow*。

```text
RodentFlow/
├── Results/
│   ├── open_field/
│   │   └── 3F2A…C1.json          每条结果一个文件
│   ├── elevated_plus_maze/
│   └── …                         每个实验范式一个文件夹
└── Experiments/
    └── 2026-03-14_101502_WT01_rectangle_a1b2c3/
        ├── full_tracking.json    所有 10 Hz 样本
        ├── preview_tracking.json 10 秒预览
        ├── summary.json          本次运行的汇总
        ├── metadata.json         实验范式、场地、校准、设置、动物信息
        ├── video_info.json       源文件名、时长、分辨率、帧率、日期
        ├── maze_events.json      进臂事件（T、Y 迷宫）
        └── result.json           由本次运行生成的结果的副本
```

- **Results/**：每条结果一个 JSON 文件，按实验范式 ID 分文件夹存放，也就是 App 里显示的结果库。把这些文件复制到另一台 iPhone，或在另一台 iPhone 上导入导出的合集，就能转移结果。
- **Experiments/**：每段分析过的视频一个*运行文件夹*，命名为*日期_时间_动物_场地_代码*。为节省空间，源视频**不会**复制到运行文件夹中，请保留原始视频。

## 追踪文件

`full_tracking.json` 中每个 10 Hz 样本一条记录：

| 字段 | 含义 |
|---|---|
| `frameIndex` | 样本序号 |
| `videoTimeSeconds` | 该帧在视频中的时间 |
| `clipTimeSeconds` | 自分析开始的时间 |
| `xCentimeters`、`yCentimeters` | 场地厘米坐标（原点在场地左上角；迷宫为迷宫外接框的左上角） |
| `arenaXNormalized`、`arenaYNormalized` | 占场地的比例（0–1） |
| `imageXNormalized`、`imageYNormalized` | 占视频画面的比例（0–1） |
| `interpolated` | 为 `true` 表示**未检测到**动物，沿用了上一位置 |
| `confidence` | 所选候选的 0–1 评分 |
| `zone` | 迷宫区域（`center`、`A`/`B`/`C`、`left`/`right`/`start`、`N`/`E`/`S`/`W`）或 `arena` |
| `motionIndex` | 与上一样本相比灰度变化 ≥ 20 级的场地像素比例 |
| `blobAreaFraction` | 追踪到的身体面积占场地的比例 |

这些都是普通的 JSON 文件，R（`jsonlite`）、Python（`json`、`pandas`）、MATLAB（`jsondecode`）等工具都能直接读取，可以用来计算 App 没有提供的指标。

## 结果文件

每条结果是一个 JSON 对象，包含：

- 身份信息：`id`、`assay`、`subjectID`、`group`、`sex`、`phase`、`day`、`trial`、`experimentDate`；
- `source`：`video`、`manual` 或 `imported`；
- `metrics`：指标键 → 数值，如 `"center_time_pct": 22.4`；
- `series`、`labels`：时间序列和文本结果；
- `parameters`：指标所依赖的全部参数；
- `qcFlags`、`excluded`、`exclusionReason`、`notes`；
- `zoneConfig`（视频结果）、`manualInput`（手动结果）和 `runFolderName`（指向运行文件夹）。

无论 App 使用哪种语言，键名、实验范式 ID 和阶段名称始终是英文，所以不同语言设置的手机之间可以互换文件。读取时会容忍未知或缺失的键，较旧或较新版本的文件都能打开。

## 导出

| 位置 | 导出项 | 格式 |
|---|---|---|
| 结果页 › 共享 | 共享结果（JSON）；共享追踪文件夹 | JSON；文件夹 |
| 完整分析后 | 共享运行文件夹；单个 JSON 文件 | 文件夹；JSON |
| 组间分析 › 导出菜单 | 图表（PNG）；统计结果（JSON）；全部〈范式〉记录（JSON）；复制文字摘要 | PNG；JSON；JSON 合集；文本 |
| 导入界面 | 〈范式〉的 CSV 模板 | CSV |

## App 私有数据

以下内容保存在 App 的私有支持文件夹中，由 App 自动管理：

- 当前打开视频的工作副本（关闭视频或点 **下一只动物** 时删除）；
- 进行中分析的检查点（分析完成或重新开始时删除）；
- 组间分析中各组的顺序、颜色和是否纳入。

## 备份与换手机

Documents 文件夹包含在 iPhone 的常规备份（iCloud 或电脑）中。如果想专门迁移结果，可以在组间分析中为每个范式导出 **全部〈范式〉记录（JSON）**，再在另一台手机上导入；也可以用“文件”App 复制 `Results` 文件夹。

## 删除数据

- 在结果页删除单条结果，或在 **全部结果** 中左滑删除，运行文件夹会保留。
- 在“文件”App 中删除运行文件夹或结果文件。
- 删除 App 会删除它在手机上的全部数据。
