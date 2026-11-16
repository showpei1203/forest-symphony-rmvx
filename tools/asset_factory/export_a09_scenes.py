"""Export two FS A09 scene-authoring blueprint JSON/TMJ packages to cloud runner.

This DOES NOT generate Ground/PAR images and does not claim art-ready masks.
The exported geometry is a repeatable starting point for semantic object kits.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path

from tools.asset_factory.scene_blueprint import build_scene, to_tiled_object_layers

SCENES=(("ELF_VILLAGE",20261108),("FOREST_BRIDGE",20261203))


def _write(path: Path, obj: dict) -> str:
    data=json.dumps(obj,indent=2,ensure_ascii=False,sort_keys=True).encode("utf-8")+b"\n"
    path.write_bytes(data)
    return hashlib.sha256(data).hexdigest()


def export_blueprint_package(output_dir: Path) -> dict:
    output_dir.mkdir(parents=True,exist_ok=True)
    sha={}
    stats=[]
    for scene,seed in SCENES:
        blueprint=build_scene(scene,seed)
        tiled=to_tiled_object_layers(blueprint)
        sha[scene+".json"]=_write(output_dir/(scene+".json"),blueprint)
        sha[scene+".tmj"]=_write(output_dir/(scene+".tmj"),tiled)
        stats.append({"scene":scene,"seed":seed,"objects":len(blueprint["objects"]),
                      "low_decor":len(blueprint["low_decor_instances"]),
                      "reachable_tiles":blueprint["reachable_tile_count"],
                      "new_art":False,"native":"NOT_RUN"})
    manifest={"schema":"fs-a09-scene-package/v1","grid_px":32,
              "scenes":stats,"file_sha256":sha,
              "generation_calls":0,"source_image_bytes_included":False,
              "native_game_exe":"NOT_RUN","art":"PENDING",
              "notes":"TMJ object layers only; no fake tile image, no final Ground/PAR."}
    _write(output_dir/"A09_MANIFEST.json",manifest)
    return manifest


if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--output",default="out/a09_blueprints")
    args=p.parse_args()
    r=export_blueprint_package(Path(args.output))
    print(json.dumps(r,indent=2,ensure_ascii=False))
