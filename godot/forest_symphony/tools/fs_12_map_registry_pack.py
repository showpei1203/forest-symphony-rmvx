#!/usr/bin/env python3
"""Private compact FS WORLD 12 registry contract overlay for Godot R8 R3.

This ZIP is NOT a standalone Godot project. Apply its data/scripts/tests to
sealed owner-only R8 R3 village project. FS_01_MAZE R7 large forest is a
separate owner-only full project, referenced by its catalog source path.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
def sha(data):return hashlib.sha256(data).hexdigest()
def seal(village:Path,docs:Path,log:Path,out:Path):
    files={}
    for rel in (
        "data/fs_12_map_catalog.json",
        "scripts/fs_world_map_registry.gd",
        "tests/test_fs_12_map_catalog_native.gd"
    ):files[rel]=(village/rel).read_bytes()
    catalog=json.loads(files["data/fs_12_map_catalog.json"])
    if len(catalog["biomes"])!=6 or len(catalog["maps"])!=12:
        raise ValueError("12-map count contract failed")
    scene_ids=[m["canonical_scene_id"] for m in catalog["maps"]]
    if scene_ids!=[f"FS_{n:02d}_{role}" for n in range(1,7) for role in ("MAZE","VILLAGE")]:
        raise ValueError("Original canonical FS IDs mismatch")
    native=log.read_bytes()
    if b"FS 12-MAP GODOT NATIVE PASS" not in native:
        raise RuntimeError("Actual Godot native test not passed")
    files["qa/FS_12MAP_NATIVE_STDOUT.log"]=native
    for name in (
        "FS_12_MAP_ACTIVE_MASTER_20261116.md",
        "FS_12_MAP_FACTORY_V1_NATIVE_HANDOFF_20261116.md",
        "FS_12_MAP_FACTORY_V1_FAILURE_LOG_20261116.md"
    ):
        files["docs/"+name]=(docs/name).read_bytes()
    summary={
      "phase":"FS 12 map production world catalog/route authority V1",
      "biomes":6,"dungeon_slots":6,"village_slots":6,
      "FS_01_VILLAGE":"R8 R3 Godot 4.7.2 native source+nav+GPU PASS ART HOLD",
      "FS_01_MAZE":"A36C R7 reconciled private full Godot source+GPU PASS, nav/river/art HOLD",
      "other_10":"PLANNED",
      "production_seals":0,
      "source_test":"Godot 4.7.2 actually executed PASS",
      "standalone_project":False,
      "private_full_village":"https://drive.google.com/file/d/1uGa7waQ-SwSSWVcgGUnbmlI7PjRaEKC2/view",
      "private_full_forest":"https://drive.google.com/file/d/1vCUPIBc6Yv3vtc3Wy7cDRBvI8Y65-9wf/view",
      "art":"HOLD"
    }
    files["qa/FS_12MAP_FACTORY_RELEASE.json"]=(json.dumps(summary,ensure_ascii=False,indent=2)+"\n").encode()
    files["README.txt"]=(
       "FS 12-MAP CATALOG OVERLAY, NOT A STANDALONE GODOT PROJECT.\n"
       "Use original native full R8 R3 elven village source and apply data/scripts/tests.\n"
       "Use original native full FS_01_MAZE R7 forest source independently.\n"
       "No other ten maps generated or misrepresented as complete.\n"
    ).encode()
    with zipfile.ZipFile(out,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for n,b in files.items():z.writestr(n,b)
    with zipfile.ZipFile(out) as z:
        if z.testzip() is not None:raise RuntimeError("12-map registry CRC fail")
    print(json.dumps({"path":str(out),"members":len(files),"bytes":out.stat().st_size,
        "sha256":sha(out.read_bytes()),"summary":summary},ensure_ascii=False,indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    for name in ("village","docs","log","out"):p.add_argument("--"+name,required=True)
    a=p.parse_args()
    seal(Path(a.village),Path(a.docs),Path(a.log),Path(a.out))
