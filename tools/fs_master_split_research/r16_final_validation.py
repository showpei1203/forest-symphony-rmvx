#!/usr/bin/env python3
"""R16 actual Godot vs unchanged artwork, selected mask candidate, tool status fail-closed.
Image compositing overlap pixel=0 is necessary and NOT evidence semantic clean background.
"""
from pathlib import Path
from PIL import Image,ImageChops,ImageDraw
import json,hashlib,subprocess
R=Path(__file__).resolve().parent;D=R/"R16_MODEL_TOOL_EVAL_20261028";G=D/"godot_selected3";E=G/"exported"
orig=Image.open(R/"R12_NEW_ELF_VILLAGE_001"/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png").convert("RGB")
got={name:Image.open(E/("R15_"+name+".png")).convert("RGBA") for name in ["MASTER","PAR","COMPOSITE","ACTOR_BACK","ACTOR_FRONT"]}
assert all(v.size==(1280,928) for v in got.values())
def diffpx(a,b):
 delta=ImageChops.difference(a.convert("RGB"),b.convert("RGB"))
 return sum(1 for px in delta.getdata() if any(px[:3]))
orig_diff=diffpx(got["MASTER"],orig)
composite_diff=diffpx(got["COMPOSITE"],orig)
assert orig_diff==composite_diff==0
par=got["PAR"]
alpha=par.getchannel("A")
opa_count=sum(bool(v) for v in alpha.getdata())
delta=ImageChops.difference(par.convert("RGB"),orig)
assert Image.composite(delta,Image.new("RGB",orig.size,(0,0,0)),alpha).getbbox() is None
mask=json.loads((D/"R16_GRABCUT_SAM2_GATE.json").read_text(encoding="utf8"))
layer=json.loads((D/"R16_LAYERDIFFUSE_PAD_GATE.json").read_text(encoding="utf8"))
items=json.loads((D/"R16_GODOT_SOURCE_MASK_MANIFEST.json").read_text(encoding="utf8"))
assert len(items["candidate_masks"])==3
assert mask["accepted_count"]==2
assert len(layer["results"])==3
# matte comparison side-by-side PNG, no claims of art gate success
board=Image.new("RGB",(1300,990),(24,27,30));draw=ImageDraw.Draw(board)
for i,(key,text) in enumerate([("MASTER","MASTER original 1280x928 unchanged"),
 ("PAR","R16 selected 3 source RGB masks"),
 ("COMPOSITE","Godot composite SourceMaster + masks exact"),
 ("ACTOR_FRONT","Godot real engine actor front, masks depth")]):
 x=(i%2)*650;y=(i//2)*495
 bg=Image.new("RGBA",(1280,928),(33,35,39,255))
 bg.alpha_composite(got[key])
 board.paste(bg.convert("RGB").resize((640,464),Image.Resampling.NEAREST),(x+5,y+26))
 draw.text((x+12,y+7),text,fill=(248,248,249))
board.save(D/"R16_GODOT_FINAL_4PANEL.png")
results={"status":"R16_LOCAL_MODEL_TOOL_TRIAL_2OF3_MASK_REFINE_GODOT_1280X928_TECH_PASS_ART_HOLD",
"actual_Godot_4_7_2_GPU_run":True,
"original_R12_Master_sha256":hashlib.sha256((R/"R12_NEW_ELF_VILLAGE_001"/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png").read_bytes()).hexdigest(),
"original_master_vs_godot_MASTER_RGB_difference_px":orig_diff,
"original_master_vs_godot_COMPOSITE_RGB_difference_px":composite_diff,
"PAR_selected_RGB_exact_to_original_master":True,
"PAR_alpha_opaque_px":opa_count,
"selected_masks_count":3,"graphcut_mask_refinements_accepted":2,
"red_cafe_graphcut_worsened_ground_overlap_and_rejected":True,
"LayerDiffuse_official_RGB_padding_function_executed_CPU":True,
"LayerDiffuse_full_diffusion_model_executed":False,
"SAM3_cloned":True,
"SAM3_full_inference_executed":False,
"SAM3_import_dependency_error":"ModuleNotFoundError: pkg_resources",
"SAM3_no_native_CUDA_GPU":True,
"QwenImageLayered_cloned":True,
"QwenImageLayered_full_20B_inference_executed":False,
"PixelART_code_weights_verified":False,
"art_precision_gate":"HOLD",
"full_village_PAR_completed":False,
"native_FS_VX_game_integration_this_cycle":False,
"formal_FS_scripts_and_sealed_assets_changed":False,
"diagnosis":"graphcut is useful constrained local fallback; even 2/3 automatic checks not guarantee clean contours; Qwen/SAM3 hardware/model availability blocks real inference"}
(D/"R16_FINAL_GATE.json").write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding="utf8")
print("R16_FINAL_GATE",json.dumps({k:results[k] for k in ["status","original_master_vs_godot_MASTER_RGB_difference_px","original_master_vs_godot_COMPOSITE_RGB_difference_px","PAR_alpha_opaque_px","graphcut_mask_refinements_accepted"]},ensure_ascii=False),flush=True)