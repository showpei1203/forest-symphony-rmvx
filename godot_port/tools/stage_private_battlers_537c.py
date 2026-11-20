#!/usr/bin/env python3
"""Privately stage EXACT original FS VX Battlers into an isolated Godot checkout.

The original E: FS project remains read-only. Archive is owner-only Google
Drive, NEVER GitHub. Refuses hash mismatch, traversal, duplicates, overwrite.
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

ARCHIVE_SHA="4d2f629ea643187d2b96999798214c1fdf75a1ec969df1c29561bf7bfa1ee9e3"
EXPECTED_COUNT=167
MAX_RAW_BYTES=12*1024*1024

class ArtGateError(ValueError):
    pass

def sha256_bytes(data:bytes)->str:
    return hashlib.sha256(data).hexdigest()

def sha256_file(path:Path)->str:
    h=hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda:f.read(1024*1024),b""):
            h.update(chunk)
    return h.hexdigest()

def valid_name(path:str)->bool:
    if not path or "\\" in path or ":" in path or path.startswith("/"):
        return False
    return all(part not in ("",".","..") for part in path.split("/"))

def stage(archive:Path,dest:Path,archive_sha:str=ARCHIVE_SHA,
        dry_run:bool=False)->dict:
    archive,dest=Path(archive),Path(dest)
    if dest.name!="battlers" or dest.parent.name!="assets":
        raise ArtGateError("private destination must end with assets/battlers")
    if dest.exists():
        raise ArtGateError("source art already staged; refuse to overwrite")
    if sha256_file(archive)!=archive_sha:
        raise ArtGateError("owner-private archive SHA256 mismatch")
    with zipfile.ZipFile(archive,"r") as z:
        entries={}
        expanded=0
        for info in z.infolist():
            name=info.filename
            if not valid_name(name) or name in entries:
                raise ArtGateError("unsafe or duplicate source path")
            if info.is_dir() or stat.S_IFMT(info.external_attr>>16)==stat.S_IFLNK:
                raise ArtGateError("directory/symlink disallowed in source ZIP")
            expanded+=info.file_size
            if expanded>MAX_RAW_BYTES or len(entries)>EXPECTED_COUNT+1:
                raise ArtGateError("Battlers archive exceeds safe bounds")
            entries[name]=info
        manifest_name="fs_battlers_source_manifest.json"
        if manifest_name not in entries:
            raise ArtGateError("source manifest missing")
        manifest=json.loads(z.read(manifest_name))
        records=manifest.get("files")
        if (manifest.get("schema")!="fs-original-battlers-private-v1" or
            manifest.get("count")!=EXPECTED_COUNT or
            not isinstance(records,list) or len(records)!=EXPECTED_COUNT or
            len(entries)!=EXPECTED_COUNT+1):
            raise ArtGateError("167-file source manifest authority mismatch")
        by_path={}
        binary={}
        for record in records:
            if not isinstance(record,dict):
                raise ArtGateError("invalid source row")
            path=record.get("path","")
            if not isinstance(path,str) or not valid_name(path):
                raise ArtGateError("invalid image path")
            parts=PurePosixPath(path).parts
            if (len(parts)!=3 or parts[:2]!=("Graphics","Battlers") or
                not parts[2].endswith(".png") or path not in entries):
                raise ArtGateError("non-Battler image or missing source")
            source=z.read(path)
            if (source[:8]!=bytes.fromhex("89504e470d0a1a0a") or
                sha256_bytes(source)!=record.get("sha256") or
                len(source)!=record.get("bytes")):
                raise ArtGateError("source original PNG SHA/byte mismatch")
            import struct
            if tuple(struct.unpack(">II",source[16:24]))!=(
                    record.get("width"),record.get("height")):
                raise ArtGateError("source original dimensions mismatch")
            fname=parts[2]
            if fname in binary:
                raise ArtGateError("source filename collision")
            binary[fname]=source
            by_path[fname]=dict(name=fname,sha256=record["sha256"],
                                bytes=len(source),width=record["width"],
                                height=record["height"])
        if z.testzip() is not None:
            raise ArtGateError("original ZIP CRC failed")
        exported={"schema":"fs-godot-private-battlers-v1",
                  "original_archive_sha256":archive_sha,
                  "source_count":EXPECTED_COUNT,
                  "source":"FS project/Graphics/Battlers (read-only)",
                  "files":list(by_path.values()),"status":"SOURCE_PRESENT_ART_HOLD"}
    if dry_run:
        return exported
    dest.parent.mkdir(parents=True,exist_ok=True)
    tmp=Path(tempfile.mkdtemp(prefix=".battlers-stage-",dir=dest.parent))
    try:
        for name,raw in binary.items():
            (tmp/name).write_bytes(raw)
            if sha256_file(tmp/name)!=by_path[name]["sha256"]:
                raise ArtGateError("staged PNG mutated")
        (tmp/"fs_battlers_import_manifest.json").write_text(
            json.dumps(exported,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
        if dest.exists():
            raise ArtGateError("concurrent overwrite refused")
        os.replace(tmp,dest)
    finally:
        if tmp.exists():
            shutil.rmtree(tmp)
    return exported

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--archive",type=Path,required=True)
    p.add_argument("--output",type=Path,default=Path("godot_port/assets/battlers"))
    p.add_argument("--dry-run",action="store_true")
    a=p.parse_args()
    try:
        result=stage(a.archive,a.output,dry_run=a.dry_run)
    except (ArtGateError,OSError,ValueError,KeyError,zipfile.BadZipFile,TypeError) as e:
        p.exit(2,"FS original Battler stage DENIED: "+str(e)+"\n")
    print(json.dumps({"source_count":result["source_count"],
        "archive_sha256":result["original_archive_sha256"],
        "status":"DRY_RUN" if a.dry_run else "STAGED_SOURCE_ONLY",
        "output":str(a.output)},ensure_ascii=False))
if __name__=="__main__":
    main()
