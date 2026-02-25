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
3. Fallback scans `OpenplanetNext/Plugins` for either folders or `.op` entries that expose `SkidOptions/Asphalt`, `SkidOptions/Dirt`, `SkidOptions/Grass`.
4. If `SkidOptions` cannot be resolved locally, fallback downloads core skids from GitHub tag-pinned raw URLs.
5. Install bundled `.dds` into user skid folders per surface.
6. Existing `Default.dds` is replaced by bundled `Default.dds`; other existing files are kept.
7. Scan user skid folders (`.dds` only) and sort names.
8. Auto-correct persisted High/Mid/Poor selections if files are missing (fallback to preferred/default/available).
9. Refresh runtime texture lists.
10. Stage required files for each surface: `Default.dds` plus selected High/Mid/Poor files.
11. Prime live targets with `Default.dds`.
12. Call `Media_RefreshFromDisk(EMediaType::Skins, 4)` if staging succeeded.

If required files cannot be staged/primed, runtime colored swaps remain disabled (`stagedFilesReady = false`).

## Runtime swap flow

When target tier changes and debounce passes:

1. For each surface, resolve `from` and `to` filenames for current and target tiers.
2. Ensure target staged file exists; if missing, restage from user `Skids/<Surface>/`.
3. Move current live file back into source staged slot.
4. Move target staged file into live slot.
5. If promotion fails, attempt rollback from stashed source.
6. Refresh game textures after at least one surface changed.

Tier state is only committed when all surface swaps report success.

## Cleanup behavior

On `OnDisabled` and `OnDestroyed`:

1. Delete live files for asphalt, dirt, grass.
2. Delete staged files for all known source texture names plus staged `Default.dds`.
3. Reset tier state and `stagedFilesReady`.
4. Refresh skins so Trackmania falls back to defaults.
