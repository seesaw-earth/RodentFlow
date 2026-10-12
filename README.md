# RodentFlow user manual

Source of the RodentFlow manual website in **English and Simplified Chinese**, built with [VitePress](https://vitepress.dev/) and published to GitHub Pages at **https://seesaw-earth.github.io/RodentFlow/**.

RodentFlow 使用手册网站的源文件（英文 / 简体中文），用 VitePress 构建，发布在 GitHub Pages。

## Structure

```text
docs/
├── index.md                 English home page (language switch in the hero and the nav bar)
├── guide/  assays/  principles/  reference/
├── privacy.md  support.md   App Store privacy-policy and support URLs
├── zh/                      Chinese pages, same file names and structure
├── public/
│   ├── img/                 figures, one file per language: name.en.png / name.zh.png
│   ├── samples/             example CSV files offered for download
│   └── logo.png, hero.png, favicon-64.png, apple-touch-icon.png
└── .vitepress/
    ├── config.mts           site config: base path, nav, sidebars, search, locales
    └── theme/               brand colors and small style additions
.github/workflows/deploy.yml builds and deploys on every push to main
```

## Preview locally

Requires Node.js 18 or later.

```bash
npm ci
npm run docs:dev        # live preview at http://localhost:5173/RodentFlow/
npm run docs:build      # production build in docs/.vitepress/dist (also checks for dead links)
npm run docs:preview    # serve the production build
```

## Publish on GitHub Pages

1. Push this folder to the repository `seesaw-earth/RodentFlow`, on branch `main`.
2. In the repository: **Settings › Pages › Build and deployment › Source: GitHub Actions**.
3. Every push to `main` runs `.github/workflows/deploy.yml` and publishes the site at https://seesaw-earth.github.io/RodentFlow/. The first run takes about a minute; progress is under the **Actions** tab.

If the repository has a different name, change `base` in `docs/.vitepress/config.mts` to `/<repository-name>/`, and the two footer links in the same file. For a custom domain, set `base` to `/`.

If the app source code lives in the same repository, keep this folder at the repository root, or move `package.json`, `package-lock.json` and `docs/` into a subfolder and add `working-directory:` to the build steps in the workflow.

## App Store Connect

- **Privacy Policy URL**: https://seesaw-earth.github.io/RodentFlow/privacy.html (Chinese: …/zh/privacy.html)
- **Support URL**: https://seesaw-earth.github.io/RodentFlow/support.html (Chinese: …/zh/support.html)
- **Marketing URL** (optional): https://seesaw-earth.github.io/RodentFlow/

## Editing

- Every page exists twice, `docs/<path>.md` and `docs/zh/<path>.md`. Change both.
- UI labels in the Chinese pages follow the app's own translation (`RodentFlow/Localizable.xcstrings`), so the manual and the app use the same words.
- Assay headings carry fixed anchors (`{#open-field-center}` …) that are identical in both languages, so links between pages work in both.
- Figures: put `name.en.png` and `name.zh.png` in `docs/public/img/` and reference them as `/img/name.en.png`. VitePress adds the `/RodentFlow/` base automatically.
- Screenshots of the app can be added the same way. Recommended width: 1170 px (iPhone portrait), shown at about 360 px with `<img src="/RodentFlow/img/…" width="360">` inside raw HTML, or as a normal Markdown image.
- `npm run docs:build` fails on broken internal links, which makes it a quick check before pushing.
