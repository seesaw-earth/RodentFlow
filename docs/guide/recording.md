---
title: "Recording videos that track well"
description: "Camera, light, framing, frame rate and file naming for RodentFlow 2.1, with notes for two-mouse, maze, water, marble-burying and tail-suspension recordings."
---

# Recording videos that track well

Most tracking problems are solved at the camera, not in the app. Ten minutes spent on the setup saves hours later. Before a real experiment, record a short test in the real rig and analyse it.

## Checklist {#checklist}

| | Do | Why |
|---|---|---|
| **Camera** | Mount it **straight above** the arena on a stand that does not move between animals. (Tail suspension: facing the front of the rig.) | Centimetres are measured on the floor plane. A fixed camera lets you reuse one calibration for a whole batch. |
| **Framing** | Let the arena **fill most of the frame**, with a small margin all round. | More pixels per centimetre means more precise keypoints. The margin keeps the nose in view during head dips over a maze edge. |
| **Contrast** | A dark mouse on a light floor, or a white mouse on a dark floor. Tell the app the **coat colour**. | The coat colour chooses the model trained for that coat. |
| **Light** | **Even, diffuse** light; no moving shadows; no glare on water, glass or acrylic. Grayscale and infrared video work well. | Shadows and reflections can look like part of an animal. |
| **Exposure** | Lock exposure and focus. In the iPhone Camera app, press and hold on the arena until **AE/AF LOCK** appears. | Automatic exposure changes the brightness of the whole picture when the mouse walks under the camera. |
| **Hands and lids** | Keep them out of the scored period, or set the analysis start after them. | Anything that moves in the arena while scoring can be mistaken for the animal. |
| **Fixed distractions** | Cover them with **Cover part of a video** before analysing (a reflection, a cable, the experimenter at the pool edge). | The app saves a covered copy with the same timestamps; the original is not changed. |

## Frame rate, resolution and length {#format}

- **Frame rate:** 25–30 frames per second suits most tasks. For fast events (attack lunges last 100–200 ms; head scanning at a T-maze choice point) use at least 25 fps and track every frame.
- **Resolution:** 1080p is plenty. 4K works; on iPhone and iPad very large frames are decoded at a reduced size that is still larger than the model input.
- **Length:** no fixed limit. Long recordings take longer and are saved as they run, so a pause or a restart does not lose work.
- **Format:** ordinary MP4 or MOV (H.264 or HEVC). If a file will not open, re-encode it as H.264 MP4, for example with the free [HandBrake](https://handbrake.fr/).

## Two mice in one arena {#two-mice}

Identity is most reliable when the two mice **differ in coat colour, size or a mark**. For mice of the same colour, a marker-pen stripe on the tail or a dyed patch on the back gives the app something to hold on to. For one dark and one white mouse, choose the coat colour *One dark, one white*. For resident–intruder tests, **start recording before the intruder goes in**: the stretch with the resident alone is used to identify it and to find the moment of entry.

## Notes for particular tasks {#tasks}

- **Elevated plus and zero maze, step-down, visual cliff:** leave room around the edges so the nose stays in the picture when the mouse looks over.
- **Water maze:** make the water opaque, in a colour that contrasts with the mouse, and avoid lights that reflect on the surface. Mark the platform position before the probe trial.
- **Marble burying:** fix the camera directly above the cage, do not move it during the test, and keep the light constant; marbles that contrast with the bedding are scored best. Footage from before the mouse is put in gives the best reference frame.
- **Fear conditioning and looming:** keep the chamber light constant; a light cue that switches on changes the whole picture for a moment.
- **Light–dark box:** an infrared camera lets the mouse be seen on the dark side. With a lid and no infrared, the mouse disappears when it goes in; the classic centroid method can count that time as dark (*Count unseen samples as dark*).
- **Novelty-suppressed feeding, passive avoidance, step-down:** set the analysis start to the moment the mouse is put in or the door opens.
- **Rotation filmed through a clear floor:** turn on *Filmed from below* so left and right are not swapped.
- **Tail suspension, multi-chamber:** film the front of the rig with every chamber in view; use climb-stoppers for strains that climb.
- **Classic centroid:** the empty arena is learned from frames across the whole video, so the mouse must move at some point; a mouse that never moves cannot be separated from the floor.

## File names and where to keep videos (Mac) {#files}

- **Name files `AnimalID_YYYY-MM-DD`**, for example `M01_2026-10-17.mp4`. The Mac reads the date from the name (`2026-10-17`, `2026_10_17`, `2026.10.17` or `20261017`) and uses the rest as the animal ID, so the import form fills itself in.
- **Put videos in their final folder before importing.** The Mac reads videos where they are and never changes them. If a video is moved or renamed later, use **Locate video** to link it again.
- Use only videos you are allowed to use, and follow your institution’s data policy for unpublished recordings.
