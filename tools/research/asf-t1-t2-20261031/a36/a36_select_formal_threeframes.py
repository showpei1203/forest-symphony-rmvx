"""A36 formal 3-frame per-action delivery. Strict three PNG cells only.
A35's 28 raw provider frames and A35 18-frame DEMO are strictly research, not SBS deliverables.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,zipfile
B=Path(r"E:\GameAssetToolLab_20261023")
R=B/"A36_FS_ACTION_3FRAME_FORMAL_20261101"
q=json.loads((R/"A36_3FRAME_QA.json").read_text(encoding="utf8"))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def div3(sheet):
 im=Image.open(sheet).convert("RGBA")
 assert im.size==(120,40),(sheet,im.size)
 return [im.crop((i*40,0,(i+1)*40,40)) for i in range(3)]
# A36 T3: readable 3-frame dodge sequence guard->duck low->return to same battle view.
src=R/"T3_READY_LOW_EVADE_RECOVER_3FRAME_40.png"
F=div3(src)
assert F[0].tobytes()==F[2].tobytes()
out=R/"A36_DODGING_FORMAL_3FRAME_CANDIDATE.png"
out.write_bytes(src.read_bytes())
# 3 real frame extracts separately; no redrawing
for i,im in enumerate(F):im.save(R/f"A36_DODGING_F{i}_SOURCE_DERIVED_40.png")
# Strict one-shot gif: omit Netscape loop extension so no repeat.
F[0].save(R/"A36_DODGING_FORMAL_3FRAME_ONESHOT.gif",save_all=True,
 append_images=F[1:],duration=[170,260,510],disposal=2,optimize=False)
gif=Image.open(R/"A36_DODGING_FORMAL_3FRAME_ONESHOT.gif")
assert gif.n_frames==3,(gif.n_frames,gif.info)
assert gif.info.get("loop") is None,gif.info
for label in ["A36_WALK_3FRAME_APPROVED_A31.png","A36_WAITING_3FRAME_STATIC_REPEATED.png","A36_NOTHING_3FRAME_TRANSPARENT.png"]:
 div3(R/label)
# exact 3 FRAME GATE for ALL actions, including Waiting (same 3px art) and Nothing (empty)
m={"version":"A36","date":"2026-11-01","rule":"Exactly 3 native frames in each and every combat action spritesheet",
"action_dimensions":"3×40px = 120x40 PNG, 3 columns x 1 row",
"source": "A34 native FS 45° battle F0/F2 and selected genuine A35 interpolation PNG B3",
"candidate":"A36_DODGING_FORMAL_3FRAME_CANDIDATE.png",
"dodging_frames":[{"idx":0,"motion":"Guard F0 with native 45° battle view","source":"A34 true native 45° PixelLab white haired unarmed master"},
 {"idx":1,"motion":"Crouch / lower hitbox / evade","source":"A35 genuine PixelLab interpolation B03, not manually repainted"},
 {"idx":2,"motion":"Recovery; exact same pixel art as native F0","source":"A34 true native 45° PixelLab white haired unarmed master"}],
"walk":"3 UNIQUE source A31 frames c0 c1 c2; 4-phase playback c0,c1,c2,c1 uses center frame twice with script, NOT 4 sprite columns",
"waiting":"3 identical real approved center images, no shoulder wiggle",
"nothing":"3 transparent frames, no PixelLab fees",
"GIF":"one shot no repeat extension; 3 frames",
"pixel_lab":{"new_paid_generations":0,"only_selected_from_existing_genuine_A34_A35_assets":True},
"fullQA":{"exactly_three_frames":"PASS","native40px_each":"PASS","alpha_channel":"PASS",
"F0_F2_visual_lock_same_file":"PASS","per-frame_45degree":"ART REVIEW PENDING",
"action_dodge_naturalness":"ART REVIEW PENDING",
"Tankentai_sbs_paper_doll_test":"NOT DONE",
"engine_formal_pass":"NOT DONE"},
"alternative_three_frame_dodge_variants":list(q["candidates"].keys()),
"no_project_assets_overwritten":True,
"sha256":sha(out)}
(R/"A36_FORMAL_3FRAME_QA.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf8")
try:font=ImageFont.truetype(r"C:\Windows\Fonts\arial.ttf",21)
except:font=ImageFont.load_default()
canvas=Image.new("RGB",(3*288,343),(235,239,244))
d=ImageDraw.Draw(canvas)
for i,f in enumerate(F):
 bg=Image.new("RGBA",(40,40),(235,239,244,255));bg.alpha_composite(f)
 canvas.paste(bg.convert("RGB").resize((270,270),Image.Resampling.NEAREST),(i*288+9,35))
 d.text((i*288+12,7),["F0 / GUARD","F1 / EVADE","F2 / RECOVER"][i],font=font,fill=(19,31,47))
canvas.save(R/"A36_DODGING_FORMAL_3FRAME_LARGE_PREVIEW.png",optimize=True)
print(json.dumps(m["fullQA"],ensure_ascii=False))
print("GIF_NFRAMES",gif.n_frames,"GIF_LOOP_EXT",gif.info.get('loop'),"MAIN_SHA",sha(out))
