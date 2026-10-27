import numpy as np, torch, json, cv2
from PIL import Image
from pathlib import Path
from sam2.build_sam import build_sam2
from sam2.sam2_image_predictor import SAM2ImagePredictor
out=Path("/mnt/e/GameAssetToolLab_20261023/FS_MasterSplit_Research_20261027/SCENE21_GUIDED_SAM2_CANDIDATE")
rgb=np.asarray(Image.open(out/"MASTER_RGBA.png").convert("RGB"))
model=build_sam2("configs/sam2.1/sam2.1_hiera_s.yaml","checkpoints/sam2.1_hiera_small.pt",device="cpu")
pr=SAM2ImagePredictor(model)
with torch.inference_mode():
 pr.set_image(rgb)
 # geom: right-tree crown, trunk; exclude separate shrub below-right
 pts=np.array([[465,155],[468,204],[480,263]],dtype=np.float32)
 labs=np.array([1,1,0],dtype=np.int32)
 masks,scores,_=pr.predict(box=np.array([419,101,526,252],dtype=np.float32),point_coords=pts,point_labels=labs,multimask_output=True)
 raw=np.asarray(Image.open(out/"right_tree_SAM2_RAW.png"))>0
 d=[]
 for i,(m,score) in enumerate(zip(masks,scores)):
  m=np.asarray(m).astype(bool)
  fn=f"right_tree_prompt_v2_variant{i}.png"
  Image.fromarray((m*255).astype(np.uint8)).save(out/fn)
  ov=rgb.copy();ov[m]=(ov[m]*.4+np.array([247,60,202])*.6).astype(np.uint8)
  Image.fromarray(ov).save(out/f"right_tree_prompt_v2_overlay{i}.png")
  y,x=np.where(m);bbox=[int(x.min()),int(y.min()),int(x.max()),int(y.max())] if len(x) else None
  d.append({"variant":i,"sam_score":float(score),"mask_pixels":int(m.sum()),"box":bbox,
   "removed_vs_raw":int(np.sum(raw&~m)),"new_vs_raw":int(np.sum(m&~raw)),
   "negative_point_in_mask":bool(m[263,480]),"positive_point_in_mask":bool(m[155,465])})
 (out/"right_tree_refinement_v2.json").write_text(json.dumps(d,indent=2))
 print(json.dumps(d))