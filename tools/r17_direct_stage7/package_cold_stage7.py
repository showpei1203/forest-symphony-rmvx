#!/usr/bin/env python3
"""Stage7 actual independent image-source pair, cold rebuild and negative gates."""
from pathlib import Path
from PIL import Image
import hashlib,zipfile,tempfile,shutil,json,subprocess,sys
base=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd):
 p=subprocess.run(cmd,capture_output=True,text=True,encoding="utf8",errors="replace")
 return p.returncode,p.stdout[-250:],p.stderr[-250:]
script=base/"build_stage7_source_first_ground_clean_par.py"
source=base/"sources/PAR_ORIGINAL_INDEPENDENT_STAGE5.png"
assert script.is_file() and source.is_file()
names=["GROUND.png","PAR.png","COMPOSITE_QA_ONLY.png","PAR_ALPHA_CHECKER_QA_ONLY.png","PAIR_SOURCE_MANIFEST.json"]
expected={n:sha(base/n) for n in names}
with tempfile.TemporaryDirectory(prefix="R17_STAGE7_COLD_") as tmp:
 t=Path(tmp);(t/"sources").mkdir()
 shutil.copy2(source,t/"sources"/source.name)
 shutil.copy2(script,t/script.name)
 rc,out,err=run([sys.executable,str(t/script.name)])
 print("COLD_REBUILD_EXIT",rc,"ERROR",err)
 assert rc==0,(out,err)
 x={n:sha(t/n)==expected[n] for n in names}
 print("COLD_SHA_ALL",x)
 assert all(x.values()),x
gate=Path(r"E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027\R17_STAGE5_LATEST_PAIR_STRICT_QA_20261029\r17_pair_alpha_canvas_gate_v2.py")
shutil.copy2(gate,base/"r17_pair_alpha_canvas_gate_v2.py")
negative={}
with tempfile.TemporaryDirectory(prefix="R17_STAGE7_NEG_") as tmp:
 t=Path(tmp)
 p=Image.open(base/"PAR.png")
 p.crop((0,0,543,416)).save(t/"PAR_1PX_BAD.png")
 negative["width_1px"]=run([sys.executable,str(gate),"--ground",str(base/"GROUND.png"),"--par",str(t/"PAR_1PX_BAD.png")])[0]
 x=p.copy();x.putpixel((0,0),(255,33,77,1));x.save(t/"PAR_BAD_BORDER.png")
 negative["border_1px"]=run([sys.executable,str(gate),"--ground",str(base/"GROUND.png"),"--par",str(t/"PAR_BAD_BORDER.png")])[0]
 m=json.loads((base/"PAIR_SOURCE_MANIFEST.json").read_text(encoding="utf8"));m["par"]["sha256"]="f"*64
 (t/"fake_manifest.json").write_text(json.dumps(m),encoding="utf8")
 negative["forged_manifest"]=run([sys.executable,str(gate),"--ground",str(base/"GROUND.png"),"--par",str(base/"PAR.png"),"--manifest",str(t/"fake_manifest.json")])[0]
assert all(v==2 for v in negative.values()),negative
print("NEGATIVE_ALL_REJECTED",negative)
ga=Image.open(base/"GROUND.png");pa=Image.open(base/"PAR.png")
audit={"stage":"FS_R17_STAGE7_RICH_PAR",
 "technical":"TECH_CANDIDATE_ONLY",
 "human_ground_art":"FAIL_GROUND_TOO_PROCEDURAL",
 "human_par_art":"IMPROVED_RICH_VISUAL_CANDIDATE_NOT_APPROVED",
 "human_pair_visual":"HOLD_FOOT_AND_STYLE",
 "source_provenance":"INDEPENDENT_PAR_ORIGINAL_ALPHAREPAIR_AND_UNIFORM_NEAREST_SCALE; PER_OBJECT_SOURCE_NOT_EDITABLE",
 "native_art":"NOT_FULLY_NATIVE_1X_PAR_ORIGINAL_1448x1086",
 "par_floor_flora_semantics":"HOLD_SOURCE_BAKED_FLOWERBEDS",
 "tree_contact_rule":"HOLD_NO_ISOLATED_STUMP_VS_HISTORIC_32PX_BARK",
 "dimensions":{"ground":list(ga.size),"par":list(pa.size)},
 "hashes":{"ground":expected["GROUND.png"],"par":expected["PAR.png"],"source_par":sha(source)},
 "par_original_size":[1448,1086],"par_offset_xy":[11,12],"par_scaled_source_size":[521,391],
 "postprocess":"alpha threshold 70-215 mapped to 0-255, NEAREST downsizing preserving ratio",
 "par_alpha_partial_count":int(sum(0<v<255 for v in pa.getchannel("A").getdata())),
 "two_validator_results":{"official":"exit0_tech_candidate","strict":"exit0_tech_candidate"},
 "cold_rebuild_same_sha":True,"negative_test_exits":negative,
 "formal_seal":"NO"}
(base/"STAGE7_FULL_AUDIT.json").write_text(json.dumps(audit,indent=2,ensure_ascii=False),encoding="utf8")
md="\n".join([
 "# FS R17 Stage7 High Detail PAR Source Repair | 2026-10-29",
 "TECH_CANDIDATE / PAR_VISUAL_IMPROVED / GROUND_ART_FAIL / FINAL_SEAL_NO",
 "",
 "R17 Stage5 originally produced a standalone, largely transparent high-detail PAR image, containing two elaborate cottages, a mature tree, fences, lanterns, signs and flower gardens. It FAILED native canvas and near-transparent-edge criteria.",
 "This experiment reused ONLY that originally independent PAR source (NOT a full illustrated Master) to make a 544x416 alpha-cleaned native output. The new GROUND was re-authored from code from scratch with a new seed/paths, NEVER cropped from any earlier Ground image.",
 "A single near-uniform 0.36 nearest-neighbor downscale and 11,12 canvas offset preserves source object proportions; no 32px source editing or per-object masks were recovered.",
 "",
 "TRUE TECH TEST:",
 "- Ground original 544x416 RGB; PAR native output 544x416 RGBA; clean alpha canvas borders.",
 "- Official R17 Source Validator and Stage5 strict alpha/canvas gate exit 0, only TECH_CANDIDATE.",
 "- Cold rebuild from standalone script and independent Stage5 PAR original recreates Ground/PAR/QA/manifest identical hashes.",
 "- Mutate by a single wrong pixel width, alpha edge, or forged PAR source SHA: all three fail-closed exit2.",
 "- Original source is a precomposed PAR collage, not per-object editable native 1x assets. Alpha cleanup/downscale does not magically create editable object ownership.",
 "",
 "ART AND SEMANTIC GATES:",
 "- Ground: FAIL, visible algorithmic noise/pebble pathway, not equivalent to user's ground3/SCENE21 samples.",
 "- PAR: RICHNESS MARKEDLY IMPROVED over Stage6, but ORIGINAL individual object assets/editability and floor-flora contamination require audit. PAR ART HOLD.",
 "- Pair: correct pixel canvas and real alpha, visually more compelling than Stage6 but tree contact/door pathway, lighting and style still need review. PAIR VISUAL HOLD.",
 "- Formal Seal = NO. No sealed FS/K4 Maps, Scripts, Collision, Passability modified.",
 "",
 "Next work: new visually rich independent 1x Ground source and independently editable rich PAR asset family; do not retreat to Model-generated QA boards with fake PASS labels or extract PAR from finished Master.",
 ])
(base/"CURRENT_HANDOFF_R17_STAGE7.md").write_text(md,encoding="utf8")
z=base/"FS_R17_STAGE7_RICH_PAR_ART_HOLD_TECH_CANDIDATE_PRIVATE.zip"
if z.exists():z.unlink()
files=sorted([f for f in base.rglob("*") if f.is_file() and f!=z and f.name not in ("prepare_stage7_source.py","fix_stage7_preamble.py")],key=lambda f:str(f))
# Package only truly portable native generator, source image, outputs, audits and gate.
with zipfile.ZipFile(z,"w",zipfile.ZIP_DEFLATED,compresslevel=8) as out:
 for f in files:out.write(f,str(f.relative_to(base)).replace("\\","/"))
with zipfile.ZipFile(z) as q:
 assert q.testzip() is None
 print("ZIP_ENTRIES",len(q.namelist()))
print("ZIP_FINAL",z.stat().st_size,sha(z))
print("GROUND_SHA",expected["GROUND.png"],"PAR_SHA",expected["PAR.png"])

[executed on device: DESKTOP-90VT437 (bc1ce35a-1602-4295-8688-94e581f048f4)]
