from pathlib import Path
import sys,subprocess,time,json,hashlib
r=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v2_20261023")
lab=r.parent
scripts=r/"scripts"
godot=lab/"Godot"/"4.7.2"/"Godot_v4.7.2-stable_win64.exe"/"Godot_v4.7.2-stable_win64_console.exe"
godot=Path(r"E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe")
p=r/"godot"/"NormalLightVisual"
jobs=[
 ("T01_SpriteNormals_Rust_CLI",[sys.executable,str(scripts/"run_t01_sprite_normals.py")],25,"T01_SPRITE_NORMALS_NATIVE_CLI.json"),
 ("T02_Laigter_T05_LibreSprite",[sys.executable,str(scripts/"run_t02_t05.py")],55,"T02_LAIGTER_REAL_ASSETS.json"),
 ("T03_Pixelorama_6frames_prep",[sys.executable,str(scripts/"run_t03_sanitized.py")],60,"T03_PIXELORAMA_NO_EFFECTS.json"),
 ("T03_Pixelorama_6distinct_frames",[sys.executable,str(scripts/"run_t03_unique_frames.py")],40,"T03_PIXELORAMA_SIX_UNIQUE_FRAMES.json"),
 ("T04_Tiled_1088x832",[sys.executable,str(scripts/"run_t04_tiled_large.py")],30,"T04_TILED_LARGE_AND_NEGATIVE.json"),
 ("T06_SpriteLab_browser",[sys.executable,str(scripts/"run_t06_spritelab_web.py")],60,"T06_SPRITELAB_WEB.json"),
 ("T06_SpriteFusion_browser",[sys.executable,str(scripts/"run_t06_spritefusion_web.py")],60,"T06B_SPRITEFUSION_WEB.json"),
 ("T07_prepare",[sys.executable,str(scripts/"prepare_t07.py")],15,None),
 ("T07_Godot_GPU",[str(godot),"--path",str(p),"--quit-after","250"],50,None),
 ("T07_Godot_visual_audit",[sys.executable,str(scripts/"audit_t07_godot.py")],15,"T07_GODOT_NORMAL_VISUAL.json"),
 ("T08_dual_engine_regression",[sys.executable,str(lab/"FS_ForestSplit_v3_2"/"run_dual.py")],125,None)
]
all_results=[];start=time.perf_counter()
for name,cmd,timeout,result_file in jobs:
 print("TOOL_TEST_START",name,flush=True)
 try:
  t=time.perf_counter()
  z=subprocess.run(cmd,cwd=r,capture_output=True,text=True,errors="replace",timeout=timeout)
  transcript=(z.stdout+"\n"+z.stderr)
  (r/"logs"/(name+".txt")).write_text(transcript,encoding="utf8")
  success=z.returncode==0
  if name=="T07_Godot_GPU":
   success=success and "T07_CAPTURE_DONE" in z.stdout and all((p/"captures"/f).is_file() for f in ("T07_normal_left.png","T07_normal_right.png","T07_without_normal_left.png"))
  if name=="T08_dual_engine_regression": success=success and "DUAL_ENGINE_SMOKE_PASS_FORMAL_VISUAL_PENDING" in z.stdout
  if result_file is not None:
   rp=r/"reports"/result_file
   success=success and rp.is_file()
  item={"name":name,"pass":success,"return_code":z.returncode,"elapsed_ms":int((time.perf_counter()-t)*1000),"evidence_json":result_file,"stdout_tail":z.stdout[-600:],"stderr_tail":z.stderr[-500:]}
  all_results.append(item)
  print("TOOL_TEST_RESULT",name,"PASS" if success else "FAIL",flush=True)
  if not success:break
 except Exception as e:
  all_results.append({"name":name,"pass":False,"error":str(e)})
  print("TOOL_TEST_ERROR",name,str(e),flush=True)
  break
passed=len(all_results)==len(jobs) and all(v.get("pass") for v in all_results)
report={"timestamp_date":"2026-10-23","status":"TOOL_AUTOMATION_SMOKE_PASS_FORMAL_VISUAL_PENDING" if passed else "FAIL_CLOSED","completed_steps":len(all_results),"planned_steps":len(jobs),
 "tools":["Sprite Normals","Laigter","Pixelorama","Tiled","LibreSprite","SpriteLab (license unverified)","Sprite Fusion Web","Godot","RPG Maker VX isolated"],
 "results":all_results,
 "known_limitations":["Pixelorama original effect-laden six-frame sample crashes headless; only shader-free six unique-frame test passed.",
 "SpriteLab freeware browser result is not verified open source.",
 "Godot shaders/materials do not fix Ground/PAR object semantics; the same Manifest remains authority.",
 "VX test uses isolated RGSS2 adapter; SEALED Forest Symphony runtime and human visual acceptance remain pending."],
 "goals_document":"https://docs.google.com/document/d/1XitoOS6llG9vlDL7vt2IoY0Wrm3gtk71ozc4RtVNEyo/edit"}
(r/"reports"/"ALL_TOOL_TESTS_SUMMARY.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(report["status"],len(all_results),"/",len(jobs),"elapsed_ms",int((time.perf_counter()-start)*1000),flush=True)
sys.exit(0 if passed else 2)
