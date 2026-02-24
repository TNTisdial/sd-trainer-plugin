# Documentation Index

This folder contains the current technical documentation for the skid runtime plugin.

## Read first

- `../README.md`: project overview, quick setup, and file layout.

## Technical references

- `io-system.md`: startup install/staging, runtime swap behavior, and cleanup lifecycle.
- `acceleration-logic.md`: acceleration sampling, expected max acceleration formulas, and tier transitions.
- `settings-reference.md`: visible plugin settings and default values.
- `skid-picker-ui.md`: skid skin picker UI behavior and hidden persisted tier-file fields.

## Code map

- `SkidRuntime.as`: constants, settings, runtime state, logging/settings helpers, and main entrypoints.
- `SkidIO.as`: texture discovery, staging/priming, live swapping, bundled install, and cleanup.
- `SkidPhysics.as`: simulation sampling, expected acceleration model, forgiveness, and tier selection.
- `SkidSettings.as`: texture picker UI and hidden persisted tier selection settings.
