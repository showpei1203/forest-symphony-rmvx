#!/usr/bin/env python3
"""R13 resource optimization: crop all source-aligned PAR objects to alpha bbox with world offsets.
Avoid 52x 1280x928 textures in VX 32-bit; use same 32px world cell semantics and no interpolation.
"""
from pathlib import Path
from PIL import Image
import json,hashlib
R=Path(__file__).resolve().parent;D=R/"R13_TILE_OCCLUSION_PAR_20261028"
reg=json.loads((D/"R13_GRID_PAR_CANDIDATE_REGISTRY.json").read_text(encoding="utf8"))
assert len(reg["objects"])==52
items=[];total_bytes=0;total_bbox_pixels=0
for obj in reg["objects"]:
 id=obj["id"]
 im=Image.open(D/(id+"_PAR.png")).convert("RGBA")
 b=im.getchannel("A").getbbox()
 if b is None:raise RuntimeError(f"EMPTY_LAYER_{id}")
 x0,y0,x1,y1=b
 cropped=im.crop(b)
 cropped.save(D/("R13_CROP_"+id+".png"),optimize=True)
 assert cropped.size==(x1-x0,y1-y0)
 size=(x1-x0)*(y1-y0)
 total_bbox_pixels+=size
 items.append({"id":id,"foot_z":obj["foot"][1],"bbox":[x0,y0,x1,y1],
    "xy":[x0,y0],"crop_filename":"R13_CROP_"+id+".png",
    "rgba_bbox_size":list(cropped.size),"alpha_area":obj["nontransparent_pixels"],
    "category":obj["category"],"source_exact":True})
data={"status":"R13_52_LAYERS_CROPPED_WORLD_OFFSETS_TECH_PASS",
 "size_master":[1280,928],"layer_count":len(items),
 "uncropped_total_virtual_bitmap_pixels":52*1280*928,
 "cropped_total_bitmap_pixels":total_bbox_pixels,
 "virtual_bitmap_memory_reduction":round(1-total_bbox_pixels/(52*1280*928),5),
 "world_display_x":"sp.x = object_bbox_left - $game_map.display_x/8",
 "world_display_y":"sp.y = object_bbox_top - $game_map.display_y/8",
 "human_art_gate_F":"HOLD",
 "objects":items}
(D/"R13_OPTIMIZED_SPRITE_MANIFEST.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding="utf8")
print("R13_CROP",json.dumps({"count":52,"full_pixels":data["uncropped_total_virtual_bitmap_pixels"],"crop_pixels":total_bbox_pixels,"memory_reduction":data["virtual_bitmap_memory_reduction"]}),flush=True)