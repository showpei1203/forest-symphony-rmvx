#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib
root=Path(__file__).resolve().parent
def rgb(n,size=(384,384)):
 p=root/n
 assert p.read_bytes()[:8]==bytes.fromhex('89504e470d0a1a0a')
 with Image.open(p) as im:
  assert im.size==size,(n,im.size)
  return np.asarray(im.convert('RGB'),dtype=np.uint8).copy()
maskrgb=rgb('A07_ADE20K_GRASS9_DIRT_TRACK91_CONTROL.png')
before=rgb('A07_INPUT_PASS1_GRASS.png')
after=rgb('A07_CONTROLNET_DIRT_TRACK_FINAL_384.png')
original_model=rgb('A07_COMFY_NATIVE_STAGE16_A07_CONTROLNET_DIRT_TRACK_FINAL_00001_.png')
assert np.array_equal(after,original_model)
assert hashlib.sha256((root/'A07_COMFY_NATIVE_STAGE16_A07_CONTROLNET_DIRT_TRACK_FINAL_00001_.png').read_bytes()).hexdigest()=='e873fe849124bccbbce6f0ef4b4883103fd589948f0a22a323048cfe5bf69bc6'
p=np.all(maskrgb==[0,10,255],axis=2)
g=np.all(maskrgb==[4,250,7],axis=2)
assert p.sum()==28818 and g.sum()==118638 and (p|g).all(),(p.sum(),g.sum())
diff=np.any(before!=after,axis=2)
assert (diff&p).sum()==28818 and (diff&g).sum()==0
workflow=json.loads((root/'A07_CONTROLNET_DIRT_TRACK_WORKFLOW.json').read_text(encoding='utf8'))
base=json.loads((root/'A07_R3_NO_CONTROLNET_BASELINE_WORKFLOW.json').read_text(encoding='utf8'))
assert workflow['20']['class_type']=='ControlNetApplyAdvanced'
assert workflow['18']['class_type']=='ControlNetLoader'
assert workflow['19']['inputs']['image']=='A07_ADE20K_GRASS9_DIRT_TRACK91_CONTROL.png'
assert workflow['5']['inputs']['positive']==['20',0] and workflow['5']['inputs']['negative']==['20',1]
assert workflow['5']['inputs']['seed']==base['5']['inputs']['seed']==160406
assert workflow['5']['inputs']['latent_image']==base['5']['inputs']['latent_image']
qa=json.loads((root/'A07_CONTROLNET_COMPARATIVE_QA.json').read_text(encoding='utf8'))
assert qa['formal_seal']=='NO' and qa['road_regenerated_pixels']==28818 and qa['outside_changed_pixels']==0
model=json.loads((root/'A07_MODEL_WEIGHT_PROVENANCE.json').read_text(encoding='utf8'))
assert model['actual_sha256']=='acd4dd3df2da2f1f2b9dd00f4504cc0d98b20afb608e25f1789a95c0ccdba14a'
print('A07_COLD_PASS actual ControlNet PNG, semantic palette mask, pixel isolation; ART FAIL; Formal Seal NO')
