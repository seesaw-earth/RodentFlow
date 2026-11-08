---
title: "How tracking works"
description: "How RodentFlow 2.1 turns video frames into clean tracks: arena-only detection, the Core ML pose models, calibration to centimetres, cleaning, derived features, two-mouse identity, classic centroid and multi-chamber motion."
---

# How tracking works

Tracking turns each frame of a video into positions in centimetres. It is the only slow step and runs once; everything after it (zones, thresholds, measures, statistics) is recomputed in a moment when you change a setting.

## Pose tracking, step by step {#pose}

| Step | What happens |
|---|---|
| **1 · Read the frame** | Frames are decoded in order with their timestamps and turned upright. With *Track the arena only* (the default), only the calibrated arena plus a margin of 5, 12 or 25 % is kept. |
| **2 · Find the mouse** | The frame is scaled to 960 × 960 pixels and passed to the Core ML pose model. The model returns candidate animals, each with a box, a score and six keypoints with a confidence each: nose, left ear, right ear, neck, body centre, tail base. One-animal tasks keep the best candidate; two-animal tasks keep two and assign identities (below). |
| **3 · Pixels to centimetres** | The calibration maps the image onto the arena floor. For boxes the mapping corrects perspective, so a slightly oblique camera still gives true centimetres. |
| **4 · Clean** | Keypoints below 0.5 confidence are set aside; positions that would need an impossible speed (over 150 cm/s) are rejected; gaps up to 0.5 s are filled by straight-line interpolation; the tracks are smoothed over 0.15 s. Resident–intruder uses lighter settings (0.07 s smoothing, 0.2 s gaps) so that 100–200 ms lunges survive. |
| **5 · Derive** | Speed from the body centre; head direction from the ear midpoint to the nose; body axis from the neck to the tail base; the head–body angle; body length from nose to tail base; and a motion index for freezing (the displacement over 0.5 s, averaged over nose, ears, body centre and tail base). |
| **6 · Flag** | Points that fall outside the calibrated arena are marked in the review and the frame-by-frame data, with their distance from the arena. They are flagged, not changed. |

All of these settings are listed with each session and written into the Methods text. The [Models](../models.md) page describes the four models, and [Speed and accuracy](./performance.md) how fast and how accurate they are.

## Two mice, two identities {#identity}

With two mice, matching each frame to the one before fails as soon as the animals touch. RodentFlow instead reads the **whole recording** before assigning identities:

1. It finds the stretches where the two animals are clearly apart and identity is certain.
2. It links these stretches across close contacts using motion and the body axis.
3. It learns from this video whether the two animals differ steadily in coat brightness, a mark or body length, and uses that difference to settle the links.
4. Links that remain uncertain are flagged for review (*Likely swap*, moments to check). **Swap A / B from here** corrects a swap in one tap and recalculates the results.

When one mouse is dark and the other white, MousePose6DyadBW finds both and the brighter one is the white mouse. In the resident–intruder test, the stretch before the intruder enters identifies the resident and the moment of entry.

## Classic centroid {#centroid}

The classic method is the RodentFlow 1.x tracker. It builds an image of the **empty arena** from frames spread across the whole video, subtracts it from each frame, and follows the centre of the largest difference: the body centroid, at 10 samples per second. A mouse resting in one place for a long time would blend into that background; the tracker detects and repairs such "ghosts". It needs no model, works on any coat colour against a contrasting floor, and gives zone, path and time measures. The full description is in [Older versions](../archive/principles/tracking.md).

## Multi-chamber tail suspension {#tst}

For tail suspension the question is not where the mouse is but whether it moves. Chambers are found automatically; for each mouse a fixed **motion box** is set around its whole range of movement, frames are aligned to cancel passive swinging, and the motion is the share of the mouse’s pixels that change from frame to frame. Immobility is motion below a threshold (2 % by default) for at least 1 s. See [Tail suspension, multi-chamber](../tasks/tail-suspension.md).

## Same numbers on every device {#same}

The iPhone, iPad and Mac compile the same analysis code. The same video, calibration and settings therefore give the same values. When the Mac imports an analysis from the phone, it recomputes it and shows whether the two agree.
