"""Read-only body pose diagnostics. Never declares visual approval or generates art."""
import argparse, hashlib, json, tempfile
from pathlib import Path
from PIL import Image
from motion_pack import validate

SOURCE = "f56855bcec4a2db5f7715859c42ba020d7b27cf00a131aedac59a07d77206f11"
ATLAS = "9569bc8beac9d928be39f482faaa8f5a2289549c7bb0b099fed8072c118d3ae5"
PHASES = ["ready","anticipation","weight_transfer","acceleration","strike","follow_through","deceleration","recover"]
CHECKS = ["identity","camera","torso","shoulder_elbow_wrist","head_motion","hip_weight_transfer","foot_contact","weapon_free","fx_free"]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok, code):
    if not ok: raise ValueError(code)
def review(bundle, out, synthetic=False):
    bundle, out = Path(bundle), Path(out)
    require(not out.exists() and not out.resolve().is_relative_to(bundle.resolve()), "OUTPUT_LOCATION")
    m = json.loads((bundle/"motion.json").read_text())
    require(m.get("schema")==1 and m.get("action")=="attack" and m.get("body_only") is True and m.get("frame_count")==8 and m.get("cell")==64 and m.get("columns")==4 and m.get("anchor")==[32,50] and m.get("loop") is False and m.get("events")==[] and m.get("art")=="HOLD", "CONTRACT")
    require(m.get("source_class")==("SYNTHETIC_TEST_ONLY" if synthetic else "OWNER_SUPPLIED_UNAUTHENTICATED"), "PROVENANCE")
    require(m.get("airborne_frames")==[], "AIRBORNE")
    src, atlas_path = bundle/"source.bin", bundle/"body.png"
    require(sha(src)==m.get("source_sha256") and sha(atlas_path)==m.get("atlas_sha256"), "MANIFEST_HASH")
    if not synthetic:
        require(sha(src)==SOURCE and sha(atlas_path)==ATLAS, "REAL_ATTACK_PIN")
    frames=[bundle/f"F{i:02d}.png" for i in range(1,9)]
    records=m.get("frames",[])
    require(len(records)==8 and [r.get("index") for r in records]==list(range(8)), "FRAME_ORDER")
    atlas, measured=validate("attack",src,frames,m["durations_ms"],m["source_sha256"],[r["sha256"] for r in records])
    require(measured==records and m.get("atlas_size")==list(atlas.size), "METADATA")
    with Image.open(atlas_path) as disk:
        require(disk.mode=="RGBA" and disk.size==atlas.size and disk.tobytes()==atlas.tobytes(), "ATLAS_PARITY")
    images=[]; metrics=[]; previous=None
    for i,p in enumerate(frames):
        with Image.open(p) as im: frame=im.copy()
        mask={j for j,a in enumerate(frame.getchannel("A").getdata()) if a}
        cx=sum(j%64 for j in mask)/len(mask)
        cy=sum(j//64 for j in mask)/len(mask)
        change=None if previous is None else round(1-len(mask&previous)/len(mask|previous),4)
        metrics.append({"frame":i+1,"sha256":sha(p),"bbox":list(frame.getbbox()),"opaque_pixels":len(mask),"silhouette_centroid":[round(cx,3),round(cy,3)],"silhouette_jaccard_change":change,"candidate_phase":PHASES[i],"phase_mapping":"UNVERIFIED","visual_checks":{k:"NOT_REVIEWED" for k in CHECKS}})
        images.append(frame);previous=mask
    report={"schema":1,"scope":"SYNTHETIC_ONLY" if synthetic else "PINNED_OWNER_ATTACK8","source_sha256":sha(src),"atlas_sha256":sha(atlas_path),"structure":"PASS","art":"HOLD","gameplay":"NOT_RUN","pose_mapping":"UNVERIFIED","notes":"Centroid and silhouette changes are diagnostics only, not joints, center of mass, anatomy or acceptance.","frames":metrics}
    out.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(dir=out.parent) as t:
        stage=Path(t)/"review";stage.mkdir()
        atlas.save(stage/"contact_1x.png")
        atlas.resize((atlas.width*4,atlas.height*4),Image.Resampling.NEAREST).save(stage/"contact_4x.png")
        images[0].save(stage/"preview.gif",save_all=True,append_images=images[1:],duration=m["durations_ms"],loop=0,disposal=2)
        (stage/"pose_review.json").write_text(json.dumps(report,indent=2)+"\n")
        stage.rename(out)
    return report
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("bundle",type=Path);p.add_argument("out",type=Path);p.add_argument("--synthetic",action="store_true");a=p.parse_args()
    print(json.dumps(review(a.bundle,a.out,a.synthetic),indent=2))
