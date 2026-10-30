from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
from PIL import Image,ImageChops
import hashlib,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
p=root/"a09_3"
engine=root/"a09_2_actor_poses"/"engine"/"godot"
source=root.parent/"VX_A09_NATIVE_ISOLATED"/"Data"/"Scripts.rvdata"
isolated=root.parent/"VX_A09_3_INENGINE_BRIDGE"/"Data"/"Scripts.rvdata"
authority=json.loads((p/"joe_weapon_authority.json").read_text(encoding="utf-8"))
aud=json.loads((p/"source_formula_audit.json").read_text(encoding="utf-8"))
render=json.loads((engine/"A09_3_WEAPON_FORMULA_V2_LOG.json").read_text(encoding="utf-8"))
bridge=json.loads((p/"bridge_runtime_report.json").read_text(encoding="utf-8"))
imgs=[engine/"A09_3_WEAPON_AUTHORITY_CANDIDATE.png",engine/"A09_3_WEAPON_FORMULA_V2_CANDIDATE.png"]
assert all(q.exists() for q in imgs)
assert Image.open(imgs[0]).size==(1050,500)
assert Image.open(imgs[1]).size==(1000,490)
assert render["draw_ok"] and len(render["samples"])==12
assert len(authority["poses"])==7
assert len(aud["weapon_results"])==3
assert len([x for x in authority["poses"] if x["weapon_key"]])==3
assert bridge["log"] is None and not bridge["files"],"unexpected native proof; re-evaluate"
assert hashlib.sha256(source.read_bytes()).hexdigest()=="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
QA={
 "status":"A09_3_GODOT_WEAPON_FORMULA_CANDIDATE_RENDERED_VX_NATIVE_NOT_VALIDATED",
 "source_pose_binding_keys":7,"bound_weapon_keys":3,"original_swing_keys":2,"Godot_v2_sample_count":12,
 "native_battler_weapon_pivot":{"normal_attack_1":[24,24],"normal_attack_2_mirrored":[0,24],"standby":[12,12]},
 "native_swing_effects_parsed":["Xa","Ya","Za","A1","A2","Or","Inv","Xs","Ys","Xp","Yp","Weapon2"],
 "v1_failure_categories":["APPLIED_FULL_SWING_XA_AT_T0","MISSED_MIRROR_PIVOT_4_TO_3","SIMPLIFIED_LINEAR_ANGLE_INTERPOLATION","NO_NATIVE_ORIGINAL_VX_CAPTURE"],
 "v2_changes":["SOURCE_DEFINED_4_TICK_DIVISION_FORMULAS","MIRROR_PIVOT_SWAP","MOVE_STEP_PER_TICK","SCENE_FRONT_BACK_Z","PRESERVED_OFFSETS"],
 "actual_native_VX_test":{"clone_505_core_unchanged":True,"instrumented_506_scripts":True,"Game_exe_launched_prior":True,"adapter_evaluated":False,"in_game_pixels_captured":False,
 "reason":"No adapter log even when invoked at toplevel before Main; window capture black and foreground browser. Cause unresolved."},
 "Godot_file_shas":{q.name:hashlib.sha256(q.read_bytes()).hexdigest() for q in imgs},
 "user_visual_quality":"CANDIDATE_IMPROVED_NO_HUMAN_APPROVAL",
 "no_original_art_published":True,
 "formal_pass":False
}
(p/"A09_3_QA.json").write_text(json.dumps(QA,ensure_ascii=False,indent=2),encoding="utf-8")
files=[
p/"extract_joe_weapon.py",p/"joe_weapon_authority.json",p/"inspect_weapon_runtime.py",
p/"audit_weapon_runtime_formulas.py",p/"source_formula_audit.json",
p/"rgss2_capture_adapter.rb",p/"build_bridge.py",p/"patch_bridge_v2.py",
p/"run_bridge.py",p/"bridge_build.json",p/"bridge_runtime_report.json",
p/"A09_3_QA.json",
engine/"capture_weapon.gd",engine/"capture_weapon_v2.gd",
engine/"joe_weapon_authority.json",engine/"source_formula_audit.json",
engine/"A09_3_WEAPON_RENDER.json",engine/"A09_3_WEAPON_FORMULA_V2_LOG.json",
engine/"A09_3_WEAPON_AUTHORITY_CANDIDATE.png",engine/"A09_3_WEAPON_FORMULA_V2_CANDIDATE.png",
engine/"weapon_icon_2.png"]
out=p/"ASF_A09_3_WEAPON_PRIVATE_20261031.zip"
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=8) as z:
 for f in files:
  assert f.exists(),f
  z.write(f,("a09_3/" + f.name) if f.parent==p else ("godot/" + f.name))
with ZipFile(out) as z:
 assert z.testzip() is None
 inv={"path":str(out),"name":out.name,"bytes":out.stat().st_size,
 "files":len(z.namelist()),"sha256":hashlib.sha256(out.read_bytes()).hexdigest(),
 "CRC":"PASS","storage":"PRIVATE_LOCAL_WINDOWS_ONLY"}
(p/"A09_3_ZIP_INVENTORY.json").write_text(json.dumps(inv,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps(inv,indent=2))