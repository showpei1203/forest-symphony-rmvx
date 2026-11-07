"""A09 deterministic scene SEMANTIC blueprints for two distinct FS maps.

Geometry-only Tiled-compatible authoring structure. NO pixel art or valid runtime
PAR is generated here. A source image and per-object art/mask identity are
required before the native FS renderer/exporter can accept a blueprint.
"""
from __future__ import annotations
import json, random, hashlib
from collections import deque

TILE=32
W,H=40,29
GROUND3_SHA="ddc1f21e1d23dcb8258a20baa2acb106d1c0e56683a4dc280faedc23bcd47a13"


def _object(oid,family,part,rect,role,source_ready=False,depth=None):
    x,y,w,h=rect
    assert all(type(v) is int for v in rect) and w>0 and h>0 and x>=0 and y>=0 and x+w<=W and y+h<=H
    return {"id":oid,"family":family,"part":part,"tile_rect":[x,y,w,h],
            "runtime_role":role,"source_art_sha256":None,
            "art_source_ready":source_ready,"occlusion_mask_sha256":None,
            "depth_footpoint_rule":depth}


def _touch(path, cells, radius=0):
    for px,py in path:
        for dx in range(-radius,radius+1):
            for dy in range(-radius,radius+1):
                x,y=px+dx,py+dy
                if 0<=x<W and 0<=y<H:
                    cells.add((x,y))


def _line(a,b):
    x,y=a;u,v=b
    while x != u:
        yield x,y
        x+=1 if u>x else -1
    while y != v:
        yield x,y
        y+=1 if v>y else -1
    yield x,y


def _reachable(blocked, start):
    seen={start};queue=deque([start])
    while queue:
        x,y=queue.popleft()
        for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
            p=(x+dx,y+dy)
            if 0<=p[0]<W and 0<=p[1]<H and p not in blocked and p not in seen:
                seen.add(p);queue.append(p)
    return seen


def build_scene(scene, seed):
    if scene not in ("ELF_VILLAGE","FOREST_BRIDGE"):
        raise ValueError("unknown template")
    if type(seed) is not int or not 0<=seed<=999999:
        raise ValueError("seed must be 0..999999")
    rand=random.Random(seed)
    blocked=set();routes=set();objects=[]
    terrain={"grass":"GRASS_WANG_SOURCE_REQUIRED","dirt":"PATH_WANG_SOURCE_REQUIRED","water":"WATER_WANG_SOURCE_REQUIRED",
             "bridge_deck":"BRIDGE_DECK_SOURCE_REQUIRED"}
    if scene=="ELF_VILLAGE":
        start=(20,20);end=(20,1)
        for path in (list(_line(start,(20,4))),list(_line((20,13),(11,13))),list(_line((20,14),(29,14)))):
            _touch(path,routes,1)
        for idx,r in enumerate(((5,5,9,7),(26,6,9,7))):
            objects.append(_object(f"HOUSE_{idx}_WHOLE","house_workshop","whole_building",r,"BACK_OR_STRUCTURAL"))
            objects.append(_object(f"ROOF_{idx}_EAVE","house_workshop","roof_eave",(r[0],r[1],r[2],2),"CONDITIONAL_FOREGROUND",depth="NATIVE_FOOTPOINT_PENDING"))
            x,y,w,h=r
            blocked.update((xx,yy) for xx in range(x,x+w) for yy in range(y,y+h))
        for idx,r in enumerate(((1,1,6,6),(34,1,6,6),(1,18,7,7),(32,19,8,9))):
            objects.append(_object(f"TREE_CLUSTER_{idx}","tree_large","canopy_group",r,"CONDITIONAL_FOREGROUND",depth="CANOPY_DEPTH_SOURCE_PENDING"))
        # Native roof and trunks are not equivalent. Full complete masks await art source.
    else:
        start=(4,16);end=(36,16)
        river=set((x,y) for x in range(18,22) for y in range(H))
        blocked |= river
        deck=set((x,y) for x in range(16,24) for y in range(15,18))
        blocked-=deck
        _touch(_line(start,end),routes,1)
        objects += [
            _object("BRIDGE_DECK","bridge","bridge_deck",(16,15,8,3),"GROUND_ONLY"),
            _object("BRIDGE_FAR_RAIL","bridge","far_rail",(16,14,8,1),"BACK_OR_STRUCTURAL"),
            _object("BRIDGE_NEAR_RAIL","bridge","near_rail",(16,17,8,1),"CONDITIONAL_FOREGROUND",depth="LEGAL_FOOTPOINT_PENDING"),
            _object("BRIDGE_POSTS","bridge","posts",(16,14,8,5),"STRUCTURAL_SOURCE_PENDING"),
        ]
        for idx,r in enumerate(((1,1,7,8),(29,2,8,7),(1,22,8,7),(31,22,9,7))):
            objects.append(_object(f"TREE_CLUSTER_{idx}","tree_large","canopy_group",r,"CONDITIONAL_FOREGROUND",depth="CANOPY_DEPTH_SOURCE_PENDING"))
        # River is visually grass+water-class geometry; no low/water pixels in foreground.
    decor=[]
    for idx in range(95):
        x=rand.randrange(1,W-1);y=rand.randrange(1,H-1)
        if (x,y) in blocked or (x,y) in routes: continue
        part=rand.choice(["grass_tuft","grass_tuft","flower","pebble"])
        decor.append({"id":f"LOW_{idx:03d}","family":"forest_decor","part":part,
                      "tile":[x,y],"runtime_role":"GROUND_ONLY"})
    must=[start,end]
    seen=_reachable(blocked,start)
    if not all(p in seen for p in must):
        raise ValueError("route disconnected")
    assert not any(o["part"] in ("bridge_deck","grass_tuft","flower") and o["runtime_role"]=="CONDITIONAL_FOREGROUND" for o in objects)
    return {
       "schema":"fs-a09-scene-blueprint/v1","scene_id":scene,"seed":seed,
       "canvas_px":[W*TILE,H*TILE],"tile_grid":[W,H],"source_style_ground3_sha256":GROUND3_SHA,
       "reference_role":"AUTHENTIC_FS_GROUND3_STYLE_SOURCE_ONLY",
       "spawn_tile":list(start),"exit_tile":list(end),
       "objects":objects,"low_decor_instances":decor,
       "terrain_palette_slots":terrain,
       "collision_blocked_tiles":[list(p) for p in sorted(blocked)],
       "walkable_route_tiles":[list(p) for p in sorted(routes)],
       "reachable_tile_count":len(seen),"bridge_collision_path_verified_static":all((x,16) in seen for x in range(16,24)) if scene=="FOREST_BRIDGE" else None,
       "source_object_art":"PENDING","master_image":"NOT_GENERATED","runtime_fullground":"NOT_GENERATED",
       "runtime_occlusion_par":"NOT_GENERATED","native_vx":"NOT_RUN","user_art":"PENDING","formal_seal":"NO"}


def to_tiled_object_layers(scene):
    """Tiled-compatible .tmj object layers with transparent source-role props."""
    if scene["schema"]!="fs-a09-scene-blueprint/v1":
        raise ValueError("bad blueprint")
    layers=[]
    for group in ("GROUND_ONLY","BACK_OR_STRUCTURAL","CONDITIONAL_FOREGROUND","STRUCTURAL_SOURCE_PENDING"):
        objects=[]
        for i,item in enumerate(o for o in scene["objects"] if o["runtime_role"]==group):
            x,y,w,h=item["tile_rect"]
            props=[{"name":"family_id","type":"string","value":item["family"]},
                   {"name":"part","type":"string","value":item["part"]},
                   {"name":"runtime_role","type":"string","value":item["runtime_role"]},
                   {"name":"source_status","type":"string","value":"SOURCE_ART_REQUIRED"}]
            objects.append({"id":len(objects)+1,"name":item["id"],"type":item["part"],
                            "x":x*TILE,"y":y*TILE,"width":w*TILE,"height":h*TILE,
                            "visible":True,"rotation":0,"properties":props})
        layers.append({"id":len(layers)+1,"name":group,"type":"objectgroup","visible":True,"opacity":1,"draworder":"topdown","objects":objects})
    return {"type":"map","version":"1.10","tiledversion":"1.11.2","orientation":"orthogonal",
            "renderorder":"right-down","width":W,"height":H,
            "tilewidth":TILE,"tileheight":TILE,"infinite":False,"layers":layers,"tilesets":[],
            "properties":[{"name":"FS_STATUS","type":"string","value":"GEOMETRY_BLUEPRINT_ONLY"},
                          {"name":"FS_SOURCE_STYLE_SHA256","type":"string","value":GROUND3_SHA},
                          {"name":"PIXELLAB_GENERATIONS","type":"int","value":0}]}


if __name__=="__main__":
    for scene,seed in (("ELF_VILLAGE",20261108),("FOREST_BRIDGE",20261203)):
        m=build_scene(scene,seed)
        print(json.dumps({"scene":scene,"objects":len(m["objects"]),"decor":len(m["low_decor_instances"]),
                          "reachable":m["reachable_tile_count"],"route":len(m["walkable_route_tiles"]),
                          "native":m["native_vx"],"art":m["user_art"]}))
