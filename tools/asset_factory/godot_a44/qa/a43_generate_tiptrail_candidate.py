"""A43 non-destructive weapon-trail candidate generator.
Run in the private A42 project copy with Pillow installed. Never modifies A42 atlases.
ART HOLD until native Godot captures and human review.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import json, math

ROOT = Path(__file__).resolve().parents[1]
RIG = json.loads((ROOT / "qa/A42_POSE_RIG_45DEG_V1.json").read_text(encoding="utf-8"))
assert len(RIG["poses"]) == 12 and RIG["frame_size"] == [64, 64]
SRC = ROOT / "assets/actor01_a42_fx_12frames.png"
assert SRC.exists(), "Mount the verified private A42 project first"
assert Image.open(SRC).size == (256,192)
out = Image.new("RGBA", (256,192))
poses = RIG["poses"]
# Temporal blade-tip trail, attached to measured sword tips rather than fixed FX pixels.
# The pre-contact frame is intentionally visible; fade rapidly after follow-through.
alpha_by_frame = {4: 65, 5: 150, 6: 230, 7: 155, 8: 55}
for i in range(12):
    frame = Image.new("RGBA", (64,64))
    if i in alpha_by_frame:
        p = poses[i]
        tip = p["sword_tip_px"]
        wrist = p["wrist_px"]
        assert tip is not None and wrist is not None
        prev = poses[i-1]["sword_tip_px"]
        if prev is not None:
            a = alpha_by_frame[i]
            d = ImageDraw.Draw(frame)
            # Only actual consecutive tip locations: no arbitrary disconnected arc.
            d.line([tuple(prev), tuple(tip)], fill=(58,185,224,a), width=3)
            d.line([tuple(prev), tuple(tip)], fill=(206,246,255,min(255,a+20)), width=1)
            # Blade-adjacent short highlight at current position.
            vx,vy = tip[0]-wrist[0],tip[1]-wrist[1]
            length = max(1, math.hypot(vx,vy))
            inner=(round(tip[0]-vx/length*5),round(tip[1]-vy/length*5))
            d.line([inner,tuple(tip)],fill=(235,250,255,min(255,a+15)),width=1)
    out.alpha_composite(frame, ((i%4)*64,(i//4)*64))
target = ROOT / "assets/actor01_a43_fx_tiptrail_candidate_12frames.png"
out.save(target)
assert Image.open(target).size == (256,192)
print("A43 FX CANDIDATE WRITTEN", target)
print("ART HOLD / GODOT NATIVE NOT RUN / A42 UNCHANGED")
