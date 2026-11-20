#!/usr/bin/env python3
"""Prepare a SOURCE LOCKED 96px first frame and 11-frame physical ATTACK plan.
No animation is generated. Binary first frame is private, code and JSON plan are public.
Use PixelLab Skeleton v3 with 11 frames. If Skeleton fails, v3 Text requires EVEN 12 frames.
"""
from __future__ import annotations
import argparse,json,hashlib
from pathlib import Path
from PIL import Image

EVENTS={"rush_frame":2,"hit_frame":5,"return_frame":7}
NATIVE_DURATIONS=[4,2,4,2,2,2,2,2,2,2,4]
TIMELINE={
  0:("NEUTRAL","source image exact lock; low crouch, closed mouth, four limbs visible"),
  1:("ANTICIPATION","hind knees tuck, head lowers slightly, elbows change angle; feet anchor"),
  2:("RUSH_START","hind legs extend; front legs lift, true articulation; head maintains 3/4 southeast"),
  3:("LEAP","front limbs reach forward; hind limbs trail; keep toes intact"),
  4:("BITE_WINDUP","head leans forward, jaw starts opening; front leg leads"),
  5:("HIT","clearly opened jaw and contact thrust; distinct from frames 4 and 6; NO fireball"),
  6:("FOLLOW_THROUGH","jaw begins closing, shoulders and front paws shift"),
  7:("RETURN","front paws plant, hind legs tuck, root moves back"),
  8:("LANDING","four feet grounded, stable body angle, not identical to frame 7"),
  9:("RECOVER","final small shoulder/head return, closed mouth"),
 10:("NEUTRAL_END","same identity and angle as first frame; restore footpoint")
}

def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def main(source:Path,out:Path):
    out.mkdir(parents=True,exist_ok=True)
    src=Image.open(source).convert('RGBA')
    assert src.size==(64,64)
    frame=Image.new('RGBA',(96,96))
    frame.alpha_composite(src,(16,24))
    bbox=frame.getbbox()
    assert bbox and all([bbox[0]>=12,bbox[1]>=12,bbox[2]<84,bbox[3]<=84]),bbox
    out_path=out/'PMD0001_ATTACK_V3_FIRST_FRAME_96.png'
    frame.save(out_path)
    plan={
       "schema":"fs-tb-attack-v3-keypose-plan","status":"PREFLIGHT_ONLY_NO_ANIMATION",
       "method":"PixelLab estimate-skeleton + animate-with-skeleton-v3; fall back to Text-v3 12f when necessary",
       "asset":"PMD0001","action":"ATTACK_PHYSICAL_LUNGE_BITE",
       "not_actions":["LAVA_SPIT","CAST","SKILL"],
       "source_id":"1jDRbwUfk-Y_5wk_8JVSXMygTun2OfSAR",
       "source_64_sha256":sha(source),"first_frame_96_sha256":sha(out_path),
       "first_frame_png":out_path.name,"transparent_canvas":[96,96],
       "source_position":[16,24],"source_frame_bbox_96":list(bbox),"feet_pivot_96":[48,83],
       "view":"source 3/4 right-facing, 45degree ART verification pending",
       "pixel_scale":"no interpolation, no photo/painting, original sprite nearest pixel",
       "target":{"frame_count":11,"frame_size":[96,96],"atlas_columns":4,"atlas_rows":3,"atlas_dimensions":[384,288],"loop":False},
       "native_reference":{"drive_id":"1QWdMHbu1VTQ85kaOEXSankeSsIY6FvOS","native_count":11,
          "native_frame_size":[64,72],"durations_ticks":NATIVE_DURATIONS,"event_indices":EVENTS},
       "frames":[{"index":idx,"stage":name,"pose":desc,"duration_tick":NATIVE_DURATIONS[idx],
           "event":next((k for k,v in EVENTS.items() if v==idx),None)} for idx,(name,desc) in TIMELINE.items()],
       "generation":{"actual_calls":0,"job_id":None,"actual_generations":0,"note":"first-frame padding plus schema only; NO API generation"},
       "art_blockers":["NO_INDEPENDENT_LEG_MOTION","MOUTH_DOES_NOT_OPEN_AT_HIT","CHARACTER_IDENTITY_DRIFT","45_VIEW_DRIFT","FRAME_CROP","FX_SUBSTITUTES_FOR_ATTACK"],
       "prompt":"Animate exactly the attached original lava frog into a short physical lunge-and-bite ATTACK, 3/4 top-down view facing southeast. Eleven frames follow the keypose plan: crouch anticipation, visible hind-leg kick-off, forward leap with separate foreleg and hindleg poses, clearly opened jaw on frame 5 HIT, four-paw landing, settle back to original stance. Keep the basalt shell, orange lava cracks, eyes, toes, body proportions and local color palette identical to the first frame. Four independently moving legs; no whole-body scale-only trick. Maintain transparency, crisp native pixel art and consistent feet pivot. No flying fireball, no second character, no text, no horizon, no extra limbs, no cropped feet or duplicate mouth. Frame 0 is the exact source."
    }
    p=out/'TB_ATTACK_V3_KEYPOSE_CONTRACT.json'
    p.write_text(json.dumps(plan,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('V3 first frame',out_path.name,out_path.stat().st_size,sha(out_path),'bbox',bbox)
    print('V3 contract',p.name,p.stat().st_size,'frames',len(TIMELINE),'cost: 0 actual API calls')

if __name__=='__main__':
    ap=argparse.ArgumentParser()
    ap.add_argument('--source',required=True,type=Path)
    ap.add_argument('--out',required=True,type=Path)
    a=ap.parse_args();main(a.source,a.out)
