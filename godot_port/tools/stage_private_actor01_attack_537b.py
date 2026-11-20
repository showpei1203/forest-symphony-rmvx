#!/usr/bin/env python3
"""Stage ONLY 3 authentic A52 attack atlases to an ephemeral private Godot build."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import struct
import tempfile

EXPECTED={
    "attack_body.png":"a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f",
    "attack_weapon.png":"6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b",
    "attack_fx.png":"46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c",
}

class StageError(ValueError):
    pass

def stage(sources:dict[str,Path],dest:Path,expected:dict=EXPECTED,dry_run:bool=False)->dict:
    dest=Path(dest)
    if dest.name!="ta_actor01" or dest.parent.name!="assets":
        raise StageError("staging path must end with assets/ta_actor01")
    if dest.exists():
        raise StageError("private output exists; no overwrite")
    if sources.keys()!=expected.keys():
        raise StageError("exactly three approved A52 attack inputs required")
    verified={}
    for name,sha in expected.items():
        data=Path(sources[name]).read_bytes()
        if hashlib.sha256(data).hexdigest()!=sha:
            raise StageError("A52 original SHA mismatch: "+name)
        if len(data)<24 or data[:8]!=bytes.fromhex("89504e470d0a1a0a"):
            raise StageError("not a PNG: "+name)
        if struct.unpack(">II",data[16:24])!=(256,192):
            raise StageError("not 256x192: "+name)
        verified[name]=data
    report={"schema":"fs-private-a52-attack/v1","art_status":"A52_SOURCE_ONLY",
            "source":"T-A original A52 frozen 12 frames 45 degree 3/4",
            "sha256":expected,"layers":["Body","Weapon","FX"]}
    if dry_run:
        return report
    dest.parent.mkdir(parents=True,exist_ok=True)
    temp=Path(tempfile.mkdtemp(prefix=".ta-actor-stage-",dir=dest.parent))
    try:
        for name,data in verified.items():
            (temp/name).write_bytes(data)
        (temp/"attack_source_manifest.json").write_text(json.dumps(report,indent=2)+"\n")
        os.replace(temp,dest)
    finally:
        if temp.exists():
            shutil.rmtree(temp)
    return report

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in EXPECTED:
        p.add_argument("--"+name.removesuffix(".png").replace("_","-"),type=Path,required=True)
    p.add_argument("--output",type=Path,default=Path("godot_port/assets/ta_actor01"))
    p.add_argument("--dry-run",action="store_true")
    v=p.parse_args()
    sources={name:getattr(v,name.removesuffix(".png")) for name in EXPECTED}
    try:
        r=stage(sources,v.output,dry_run=v.dry_run)
    except (StageError,OSError) as e:
        p.exit(2,"A52 original attack denied: "+str(e)+"\n")
    print(json.dumps({"ok":True,"art_status":r["art_status"],"output":str(v.output)}))
if __name__=="__main__":
    main()
