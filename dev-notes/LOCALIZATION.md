# 本地化说明 / Localization

## 中文简介

- 所有界面文字的中文翻译都在 `RodentFlow/Localizable.xcstrings`（Xcode 的 String Catalog）。在 Xcode 中点开这个文件即可逐条查看、修改译文：左列是英文原文（也是查找用的“键”），右侧选 “Chinese, Simplified” 编辑中文。
- App 跟随 iPhone 的语言；也可以在“设置 › App › RodentFlow › 语言”里单独设置（App 内 **Aa** 菜单里的 “Language / 语言” 按钮会直接打开这一页）。
- 保存和导出的数据（结果文件、CSV 列名、JSON 字段、实验阶段等）始终用英文，中英文手机之间可以互相导入导出。
- 导入表格时，编号 / 组别 / 性别（雄、雌）/ 天 / 试次 / 阶段 / 日期 / 备注 等中文列名在两种语言下都能识别；指标列名在中文界面下也可以直接用 App 中显示的中文名称。
- 修改译文时请保留占位符：`%@`（文字）、`%ld`（整数）、`%.1f`（小数）、`%%`（百分号），数量和顺序都要与英文一致。例如 “%ld samples” → “%ld 个样本”。

## English

### Where the text lives
- `RodentFlow/Localizable.xcstrings` — one entry per English text (the key) with its Simplified Chinese translation. All entries are marked *manual*, so Xcode does not remove them. About 1,000 entries.
- English is the development language and the fallback: a missing translation shows the English text, never an empty label.

### How the code looks up text
| Kind of text | How it is written | Example |
|---|---|---|
| SwiftUI literal | as before | `Button("Cancel")`, `Text("Quality check")`, `.navigationTitle("Import data")` |
| Text built in code, model names, messages | `loc("…")` | `out.qcFlags.append(loc("Platform position is not set."))` |
| Text with values | `locf("format", args…)` | `locf("%ld samples", count)`, `locf("Show settings for %@", name)` |
| Titles passed to shared components | plain English string; the component translates it | `SectionCard("Results", …)`, `KeyValueRow(key: "Source", …)`, `FlowAction(title: "Next Animal", …)` |
| Stored values shown to the user | translate when shown | `AssayKind.phaseTitle(phase)`, `assay.displayName`, `assay.displayShortName`, `locKey(parameterKey)`, `loc(series.name)` |
| Same English word, different meaning | context key | `loc("Groups", context: "tab.groups")` |

Never put a translated string into a file name, a CSV column, a JSON key or a value that code compares (phases, zone ids, choice options): those stay English (`shortName`, `phases`, `rowName`, `englishName`, `englishLabel`).

### Adding or changing text
1. Write the English text in code using the table above. For a value inside a sentence use `locf` with `%@` (text), `%ld` (Int) or `%.1f` (Double); write a literal percent sign in a format as `%%`.
2. Add the English text as a key in `Localizable.xcstrings` with its Chinese translation (in Xcode: open the catalog, "+" for a manual entry; SwiftUI literals are added by Xcode automatically after a build).
3. Run `python3 Tools/localization/check_catalog.py` from the project folder. It lists interface text that is not translatable yet, keys missing from the catalog, and translations whose placeholders differ from the key. It needs only Python 3.

### Adding another language
In Xcode: Project › Info › Localizations › "+", choose the language; the catalog gets a new column to fill in. Nothing in the code needs to change.
