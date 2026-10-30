from PIL import Image,ImageDraw,ImageFont,ImageFilter,ImageOps
import numpy as np, pathlib,json,hashlib
root=pathlib.Path(__file__).resolve().parent
out=root/"out"
G=Image.open(out/"GROUND.png").convert("RGB")
P=Image.open(out/"PAR.png").convert("RGBA")
assert G.size==P.size==(544,416)
def compose(g,p):
 return Image.alpha_composite(g.convert("RGBA"),p).convert("RGB")
def posterize_rgb(image,bits):
 return ImageOps.posterize(image.convert("RGB"),bits)
def process_variant(name):
 if name=="A_NATIVE":
  g=G.copy();p=P.copy()
 elif name=="B_PIXEL_2X":
  # Hard 2x sample. Upscale with no interpolation: every color edge stays pixel-crisp.
  g=G.resize((272,208),Image.Resampling.NEAREST).resize(G.size,Image.Resampling.NEAREST)
  p=P.resize((272,208),Image.Resampling.NEAREST).resize(P.size,Image.Resampling.NEAREST)
 elif name=="C_PALETTE_1X":
  # Full-res fixed quantized color - keeps every 1px mask detail. Palette not bilinear.
  g=posterize_rgb(G,5)
  par_arr=np.asarray(P)
  pr=Image.fromarray(par_arr[:,:,:3],"RGB")
  pr=posterize_rgb(pr,5)
  p=Image.merge("RGBA",(*pr.split(),P.getchannel("A")))
 else:raise ValueError(name)
 a=out/name;a.mkdir(exist_ok=True)
 g.save(a/"GROUND.png");p.save(a/"PAR.png")
 c=compose(g,p);c.save(a/"COMPOSITE.png")
 ar=np.asarray(p.getchannel("A"))
 return {"id":name,"mode_ground":g.mode,"mode_par":p.mode,"ground_unique_colors":int(len(np.unique(np.asarray(g).reshape(-1,3),axis=0))),
 "par_opaque_pixels":int((ar==255).sum()),"par_transparent_pixels":int((ar==0).sum()),
 "par_semialpha_pixels":int(((ar>0)&(ar<255)).sum()),"par_border_violations":int(np.count_nonzero(np.r_[ar[0,:],ar[-1,:],ar[:,0],ar[:,-1]])),
 "png_sha256":{f:hashlib.sha256((a/f).read_bytes()).hexdigest() for f in ["GROUND.png","PAR.png","COMPOSITE.png"]},
 "preview":c}
variants=[process_variant(a) for a in ["A_NATIVE","B_PIXEL_2X","C_PALETTE_1X"]]
# Track coverage loss: 1px details and author-intended PAR silhouette.
maskA=np.asarray(P.getchannel("A"))>0
for v in variants:
 mask=np.asarray(Image.open(out/v["id"]/"PAR.png").getchannel("A"))>0
 v["par_mask_pixels_changed_vs_A"]=int(np.count_nonzero(mask^maskA))
 v["par_mask_loss_fraction"]=float(np.sum(maskA & ~mask)/np.sum(maskA))
# Make source-quality side-by-side, full native size per panel.
canvas=Image.new("RGB",(544*3,452),(29,37,42))
d=ImageDraw.Draw(canvas)
labels={"A_NATIVE":"A 原生 1x","B_PIXEL_2X":"B 2x 整數像素化","C_PALETTE_1X":"C 1x 限色保留細節"}
for i,v in enumerate(variants):
 x=i*544
 canvas.paste(v["preview"],(x,34))
 d.text((x+12,10),labels[v["id"]],fill=(250,247,227))
canvas.save(out/"STAGE4_STYLE_ABC.png")
report={"size":[544,416],"authority":"Ground/PAR are independent native 3D capture; style transforms occur separately on both native layers, no master segmentation", "baseline_stage3":"Untextured, flat Ground candidate, ART FAIL","stage4":"Authored 1024x1024 ground biome texture projected in Godot at fixed world coordinates, still ART HOLD","variants":[{k:val for k,val in v.items() if k!="preview"} for v in variants],"seal":"NO","human_visual_gate":"PENDING"}
(out/"STAGE4_STYLE_REPORT.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding="utf-8")
for v in variants:
 print(v["id"], "colors=",v["ground_unique_colors"],"PAR mask changed=",v["par_mask_pixels_changed_vs_A"],"PAR area lost fraction=",round(v["par_mask_loss_fraction"],5),flush=True)
print("ABC",out/"STAGE4_STYLE_ABC.png")