# Settings Reference

All values below are current defaults from `SkidRuntime.as`.

## General

- `Enable Plugin`: `true`
- `Gravity Acceleration Adjustment`: `true`
- `Debug Logging`: `false`
- `Show Advanced Settings`: `false` (reveals advanced controls in the `Runtime` settings tab)

## Dynamic colored skids

- `Enable Colored Skids`: `true`

Advanced (hidden by default):

- `Swap Debounce (ms)`: `250`

## Tier thresholds

Thresholds apply to `driftQualityRatio` (clamped to `[-1.0, 1.0]`). `1.0` represents a perfect SD.

- `Green Skid Threshold`: `0.94`
- `Yellow Skid Threshold`: `0.75`
- `Red Skid Threshold`: `0.20`

## Hysteresis

Advanced (hidden by default):

- `Upgrade Hysteresis`: `0.02`
- `Downgrade Hysteresis`: `0.01`

## Low-speed forgiveness

- `Low Speed Forgiveness`: `true`

Advanced (hidden by default):

Asphalt defaults:

- `Asphalt Forgiveness Max Speed`: `700.0`
- `Asphalt Forgiveness Min Speed`: `400.0`
- `Asphalt Forgiveness Factor`: `0.80`

Dirt defaults:

- `Dirt Forgiveness Max Speed`: `300.0`
- `Dirt Forgiveness Min Speed`: `150.0`
- `Dirt Forgiveness Factor`: `0.80`

Grass defaults:

- `Grass Forgiveness Max Speed`: `300.0`
- `Grass Forgiveness Min Speed`: `150.0`
- `Grass Forgiveness Factor`: `0.80`
