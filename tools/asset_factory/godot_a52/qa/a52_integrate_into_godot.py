from pathlib import Path
from PIL import Image
import glob,shutil,json,hashlib
root=Path(glob.glob("G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries")[0])
p=root/"FS_A52_LEG_WEIGHT_TRANSFER_REAL_PIXELLAB_20261116"
a51=root/"FS_A51_ATTACK_ANTICIPATION_TRUE_PIXELLAB_20261116"
src=a51/"godot_a51_r4_stable_fx"
out=p/"godot_a52_lower_body_lunge"
assert src.is_dir()
if out.exists():
 assert not (p/'A52_GODOT_INTEGRATION_QA.json').exists(),'Prevent overwriting a completed A52 project'
 shutil.rmtree(out)
check=json.loads((p/"A52_REAL_MODEL_LOWER_BODY_ART_QA.json").read_text(encoding="utf8"))
# Whole model is genuine PixelLab output, no person cut-and-paste.
assert check["real_provider_job_id"]=="094a45f9-c279-4c06-94e4-a1708a13daac"
shutil.copytree(src,out,ignore=shutil.ignore_patterns(".godot","*.import","__pycache__"))
asset=out/"assets"
body=Image.open(p/"A52_REAL_MODEL_BODY_12FRAME_256x192.png").convert("RGBA")
weapon=Image.open(asset/"actor01_a50_r4_weapon_12frames.png").convert("RGBA")
fx=Image.open(asset/"actor01_a51_r4_stable_fx_12frames.png").convert("RGBA")
def section(im,i):return im.crop((i%4*64,i//4*64,i%4*64+64,i//4*64+64))
def components(im):
 pts={(x,y)for y in range(64) for x in range(64)if im.getpixel((x,y))[3]}
 sizes=[]
 while pts:
  st=[pts.pop()];n=1
  while st:
   x,y=st.pop()
   for xx in range(x-1,x+2):
    for yy in range(y-1,y+2):
     if (xx,yy) in pts:pts.remove((xx,yy));st.append((xx,yy));n+=1
  sizes.append(n)
 return sorted(sizes,reverse=True)
# If model's sword hand shifts subtly, move Weapon/FX only, max 2px; never cut or redraw Body.
adjustment=[]
newweapon=Image.new("RGBA",(256,192))
newfx=Image.new("RGBA",(256,192))
anchors=json.loads((asset/"actor01_a50_r4_attack_anchors.json").read_text(encoding="utf8"))
for i in range(12):
 b=section(body,i);w=section(weapon,i);t=section(fx,i)
 n_w=sum(px[3]>0 for px in w.get_flattened_data())
 options=[]
 for dx in range(-2,3):
  for dy in range(-2,3):
   shifted=Image.new("RGBA",(64,64));shifted.paste(w,(dx,dy))
   if sum(px[3]>0 for px in shifted.get_flattened_data())!=n_w:continue
   mixed=b.copy();mixed.alpha_composite(shifted)
   connected=len(components(mixed))==1
   if connected:options.append((abs(dx)+abs(dy),abs(dx),abs(dy),dx,dy))
 if not options:raise RuntimeError("A52 PixelLab body and existing sword separated on frame "+str(i))
 _,_,_,dx,dy=min(options)
 shiftedw=Image.new("RGBA",(64,64));shiftedw.paste(w,(dx,dy))
 shiftedf=Image.new("RGBA",(64,64));shiftedf.paste(t,(dx,dy))
 newweapon.alpha_composite(shiftedw,(i%4*64,i//4*64))
 newfx.alpha_composite(shiftedf,(i%4*64,i//4*64))
 pose=anchors["pose_anchors"][i]
 for key in ("wrist_px","hit_marker_local_px","sword_tip_px"):
  if isinstance(pose.get(key),list)and len(pose[key])==2:
   pose[key]=[pose[key][0]+dx,pose[key][1]+dy]
 adjustment.append({"frame":i,"weapon_dx":dx,"weapon_dy":dy,"body_sword_one_connected_component":True,
                    "raw_model_body_single_component":len(components(b))==1})
assert all(x["raw_model_body_single_component"]for x in adjustment),"Original provider Body malformed"
bodyfile=asset/"actor01_a52_body_12frames.png"
weaponfile=asset/"actor01_a52_weapon_12frames.png"
fxfile=asset/"actor01_a52_fx_12frames.png"
body.save(bodyfile);newweapon.save(weaponfile);newfx.save(fxfile)
assert bodyfile.read_bytes()==(p/"A52_REAL_MODEL_BODY_12FRAME_256x192.png").read_bytes()
anc=asset/"actor01_a52_attack_anchors.json"
anchors["stage"]="A52"
anchors["provenance"]="True PixelLab Skeleton V3 094a45f9-c279-4c06-94e4-a1708a13daac; lower-body stage; independent unchanged-aesthetic sword with verified rigid shifts"
anc.write_text(json.dumps(anchors,indent=2),encoding="utf8")
combined=body.copy();combined.alpha_composite(newweapon);combined.alpha_composite(newfx)
composite=asset/"actor01_a52_composite_reference.png"
combined.save(composite)
man=asset/"actor01_animation_manifest.json"
manifest=json.loads(man.read_text(encoding="utf8"))
manifest["animation_profiles"]["attack_weighted"]["sprite_sheet"]="res://assets/actor01_a52_body_12frames.png"
manifest["animation_profiles"]["attack_weighted"]["provenance"]="10 real new 64x64 PixelLab A52 lower-body weight-shift poses, first/last A62, independent true PixelLab original sword with position-aligned FX"
manifest["animation_profiles"]["attack_weighted"]["art_gate"]="HOLD: user requested stronger lower body movement, check visual identity/foot motion"
for layer in ["body","weapon","fx"]:manifest["layering"][layer]="res://assets/actor01_a52_"+layer+"_12frames.png"
manifest["layering"]["geometry"]="res://assets/actor01_a52_attack_anchors.json"
man.write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding="utf8")
script=out/"scripts/fs_actor_animator.gd"
code=script.read_text(encoding="utf8")
for old,new in [
 ("actor01_a50_r4_attack_anchors.json","actor01_a52_attack_anchors.json"),
 ("actor01_a50_r4_weapon_12frames.png","actor01_a52_weapon_12frames.png"),
 ("actor01_a51_r4_stable_fx_12frames.png","actor01_a52_fx_12frames.png")]:
 assert code.count(old)==1,(old,code.count(old))
 code=code.replace(old,new)
script.write_text(code,encoding="utf8")
gpu=out/"qa/a51_safe_native_gpu_runtime_qa.gd"
g=gpu.read_text(encoding="utf8")
for old,new in [
 ("actor01_a50_r4_body_12frames.png","actor01_a52_body_12frames.png"),
 ("actor01_a50_r4_weapon_12frames.png","actor01_a52_weapon_12frames.png"),
 ("actor01_a51_r4_stable_fx_12frames.png","actor01_a52_fx_12frames.png"),
 ("actor01_a51_r4_stable_composite_reference.png","actor01_a52_composite_reference.png"),
 ("A51_SAFE_","A52_"),("a51safe","a52"),("a51_safe_","a52_")]:
 g=g.replace(old,new)
assert "A52_QA_RESULT " in g
(out/"qa/a52_native_gpu_runtime_qa.gd").write_text(g,encoding="utf8")
h=(out/"qa/a51_safe_contact_damage_native_qa.gd").read_text(encoding="utf8")
for old,new in [("A51_SAFE_","A52_"),("a51safe","a52"),("a51_safe_","a52_")]:
 h=h.replace(old,new)
hit=anchors["pose_anchors"][7]["hit_marker_local_px"]
if hit!=[29,7]:
 h=h.replace("Vector2(29,7)","Vector2(%d,%d)"%tuple(hit))
assert "A52_CONTACT_QA_RESULT " in h
(out/"qa/a52_contact_damage_native_qa.gd").write_text(h,encoding="utf8")
receipt={"stage":"A52","source_real_PixelLab_job":check["real_provider_job_id"],
 "model_raw_full_body_unmodified":True,
 "Body_SHA256":hashlib.sha256(bodyfile.read_bytes()).hexdigest(),
 "model_art_gates":check["gates"],
 "original_A51_stable_unmodified":True,
 "weapon_alignment":adjustment,"F7_contact_px":hit,
 "native_Godot":"PENDING","ART":"HOLD"}
(p/"A52_GODOT_INTEGRATION_QA.json").write_text(json.dumps(receipt,indent=2),encoding="utf8")
print("A52_NEW_REAL_PIXEL_LAB_BODY_GODOT_INTEGRATED",
 "body_SHA",receipt["Body_SHA256"],
 "sword_shifts",[(x["weapon_dx"],x["weapon_dy"])for x in adjustment],
 "F7",hit,flush=True)