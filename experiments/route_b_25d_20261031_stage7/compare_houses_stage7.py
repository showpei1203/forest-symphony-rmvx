from PIL import Image,ImageDraw
from pathlib import Path
import json
root=Path(__file__).resolve().parent
cases=[('medieval_timber_small','A: Low-poly Timber House'),('medieval_thatch_cottage','B: Low-poly Thatched Cottage'),('witch_cottage','C: Textured Witch Cottage')]
W,H=544,416
canvas=Image.new('RGB',(W*3,H+42),(31,39,44))
dr=ImageDraw.Draw(canvas)
rows=[]
for i,(name,label) in enumerate(cases):
 p=root/'candidates'/name/'COMPOSITE_PREVIEW.png'
 im=Image.open(p).convert('RGB')
 canvas.paste(im,(i*W,42))
 dr.text((i*W+10,13),label,fill=(249,247,236))
 r=json.loads((root/'candidates'/name/'QA_REPORT.json').read_text())
 rows.append({'name':name,'pixel_difference':r['full_vs_alpha_composite_differing_pixel_count'],'par_border_nonzero':r['par_border_nonzero'],'unique_par_rgba':r['par_unique_rgba'],'ground_unique_rgb':r['ground_unique_rgb']})
canvas.save(root/'out'/'STAGE7_THREE_HOUSE_COMPARISON.png')
(root/'out'/'STAGE7_CANDIDATE_QA.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
print(rows)