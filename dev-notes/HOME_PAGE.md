# 网站首页（原 rodentflow2 项目页）维护说明

`https://seesaw-earth.github.io/RodentFlow/` 的首页就是原来的 rodentflow2 项目页。它不是 VitePress 页面，而是一个独立的 HTML 文件，样式和脚本都在文件里面。手册的其他页面仍由 VitePress 从 `docs/` 生成。

## 文件在哪里

| 文件 | 作用 |
|---|---|
| `docs/public/index.html` | 英文首页（`/RodentFlow/`） |
| `docs/public/zh/index.html` | 中文首页（`/RodentFlow/zh/`） |
| `docs/public/videos/` | 首页视频区的 8 段录屏，每段 3 个文件：`名字.mp4`、`名字.jpg`、`名字-thumb.jpg` |
| `docs/public/home/` | 首页图标，以及自托管字体 `fonts/`（不再从 Google Fonts 加载） |
| `tools/homepage/encode-all.sh`、`encode.sh` | 视频转码脚本，输出到 `docs/public/videos/` |

**中英文是两个文件。** 改文字、换视频顺序时，两个 `index.html` 都要改：视频清单在每个文件底部脚本里的 `const CLIPS`（中文文件里的标题和说明已翻译），实验表在 `const TESTS`。

## 颜色

视频旁“视频中”的图例和“三种追踪方式”里的动画，用的都是 App 在视频上画的颜色：

- 六关键点：鼻尖红 `#FF383C`、左耳橙 `#FF8D28`、右耳黄 `#FFCC00`、颈部绿 `#34C759`、身体中心青 `#00C0E8`、尾根紫 `#CB30E0`（App 源码里的 `DesignSystem.keypoints`）。
- 质心：薄荷绿点 `#00C8B3`，加最近 2.5 秒的橙色轨迹 `#FF8D28`（`TrackingOverlayView.swift`）。
- 两只动物：A 蓝、B 红。

如果 App 改了配色，两个 `index.html` 里都要改三处：CSS 的 `--kp-*` 变量、脚本里 `TRACKERS` 的图例、动画里的 `COL`。左上角 Logo 用的是 App 图标的配色，不跟着改。

## 换视频

```bash
brew install ffmpeg                                   # 只需一次
bash tools/homepage/encode-all.sh ~/Downloads/APP_demo/3x
```

单个视频：`bash tools/homepage/encode.sh 原文件 新名字 --start 1 --dur 12`。参数说明见 `encode.sh` 开头的注释。加新视频后，在两个 `index.html` 的 `CLIPS` 里各加一段，`file` 写转码时起的名字。`tracker` 要按视频里实际用的追踪方式填：`centroid`（质心）、`pose`（单只六关键点）、`dyad`（两只）或 `tst`（悬尾），它决定标签和图例。

## 本地预览

```bash
npm ci                      # 只需一次
npm run docs:build
npm run docs:preview        # 打开 http://localhost:4173/RodentFlow/
```

`docs:preview` 用的是构建好的网站，首页、手册和视频都和线上一样。`npm run docs:dev` 只适合改手册页面，首页在 dev 模式下不一定显示。

## 首页与手册之间的链接

- 首页里的链接都是相对路径（`guide/editions.html`、`source.html`、`support.html`），中文首页里的链接指向中文手册。
- 手册左上角的 RodentFlow 标志链接回首页。`docs/.vitepress/theme/index.ts` 让这些链接整页跳转，否则 VitePress 会显示“页面不存在”。

## 发布

合并到 `main` 后，`.github/workflows/deploy.yml` 会自动构建并发布，一两分钟后生效。
