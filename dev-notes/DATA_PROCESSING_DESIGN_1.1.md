> **1.1.1 更新**：追踪点改为按对比度加权的斑点质心（尾巴不再把质心往后拉约 1 cm）；全视频分析的帧换算到 full range（与背景一致）；自动修补"静止小鼠被算进背景"造成的幽灵斑点；运动指数像素阈值 12 → 20；NOR / Barnes 半径默认 8 cm。详见 README 和合成测试视频包。

# RodentFlow 1.1 — 实验结果与组间分析设计说明

本文档说明 1.1 版如何把"检测到的轨迹"直接变成"实验结果数据"，以及两个 Tab（单个实验 / 组间比较）的设计和统计逻辑。

---

## 1. 总体思路：三层结构

```
视频 ──► ① 跟踪层（每个视频只跑一次）
          每 0.1 s：x/y (cm)、是否检测到、置信度、区域、帧间运动指数、身体面积
            │  保存在 Documents/Experiments/<run>/full_tracking.json
            ▼
         ② 区域 / 事件层（可随时修改，不需要重跑视频）
          中心区大小、物体/平台/目标洞位置、明暗分界、CPP 分区、freezing 阈值、分析时间窗……
            │
            ▼
         ③ 指标层：每只动物一条结果记录 ExperimentResult
          subject、group、sex、phase、day、trial + 指标 + 时间序列 + 参数 + QC 标记
            │  保存在 Documents/Results/<assay>/<id>.json（Files App 可见）
            ▼
         Groups Tab：按动物汇总 → 选择统计方法 → 出图 → 导出
```

关键点：
- **跟踪和结果分离**。视频跟踪最耗时，只做一次；区域、阈值、时间窗都在结果页调整，指标立即重算（同一段轨迹，毫秒级）。
- **每个指标都有定义文字和参数记录**（结果页 "Methods" 中可见，也写入 JSON），可直接用于论文 Methods。
- **三种数据来源**进入同一个结果库：视频跟踪、手动录入（秒表、计数、称重）、导入表格（CSV/TSV/JSON）。

---

## 2. 两个 Tab

### Tab 1 · Experiment（单个实验处理）
1. 选择范式（按类别：焦虑/情绪、学习记忆、运动、奖励决策、其他）。
2. 选择数据来源：
   - **视频**（支持的范式）：导入 → 标定（含新增的十字迷宫 C/N/E/S/W，以及物体 A/B、平台 P、目标洞 T 标记）→ 10 秒预览 → 全视频分析 → 自动生成该范式的结果。
   - **手动录入**：表单由每个范式的 schema 自动生成，支持重复行（trial / day / stride / CS），实时显示计算结果。
   - **导入表格**：CSV/TSV/JSON，自动识别列名。
3. 结果页：指标卡片、轨迹+区域图（可拖动物体/平台/目标洞标记）、占位热图、freezing 时间线、bandit 选择曲线、时间分段图；分析参数可调并实时重算；可编辑 subject/group/sex/phase/day/trial；可标记 **排除** 并写原因（排除的数据保留但默认不进入组间分析）。
4. 1.0 版留下的跟踪文件夹可一键 **重新分析** 成 1.1 的结果（中心区、静止时间、时间分段等新指标）。

### Tab 2 · Groups（实验组 vs 对照组，或更多组）
- 选择范式 → 选择分析设计 → 选择指标 → 组的顺序（第一个为对照）、颜色、是否纳入 → 自动统计 + 出图。
- 可导入其他手机或 Excel 的数据（导出成 CSV 即可），或导入其他 RodentFlow 导出的 JSON。
- 导出：图（PNG，3× 分辨率，带图例和检验结果）、统计结果（JSON）、该范式全部记录（JSON，可在另一台手机重新导入）、文字摘要（复制到剪贴板，可直接贴进实验记录）。

---

## 3. 各范式：数据来源与指标

| 范式 | 来源 | 需要的设置 | 主要指标（主指标加粗） |
|---|---|---|---|
| Open Field / Center | 视频·手动·CSV | 矩形/圆形；中心区大小（默认边长 50% = 面积 25%） | **总距离**、平均速度、运动时间%、静止时间、中心时间 (s/%)、中心进入次数、进入中心潜伏期、中心距离%、5 min 分段 |
| Elevated Plus Maze | 视频·手动·CSV | 新增十字迷宫标定；臂长（不含中心）、臂宽；哪一对是开臂 | **开臂时间%** = 开/(开+闭)、开臂进入%、开/闭/总进入、开臂潜伏期、距离 |
| Light–Dark Box | 视频·手动·CSV | 明区在左/右、明区长度比例；看不到的样本计为暗区 | **明区时间%**、明/暗时间、穿梭次数、进入暗区潜伏期、明区距离 |
| Marble Burying | 手动·CSV | 弹珠总数 | **埋藏%**（≥2/3 覆盖）、埋藏数、部分埋藏数 |
| Sucrose Preference | 手动·CSV | 每天瓶重（前/后）、漏液对照、体重 | **偏好%** = Σ蔗糖/(Σ蔗糖+Σ水)、每日平均偏好、蔗糖/水/总摄入 (g/day)、蔗糖摄入/体重 |
| Y-Maze | 视频·手动·CSV | Y 迷宫标定；或手动输入臂序列 "ABCAB…" | **自发交替%**、臂进入次数、交替次数、距离 |
| T-Maze | 视频·手动·CSV | T 迷宫标定 | **右侧首选%**（多次 trial 平均即为右选比例）、左右臂进入、选择潜伏期 |
| NOR | 视频·手动·CSV | 拖放物体 A/B；新物体是 A 或 B；交互半径；分析前 5 min；排除标准（总探索 <10 s） | **DI** = (N−F)/(N+F)、RI%、新/旧物体探索时间、总探索、接近次数、首次接近潜伏期 |
| Morris Water Maze | 视频·手动·CSV | 拖放平台 P；平台半径；trial 上限；需在平台停留时间；Acquisition / Probe；Day、Trial | Acquisition：**逃避潜伏期**、路径长度、游速、是否找到；Probe：**目标象限%**、对侧象限%、穿越次数、首次到达潜伏期、平均离平台距离、贴壁% |
| Barnes Maze | 视频·手动·CSV | 拖放目标洞 T（其余洞自动均匀分布）；洞数；洞区半径；trial 上限 | **主潜伏期**、主错误数、总错误数、到目标路径长度、速度、逃入潜伏期、目标象限%、搜索策略（Direct/Serial/Random） |
| Fear Conditioning | 视频·手动·CSV | 协议：起点、baseline、CS 开始时间与长度；freezing 阈值与最短持续时间 | **freezing%**（全程 / baseline / 每个 CS / CS 平均 / ITI）、freezing 次数、平均持续时间、每分钟曲线 |
| Beam Walking | 手动·CSV | 每次 trial：通过时间、打滑数、是否掉落；Phase 写横木规格 | **通过时间**、每次打滑数、总打滑、掉落%、trial 数 |
| Gait Analysis | 手动·CSV | 每个步幅：左右、前/后肢步长、步宽、重叠 | **后肢步长**、前肢步长、前/后步宽、重叠、步长 CV、左右不对称%、步频、速度 |
| CPP | 视频·手动·CSV | 2 室或 3 室；中性室宽度；配对侧；Pre-test / Conditioning / Test | **偏好分数** = 配对−非配对 (s)、配对侧偏好%、各室时间、进入次数；组间可直接算 **Test − Pre-test** |
| Two-Armed Bandit | 导入 trial CSV（或手动） | 列：choice、reward，可选 p_left、p_right、rt | **高价值选择%**、奖励率、win-stay%、lose-shift%、切换率、侧偏、Q-learning α/β、模型伪 R²、反转前后选择曲线 |
| Other / Custom | CSV | 任意数值列 | 列名即指标名（例如 Rotarod latency） |

### 3.1 指标计算中的几个关键规则
- **时间**：每个样本代表到下一个样本的时间（10 Hz → 0.1 s），视频中断不会被放大（上限 5 个采样间隔）。
- **百分比的分母**：区域时间% 用"检测到的时间"作分母，追踪丢失不会稀释结果；追踪率 <90% 会自动标记。
- **进入次数**：需要在新区域稳定停留（默认 0.3 s，迷宫 0.25 s，可调），避免边界抖动算成多次进入。
- **距离**：与 1.0 一致，只累计连续两帧都检测到的位移。
- **速度/静止**：用中心差分速度（前后两帧），减小单帧抖动。
- **NOR / Barnes**：用身体中心点进入物体/洞的区域来近似"鼻尖探索/探洞"，所以保留手动打分录入；交互半径可调。1.1.1 起两者默认 8 cm：身体中心在鼻尖后约 4–5 cm，嗅 2–3 cm 半径的物体时身体中心离物体中心约 7–9 cm；探洞时头部没入洞中，可见身体的中心离洞中心约 5–7 cm。
- **MWM 逃避**：中心点进入平台区并停留 ≥1 s（可调）才算找到；没找到记为 trial 上限并标记。
- **Freezing**：新增的运动指数 = 相邻 10 Hz 帧之间灰度变化 ≥20（full range；1.1 为 ≥12，压缩视频里静止小鼠的边缘闪烁会把 freezing 切碎，1.1.1 改为 20）的竞技场像素比例，再除以该视频小鼠身体面积的中位数 → "身体面积的 x% 在变化"。低于阈值（默认 5%）并持续 ≥1 s 判为 freezing。合成测试中小鼠移动 4 像素时变化约 67%，静止为 0；**正式使用前请用几段人工打分的视频校准一次阈值**。

---

## 4. 组间分析：统计设计

### 4.1 n = 动物
同一只动物的多个 trial / session 先在动物内平均，再做组间比较（避免把 100 个 trial 当成 100 只独立动物）。按天的学习曲线先在"动物 × 天"内平均 trial。

### 4.2 五种分析设计（按数据自动提供）
| 设计 | 适用 | 参数检验 | 非参数检验 |
|---|---|---|---|
| Compare groups | 每只动物一个值 | 2 组：Welch t（含 95% CI 和 Hedges' g）；≥3 组：单因素 ANOVA + Tukey–Kramer（或每组 vs 对照的 Welch t + Holm） | Mann–Whitney U（小样本精确 p）；Kruskal–Wallis + Dunn (Holm) |
| Across days | MWM/Barnes/Beam 学习曲线 | 混合 ANOVA（组 × 天，动物为重复单位，Greenhouse–Geisser 校正）+ 每天组间 Welch t（Holm） | 每天 Mann–Whitney（Holm）；单组用 Friedman |
| Time course | 时间分段、每个 CS、每天偏好、反转曲线 | 同上 | 同上 |
| Paired measures | 新 vs 旧物体、配对 vs 非配对、目标 vs 对侧象限、baseline vs CS、蔗糖 vs 水 | 每组配对 t；≥2 组用混合 ANOVA（交互作用 = 差值是否组间不同） | 每组 Wilcoxon；组间比较差值（MWU / KW） |
| Change between phases | CPP Test − Pre-test 等 | 同 Compare groups | 同 Compare groups |

- 可选 **与机会水平比较**：DI vs 0、RI vs 50%、象限 vs 25%、偏好 vs 50%（单样本 t / Wilcoxon）。
- 缺少某一天的动物会从 ANOVA 中剔除（图中仍显示），并在备注中说明。
- 组内数值完全相同（没有变异）时不给出检验结果，而是提示原因，避免出现荒谬的统计量。

### 4.3 图
- 默认 **柱 + 个体点**（均值 ± SEM），可切换 **箱线 + 点** 或 **均值 ± SEM**；学习曲线为组均值 ± SEM；配对设计显示每只动物的连线。
- 显著性括号与星号来自校正后的 p 值；可选显示 ns。
- 色盲友好配色（Okabe–Ito），对照组默认灰色；颜色、顺序、纳入与否按范式保存。

### 4.4 统计引擎验证
所有统计函数在 Linux 上用 Swift 编译后与 SciPy / pingouin / scikit-posthocs 对比：1,059 项检查全部一致（Welch/Student/配对/单样本 t、Mann–Whitney 精确与渐近、Wilcoxon、单因素 ANOVA、Tukey（移植 R 的 ptukey）、Kruskal–Wallis、Dunn、混合 ANOVA + GG、单因素重复测量 ANOVA、Friedman）。

---

## 5. 数据导入格式

CSV / TSV（第一行为列名，逗号、分号、制表符自动识别；分号文件支持小数逗号 12,5）：

- **每只动物一行（宽表）**：`subject, group, [sex, day, trial, phase], 指标列…`。列名与指标自动匹配，例如 `Center time (%)`、`center_time_pct`、`Total distance (m)` 都能识别；不认识的数值列保留为自定义指标。
- **长表**：`subject, group, metric, value`。
- **原始测量表**（推荐用于手动类范式）：列名用模板中的字段，例如蔗糖偏好 `sucrose_start, sucrose_end, water_start, water_end`，Beam `trial, time_s, slips, fell`，App 会按动物分组后计算。
- **Bandit trial 表**：`subject, group, choice (L/R), reward (0/1), [p_left, p_right, rt]`，按动物 × session 生成记录。
- **JSON**：RodentFlow 导出的结果包；或 1.0 的 `summary.json`。
- 每个范式在导入页都可以生成 **CSV 模板**。
- 列名别名：subject/mouse/animal/id；group/genotype/treatment/condition；phase/stage/session/beam。

`SampleData/` 文件夹中有几份**合成的示例数据**（不是真实实验数据），可用于在手机上试用导入和 Groups Tab。

---

## 6. 文件与存储

| 位置 | 内容 |
|---|---|
| Documents/Experiments/<run>/ | 1.0 的全部 JSON（full_tracking.json 现在包含 motionIndex 与 blobAreaFraction）+ 新的 `result.json` |
| Documents/Results/<assay>/<id>.json | 每条结果记录（Files App 可见，可备份/拷贝） |
| Application Support/RodentFlow/group_settings.json | 组的顺序、颜色、是否纳入 |

- 1.0 中断分析的恢复记录仍可读取（新增字段都是可选的）。
- 导出仍以 JSON + PNG 为主；1.0 特意去掉的 CSV 导出没有恢复，只增加了 CSV **导入**和模板。

---

## 7. 已知限制与后续可做

1. NOR 和 Barnes 的"探索 / 探洞"基于身体中心点，不是鼻尖。下一步可接入关键点模型（如 DeepLabCut/SLEAP 导出的 CSV）或加一个"按住计时"的人工打分器。
2. Freezing 阈值需要按每个实验箱/相机校准；之后可以做"用 3 段人工打分视频自动拟合阈值"。
3. Gait 目前是手动录入步长；可以加"拍照足迹纸 + 比例尺 + 点选足印"自动计算。
4. Beam 的打滑只能人工计数；可以加"边看视频边点按计数"的事件打分器（同时适用于 grooming、rearing）。
5. 圆形场地的坐标沿用 1.0 的原始帧方向；对于竖拍视频，轨迹图可能相对画面旋转 90°（不影响指标）。
6. Barnes 搜索策略是规则分类，仅供参考，没有进入组间统计。
