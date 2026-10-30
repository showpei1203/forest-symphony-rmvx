from PIL import Image, ImageChops, ImageStat, ImageOps, ImageDraw, ImageFont
import numpy as np, pathlib, json, hashlib
p=pathlib.Path(__file__).parent
out=p/'out'
g=Image.open(out/'GROUND.png').convert('RGBA')
o=Image.open(out/'PAR.png').convert('RGBA')
f=Image.open(out/'SCENE_FULL.png').convert('RGBA')
c=Image.alpha_composite(g,o)
c.save(out/'COMPOSITE_PREVIEW.png')
n=np.asarray(c.convert('RGB'),dtype=np.int16)
full=np.asarray(f.convert('RGB'),dtype=np.int16)
dif=np.abs(n-full)
a=np.asarray(o.getchannel('A'), dtype=np.uint8)
tot=a.size
report={
  "test":"FS Route B / Godot 4.7.2 2.5D identical world coordinates",
  "size":list(g.size),
  "ground_mode":g.mode,"par_mode":o.mode,
  "ground_alpha_all_opaque":bool(np.all(np.asarray(g.getchannel('A'))==255)),
  "par_alpha_zero_pixels":int(np.sum(a==0)),
  "par_alpha_nonzero_pixels":int(np.sum(a>0)),
  "par_alpha_0_ratio":float(np.sum(a==0)/tot),
  "par_border_nonzero":int(np.count_nonzero(np.concatenate([a[0,:],a[-1,:],a[:,0],a[:,-1]]))),
  "full_vs_alpha_composite_rgb_mae":float(np.mean(dif)),
  "full_vs_alpha_composite_rgb_max_error":int(dif.max()),
  "full_vs_alpha_composite_differing_pixel_count":int(np.count_nonzero(np.any(dif>0,axis=2))),
  "ground_unique_rgb":int(np.unique(np.asarray(g.convert('RGB')).reshape(-1,3),axis=0).shape[0]),
  "par_unique_rgba":int(np.unique(np.asarray(o).reshape(-1,4),axis=0).shape[0]),
  "hashes_sha256":{x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in sorted(out.glob('*.png'))},
  "visual_result":"HOLD_LOW_POLY_EXPERIMENT_NOT_PIXEL_ART_PASS",
  "formal_seal":False
}
(out/'QA_REPORT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
W,H=g.size
preview=Image.new('RGB',(W*2,H*2+60),(33,39,46))
for i,(title,im) in enumerate([('GROUND from 3D',g),('PAR / transparent',o),('Composite',c),('Independent full render',f)]):
 x=(i%2)*W;y=(i//2)*(H+30)
 # checkerboard only for PAR
 if i==1:
  bg=Image.new('RGBA',im.size,(241,241,241,255))
  dr=ImageDraw.Draw(bg)
  for yy in range(0,H,32):
   for xx in range(0,W,32):
    if (xx//32+yy//32)%2:dr.rectangle([xx,yy,xx+31,yy+31],fill=(192,193,200,255))
  bg.alpha_composite(im)
  preview.paste(bg.convert('RGB'),(x,y+30))
 else:preview.paste(im.convert('RGB'),(x,y+30))
 ImageDraw.Draw(preview).text((x+8,y+8),title,fill=(244,244,236))
preview.save(out/'QA_4PANEL.png')
print(json.dumps({k:v for k,v in report.items() if k!='hashes_sha256'},indent=2))