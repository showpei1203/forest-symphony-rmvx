from pathlib import Path
import sys,subprocess,time,json,hashlib
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
godot=Path(r"E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe")
project=r/"godot"/"B0NormalCrossTool"
py=sys.executable
jobs=[
 ("T09_inputs",[py,r/"scripts"/"prepare_v3.py"],30,None),
 ("T09_SpriteNormals_B0",[py,r/"scripts"/"run_t09.py"],40,"T09_SPRITENORMALS_B0.json"),
 ("T10_Laigter_B0",[py,r/"scripts"/"run_t10.py"],60,"T10_LAIGTER_B0.json"),
 ("T11_Pixelorama_B0",[py,r/"scripts"/"run_t11.py"],55,"T11_PIXELORAMA_B0.json"),
 ("T12_LibreSprite_B0",[py,r/"scripts"/"run_t12.py"],45,"T12_LIBRESPRITE_ANIMATION.json"),
 ("T13_prepare",[py,r/"scripts"/"prepare_t13.py"],25,None),
 ("T13_Godot_import",[godot,"--headless","--path",project,"--editor","--import","--quit"],55,None),
 ("T13_Godot_real_GPU",[godot,"--path",project,"--quit-after","260"],65,None),
 ("T13_visual_audit",[py,r/"scripts"/"audit_t13.py"],25,"T13_CROSS_TOOL_GODOT_GPU.json"),
]
results=[];start=time.monotonic()
for name,cmd,limit,report_file in jobs:
 print("V3_TOOL_START",name,flush=True)
 try:
  t=time.monotonic()
  p=subprocess.run(list(map(str,cmd)),cwd=r,capture_output=True,text=True,errors="replace",timeout=limit)
  log=r/"logs"/(name+".log")
  log.write_text(p.stdout+"\n"+p.stderr,encoding="utf8")
  good=p.returncode==0
  item={"name":name,"pass":good,"exit":p.returncode,"elapsed_ms":int(1000*(time.monotonic()-t)),
   "log":str(log.relative_to(r)),"stdout_tail":p.stdout[-900:],"stderr_tail":p.stderr[-450:]}
  if name=="T13_Godot_real_GPU":good=good and "T13_B0_NORMAL_GPU_CAPTURE_DONE" in p.stdout
  if report_file:
   j=json.loads((r/"reports"/report_file).read_text(encoding="utf8"))
   item["report"]=report_file
   item["reported_status"]=j.get("status")
   good=good and j.get("status") not in ("FAIL","FAIL_CLOSED","T12_NATIVE_EXPORT_FAIL") and ("PASS" in j.get("status",""))
  item["pass"]=bool(good)
  results.append(item)
  print("V3_TOOL_GATE",name,"PASS" if good else "FAIL",flush=True)
  if not good:break
 except Exception as e:
  results.append({"name":name,"pass":False,"error":str(e)})
  print("V3_TOOL_ERROR",name,str(e),flush=True)
  break
passed=len(results)==len(jobs) and all(item["pass"] for item in results)
final={"date":"2026-10-24","status":"V3_EXTENDED_TOOL_SMOKE_PASS_WITH_LAIGTER_WARNINGS_FORMAL_ART_PENDING" if passed else "V3_FAIL_CLOSED",
"completed":len(results),"planned":len(jobs),"results":results,
"limitations":["Laigter raw alpha mismatch on all 16 maps; auto repair required; tree and sign parallax normal/height map flat.",
"Pixelorama export six frames PASS only after removing Shader Layer Effects; original Shader-enabled project crashes headless historically.",
"SpriteLab browser source license still unverified, not in V3 local OSS core.",
"NormalMap materials DO NOT infer Ground/PAR/Height/Collision semantic geometry.",
"Godot OpenGL tests native GPU visuals, not artistic/formal quality acceptance.",
"Source assets are authored procedural B0 test art; no Hanzo rights-restricted imagery in V3 content.",
"Previous V2 11/11 regression stays the historical baseline, not rerun as part of these V3 9 steps."],
"elapsed_ms":int(1000*(time.monotonic()-start)),
"map_checkpoint":"https://docs.google.com/document/d/1Fwwert2ILfA2MLWdgQQJXMo9Sqhg-20Z5bjqWcYrdBY/edit",
"previous_v2":"E:\\GameAssetToolLab_20261023\\ToolValidation_v2_20261023",
"project_root":str(r)}
(r/"reports"/"V3_ALL_TOOL_GATES.json").write_text(json.dumps(final,ensure_ascii=False,indent=2),encoding="utf8")
print("V3_FINAL",final["status"],len(results),"/",len(jobs),"ms",final["elapsed_ms"],flush=True)
if not passed:raise SystemExit(2)
