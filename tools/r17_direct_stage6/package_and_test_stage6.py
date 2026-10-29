#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
import hashlib,json,zipfile,subprocess,tempfile,shutil,sys
base=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
g=base/"GROUND.png";p=base/"PAR.png";manifest=base/"PAIR_SOURCE_MANIFEST.json"
script=base/"build_stage6_native_pair_v2.py"
assert all(x.exists() for x in [g,p,manifest,script])
baseline={"ground":sha(g),"par":sha(p),"qa":sha(base/"COMPOSITE_QA_ONLY.png")}
with tempfile.TemporaryDirectory(prefix="FS_R17_STAGE6_COLD_") as tmp:
    t=Path(tmp);shutil.copytree(base/"sources",t/"sources");shutil.copy2(script,t/script.name)
    process=subprocess.run([sys.executable,str(t/script.name)],text=True,capture_output=True,encoding="utf8",errors="replace")
    print("COLD_EXIT",process.returncode,process.stderr[-300:])
    assert process.returncode==0
    c={x:sha(t/fn)==baseline[x] for x,fn in [("ground","GROUND.png"),("par","PAR.png"),("qa","COMPOSITE_QA_ONLY.png")]}
    assert all(c.values()),c
    print("COLD_SHA",c)
gate=Path(r"E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027\R17_STAGE5_LATEST_PAIR_STRICT_QA_20261029\r17_pair_alpha_canvas_gate_v2.py")
negative={}
assert gate.exists(),gate
with tempfile.TemporaryDirectory(prefix="FS_R17_S6_NEG_") as tmp:
 t=Path(tmp);par=Image.open(p)
 par.crop((0,0,543,416)).save(t/"PAR_BAD_WIDTH.png")
 q=subprocess.run([sys.executable,str(gate),"--ground",str(g),"--par",str(t/"PAR_BAD_WIDTH.png")],capture_output=True,text=True)
 negative["one_pixel_width"]=q.returncode
 a=par.copy();a.putpixel((0,0),(255,0,0,1));a.save(t/"PAR_BAD_ALPHA_BORDER.png")
 q=subprocess.run([sys.executable,str(gate),"--ground",str(g),"--par",str(t/"PAR_BAD_ALPHA_BORDER.png")],capture_output=True,text=True)
 negative["alpha_border_1px"]=q.returncode
 m=json.loads(manifest.read_text(encoding="utf8"));m["ground"]["sha256"]="0"*64
 (t/"fake.json").write_text(json.dumps(m),encoding="utf8")
 q=subprocess.run([sys.executable,str(gate),"--ground",str(g),"--par",str(p),"--manifest",str(t/"fake.json")],capture_output=True,text=True)
 negative["forged_source_sha"]=q.returncode
assert negative=={"one_pixel_width":2,"alpha_border_1px":2,"forged_source_sha":2},negative
print("NEGATIVE_EXITS",negative)
audit={"phase":"R17_STAGE6_V2","result":"TECH_PASS_ART_FAIL","formal_seal":"NO",
 "method":"new Ground from scratch authored by code + independently sourced cottage/tree PAR objects; no old Ground pixels read",
 "source_provenance":"REPRODUCIBLE_SOURCE_GENERATOR_AND_NATIVE_SPRITES; NOT FINAL ART",
 "baseline_sha":baseline,"cold_rebuild_same_sha":True,"negative_mutations_exit_codes":negative,
 "visual_review":{"ground":"FAIL: procedural grass and repeated-looking pebble ribbons, far inferior to ground3",
 "par":"FAIL: 19 objects include 2 houses, 2 trees, lamps/fences/pots, but artwork still insufficiently rich",
 "ratio":"CANDIDATE: house width 153, max ground flower patch width 18, detached trunk gone",
 "tree_foot_semantic":"HOLD: latest user rejected isolated stump; V2 uses full tree on PAR and Ground shadow only, differing from earlier lowest-32px-bark rule",
 "combined":"FAIL: sparse and repetitive compared to detailed elf-village examples"},
 "sealed_assets_not_edited":True}
(base/"R17_STAGE6_EVIDENCE_SUMMARY.json").write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding="utf8")
md="\n".join([
"# FS R17 Stage6 V2 | 2026-10-29",
"RESULT: SOURCE-FIRST TECH PASS / HUMAN ART FAIL / FORMAL SEAL NO",
"",
"Actual source-first artwork produced on authorized Windows Python3.11 + Pillow + NumPy.",
"Fresh Ground authored from seed and polygons. Never reads any old Ground or finished Master.",
"PAR: two standalone transparent houses, one large tree, one small tree, fence, well, lanterns, sign, bench and 7 pots (19 original placed objects).",
"Blueprint canvas 544x416, no interpolation of Ground, nontransparent scene object source provenance stored.",
"",
"Ground SHA256: "+baseline["ground"],
"PAR SHA256: "+baseline["par"],
"Strict native gate and official R17 direct source gate: exit 0 (technical only).",
"PAR alpha0 158330, alpha255 67974, partial 0; clean 4 canvas borders.",
"Cold regeneration Ground/PAR/QA SHA all match.",
"Negative tests off-by-one pixel size, dirty border and forged source SHA all exit 2.",
"",
"ART FAIL: ground turf textures still simplistic and paths artificial. PAR 19 objects still not as richly detailed as requested examples.",
"Tree foot semantic HOLD: user objected to isolated trunk in Ground. V2 keeps complete tree in PAR and contact shadow Ground, while historical 32x32-bark rule expects bottom tile Ground. Keep this explicit discrepancy.",
"No modification to sealed FS/K4, Map.rvdata, Scripts.rvdata, collision or user-defined passability.",
"Next step: replace low-detail art with independent high-fidelity native source sprite kit and refined Ground; never claim PASS based on dimensions alone."])
(base/"R17_STAGE6_CURRENT_HANDOFF.md").write_text(md,encoding="utf8")
z=base/"FS_R17_STAGE6_V2_TECH_PASS_ART_FAIL_PRIVATE.zip"
for old in (base/"FS_R17_STAGE6_V2_TECH_PASS_ART_FAIL_PRIVATE.zip",):
 if old.exists():old.unlink()
files=sorted([f for f in base.rglob("*") if f.is_file() and f!=z],key=lambda x:str(x))
contents={str(x.relative_to(base)).replace("\\","/"):sha(x) for x in files}
(base/"FILES_SHA256.json").write_text(json.dumps(contents,indent=2,ensure_ascii=False),encoding="utf8")
with zipfile.ZipFile(z,"w",zipfile.ZIP_DEFLATED,compresslevel=8) as zz:
 for f in sorted(base.rglob("*")):
  if f.is_file() and f!=z:zz.write(f,str(f.relative_to(base)).replace("\\","/"))
with zipfile.ZipFile(z) as zz:assert zz.testzip() is None
print("ZIP",z.stat().st_size,sha(z),"ENTRIES",len(zipfile.ZipFile(z).namelist()))

[executed on device: DESKTOP-90VT437 (bc1ce35a-1602-4295-8688-94e581f048f4)]
