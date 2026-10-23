from pathlib import Path
import json,hashlib,sys
R=Path(r"E:\GameAssetToolLab_20261023\ToolValidation_v3_20261024")
MAP=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024")
reports=R/"reports"
def load(path):return json.loads(path.read_text(encoding="utf8"))
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
checks={}
def gate(key,value,detail=None):
 checks[key]={"pass":bool(value),"detail":detail}
summary=load(reports/"V3_ALL_TOOLS_SUMMARY.json")
gate("T09_T13_prior_10_step_baseline",summary["status"]=="T09_TO_T13_EXTENDED_TOOL_SMOKE_PASS_NOT_FORMAL_ART_APPROVAL" and len(summary["steps"])==10 and all(z["pass"] for z in summary["steps"]),{"status":summary["status"],"steps":len(summary["steps"])})
increment=load(reports/"T14_T16_INCREMENTAL_REGRESSION.json")
gate("T14_T16_new_5_step_native_GPU",increment["status"]=="T14_T16_INCREMENTAL_REAL_GPU_5_OF_5_PASS" and len(increment["steps"])==5 and all(z["pass"] for z in increment["steps"]) and increment.get("sealed_n5_unchanged") is True,increment["status"])
t14=load(reports/"T14_LAIGTER_STITCHED_NORMALS.json")
t14_path=R/"godot"/"AnimatedNormalsB0"/"normal_atlas.png" # confirmed per-frame atlas source consumed by Godot
gate("T14_image_per_frame_source_SHA",t14["status"]=="T14_PERFRAME_ATLAS_ALPHA_AND_FRAME_PASS" and t14_path.is_file() and sha(t14_path)==t14["normal_sha256"] and t14.get("negative_1px_shift_visible_diff",0)>0 and t14.get("negative_swapped_2_3_visible_diff",0)>0,{"path":str(t14_path),"source_vs_naive_sheet_visible_diff":t14["naive_sheet_vs_perframe_visible_diff"]})
t12=load(reports/"T12_LIBRESPRITE_NATIVE_METADATA.json")
gate("T12_native_ASE_six_frame_timing",t12["status"]=="T12_NATIVE_ASE_SIXFRAME_PASS" and t12["durations_expected"]==t12["durations_exported"]==[70,90,110,130,150,170] and len(t12.get("tags_exported",[]))>0)
t16=load(reports/"T16_GODOT_SYNCHRONIZED_NORMAL_ANIM.json")
frames=R/"godot"/"AnimatedNormalsB0"/"captures"
captures={int(x["frame"]):x["sha256"] for x in t16["captures"]}
frame_checks={str(n): (frames/f"T16_frame_{n:02d}.png").is_file() and sha(frames/f"T16_frame_{n:02d}.png")==captures[n] for n in range(6)}
gate("T16_Godot_six_real_GPU_captures_SHA",t16["status"]=="T16_NATIVE_GODOT_NORMAL_ANIMATION_PASS" and len(captures)==6 and all(frame_checks.values()) and t16["timings_expected_ms"]==[70,90,110,130,150,170] and max(abs(a-b) for a,b in zip(t16["timings_expected_ms"],t16["observed_native_ms"]))<=t16["timing_tolerance_ms"],{"capture_SHA":frame_checks,"observed_timings_ms":t16["observed_native_ms"]})
t11=load(reports/"T11_PIXELORAMA_SHADER_VARIANTS.json")
gate("T11_effect_crash_preserved_not_falsely_PASS",t11["status"]=="T11_SHADER_VARIANTS_DIAGNOSED_CLEAN_ANIMATION_PASS" and "results" in t11,{"shader_effects":"FAIL / no formal pass","plain_spritesheet":"PASS"})
t13=load(reports/"T13_GODOT_B0_NORMAL_COMPARE.json")
gate("T13_real_GPU_normal_compare",t13["status"]=="T13_REAL_GPU_B0_TWO_TOOLS_PASS" and t13.get("capture_count")==12)
mapj=load(MAP/"logs"/"N5_B0_FINAL_REGRESSION.json")
n5=MAP/"clone_project"/"N5_RUNTIME_CLONE"/"Data"/"Scripts.rvdata"
n5sha="3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9"
gate("sealed_N5_MAP_UNCHANGED",mapj["status"]=="N5_B0_RUNTIME_ADAPTER_ISOLATED_SMOKE_PASS_VISUAL_GATE_F_PENDING" and n5.is_file() and sha(n5)==n5sha and len(mapj["checks"])==6 and all(z["pass"] for z in mapj["checks"]),{"sealed_SHA256":n5sha,"map_status":"PAUSED"})
result={"status":"TOOL_V3_2_HANDOFF_AUDIT_PASS" if all(x["pass"] for x in checks.values()) else "FAIL_CLOSED",
"date":"2026-10-24","tests":checks,"prior_tool_v3_1_steps":10,"T14_T16_incremental_steps":5,
"T15_Pixelorama_Shader_GUI":"NOT_TESTED","T17_REAL_PMD_LPC_SBS":"NOT_TESTED","T18_PERFORMANCE":"NOT_TESTED",
"human_visual_Gate_F":"PENDING","map_runtime":"PAUSED_N5_ADAPTER_SMOKE_PASS"}
(reports/"TOOL_V3_2_HANDOFF_CHECK.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("TOOL_V3_2_HANDOFF_AUDIT",result["status"],sum(z["pass"] for z in checks.values()),"/",len(checks),flush=True)
for k,v in checks.items():print(("PASS " if v["pass"] else "FAIL ")+k,flush=True)
if result["status"]!="TOOL_V3_2_HANDOFF_AUDIT_PASS":sys.exit(2)
