# -*- coding: utf-8 -*-
"""T17B: two-depth licensed LPC dagger/slash sheet, isolated read-only to sealed projects."""
from pathlib import Path
import urllib.request, zipfile, json, csv, io, hashlib, sys
from PIL import Image
ROOT=Path(__file__).resolve().parent
OLD=ROOT/"lpc_base_assets.zip"
IN=ROOT/"inputs"; OUT=ROOT/"outputs"; IN.mkdir(parents=True,exist_ok=True); OUT.mkdir(parents=True,exist_ok=True)
URL="https://api.github.com/repos/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator/commits/master"
def get(url):
    req=urllib.request.Request(url,headers={"User-Agent":"FS-T17B-LPC-ToolQA"})
    return urllib.request.urlopen(req,timeout=20).read()
sha=lambda b: hashlib.sha256(b).hexdigest()
commit="9bf06be193b053db256b2536824af426de046aa2" # pinned verified revision
base="https://raw.githubusercontent.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator/"+commit+"/"
paths=["weapon/sword/dagger/slash.png","weapon/sword/dagger/behind/slash.png"]
credits_path=IN/"CREDITS.csv"
credits_csv=credits_path.read_bytes() if credits_path.exists() else get(base+"CREDITS.csv")
credits_path.write_bytes(credits_csv)
assert sha(credits_csv)=="9bc3c6fc660946a8f36cefe8df8196884ac0309869cdcf3a8741f40577eb8c50"
rows=list(csv.DictReader(io.StringIO(credits_csv.decode("utf-8-sig"))))
selected=[next((r for r in rows if r["filename"]==p),None) for p in paths]
assert all(selected),("No credits attribution",paths)
assert all("OGA-BY 3.0" in r["licenses"] for r in selected),"Not OGA-BY licensed"
(IN/"SELECTED_CREDITS.json").write_text(json.dumps({"commit":commit,"files":selected},ensure_ascii=False,indent=2),encoding="utf-8")
with zipfile.ZipFile(OLD) as z:
    key="LPC Base Assets/sprites/people/"
    body=Image.open(io.BytesIO(z.read(key+"male_slash.png"))).convert("RGBA")
    pants=Image.open(io.BytesIO(z.read(key+"male_slash_pants.png"))).convert("RGBA")
    assert body.size==pants.size==(384,256)
    src={"body":sha(z.read(key+"male_slash.png")),"pants":sha(z.read(key+"male_slash_pants.png"))}
    (IN/"lpc_base_credits.txt").write_bytes(z.read("LPC Base Assets/CREDITS.TXT"))
    body.save(IN/"body_slash.png");pants.save(IN/"pants_slash.png")
frontpath=IN/"dagger_front_slash.png"
front_bytes=frontpath.read_bytes() if frontpath.exists() else get(base+"spritesheets/weapon/sword/dagger/slash/dagger.png")
assert sha(front_bytes)=="238792746ed9d90148ac9a85c88d224f1ea81ea2376fcb85228b26fdf1159cd1"
behindpath=IN/"dagger_behind_slash.png"
behind_bytes=behindpath.read_bytes() if behindpath.exists() else get(base+"spritesheets/weapon/sword/dagger/behind/slash/dagger.png")
assert sha(behind_bytes)=="328b5818b9d379e77b6ec51edbf0de49dc987e41db252841c16a7dfcc978fbc0"
for file,payload in [("dagger_front_slash.png",front_bytes),("dagger_behind_slash.png",behind_bytes)]:
    (IN/file).write_bytes(payload)
fg=Image.open(io.BytesIO(front_bytes)).convert("RGBA")
bg=Image.open(io.BytesIO(behind_bytes)).convert("RGBA")
assert fg.size==bg.size==body.size==(384,256),[fg.size,bg.size,body.size]
framew=frameh=64
def compose(xbg,xfg):
    canvas=Image.alpha_composite(xbg,body)
    canvas=Image.alpha_composite(canvas,pants)
    return Image.alpha_composite(canvas,xfg)
full=compose(bg,fg)
full.save(OUT/"dagger_slash_4dir_full.png")
(OUT/"source_reference.png").write_bytes((IN/"body_slash.png").read_bytes())
rebuild=Image.new("RGBA",full.size)
frame_rows=[]; direction_names=["up","left","down","right"]
for dy in range(4):
    for fx in range(6):
        rect=(fx*64,dy*64,(fx+1)*64,(dy+1)*64)
        parts=[p.crop(rect) for p in (bg,body,pants,fg)]
        frame=Image.alpha_composite(Image.alpha_composite(Image.alpha_composite(parts[0],parts[1]),parts[2]),parts[3])
        rebuild.paste(frame,(fx*64,dy*64))
        combined=sum(v>0 for v in Image.alpha_composite(parts[0],parts[3]).getchannel("A").get_flattened_data())
        frame_rows.append({"direction":direction_names[dy],"frame":fx,"weapon_nontransparent_pixels":combined})
    full.crop((0,dy*64,384,(dy+1)*64)).save(OUT/("dagger_"+direction_names[dy]+".png"))
assert rebuild.tobytes()==full.tobytes(),"T17B per cell vs atlas mismatch"
assert sum(1 for r in frame_rows if r["weapon_nontransparent_pixels"]>0)>=20, "Not enough weapon frames"
# do not silently mask real z order errors; test reversing above/below.
wrong_order=Image.alpha_composite(Image.alpha_composite(Image.alpha_composite(body,pants),fg),bg)
wrong_z=sum(a!=b for a,b in zip(full.get_flattened_data(),wrong_order.get_flattened_data()))
assert wrong_z>0,"inverted Z layer was not detected"
shift=Image.new("RGBA",fg.size,(0,0,0,0));shift.paste(fg,(1,0))
bad1=compose(bg,shift)
shift_diff=sum(a!=b for a,b in zip(full.get_flattened_data(),bad1.get_flattened_data()))
assert shift_diff>0
swapfg=fg.copy(); swbg=bg.copy()
for img,out_image in [(fg,swapfg),(bg,swbg)]:
    left=img.crop((0,64,384,128));down=img.crop((0,128,384,192))
    out_image.paste(down,(0,64));out_image.paste(left,(0,128))
swapped=compose(swbg,swapfg)
sw_diff=sum(a!=b for a,b in zip(full.get_flattened_data(),swapped.get_flattened_data()))
assert sw_diff>0
# dimensional drift: grid and transparent, never resize
no_bg=compose(Image.new("RGBA",bg.size,(0,0,0,0)),fg)
missing_bg_diff=sum(a!=b for a,b in zip(full.get_flattened_data(),no_bg.get_flattened_data()))
# alternative debugging thumbnail (not validation)
pre=Image.new("RGBA",(full.width*2,full.height),(0,0,0,0))
pre.paste(Image.alpha_composite(body,pants),(0,0));pre.paste(full,(full.width,0));pre.save(OUT/"T17B_BEFORE_AFTER.png")
result={
 "status":"T17B_LPC_DAGGER_TWO_DEPTH_24FRAME_STRUCTURAL_PASS",
 "source_repository":"https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator",
 "source_commit":commit,
 "asset_sha256":{"body":src["body"],"pants":src["pants"],"dagger_front":sha(front_bytes),"dagger_behind":sha(behind_bytes),"LPC_original_zip":sha(OLD.read_bytes()),"CREDITS_csv":sha(credits_csv)},
 "selected_credit_rows":selected,"selected_license_choice":"OGA-BY 3.0, retain required author credits",
 "sprite_dimensions":[384,256],"grid_dimensions":[64,64],"frame_count":24,"directions":direction_names,
 "compositing_order":["weapon_behind","body","pants","weapon_front"],
 "perframe_vs_full_rgba_exact":True,
 "weapon_visible_frames":sum(1 for r in frame_rows if r["weapon_nontransparent_pixels"]>0),
 "per_frame_weapon_pixels":frame_rows,
 "negative_1px_shift_diff_pixels":shift_diff,
 "negative_swapped_left_down_diff_pixels":sw_diff,
 "negative_reverse_layer_order_diff_pixels":wrong_z,
 "negative_omit_behind_diff_pixels":missing_bg_diff,
 "limits":["No semantic animation grip-point human visual acceptance","No VX SBS runtime adapter yet","No licensed PMD rights verification","No FS Human Gate F","Mixed old base vs current weapon art styles need human check"]
}
(ROOT/"T17B_LPC_WEAPON_LAYER_ALIGNMENT.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({k:v for k,v in result.items() if k in ("status","source_commit","sprite_dimensions","frame_count","weapon_visible_frames","perframe_vs_full_rgba_exact","negative_1px_shift_diff_pixels","negative_swapped_left_down_diff_pixels","negative_reverse_layer_order_diff_pixels","negative_omit_behind_diff_pixels")},ensure_ascii=False,indent=2))
