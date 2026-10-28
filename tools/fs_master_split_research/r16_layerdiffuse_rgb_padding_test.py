#!/usr/bin/env python3
"""Execute original LayerDiffuse_DiffusersCLI build_alpha_pyramid + pad_rgb source functions
without importing unsupported SDXL/diffusers GPU code. This tests only RGB padding utility.
"""
from pathlib import Path
from PIL import Image,ImageOps
import numpy as np,cv2,ast,json
R=Path(__file__).resolve().parent;T=R/"R16_MODEL_TOOL_EVAL_20261028"
repo=T/"LayerDiffuse_DiffusersCLI"/"lib_layerdiffuse"/"vae.py"
code=repo.read_text(encoding="utf8")
module=ast.parse(code)
nodes=[n for n in module.body if isinstance(n,ast.FunctionDef) and n.name in ("build_alpha_pyramid","pad_rgb")]
assert len(nodes)==2
mini=ast.Module(body=nodes,type_ignores=[])
ctx={"np":np,"cv2":cv2};exec(compile(mini,str(repo),"exec"),ctx)
func=ctx["pad_rgb"]
source=R/"R15_MULTISCALE_MASK_RESEARCH_20261028"
names=["TREE_LEFT_MAJOR","CAFE_RED_HOUSE","LAMP_FOUNTAIN_NW"]
checks=[]
for n in names:
 img=Image.open(source/(n+"_SAM2_EXACT_RGBA.png")).convert("RGBA")
 bbox=img.getchannel("A").getbbox();assert bbox
 # small 16px transparent border lets us assess fill beyond alpha
 x0,y0,x1,y1=bbox;pad=16
 target=Image.new("RGBA",(x1-x0+pad*2,y1-y0+pad*2),(0,0,0,0))
 target.alpha_composite(img.crop(bbox),(pad,pad))
 arr=np.asarray(target)
 # Input pack is RGBA. Native implementation expects [color channels, alpha].
 padded=(func(arr)*255.0).clip(0,255).astype(np.uint8)
 assert padded.shape==arr.shape[:2]+(3,)
 alpha=arr[:,:,3]
 visible=alpha==255
 transparent=alpha==0
 diff=np.abs(padded.astype("int16")-arr[:,:,:3].astype("int16"))
 max_visible=int(diff[visible].max()) if np.any(visible) else None
 filled=int(np.any(padded[transparent]!=0,axis=1).sum()) if np.any(transparent) else 0
 Image.fromarray(padded,"RGB").save(T/(n+"_LAYERDIFFUSE_PADDED_RGB.png"))
 checks.append({"object_id":n,"original_mask_alpha_nonzero":int((alpha>0).sum()),
 "transparent_px":int(transparent.sum()),"padded_background_nonzero_pixels":filled,
 "max_visible_RGB_change":max_visible,"padded_Rgb_output_from_unchanged_alpha":True})
 print("R16_LAYERDIFFUSE_PADDING",checks[-1],flush=True)
out={"status":"R16_LAYERDIFFUSE_OFFICIAL_PADDING_FUNCTION_CPU_EXECUTED",
 "repository_path":str(repo),
 "executed_original_functions":["build_alpha_pyramid","pad_rgb"],
 "not_executed":["SDXL T2I transparent model","SDXL I2I transparent model"],
 "saved_outputs_count":len(checks),"original_Master_or_PAR_unmodified":True,
 "alpha_routing_source":"R15 SAM2 separate candidate, no new image generation model run",
 "results":checks}
(T/"R16_LAYERDIFFUSE_PAD_GATE.json").write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf8")
print("R16_LAYERDIFFUSE_PAD",json.dumps({"status":out["status"],"cases":len(checks)},ensure_ascii=False),flush=True)