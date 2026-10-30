from pathlib import Path
import json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
d=json.loads((root/"tankentai_pose_coverage_conditional.json").read_text(encoding="utf-8"))
reduced={"scope":d["scope"],"matched_poses":d["matched_poses"],"conditional_missing":d["missing_conditionally"],"source_scripts_sha256":d["source_scripts_sha256"],"not_proven":d["not_proven"],"risk_items":[{"name":v["name"],"file_no":v["file_no"],"row":v["row"],"fixed":v["fixed"],"missing_columns":v["missing_columns"],"reason":"absent numbered sheet" if v["source"] is None else "missing required cells in existing numbered sheet"} for v in d["missing_records"]]}
p=root/"tankentai_pose_coverage_risks_only.json"
p.write_text(json.dumps(reduced,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"file":str(p),"bytes":p.stat().st_size,"pose_count":reduced["matched_poses"],"risk_count":len(reduced["risk_items"])},ensure_ascii=False))