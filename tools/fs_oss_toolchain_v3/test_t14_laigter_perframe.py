from pathlib import Path
from PIL import Image
from hashlib import sha256
import json,sys
R=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
IN=R/"inputs"
OUT=R/"outputs"/"t14_per_frame"
OUT.mkdir(exist_ok=True,parents=True)
source_sheet=Image.open(IN/"tree_animation_6frames.png").convert("RGBA")
assert source_sheet.size==(384,96)
atlass=Image.new("RGBA",(384,96),(0,0,0,0))
seq=[];touched=0
for i in range(6):
 src=Image.open(IN/f"tree_frame_{i:02}.png").convert("RGBA")
 output=Image.open(R/"outputs"/"laigter"/f"tree_frame_{i:02}_n.png").convert("RGBA")
 assert src.size==output.size==(64,96)
 assert src.tobytes()==source_sheet.crop((i*64,0,(i+1)*64,96)).tobytes()
 alpha_equal_raw=src.getchannel("A").tobytes()==output.getchannel("A").tobytes()
 # Laigter source alpha repair: maintain RGB normal, copy only alpha.
 output.putalpha(src.getchannel("A"))
 dest=OUT/f"tree_frame_{i:02}_normal_fixed.png"
 output.save(dest)
 atlass.paste(output,(i*64,0))
 srcsha=sha256((IN/f"tree_frame_{i:02}.png").read_bytes()).hexdigest()
 seq.append({"frame":i,"source_sha":srcsha,"native_laigter_alpha_exact":alpha_equal_raw,
 "fixed_alpha_exact":output.getchannel("A").tobytes()==src.getchannel("A").tobytes(),
 "output_sha":sha256(dest.read_bytes()).hexdigest(),"normal_rgb_nonflat":len(set(output.convert("RGB").getdata()))>1})
atlas_path=OUT/"tree_6frame_normal_perframe.png"
atlass.save(atlas_path)
for i in range(6):
 fixed=Image.open(OUT/f"tree_frame_{i:02}_normal_fixed.png").convert("RGBA")
 assert atlass.crop((i*64,0,(i+1)*64,96)).tobytes()==fixed.tobytes()
 assert atlass.crop((i*64,0,(i+1)*64,96)).getchannel("A").tobytes()==source_sheet.crop((i*64,0,(i+1)*64,96)).getchannel("A").tobytes()
naive=Image.open(R/"outputs"/"laigter"/"tree_animation_6frames_n.png").convert("RGBA")
naive.putalpha(source_sheet.getchannel("A"))
def visible_pixels_diff(x,y,visible=source_sheet):
 a=x.load();b=y.load();p=visible.getchannel("A").load()
 return sum(a[xx,yy]!=b[xx,yy] and p[xx,yy]>0 for yy in range(96) for xx in range(384))
naive_diff=visible_pixels_diff(naive,atlass)
# Mutation detects a changed placement and frame order
off=Image.new("RGBA",(384,96),(0,0,0,0))
for i in range(6):
 part=Image.open(OUT/f"tree_frame_{i:02}_normal_fixed.png").convert("RGBA")
 off.paste(part,(i*64+(1 if i==2 else 0),0))
off_diff=visible_pixels_diff(off,atlass)
reordered=Image.new("RGBA",(384,96),(0,0,0,0))
for i in range(6):
 k=3 if i==2 else 2 if i==3 else i
 part=Image.open(OUT/f"tree_frame_{k:02}_normal_fixed.png").convert("RGBA")
 reordered.paste(part,(i*64,0))
reorder_diff=visible_pixels_diff(reordered,atlass)
meta=json.loads((R/"outputs"/"libresprite"/"T12_6FRAME.json").read_text(encoding="utf8"))
entries=list(meta["frames"].values())
durations=[int(a["duration"]) for a in entries]
assert len(durations)==6
sprite_meta={"frame_width":64,"frame_height":96,"atlas_columns":6,
 "diffuse_atlas_path":"inputs/tree_animation_6frames.png",
 "normal_atlas":"outputs/t14_per_frame/tree_6frame_normal_perframe.png",
 "frame_duration_ms":durations,"frame_tags":meta["meta"].get("frameTags",[]),
 "origin":"B0 6 procedural source sprite frames; Laigter CLI per frame; alpha restored"}
(OUT/"NORMAL_ANIMATION_MANIFEST.json").write_text(json.dumps(sprite_meta,ensure_ascii=False,indent=2),encoding="utf8")
result={"test":"T14 Laigter per-frame normal stitching from source B0 frame sprites",
 "status":"T14_PERFRAME_ATLAS_ALPHA_AND_FRAME_PASS" if (all(row["fixed_alpha_exact"] and row["normal_rgb_nonflat"] for row in seq) and naive_diff>0 and off_diff>0 and reorder_diff>0) else "T14_FAIL_CLOSED",
 "frame_dimensions":[64,96],"atlas_dimensions":[384,96],"normal_sha256":sha256(atlas_path.read_bytes()).hexdigest(),
 "original_sheet_sha256":sha256((IN/"tree_animation_6frames.png").read_bytes()).hexdigest(),
 "frame_checks":seq,"naive_sheet_vs_perframe_visible_diff":naive_diff,
 "negative_1px_shift_visible_diff":off_diff,"negative_swapped_2_3_visible_diff":reorder_diff,
 "frame_durations_ms":durations,"assumptions":["All six source images approved test art only", "No image rescaling","Godot visual acceptance separate","Do not claim normal maps solve Ground/PAR layering"]}
(R/"reports"/"T14_LAIGTER_STITCHED_NORMALS.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("T14_RESULT",result["status"],"NAIVE_VISIBLE_DIFF",naive_diff,"SHIFTED",off_diff,"REORDER",reorder_diff,"DURATIONS",durations,flush=True)
if result["status"]!="T14_PERFRAME_ATLAS_ALPHA_AND_FRAME_PASS":sys.exit(2)
