#!/usr/bin/env python3
"""Privately stage authentic VX UI art for Godot. Never commit PNG/ZIP to GitHub.

Use only an authorized ephemeral build workspace; source archive remains
owner-only Drive. Each original PNG is unchanged and hash checked.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import os
import shutil
import stat
import tempfile
import zipfile

ARCHIVE_SHA = "c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6"
CATEGORIES = {"Menu": "menu", "System": "system", "Windows": "windows"}
COUNT = 202
CAP_BYTES = 80 * 1024 * 1024

class UIStageError(ValueError):
    pass

def hash_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def hash_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024*1024), b""):
            h.update(block)
    return h.hexdigest()

def check_path(name: str) -> str:
    if not name or name.startswith("/") or "\\" in name or ":" in name or any(
        part in ("", ".", "..") for part in name.split("/")
    ):
        raise UIStageError("unsafe ZIP member name")
    return name

def stage(archive: Path, dest: Path, expected_sha: str = ARCHIVE_SHA, dry_run: bool = False) -> dict:
    archive, dest = Path(archive), Path(dest)
    if dest.name != "ui" or dest.parent.name != "assets":
        raise UIStageError("destination must be godot_port/assets/ui in a private, temporary workspace")
    if dest.exists():
        raise UIStageError("existing UI assets must never be overwritten")
    if hash_file(archive) != expected_sha:
        raise UIStageError("original private UI archive SHA256 mismatch")
    with zipfile.ZipFile(archive) as zipf:
        listing = {}
        total = 0
        for info in zipf.infolist():
            name = check_path(info.filename)
            if info.is_dir():
                continue
            if name in listing or stat.S_IFMT(info.external_attr >> 16) == stat.S_IFLNK:
                raise UIStageError("duplicate or symlink member")
            total += info.file_size
            if total > CAP_BYTES or len(listing) > 240:
                raise UIStageError("UI ZIP exceeds file/expanded-size limit")
            listing[name] = info
        if "fs_ui_source_manifest.json" not in listing:
            raise UIStageError("missing original UI source manifest")
        manifest = json.loads(zipf.read("fs_ui_source_manifest.json"))
        records = manifest.get("files")
        if manifest.get("schema") != "fs-original-ui-private-v1" or (
            not isinstance(records, list) or len(records) != COUNT or
            manifest.get("count") != COUNT or len(listing) != COUNT + 1
        ):
            raise UIStageError("original UI manifest schema/count mismatch")
        staged = []
        contents = {}
        for rec in records:
            path = check_path(rec["path"])
            parts = PurePosixPath(path).parts
            if (len(parts) != 3 or parts[0] != "Graphics" or
                parts[1] not in CATEGORIES or not parts[2].lower().endswith(".png")
                or path not in listing):
                raise UIStageError("unapproved UI source path")
            source = zipf.read(path)
            if (not source.startswith(bytes.fromhex("89504e470d0a1a0a")) or
                len(source) != rec["bytes"] or hash_bytes(source) != rec["sha256"]):
                raise UIStageError("source-original PNG hash/length mismatch")
            relative = f'{CATEGORIES[parts[1]]}/{parts[2]}'
            if relative in contents:
                raise UIStageError("case/path collision in private UI files")
            contents[relative] = source
            staged.append({"path": relative, "sha256": rec["sha256"],
                           "bytes": rec["bytes"], "width": rec["width"],
                           "height": rec["height"]})
        if zipf.testzip() is not None:
            raise UIStageError("private UI ZIP CRC failed")
        report = {"schema": "fs-godot-private-ui-v1", "original_archive_sha256": expected_sha,
                  "count": len(staged), "source": "FS original read-only UI",
                  "status": "ART_SOURCE_PRESENT_NOT_VISUAL_SEALED", "files": staged}
        if dry_run:
            return report
        dest.parent.mkdir(parents=True, exist_ok=True)
        tmp = Path(tempfile.mkdtemp(prefix=".ui-staging-", dir=dest.parent))
        try:
            for name, data in contents.items():
                out = tmp / name
                out.parent.mkdir(parents=True, exist_ok=True)
                out.write_bytes(data)
                if hash_file(out) != next(a["sha256"] for a in staged if a["path"]==name):
                    raise UIStageError("copied original UI PNG altered")
            (tmp/"fs_ui_import_manifest.json").write_text(
                json.dumps(report, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
            if dest.exists():
                raise UIStageError("stage output created concurrently")
            os.replace(tmp, dest)
        finally:
            if tmp.exists():
                shutil.rmtree(tmp)
        return report

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive", required=True, type=Path)
    parser.add_argument("--output", type=Path, default=Path("godot_port/assets/ui"))
    parser.add_argument("--dry-run", action="store_true")
    options = parser.parse_args()
    try:
        result = stage(options.archive, options.output, dry_run=options.dry_run)
    except (OSError, ValueError, zipfile.BadZipFile, KeyError, TypeError) as e:
        parser.exit(2, "FS UI staging DENIED: "+str(e)+"\n")
    print(json.dumps({"status":"STAGED" if not options.dry_run else "DRY_RUN",
                      "count":result["count"],"source_archive_sha256":result["original_archive_sha256"],
                      "output":str(options.output)},ensure_ascii=False))

if __name__=="__main__":
    main()
