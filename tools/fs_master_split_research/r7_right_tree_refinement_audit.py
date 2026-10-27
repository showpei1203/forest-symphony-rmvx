from pathlib import Path
from PIL import Image
import numpy as np,json
R=Path(__file__).resolve().parent
old=np.asarray(Image.open(R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"right_tree_SAM2_RAW.png").convert("L"))>0
refined=np.asarray(Image.open(R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"right_tree_prompt_v2_variant1.png").convert("L"))>0
new=np.asarray(Image.open(R/"R7_SEMANTIC_MASK_CANDIDATES"/"right_deciduous_SAM2_FULL_SEMANTIC_MASK.png").convert("L"))>0
r=np.zeros_like(old);r[240:311,430:544]=True
results={"old_raw_mask_px":int(old.sum()),"prior_prompt_refined_mask_px":int(refined.sum()),"r7_new_prompt_mask_px":int(new.sum()),
"comparison_lower_right_rect":[430,240,544,311],
"old_raw_overlap_with_lower_right_px":int((old&r).sum()),
"prior_refined_overlap_with_lower_right_px":int((refined&r).sum()),
"r7_overlap_with_lower_right_px":int((new&r).sum()),
"semantic_label":"SUSPECT_ONLY: lower-right region includes both trunk/contact and shrubs; false positives require visual comparison",
"art_status":"HOLD"}
(R/"R7_SEMANTIC_MASK_CANDIDATES"/"R7_RIGHT_TREE_REFINEMENT_AUDIT.json").write_text(json.dumps(results,indent=2),encoding="utf8")
print(json.dumps(results),flush=True)