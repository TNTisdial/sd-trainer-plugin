# Skid Picker UI

`src/settings/SkidSettings.as` provides both:

- menu window: `Skid Skin Picker`
- settings tab: `Skid Skins`

## Purpose

Select High/Mid/Poor texture files independently for:

- Asphalt
- Dirt
- Grass

Selections are persisted as hidden settings:

- `S_AsphaltHighSkidFile`, `S_AsphaltMidSkidFile`, `S_AsphaltPoorSkidFile`
- `S_DirtHighSkidFile`, `S_DirtMidSkidFile`, `S_DirtPoorSkidFile`
- `S_GrassHighSkidFile`, `S_GrassMidSkidFile`, `S_GrassPoorSkidFile`

## Folder scan behavior

Folders are scanned from user game paths:

- `Skins/Stadium/Skids/Asphalt/`
- `Skins/Stadium/Skids/Dirt/`
- `Skins/Stadium/Skids/Grass/`

Only `.dds` files are listed (case-insensitive extension match). Scanning is non-recursive (top-level files in each surface folder only). Names are sorted and shown without `.dds` in combo labels.

On startup, if a persisted selected filename is missing, the plugin auto-corrects per tier to:

1. currently selected file (if present)
2. preferred default tier file for that surface
3. `Default.dds`
4. first available file

This avoids startup staging failures when a previously selected skin was removed.

Auto-correct is run during startup/bootstrap flows (plugin startup, startup rebuild, and profile load), not by the picker `Refresh` button.

## Startup population of options

Before folder scans, startup attempts to install bundled `SkidOptions` into user skid folders.
If packaged `SkidOptions` are not accessible in the running install, missing core files are downloaded from tag-pinned GitHub fallback URLs.

## UI controls

Per surface:

- Tier dropdowns for High/Mid/Poor
- Previous/next arrow buttons for quick cycling
- `Refresh` button to rescan folders (`RefreshAllSkidOptionLists` only)
- folder button to open the source folder in the OS file explorer (available when at least one `.dds` exists)
- collapsible preview section with High/Mid/Poor preview tabs
- preview states may show `Loading preview...` or `File not found: <path>` before/if a texture can be loaded

If no `.dds` files are found, the panel displays the expected folder path and only the `Refresh` button.

## Selection-to-runtime flow

1. Picker selection writes per-surface tier filenames (`S_*SkidFile` hidden settings).
2. Runtime maps target tier to selected filename for the active surface.
3. Swap logic promotes staged files into live ModWork targets (and can restage missing targets from source folders).
4. If startup staging/priming is not ready, runtime colored swaps are skipped until rebuild/init succeeds.
