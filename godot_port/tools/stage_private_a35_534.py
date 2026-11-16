#!/usr/bin/env python3
"""Stage the owner-only A35 R8 R3 Godot village in a separate project namespace.

No private PNG, RVData, ZIP, or derived art may be committed to GitHub.
The exact Drive owner-only source archive is an input, never a download URL.
This tool only stages on an authorized ephemeral QA/build workspace.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import tempfile
import zipfile

ARCHIVE_SHA = "1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830"
GROUND_SHA = "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
SCENE = "scenes/a35_r8_r3_grove_balance_scene.tscn"
GROUND = "private_assets/ground_only.png"
DIRECTORIES = frozenset(("addons", "assets", "data", "private_assets", "resources", "scenes", "scripts"))
TEXT_SUFFIXES = frozenset((".gd", ".gdshader", ".tscn", ".tres", ".json", ".cfg"))
MAX_FILES = 1500
MAX_UNCOMPRESSED = 650 * 1024 * 1024

class PrivateStageError(ValueError):
    pass

def digest_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()

def _checked_name(raw: str) -> PurePosixPath:
    if not raw or raw.startswith("/") or "\\" in raw:
        raise PrivateStageError("unsafe ZIP path")
    posix = PurePosixPath(raw)
    if any(p in ("..", ".", "") or ":" in p for p in raw.split("/") if p):
        raise PrivateStageError("unsafe ZIP traversal or drive")
    if ".." in posix.parts:
        raise PrivateStageError("unsafe ZIP traversal")
    return posix

def _select_project(entries: dict[str, zipfile.ZipInfo]) -> str:
    prefixes = []
    for name in entries:
        if name == "project.godot" or name.endswith("/project.godot"):
            prefix = name[:-len("project.godot")]
            if prefix + SCENE in entries and prefix + GROUND in entries:
                prefixes.append(prefix)
    if len(prefixes) != 1:
        raise PrivateStageError("expected exactly one complete A35 R8 R3 Godot project")
    return prefixes[0]

def stage_archive(
    archive: Path,
    destination: Path,
    expected_archive_sha: str = ARCHIVE_SHA,
    expected_ground_sha: str = GROUND_SHA,
    dry_run: bool = False,
) -> dict:
    archive = Path(archive)
    destination = Path(destination)
    if destination.name != "a35_private":
        raise PrivateStageError("output must be an isolated a35_private directory")
    if destination.exists():
        raise PrivateStageError("output exists; refuse replacement of any prior A35 stage")
    if not archive.is_file():
        raise PrivateStageError("private archive not found")
    archive_sha = digest_file(archive)
    if archive_sha != expected_archive_sha:
        raise PrivateStageError("A35 source ZIP SHA256 mismatch; no files staged")
    with zipfile.ZipFile(archive) as zf:
        entries = {}
        total = 0
        for info in zf.infolist():
            path = _checked_name(info.filename.rstrip("/"))
            if info.is_dir():
                continue
            mode = info.external_attr >> 16
            if stat.S_IFMT(mode) == stat.S_IFLNK:
                raise PrivateStageError("ZIP symlink rejected")
            if info.filename in entries:
                raise PrivateStageError("duplicate ZIP entry")
            total += info.file_size
            if total > MAX_UNCOMPRESSED or len(entries) >= MAX_FILES:
                raise PrivateStageError("archive exceeds file or expanded size limit")
            entries[str(path)] = info
        prefix = _select_project(entries)
        allowed = {}
        for name, info in entries.items():
            if not name.startswith(prefix):
                continue
            relative = name[len(prefix):]
            parts = PurePosixPath(relative).parts
            if parts and parts[0] in DIRECTORIES:
                allowed[relative] = info
        with zf.open(entries[prefix + GROUND]) as stream:
            source_ground_sha = hashlib.sha256(stream.read()).hexdigest()
        if source_ground_sha != expected_ground_sha:
            raise PrivateStageError("original Ground-only PNG hash mismatch")
        if not allowed or SCENE not in allowed or GROUND not in allowed:
            raise PrivateStageError("missing required A35 scene/ground in allowable project")
        bad = zf.testzip()
        if bad is not None:
            raise PrivateStageError("archive CRC failure")
        report = {
            "schema": "fs-private-a35-village-stage/v1",
            "map_id": "FS_01_VILLAGE",
            "art": "HOLD",
            "source_archive_sha256": archive_sha,
            "ground_sha256": source_ground_sha,
            "scene": "res://a35_private/" + SCENE,
            "files_staged": len(allowed),
            "source_project_prefix": prefix,
        }
        if dry_run:
            return report
        destination.parent.mkdir(parents=True, exist_ok=True)
        tmp = Path(tempfile.mkdtemp(prefix=".a35-stage-", dir=destination.parent))
        try:
            for relative, info in allowed.items():
                target = tmp.joinpath(*PurePosixPath(relative).parts)
                target.parent.mkdir(parents=True, exist_ok=True)
                with zf.open(info) as src:
                    if target.suffix.lower() in TEXT_SUFFIXES:
                        body = src.read()
                        try:
                            contents = body.decode("utf-8")
                        except UnicodeDecodeError as exc:
                            raise PrivateStageError("non UTF-8 Godot resource: " + relative) from exc
                        contents = contents.replace("res://", "res://a35_private/")
                        target.write_text(contents, encoding="utf-8")
                    else:
                        with target.open("wb") as out:
                            shutil.copyfileobj(src, out, length=1024 * 1024)
            (tmp / "fs_private_a35_manifest.json").write_text(
                json.dumps(report, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            if digest_file(tmp / GROUND) != expected_ground_sha:
                raise PrivateStageError("post-stage Ground SHA mismatch")
            if destination.exists():
                raise PrivateStageError("destination appeared during staging")
            os.replace(tmp, destination)
        finally:
            if tmp.exists():
                shutil.rmtree(tmp)
        return report

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", type=Path, required=True,
                        help="Owner-only SHA-locked A35 R8 R3 QA ZIP, already obtained privately")
    parser.add_argument("--output", type=Path,
                        default=Path("godot_port/a35_private"))
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    try:
        result = stage_archive(args.archive, args.output, dry_run=args.dry_run)
    except (PrivateStageError, zipfile.BadZipFile, OSError) as exc:
        parser.exit(2, "A35 import DENIED: " + str(exc) + "\n")
    print(json.dumps(result, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
