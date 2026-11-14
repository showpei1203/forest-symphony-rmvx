"""Export a normalized, reusable 45-degree wrist/foot/torso pose manifest.
The authoritative A41 sequence is retained and validated, not AI-resynthesized.
"""
from pathlib import Path
import runpy, json
r=Path(__file__).resolve().parent.parent
ns=runpy.run_path(str(r/'qa/a41_build_weighted_attack.py'))
out=[]
names=['ready','load','guard','draw','windup','accelerate','contact','followthrough','recover','settle','lower','return']
for i,p in enumerate(ns['poses']):
    lean,bob,lsx,lsy,rsx,rsy,wrist,tip,effect=p
    out.append({'frame':i,'phase':names[i],'torso_offset_px':[lean,bob],
                'left_leg_offset_px':[lsx,lsy],'right_leg_offset_px':[rsx,rsy],
                'wrist_px':list(wrist) if wrist else None,
                'sword_tip_px':list(tip) if tip else None,
                'effect':bool(effect),'normalized_wrist':([round(wrist[0]/64,5),round(wrist[1]/64,5)] if wrist else None)})
data={'schema':'fs.battle.45deg.rig.pose-v1','stage':'A42','frame_size':[64,64],'fps':12,
      'view_angle':'topdown three-quarter ~45 degrees','source_actor':'A62 approved Actor01',
      'stable_joints_px':{'right_shoulder':[40,38],'pelvis':[35,43],'contact_anchor':[60,43]},
      'event':{'type':'attack_hit','time_sec':0.55,'visible_frame':6,'hitstop_sec':0.07},
      'head_policy':'copy original source head rigidly without repaint','palette_policy':'native A62 RGBA only','poses':out,
      'scope':'A41 exact 12-pose reference; new actor proportions require explicit rig retarget before acceptance'}
(r/'qa/A42_POSE_RIG_45DEG_V1.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n','utf-8')
print('A42_POSE_RIG_EXPORTED',len(out),data['event'])