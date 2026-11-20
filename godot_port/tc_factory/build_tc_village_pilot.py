#!/usr/bin/env python3
"""T-C C1/C2: independent 17x13 pixel-art pilot from existing A36G PixelLab sources.

Writes images ONLY to the supplied ephemeral output directory; never to owner's PC.
Output is candidate art, not PixelLab-new-generation, not a certified map.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import random
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "experiments/route_b_25d_20261031_stage16/a36g_pixellab_r3b_20261104"
W, H = 544, 416
CROP = (256, 115, 800, 531)
SOURCE_IDS = {
    "ground": "A36G_GROUND_1280x928.png",
    "par": "A36G_PAR50_RGBA_1280x928.png",
    "manifest": "A36G_SCENE_MANIFEST.json",
}
def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def paste_owner_rgba(sprite: Image.Image, box: tuple[int,int,int,int], owner: dict) -> Image.Image:
    """Use independent source-owner alpha. RGB is sampled from the frozen MASTER."""
    x, y, w, h = (int(owner[k]) for k in ("x", "y", "w", "h"))
    if sprite.size != (w,h):
        raise ValueError("Owner sprite size mismatch: " + str(owner["id"]))
    fx, fy = map(int, owner["foot"])
    left, top = max(x, box[0]), max(y, box[1], int(owner.get("slice_y0",y)))
    right, bottom = min(x+w, box[2]), min(y+h, box[3], int(owner.get("slice_y1",y+h)), fy - (22 if owner["type"] == "house" else 9))
    alpha = Image.new("L", (W,H), 0)
    if right <= left or bottom <= top:
        return alpha
    original = sprite.getchannel("A").crop((left-x, top-y, right-x, bottom-y))
    alpha.paste(original, (left-box[0], top-box[1]))
    return alpha

def compose_mask_from_master(master: Image.Image, alpha: Image.Image) -> Image.Image:
    # The occluder must match the ORIGINAL, not the RGB of an independently recreated tree.
    return Image.merge("RGBA", (*master.split()[:3], alpha))

def build(out: Path, source: Path=SOURCE):
    out.mkdir(parents=True, exist_ok=True)
    missing = [str(source/name) for name in SOURCE_IDS.values() if not (source/name).is_file()]
    if missing:
        raise FileNotFoundError("Real historical source missing. NO synthetic substitutes: " + ", ".join(missing))
    scene = json.loads((source / SOURCE_IDS["manifest"]).read_text(encoding="utf-8"))
    if scene["canvas"] != [1280,928] or scene["grid"] != [40,29]:
        raise ValueError("Unexpected 32px source canvas or manifest.")
    original_ground = Image.open(source/SOURCE_IDS["ground"]).convert("RGB")
    original_par = Image.open(source/SOURCE_IDS["par"]).convert("RGBA")
    if original_ground.size != original_par.size or original_ground.size != (1280,928):
        raise ValueError("Source Ground/PAR geometry mismatch.")
    ground = original_ground.crop(CROP).copy()
    par = original_par.crop(CROP).copy()

    # A reversible, small authored delta: botanically clustered floor flowers and sprouts,
    # added ONLY to real green floor pixels, never the path, river or built objects.
    # No resized/bilinear image. The original A36G input bytes are immutable.
    art = ImageDraw.Draw(ground)
    rnd = random.Random(20261121)
    clusters = 0
    flower_pixels = 0
    colors = [(193,177,114), (220,203,145), (198,173,204), (234,225,177)]
    for _ in range(190):
        cx,cy = rnd.randrange(12,W-12),rnd.randrange(12,H-12)
        rgb=ground.getpixel((cx,cy))
        if not (rgb[1] >= rgb[0]*0.92 and rgb[1] > rgb[2]*1.10 and 43 < rgb[1] < 188):
            continue
        clusters += 1
        for j in range(rnd.randint(3,8)):
            x,y = cx + rnd.randint(-9,9), cy + rnd.randint(-6,6)
            if not (2 <= x < W-2 and 2 <= y < H-2):
                continue
            bg=ground.getpixel((x,y))
            if not (bg[1] >= bg[0]*0.92 and bg[1] > bg[2]*1.10):
                continue
            art.point((x,y), fill=(63,104,49))
            art.point((x-1,y+1), fill=(44,87,41))
            if j % 3 == 0:
                art.point((x,y-1), fill=colors[(clusters+j)%len(colors)])
                flower_pixels += 1

    master = Image.alpha_composite(ground.convert("RGBA"), par).convert("RGB")
    ground_path=out/"Authoring_GroundOnly.png"
    complete_path=out/"Authoring_CompletePAR.png"
    master_path=out/"MASTER.png"
    full_path=out/"Runtime_FullGround.png"
    runtime_path=out/"Runtime_OcclusionPAR.png"
    ground.save(ground_path)
    par.save(complete_path)
    master.save(master_path)
    master.save(full_path)

    # D is NOT B. Only source-verified independent alpha may be actor occlusion.
    # Most 193 former A36G tree images are PRIVATE and missing from this public repo;
    # never invent individual source masks from the flattened PAR. We derive independent
    # canopy segments from the one existing original PixelLab west-forest source instead.
    houses = [o for o in scene["objects"] if o.get("type")=="house"
              and o.get("id")=="A36G_ELF_HOUSE_AND_WORKSHOP"]
    if len(houses)!=1:
        raise ValueError("Original complete PixelLab cottage source not found.")
    house = houses[0]
    forest_file = "A36G_PIXELLAB_WEST_FOREST_R3B_ROAD_SAFE_RGBA.png"
    forest_path = source / "SOURCE_INDEPENDENT_RGBA" / forest_file
    forest = Image.open(forest_path).convert("RGBA")
    if forest.size != (464,576):
        raise ValueError("Original forest source not 464x576.")
    forest_blueprint = scene.get("forest_region_blueprint", {})
    forest_hash = forest_blueprint.get("compiled_SHA256")
    if forest_hash and sha(forest_path) != forest_hash:
        raise ValueError("Independent forest source SHA mismatch.")
    strips=[]
    # 12 ordered independently-owned bands, one original continuous source.
    # These are depth strips, NOT 12 distinct biological tree identities.
    for i in range(12):
        y0=115+(351*i)//12
        y1=115+(351*(i+1))//12
        strips.append({
            "id":"A36G_PIXELLAB_WEST_FOREST_DEPTH_%02d"%i,
            "type":"forest_group", "x":-112, "y":-110,
            "w":464,"h":576,"foot":[315,y1+9],
            "slice_y0":y0, "slice_y1":y1,
            "filename":forest_file, "source_sha256":sha(forest_path)})
    chosen=houses+strips
    union_alpha=Image.new("L",(W,H),0)
    owners=[]
    overlay_dir=out/"occlusion_owners"
    overlay_dir.mkdir(exist_ok=True)
    for i,o in enumerate(chosen):
        source_owner = source / "SOURCE_INDEPENDENT_RGBA" / str(o["filename"])
        if not source_owner.is_file():
            raise ValueError("Independent source owner missing: " + str(o["id"]))
        expected = o.get("sha256",o.get("source_sha256"))
        if expected and sha(source_owner) != expected:
            raise ValueError("Independent source owner SHA mismatch: " + str(o["id"]))
        alpha=paste_owner_rgba(Image.open(source_owner).convert("RGBA"),CROP,o)
        if not alpha.getbbox():
            continue
        mask=compose_mask_from_master(master,alpha)
        filename="owner_%02d.png"%i
        mask.save(overlay_dir/filename)
        union_alpha=ImageChops.lighter(union_alpha,alpha)
        owners.append({"id":o["id"],"type":o["type"],"foot_y":int(o["foot"][1])-CROP[1],
                       "foot_x":int(o["foot"][0])-CROP[0],"file":filename,
                       "bbox":list(alpha.getbbox()),"sha256":sha(overlay_dir/filename),
                       "source_sha256":sha(source_owner),
                       "occlusion_pixels":sum(alpha.histogram()[1:])})
    if len(owners)<7 or not any(o["type"]=="house" for o in owners):
        raise ValueError("Independent house/canopy masks insufficient for a complete pilot.")
    runtime=compose_mask_from_master(master,union_alpha)
    runtime.save(runtime_path)
    if not owners:
        raise ValueError("No occlusion objects!")
    # STATIC registration QA: four images share the same integer XY / RGB source.
    recomposed=Image.alpha_composite(ground.convert("RGBA"),par).convert("RGB")
    if ImageChops.difference(recomposed,master).getbbox() is not None:
        raise AssertionError("Ground + PAR does not reconstruct MASTER")
    if ImageChops.difference(master,Image.open(full_path).convert("RGB")).getbbox():
        raise AssertionError("RuntimeFullGround is not exact MASTER")
    if sum(runtime.getchannel("A").histogram()[1:]) >= sum(par.getchannel("A").histogram()[1:]):
        raise AssertionError("Occlusion PAR incorrectly covers entire CompletePAR")
    if sum(runtime.getchannel("A").histogram()[1:]) == 0:
        raise AssertionError("No actual canopy/roof occlusion")
    # Original A36G authored cottage footprint, NOT a guessed 1x image rectangle.
    house_rect=house.get("blocking_footprint_px")
    if not (isinstance(house_rect,list) and len(house_rect)==4):
        raise ValueError("PixelLab cottage footprint absent; no fabricated collision.")
    x0,y0,x1,y1=map(int,house_rect)
    if not (x0<x1 and y0<y1):
        raise ValueError("Invalid source cottage collision footprint.")
    collider={"id":str(house["id"]),"type":"house_facade","bbox":[x0-CROP[0],y0-CROP[1],x1-CROP[0],y1-CROP[1]],
              "source_manifest_sha256":sha(source/SOURCE_IDS["manifest"])}
    collision={"colliders":[collider],"source":"A36G original blocking_footprint_px",
               "native_gate":"PENDING_GODOT_REAL_PHYSICS", "forest_collision":"HOLD_PRIVATE_TREE_ROOT_SOURCES"}
    (out/"TC_PILOT_COLLISION.json").write_text(json.dumps(collision,ensure_ascii=False,indent=2),encoding="utf8")
    qa={
        "target":"T-C", "phase":"C1/C2 independent candidate", "art_gate":"ART_HOLD",
        "native_godot":"NOT_RUN_BY_GENERATOR",
        "pixellab_new_generation":"NOT_RUN", "pixellab_cost":None,
        "canvas":[W,H], "world_grid":[17,13], "crop":list(CROP),
        "source_stage":scene["stage"],
        "source_sha256":{k:sha(source/v) for k,v in SOURCE_IDS.items()},
        "art_delta":{"floor_flower_clusters":clusters,"flower_pixels":flower_pixels},
        "owners":{"house":len([o for o in owners if o["type"]=="house"]),
                  "tree":0, "independent_forest_depth_strips":len([o for o in owners if o["type"]=="forest_group"])},
        "source_inventory_warning":"193 historical tree identities are present in the original PAR/manifest but their independent alpha PNGs are private and unavailable in this public worktree. Do not infer individual tree occlusion owners.",
        "semantic_occlusion_count":len(owners),
        "candidate_physics_colliders":{"verified_source_house":1,"tree_root":0},
        "image_sha256":{p.name:sha(p) for p in (master_path,ground_path,complete_path,full_path,runtime_path)},
        "source_registration":"STATIC_PASS_RECOMPOSE_RGB_IDENTICAL",
        "known_failure":"Source-independent alpha verified; roof/canopy occlusion correctness still requires native actor/1x and art approval.",
        "excluded":"No transfers, save/load, gameplay or NAV refactor."
    }
    (out/"TC_PILOT_SOURCE_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
    (out/"TC_PILOT_OCCLUSION_OWNERS.json").write_text(json.dumps(owners,ensure_ascii=False,indent=2),encoding="utf8")
    print(json.dumps(qa,ensure_ascii=False,indent=2))
    return qa

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--out",type=Path,required=True)
    parser.add_argument("--source",type=Path,default=SOURCE)
    args=parser.parse_args()
    build(args.out,args.source)
