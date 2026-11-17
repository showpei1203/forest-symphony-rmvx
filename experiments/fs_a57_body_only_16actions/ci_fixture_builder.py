#!/usr/bin/env python3
"""A57 PUBLIC CI ONLY: synthetic atlas for Godot logic, NEVER FS art.
Private A53 SHA is checked independently in owner-only Drive package.
"""
from pathlib import Path
import hashlib, json, sys
from PIL import Image, ImageDraw

out=Path(sys.argv[1])
assets=out/"assets"
assets.mkdir(parents=True,exist_ok=True)
sheet=Image.new("RGBA",(256,192),(0,0,0,0))
for i in range(12):
    frame=Image.new("RGBA",(64,64),(0,0,0,0))
    d=ImageDraw.Draw(frame)
    x=28+(i%3)
    d.ellipse((x-10,7,x+10,28),fill=(150,160,180,255))
    d.rectangle((x-6,28,x+6,43),fill=(120,150,190,255))
    d.line((x-3,43,x-8,55),fill=(210,210,205,255),width=3)
    d.line((x+3,43,x+9,55),fill=(210,210,205,255),width=3)
    d.line((x+4,30,45,42),fill=(155,165,175,255),width=3)
    sheet.alpha_composite(frame,((i%4)*64,(i//4)*64))
src=assets/"actor01_a53_body_12frames.png"
sheet.save(src)
sha=hashlib.sha256(src.read_bytes()).hexdigest()
anchor={"weapon_graphic_baked":False,"contact_frame":7,"contact_second":0.63,
        "pose_anchors":[{"frame":i,"wrist_px":([47.0,45.0] if i==7 else [42.0,40.0]),
                         "hit_marker_local_px":([15.0,13.0] if i==7 else [10.0,8.0])}
                        for i in range(12)]}
(assets/"actor01_a53_hand_and_fist_anchors.json").write_text(json.dumps(anchor),encoding="utf-8")
player=out/"scripts/a57_body_action_player.gd"
s=player.read_text(encoding="utf-8")
real="af2b94a424ab613fa5a8ff45125f0398da3a20432cdeaa744f87f9f1b1a9ac44"
if s.count(real)!=1:raise SystemExit("Expected real hash exactly once")
player.write_text(s.replace(real,sha),encoding="utf-8")
print("A57_SYNTHETIC_CI_FIXTURE_READY; not real FS art; source contract separately retained")
