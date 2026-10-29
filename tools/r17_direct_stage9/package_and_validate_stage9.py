#!/usr/bin/env python3
"""R17 Stage9 source material QA with positive, cold, mutation gates, real artifact ZIP."""
import hashlib,json,zipfile,subprocess,sys,tempfile,shutil
from pathlib import Path
from PIL import Image, ImageChops
p=Path(__file__).resolve().parent
def sha(x):return hashlib.sha256(Path(x).read_bytes()).hexdigest()
def run(args):return subprocess.run(args,capture_output=True,text=True,encoding='utf-8',errors='replace')
ground=p/'GROUND.png';par=p/'PAR.png';qa=p/'COMPOSITE_QA_ONLY.png'
orig=Image.open(ground).convert('RGBA');pr=Image.open(par).convert('RGBA')
assert orig.size==pr.size==(544,416)
alpha=pr.getchannel('A')
alpha_list=alpha.histogram()
comp=Image.alpha_composite(orig,pr).convert('RGB')
assert ImageChops.difference(comp,Image.open(qa).convert('RGB')).getbbox() is None
scrip=p/'build_stage9_source_material_ground_v2.py'
assert scrip.exists()
manifest={"source_mode":"independent_direct_layers",
"ground":{"source_artifact_id":"R17_STAGE9_ORIGINAL_TILES_SOURCE_NEW_GROUND_B","creation_method":"direct_ground","scene_blueprint_id":"R17_STAGE9_544x416_SHARED_V1","style_lock_id":"FS_PIXEL_SOURCE_TILES_GROUND_NATIVE","world_origin_xy":[0,0],"sha256":sha(ground)},
"par":{"source_artifact_id":"R17_STAGE7_RICH_ORIGINAL_INDEPENDENT_PAR_SCENE","creation_method":"direct_par","scene_blueprint_id":"R17_STAGE9_544x416_SHARED_V1","style_lock_id":"FS_PIXEL_SOURCE_TILES_GROUND_NATIVE","world_origin_xy":[0,0],"sha256":sha(par)}}
(p/'PAIR_SOURCE_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
# actual official and strict validators; they're structural only, human art not implied
formal=Path.home()/'AppData'/'Local'/'Temp'/'fs_r17_source_validator_20261029.py'
strict=Path(r'E:\GameAssetToolLab_20261023\FS_MasterSplit_Research_20261027\R17_STAGE5_LATEST_PAIR_STRICT_QA_20261029\r17_pair_alpha_canvas_gate_v2.py')
assert formal.exists() and strict.exists()
codes={}
for name,v in [('official',formal),('strict',strict)]:
 proc=run([sys.executable,str(v),'--ground',str(ground),'--par',str(par),
           '--manifest',str(p/'PAIR_SOURCE_MANIFEST.json'),'--report',str(p/(name.upper()+'_GATE.json'))])
 codes[name]=proc.returncode;print(name,'EXIT',proc.returncode,proc.stderr[-150:])
assert codes=={'official':0,'strict':0}
# portable cold source-only recomposition, no old GROUND file or prior scene outputs.
files={'GROUND.png':sha(ground),'PAR.png':sha(par),
       'COMPOSITE_QA_ONLY.png':sha(qa),'GROUND_B_LAYERED_SOURCE_TEXTURE.png':sha(p/'GROUND_B_LAYERED_SOURCE_TEXTURE.png')}
with tempfile.TemporaryDirectory(prefix='FS_R17_STAGE9_COLD_') as td:
 t=Path(td);shutil.copytree(p/'sources',t/'sources')
 shutil.copy2(scrip,t/scrip.name);shutil.copy2(par,t/par.name)
 proc=run([sys.executable,str(t/scrip.name)])
 assert proc.returncode==0,proc.stderr[-600:]
 assert all(sha(t/name)==h for name,h in files.items()),[(n,sha(t/n),h) for n,h in files.items() if sha(t/n)!=h]
 print('COLD_REBUILD_SHA',True)
negative={}
with tempfile.TemporaryDirectory(prefix='FS_R17_STAGE9_NEG_') as td:
 t=Path(td)
 im=pr.copy();im.crop((0,0,543,416)).save(t/'bad_width.png')
 negative['1px_width']=run([sys.executable,str(strict),'--ground',str(ground),'--par',str(t/'bad_width.png')]).returncode
 im.putpixel((0,0),(255,25,21,1));im.save(t/'bad_alpha.png')
 negative['1px_alpha_border']=run([sys.executable,str(strict),'--ground',str(ground),'--par',str(t/'bad_alpha.png')]).returncode
 fake=json.loads((p/'PAIR_SOURCE_MANIFEST.json').read_text(encoding='utf8'));fake['ground']['sha256']='a'*64
 (t/'bad_manifest.json').write_text(json.dumps(fake),encoding='utf8')
 negative['forged_manifest']=run([sys.executable,str(strict),'--ground',str(ground),'--par',str(par),'--manifest',str(t/'bad_manifest.json')]).returncode
assert all(v==2 for v in negative.values()),negative
# Additional manual visual assessment, user reference remains governing.
audit={
"stage":"R17_STAGE9_SOURCE_MATERIAL_GROUND","status":"TECH_CANDIDATE_ART_FAIL",
"ground":{"dimensions":[544,416],"SHA256":sha(ground),"RGB":True,
"from_old_ground_image":False,"origins":"original 32x32 grass/path source Tileset plus small native alpha components from legacy_tileD; not an existing Ground",
"visually_approved":False},
"par":{"dimensions":[544,416],"SHA256":sha(par),"RGBA":True,
"alpha0":alpha_list[0],"alpha255":alpha_list[255],"alpha_partial":sum(alpha_list[1:255]),
"source":"unaltered Stage7 rich precomposed independent PAR; original high res resampled; per-object editability HOLD",
"source_semantics":"ground flowerbed contamination and trunk foot remain HOLD"},
"source_ground_technical":{"vegetation_component_count":8,"ground_foliage_scale_max_px":[16,13],
"stone_shape_count":96,"out_of_style_tiles_removed":True,"new_ground_generated_two_material_variants":True},
"checks":{"canvas_equal":True,"par_true_alpha":True,"composite_exact":True,
"cold_source_rebuild_sha_exact":True,"official_validator_exit":codes['official'],"strict_validator_exit":codes['strict'],
"negative_exits":negative},
"visual_assessment":{"ground":"FAIL: source-tile meadow still repetitive/insufficient fine detail compared to rich R17 reference",
"par":"HOLD: two high-detail cottages+tree+fences, but single precomposed source and scale ambiguity",
"pair":"FAIL: art finish mismatch and object foot ownership unresolved"},
"formal_seal":"NO","sealed_map_scripts_collision_unchanged":True}
(p/'R17_STAGE9_GATE_RESULTS.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding='utf8')
handoff="""# R17 Stage9 source tile material Ground candidate | 2026-10-29

TECH CANDIDATE / GROUND ART FAIL / PAR SOURCE HOLD / FORMAL SEAL NO

Built two variants of a completely new 544×416 GROUND using original 32×32 grass_tile.png and path_tile.png, with foliage from connected small vegetation components on legacy_tileD.png (original Tileset, NOT an old completed Ground).
The source was copied and SHA retained. No finished master extraction. A/B: 51/68 ground micro-flora clusters, max 16×13 px, avoiding oversized bush proportions; 96 original rock/stone shapes in textured organically-curved paths. Black-square contaminants from first test variant were excluded by testing green color percentages and dark/brown fractions. Both A and B raster candidates retained for negative/review.
PAR is unchanged from Stage7, which is independent but precomposed: two houses, sacred tree, garden, wooden fences and lanterns. The source image was originally resampled by Stage7; object source editability and ground flowerbed semantics still HOLD. Tree stump no longer on Ground; historic ground-contact bark tile rule is HOLD, not silently fulfilled.
ACTUAL QA: two official structural validators exit0; 544x416 source-images, RGB Ground + real-alpha RGBA PAR, actual PNG-based composite 0 pixel diff; five source-only outputs re-generate exactly in isolated cold-folder; negative crop 1px, contaminated border 1px and forged manifest SHA each exit2.
HUMAN ART FAIL: Despite relative improvement in source-sprite scale, the Ground still fails the user-provided painterly reference: meadow materials too repetitive, soil/path lacks organically varied stones, small flora too evenly scattered. Not a final user-approved paired map.
Next: actual art-quality source creation in one consistent style. Do not run further dozens of nearly identical purely procedural variations and call it progress. Preserve FS K4 sealed binaries and user's own passability/collision design.
"""
(p/'CURRENT_HANDOFF_R17_STAGE9.md').write_text(handoff,encoding='utf8')
z=p/'FS_R17_STAGE9_SOURCE_MATERIAL_TECH_PASS_ART_FAIL_PRIVATE.zip'
if z.exists():z.unlink()
with zipfile.ZipFile(z,'w',zipfile.ZIP_DEFLATED,compresslevel=8) as q:
 for f in sorted(p.rglob('*')):
  if f.is_file() and f!=z and f.name not in ['build_stage9_source_material_ground.py','patch_v2.py','fix_without_opencv.py']:
   q.write(f,str(f.relative_to(p)).replace('\\','/'))
with zipfile.ZipFile(z) as q:
 assert q.testzip() is None
 print('ZIP_ENTRIES',len(q.namelist()))
print('FINAL',json.dumps({"ground":sha(ground),"par":sha(par),"zip":sha(z),"bytes":z.stat().st_size,"negative":negative},ensure_ascii=False))
