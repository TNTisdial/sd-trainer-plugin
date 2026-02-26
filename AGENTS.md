# Rules

- AngelScript: never use `&inout` with primitives (`bool`, `int`, `uint64`, `float`, etc.); use `&in`/`&out` or return values.

# Build `.op` Package

- Build `SD-Trainer-Plugin.op` from a zip, then rename `.zip` -> `.op`.
- Include only runtime files:
  - `info.toml`
  - `SkidRuntime.as`
  - `SkidPhysics.as`
  - `SkidIO.as`
  - `SkidSettings.as`
  - `DDS_IMG/`
- Do **not** bundle `SkidOptions/` in the `.op` (it is distributed via GitHub).
- Exclude docs/repo metadata (`docs/`, `.git/`, release notes, etc.).

```bash
rm -f "SD-Trainer-Plugin.op" "SD-Trainer-Plugin.zip" && zip -r "SD-Trainer-Plugin.zip" "info.toml" "SkidRuntime.as" "SkidPhysics.as" "SkidIO.as" "SkidSettings.as" "DDS_IMG" && mv "SD-Trainer-Plugin.zip" "SD-Trainer-Plugin.op"
```

- Verify package contents before release:

```bash
unzip -l "SD-Trainer-Plugin.op"
```

# Runtime Behavior

- Keep logging clear when optional external assets are missing (especially `SkidOptions/`).
- Operations should continue with safe defaults/fallbacks instead of hard-failing.
