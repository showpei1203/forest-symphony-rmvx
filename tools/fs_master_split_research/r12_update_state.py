from pathlib import Path
import json
R=Path(__file__).resolve().parent;D=R/"R12_NEW_ELF_VILLAGE_001"
F=json.loads((R/"R12_NEW_ELF_VILLAGE_NATIVE"/"R12_FINAL_GATE.json").read_text(encoding="utf8"))
S=json.loads((D/"R12_PROJECT_STATE.json").read_text(encoding="utf8"))
S.update({"phase":"R12_P4_NATIVE_CANDIDATE_TECH_PASS_ART_HOLD",
"new_master_exists":True,"new_master_sha256":F["new_master_sha256"],
"new_par_exists":True,"new_par_selected_objects":14,"new_par_source_exact_alpha_pixels":F["selected_PAR_source_RGB_exact_alpha_pixels"],
"new_native_test_exists":True,"native_independent_runs":len(F["native_game_runs"]),"native_screenshots":F["native_screenshots_total"],
"quality_gate_A":"HOLD_HUMAN_ART","source_gate_C":"TECH_RGB_PASS_SEMANTIC_HOLD",
"native_gate_E":"ISOLATED_14_ACTIONS_2_RUNS_PASS_BUT_FULL_EVENTS_HOLD",
"collision_grid_walkable":F["compiled_ground_walk_769"],
"collision_grid_blocked":F["compiled_terrain_and_objects_block_768"],
"ground3_test_only_alias":True,
"original_image_in_game_actual_source_pixel_verified":True,
"human_visual_gate_F":"PENDING_USER_REVIEW_LATER",
"formal_seal":False})
(D/"R12_PROJECT_STATE.json").write_text(json.dumps(S,ensure_ascii=False,indent=2),encoding="utf8")
print("R12_STATE_UPDATED",S["phase"],S["native_screenshots"],flush=True)