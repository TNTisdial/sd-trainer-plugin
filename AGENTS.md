# Rules

- AngelScript: never use `&inout` with primitives (`bool`, `int`, `uint64`, `float`, etc.); use `&in`/`&out` or return values.

# Building `.op` Package
- Use `python3 build_op.py` from repo root.
- The builder includes only runtime files:
  - `info.toml`
  - `SkidRuntime.as`
  - `SkidPhysics.as`
  - `SkidIO.as`
  - `SkidSettings.as`
  - `DDS_IMG/`
  - `SkidOptions/`
- It never overwrites prior builds. Output naming is auto-slotted:
  - `SD-Trainer-Plugin.op`
  - `SD-Trainer-Plugin1.op`
  - `SD-Trainer-Plugin2.op`
  - ...
- It logs each step (slot choice, staging, archive creation, verification) so agents can decide whether to delete old artifacts.
- By default it stamps branch metadata inside packaged `info.toml` (`name` + `version` suffix) on non-release branches.
- On `main`/`master`, it skips branch stamping by default (release-friendly).
- Optional flags:
  - `python3 build_op.py --no-branch-tag`
  - `python3 build_op.py --force-branch-tag`
  - `python3 build_op.py --stem "SD-Trainer-Plugin-Test"`
