# Troubleshooting: Mac and pose tracking

## Importing

“The video cannot be opened” for a session that used to work

The file was moved, renamed, deleted, or is on an external/network drive that is not connected. Reconnect the drive or put the file back. Otherwise, remove the session from the project and add the video again (and re-check its calibration).

A video will not import or shows no picture

The codec may not be supported by macOS/iOS. Re-encode as H.264 MP4 (e.g. with [HandBrake](https://handbrake.fr/), “Fast 1080p30” preset) and try again. If a normal H.264 MP4 still fails, please [report it](/support).

“Date not found in the file name or file” / wrong dates

Rename files to include the date (`M01_2026-10-17.mp4`) before importing, or type the date in the import sheet. *Use the first date for all* helps when a whole batch was recorded on one day.

“M01 already has session \#1 in this task”

Each animal’s session numbers must be unique within a task. Use the next number (the sheet suggests one), or check whether you are importing the same video twice.

A session sits in “Missing info” and will not analyse

Open it and complete animal ID, recording date and session number in *Session info*. Sessions imported by older versions may need this once.

## Analysis

“The analysis model is not installed in this build”

Your copy was built without the Core ML models. App Store builds include them. If you built from source, run `git lfs pull` so the model weights are real files, then rebuild (see [Building from source](/source#build)). *Tools › Models* shows what is installed.

“Calibrate the arena first” (RodentFlow)

RodentFlow’s tracker needs the arena before it can run. Go to *Calibrate*, place the handles, save, then analyse.

Analysis is slow

Pose tracking runs on every frame; long, high-resolution videos take time, especially on Intel Macs. Let the queue run (you can keep working), close other heavy apps, and keep the Mac plugged in. On iPhone/iPad, sample every 2–3 frames for long videos where fast head movements do not matter.

The analysis stopped or the Mac went to sleep

Click *Resume* — finished segments are kept. “Analysis failed” shows the reason; *Try again* starts fresh. If it fails repeatedly on one video, try re-encoding it.

Low detection rate / points jump around

Check lighting, contrast, reflections and whether the animal leaves the frame. Use *Frame review* to find the problem frames. Raising the keypoint confidence threshold hides uncertain points; smoothing and gap interpolation (Calibrate › Analysis window and preprocessing) reduce jitter without re-tracking.

Results look implausible (e.g. 0 % centre time, huge distances)

Usually a calibration issue: handles on the outer instead of the inner wall, wrong arena dimensions, or the wrong analysis window. Check the pixels/cm scale and the handle positions, and compare the trajectory with the zones.

Same video, different numbers in RodentPose and RodentFlow

Expected. RodentPose uses keypoints (e.g. nose for object investigation); RodentFlow uses the body centroid at 10 Hz, and zone definitions differ. Choose one family per study.

Pose points are hidden in frame review

The decoded frame did not match the tracking timestamp (or the orientation differs), so the overlay is hidden to avoid a misleading check. Step to a neighbouring frame; the raw data are unaffected.

## TST multi-chamber

Chambers were not found automatically

The picture is split evenly into 6. Set the correct number of chambers and drag the white handles onto the walls, or click *Detect again*.

“No moment was found where every selected chamber had a mouse”

Check that only occupied chambers are selected, lower *Minimum confidence* in *Detection settings…*, or use *Set start by hand…*. For light-coloured mice, change *Mouse colour* to “Light mice / dark background”.

Outlines do not follow the mice

Stop, adjust the analysed band so it covers the mice, or change the mouse colour in *Detection settings…*. Hands, sleeves and shadows confuse the classical detector; a YOLO model fine-tuned on your rig can be imported in Detection settings.

The Results step is greyed out

The start, band, chambers or window changed since the last analysis. Click *Analyse again* to update.

More than 10 % “no mouse” frames

The mouse climbed its tail, was taken down early or left the view. Review the chamber in the original recording and exclude the animal (with a reason) if it does not meet your criteria.

## iPhone & iPad

Detection paused by itself

The app was sent to the background or the device was locked. Progress is saved; open the session and tap *Resume detection*. Keep the app in front while detecting.

I cannot review or re-detect an old session

Its video copy was deleted to save space. Results and pose data remain; to review, start a new analysis with the original video.

The pose model is still loading

You can import and calibrate meanwhile. If it never becomes ready, open Settings and tap *Reload model*; restarting the app also helps.

## Exports

Chinese characters are garbled in Excel

Import the CSV via *Data › From Text/CSV* with UTF-8 encoding, or open it in Numbers. Column names are English and unaffected.

Some sessions have empty values in the task export

Their results were still being computed. Wait for the progress bar on the task page to finish, then export again. Sessions that are not analysed or (RodentFlow) not calibrated have no values.
