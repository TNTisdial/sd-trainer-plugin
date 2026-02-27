# Settings Reference

All values below are current defaults from `src/settings/SkidSettings.as`.

## General

- `Enable Plugin`: `true`
- `Debug Logging`: `false`

Advanced (hidden by default):

- `Show Advanced Settings`: `false` (reveals runtime tuning controls)

Runtime UI action:

- `Reset Runtime Tuning Defaults`: resets Runtime tuning values shown below to code defaults. It does not reset `Gravity Acceleration Adjustment`.
- `Settings profiles`: save/load/delete named snapshots of runtime tuning + skid skin tier picks.

General UI action:

- `Repopulate Skids (Startup Rebuild)`: runs startup rebuild/staging asynchronously.
- `Delete ModWork Folder (Modless handoff)`: deletes current `Skins/Stadium/ModWork` contents so Modless-Skids can repopulate on next map load.

Runtime profiles details:

- Save with an existing profile name overwrites that profile.
- `Duplicate` copies the selected profile to a new name from `Profile Name`.
- `Rename Selected Profile` renames the selected profile to `Profile Name`.
- Profile names must be non-empty (not just whitespace) and at most 48 characters.
- Loading a profile applies settings, validates selected skid files, and runs startup rebuild/staging asynchronously.
- Profile scope includes Runtime tab tuning fields and per-surface High/Mid/Poor skid file selections.
- Profile loading is blocked while General startup rebuild is running, and startup rebuild is blocked while profile loading is running.

Runtime UI help:

- Most advanced Runtime controls show a hoverable `?` icon tooltip.
- Controls currently without `?` tooltip include `Gravity Acceleration Adjustment`, `Allow Live Grading During Boost`, and `Low Speed Forgiveness`.

## Dynamic colored skids

Advanced (hidden by default):

- `Swap Debounce (ms)`: `260`

## Runtime acceleration model

Advanced (hidden by default):

- `Gravity Acceleration Adjustment`: `true`

## Tier thresholds

Thresholds apply to the drift quality value (clamped to `[-1.0, 1.0]`). `1.0` represents a perfect SD.

These thresholds are always visible in the Runtime tab (not advanced-gated).

Asphalt defaults:

- `Asphalt High Skid Threshold`: `0.910`
- `Asphalt Mid Skid Threshold`: `0.70`
- `Asphalt Poor Skid Threshold`: `0.10`

Dirt defaults:

- `Dirt High Skid Threshold`: `0.910`
- `Dirt Mid Skid Threshold`: `0.70`
- `Dirt Poor Skid Threshold`: `0.10`

Grass defaults:

- `Grass High Skid Threshold`: `0.910`
- `Grass Mid Skid Threshold`: `0.70`
- `Grass Poor Skid Threshold`: `0.10`

## Hysteresis

Advanced (hidden by default):

- `Upgrade Hysteresis`: `0.015`
- `Downgrade Hysteresis`: `0.015`

## Stability filters

Advanced (hidden by default):

- `Promotion Persistence Frames`: `4`
- `Downgrade Persistence Frames`: `4`
- `Surface Stability Frames`: `2`
- `Surface Transition Grace (ms)`: `100`
- `Landing Lockout (ms)`: `30`
- `Min SlipCoef To Drift`: `0.150`
- `Slip Hysteresis`: `0.020`
- `Post-Landing Impact Guard (ms)`: `30`
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
