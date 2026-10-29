#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageChops
import tempfile, shutil, subprocess, sys, json, hashlib, zipfile
from collections import Counter
P=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
G=P/'GROUND.png';F=P/'PAR.png';Q=P/'COMPOSITE_QA_ONLY.png'
assert G.exists() and F.exists() and Q.exists()
manifest={
 'source_mode':'independent_direct_layers',
 'ground': {'source_artifact_id':'R17_S10_NEW_ART_GROUND_COBBLE_SOURCE_544','creation_method':'direct_ground','scene_blueprint_id':'R17_S10_SHARED_WORLD_544x416_V2','style_lock_id':'FS_ELF_R17_S10_TILE_ART','world_origin_xy':[0,0],'sha256':sha(G)},
 'par': {'source_artifact_id':'R17_S7_RICH_SEPARATELY_GENERATED_PAR_544','creation_method':'direct_par','scene_blueprint_id':'R17_S10_SHARED_WORLD_544x416_V2','style_lock_id':'FS_ELF_R17_S10_TILE_ART','world_origin_xy':[0,0],'sha256':sha(F)},
 'important_limitation':'PAR inherited from R17 Stage7: independently generated but precomposed and nearest downsized source; shared blueprint declares final canvas, not certified common art-generation coordinates.'}
M=P/'PAIR_SOURCE_MANIFEST.json';M.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
g=Image.open(G);f=Image.open(F);q=Image.open(Q)
assert g.size==f.size==q.size==(544,416)
assert g.mode=='RGB' and f.mode=='RGBA'
assert ImageChops.difference(Image.alpha_composite(g.convert('RGBA'),f).convert('RGB'),q.convert('RGB')).getbbox() is None
from PIL import ImageStat
h=f.getchannel('A').histogram()
alpha=dict(zero=h[0],solid=h[255],partial=sum(h[1:255]),visible=sum(h[1:]),edges={
 'top':sum(v>0 for v in list(f.getchannel('A').crop((0,0,544,1)).getdata())),
 'bottom':sum(v>0 for v in list(f.getchannel('A').crop((0,415,544,416)).getdata())),
 'left':sum(v>0 for v in list(f.getchannel('A').crop((0,0,1,416)).getdata())),
 'right':sum(v>0 for v in list(f.getchannel('A').crop((543,0,544,416)).getdata()))})
strict=P/'r17_pair_alpha_canvas_gate_v2.py'
def check(ground,par,manifest=None):
 cmd=[sys.executable,str(strict),'--ground',str(ground),'--par',str(par)]
 if manifest:cmd.extend(['--manifest',str(manifest)])
 return subprocess.run(cmd,capture_output=True,text=True)
positive=check(G,F,M)
assert positive.returncode==0,positive.stdout+' '+positive.stderr
print('STRICT_POSITIVE',positive.returncode,positive.stdout.strip())
# isolated source cold rebuild. No previous ground PNG goes inside temporary folder.
with tempfile.TemporaryDirectory(prefix='R17_STAGE10_COLD_') as tmp:
 p=Path(tmp);(p/'sources').mkdir()
 for name in ['grass_tile.png','path_tile.png','legacy_tileD.png']:
  shutil.copy2(P/'sources'/name,p/'sources'/name)
 shutil.copy2(P/'build_stage10_ground_v2.py',p/'build_stage10_ground_v2.py')
 shutil.copy2(F,p/'PAR.png')
 res=subprocess.run([sys.executable,str(p/'build_stage10_ground_v2.py')],capture_output=True,text=True)
 assert res.returncode==0,res.stderr
 names=['GROUND.png','PAR.png','COMPOSITE_QA_ONLY.png','GROUND_A_OPEN_MEADOW.png','GROUND_B_CLUSTERED_GARDEN.png','QA_A_OPEN_MEADOW.png','QA_B_CLUSTERED_GARDEN.png','STAGE10_AUTHORING.json']
 cold={x:sha(P/x)==sha(p/x) for x in names}
 assert all(cold.values()),cold
 print('COLD_REBUILD',cold)
mut={}
with tempfile.TemporaryDirectory(prefix='R17_STAGE10_NEG_') as tmp:
 p=Path(tmp)
 Image.open(F).crop((0,0,543,416)).save(p/'bad_width.png')
 mut['1px_wrong_canvas']=check(G,p/'bad_width.png').returncode
 a=f.copy();a.putpixel((0,0),(255,0,0,1));a.save(p/'bad_border.png')
 mut['1px_alpha_border']=check(G,p/'bad_border.png').returncode
 m=json.loads(M.read_text(encoding='utf-8'));m['par']['sha256']='9'*64
 (p/'fake.json').write_text(json.dumps(m),encoding='utf-8')
 mut['forged_source_sha']=check(G,F,p/'fake.json').returncode
assert all(x==2 for x in mut.values()),mut
print('NEGATIVE_MUTATIONS',mut)
art={
 'ground':'HUMAN_ART_HOLD_REVIEW: more coherent dense stone roadway than Stage9, grass is still less painterly and less rich than buildings',
 'par':'HOLD: detailed independent PAR canvas inherited from Stage7, not individually authored 1x sprite assets',
 'scale':'TECH_CANDIDATE: flora patches bounded to 16x12px; no isolated stump; exact actor/world scale not verified',
 'semantics':'HOLD: visible roots complete on PAR, original lowest 32x32 trunk ground-authority not met; floor floral spill from PAR still possible',
 'pair':'TECH_CHECKS_PASS, VISUAL_HOLD_ART_NOT_APPROVED',
 'formal_seal':'NO'}
report={'phase':'R17_STAGE10_V2','result':'TECH_CANDIDATE_ART_HOLD','ground_sha256':sha(G),'par_sha256':sha(F),
 'pixel_composite_mismatch':0,'native_size':[544,416],'ground':'RGB opaque','par':'RGBA native canvas',
 'alpha':alpha,'strict_native_gate_exit':positive.returncode,'cold_rebuild_identical_source_outputs':cold,
 'negative_mutation_exits':mut,'art_gate':art,'nonced_material':'Recomposed Ground from original grass/path Tile art and original geometric Voronoi stones; no Stage9 Ground loaded',
 'par_provenance_warning':manifest['important_limitation']}
(P/'R17_STAGE10_REAL_GATE_AUDIT.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
(P/'CURRENT_HANDOFF_R17_STAGE10.md').write_text('''# R17 Stage10 | Source-art High-density Stone Ground candidate

**TECH CANDIDATE / GROUND ART HOLD / PAR ART & PER-OBJECT SOURCE HOLD / FINAL SEAL NO**.

## Actual progress

This stage **did not load previous Ground bitmap**. Reconstructed two complete native 544x416 RGB Grounds from original grass/path source texture tiles and new Voronoi stone road geometry, with independent bounded 16x12 or smaller low-flora pixel shapes. Warm slate-stone material with dark grout was improved over Stage9; 32x32 tile repeat seams were mitigated using source texture coordinate warp. Ground has no houses, trees, trunks, fences or standalone decorative 3D objects. Native PAR still uses the rich, separately generated Stage7 transparency layer as candidate only.

### Evaluation

- A: open meadow, 68 groups, B: clustered garden, 114 low-height groups. Both independent whole Ground scenes; B chosen as best technical candidate.
- Both images 544x416, Ground RGB and PAR actual RGBA, 0 pixel differences between official RGB composite and reconstructed QA, no border contamination.
- Strict native image and provenance declaration gate returns exit0; cold re-running source-only script reconstructs all 8 outputs with matching SHA; deliberate 1px size, alpha contamination and manifest spoof all fail exit2.
- Compared to Stage9, paths are covered in coherent irregular individually-shaded stone shapes, not a uniform brown trail. Still pixel material and flora mismatch the rich cottage/large tree reference in visual artistry, so **no Art PASS**.
- PAR is an independently generated but historically resampled *composite transparent image*; individual objects are not native editable source sprites. Source-manifest declares common final 544 canvas but does NOT establish independent creation with a common native scene blueprint; resulting visual semantics are HOLD.
- Root contact rule HOLD. Ground avoids user-rejected disembodied trunk. The entire root remains in PAR, differing from historic lowest 32px Ground bark rule. Explicitly requires reconciliation, not silent PASS.
- All sealed FS/K4 binaries, Scripts, Map and passability untouched.

## Next

Stop repeatedly passing Alpha and source hashes. Needs artist-grade Ground source family with more natural texture/shadow/detail and separate high-resolution native PAR object authoring. Formal Seal NO.
''',encoding='utf-8')
# Side-by-side PREVIEW of authentic images, no fake labels.
old=Image.open('/mnt/data/R17_STAGE9_DELIVERY/COMPOSITE_QA_ONLY.png').convert('RGB')
new=Image.open(Q).convert('RGB')
comparison=Image.new('RGB',(1088,445),(25,33,39));comparison.paste(old,(0,29));comparison.paste(new,(544,29))
from PIL import ImageDraw, ImageFont
d=ImageDraw.Draw(comparison)
d.text((12,7),'Stage9 / previous',fill=(235,235,234));d.text((558,7),'Stage10 / source-art cobbled road',fill=(235,235,234))
comparison.save(P/'R17_STAGE9_VS_STAGE10_ACTUAL.png')
# Source files and checks in full archive
z=P/'FS_R17_STAGE10_SOURCE_ART_TECH_CANDIDATE_NO_SEAL.zip'
if z.exists():z.unlink()
with zipfile.ZipFile(z,'w',zipfile.ZIP_DEFLATED,compresslevel=8) as zipfileout:
 for fn in sorted(P.rglob('*')):
  if fn.is_file() and fn!=z and fn.name not in ['build_stage10_ground.py']:
   zipfileout.write(fn,str(fn.relative_to(P)))
with zipfile.ZipFile(z) as zz:assert zz.testzip() is None
print('ZIP',z,'bytes',z.stat().st_size,'sha256',sha(z),'entries',len(zipfile.ZipFile(z).namelist()))
