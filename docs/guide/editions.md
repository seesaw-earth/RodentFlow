# Which edition do I need?

::: info
Written for RodentFlow for Mac 0.7.1 and RodentFlow for iPhone & iPad 1.0 (the pose edition, formerly RodentStudio).
:::

RodentFlow analyses **your own videos of laboratory rodents** on your own device. There is no account and no upload: videos, tracking and results stay on your Mac, iPhone or iPad (see [Privacy](/privacy)). It comes in two editions that share the same research logic but are built for different jobs.

|                   | RodentFlow for Mac                                                                            | RodentFlow Mobile (iPhone / iPad)                                                 |
|-------------------|-----------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| Best for          | Whole studies: many animals, groups, repeated sessions, statistics and bulk export            | Quick single-video analysis, checking a recording at the bench, teaching          |
| Requires          | macOS 14 Sonoma or later (Apple silicon recommended)                                          | iOS / iPadOS 17 or later                                                          |
| Analysis families | RodentPose (16 assays), RodentLimb (3), RodentFlow (10), TST multi-chamber                    | RodentPose (16 assays)                                                            |
| Organisation      | Project → Task → Group → Animal → Session                                                     | One analysis per video, with subject ID, group, phase, day, trial                 |
| Group statistics  | Built-in “Compare groups” (t-tests, ANOVA, mixed ANOVA, non-parametric)                       | Export a summary CSV and analyse elsewhere                                        |
| Exports           | Session, group and task tables, figures, methods text, DeepLabCut-style frame data, TST files | Metrics CSV, frame-by-frame CSV, raw keypoints CSV, full JSON report, summary CSV |

## Check your device {#check-device}

- Which macOS am I running? [Apple: Find out which macOS your Mac is using](https://support.apple.com/109033)
- Apple silicon or Intel? [Apple: Mac computers with Apple silicon](https://support.apple.com/116943). Both are targeted; Apple silicon runs the Core ML models much faster, so long videos finish sooner.
- Which iOS / iPadOS? [Apple: Find the software version on your iPhone or iPad](https://support.apple.com/109065)

## Getting the app {#get-app}

RodentFlow is on the [App Store](https://apps.apple.com/app/id6818278240). A public beta of the Mac app is on [TestFlight](https://testflight.apple.com/join/dU24jGY7). Please do not trust download links from other sites. Researchers who want to build it themselves can follow [Building from source](/source#build). You do **not** need Python, a GitHub account or an internet connection to analyse videos — the models are bundled inside the app.
