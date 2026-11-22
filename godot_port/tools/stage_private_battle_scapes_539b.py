#!/usr/bin/env python3
"""Stage source-exact FS #264 BattleScape original files, owner-only.

Input ZIP is the original 7 assets actually found in FS project/Graphics/
Parallaxes, source hash locked. Bridge and BlueSky are absent in source and
must not be invented. No write to VX E:, no GitHub originals, no overwrite.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import tempfile
import zipfile

ARCHIVE_SHA="fc0e5f7a14dd239bdf7dd5db3a9041bcdf59616cfef71da903c2ad1657b0c76b"
SOURCE_SHA={
 "new_back00.png":"79d95fb213115561e0be4b4c37f169fdd38480ad5815cf28e1f5798ab898ca4b",
 "temp1.png":"eb77c242d1b9400eff1b96634c089cb000dcd444806388767ecd444e53c7fc29",
 "ffog.png":"5b15d19fe41c5c81834877cd6fc3211bc3c2745dca531ea53161f70bc12ec1ac",
 "new_back01.png":"658fed494341756c95bc149a979454ac5fe8cfe5d37c6b1f8ecacb7c71797829",
 "new_back02.png":"97b076e5e9486c988b2d0389a5b1dd9cff686fa223bbe11a3c9ee7c633c942b5",
 "back02.jpg":"f0871682023053dc619f351eadb638540fbc6e9da301499021e41b814ec460f4",
 "back08.jpg":"4f83c9d4806509e34477fd9804ce55495fe871ec6a02b2056643a6043075d37c"}
MISSING=["Bridge","BlueSky"]

def sha(raw:bytes)->str:return hashlib.sha256(raw).hexdigest()

def stage(archive:Path,destination:Path,expected_sha:str=ARCHIVE_SHA)->dict:
    destination=Path(destination)
    if destination.name!="battle_scapes" or destination.parent.name!="assets":
        raise ValueError("private output must be Godot assets/battle_scapes")
    if destination.exists():raise FileExistsError("private original art destination already exists")
    archive=Path(archive)
    if sha(archive.read_bytes())!=expected_sha:
        raise ValueError("original #264 seven-file archive SHA mismatch")
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None or len(z.namelist())!=8:
            raise ValueError("original seven-file ZIP CRC/count mismatch")
        if len(set(z.namelist()))!=8:
            raise ValueError("duplicate source entry")
        manifest=json.loads(z.read("fs_original_battlescape_manifest.json"))
        if manifest.get("schema")!="fs-original-battlescape-private-v1" or (
                manifest.get("section")!=264) or (
                manifest.get("missing_in_original_graphics_parallaxes")!=MISSING):
            raise ValueError("original BattleScape source manifest authority mismatch")
        records=manifest.get("files",[])
        if not isinstance(records,list) or len(records)!=7:
            raise ValueError("original BattleScape source record count mismatch")
        content={}
        for record in records:
            name=record.get("name","")
            if name not in SOURCE_SHA or name in content:
                raise ValueError("source image missing/duplicate/unknown")
            p="Graphics/Parallaxes/"+name
            if p not in z.namelist() or "\\" in p or ".." in p:
                raise ValueError("source image invalid path")
            raw=z.read(p)
            if (len(raw)!=record.get("bytes") or
                sha(raw)!=SOURCE_SHA[name] or
                record.get("sha256")!=SOURCE_SHA[name] or
                not (raw.startswith(bytes.fromhex("89504e470d0a1a0a")) if name.endswith(".png")
                     else raw.startswith(bytes.fromhex("ffd8ff")))):
                raise ValueError("original source artwork SHA/type mismatched")
            content[name]=raw
        if set(content)!=set(SOURCE_SHA):
            raise ValueError("missing original source BattleScape images")
    manifest={"schema":"fs-godot-private-battle-scapes-v1",
        "original_archive_sha256":expected_sha,"source_section":264,
        "missing_source_names":MISSING,
        "files":[{"name":name,"bytes":len(raw),"sha256":sha(raw)}
                 for name,raw in content.items()]}
    destination.parent.mkdir(parents=True,exist_ok=True)
    tmp=Path(tempfile.mkdtemp(prefix=".scapes-",dir=destination.parent))
    try:
        for name,raw in content.items():(tmp/name).write_bytes(raw)
        (tmp/"fs_battle_scapes_import_manifest.json").write_text(
            json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
        if destination.exists():raise FileExistsError("concurrent stage overwrite")
        os.replace(tmp,destination)
    finally:
        if tmp.exists():shutil.rmtree(tmp)
    return manifest

if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--archive",required=True,type=Path)
    p.add_argument("--output",type=Path,default=Path("godot_port/assets/battle_scapes"))
    args=p.parse_args()
    m=stage(args.archive,args.output)
    print(json.dumps({"files":len(m["files"]),
        "missing_not_in_original_source":m["missing_source_names"],
        "source_archive_sha256":m["original_archive_sha256"]}))
