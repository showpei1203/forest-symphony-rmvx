from pathlib import Path
from rubymarshal.reader import loads
import json,re
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
base=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
act=loads((base/"Data"/"Actors.rvdata").read_bytes())
actors={}
for i,a in enumerate(act):
 if a is None:continue
 v=a.attributes
 name=v.get("@name") or b""
 fn=v.get("@character_name") or b""
 actors[str(i)]={"name":name.decode("utf-8","replace") if isinstance(name,bytes) else str(name),
 "filename":fn.decode("utf-8","replace") if isinstance(fn,bytes) else str(fn),
 "weapon_id":v.get("@weapon_id"),"id":v.get("@id")}
v=json.loads((root/"tankentai_pose_coverage_conditional.json").read_text(encoding="utf-8"))
n=actors["1"]["name"]
specific=[r for r in v["poses"] if n in r["name"]]
risks=[r for r in v["missing_records"] if n in r["name"]]
others=[r for r in v["missing_records"] if n not in r["name"]]
s=(base/"All_Scripts_Export.txt").read_text(encoding="utf-8",errors="replace")
# Count actual literal pose-key usages outside their own definitions; this is evidence only, not proof of per-actor reachability.
counts=[]
for r in specific:
 key='"'+r["name"]+'"'
 hits=[m.start() for m in re.finditer(re.escape(key),s)]
 counts.append({"name":r["name"],"file_no":r["file_no"],"row":r["row"],
    "fixed":r["fixed"],"missing_columns":r["missing_columns"],"literal_occurrences":len(hits),
    "snippet":s[max(0,hits[-1]-90):hits[-1]+100] if hits else None})
out={"actor1":actors["1"],"actors_preview":[actors[str(i)] for i in range(1,10)],
"risk_statement_revision":"The 9 previous risks are conditional for an arbitrary $actor01 image; all named keys are Taylor's, not actor #1 Joe. This does not prove actual runtime dispatch is absent.",
"all_9_risk_labels_are_other_actor":len(others)==len(v["missing_records"]),
"actor_specific_pose_defs":len(specific),"actor_specific_pose_cell_risks":len(risks),
"actor_specific_pose_details":counts,
"unresolved":"Need inspect actual action sequence dispatch and runtime. A name heuristic is not dynamic call proof."}
(root/"actor1_binding_a09_2.json").write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"actor1":out["actor1"],"actor_named_pose_defs":len(specific),
"actor_named_missing_rows":len(risks),"all9_other":out["all_9_risk_labels_are_other_actor"],"actor_pose_summary":[{"name":x["name"],"file_no":x["file_no"],"row":x["row"],"missing":x["missing_columns"],"usages":x["literal_occurrences"]} for x in counts]},ensure_ascii=True,indent=2))