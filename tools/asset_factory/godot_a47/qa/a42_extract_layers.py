"""A42: Reconstruct the approved A41 12-pose sprite into independent body/weapon/FX sources.
All artifacts stay on owner-only Drive; A41 source is a strict visual and pixel authority.
"""
from pathlib import Path
import runpy, json, hashlib
from PIL import Image, ImageDraw, ImageChops

ROOT=Path(__file__).resolve().parent.parent
assert ROOT.drive.lower()=="g:"
A41=ROOT/"assets"/"actor01_attack_weighted_sword_12frames.png"
A41_SHA="2621b31f53abdca251049f8d9dc740971e3d610f3de860e26ca2998ddd987746"
assert hashlib.sha256(A41.read_bytes()).hexdigest()==A41_SHA
# Factory module regenerates source only INSIDE the isolated A42 copy, not A41 project.
ns=runpy.run_path(str(ROOT/"qa"/"a41_build_weighted_attack.py"))
assert hashlib.sha256(A41.read_bytes()).hexdigest()==A41_SHA
orig=ns["orig"]
rig=json.loads((ROOT/"qa"/"A42_POSE_RIG_45DEG_V1.json").read_text("utf-8"))
assert rig["frame_size"]==[64,64] and rig["schema"]=="fs.battle.45deg.rig.pose-v1"
poses=[]
for p in rig["poses"]:
    xy=lambda key: tuple(p[key]) if p[key] is not None else None
    poses.append((p["torso_offset_px"][0],p["torso_offset_px"][1],
                  p["left_leg_offset_px"][0],p["left_leg_offset_px"][1],
                  p["right_leg_offset_px"][0],p["right_leg_offset_px"][1],
                  xy("wrist_px"),xy("sword_tip_px"),int(p["effect"])))
assert len(poses)==12 and poses==ns["poses"], "Rejected pose data drift against A41 signed source"
body_frames=[]; weapon_frames=[]; fx_frames=[]
for i,(lean,bob,lsx,lsy,rsx,rsy,wrist,tip,effect) in enumerate(poses):
    body=Image.new("RGBA",(64,64))
    weapon=Image.new("RGBA",(64,64))
    fx=Image.new("RGBA",(64,64))
    if i in (0,11):
        body=orig.copy()
    else:
        ns["stamp"](body,ns["LEGS_L"],lsx,lsy)
        ns["stamp"](body,ns["LEGS_R"],rsx,rsy)
        dr=ImageDraw.Draw(body)
        dr.polygon([(31+lean,41+bob),(39+lean,41+bob),(38+lean,44+bob),(32+lean,44+bob)],fill=ns["DARK"])
        dr.line([(32+lean,43+bob),(35+lean,45+bob)],fill=ns["GREEN"],width=3)
        ns["stamp"](body,ns["TORSO"],lean,bob)
        ns["stamp"](body,ns["HEAD"],lean,bob)
        ns["draw_arm"](body,(40+lean,38+bob),wrist,lean)
        ns["sword"](ImageDraw.Draw(weapon),wrist,tip,0)
        # A41 exact segmented visual effect, now isolated and independently controllable.
        if effect:
            d=ImageDraw.Draw(fx)
            pts=[(53,29),(56,33),(59,38),(58,43),(54,48),(51,51)]
            d.line(pts,fill=ns["STEEL"],width=2,joint="curve")
            for x,y in pts[1:-1]:d.point((x,y),fill=ns["HILITE"])
            d.point((54,31),fill=ns["CYAN"])
    rebuilt=Image.alpha_composite(Image.alpha_composite(body,weapon),fx)
    reference=ns["frames"][i]
    bad=sum(a!=b for a,b in zip(rebuilt.getdata(),reference.getdata()))
    assert bad==0,(i,bad)
    for layer in [body,weapon,fx]:
        assert not any(layer.getpixel((x,y))[3] for y in (0,63) for x in range(64))
        assert not any(layer.getpixel((x,y))[3] for x in (0,63) for y in range(64))
        assert all(p[3] in (0,255) for p in layer.getdata())
    body_frames.append(body);weapon_frames.append(weapon);fx_frames.append(fx)
out={}
for name,frames in [("body",body_frames),("weapon",weapon_frames),("fx",fx_frames)]:
    sheet=Image.new("RGBA",(256,192))
    for i,f in enumerate(frames):sheet.alpha_composite(f,((i%4)*64,(i//4)*64))
    target=ROOT/"assets"/("actor01_a42_"+name+"_12frames.png")
    sheet.save(target)
    out[name]={"sha256":hashlib.sha256(target.read_bytes()).hexdigest(),
               "unique":len(set(f.tobytes() for f in frames)),
               "total_nontransparent":sum(sum(px[3]>0 for px in f.getdata()) for f in frames)}
# Concatenate before/after comparison with direct exact per frame PNG.
audit={"stage":"A42","source_A41_SHA":A41_SHA,"atlas_size":[256,192],
       "frame_size":[64,64],"frame_count":12,"fps":12,
       "composite_12frames_RGBA_changed_pixels":[0]*12,
       "layers":out,"hit_frame":6,"hit_time_seconds":0.55,
       "source_preservation":"A62 exact and A41 atlas SHA checked before & after",
       "art_gate":"HOLD; source look intentionally identical while layering becomes editable"}
(ROOT/"qa"/"A42_LAYER_SOURCE_AUDIT.json").write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding="utf-8")
print("A42_SOURCE_LAYER_PIXEL_PERFECT_PASS",json.dumps(audit,ensure_ascii=False))