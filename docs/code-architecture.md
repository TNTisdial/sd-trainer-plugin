# Code Architecture

This plugin is split into four domains with explicit ownership.

## Module ownership

- Runtime domain:
  - `src/runtime/SkidRuntime.as`: shared enums and runtime state.
  - `src/runtime/SkidRuntimeLifecycle.as`: lifecycle entry points (`Main`, `Render`) and startup bootstrap.
  - `src/runtime/SkidRuntimeHelpers.as`: helper utilities and per-surface state accessors.
- Physics domain:
  - `src/physics/SkidPhysics.as`: core acceleration math and drift-quality ratio.
  - `src/physics/SkidPhysicsSimulation.as`: simulation sampling and frame-derived state updates.
  - `src/physics/SkidPhysicsTiering.as`: tier ranking, thresholds, hysteresis, and gates.
- IO domain:
  - `src/io/SkidIO.as`: path mapping, texture list indexing, and core IO helpers.
  - `src/io/IOBundledInstall.as`: bundled install and remote fallback download.
  - `src/io/IOStagingSwap.as`: staging/priming and live swap mechanics.
  - `src/io/IOCleanup.as`: disable/destroy cleanup paths.
- Settings domain:
  - `src/settings/SkidSettings.as`: persisted settings declarations.
  - `src/settings/SettingsGeneralUI.as`: General/Runtime tabs and rebuild/reset actions.
  - `src/settings/SettingsSkidPickerUI.as`: skid picker UI and option scanning/validation.
  - `src/settings/SettingsProfiles.as`: profile serialization and load/save flows.
  - `src/settings/SettingsTracking.as`: debug-gated settings change logging.

## Startup flow

1. `Main` initializes picker settings and path roots.
2. Bundled skids are installed (or downloaded as fallback).
3. Picker option lists are scanned from user skid folders.
4. Persisted selected skid files are validated/corrected.
5. Runtime source texture lists are refreshed.
6. Required files are staged and live defaults are primed.

The startup scan/index steps intentionally maintain two lists: picker option lists (UI-facing) and runtime source texture lists (swap/staging-facing).

## Per-frame flow

1. `Render` exits early if plugin or scene/player state is unavailable.
2. `SimulationStep` updates physics-derived runtime state.
3. Stable active surface is used to compute expected acceleration and ratio.
4. Target tier is computed and passed through lockout/persistence gates.
5. If tier changed, swap is attempted for the active stable surface only.
6. Swap debounce applies per surface, with optional transition-grace bypass after surface changes.
7. Game skin media is refreshed if that surface's live texture changed.

## Settings-to-runtime data flow

- Runtime and picker settings are persisted in `src/settings/SkidSettings.as`.
- Physics and orchestration read those global settings directly each frame.
- `OnSettingsChanged` emits change logs only when debug logging is enabled.

## Re-entry and cleanup lifecycle

- Startup bootstrap is used at plugin startup and is also re-run by:
  - General action: `Repopulate Skids (Startup Rebuild)`.
  - Runtime profile load flow after applying profile values.
- Cleanup hooks on `OnDisabled`/`OnDestroyed` clear live and staged files, reset swap state, and refresh skins.
