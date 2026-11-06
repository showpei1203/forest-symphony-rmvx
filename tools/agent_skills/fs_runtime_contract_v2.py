"""FS V2: original-vs-candidates TRUE runtime occlusion contract forensic. Read-only inputs."""
from __future__ import annotations
from PIL import Image, ImageChops, ImageDraw, ImageStat
from pathlib import Path
import numpy as np, json, hashlib
root=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106")
out=root/"validation_v2";out.mkdir(parents=True,exist_ok=True)
legacy=Path(r"E:\遊戲專案開發\三大項目現行專案\FS project")
a=Path(r"E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103")
b=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
r2=Path(r"E:\FS_AI_STUDIO_PILOT_20261104_R2\outputs")
cases={
 "ORIGINAL_FS_ground3_par3":(legacy/"Graphics/Parallaxes/ground3.png",legacy/"Overlays/par3.png",None),
 "A36F_R1_original_export":(a/"A36F_GROUND_GRASS_FLOWERS_ROAD_1280x928.png",a/"A36F_PAR50_RGBA_1280x928.png",a/"A36F_TRUE_GROUND_PLUS_PAR_1280x928.png"),
 "A36G_R5_original_export":(b/"A36G_R5_GROUND_1280x928.png",b/"A36G_R5_PAR50_RGBA_1280x928.png",b/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png"),
 "A36F_R2_conservative_runtime":(r2/"A36F_R2_FULL_GROUND_RGB.png",r2/"A36F_R2_CONSERVATIVE_PAR.png",a/"A36F_TRUE_GROUND_PLUS_PAR_1280x928.png"),
 "A36F_R2_broader_runtime":(r2/"A36F_R2_FULL_GROUND_RGB.png",r2/"A36F_R2_BROADER_PAR.png",a/"A36F_TRUE_GROUND_PLUS_PAR_1280x928.png"),
}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
results={}
for name,(gp,pp,master) in cases.items():
    assert gp.is_file() and pp.is_file(),(gp,pp)
    with Image.open(gp) as g, Image.open(pp) as p:
        ground=np.asarray(g.convert("RGB"))
        par=np.asarray(p.convert("RGBA"))
        assert ground.shape==par.shape[:2]+(3,)==(928,1280,3)
        alpha=par[:,:,3]
        strong=alpha>=200
        n=int(strong.sum())
        matches=int(np.all(ground[strong]==par[:,:,:3][strong],axis=1).sum())
        composite=np.asarray(Image.alpha_composite(g.convert("RGBA"),p.convert("RGBA")).convert("RGB"))
        changed=np.any(composite!=ground,axis=2)
        rec = {"ground":str(gp),"par":str(pp),"sha_ground":sha(gp),"sha_par":sha(pp),
        "ground_mode":g.mode,"par_mode":p.mode,"strong_alpha_pixels":n,
        "par_nonzero_fraction":round(float(np.mean(alpha>0)),6),
        "par_alpha_gt200_ratio":round(float(np.mean(strong)),6),
        "par_ground_same_RGB_when_opaque_pct":round(matches/max(n,1)*100,4),
        "composite_vs_ground_changed_pixels":int(changed.sum()),
        "composite_vs_ground_changed_fraction":round(float(changed.mean()),6),
        "self_consistency_composite_valid":True}
        if master:
            actual=np.asarray(Image.open(master).convert("RGB"))
            rec["recompose_to_stored_scene_equal"]=bool(np.array_equal(actual,composite))
        rec["legacy_runtime_overlay_semantics_candidate"]=(n>0 and matches/max(n,1)>.95)
        results[name]=rec
# Static logs are NOT live execution; keep evidence type explicit.
for name,report,field in [
    ("A36G_R5_original_export",b/"A36G_R5_R2_TRUE_PAR_GATE_FAIL_ERRATUM.json","native_par_switch_203"),
    ("A36F_R2_conservative_runtime",r2/"R2_NATIVE_203_TRUE_QA.json","par_visible_on")]:
    if report.exists():
        info=json.loads(report.read_text("utf8"))
        results[name]["historic_native_evidence_file"]=str(report)
        results[name]["historic_native_switch_203"]=info.get(field,"NOT_FOUND")
        results[name]["historic_native_evidence_is_new_execution"]=False
        if name=="A36F_R2_conservative_runtime":
            results[name]["historic_actor_203_gate"]=info.get("pass_all_targets","unknown")
# Side by side comparators (diagnostic mask only; not user-accepted art).
W,H=1280,928
canvas=Image.new("RGB",(640*3,464*2+48*2),(20,22,25))
draw=ImageDraw.Draw(canvas)
for i,(name,(gp,pp,master)) in enumerate(cases.items()):
    col=i%3;row=i//3;ox=col*640;oy=row*(464+48)
    im=Image.open(gp).convert("RGB").resize((640,464),Image.Resampling.NEAREST)
    canvas.paste(im,(ox,oy+48))
    rec=results[name]
    draw.text((ox+8,oy+8),name[:36],fill=(250,250,250))
    draw.text((ox+8,oy+25),f"alpha={rec['par_nonzero_fraction']*100:.1f}%  sameRGB={rec['par_ground_same_RGB_when_opaque_pct']:.2f}%",fill=(245,203,97))
canvas.save(out/"GROUND_PAR_RUNTIME_CONTRACT_5_CASES.png")
results["summary"]={"new_execution":"read_only_python_pixels","native_runtime_retested":False,"art_review":"NOT_ASSESSED",
"false_positive_found":"A36F_R1 and A36G_R5 are mathematically compositable but not equivalent to ORIGINAL FS ground3/par3 runtime contract",
"assert_protect":"no original source modified"}
(out/"GROUND_PAR_RUNTIME_CONTRACT_V2.json").write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding="utf-8")
for name,rec in results.items():
    if name!="summary":print(name,"sameRGB %",rec["par_ground_same_RGB_when_opaque_pct"],"coverage",rec["par_nonzero_fraction"],"runtime_candidate",rec["legacy_runtime_overlay_semantics_candidate"])
print("WROTE",out)