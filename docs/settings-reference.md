# Settings Reference

All values below are current defaults from `SkidRuntime.as`.

## General

- `Enable Plugin`: `true`
- `Debug Logging`: `false`

Advanced (hidden by default):

- `Show Advanced Settings`: `false` (reveals runtime tuning controls)
- `Gravity Acceleration Adjustment`: `true`

Runtime UI action:

- `Reset Runtime Tuning Defaults`: sets all Runtime tab tuning values back to code defaults.

Runtime UI help:

- Advanced Runtime controls show a hoverable `?` icon tooltip next to each setting.

## Dynamic colored skids

Advanced (hidden by default):

- `Swap Debounce (ms)`: `260`

## Tier thresholds

Thresholds apply to `driftQualityRatio` (clamped to `[-1.0, 1.0]`). `1.0` represents a perfect SD.

Advanced (hidden by default):

- `Green Skid Threshold`: `0.910`
- `Yellow Skid Threshold`: `0.70`
- `Red Skid Threshold`: `0.10`

## Hysteresis

Advanced (hidden by default):

- `Upgrade Hysteresis`: `0.015`
- `Downgrade Hysteresis`: `0.015`

## Stability filters

Advanced (hidden by default):

- `Promotion Persistence Frames`: `4`
- `Downgrade Persistence Frames`: `4`
- `Landing Lockout (ms)`: `80`
- `Min SlipCoef To Drift`: `0.150`
- `Slip Hysteresis`: `0.020`
- `Post-Landing Impact Guard (ms)`: `60`
- `Impact Spike Threshold`: `3.000`
- `Impact Extra Promotion Frames`: `2`
- `Post-Boost Impact Guard (ms)`: `100`
- `Boost Spike Threshold`: `2.500`
- `Boost Extra Promotion Frames`: `2`
- `Allow Live Grading During Boost`: `true`
- `Boost Baseline Follow Rate`: `0.080`
- `Boost Headroom Scale`: `0.45`
- `Uphill Slope Leniency`: `0.030`
- `Downhill Slope Strictness`: `0.050`

## Low-speed forgiveness

Advanced (hidden by default):

- `Low Speed Forgiveness`: `true`

Asphalt defaults:

- `Asphalt Forgiveness Max Speed`: `550.0`
- `Asphalt Forgiveness Min Speed`: `400.0`
- `Asphalt Forgiveness Factor`: `0.90`

Dirt defaults:

- `Dirt Forgiveness Max Speed`: `300.0`
- `Dirt Forgiveness Min Speed`: `150.0`
- `Dirt Forgiveness Factor`: `0.90`

Grass defaults:

- `Grass Forgiveness Max Speed`: `300.0`
- `Grass Forgiveness Min Speed`: `150.0`
- `Grass Forgiveness Factor`: `0.90`
