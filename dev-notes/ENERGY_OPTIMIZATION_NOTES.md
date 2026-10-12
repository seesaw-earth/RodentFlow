# Energy Optimization Notes

This build keeps the original V0.1 centroid tracker, 10 Hz sampling, original source timestamps, and JSON schema.

## Applied

- Reduced working video dimension from 260 px to 192 px on the longest side.
- Sparse background frames are requested at the analysis working size instead of 960 px.
- Foreground difference and threshold statistics are evaluated only on calibrated arena pixels.
- The two 3x3 majority-filter passes and connected-components scan only the arena bounding box plus 2 px padding.
- Reuses diff, binary A/B, visited, connected-component queue, and per-frame grayscale buffers.
- Keeps `AVAssetReaderTrackOutput.alwaysCopiesSampleData = false` and reads the Y plane directly from bi-planar YUV.

## Intentionally unchanged

- 10 Hz tracking cadence.
- Original V0.1 blob selection and centroid rule.
- 0.90 current / 0.10 previous mild smoothing.
- Original video timestamps.
- JSON outputs and automatic experiment-folder saving.

## Decoder note

The reader still advances through the source stream sequentially and only runs the tracker at 10 Hz. Random-time extraction with `AVAssetImageGenerator` was not made the default because inter-frame H.264/HEVC decoding can still require reference-frame work; this should be A/B tested on the target iPhone before changing the production decoder.

## Recommended on-device validation

Run the same representative 10-30 minute video on the previous V0.9 and this build. Compare total analysis time, thermal state/phone temperature, Energy Impact in Instruments, tracked fraction, distance, and trajectory overlay.
