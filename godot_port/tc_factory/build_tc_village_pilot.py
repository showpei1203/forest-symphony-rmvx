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
    left, top = max(x, box[0]), max(y, box[1])
    right, bottom = min(x+w, box[2]), min(y+h, box[3], fy - (22 if owner["type"] == "house" else 9))
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

    # D is NOT B. Occlusion is a set of semantic ROOF/CANOPY owner masks,
    # sampled from the MASTER's precise RGB. Conditionally shown by actor footpoint.
    # For this pilot, cover a REAL house and diverse standalone tree candidates.
    objs = []
    for o in scene["objects"]:
        if o.get("type") not in ("house","tree"):
            continue
        if not all(k in o for k in ("x","y","w","h","foot")):
            continue
        x,y,w,h=(int(o[k]) for k in ("x","y","w","h"))
        if x+w < CROP[0] or y+h < CROP[1] or x > CROP[2] or y > CROP[3]:
            continue
        objs.append(o)
    houses=[o for o in objs if o["type"]=="house"]
    trees=sorted((o for o in objs if o["type"]=="tree"),key=lambda o:
        (abs(int(o["foot"][0])-545)+abs(int(o["foot"][1])-320),str(o["id"])))
    chosen=houses[:1] + trees[:16]
    if not houses or len(trees)<6:
        raise ValueError("Missing actual PixelLab house/forest sample objects; stop instead of inventing.")
    union_alpha=Image.new("L",(W,H),0)
    owners=[]
    overlay_dir=out/"occlusion_owners"
    overlay_dir.mkdir(exist_ok=True)
    for i,o in enumerate(chosen):
        source_owner = source / "SOURCE_INDEPENDENT_RGBA" / str(o["filename"])
        if not source_owner.is_file() or sha(source_owner) != o["sha256"]:
            raise ValueError("Independent source owner missing or mutated: " + str(o["id"]))
        alpha=paste_owner_rgba(Image.open(source_owner).convert("RGBA"),CROP,o)
        # Alpha comes from an independent complete object. RGB comes only from MASTER.
        if not alpha.getbbox():
            continue
        mask=compose_mask_from_master(master,alpha)
        filename="owner_%02d.png"%i
        mask.save(overlay_dir/filename)
        union_alpha=ImageChops.lighter(union_alpha,alpha)
        owners.append({"id":o["id"],"type":o["type"],"foot_y":int(o["foot"][1])-CROP[1],
                       "foot_x":int(o["foot"][0])-CROP[0],"file":filename,
                       "bbox":list(alpha.getbbox()),"sha256":sha(overlay_dir/filename),
                       "occlusion_pixels":sum(alpha.histogram()[1:])})
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
    qa={
        "target":"T-C", "phase":"C1/C2 independent candidate", "art_gate":"ART_HOLD",
        "native_godot":"NOT_RUN_BY_GENERATOR",
        "pixellab_new_generation":"NOT_RUN", "pixellab_cost":None,
        "canvas":[W,H], "world_grid":[17,13], "crop":list(CROP),
        "source_stage":scene["stage"],
        "source_sha256":{k:sha(source/v) for k,v in SOURCE_IDS.items()},
        "art_delta":{"floor_flower_clusters":clusters,"flower_pixels":flower_pixels},
        "owners":{"house":len([o for o in owners if o["type"]=="house"]),
                  "tree":len([o for o in owners if o["type"]=="tree"])},
        "semantic_occlusion_count":len(owners),
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
