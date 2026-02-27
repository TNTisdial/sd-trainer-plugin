# Acceleration and Tier Logic

## Drift quality ratio

Each frame, the plugin computes:

`driftQualityRatio = numerator / denominator`

Where:

- `numerator` is normally `slopeAdjustedAcceleration`.
- If turbo is active and `Allow Live Grading During Boost` is enabled, `numerator` becomes `slopeAdjustedAcceleration - boostBaselineAccel`.
- `denominator` starts as `adjustedMaxAccelSpeedSlide`.
- If boost live grading is enabled, denominator is scaled by `Boost Headroom Scale`.
- A slope bias is then applied to the ratio using:
  - `Uphill Slope Leniency` (ratio bonus uphill)
  - `Downhill Slope Strictness` (ratio penalty downhill)

Then clamps to `[-1.0, 1.0]`.

This ratio (`driftQualityRatio`) feeds target tier selection: `default`, `poor`, `mid`, `high`.
Final swaps are then filtered by runtime gates (surface stability, lockout/persistence, debounce, and staging readiness).

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

Implementation note: this means speeds below `minSpeed` are also currently unmodified (forgiveness is not hard-clamped to full factor below min).

## Tier selection and swap gating

1. Surface material is stabilized first: a detected surface must persist for `Surface Stability Frames` before becoming the active grading surface.
2. If turbo is active and `Allow Live Grading During Boost` is disabled, the target tier is held at current tier.
3. If not drifting, target is `default`.
4. Otherwise, tier selection uses per-surface thresholds and hysteresis (`threshold + skidHysteresisUp` for upgrades and `threshold - skidHysteresisDown` for downgrades).
5. Landing lockout can block upgrades for `Landing Lockout (ms)` after landing.
6. Persistence gate requires consecutive frames before upgrades/downgrades are accepted (`Promotion Persistence Frames` / `Downgrade Persistence Frames`).
7. For upgrades, persistence requirement can be extended by post-landing and post-boost spike guards (`Impact Extra Promotion Frames`, `Boost Extra Promotion Frames`).
8. Swap is attempted only for the active surface when target tier differs and staged files are ready.
9. Debounce is enforced per surface (`Swap Debounce (ms)`), except during `Surface Transition Grace (ms)` after stable surface changes.

If active-surface swap fails, that surface keeps its previous tier for retry.

## Boost baseline behavior

- On boost start, baseline state is reset.
- While boosted and not drifting, baseline acceleration is updated with an EMA controlled by `Boost Baseline Follow Rate`.
- If boost live grading is active and baseline is not ready when ratio computation runs, baseline is initialized from the current slope-adjusted acceleration.
- While drifting, baseline is held, so grading reflects acceleration above boost-only expectation.
