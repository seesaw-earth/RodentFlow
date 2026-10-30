# 数据存放位置与备份

## Mac

- **你的视频**留在原位置，只读不改。App 会记住你选择这些文件时授予的访问权限。
- **工作区**（项目、任务、实验、标定、复核结论）和**追踪结果**保存在 App 的沙盒容器中，通常位于  
  `~/Library/Containers/com.ziqingshi.RodentStudio/Data/Library/Application Support/RodentDesktopNative/`  
  （`workspace.json` 和 `Runs` 文件夹）。在访达中选择“前往 › 前往文件夹…”（<kbd>⇧</kbd><kbd>⌘</kbd><kbd>G</kbd>）并粘贴该路径即可打开。
- 每次自动合并任务之前，都会在工作区旁写入备份 `workspace-before-task-merge-*.json`。
- 请**备份**视频文件夹、上述容器文件夹和导出文件夹——[时间机器](https://support.apple.com/zh-cn/104984)可一次备份全部。手动复制工作区前请先退出 RodentFlow。
- 在 App 中移除视频或删除任务**不会**删除原始视频或追踪结果文件夹，因此不会误删数据——但也意味着磁盘空间不会自动释放。
- 文件访问遵循你选择文件或文件夹时授予的权限，参见 [Apple：控制对 Mac 上文件和文件夹的访问](https://support.apple.com/zh-cn/guide/mac-help/mchld5a35146/mac)。

## iPhone 与 iPad

- 每次分析是“文件”App › 我的 iPhone/iPad › RodentFlow › Sessions 下的一个文件夹，含视频副本。设置页会显示分析次数和占用空间。
- 设备备份（iCloud 或访达）会按你的备份设置包含 App 数据；重要研究请另外导出结果。

无账号、无广告、无开发者数据分析、无上传服务：详情和注意事项见[隐私政策](/zh/privacy)。
