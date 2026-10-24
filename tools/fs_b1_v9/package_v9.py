from pathlib import Path
import zipfile,hashlib,json
R=Path(__file__).resolve().parent
t=json.loads((R/"V9_GATE_RESULT.json").read_text(encoding="utf8"))
assert t["status"]=="B1_V9_NEW_SACRED_TREE_LAYER_SOURCE_GATE_PASS_VISUAL_PENDING"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
out=R.parent/"deliveries"/"FS_B1_V9_SACRED_TREE_SOURCE_CANDIDATE_20261024.zip"
assert not out.exists()
name="FS_B1_V9_SACRED_TREE_SOURCE_CANDIDATE_20261024"
files=sorted(f for f in R.rglob("*") if f.is_file() and not f.name.endswith(".import") and not any(x in f.parts for x in (".godot","__pycache__")) and f.name!="PACKAGE_INTEGRITY.json")
entries=[{"path":str(f.relative_to(R)).replace("\\","/"),"sha256":sha(f),"size":f.stat().st_size} for f in files]
manifest={"status":t["status"],"source_rights":"PRIVATE LICENSE_UNVERIFIED","v8_vx_sealed_unchanged":True,"files":entries}
(R/"PACKAGE_INTEGRITY.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
files.append(R/"PACKAGE_INTEGRITY.json")
with zipfile.ZipFile(out,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in files:z.write(f,name+"/"+str(f.relative_to(R)).replace("\\","/"))
with zipfile.ZipFile(out) as z:
 assert z.testzip() is None
 for f in files:assert hashlib.sha256(z.read(name+"/"+str(f.relative_to(R)).replace("\\","/"))).hexdigest()==sha(f)
data={"status":t["status"],"zip":str(out),"bytes":out.stat().st_size,"sha256":sha(out),"files":len(files),"quick_test":"PASS"}
(R/"PACKAGE_RESULT.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding="utf8")
print("V9_ZIP_PASS",json.dumps(data,ensure_ascii=False),flush=True)
