from pathlib import Path
import json,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
record=json.loads((root/"a09_3"/"joe_weapon_authority.json").read_text(encoding="utf-8"))
names=["喬伊普攻武器","喬伊普攻武器2","正常武器待機"]
out={"stage":"A09_3_WEAPON_RUNTIME_CODE_AUTHORITY", "status":"SOURCE_AND_FORMULA_AUDITED", "source_sha256":record["source_script_sha256"],
"runtime_source":"Scripts.rvdata[227] Sideview 2 (3.4d) Sprite_Weapon#weapon_action and Sprite_Weapon#update",
"unsafe_assumption_previous":"A08 G0-1B generic VERT_SWING angle sequence is not Joe's specific Normal Attack weapon authority",
"frame_time":{"ANIME_PATTERN":3,"per_weapon_action_update_denominator":4,"fps_reference":60},
"weapon_results":[]}
for name in names:
 v=record["weapon_table"][name]
 flip=bool(v["invert_horizontal"])
 origin=int(v["origin_id"])
 actual_pivot=3 if flip and origin==4 else (4 if flip and origin==3 else (2 if flip and origin==1 else (1 if flip and origin==2 else origin)))
 pivot={0:[12,12],1:[0,0],2:[24,0],3:[0,24],4:[24,24]}[actual_pivot]
 aa=int(v["angle_start_rgss"]);bb=int(v["angle_end_rgss"])
 dx=int(v["xa"]);dy=int(v["ya"])
 # Ruby 1.8 Fixnum integer / floors and % uses positive modulus for positive divisor
 samples=[]
 delta=bb-aa
 step_angle=delta//4
 angle_remainder=delta%4
 step_x=dx//4;step_y=dy//4
 for i in range(4):
  samples.append({"tick":i,"angle_rgss_inferred":aa+angle_remainder+i*step_angle,
   "angle_godot_candidate":-(aa+angle_remainder+i*step_angle),
   "move_x_inferred":i*step_x,"move_y_inferred":i*step_y,
   "pose_offset_x":int(v["pos_offset_x"]),"pose_offset_y":int(v["pos_offset_y"])})
 out["weapon_results"].append({"weapon":name,"native_values":v,"base_mirror":False,
 "actual_mirror_when_base_unmirrored":flip,"effective_origin_id":actual_pivot,
 "effective_pivot_24x24":pivot,
 "battler_root_relative_position_update":"x=battler.position_x+move_x+Xp, y=battler.position_y+move_y+Yp",
 "actual_swing_is_incremental_not_full_Xa_at_start":True,
 "angle_division_Ruby_Fixnum":{"per_tick":step_angle,"remainder":angle_remainder},
 "motion_division_Ruby_Fixnum":{"x_per_tick":step_x,"y_per_tick":step_y},
 "4_tick_inferred_samples":samples,
 "source_runtime_reference":"Sideview 2: weapon_action lines 1548..1666, action lines 1710..1725, update lines 1729..1739"})
assert out["weapon_results"][1]["effective_pivot_24x24"]==[0,24]
assert out["weapon_results"][0]["effective_pivot_24x24"]==[24,24]
assert out["weapon_results"][2]["effective_pivot_24x24"]==[12,12]
assert out["weapon_results"][0]["motion_division_Ruby_Fixnum"]["x_per_tick"]==-2
assert out["weapon_results"][1]["motion_division_Ruby_Fixnum"]["x_per_tick"]==1
p=root/"a09_3"/"source_formula_audit.json"
p.write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"status":out["status"],"checks":len(out["weapon_results"]),"summary":[{"name":x["weapon"],"pivot":x["effective_pivot_24x24"],"step_x":x["motion_division_Ruby_Fixnum"]["x_per_tick"],"step_angle":x["angle_division_Ruby_Fixnum"]} for x in out["weapon_results"]]},ensure_ascii=True,indent=2))