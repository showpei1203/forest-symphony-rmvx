from pathlib import Path
from PIL import Image,ImageDraw
import json,numpy as np,hashlib
r=Path(__file__).resolve().parent
qa=json.loads((r/'evidence/STAGE13_GPU_PIXEL_QA.json').read_text()) if (r/'evidence/STAGE13_GPU_PIXEL_QA.json').exists() else {}
for s in ('A_BLUE_COTTAGE','B_OCHRE_GROVE'):
    gpu=Image.open(r/'gpu'/s/'FULL_GPU.png').convert('RGB')
    assert gpu.size==(544,416)
v=Image.new("RGB",(544*4,416+38),(31,39,46))
d=ImageDraw.Draw(v)
data=[
 ('STAGE 12 / old A',r/'baseline_stage12'/'STAGE12_GODOT_2_SCENES.png',(0,35,544,451)),
 ('STAGE 13 / new A',r/'gpu/A_BLUE_COTTAGE/FULL_GPU.png',None),
 ('STAGE 12 / old B',r/'baseline_stage12'/'STAGE12_GODOT_2_SCENES.png',(544,35,1088,451)),
 ('STAGE 13 / new B',r/'gpu/B_OCHRE_GROVE/FULL_GPU.png',None)
]
for i,(label,path,rect) in enumerate(data):
    img=Image.open(path).convert('RGB')
    if rect:img=img.crop(rect)
    assert img.size==(544,416), (path,img.size)
    v.paste(img,(i*544,38));d.text((i*544+10,12),label,fill=(245,245,226))
v.save(r/'evidence/STAGE12_VS_STAGE13_SOURCE_COMPARE.png')
# Programmatic provenance, no third-party absolute scene file needed at build time.
source=json.loads((r/'SOURCE_LEDGER.json').read_text(encoding='utf8'))
actual=(r/'source/ground_long.png').read_bytes()
for entry in source:
    if entry['name']=='ground_long.png':
        entry['source_path']='NEW_DETERMINISTIC_GROUND_SOURCE_STAGE13'
        entry['sha256']=hashlib.sha256(actual).hexdigest()
        entry['status']='NEW_AUTHOR_SCRIPT, NOT STYLE_FIRST SOURCE. Art gate FAIL pending human feedback'
(r/'STAGE13_SOURCE_LEDGER.json').write_text(json.dumps(source,indent=2,ensure_ascii=False),encoding='utf8')
report={'new_ground_sha256':hashlib.sha256(actual).hexdigest(),
        'old_ground_sha256':hashlib.sha256((r/'baseline_stage12/ground_long.png').read_bytes()).hexdigest(),
        'new_and_old_distinct':hashlib.sha256(actual).hexdigest()!=hashlib.sha256((r/'baseline_stage12/ground_long.png').read_bytes()).hexdigest(),
        'qa':qa,'art_pass':False,'vx_runtime_pass':False,'formal_seal':False}
(r/'evidence/STAGE13_ART_AND_SOURCE_QA.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print(json.dumps({'new_ground_is_distinct':report['new_and_old_distinct'],'files':['evidence/STAGE12_VS_STAGE13_SOURCE_COMPARE.png','evidence/STAGE13_ART_AND_SOURCE_QA.json']},indent=2))