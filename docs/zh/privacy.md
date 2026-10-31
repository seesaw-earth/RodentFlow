---
outline: false
---

# 隐私政策

*最近更新：2026 年 10 月 30 日 · 适用于 iPhone、iPad 版 RodentFlow 和 Mac 版 RodentFlow*

**简而言之：RodentFlow 不收集、不传输、不共享任何数据。视频、结果和你填写的一切都留在你的 iPhone、iPad 或 Mac 上。**

## App 处理哪些数据

RodentFlow **仅在你自己的设备上**处理：

- 你选择用于分析的视频；
- 你填写的实验信息，如项目和任务名称、实验条件、动物编号、组别、性别、阶段和备注；
- 标定点、复核注释和其他测试设置；
- 你手动录入或从文件导入的数值；
- App 由此计算出的结果：位置和姿态关键点、追踪数据、图表、统计和导出文件。

## App 不做什么

- **不会**向开发者或开发者运营的任何服务器上传、同步或发送你的视频、录入内容或结果。
- **没有账号**，不需要登录或注册。
- **不含任何广告、统计分析或追踪**代码或 SDK。
- **不访问**通讯录、位置、相机、麦克风或健康数据。

姿态追踪使用内置在 App 中的 Core ML 模型，分析视频不需要联网。

## 你可以自行核实

RodentFlow 是开源软件，见[源代码](./source.md)，任何人都可以查看 App 如何处理数据。iPhone App 内附带的隐私清单（`PrivacyInfo.xcprivacy`）声明不追踪、不收集任何数据。

## iPhone 与 iPad 上的照片与文件

- **照片**：通过系统的照片选择器选择视频。RodentFlow 只能拿到你选中的视频，无法访问照片图库的其他内容。
- **文件**：只有在你通过“文件”选择器选中时，App 才读取该文件。结果和追踪文件保存在 App 自己的文件夹中，可以在“文件”App 里看到（见[文件与数据](./reference/files.md)）。

## Mac 上的文件与文件夹

- Mac 版 RodentFlow **在原位置**读取你添加的视频，从不修改它们。
- 工作区（项目、测试、设置和追踪记录）保存在你用户资源库中 App 自己的存储区域（Application Support）。导出文件保存到你选择的文件夹。
- 访问文件和文件夹需要你在选择时授予 macOS 相应权限。

具体位置见[数据存放位置与备份](./reference/data-and-backups.md)。

## 数据存放在哪里

所有数据都保存在你设备上 App 的存储空间和你选择的文件夹里。在 iPhone 和 iPad 上，是否随设备备份（iCloud 或电脑）由你自己的备份设置决定，并受 Apple 管理；在 Mac 上，则随你自己的备份（如时间机器）。

只有当**你**主动共享、导出或另存时（例如隔空投送、邮件、“文件”或访达），数据才会离开设备，而且只发送到你选择的目的地。如果你选择 iCloud 云盘这类云端文件夹（例如把 iPhone 上的分析传到 Mac），文件由该服务按其自身条款保存。

## 删除数据

- **iPhone 和 iPad**：在 App 中删除单条结果、在“文件”App 中删除文件夹，或删除 App 本身，即可移除 App 在设备上的全部数据。
- **Mac**：在 App 中删除任务和测试，在访达中删除导出文件。在 App 中删除任务不会删除你的原始视频，部分追踪文件可能仍留在磁盘上；卸载前请对照[数据存放位置与备份](./reference/data-and-backups.md)检查。

开发者无法访问你的数据，也无法远程删除你设备上的任何内容。

## 本网站

本网站托管于 GitHub Pages，GitHub 可能根据其[隐私声明](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement)处理网站连接和使用数据。本网站没有统计脚本、没有表单、不使用 Cookie，字体和视频都由本网站自己提供。你的浏览器只会记住你选择的浅色或深色外观。

## 儿童

RodentFlow 是面向科研实验室的工具，不收集任何人（包括儿童）的数据。

## 变更

如果本政策有变更，新版本会以新的日期发布在本页。任何引入数据收集的变更，都会在生效前在本页和 App 的版本说明中明确说明。

## 联系方式

对本政策有疑问，请在 [github.com/seesaw-earth/RodentFlow/issues](https://github.com/seesaw-earth/RodentFlow/issues) 提交 issue，或见[支持](./support.md)。GitHub issue 是公开的：涉及敏感问题时，请只提交一个请求私下联系的 issue，不要写具体内容。

开发者：Ziqing Shi
