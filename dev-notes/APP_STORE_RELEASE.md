# RodentFlow 1.3 — App Store Release Identity

## Fixed identity

- App name: **RodentFlow**
- Bundle ID: **com.ziqingshi.rodentflow**
- SKU: **RODENTFLOW-IOS-001**
- Version: **1.3**
- Build: **6**
- Platform: **iOS / iPhone**
- Primary language: **English (U.S.)**
- Primary App Store category: **Utilities**
- Secondary App Store category: **Productivity**
- Developer / Seller (Individual account): **Ziqing Shi**
- Copyright: **2026 Ziqing Shi**
- Suggested subtitle: **Rodent behavior tracking**

## Build identity already configured in the Xcode project

- CFBundleDisplayName: RodentFlow
- PRODUCT_BUNDLE_IDENTIFIER: com.ziqingshi.rodentflow
- MARKETING_VERSION: 1.3
- CURRENT_PROJECT_VERSION: 6
- Localizations: English (development language), Simplified Chinese (zh-Hans)
- iPhone only
- iOS 17.0+
- App category plist value: Utilities
- App uses non-exempt encryption: No
- Privacy manifest included
- 1024x1024 opaque App Store icon included

## Before Archive

1. Open `RodentFlow.xcodeproj`.
2. Select target `RodentFlow` → Signing & Capabilities.
3. Select Ziqing Shi's Apple Developer Team.
4. Confirm Bundle Identifier is exactly `com.ziqingshi.rodentflow`.
5. Run once on a real iPhone and test Photos import, Files import, Open Field, T-Maze, Y-Maze, preview, full analysis, recovery, and JSON export.
6. Product → Archive, then Validate App before uploading to App Store Connect.

## App Store Connect record

Create/select the App Store Connect record with:

- Name: RodentFlow
- Primary language: English (U.S.)
- Bundle ID: com.ziqingshi.rodentflow
- SKU: RODENTFLOW-IOS-001
- User Access: Full Access

## Simplified Chinese App Store listing (new in 1.3)

In App Store Connect › App Information, add the localization **Chinese (Simplified)** and fill in:

- Name: **RodentFlow**
- Subtitle: **啮齿类动物行为追踪与分析**
- Keywords: **小鼠,大鼠,行为学,旷场,高架十字迷宫,水迷宫,新物体识别,恐惧条件化,糖水偏好,统计**
- Description (suggested):

  RodentFlow 在 iPhone 上完成啮齿类动物行为实验的视频追踪、结果计算和组间统计。

  • 视频追踪：旷场 / 中央区、高架十字迷宫、明暗箱、条件性位置偏好、新物体识别、Morris 水迷宫、Barnes 迷宫、恐惧条件化、Y 迷宫、T 迷宫
  • 手动录入或表格导入：埋珠实验、糖水偏好、平衡木、步态分析、双臂老虎机任务等
  • 每只动物一条结果记录，区域和阈值可在分析后修改，无需重新追踪
  • 组间分析：自动选择检验方法（t 检验、Mann–Whitney、方差分析、Kruskal–Wallis、混合方差分析等），生成带个体数据点和显著性标记的图表
  • 导出 PNG 图表、JSON 统计结果和记录，CSV 模板列名中英文通用
  • 所有计算都在手机本地完成

- What's New in 1.3: **新增简体中文界面。在“设置 › App › RodentFlow › 语言”中可单独选择 App 的语言。**

Screenshots: the existing ones can be reused; Chinese screenshots are optional.

## Suggested "What's New in 1.3"

- RodentFlow is now available in Simplified Chinese. The app follows the iPhone language; choose a different language for RodentFlow in Settings › Apps › RodentFlow › Language.

## Suggested "What's New in 1.2.1"

- Smoother: no more pauses when choosing a video, opening the preview, finishing an analysis or switching tabs.

## Suggested "What's New in 1.2"

- Larger, adjustable text: tap Aa to choose the text size.
- A step bar and Back / Next buttons guide you from video to result; jump to any finished step.
- Score a batch faster: "Next Animal" and "Use Previous Setup".
- Browse results with ▲▼ and open any assay in Groups with one tap.

## Suggested "What's New in 1.1.1"

- More accurate tracking: steadier position estimates, correct handling of mice hidden in a covered dark box, and of mice that stay in one place for most of the session.
- More reliable freezing detection on compressed videos.
- Better default zone sizes for novel object recognition and the Barnes maze.

## Suggested "What's New in 1.1"

- New Experiment tab: results for Open Field, Elevated Plus Maze, Light–Dark Box, Place Preference, Novel Object Recognition, Morris Water Maze, Barnes Maze, Fear Conditioning, Y/T-Maze — from video, manual entry or CSV.
- Manual entry for Marble Burying, Sucrose Preference, Beam Walking and Gait; trial import for Two-Armed Bandit.
- Adjust zones and thresholds after tracking with instant re-calculation.
- New Groups tab: compare groups with appropriate statistics and publication-style figures; export PNG and JSON.
