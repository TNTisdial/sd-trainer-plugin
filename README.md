# SD-Trainer-Plugin

Openplanet plugin for Trackmania that swaps skidmark textures in real time based on drift quality.

## What it does

- Computes drift quality (`barFactor`) each frame from measured acceleration vs surface-specific expected max acceleration.
- Maps quality to tiers: `default`, `poor`, `mid`, `high`.
- Swaps skid textures across asphalt, dirt, and grass with hysteresis and debounce to reduce flicker.
- Includes a skin-picker UI for selecting tier textures per surface.

## Quick setup

1. Install plugin dependency `VehicleState`.
2. Launch Trackmania with Openplanet.
3. Open the plugin settings tab `Skid Skins` and choose textures for each tier.
4. Drive and drift; texture changes happen automatically while drifting (disabled while turbo/boosted).

## Runtime paths

- Source texture folders: `Documents/Trackmania/Skins/Stadium/Skids/Asphalt/`, `Documents/Trackmania/Skins/Stadium/Skids/Dirt/`, `Documents/Trackmania/Skins/Stadium/Skids/Grass/`
- Live ModWork targets: `Skins/Stadium/ModWork/CarFxImage/CarAsphaltMarks.dds`, `Skins/Stadium/ModWork/CarFxImage/CarGrassMarks.dds`, `Skins/Stadium/ModWork/DirtMarks.dds`

## Project layout

- `SkidRuntime.as`: plugin settings/state, startup wiring, and render-time orchestration.
- `SkidIO.as`: bundled install, staging/priming, live swap file IO, cleanup, and texture refresh.
- `SkidPhysics.as`: drift sampling, acceleration model, forgiveness, and tier selection.
- `SkidSettings.as`: settings UI for per-surface High/Mid/Poor texture selection and preview.
- `DDS_IMG/`: DDS preview helper code.
- `docs/`: detailed docs index and subsystem references.

## Documentation

- `docs/README.md` for full navigation.
- `docs/io-system.md` for staging and swap pipeline details.
- `docs/acceleration-logic.md` for drift-quality computation.
- `docs/settings-reference.md` for runtime settings and defaults.
- `docs/skid-picker-ui.md` for UI behavior and hidden persisted fields.

## Licensing notes

- `DDS_IMG/` is MIT-licensed code with its original license text at `DDS_IMG/LICENSE`.

## Authors

Thanks to the people and projects that made this possible:

- `XertroV/tm-modless-skids` (The Unlicense) for core modless skid swap reference patterns.
- `voblivion/Openplanet-IMG` (MIT) for DDS preview helper inspiration/code used in `DDS_IMG/`.
- Magpie (`SilasDo/Trackmania-Speed-Drift-Trainer-Plugin`, MIT) for speed-drift acceleration logic direction.
- Shorty for proving the concept and helping inspire this plugin's approach.
