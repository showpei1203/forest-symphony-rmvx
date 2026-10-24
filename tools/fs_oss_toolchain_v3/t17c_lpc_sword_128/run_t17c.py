# -*- coding: utf-8 -*-
"""T17C 128-cell LPC arming sword adapter: deterministic layering, conservative anchor candidate."""
from pathlib import Path
import json, hashlib, zipfile, sys
from PIL import Image
ROOT=Path(__file__).resolve().parent
IN=ROOT/"inputs"; OUT=ROOT/"outputs"
BODY=Image.open(IN/"body_slash_64.png").convert("RGBA")
BACK=Image.open(IN/"steel_behind_128.png").convert("RGBA")
FRONT=Image.open(IN/"steel_front_128.png").convert("RGBA")
assert BODY.size==(384,256) and BACK.size==FRONT.size==(768,512)
assert (IN/"CREDITS.csv").is_file() and (IN/"ASSET_CREDITS_SELECTED.json").is_file()
credits=json.loads((IN/"ASSET_CREDITS_SELECTED.json").read_text(encoding="utf8"))
assert credits["source_commit"]=="9bf06be193b053db256b2536824af426de046aa2"
assert all("OGA-BY 3.0" in r["licenses"] for r in credits["rows"])
# Deliberate source-mode-specific interface: body native 64px inserted unscaled in 128px weapon frame.
OFF=(32,32); CW=128; CH=128; BCW=BCH=64
def make_padded(source,offset=(32,32)):
    ox,oy=offset; assert 0<=ox<=CW-BCW and 0<=oy<=CH-BCH
    surface=Image.new("RGBA",(768,512))
    for dr in range(4):
        for fc in range(6):
            patch=source.crop((fc*BCW,dr*BCH,(fc+1)*BCW,(dr+1)*BCH))
            surface.alpha_composite(patch,(fc*CW+ox,dr*CH+oy))
    return surface
P=make_padded(BODY,OFF)
SHEET=Image.alpha_composite(Image.alpha_composite(BACK,P),FRONT)
OUT.mkdir(exist_ok=True)
SHEET.save(OUT/"T17C_ARMING_STEEL_128_MASTER.png")
P.save(OUT/"T17C_BODY_64_IN_128_NO_SCALE.png")
# Strict per-cell route matches whole-sheet route bit-for-bit.
rebuild=Image.new("RGBA",SHEET.size)
cell_analysis=[]
directions=["up","left","down","right"]
border_flags=[]
for dr in range(4):
    for fc in range(6):
        rect=(fc*CW,dr*CH,(fc+1)*CW,(dr+1)*CH)
        slices=[im.crop(rect) for im in (BACK,P,FRONT)]
        merged=Image.alpha_composite(Image.alpha_composite(slices[0],slices[1]),slices[2])
        rebuild.paste(merged,(fc*CW,dr*CH))
        aw=Image.alpha_composite(slices[0],slices[2]).getchannel("A")
        border=(sum(1 for x in range(CW) if aw.getpixel((x,0)) or aw.getpixel((x,CH-1)))
                +sum(1 for y in range(1,CH-1) if aw.getpixel((0,y)) or aw.getpixel((CW-1,y))))
        border_flags.append(border)
        cell_analysis.append({"direction":directions[dr],"frame":fc,
                              "weapon_visible":aw.getbbox() is not None,"weapon_cell_edge_alpha_pixels":border,
                              "final_merged_bbox":merged.getbbox()})
    SHEET.crop((0,dr*CH,6*CW,(dr+1)*CH)).save(OUT/f"T17C_ARMING_{directions[dr]}.png")
assert rebuild.tobytes()==SHEET.tobytes(),"Atlas vs cell compositor mismatch"
# Extraction: recover original 64x64 body without scaling, interpolation or positional guessing.
recovered=Image.new("RGBA",BODY.size)
for dr in range(4):
    for fc in range(6):
        c=P.crop((fc*CW+OFF[0],dr*CH+OFF[1],fc*CW+OFF[0]+BCW,dr*CH+OFF[1]+BCH))
        recovered.paste(c,(fc*BCW,dr*BCH))
assert recovered.tobytes()==BODY.tobytes(),"Upsize embedding changed body"
# Wrong offset, 1px weapon shift, wrong order, missing back all must be detected.
px=SHEET.get_flattened_data()
diff=lambda im:sum(a!=b for a,b in zip(px,im.get_flattened_data()))
bad_offset=diff(Image.alpha_composite(Image.alpha_composite(BACK,make_padded(BODY,(33,32))),FRONT))
front_shift=Image.new("RGBA",FRONT.size)
front_shift.paste(FRONT,(1,0))
bad_shift=diff(Image.alpha_composite(Image.alpha_composite(BACK,P),front_shift))
bad_order=diff(Image.alpha_composite(Image.alpha_composite(FRONT,P),BACK))
bad_missing=diff(Image.alpha_composite(P,FRONT))
assert all(v>0 for v in (bad_offset,bad_shift,bad_order,bad_missing))
# Source window boundaries: samples with border alpha might be naturally clipped in original PNG, must report rather than invent pixels.
# Evidence PNG for human observation: alpha-checker+unscaled nearest zoom on 2 chosen frames.
rgb=Image.new("RGBA",SHEET.size,(31,38,49,255))
rgb.alpha_composite(SHEET)
rgb.save(OUT/"T17C_128_FOUR_DIRECTIONS_HUMAN_PREVIEW.png")
# Native 128 frame engine pivot contract 64,96 is provisional; artist must approve.
manifest={
 "status":"T17C_128_CELL_WEAPON_24_FRAME_STRUCTURAL_PASS_HUMAN_PENDING",
 "source_commit":credits["source_commit"],"sources":{f:(IN/f).stat().st_size for f in ["body_slash_64.png","steel_behind_128.png","steel_front_128.png"]},
 "source_credits":credits["rows"],"cell_size":[128,128],"body_native_cell_size":[64,64],"body_embedding_offset":[32,32],
 "render_scale":1,"frame_grid":[6,4],"total_frames":24,"directions":directions,"layer_order":["steel_behind_128","body_64_in_128","steel_front_128"],
 "cell_vs_sheet_rgba_identical":True,"body_extract_rgba_identical":True,
 "weapon_visible_frames":sum(c["weapon_visible"] for c in cell_analysis),
 "weapon_edge_alpha_frame_count":sum(v>0 for v in border_flags),
 "weapon_edge_alpha_pixels_total":sum(border_flags),
 "negative_tests":{"body_offset_x_plus1_diff":bad_offset,"front_shift_x_plus1_diff":bad_shift,
                   "reversed_z_diff":bad_order,"missing_behind_diff":bad_missing},
 "engine_origin_candidate":[64,96],
 "engine_origin_gate":"CANDIDATE ONLY, not verified on Godot/VX runtime; do not assume ground foot registration",
 "visual_gate":"HUMAN_PENDING: modular LPC body has no head/hair and weapon hand-grip needs human approval",
 "style_gate":"PENDING; character base and 128 weapon source render aesthetics need artist review",
 "limits":["64px original body inserted at x32 y32 native resolution, NOT 2x upscaled","Cannot derive VX/SBS hit timing from still PNG", "Original 128 weapon pixels near tile edge must be documented; no fail if source touches edge"]
}
(ROOT/"T17C_128_ARMING_WEAPON_VALIDATION.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding="utf8")
print(json.dumps({k:manifest[k] for k in ("status","total_frames","body_embedding_offset","weapon_visible_frames","weapon_edge_alpha_frame_count","weapon_edge_alpha_pixels_total","negative_tests")},ensure_ascii=False,indent=2),flush=True)
