#!/usr/bin/env python3
from pathlib import Path
import hashlib,json
import numpy as np
from PIL import Image
root=Path(__file__).resolve().parent
def read_img(n,size):
 f=root/n;assert f.read_bytes()[:8]==bytes.fromhex('89504e470d0a1a0a')
 with Image.open(f) as im:
  assert im.size==size,(f,im.size)
  return np.asarray(im.convert('RGB'),dtype=np.uint8).copy()
sample=read_img('A06_GROUND3_SAND_MATERIAL_REF_48.png',(48,48))
assert hashlib.sha256((root/'A06_GROUND3_SAND_MATERIAL_REF_48.png').read_bytes()).hexdigest()=='ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb'
mask=read_img('A05_ROAD_TARGET_MASK_384.png',(384,384))[:,:,0]==255
assert mask.sum()==28818
assert hashlib.sha256((root/'A05_ROAD_TARGET_MASK_384.png').read_bytes()).hexdigest()=='eed1ce659987b37ef074483fad3dd7fdfa17107e49b609ecce6afd83ca2b973e'
before=read_img('A05_FIRST_PASS_GRASS_RESULT.png',(384,384))
final=read_img('A06_SAND_SPECIFIC_REFERENCE_FINAL_384.png',(384,384))
read_img('A05_R2_MIXED_REFERENCE_FINAL.png',(384,384))
read_img('A05_R3_NO_REFERENCE_FINAL.png',(384,384))
changed=np.any(before!=final,axis=2)
assert (changed&mask).sum()==28818
assert (changed&~mask).sum()==0
model=json.loads((root/'A06_SAND_REFERENCE_CONTROLLED_WORKFLOW.json').read_text(encoding='utf8'))
base=json.loads((root/'A05_WORKFLOW_ROAD_INPAINT_API.json').read_text(encoding='utf8'))
changedfields=[]
for node in model:
 assert node in base,node
 for k,v in model[node]['inputs'].items():
  if v!=base[node]['inputs'][k]:changedfields.append((node,k))
assert sorted(changedfields)==sorted([('8','image'),('7','filename_prefix'),('17','filename_prefix')]),changedfields
assert model['8']['inputs']['image']=='A06_GROUND3_SAND_MATERIAL_REF_48.png'
qa=json.loads((root/'A06_MATERIAL_REFERENCE_AB_QA.json').read_text(encoding='utf8'))
assert qa['formal_seal']=='NO' and qa['road_changed_vs_pass1']==28818 and qa['outside_changed_vs_pass1']==0
print('A06_COLD_PASS: reference swap only; 28818 road pixels changed; 0 outside; ART FAIL; Formal Seal NO')
