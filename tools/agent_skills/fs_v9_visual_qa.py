"""V9 real native actor canopy exit: compare ParSwitch203 at both start and end positions."""
from pathlib import Path
from PIL import Image,ImageChops,ImageDraw
import numpy as np,json,hashlib
R=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\validation_v6")
p=R/"FS_V9_NATIVE_MOVEMENT_AND_OCCLUSION_QA.json"
q=json.loads(p.read_text(encoding="utf8"))
states=["OFF","ON","AFTER","END_OFF","END_ON"]
rows=[]
sheet=Image.new("RGB",(272*5,245*4),(23,26,30))
draw=ImageDraw.Draw(sheet)
for idx,(name,v) in enumerate(q["cases"].items()):
 scr=v["screens"];plan=v["plan"]
 assert all(s in scr and scr[s]["capture_ok"] for s in states),(name,scr)
 assert scr["OFF"]["actor_tile"]==scr["ON"]["actor_tile"]==plan["start"]
 assert scr["END_OFF"]["actor_tile"]==scr["END_ON"]["actor_tile"]==plan["dest"]
 def pixel_diff(a,b):
  with Image.open(R/scr[a]["image"]) as x,Image.open(R/scr[b]["image"]) as y:
   d=ImageChops.difference(x.convert("RGB"),y.convert("RGB"))
   rect=d.getbbox()
   return {"changed_pixels":int(np.any(np.asarray(d)!=0,axis=2).sum()),
           "bbox":list(rect) if rect else None}
 start=pixel_diff("OFF","ON")
 end=pixel_diff("END_OFF","END_ON")
 start_local=bool(start["bbox"] and start["bbox"][2]-start["bbox"][0]<=64 and start["bbox"][3]-start["bbox"][1]<=64)
 end_local=bool(end["bbox"] is None or (end["bbox"][2]-end["bbox"][0]<=64 and end["bbox"][3]-end["bbox"][1]<=64))
 camera_start=scr["OFF"]["display"]==scr["ON"]["display"]
 camera_end=scr["END_OFF"]["display"]==scr["END_ON"]["display"]
 state_pass=not scr["OFF"]["par_visible"] and scr["ON"]["par_visible"] and not scr["END_OFF"]["par_visible"] and scr["END_ON"]["par_visible"]
 movement_pass=v["movement_matches_manifest"]
 ratio=round(end["changed_pixels"]/max(start["changed_pixels"],1),4)
 pass_sample=bool(movement_pass and camera_start and camera_end and state_pass and start_local and end_local and start["changed_pixels"]>=250 and ratio<0.4)
 out={"name":name,"start_mask_ratio":plan["start_actor_mask_overlap"],
      "end_mask_ratio":plan["end_actor_mask_overlap"],"start":start,"end":end,
      "end_vs_start_changed_pixel_ratio":ratio,"moving_matches_manifest":movement_pass,
      "camera_stable_start":camera_start,"camera_stable_end":camera_end,
      "par203_toggle_valid":state_pass,"start_diff_actor_local":start_local,
      "end_diff_actor_local":end_local,"gate":"PASS" if pass_sample else "FAIL"}
 rows.append(out)
 for j,state in enumerate(states):
  with Image.open(R/scr[state]["image"]) as im:
   small=im.convert("RGB").resize((272,208),Image.Resampling.NEAREST)
  x=j*272; y=idx*245+27
  sheet.paste(small,(x,y))
  draw.text((x+6,idx*245+7),name.replace("FOREST_CANOPY_EXIT_","")[:8]+" "+state,fill=(245,245,245))
 print("CASE",name,"start",start["changed_pixels"],"end",end["changed_pixels"],"ratio",ratio,"gate",out["gate"])
sheet.save(R/"V9_CANOPY_EXIT_4CASES_5STATES_CONTACT.png")
result={"tests":rows,
        "four_sample_native_gate":"PASS" if all(v["gate"]=="PASS" for v in rows) else "FAIL",
        "sample_count":len(rows),"original_source_unchanged":q["source_hashes_unchanged"],
        "source":"real RPG Maker VX Game.exe native switch203 screenshots",
        "art_approval":"UNVERIFIED","all_map_coverage":"NOT TESTED",
        "formal_seal":"NO"}
(R/"FS_V9_CANOPY_EXIT_203_VISUAL_QA.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("SUMMARY",result["four_sample_native_gate"],"sha",result["original_source_unchanged"],flush=True)