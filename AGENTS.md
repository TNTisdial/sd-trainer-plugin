# AngelScript Rule

- Do not use `&inout` with primitive types (`bool`, `int`, `uint64`, `float`, etc.); use `&in`/`&out` or return a value instead.

# Openplanet Package Build

- Build the plugin package as a zip archive, then rename it to `.op`.
- Include only runtime payload files and folders needed by Openplanet:
  - `info.toml`
  - `SkidRuntime.as`
  - `SkidPhysics.as`
  - `SkidIO.as`
  - `SkidSettings.as`
  - `DDS_IMG/`
  - `SkidOptions/`
- Do not include docs, `.git`, release notes, or other repo metadata in the package.
- From repo root, rebuild package with:

```bash
rm -f "SD-Trainer-Plugin.op" "SD-Trainer-Plugin.zip" && zip -r "SD-Trainer-Plugin.zip" "info.toml" "SkidRuntime.as" "SkidPhysics.as" "SkidIO.as" "SkidSettings.as" "DDS_IMG" "SkidOptions" && mv "SD-Trainer-Plugin.zip" "SD-Trainer-Plugin.op"
```

- Verify package contents before release:

```bash
unzip -l "SD-Trainer-Plugin.op"
```
