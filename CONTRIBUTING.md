# Contributing to RodentFlow

Thank you for helping. RodentFlow is used for real experiments, so correctness and clear documentation matter more than features.

## Reporting a problem

Open an [issue](https://github.com/seesaw-earth/RodentFlow/issues) with:

- the app version (iPhone Settings › General › iPhone Storage › RodentFlow), iPhone model and iOS version;
- the assay and the data source (video, manual entry or import);
- what you did, what you expected and what happened;
- for tracking problems, a screenshot of the preview and, if you are allowed to share it, a short clip;
- for import problems, the first lines of the file with real animal IDs replaced.

Issues are public: do not post unpublished data or videos you may not share.

## Proposing an assay or metric

Describe the protocol, the measure and how it is defined in your field, ideally with a reference to a methods paper. Say whether it should come from video, manual entry or import.

## Pull requests

1. Fork the repository and create a branch from `main`.
2. Build and run on an iPhone (see *Build from source* in the [README](README.md)).
3. Keep changes focused; one topic per pull request.
4. If you change a metric, a default or a statistical method, also update the manual in `docs/` (English **and** Chinese pages) and add a line to [CHANGELOG.md](CHANGELOG.md).

### Code guidelines

- No third-party dependencies, no network code. The privacy promise depends on it.
- Long work (decoding, writing files) stays off the main thread. See [dev-notes/BUILD_NOTES.md](dev-notes/BUILD_NOTES.md) for the 1.2.1 rules.
- Stored and exported data use English keys, assay ids and phases. Only displayed text is translated.

### Interface text and translations

All user-facing text is translatable through `RodentFlow/Localizable.xcstrings`. Read [dev-notes/LOCALIZATION.md](dev-notes/LOCALIZATION.md), then check the catalog before you commit:

```bash
python3 Tools/localization/check_catalog.py
```

## Editing the user manual

The manual in `docs/` is a [VitePress](https://vitepress.dev/) site in English and Simplified Chinese.

```bash
npm ci
npm run docs:dev      # live preview at http://localhost:5173/RodentFlow/
npm run docs:build    # fails on broken internal links
```

- Every page exists twice: `docs/<path>.md` (English) and `docs/zh/<path>.md` (Chinese). Change both.
- UI labels in the Chinese pages follow the app's own translation in `Localizable.xcstrings`, so the manual and the app use the same words.
- Assay headings carry fixed anchors (`{#open-field-center}` …) that are identical in both languages.
- Figures go in `docs/public/img/` as `name.en.png` and `name.zh.png` and are referenced as `/img/name.en.png`. VitePress adds the `/RodentFlow/` base path.
- Site settings (navigation, sidebars, search, footer, base path) are in `docs/.vitepress/config.mts`.
- Pushing changes under `docs/` to `main` redeploys the site through `.github/workflows/deploy.yml`.

## License

By contributing you agree that your contributions are licensed under the [MIT License](LICENSE).
