from pathlib import Path
import json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A10_ONE_MASTER_RIG")
ops=[("T1_forest_scout","attack",1,2),("T2_moss_antler","faint",6,7)]
report=[]
for case,act,keep,remove in ops:
 p=root/case/"rig"/"clips.json"
 doc=json.loads(p.read_text(encoding="utf8"))
 clip=doc["clips"][act]
 original_frames=clip["frames"][:]; original_ticks=clip["ticks"][:]
 clip["ticks"][keep]+=clip["ticks"][remove]
 del clip["ticks"][remove]
 del clip["frames"][remove]
 assert sum(clip["ticks"])==sum(original_ticks)
 out=p.with_name("clips_nodup.json")
 out.write_text(json.dumps(doc,indent=2),encoding="utf8")
 report.append({"case":case,"clip":act,"before":len(original_frames),"after":len(clip["frames"]),
                 "original_ticks":sum(original_ticks),"new_ticks":sum(clip["ticks"]),
                 "removed_clip_position":remove})
(root/"A10_STRICT_REPAIR_QA.json").write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))