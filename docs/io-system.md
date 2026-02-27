# IO System

## Overview

The plugin uses user `Skids` folders as source-of-truth and `ModWork` as live runtime targets.
Swaps are done with file moves inside ModWork, not full source recopy each frame.

## Source and target folders

- Source roots: `Skins/Stadium/Skids/Asphalt`, `Skins/Stadium/Skids/Dirt`, `Skins/Stadium/Skids/Grass`
- Live targets: asphalt `Skins/Stadium/ModWork/CarFxImage/CarAsphaltMarks.dds`, grass `Skins/Stadium/ModWork/CarFxImage/CarGrassMarks.dds`, dirt `Skins/Stadium/ModWork/DirtMarks.dds`
- Staging slot pattern: `Skins/Stadium/ModWork/CarFxImage/_staged_<surface>_<filename>.dds`

Note: dirt live target is outside `CarFxImage` by engine behavior.

## Startup flow

1. Resolve bundled `SkidOptions` root.
2. Preferred source is the executing plugin source path (works for folder installs and `.op` loads where `SkidOptions` is addressable).
3. Fallback scans `IO::FromDataFolder("Plugins")` for folders/`.op` entries that expose `SkidOptions/Asphalt`, `SkidOptions/Dirt`, `SkidOptions/Grass`.
4. Plugin scan runs in two passes: preferred entries with runtime markers first, then a broader fallback pass.
5. If `SkidOptions` cannot be resolved locally, fallback downloads a core skid set from GitHub tag-pinned raw URLs.
6. Install bundled `.dds` into user skid folders per surface.
7. During packaged install, existing `Default.dds` is replaced by bundled `Default.dds`; other existing files are kept.
8. During remote fallback install, only missing files are downloaded (existing files are not replaced).
9. Scan user skid folders (`.dds` only) and sort names.
10. Auto-correct persisted High/Mid/Poor selections if files are missing (fallback to preferred/default/available).
11. Refresh runtime texture lists.
12. Stage required files for each surface: `Default.dds` plus selected High/Mid/Poor files.
13. Prime live targets with `Default.dds`.
14. Call `Media_RefreshFromDisk(EMediaType::Skins, 4)` if staging succeeded.

If required files cannot be staged/primed, runtime colored swaps remain disabled (`stagedFilesReady = false`).

This startup flow is also reused by:

- `Repopulate Skids (Startup Rebuild)` in General settings.
- Runtime settings profile load (after profile values are applied).

Remote fallback core skid set (current): `Default.dds`, `BlueFadeThicc.dds`, `GreenFadeThicc.dds`, `YellowFadeThicc.dds`, `RedFadeThicc.dds` from tag `v1.0.2`.

## Runtime swap flow

When target tier changes and debounce passes:

1. Use the active stable surface only.
2. Resolve `to` filename for target tier and read tracked live filename for `from`.
3. Ensure target staged file exists; if missing, restage from user `Skids/<Surface>/`.
4. Move current live file back into tracked source staged slot.
5. Move target staged file into that surface live slot.
6. If promotion fails, attempt rollback from stashed source and preserve tracked live filename.
7. Refresh game textures when that surface's live texture changed.

Notes:

- Tracked per-surface live filenames avoid staged-slot mismatch after partial failures.
- If `from == to` but live file is missing, runtime re-promotes the tracked file to live.
- Tier commit is per active surface swap result: success commits that surface's tier, failure keeps prior tier for retry.

## Persistence and serialization

- Per-surface High/Mid/Poor picker selections are persisted as hidden Openplanet settings fields.
- Runtime profiles persist tuning + picker state in a serialized payload blob; loading a profile reapplies fields, validates picker files, then re-runs startup rebuild.

## Cleanup behavior

On `OnDisabled` and `OnDestroyed`:

1. Delete live files for asphalt, dirt, grass.
2. Delete staged files for all known source texture names plus staged `Default.dds`.
3. Reset tier state and `stagedFilesReady`.
4. Refresh skins so Trackmania falls back to defaults.
