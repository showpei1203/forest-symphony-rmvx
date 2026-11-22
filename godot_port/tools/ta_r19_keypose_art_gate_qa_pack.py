#!/usr/bin/env python3
"""R19 key-pose ART_GATE packaging. Never claim ENGINE/ART PASS from file QA."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageChops
import hashlib,zipfile,json
ROOT=Path(r"E:\LPC_Original_20261121")
D=ROOT/"FS_R19_ACTOR01_FIVE_HAND_PAINTED_BOXING_KEYS"
S=ROOT/"FS_R19_FIVE_HAND_PAINTED_KEYPOSES.py"
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
m=json.loads((D/"R19_ART_GATE_MANIFEST.json").read_text(encoding="utf8"))
assert m["status"]=="ART_GATE_PENDING_1X_OWNER_APPROVAL"
assert m["source_A62_sha256"]=="70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e"
names=["F0_GUARD","F3_COIL","F5_DRIVE","F7_IMPACT","F9_RECOVER"]
frames=[]
for name in names:
 p=D/f"R19_{name}_64.png"
 im=Image.open(p).convert("RGBA")
 assert im.size==(64,64)
 assert im.getbbox() is not None
 assert set(im.getchannel("A").getdata())=={0,255}
 frames.append(im)
assert len({f.tobytes() for f in frames})==5
atlas=Image.open(D/"R19_FIVE_KEYPOSES_320x64.png").convert("RGBA")
assert atlas.size==(320,64)
for i,f in enumerate(frames):
 assert atlas.crop((i*64,0,(i+1)*64,64)).tobytes()==f.tobytes()
assert sha(D/"R19_FIVE_KEYPOSES_320x64.png")==m["sheet_sha256"]
prior=Image.open(D/"R19A_FIRST_DRAFT/R19_FIVE_KEYPOSES_320x64.png").convert("RGBA")
delta=[sum(x!=y for x,y in zip(prior.crop((i*64,0,(i+1)*64,64)).tobytes(),f.tobytes()))//4 for i,f in enumerate(frames)]
assert any(delta),"R19B still equals R19A"
compare=Image.new("RGBA",(5*512,550),(26,30,34,255));paint=ImageDraw.Draw(compare)
for i,f in enumerate(frames):
 x=i*512
 old=prior.crop((i*64,0,(i+1)*64,64))
 compare.alpha_composite(old.resize((256,256),Image.Resampling.NEAREST),(x,20))
 compare.alpha_composite(f.resize((256,256),Image.Resampling.NEAREST),(x+256,20))
 paint.text((x+4,4),f"{names[i]} R19A",fill=(245,245,245))
 paint.text((x+260,4),"R19B detail",fill=(245,245,245))
compare.crop((0,0,2560,275)).convert("RGB").save(D/"R19A_VS_R19B_FIVE_POSES_4X.png")
metrics=[{"pose":name,"sha256":sha(D/f"R19_{name}_64.png"),"bbox":list(im.getbbox()),
"opaque_pixels":sum(px[3]==255 for px in im.getdata()),
"changed_rgba_vs_first":delta[i]} for i,(name,im) in enumerate(zip(names,frames))]
report={"status":"ART_CANDIDATE_PENDING_OWNER_1X_REVIEW","source_manifest_sha":sha(D/"R19_ART_GATE_MANIFEST.json"),
"source_A62_sha":m["source_A62_sha256"],"all_5_actual_native_64":True,
"all_five_poses_unique":True,"all_alpha_binary":True,"output_sheet_size":[320,64],
"original_facial_identity":"approved A62 exact head pixels copied into each pose; lower guard overlay may cover cheeks, art review required",
"five_poses":metrics,"review":"MUST visually assess at native 1x and slowed 4x; key poses are preliminary, not approved",
"engine":"NOT_RUN_PER_ART_GATE","official_FSBattle":"NOT_RUN",
"full_12_frame":"NOT_PRODUCED_PER_KEYPOSE_GATE",
"weapon_fx":"NOT_PRODUCED","paid_PixelLab":"NOT_RUN",
"source_scope":"private original reference E / private Drive; GitHub only source and manifest",
"art_risks":["far fist at left cheek may visually crowd A62 facial area","F7 extended forearm can still read stiff at 1x","five blocking poses need human visual approval"]}
(D/"R19_QA_ART_PENDING.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
(D/"R19_FAILURE_LOG.md").write_text(
 "# R19 Keypose Failure Log (2026-11-22)\n"
 "- First script execution: SyntaxError from 2 closing parentheses after final POSES dict; fixed list terminator, source run PASS.\n"
 "- R19A: 5 native images generated, actual 1x/4x visual review found off-hand not sufficiently visible and torso twist understated. Preserved first draft.\n"
 "- R19B: repainted off-hand cheek guard over source hair edge (kept eyes/crown), added individually authored chest lapel folds; new PNGs and preview produced; 5/5 changed.\n"
 "- No false ART PASS: R19B still owner ART GATE PENDING; F7 stiff arm, off-hand vs cheek may still block.\n"
 "- Godot NOT_RUN and full 12 sprites NOT_PRODUCED intentionally, per authority requiring five keypose visual gate first.\n",
 encoding="utf8")
include=["R19_FIVE_KEYPOSES_320x64.png","R19_FIVE_KEYPOSES_BLOCKING_PREVIEW.gif",
"R19_FIVE_KEYPOSES_CONTACT_1X.png","R19_FIVE_KEYPOSES_CONTACT_4X.png","R19_FIVE_KEYPOSES_CONTACT_8X.png",
"R19A_VS_R19B_FIVE_POSES_4X.png","R19_ART_GATE_MANIFEST.json","R19_QA_ART_PENDING.json","R19_FAILURE_LOG.md"]
include += [f"R19_{x}_64.png" for x in names]
include += ["R19A_FIRST_DRAFT/"+p.name for p in (D/"R19A_FIRST_DRAFT").iterdir() if p.is_file()]
zipfile_path=D/"FS_TA_R19_FIVE_HANDPAINTED_KEYPOSES_ART_GATE_20261122.zip"
with zipfile.ZipFile(zipfile_path,"w",zipfile.ZIP_DEFLATED) as z:
 for p in include:z.write(D/p,p)
 z.write(S,"source/FS_R19_FIVE_HAND_PAINTED_KEYPOSES.py")
with zipfile.ZipFile(zipfile_path) as z:
 assert z.testzip() is None
 count=len(z.namelist())
result={"zip_bytes":zipfile_path.stat().st_size,"zip_sha256":sha(zipfile_path),"archive_items":count,
"pose_count":5,"source_A62_sha":m["source_A62_sha256"],"art":"PENDING_OWNER_APPROVAL","godot":"NOT_RUN"}
(D/"R19_ARCHIVE_SHA.json").write_text(json.dumps(result,indent=2),encoding="utf8")
print("R19_PACKAGED",json.dumps(result))
