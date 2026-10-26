from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np, zipfile, xml.etree.ElementTree as ET,json,shutil
from io import BytesIO
from scipy.ndimage import label
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
PREV=R/"outputs/P3_G8R4_AUTHENTIC_FRAME_OUTLINE_MAGMA_20261026"
OUT=R/"outputs/P3_G8R5_0003_IDLE_BACK_STRAY_ROCK_FIX_20261027"
assert PREV.is_dir() and not OUT.exists(),"No baseline overwrite"
OUT.mkdir(parents=True)
def png(x):
 b=BytesIO();x.save(b,format="PNG");return b.getvalue()
before_atlas=np.asarray(Image.open(PREV/"0003/Idle-Anim.png").convert("RGBA"))
after_atlas=before_atlas.copy()
assert before_atlas.shape==(256,128,4)
qa={"candidate":"P3_G8R5_0003_IDLE_BACK_STRAY_ROCK_FIX","source_candidate":"G8R4","action":"Idle","direction":4,"edited_frame_indices":[1],"no_other_atlas_pixels_modified":True,"frames":[]}
for f in (0,1):
 orig_cell=before_atlas[128:160,f*32:(f+1)*32].copy()
 yy,xx=np.indices((32,32))
 if f==0:
  # Source F0 back does not have this exterior fragment. Keep it pixel-exact.
  right=np.zeros((32,32),dtype=bool)
  left=np.zeros((32,32),dtype=bool)
 else:
  # Frame1 original 6px fleck near (25..26,8..11) + old G8R4 "bridge",
  # and left peripheral original underlayer pixels around x4..6, y13..17.
  right=(xx>=24)&(yy<=12)
  left=(xx<=6)&(yy>=13)&(yy<=17)
 clip_mask=right|left
 source=PREV/"0003/pixelorama_layers"/f"Idle_back_F{f}.ora"
 export_dir=OUT/"pixelorama_layers";export_dir.mkdir(exist_ok=True)
 with zipfile.ZipFile(source) as zin:
  assert zin.testzip() is None
  doc=ET.fromstring(zin.read("stack.xml"))
  layers=[]
  # All layers except original torso/outline remain totally unchanged except the
  # upper-right old patch pixels originating in R4 top overlay.
  for node in doc.findall(".//layer"):
   name=node.attrib["name"]
   ar=np.asarray(Image.open(BytesIO(zin.read(node.attrib["src"]))).convert("RGBA")).copy()
   alpha_before=ar[:,:,3].copy()
   if name in ("Recolored_Original_Body","Protected_Original_Frog_Body","Clean_Floral_Border_Mineral_Retone","G8R4_Visible_Crater_And_Connected_Outline_Repair"):
    ar[clip_mask]=[0,0,0,0]
   # Original magma/rock unit layering and positions must not move.
   if name.startswith("Round_Basalt_") or name in ("Visible_Magma_Rim_Flame","Magma_Crater","Mount_Saddle"):
    assert np.array_equal(alpha_before,ar[:,:,3]),(f,name,"ROCK_OR_LAVA_MODIFIED")
   layers.append((name,node.attrib["src"],Image.fromarray(ar,"RGBA")))
  corrected=Image.new("RGBA",(32,32))
  # ORA stack: first XML child topmost
  for name,path,img in reversed(layers):corrected=Image.alpha_composite(corrected,img)
  after=np.asarray(corrected.convert("RGBA"))
  actual=np.any(after!=orig_cell,axis=2)
  assert np.all(~actual | clip_mask),(f,"OUTSIDE_TARGET_CHANGED",np.where(actual&~clip_mask))
  changed=int(actual.sum())
  assert (changed==0 if f==0 else changed>=1),(f,"UNEXPECTED_CHANGE_COUNT",changed)
  assert not np.any(after[right,3]>0),(f,"RIGHT_STRAY_STILL_VISIBLE")
  # Left is source-only cleanup: any rocks at x6 may legitimately remain; no
  # left source layer can survive within the identified original peripheral zone.
  for name,path,im in layers:
   if name in ("Recolored_Original_Body","Protected_Original_Frog_Body"):
    a=np.asarray(im)
    assert not np.any(a[left,3]>0),(f,name,"LEFT_OLD_SOURCE_STILL_PRESENT")
  # Real body with central/feet outline stays pixel-identical and unchanged.
  protected=(xx>=8)&(xx<=23)&(yy>=15)
  assert np.array_equal(after[protected],orig_cell[protected]),(f,"REAL_BODY_CHANGED")
  assert np.array_equal(after[-4:,:,:],orig_cell[-4:,:,:]),(f,"FOOT_CHANGE")
  # Every overlay still merges pixel-equal to the patched native atlas.
  target=export_dir/f"Idle_back_F{f}.ora"
  with zipfile.ZipFile(target,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as zout:
   zout.writestr("mimetype","image/openraster",compress_type=zipfile.ZIP_STORED)
   zout.writestr("stack.xml",ET.tostring(doc,encoding="utf-8",xml_declaration=True))
   for name,pth,im in layers:zout.writestr(pth,png(im))
   zout.writestr("mergedimage.png",png(corrected))
   zout.writestr("Thumbnails/thumbnail.png",png(corrected.resize((128,128),Image.Resampling.NEAREST)))
  with zipfile.ZipFile(target) as z:
   assert z.testzip() is None
   merged=np.asarray(Image.open(BytesIO(z.read("mergedimage.png"))).convert("RGBA"))
   assert np.array_equal(merged,after)
  after_atlas[128:160,f*32:(f+1)*32]=after
  (OUT/"keyframes").mkdir(exist_ok=True)
  corrected.save(OUT/"keyframes"/f"Idle_back_F{f}.png")
  # The original rim/hot magma must not vanish due to trimming.
  hot=np.any((after[:,:,:3] >= [230,85,10]) & (after[:,:,:3] <= [255,230,150]),axis=2)&(after[:,:,3]>0)&(yy<15)
  assert np.count_nonzero(hot)>4,(f,"CRATER_DESTROYED")
  qa["frames"].append({"frame":f,"rgba_changed_pixel_count":changed,
      "right_stray_clip_bbox":[24 if f else 27,0,31,12 if f else 14],
      "left_source_clip_bbox":[0,13 if f else 11,6 if f else 5,17],
      "preserved_core_body":True,"preserved_rock_modules":True,
      "preserved_original_magma":True,"corrected_ORA_verified":True})
assert np.array_equal(before_atlas[0:128,:,:],after_atlas[0:128,:,:])
assert np.array_equal(before_atlas[160:,:,:],after_atlas[160:,:,:])
assert np.array_equal(before_atlas[128:160,64:,:],after_atlas[128:160,64:,:])
modified=np.any(after_atlas!=before_atlas,axis=2)
assert not np.any(modified[128:160,0:32])
assert np.count_nonzero(modified)==sum(x["rgba_changed_pixel_count"] for x in qa["frames"])
assert all(np.all(~modified[:,c*32:(c+1)*32]) for c in (2,3))
Image.fromarray(after_atlas,"RGBA").save(OUT/"Idle-Anim.png")
# Compare original candidate and corrected from true 32x32 atlas, zoom nearest-neighbor only.
pic=Image.new("RGB",(920,390),(42,48,54));d=ImageDraw.Draw(pic)
for f in (0,1):
 src=Image.fromarray(before_atlas[128:160,f*32:(f+1)*32])
 dst=Image.fromarray(after_atlas[128:160,f*32:(f+1)*32])
 for k,(label_text,im) in enumerate((("G8R4 original",src),("G8R5 corrected",dst))):
  x=18+f*460+k*215;y=28
  up=im.resize((192,192),Image.Resampling.NEAREST)
  # neutral checker behind sprites, with nearest neighbor exact pixels
  back=Image.new("RGB",(192,192),(197,194,188))
  back.paste(up,(0,0),up)
  pic.paste(back,(x,y))
  d.text((x,y+201),f"Idle Back F{f} | {label_text}",fill=(245,228,198))
d.text((16,286),"ONLY 0003 Idle Back F0/F1 changed. ROCK / LAVA / XML unchanged.",fill=(231,221,205))
d.text((16,306),"Target: right upper extraneous fragment and left peripheral old decoration.",fill=(213,226,215))
pic.save(OUT/"G8R5_0003_IDLE_BACK_G8R4_VS_FIXED_6X.png")
qa["total_changed_32px_pixels"]=int(np.count_nonzero(modified))
(OUT/"G8R5_0003_IDLE_BACK_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf-8")
print("G8R5_NATIVE_ATLAS_EDIT_PASS",json.dumps(qa,ensure_ascii=False),flush=True)
