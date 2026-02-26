#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import tempfile
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


RUNTIME_ITEMS = [
    "info.toml",
    "SkidRuntime.as",
    "SkidPhysics.as",
    "SkidIO.as",
    "SkidSettings.as",
    "DDS_IMG",
    "SkidOptions",
]


def log(msg: str) -> None:
    print(f"[build-op] {msg}")


def sanitize_branch(branch: str) -> str:
    return re.sub(r"[^A-Za-z0-9._-]", "-", branch)


def detect_git_branch(repo_root: Path) -> str | None:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=repo_root,
            capture_output=True,
            text=True,
            check=True,
        )
    except Exception:
        return None

    branch = result.stdout.strip()
    if not branch or branch == "HEAD":
        return None
    return sanitize_branch(branch)


def should_stamp_branch(
    branch: str | None, no_branch_tag: bool, force_branch_tag: bool
) -> bool:
    if force_branch_tag:
        return branch is not None
    if no_branch_tag:
        return False
    if branch is None:
        return False
    if branch in {"main", "master"}:
        return False
    return True


def find_available_output_slot(repo_root: Path, stem: str) -> tuple[Path, Path, int]:
    slot = 0
    while True:
        suffix = "" if slot == 0 else str(slot)
        op_path = repo_root / f"{stem}{suffix}.op"
        zip_path = repo_root / f"{stem}{suffix}.zip"
        if not op_path.exists() and not zip_path.exists():
            return op_path, zip_path, slot
        slot += 1


def patch_info_toml(info_path: Path, branch_tag: str) -> None:
    text = info_path.read_text(encoding="utf-8")

    text, name_count = re.subn(
        r'(?m)^name\s*=\s*"[^"]*"\s*$',
        f'name     = "SD-Trainer-Plugin ({branch_tag})"',
        text,
        count=1,
    )
    if name_count == 0:
        raise RuntimeError("Could not find [meta] name in info.toml")

    version_match = re.search(r'(?m)^version\s*=\s*"([^"]+)"\s*$', text)
    if not version_match:
        raise RuntimeError("Could not find [meta] version in info.toml")

    base_version = version_match.group(1).split("+", 1)[0]
    text = re.sub(
        r'(?m)^version\s*=\s*"[^"]*"\s*$',
        f'version  = "{base_version}+{branch_tag}"',
        text,
        count=1,
    )

    info_path.write_text(text, encoding="utf-8")


def copy_runtime_items(repo_root: Path, stage_root: Path) -> None:
    for rel in RUNTIME_ITEMS:
        src = repo_root / rel
        dst = stage_root / rel
        if not src.exists():
            raise FileNotFoundError(f"Missing required runtime path: {rel}")
        if src.is_dir():
            shutil.copytree(src, dst)
        else:
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)


def build_zip_from_stage(stage_root: Path, zip_path: Path) -> int:
    files_written = 0
    with ZipFile(zip_path, "w", compression=ZIP_DEFLATED) as zf:
        for rel in RUNTIME_ITEMS:
            src = stage_root / rel
            if src.is_file():
                zf.write(src, arcname=rel)
                files_written += 1
                continue

            for child in sorted(src.rglob("*")):
                if child.is_file():
                    arcname = child.relative_to(stage_root).as_posix()
                    zf.write(child, arcname=arcname)
                    files_written += 1

    return files_written


def verify_op(op_path: Path) -> None:
    with ZipFile(op_path, "r") as zf:
        names = zf.namelist()
        top_level = sorted({name.split("/", 1)[0] for name in names if name})
        log(
            f"Verification: {len(names)} archive entries, top-level: {', '.join(top_level)}"
        )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build Openplanet .op package with safe numbering"
    )
    parser.add_argument(
        "--stem",
        default="SD-Trainer-Plugin",
        help="Output base name without number or extension (default: SD-Trainer-Plugin)",
    )
    parser.add_argument(
        "--no-branch-tag",
        action="store_true",
        help="Do not inject branch marker into staged info.toml name/version",
    )
    parser.add_argument(
        "--force-branch-tag",
        action="store_true",
        help="Always inject branch marker when a branch is detected (even on main/master)",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent
    log(f"Repo root: {repo_root}")

    op_path, zip_path, slot = find_available_output_slot(repo_root, args.stem)
    if slot == 0:
        log(f"Output slot available: {op_path.name}")
    else:
        log(f"Output slot {slot} selected: {op_path.name}")

    branch = detect_git_branch(repo_root)
    stamp_branch = should_stamp_branch(
        branch, args.no_branch_tag, args.force_branch_tag
    )

    if args.no_branch_tag:
        log("Branch tagging disabled via --no-branch-tag")
    elif args.force_branch_tag and branch:
        log(f"Branch tag forced: {branch}")
    elif branch in {"main", "master"}:
        log(f"Branch tagging skipped on release branch: {branch}")
    elif branch:
        log(f"Branch tag detected: {branch}")
    else:
        log("No branch tag found (git unavailable or detached HEAD)")

    with tempfile.TemporaryDirectory(prefix=".opbuild-", dir=repo_root) as tmp_dir:
        stage_root = Path(tmp_dir)
        log(f"Staging runtime files in: {stage_root.name}")
        copy_runtime_items(repo_root, stage_root)

        if stamp_branch and branch:
            patch_info_toml(stage_root / "info.toml", branch)
            log("Patched staged info.toml with branch metadata")

        file_count = build_zip_from_stage(stage_root, zip_path)
        log(f"Created zip: {zip_path.name} ({file_count} files)")

    zip_path.rename(op_path)
    size_kib = op_path.stat().st_size / 1024.0
    log(f"Renamed to: {op_path.name} ({size_kib:.1f} KiB)")

    verify_op(op_path)
    log("Done")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
