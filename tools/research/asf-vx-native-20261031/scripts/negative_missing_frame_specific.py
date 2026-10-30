from pathlib import Path
import json,subprocess,shutil,sys
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
bad=root/"neg_missing_frame_specific";(bad/"frames").mkdir(parents=True,exist_ok=True)
m=json.loads((root/"clips.v2.json").read_text(encoding="utf-8"))
missing="down-0.png"
for f in (root/"frames").glob("*.png"):
 if f.name!=missing: shutil.copy2(f,bad/"frames"/f.name)
(bad/"clips.json").write_text(json.dumps(m,indent=2),encoding="utf-8")
tool=Path(r"E:\GameAssetToolLab_20261023\ASF_SkillRegistry_20261030\generate2dsprite\scripts\build_animation_clips.py")
out=bad/"MUST_NOT_PUBLISH"
p=subprocess.run([sys.executable,str(tool),"--manifest",str(bad/"clips.json"),"--output-dir",str(out),"--strict"],capture_output=True,text=True)
status={"exit_code":p.returncode,"published":out.exists(),"missing_frame":missing,"frame_sources_present":len(list((bad/"frames").glob("*.png"))),"stderr":p.stderr[:1000],"expected":"non-zero exit, 11/12 source frames present, no output"}
(root/"negative_test_result.json").write_text(json.dumps(status,indent=2),encoding="utf-8")
print(json.dumps(status,indent=2))
assert p.returncode!=0 and not out.exists() and status["frame_sources_present"]==11 and "down-0.png" in p.stderr,"MISSING FRAME FAIL-CLOSED CHECK"