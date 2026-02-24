# Acceleration and Tier Logic

## Drift quality ratio

Each frame, the plugin computes:

`driftQualityRatio = slopeAdjustedAcceleration / adjustedMaxAccelSpeedSlide`

Then clamps to `[-1.0, 1.0]`.

This ratio (`driftQualityRatio`) drives tier selection: `default`, `poor`, `mid`, `high`.

## Measured acceleration path (`SimulationStep`)

1. Read vehicle state from `VehicleState::ViewingPlayerState()`.
2. Compute scalar speed from front and side speed.
3. Compute frame acceleration using guarded dt: `dtMs = max(frameDtMs, 1.0)` and `rawAcc = (scalarSpeed - prevSpeed) / (dtMs / 1000.0)`.
4. Estimate slope and apply gravity compensation: `trueAcc = rawAcc + 29.0 * sin(slopeEstimate)`.
5. Keep rolling 4-sample averages (`ACCEL_ARRAY_SIZE = 4`).
6. Zero tiny values under `0.2` magnitude.

`slopeAdjustedAcceleration` comes from the rolling average of `trueAcc`.

## Expected max acceleration (`ComputeAdjustedMaxAccelSpeedSlide`)

Baseline:

- Asphalt low speed: `16.0`
- Asphalt above 400 km/h: `4.915 + speedKmh * 0.003984518249 + 0.3`

Surface overrides:

- Dirt: `9.39951 + 0.3`
- Green/grass: `9.10985 + 0.3`

## Low-speed forgiveness

When enabled, expected max acceleration can be scaled by a surface-specific factor between configured Min/Max speeds.

Current implementation applies interpolation only for:

- `minSpeed <= speed < maxSpeed`

Outside that range, it returns the unmodified expected max acceleration.

## Tier selection and swap gating

1. If turbo is active, the target tier is held at the current tier (no forced reset).
2. If not drifting and not turbo, target is `default`.
3. Otherwise, tier selection uses thresholds and hysteresis (`threshold + skidHysteresisUp` for upgrades and `threshold - skidHysteresisDown` for downgrades).
4. Swap is attempted only when target tier differs, debounce elapsed (`swapDebounceMs`), and staged files are ready.

If any surface swap fails, current tier is kept for retry.
