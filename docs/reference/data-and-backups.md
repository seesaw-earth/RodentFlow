# Where your data lives & backups

## Mac

- **Your videos** stay where you put them and are only read. The app remembers permission to open the files you chose.
- **The workspace** (projects, tasks, sessions, calibrations, review verdicts) and the **tracking runs** live in the app’s sandbox container, typically  
  `~/Library/Containers/com.ziqingshi.RodentStudio/Data/Library/Application Support/RodentDesktopNative/`  
  (`workspace.json` and the `Runs` folder). In Finder use *Go › Go to Folder…* (<kbd>⇧</kbd><kbd>⌘</kbd><kbd>G</kbd>) and paste the path.
- Before any automatic task merge, a backup `workspace-before-task-merge-*.json` is written next to the workspace.
- **Back up** your video folder, the container folder above and your export folders — [Time Machine](https://support.apple.com/104984) does all three. Quit RodentFlow before copying the workspace manually.
- Removing a video or deleting a task in the app does **not** delete source videos or tracking folders, so nothing is lost by accident — but it also means disk space is not freed automatically.
- File access follows the permissions you grant when choosing files or folders; see [Apple: Control access to files and folders](https://support.apple.com/guide/mac-help/mchld5a35146/mac).

## iPhone & iPad

- Each analysis is a folder under *Files › On My iPhone/iPad › RodentFlow › Sessions*, including a copy of the video. Settings shows the number of analyses and storage used.
- Device backups (iCloud or Finder) include app data according to your backup settings; for important studies, also export the results.

No account, no ads, no developer analytics, no upload service: see the [Privacy Policy](/privacy) for details and caveats.
