# -*- coding: utf-8 -*-
"""Audit actual 24 Godot 4.7 GPU screenshots against source cell pixel geometry."""
from PIL import Image
from pathlib import Path
import hashlib,json,sys
ROOT=Path(__file__).resolve().parent
proj=ROOT/"godot"/"LPC128_24frame"
CAP=proj/"captures"
SOURCE=Image.open(ROOT/"outputs"/"T17D1_ARMING_SWORD_HEAD_HAIR_128.png").convert("RGBA")
assert SOURCE.size==(768,512)
files=[]
for d in range(4):
 for f in range(6):
  p=CAP/(f"T17D2_{d}_{f}.png")
  assert p.is_file(),str(p)
  im=Image.open(p).convert("RGBA")
  assert im.size==(160,160)
  cell=SOURCE.crop((f*128,d*128,(f+1)*128,(d+1)*128))
  # Rendered engine background: derive via definite unsprited upper-left viewport.
  bg=im.getpixel((0,0))
  bgim=Image.new("RGBA",(128,128),bg)
  expected=Image.alpha_composite(bgim,cell)
  actual=im.crop((16,16,144,144))
  exp_pix=list(expected.get_flattened_data())
  obs_pix=list(actual.get_flattened_data())
  differences=[(sum(abs(e[i]-o[i]) for i in range(3))) for e,o in zip(exp_pix,obs_pix)]
  total_rgb_error=sum(differences)
  diff_pixels=sum(v>0 for v in differences)
  max_channel_error=max((max(abs(e[i]-o[i]) for i in range(3)) for e,o in zip(exp_pix,obs_pix)),default=0)
  border=Image.new("RGBA",(160,160),bg)
  border.alpha_composite(im.crop((16,16,144,144)),(16,16))
  outside=sum(a!=b for a,b in zip(im.get_flattened_data(),border.get_flattened_data()))
  files.append({"direction":d,"frame":f,"sha256":hashlib.sha256(p.read_bytes()).hexdigest(),
    "bg_rgba":bg,"num_source_visible_pixels":sum(a>0 for a in cell.getchannel("A").get_flattened_data()),
    "diff_rgb_pixels_vs_expected_rgba_over_bg":diff_pixels,"sum_rgb_channel_errors":total_rgb_error,
    "max_channel_error":max_channel_error,"outside_128_drawregion_diff_pixels":outside})
uni=len({r["sha256"] for r in files})
maxerr=max(x["max_channel_error"] for x in files)
total_diff=sum(x["diff_rgb_pixels_vs_expected_rgba_over_bg"] for x in files)
outside=sum(x["outside_128_drawregion_diff_pixels"] for x in files)
result={"status":"T17D2_NATIVE_GODOT_GPU_24_CAPTURE_PASS" if uni==24 and outside==0 else "T17D2_FAIL_CLOSED",
 "gpu":"Godot 4.7.2 OpenGL 3.3 RX 6700XT; observed from T17D2_GPU.log",
 "captured_frames":len(files),"distinct_screenshot_hashes":uni,
 "max_rgb_channel_error_vs_expected_blend":maxerr,
 "total_diff_rgb_pixels_vs_expected_blend":total_diff,
 "outside_drawregion_total_changed":outside,
 "foot_pivot":"engine Sprite2D top-left (16,16) for 128px attack canvas; pivot relative (64,96) CANDIDATE not approved",
 "reports":files,"limitations":"No VX/SBS runtime test, no animation timing/attack hit frame, no human pixel review"}
(ROOT/"T17D2_GODOT_GPU_RENDER_AUDIT.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({k:v for k,v in result.items() if k not in ("reports","limitations")},ensure_ascii=False,indent=2))
sys.exit(0 if result["status"].endswith("PASS") else 2)
