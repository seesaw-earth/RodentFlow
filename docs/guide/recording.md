# Recording videos that track well

The tracker separates the animal from the arena by comparing each frame with an image of the empty arena (see [Tracking](../principles/tracking.md)). Anything that changes in the arena other than the animal can be mistaken for it, and an animal that looks like the floor is hard to find. Most tracking problems are solved at the camera, not in the app.

## Checklist

| | Do | Why |
|---|---|---|
| Camera | Mount it **straight above** the arena, on a stand that does not move between animals | Centimeters are measured on the floor plane. A fixed camera lets you reuse the calibration with **Use Previous Setup**. |
| Framing | Let the arena **fill most of the frame** | The analysis runs at 192 pixels on the long side of the video, so a small arena means few pixels per centimeter (see below). |
| Contrast | Dark animal on a light floor, or white animal on a dark floor | The tracker uses the size of the difference from the background, so either polarity works, but it needs a difference. |
| Light | **Even**, diffuse light; no moving shadows; no glare on water or acrylic | Shadows and reflections change the image the same way an animal does. |
| Exposure | Lock exposure and focus. In the iPhone Camera app, press and hold on the arena until **AE/AF LOCK** appears. | Automatic exposure changes the brightness of the whole frame when a dark animal walks under the camera. |
| Start and end | Keep hands, lids and the experimenter out of the frame during the scored period, or skip that time with the analysis window | Anything that moves inside the arena during scoring is a candidate for the animal. |
| One animal | One animal per arena | The tracker follows a single animal. |

## How many pixels per centimeter?

All frames are scaled so that their long side is 192 pixels before tracking. That is enough for a mouse body, provided the arena is not small in the picture.

| Arena in a 16:9 frame | Pixels per cm after scaling | What it means |
|---|---|---|
| 40 cm open field filling 60 % of the width | about 2.9 px/cm | A mouse body is about 25 px long; comfortable. |
| 70 cm plus maze filling 55 % of the width | about 1.5 px/cm | Times and entries are correct, but total distance is overestimated (see [Validation](../principles/validation.md)). |

Frame the arena as tightly as you can while keeping all of it in view. Turning the phone so that the long side of the frame matches the long side of the arena also helps.

## Video format, resolution and length

- **Format**: anything the iPhone can play, such as MOV or MP4 with H.264 or HEVC. Videos from other cameras can be copied to the phone through AirDrop, Files or a USB drive.
- **Resolution**: 720p or 1080p is plenty. 4K works but takes longer to decode, because every frame is still reduced to 192 px.
- **Frame rate**: any. The analysis samples 10 frames per second using the timestamps stored in the video, so 25, 30 and 60 fps all give the same time base.
- **Length**: no fixed limit. Long sessions simply take longer, and the analysis can be paused and resumed.

## The animal must move at some point

The empty-arena image is built from 21 frames spread across the whole video. Where the animal is somewhere else in most of those frames, the floor is visible and the background is correct. Two cases need attention:

- **An animal that rests at one spot for much of the session** (closed arm of the plus maze, long freezing, platform in the water maze). Without care, the resting animal would become part of the background and leave a "ghost". The tracker detects and repairs this automatically ([how](../principles/tracking.md#resting-animal-repair)).
- **An animal that never moves at all** cannot be separated from the background. Such a session cannot be tracked by any background method.

## Assay-specific advice

- **Light–dark box.** If the dark compartment is covered, the animal disappears when it enters. That is expected. With **Count unseen samples as dark** on, those samples count as time in the dark. Calibrate only the visible floor, and set the light compartment length accordingly.
- **Water maze.** Make the water opaque and choose a color that contrasts with the animal. Avoid ceiling lights that reflect on the water surface. Mark the platform position before the probe trial, because the platform is not visible then.
- **Barnes maze.** Lighting should be bright and even. The holes are dark, so a dark animal's head disappears into a hole during a poke. This is why the hole zone is larger than the hole itself.
- **Novel object recognition.** Objects should not cast long shadows. Their centers are marked during calibration.
- **Fear conditioning.** Keep the chamber light constant during the session. A light cue switched on at CS onset changes all pixels at once and appears as movement for a moment. Bedding that the animal kicks around also counts as motion.
- **Several arenas in one video.** Each analysis looks only inside its calibrated arena, so the same video can be analyzed once per arena with a separate calibration each time.

## If you can trim, trim

If the first seconds show the animal being placed in the arena, either trim the video in Photos before importing it, or set **Start after** in the analysis window to the first second you want scored. For the water and Barnes mazes, the corresponding field is **Trial start in video**.
