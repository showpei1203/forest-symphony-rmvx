from pathlib import Path
import shutil,subprocess,sys,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\T1T2_NEW_PIPELINE")
src=root/"T1_hero"/"r2"
dst=root/"NEGATIVE_MISSING_FRAME";assert not dst.exists(),"negative fixture already exists"
(dst/"frames").mkdir(parents=True)
for p in (src/"frames").glob("*.png"):
 if p.name!="attack_02.png":shutil.copy2(p,dst/"frames"/p.name)
shutil.copy2(src/"clips.json",dst/"clips.json")
tool=Path(r"E:\GameAssetToolLab_20261023\ASF_SkillRegistry_20261030\generate2dsprite\scripts\build_animation_clips.py")
target=dst/"must_not_publish"
r=subprocess.run([sys.executable,str(tool),"--manifest",str(dst/"clips.json"),"--output-dir",str(target),"--strict"],capture_output=True,text=True)
qa={"missing":"attack_02.png","files_present":len(list((dst/"frames").glob("*.png"))),"files_required":24,"code":r.returncode,
"published":target.exists(),"error_excerpt":r.stderr[-1000:],"PASS_FAILCLOSED":r.returncode!=0 and not target.exists()}
assert qa["PASS_FAILCLOSED"] and qa["files_present"]==23
(root/"R2_NEGATIVE_FAILCLOSED_QA.json").write_text(json.dumps(qa,indent=2),encoding="utf-8")
print(json.dumps(qa,indent=2))