---
outline: false
---

# Privacy policy

*Last updated: 30 October 2026 · applies to RodentFlow for iPhone and iPad and RodentFlow for Mac*

**In short: RodentFlow does not collect, transmit or share any data. Videos, results and everything you enter stay on your iPhone, iPad or Mac.**

## What the app processes

RodentFlow processes, **on your own device only**:

- videos you choose for analysis;
- the experiment details you enter, such as project and task names, conditions, animal IDs, groups, sex, phases and notes;
- calibration points, review annotations and other session settings;
- values you enter by hand or import from files;
- the results the app computes from them: positions and pose keypoints, tracking data, figures, statistics and exports.

## What the app does not do

- It does **not** upload, sync or send your videos, entries or results to the developer or to any server operated by the developer.
- It has **no account**, no sign-in and no registration.
- It contains **no advertising, analytics or tracking** code or SDKs.
- It does **not** access your contacts, location, camera, microphone or health data.

Pose tracking runs with Core ML models that are bundled inside the app, so analysing a video needs no internet connection.

## You can check this

RodentFlow is open source; see [Source code](./source.md). Anyone can read how the apps handle data. The privacy manifest in the iPhone app (`PrivacyInfo.xcprivacy`) declares no tracking and no collected data.

## Photos and files on iPhone and iPad

- **Photos.** Videos are chosen with the system photo picker. RodentFlow receives only the video you select and has no access to the rest of your photo library.
- **Files.** Files you choose in the Files picker are read only when you choose them. Results and tracking files are saved in the app's own folder, which you can see in the Files app (see [Files & data](./reference/files.md)).

## Files and folders on the Mac

- RodentFlow for Mac reads the videos you add **where they are** and never modifies them.
- Its workspace (projects, sessions, settings and tracking runs) is saved in the app's own storage in your user Library (Application Support). Exports go to the folders you choose.
- Access to files and folders follows the permissions macOS asks you to grant when you choose them.

See [Where your data lives & backups](./reference/data-and-backups.md) for the exact locations.

## Where your data are stored

All data stay in the app's storage on your device and in the folders you choose. On iPhone and iPad they are included in your device backup (iCloud or computer) according to your own backup settings, which Apple governs; on the Mac, in your own backups such as Time Machine.

Data leave the device only when **you** share, export or save them elsewhere, for example through AirDrop, Mail, Files or Finder, and they then go only to the destination you choose. If you choose a cloud folder such as iCloud Drive, for example to pass analyses from your iPhone to your Mac, that service stores the files under its own terms.

## Deleting your data

- **iPhone and iPad:** delete individual results in the app, delete folders in the Files app, or delete the app to remove all of its data from the device.
- **Mac:** delete tasks and sessions in the app, and exported files in Finder. Deleting a task in the app does not delete your original videos, and some tracking files may remain on disk; check the locations in [Where your data lives & backups](./reference/data-and-backups.md) before you uninstall.

The developer has no access to your data and cannot remotely delete anything stored on your device.

## This website

This website is hosted on GitHub Pages. GitHub may process connection and usage information according to the [GitHub Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement). The website has no analytics script, no forms and no cookies, and its fonts and videos are served from the site itself. Your browser stores only your light or dark appearance choice.

## Children

RodentFlow is a tool for research laboratories. It does not collect data from anyone, including children.

## Changes

If this policy changes, the new version will be posted on this page with a new date. A change that introduced any data collection would be stated clearly here and in the app's release notes before it took effect.

## Contact

Questions about this policy: open an issue at [github.com/seesaw-earth/RodentFlow/issues](https://github.com/seesaw-earth/RodentFlow/issues), or see [Support](./support.md). GitHub issues are public: for a sensitive question, open an issue asking only for a private contact channel, without the details.

Developer: Ziqing Shi
