from pathlib import Path
import subprocess,sys,json
root=Path(__file__).resolve().parent
tasks=[("source_semantic_tiled_godot",root/"run_all.py"),("vx_native_isolated",root/"vx_test"/"run_vx_test.py")]
report={}
for name,path in tasks:
    proc=subprocess.run([sys.executable,str(path)],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,errors="replace",timeout=150)
    ok=proc.returncode==0
    report[name]={"pass":ok,"return_code":proc.returncode,"log_stdout":proc.stdout[-3000:],"log_stderr":proc.stderr[-1000:]}
    print(("PASS " if ok else "FAIL ")+name,flush=True)
    if not ok:break
passed=len(report)==len(tasks) and all(r["pass"] for r in report.values())
report["status"]="DUAL_ENGINE_SMOKE_PASS_FORMAL_VISUAL_PENDING" if passed else "FAIL_CLOSED"
(root/"logs"/"DUAL_ENGINE_RUN_SUMMARY.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(report["status"])
sys.exit(0 if passed else 2)
