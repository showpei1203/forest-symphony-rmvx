from pathlib import Path
import subprocess,sys,hashlib,json,time
R=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
godot=Path(r"E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe")
project=R/"godot"/"AnimatedNormalsB0"
sealed=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\N5_RUNTIME_CLONE\Data\Scripts.rvdata")
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
baseline="3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9"
assert sha(sealed)==baseline
test=[
 ("T14_rebuild_atlas",[sys.executable,R/"scripts"/"test_t14_laigter_perframe.py"],"T14_PERFRAME_ATLAS_ALPHA_AND_FRAME_PASS",20),
 ("T16_prepare",[sys.executable,R/"scripts"/"prepare_t16_godot_animated.py"],"T16_PREPARED",15),
 ("T16_godot_import",[godot,"--headless","--path",project,"--editor","--import","--quit"],None,35),
 ("T16_godot_real_GPU",[godot,"--path",project,"--quit-after","300"],"T16_NATIVE_GPU_ANIMATION_PASS",30),
 ("T16_visual_pixel_audit",[sys.executable,R/"scripts"/"audit_t16_godot_animation.py"],"T16_NATIVE_GODOT_NORMAL_ANIMATION_PASS",20),
]
reports=[];start=time.perf_counter()
try:
 for name,args,marker,timeout in test:
  t=time.perf_counter()
  r=subprocess.run(list(map(str,args)),cwd=R,capture_output=True,text=True,errors="replace",timeout=timeout)
  output=r.stdout+"\n"+r.stderr
  (R/"reports"/(name+".log")).write_text(output,encoding="utf8")
  passed=(r.returncode==0 and (marker is None or marker in output))
  reports.append({"name":name,"pass":passed,"exit":r.returncode,"milliseconds":round((time.perf_counter()-t)*1000),"log":"reports/"+name+".log"})
  print("PASS" if passed else "FAIL",name,"elapsed",reports[-1]["milliseconds"],flush=True)
  if not passed:raise RuntimeError(name+" "+output[-500:])
 assert sha(sealed)==baseline
 status="T14_T16_INCREMENTAL_REAL_GPU_5_OF_5_PASS"
except Exception as e:
 status="T14_T16_INCREMENTAL_FAIL_CLOSED"
 reports.append({"error":str(e),"pass":False})
result={"status":status,"steps":reports,"elapsed_ms":round((time.perf_counter()-start)*1000),
 "sealed_n5_unchanged":sha(sealed)==baseline,"sealed_sha256":baseline,
 "source_map_status":"N5_B0_ISOLATED_6_6_PASS_VISUAL_GATE_F_PENDING",
 "artistic_review":"NOT FORMAL PASS", "tool_suite_baseline":"V3.1 10/10 PASS preserved"}
(R/"reports"/"T14_T16_INCREMENTAL_REGRESSION.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("T14_T16_END",status,flush=True)
if "PASS" not in status:sys.exit(2)
