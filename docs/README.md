# Documentation Index

This folder contains the current technical documentation for the skid runtime plugin.

## Read first

- `../README.md`: project overview, quick setup, and file layout.

## Technical references

- `io-system.md`: startup install/staging, runtime swap behavior, and cleanup lifecycle.
- `acceleration-logic.md`: acceleration sampling, expected max acceleration formulas, and tier transitions.
- `settings-reference.md`: plugin settings, advanced visibility notes, and default values.
- `skid-picker-ui.md`: skid skin picker UI behavior and hidden persisted tier-file fields.
- `code-architecture.md`: module ownership and startup/frame data flow.

## Code map

- `SkidRuntime.as`: plugin lifecycle and frame orchestration, plus shared runtime state.
- `SkidIO.as`: texture discovery, staging/priming, live swapping, bundled install, and cleanup.
- `SkidPhysics.as`: simulation sampling, drift-quality model, forgiveness, and tier selection/gates.
- `SkidSettings.as`: persisted settings declarations, runtime settings tab, and skid picker UI.
