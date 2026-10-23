# -*- coding: utf-8 -*-
"""T17A licensed original LPC layer alignment test. No changes to game projects."""
import zipfile,io,json,hashlib,sys
from pathlib import Path
from PIL import Image
root=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_T17_20261024")
inputzip=root/"lpc_base_assets.zip"
out=root/"outputs";out.mkdir(exist_ok=True)
def sha(data): return hashlib.sha256(data).hexdigest()
source="https://opengameart.org/content/liberated-pixel-cup-lpc-base-assets-sprites-map-tiles"
actions=[("walk","male_walkcycle.png","male_pants.png",9),
         ("slash","male_slash.png","male_slash_pants.png",6),
         ("spellcast","male_spellcast.png","male_spellcast_pants.png",7)]
dirs=["up","left","down","right"]
rows=[]
with zipfile.ZipFile(inputzip) as z:
  assert z.testzip() is None
  credits=z.read("LPC Base Assets/CREDITS.TXT")
  (root/"CREDITS_original.TXT").write_bytes(credits)
  for action,body_file,overlay_file,cols in actions:
    key="LPC Base Assets/sprites/people/"
    body_bytes=z.read(key+body_file);overlay_bytes=z.read(key+overlay_file)
    body=Image.open(io.BytesIO(body_bytes)).convert("RGBA")
    pants=Image.open(io.BytesIO(overlay_bytes)).convert("RGBA")
    expect=(64*cols,256)
    assert body.size==pants.size==expect,(action,body.size,pants.size,expect)
    whole=Image.alpha_composite(body,pants)
    rebuilt=Image.new("RGBA",expect)
    visible,base_only,overlay_only=[],[],[]
    for row in range(4):
      row_bbox=[]
      for col in range(cols):
        box=(col*64,row*64,col*64+64,row*64+64)
        a=body.crop(box);b=pants.crop(box)
        tile=Image.alpha_composite(a,b)
        rebuilt.paste(tile,(col*64,row*64))
        bb=b.getchannel("A")
        visible.append(sum(v>0 for v in bb.getdata()))
        outside=sum(1 for av,bv in zip(a.getchannel("A").getdata(),bb.getdata()) if bv>0 and av==0)
        overlay_only.append(outside)
      strip=rebuilt.crop((0,row*64,64*cols,(row+1)*64))
      strip.save(out/(action+"_"+dirs[row]+".png"))
    assert rebuilt.tobytes()==whole.tobytes(),action+" cropped vs full compositing mismatch"
    assert len(visible)==cols*4 and min(visible)>0,(action,"blank overlay tile")
    # Negative tests: a 1px horizontal shift is not an equivalent alignment.
    shifted=Image.new("RGBA",expect)
    shifted.paste(pants,(1,0))
    shifted_full=Image.alpha_composite(body,shifted)
    shifted_pixels=sum(1 for a,b in zip(whole.getdata(),shifted_full.getdata()) if a!=b)
    assert shifted_pixels>0,(action,"shift undetected")
    swapped=pants.copy()
    up=pants.crop((0,0,cols*64,64))
    down=pants.crop((0,128,cols*64,192))
    swapped.paste(down,(0,0));swapped.paste(up,(0,128))
    swap_pixels=sum(1 for a,b in zip(whole.getdata(),Image.alpha_composite(body,swapped).getdata()) if a!=b)
    assert swap_pixels>0,(action,"direction swap undetected")
    whole.save(out/(action+"_body_pants_composite.png"))
    rows.append({"action":action,"frames_per_direction":cols,"directions":dirs,"total_frames":cols*4,
                 "canvas":list(expect),"body_sha256":sha(body_bytes),"overlay_sha256":sha(overlay_bytes),
                 "pixel_exact_cel_vs_sheet":True,"overlay_nonempty_all":True,
                 "negative_shift_1px_changed_pixels":shifted_pixels,
                 "negative_swap_up_down_changed_pixels":swap_pixels,
                 "overlay_pixels_outside_body_alpha":sum(overlay_only),
                 "output_sha256":sha((out/(action+"_body_pants_composite.png")).read_bytes())})
manifest={"test":"T17A LPC base body/pants layer alpha alignment","status":"T17A_LPC_3_ACTION_4D_88FRAMES_PASS",
          "source":source,"source_zip_sha256":sha(inputzip.read_bytes()),
          "credits_sha256":sha(credits),"license":"CC-BY-SA-3.0 or GPL-3.0 for LPC Base Assets collection; specific Redshrike parts potentially also OGA-BY 3.0 per credits (requires asset-by-asset review)",
          "rows":rows,"total_frames":sum(x["total_frames"] for x in rows),
          "note":"LPC direction labels [up,left,down,right] are generator convention, not a human visual acceptance for each 2012 source. No weapons/PMD/SBS images tested. No game Scripts touched."}
(root/"T17A_LPC_LAYER_ALIGNMENT.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"status":manifest["status"],"total_frames":manifest["total_frames"],
"actions":[{k:x[k] for k in ("action","total_frames","negative_shift_1px_changed_pixels","negative_swap_up_down_changed_pixels","overlay_pixels_outside_body_alpha")} for x in rows]},ensure_ascii=False,indent=2))
