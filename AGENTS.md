# AGENTS.md
## Rules
- **AngelScript:** Never use `&inout` with primitives (`bool`, `int`, `uint64`, `float`, etc.) — use `&in`/`&out` or return values.
## Building `.op` Package
Run from repo root:
```
python3 build_op.py
```
**Bundled files:** `info.toml`, `SkidRuntime.as`, `SkidPhysics.as`, `SkidIO.as`, `SkidSettings.as`, `DDS_IMG/`, `SkidOptions/`
**Output:** Auto-slotted, never overwrites — `SD-Trainer-Plugin.op`, `SD-Trainer-Plugin1.op`, `SD-Trainer-Plugin2.op`, …
**Branch stamping:** Non-`main`/`master` branches stamp `name` + `version` suffix in `info.toml`. Skipped on `main`/`master`.
**Flags:**
| Flag | Effect |
| `--no-branch-tag` | Skip branch stamp |
| `--force-branch-tag` | Force branch stamp |
| `--stem "SD-Trainer-Plugin-Test"` | Custom output name |
