from pathlib import Path
import json,hashlib,subprocess,sys
import numpy as np
from PIL import Image
R=Path(__file__).resolve().parent
sha=lambda n:hashlib.sha256((R/n).read_bytes()).hexdigest()
expected={
 'A13_A12_FINAL_COMPARATOR_544x416.png':'174fbcd122acb5cf99117e048a42834975d5780d8d9b87380a01219823774d00',
 'A13_BOTANICAL_MOTIFS_RGBA_8x16.png':'08969eb8b33e4112312801a12bc0afc81accccca77315827f7879e900d4e4f40',
 'A13_BOTANICAL_CLUSTER_GROUND_544x416.png':'3078a9170ab973ad36398a315c6c4e29857aa49792c1cf6e5b8b7e91b8273475',
 'A13_R2_PALETTE_HARMONIZED_544x416.png':'14dcbee8a6c2d5b4fcdf12d6ffa7f1f95a581bbb006c44889279ce30296485d8'
}
for n,v in expected.items():assert sha(n)==v,(n,sha(n))
def arr(n):
 with Image.open(R/n) as im:
  assert im.size==(544,416)
  return np.asarray(im.convert('RGB'),dtype=np.uint8).copy()
def mask(n):
 with Image.open(R/n) as im:return np.asarray(im.convert('L'))>0
a12=arr('A13_A12_FINAL_COMPARATOR_544x416.png')
r1=arr('A13_BOTANICAL_CLUSTER_GROUND_544x416.png')
r2=arr('A13_R2_PALETTE_HARMONIZED_544x416.png')
soil=mask('A13_SOIL_LEGAL_PIXELS.png')
protected=mask('A13_PROTECTED_MASK.png')
motif=mask('A13_NEW_MOTIF_PIXELS_MASK.png')
old=mask('A13_OLD_DOTS_REPLACED_MASK.png')
assert int(protected.sum())==47649 and int(soil.sum())==900
assert np.array_equal(r1[protected],a12[protected])
assert np.array_equal(r2[protected],a12[protected])
assert np.array_equal(r2[soil],a12[soil])
assert not np.any(np.any(r1!=a12,axis=2)&~(motif|old))
assert not np.any(np.any(r1!=r2,axis=2)&~motif)
atlas=np.asarray(Image.open(R/'A13_BOTANICAL_MOTIFS_RGBA_8x16.png').convert('RGBA'))
assert atlas.shape==(16,128,4) and set(np.unique(atlas[:,:,3]).tolist())=={0,255}
placements=json.loads((R/'A13_SPRITE_PLACEMENTS.json').read_text(encoding='utf8'))
assert len(placements)==292
assert sum(x['kind']=='flower' for x in placements)==82
assert sum(x['kind']=='cover' for x in placements)==210
q=json.loads((R/'A13_GENERATION_QA.json').read_text(encoding='utf8'))
q2=json.loads((R/'A13_R1_R2_CONTROLLED_AB_QA.json').read_text(encoding='utf8'))
assert q['protected_changed_px']==q['illegal_diff_outside_old_and_new_motifs_px']==0
assert q2['road_and_transition_unchanged']==q2['soil_unchanged']==q2['illegal_changed_outside_new_motif_pixels']==0
assert q['formal_seal']==q2['formal_seal']=='NO'
assert q['visual_art']==q2['art']=='FAIL_INTERNAL_GROUND3_STYLE'
# Cold reproduce truly regenerates atlas, R1 and R2, not just reread files.
rebuilt=['A13_BOTANICAL_MOTIFS_RGBA_8x16.png','A13_BOTANICAL_MOTIFS_NEAREST8X_PREVIEW.png','A13_MOTIF_ATLAS_MANIFEST.json','A13_BOTANICAL_CLUSTER_GROUND_544x416.png','A13_REPLACEMENT_BASE_544x416.png','A13_SPRITE_PLACEMENTS.json','A13_GENERATION_QA.json','A13_NEW_MOTIF_PIXELS_MASK.png','A13_FLOWER_PIXELS_MASK.png','A13_COVER_PIXELS_MASK.png','A13_OLD_DOTS_REPLACED_MASK.png','A13_R2_PALETTE_HARMONIZED_544x416.png','A13_R2_CHANGED_ALLOWED_MASK.png','A13_R1_R2_CONTROLLED_AB_QA.json','A13_A12_R1_R2_1X_COMPARISON.png','A13_A12_R1_R2_32PX_AUDIT.png']
original_hash={n:sha(n) for n in rebuilt}
for script in ('a13_author_motifs.py','a13_place_motifs.py','a13_r2_palette_ab.py'):
 result=subprocess.run([sys.executable,str(R/script)],cwd=R,capture_output=True,text=True,encoding='utf8',errors='replace',timeout=90)
 assert result.returncode==0,(script,result.stdout,result.stderr)
for n,h in original_hash.items():assert sha(n)==h,'COLD REBUILD DIFFERENCE: '+n
print('A13_COLD_REGEN_PASS: exact RGBA atlas, 292 placements, native R1/R2 PNG and layer masks')
print('A13_SOURCE_GATE: 47649 protected pixels unchanged, 900 soil source pixels unchanged')
print('A13_VISUAL_GATE: Ground3 ART FAIL / Godot NOT RUN / VX NOT RUN / Formal Seal NO')
