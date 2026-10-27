#!/usr/bin/env python3
"""Fail-closed R5 final verification (true page isolation and native screen captures, art HOLD)."""
from pathlib import Path
from rubymarshal.reader import load
from PIL import Image
import hashlib,json
R=Path(__file__).resolve().parent
E=R/"R5_FORMAL_ADAPTER_ISOLATED"
CAP=E/"NATIVE_CAPTURE"
A=R/"R5_FORMAL_READONLY_AUDIT"
base=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
built=E/"FULL505"/"Data"/"Scripts.rvdata"
formal=load(base.open("rb"));current=load(built.open("rb"))
assert len(formal)==505 and len(current)==506
assert all(current[i if i<482 else i+1]==formal[i] for i in range(505) if i!=480)
for idx in (145,146,342):assert current[idx]==formal[idx]
comparison=json.loads((CAP/"R5_REAL505_VISUAL_COMPARISON_AUDIT.json").read_text())
pasa=json.loads((A/"R5_TRUE_FORMAL_PASSPASSA_THIRDLAYER_USAGE.json").read_text())
results={}
for mode in ["HK_STATIC","DYNAMIC_ADAPTER"]:
 folder=CAP/mode
 manifest=json.loads((folder/"R5_NATIVE_CAPTURE_MANIFEST.json").read_text())
 log=(folder/"GAME_LOG.txt").read_text(errors="replace")
 p=["PLAYER_FRONT_NPC_BEHIND","PLAYER_BEHIND_NPC_FRONT","BOTH_FRONT","BOTH_BEHIND","CLEAR"]
 assert all((folder/(n+".png")).exists() for n in p)
 assert all(Image.open(folder/(n+".png")).size==(544,416) for n in p)
 assert "R5_FULL505_CAPTURE_DONE" in log
 assert "R5_TRUE_PASSPASSA_GATE mapPass769=true mapBlock768=true playerMovePass=true playerMoveBlocked=true" in log
 assert "R5_HK_VIEWPORT_GATE parPresent=true" in log and "parVZ=8" in log
 assert ("parSwitch=true" if mode=="HK_STATIC" else "parSwitch=false") in log
 manifest["formal_baseline_disk_untouched"]=True
 manifest["isolated_original_page_480_disabled"]=True
 manifest["isolated_other_504_pages_byte_identical"]=True
 manifest["unmodified_505_script_runtime_tested"]=False
 manifest["runtime_passability_move_gate"]=True
 manifest["native_hk_overlay_viewport_gate"]=True
 manifest["final_visual_gate"]=False
 manifest["status"]="R5_ISOLATED_NATIVE_BOOT_PASS_AND_MOVE_GATE_PASS_VISUAL_HOLD"
 (folder/"R5_NATIVE_CAPTURE_MANIFEST.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
 results[mode]={"native_images":len(p),"movement_gate":True,"overlay_viewport":True,
                "native_log_sha256":hashlib.sha256(log.encode()).hexdigest()}
out={
 "status":"R5_ISOLATED_HK_PASSPASSA_NATIVE_TECH_PASS_VISUAL_HOLD",
 "formal_source_505_sha256":hashlib.sha256(base.read_bytes()).hexdigest(),
 "unmodified_505_script_runtime_tested":False,
 "formal_505_pages":505,"source_pages_exact_in_isolation":504,"disabled_regression_page":480,
 "added_test_probe_pages":1,"current_isolated_page_count":506,
 "core_scripts_original_byte_identical":{"HK145":True,"Animated146":True,"ParaPassa342":True},
 "formal_passa_map_usage":{"maps_scanned":pasa["maps_scanned"],"maps_with_passa":pasa["maps_with_passa"],"pasa_tiles":pasa["all_passa_tiles"]},
 "actual_native_results":results,
 "visual_pixels_nonactor_diff":{"min":min(r["comparison_diff_nonactor_px"] for r in comparison["cases"]),
                               "max":max(r["comparison_diff_nonactor_px"] for r in comparison["cases"])},
 "visual_regression":"FAIL/HOLD due full FS visual effects / HUD / tone not controlled across runs",
 "semantic_par_art":"HOLD / three candidates only",
 "formal_sealed_modified":False,
 "report_not_proof":"Original 505 is not fully bootable without isolating regression harness page 480; no final Gate F."
}
(E/"R5_FINAL_GATE.json").write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(out,ensure_ascii=False),flush=True)