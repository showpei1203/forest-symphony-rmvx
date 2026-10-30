#!/usr/bin/env python3
"""Native source-first Stage12 formal structural QA / cold isolated regen / negative tests.
Art gate separately reviewed by human; no auto artistic PASS.
"""
import hashlib,sys,subprocess,json,zipfile,shutil,tempfile
from pathlib import Path
import numpy as np
from PIL import Image,ImageChops,ImageDraw,ImageFont
P=Path(__file__).resolve().parent; S=P/'sources'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def call(args):
 return subprocess.run(args,capture_output=True,text=True,encoding='utf8',errors='replace')
files={f:sha(P/f) for f in ['GROUND.png','PAR.png','COMPOSITE_QA_ONLY.png',
 'GROUND_A_SOFT_SOURCE_QUILT.png','GROUND_B_ARTISAN_A2_QUILT.png',
 'GROUND_C_RESTRAINED_ART_MIX.png','QA_C_RESTRAINED_ART_MIX.png']}
g=Image.open(P/'GROUND.png')
par=Image.open(P/'PAR.png')
comp=Image.alpha_composite(g.convert('RGBA'),par).convert('RGB')
diff=ImageChops.difference(comp,Image.open(P/'COMPOSITE_QA_ONLY.png').convert('RGB'))
assert g.size==par.size==(544,416) and g.mode=='RGB' and par.mode=='RGBA' and not diff.getbbox()
alpha=np.array(par.getchannel('A'))
border={"top":int((alpha[0,:]>0).sum()),"bottom":int((alpha[-1,:]>0).sum()),
        "left":int((alpha[:,0]>0).sum()),"right":int((alpha[:,-1]>0).sum())}
manifest={"source_mode":"independent_direct_layers",
 "ground":{"source_artifact_id":"R17_S12_FRESH_SOURCE_QUILT_C",
           "creation_method":"direct_ground","scene_blueprint_id":"FS_R17_S12_544x416_V2",
           "style_lock_id":"R17_S12_A2_ART_BASE_NATIVE_1X",
           "world_origin_xy":[0,0],"sha256":files["GROUND.png"],
           "source_atlas_sha256":sha(S/"A2_VSCliff.png")},
 "par":{"source_artifact_id":"R17_S7_PRECOMPOSED_INDEPENDENT_PAR_REUSE",
        "creation_method":"direct_par","scene_blueprint_id":"FS_R17_S12_544x416_V2",
        "style_lock_id":"R17_S12_A2_ART_BASE_NATIVE_1X",
        "world_origin_xy":[0,0],"sha256":files["PAR.png"],
        "limitation":"Existing independent transparent precomposed PAR, not per-object editable native original"}}
(P/'PAIR_SOURCE_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
official=Path.home()/'AppData'/'Local'/'Temp'/'fs_r17_source_validator_20261029.py'
strict=Path(r'E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027\R17_STAGE5_LATEST_PAIR_STRICT_QA_20261029\r17_pair_alpha_canvas_gate_v2.py')
assert official.exists() and strict.exists()
exits={}
for name,tool in [('official',official),('strict',strict)]:
 q=call([sys.executable,str(tool),'--ground',str(P/'GROUND.png'),'--par',str(P/'PAR.png'),
         '--manifest',str(P/'PAIR_SOURCE_MANIFEST.json'),'--report',str(P/(name.upper()+'_GATE.json'))])
 exits[name]=q.returncode;print(name,q.returncode,q.stdout[-220:],q.stderr[-120:])
assert exits['official']==exits['strict']==0
with tempfile.TemporaryDirectory(prefix="FS_R17_S12_COLD_") as td:
 cold=Path(td);shutil.copytree(S,cold/'sources')
 shutil.copy2(P/'build_stage12_a2_quilt_v2.py',cold/'build_stage12_a2_quilt_v2.py')
 q=call([sys.executable,str(cold/'build_stage12_a2_quilt_v2.py')])
 assert q.returncode==0,(q.stdout,q.stderr)
 cold_checks={name:sha(cold/name)==digest for name,digest in files.items()}
 assert all(cold_checks.values()),cold_checks
 print('COLD_SHA',cold_checks)
negative={}
with tempfile.TemporaryDirectory(prefix="FS_R17_S12_NEG_") as td:
 tmp=Path(td)
 par.crop((0,0,543,416)).save(tmp/'badwidth.png')
 negative['1px_width']=call([sys.executable,str(strict),'--ground',str(P/'GROUND.png'),'--par',str(tmp/'badwidth.png')]).returncode
 broken=par.copy();broken.putpixel((0,0),(123,34,67,1));broken.save(tmp/'badborder.png')
 negative['1px_alpha_border']=call([sys.executable,str(strict),'--ground',str(P/'GROUND.png'),'--par',str(tmp/'badborder.png')]).returncode
 fake=json.loads((P/'PAIR_SOURCE_MANIFEST.json').read_text(encoding='utf8'))
 fake['ground']['sha256']='0'*64
 (tmp/'fake.json').write_text(json.dumps(fake),encoding='utf8')
 negative['forged_sha']=call([sys.executable,str(strict),'--ground',str(P/'GROUND.png'),'--par',str(P/'PAR.png'),'--manifest',str(tmp/'fake.json')]).returncode
assert all(code==2 for code in negative.values()),negative
# Actual side-by-side from two REAL candidate composited pictures, no AI QA poster.
prior=Path(r"E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027\R17_STAGE10_COLD_PACKAGE_VERIFY_20261030\COMPOSITE_QA_ONLY.png")
if not prior.exists():prior=Path(r"E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027\R17_STAGE7_HIGH_FIDELITY_PAR_PAIR_20261029\COMPOSITE_QA_ONLY.png")
lhs=Image.open(prior).convert('RGB') if prior.exists() else Image.open(P/'QA_A_SOFT_SOURCE_QUILT.png').convert('RGB')
rhs=Image.open(P/'COMPOSITE_QA_ONLY.png').convert('RGB')
side=Image.new('RGB',(1096,450),(20,25,27))
side.paste(lhs,(0,34));side.paste(rhs,(552,34))
draw=ImageDraw.Draw(side);draw.text((8,9),'Previous actual QA (technical reference)',fill=(245,245,245))
draw.text((560,9),'Stage12 C actual composite (new Ground)',fill=(245,245,245))
side.save(P/'PREVIOUS_VS_STAGE12_C_QA.png')
report={"stage":"FS_R17_STAGE12","ground":"C_RESTRAINED_ART_MIX",
 "technology":{"size":[544,416],"ground_rgb":True,"par_rgba":True,
 "alpha0":int((alpha==0).sum()),"alpha255":int((alpha==255).sum()),
 "alpha_partial":int(((alpha>0)&(alpha<255)).sum()),"alpha_borders":border,
 "real_png_composite_exact":True,"formal_exit":exits,
 "source_only_cold_regen_byte_match":cold_checks,"negative_fail_closed_exits":negative},
 "provenance":{"new_ground":"original A2 and grass source patches quilted from source; no prior Ground or Master opened",
 "par":"unchanged standalone high-density precomposed PAR from Stage7; still NOT native editable per object",
 "sources":{x.name:sha(x) for x in S.iterdir() if x.is_file()}},
 "visual_review":{
 "A":"Ground too plain; high-detail stone road good",
 "B":"FAIL huge repeated tall grass texture, incorrect Ground object semantics",
 "C":"BEST CANDIDATE, original source grass and artist stone path; road continuity improved after Bezier fix; still lower fine detail than PAR",
 "tree_foot":"HOLD: complete tree on PAR vs historic 32px trunk contact; no detached stump in Ground",
 "par_flora":"HOLD: precomposed PAR includes soil and flowerbed detail",
 "final_art":"HOLD_UNAPPROVED","formal_seal":"NO"}}
(P/'STAGE12_VERIFIED_GATES.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
handoff="""# R17 Stage12｜2026-10-30 Source Quilt Art Pilot
Latest: TECH PASS / GROUND ART CANDIDATE (NOT USER APPROVED) / PAR EDITABILITY HOLD / FORMAL SEAL NO.

Source art breakthrough: user-authorized local original 'A2_VSCliff.png' 512x384 including hand-drawn beige cobblestone and vegetation materials. New Ground source authored via overlap-matched patch quilting (24-28 px native, no image rescale) from artist source + original grass_tile.png. Not based on previous Ground raster and no completed Master reverse segmentation. C mixed 86% source-flat grass + 14% high-detail source-microtex, using continuous properly-corrected Bezier 4-way road. Flowers max 6x6px each. Variant A underdetailed; Variant B violates ground-level semantic due dense tall grass; C nominated for review.
Actual images Ground 544x416 RGB and original independent PAR 544x416 RGBA, composite directly from exported PNG (zero RGB diff), borders clean. Validators official+strict exit0 (TECH ONLY), isolated source-only cold regen hashes exact. Negative 1px crop, alpha border and fake SHA rejected exit2.
PAR still the Stage7 precomposed high-richness original with different per-object editability and tree contact semantic unresolved. No claim of native per-object source or visual Art PASS, no sealed FS/K4 Map/Scripts/Collision/passability changes.
NEXT: 1x user art check; micro-scale ground vegetation art and tree-base semantics; never substitute generated QA poster as proof; expand to 1280x928 only after artwork approved.
"""
(P/'CURRENT_HANDOFF_R17_STAGE12.md').write_text(handoff,encoding='utf8')
z=P/'FS_R17_STAGE12_SOURCE_QUILT_TECH_CANDIDATE_ART_HOLD_PRIVATE.zip'
with zipfile.ZipFile(z,'w',zipfile.ZIP_DEFLATED,compresslevel=8) as arch:
 for f in sorted(P.rglob('*')):
  if f.is_file() and f!=z and f.name not in ('build_stage12_a2_quilt.py','fix_stage12_path_and_texture.py'):
   arch.write(f,str(f.relative_to(P)).replace('\\','/'))
with zipfile.ZipFile(z) as arch: assert arch.testzip() is None
print('FINAL_RESULTS',json.dumps({"ground_sha":files["GROUND.png"],"par_sha":files["PAR.png"],
"zip_sha":sha(z),"zip_bytes":z.stat().st_size,"zip_entries":len(zipfile.ZipFile(z).namelist()),
"validators":exits,"negative":negative},ensure_ascii=False))
