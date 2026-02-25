# Skid Picker UI

`SkidSettings.as` provides both:

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

Only `.dds` files are listed. Names are sorted and shown without `.dds` in combo labels.

On startup, if a persisted selected filename is missing, the plugin auto-corrects per tier to:

1. currently selected file (if present)
2. preferred default tier file for that surface
3. `Default.dds`
4. first available file

This avoids startup staging failures when a previously selected skin was removed.

## UI controls

Per surface:

- Tier dropdowns for High/Mid/Poor
- Previous/next arrow buttons for quick cycling
- `Refresh` button to rescan folders
- folder button to open the source folder in the OS file explorer
- preview tabs (High/Mid/Poor) with DDS texture previews

If no `.dds` files are found, the panel displays the expected folder path.
