# Settings Reference

All values below are current defaults from `SkidRuntime.as`.

## General

- `Enable Plugin`: `true`
- `Debug Logging`: `false`

Advanced (hidden by default):

- `Show Advanced Settings`: `false` (reveals runtime tuning controls)
- `Gravity Acceleration Adjustment`: `true`

## Dynamic colored skids

Advanced (hidden by default):

- `Swap Debounce (ms)`: `225`

## Tier thresholds

Thresholds apply to `driftQualityRatio` (clamped to `[-1.0, 1.0]`). `1.0` represents a perfect SD.

Advanced (hidden by default):

- `Green Skid Threshold`: `0.93`
- `Yellow Skid Threshold`: `0.70`
- `Red Skid Threshold`: `0.10`

## Hysteresis

Advanced (hidden by default):

- `Upgrade Hysteresis`: `0.015`
- `Downgrade Hysteresis`: `0.015`

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
