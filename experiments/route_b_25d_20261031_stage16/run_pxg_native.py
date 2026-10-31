from pathlib import Path
import sys,json,hashlib,subprocess
import numpy as np
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
repo=R/"PXG-Tiny-AI"
sys.path.insert(0,str(repo/"src"))
from pxg_tiny.pipeline import PXGPipeline
from pxg_tiny.render import grid_to_rgba
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
pipe=PXGPipeline(repo/"weights")
git=subprocess.run(["git","-C",str(repo),"rev-parse","HEAD"],capture_output=True,text=True,check=True).stdout.strip()
weights={f.name:sha(f) for f in sorted((repo/"weights").iterdir()) if f.is_file()}
cases=[
 {"id":"T1_GRASS","prompt":"a grass tile","seed":17001},
 {"id":"T2_STONE","prompt":"a stone tile","seed":17002},
 {"id":"T3_WILDFLOWERS","prompt":"a colorful patch of wildflowers on the meadow floor","seed":17003}
]
records=[]
sheet=Image.new("RGB",(3*260,321),(25,27,30))
draw=ImageDraw.Draw(sheet)
for i,c in enumerate(cases):
 grid,meta=pipe.generate_pixels(c["prompt"],seed=c["seed"],enforce_quality=True)
 rec=dict(c,meta=meta,native=(grid is not None))
 x=i*260
 draw.text((x+3,5),c["id"],fill="white")
 draw.text((x+3,21),c["prompt"][:27],fill="white")
 if grid is None:
  draw.text((x+4,125),"UNSUPPORTED",fill="white")
 else:
  assert grid.shape==(16,16)
  rgba=grid_to_rgba(grid)
  assert rgba.shape==(16,16,4)
  original=R/(c["id"]+"_NATIVE16_RGBA.png")
  Image.fromarray(rgba,"RGBA").save(original)
  enlarged=Image.fromarray(rgba,"RGBA").resize((256,256),Image.Resampling.NEAREST)
  sheet.paste(enlarged,(x+2,45),enlarged)
  rec.update({"file":original.name,"sha256":sha(original),"size":[16,16],"colors_rgba":len(np.unique(rgba.reshape(-1,4),axis=0)),"opaque_pixels":int((rgba[:,:,3]==255).sum()),"transparent_pixels":int((rgba[:,:,3]==0).sum()),"model_first_attempt":meta.get("attempt")==0})
 records.append(rec)
sheet.save(R/"A17_PXG_TINY_NATIVE_16PX_AUDIT.png")
data={"stage":"A17","date":"2026-10-31","model":"PXG-Tiny v0.4 native-palette 16x16","repo":"https://github.com/tarulahsan/PXG-Tiny-AI","repo_commit":git,"weight_files_sha256":weights,"implementation":"Actual pretrained weights from Git clone and NumPy autoregressive pipeline, NOT hand-drawn dummy and not SD resize","generations":records,"user_ground3_match":"NOT_APPROVED","max_resolution_model":[16,16],"no_full_544x416_model_run":True,"pixel_lab_API":"NO_AUTHENTICATED_ACCOUNT_KEY_IN_EXECUTION_ENV","retro_diffusion_API":"NO_AUTHENTICATED_ACCOUNT_KEY_IN_EXECUTION_ENV","formal_seal":"NO"}
(R/"A17_PXG_MODEL_TRIAL.json").write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding="utf8")
print("A17_PXG_TRIAL_RESULTS",json.dumps(data,ensure_ascii=False)[:3500],flush=True)
