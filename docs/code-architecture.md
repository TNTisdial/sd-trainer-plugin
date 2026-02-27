# Code Architecture

This plugin is split into four runtime modules with explicit ownership.

## Module ownership

- `src/runtime/SkidRuntime.as`: plugin lifecycle and frame orchestration (`Main`, `Render`), shared runtime state, and shared logging/ID helpers.
- `src/physics/SkidPhysics.as`: acceleration sampling, drift-quality math, tier selection, and transition gates.
- `src/io/SkidIO.as`: file IO, texture discovery, staging/priming, live swaps, bundled install/fallback download, and cleanup hooks.
- `src/settings/SkidSettings.as`: all persisted settings declarations, runtime settings UI, settings change logging, and skid picker UI.

## Startup flow

1. `Main` initializes picker settings and path roots.
2. Bundled skids are installed (or downloaded as fallback).
3. Available texture lists are indexed.
4. Selected skid files are validated/corrected.
5. Required files are staged and live defaults are primed.

## Per-frame flow

1. `Render` exits early if plugin or scene/player state is unavailable.
2. `SimulationStep` updates physics-derived runtime state.
3. Drift quality ratio is computed from current acceleration model.
4. Target tier is computed and passed through lockout/persistence gates.
5. If tier changed and debounce allows, textures swap for all surfaces.
6. Game skin media is refreshed if any live texture changed.

## Settings-to-runtime data flow

- Runtime and picker settings are persisted in `src/settings/SkidSettings.as`.
- Physics and orchestration read those global settings directly each frame.
- `OnSettingsChanged` emits change logs only when debug logging is enabled.
