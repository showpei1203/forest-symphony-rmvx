from pathlib import Path
import subprocess,json,time,sys,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
P=R/"reports"
godot=Path(r"E:\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe")
tasks=[
 ("T09_RUST_SPRITENORMALS",[sys.executable,R/"scripts"/"test_t09_normals_v3.py"],50,"T09"),
 ("T10_LAIGTER_BATCH",[sys.executable,R/"scripts"/"test_t10_laigter_v3.py"],50,None),
 ("T11_SHADER_DIAGNOSTIC",[sys.executable,R/"scripts"/"test_t11_pixelorama_shader.py"],55,"T11_RESULT"),
 ("T11B_SIX_DISTINCT",[sys.executable,R/"scripts"/"test_t11b_real_b0_pixelorama.py"],35,"T11B_PXO_REAL_B0_SIXFRAME_PASS"),
 ("T12_LIBRESPRITE_NATIVE",[sys.executable,R/"scripts"/"test_t12_libresprite_native.py"],25,"T12_NATIVE_ASE_SIXFRAME_PASS"),
 ("T13_PROJECT_PREP",[sys.executable,R/"scripts"/"prepare_t13_cross_tools.py"],20,"T13_CROSS_TOOL_GPU_PROJECT_READY"),
 ("T13_NATIVE_IMPORT",[godot,"--headless","--path",R/"godot"/"NormalLightB0","--editor","--import","--quit"],65,None),
 ("T13_NATIVE_GPU",[godot,"--path",R/"godot"/"NormalLightB0","--quit-after","350"],50,"T13_REAL_GPU_CAPTURES_PASS"),
 ("T13_GPU_PIXEL_AUDIT",[sys.executable,R/"scripts"/"test_t13_normal_compare.py"],25,"T13_REAL_GPU_B0_TWO_TOOLS_PASS")
]
rows=[]
def save(status):
 report={"status":status,"run_date":"2026-10-24","root":str(R),"prior_t01_t08":"NOT_RERUN; v2 11/11 prior pass remains",
 "scope":"T09 to T13 B0 source, native 6-frame sprite export, true Godot RX6700XT lighting","steps":rows,
 "known_fails":["T11 Pixelorama shader effects enabled: 0xC0000005 Access Violation; disabled both exports","T10 Laigter sheet vs frame normals 1726 visible pixel mismatch, generate per-frame","human artistic acceptance NOT RUN"],"formal_pass":False}
 (P/"V3_ALL_TOOLS_SUMMARY.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding="utf8")
for label,cmd,timeout,witness in tasks:
 start=time.monotonic()
 p=subprocess.run(list(map(str,cmd)),cwd=R,capture_output=True,text=True,errors="replace",timeout=timeout)
 stdout=p.stdout+"\n"+p.stderr
 (P/(label+".log")).write_text(stdout,encoding="utf8")
 ok=p.returncode==0 and (witness is None or witness in stdout)
 rows.append({"name":label,"pass":ok,"exit_code":p.returncode,"elapsed_ms":round((time.monotonic()-start)*1000),
 "command":list(map(str,cmd)),"log":label+".log","last_400":stdout[-400:]})
 print(("PASS " if ok else "FAIL ")+label,flush=True)
 save("IN_PROGRESS")
 if not ok:
  save("FAIL_CLOSED")
  print(stdout[-950:],flush=True)
  raise SystemExit(2)
checks={
 "T09":json.loads((P/"T09_SPRITENORMALS_B0_ANIMATION.json").read_text(encoding="utf8"))["status"]=="T09_B0_SPRITENORMALS_EXTENDED_PASS",
 "T10":json.loads((P/"T10_LAIGTER_B0_BATCH.json").read_text(encoding="utf8"))["status"]=="T10_LAIGTER_B0_BATCH_PASS_SHEET_EQUIVALENCE_NOT_ASSUMED",
 "T11":json.loads((P/"T11_PIXELORAMA_SHADER_VARIANTS.json").read_text(encoding="utf8"))["status"]=="T11_SHADER_VARIANTS_DIAGNOSED_CLEAN_ANIMATION_PASS",
 "T11B":json.loads((P/"T11B_PIXELORAMA_REAL_B0_ANIMATION.json").read_text(encoding="utf8"))["status"]=="T11B_PXO_REAL_B0_SIXFRAME_PASS",
 "T12":json.loads((P/"T12_LIBRESPRITE_NATIVE_METADATA.json").read_text(encoding="utf8"))["status"]=="T12_NATIVE_ASE_SIXFRAME_PASS",
 "T13":json.loads((P/"T13_GODOT_B0_NORMAL_COMPARE.json").read_text(encoding="utf8"))["status"]=="T13_REAL_GPU_B0_TWO_TOOLS_PASS"
}
if not all(checks.values()):
 rows.append({"name":"FINAL_RESULT_CONSISTENCY","pass":False,"details":checks})
 save("FAIL_CLOSED_REPORT_INCONSISTENCY");raise SystemExit(2)
rows.append({"name":"FINAL_RESULT_CONSISTENCY","pass":True,"details":checks})
save("T09_TO_T13_EXTENDED_TOOL_SMOKE_PASS_NOT_FORMAL_ART_APPROVAL")
print("V3_TOOL_SUITE_PASS steps",len(rows),"pass",sum(r["pass"] for r in rows),flush=True)
