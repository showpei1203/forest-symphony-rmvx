"""A36G R7 V14 native actual actor traversal with ParSwitch203 OFF/ON before and after each legal step."""
from pathlib import Path
from PIL import Image,ImageChops,ImageDraw
import numpy as np,json
ROOT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\A36G_V7_REAL_NATIVE_MOVEMENT_V14_20261107")
src=ROOT/"FS_V14_A36G_R7_NATIVE_EXIT_QA.json"
q=json.loads(src.read_text("utf8"))
states=["OFF","ON","AFTER","END_OFF","END_ON"]
out=[]
sheet=Image.new("RGB",(272*5,245*5),(23,27,31))
dr=ImageDraw.Draw(sheet)
for i,(name,c) in enumerate(q["cases"].items()):
 s=c["screens"];plan=c["plan"]
 def compare(l,r):
  a=Image.open(ROOT/s[l]["image"]).convert("RGB")
  b=Image.open(ROOT/s[r]["image"]).convert("RGB")
  delta=ImageChops.difference(a,b)
  box=delta.getbbox()
  return {"changed":int(np.any(np.asarray(delta)!=0,axis=2).sum()),
          "bbox":list(box) if box else None,
          "actor_local":bool(box is None or (box[2]-box[0]<=64 and box[3]-box[1]<=64))}
 assert all(z in s and s[z]["capture_ok"] for z in states),name
 start=compare("OFF","ON");end=compare("END_OFF","END_ON")
 consistent=(s["OFF"]["actor_tile"]==s["ON"]["actor_tile"]==plan["start"] and
             s["END_OFF"]["actor_tile"]==s["END_ON"]["actor_tile"]==plan["dest"])
 camera=(s["OFF"]["display"]==s["ON"]["display"] and
         s["END_OFF"]["display"]==s["END_ON"]["display"])
 switch=(s["OFF"]["par_visible"]==False and s["ON"]["par_visible"]==True and
         s["END_OFF"]["par_visible"]==False and s["END_ON"]["par_visible"]==True)
 step=(c["native_move"]["after"]==plan["dest"] and c["native_move"]["runtime_passable"])
 ratio=round(end["changed"]/max(1,start["changed"]),4)
 valid=(consistent and camera and switch and step and
        start["changed"]>200 and start["actor_local"] and end["actor_local"] and
        ratio<=.45 and plan["start_actor_mask_overlap"]>.5 and
        plan["end_actor_mask_overlap"]<.13)
 rec={"name":name,"start_mask":plan["start_actor_mask_overlap"],
      "end_mask":plan["end_actor_mask_overlap"],
      "start_native":start,"end_native":end,
      "ratio_end_to_start":ratio,"same_camera_per_state":camera,
      "test_actor_positions_valid":consistent,
      "R5_move_permitted_and_occurred":step,
      "switch203_true_toggle":switch,
      "gate":"PASS" if valid else "FAIL"}
 out.append(rec)
 print("DYNAMIC",name,"start",start["changed"],"end",end["changed"],"ratio",ratio,
       "moved",step,"gate",rec["gate"],flush=True)
 for j,state in enumerate(states):
  with Image.open(ROOT/s[state]["image"]) as im:
   small=im.convert("RGB").resize((272,208),Image.Resampling.NEAREST)
  x=j*272;y=i*245+32
  sheet.paste(small,(x,y))
  dr.text((x+5,i*245+8),name.replace("_EXIT","")[:18]+" "+state,fill=(245,245,245))
sheet.save(ROOT/"V14_R7_FIVE_DYNAMIC_EXITS_FIVE_STATES_CONTACT.png")
result={"stage":"A36G_R7_V14_REAL_NATIVE_DYNAMIC_SOURCE_OWNED_203",
        "test_count":len(out),"cases":out,
        "game_exe_test":True,
        "R5_MAP050_native_collision_used":q["R5_Map050_verified"],
        "original_source_SHA_unchanged":q["source_hashes_unchanged"],
        "five_case_engine_gate":"PASS" if len(out)==5 and all(x["gate"]=="PASS" for x in out) and q["source_hashes_unchanged"] and q["completed_all"] else "FAIL",
        "C1_semantic_mask_user_approved":False,
        "R5_art_approved":False,
        "all_192_objects_covered":False,
        "formal_seal":"NO"}
(ROOT/"V14_A36G_R7_DYNAMIC_203_VISUAL_QA.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("FINAL",result["five_case_engine_gate"])