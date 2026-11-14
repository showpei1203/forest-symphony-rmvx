from pathlib import Path
import json
r=Path(__file__).resolve().parent.parent
f=r/'assets'/'actor01_animation_manifest.json'
data=json.loads(f.read_text('utf-8'))
data['animation_profiles']['attack_weighted']={
'motion':'attack','sprite_sheet':'res://assets/actor01_attack_weighted_sword_12frames.png',
'grid':{'frame_width':64,'frame_height':64,'columns':4,'rows':3,'frame_count':12},
'fps':12.0,'durations':[1]*12,'loop':False,'hit_time':0.55,'hit_frame':6,
'art_gate':'HOLD: rigged original-palette 45 degree sword strike, user visual approval pending',
'provenance':'A62 approved native RGBA recolor-free, 12 weighted poses from source'}
# A40 jab retained as comparative-only but avoids incorrect legacy 0.44s contact timing
data['animation_profiles']['attack_slash']['motion']='attack_legacy_compare'
data['animation_profiles']['attack_slash']['art_gate']='A40 prototype hold, not battle-validated at A41 attack timing'
data['default_profiles']['attack']='attack_weighted'
data['unsupported_motions']=[x for x in data.get('unsupported_motions',[]) if x!='attack']
f.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n','utf-8')
p=r/'project.godot'
s=p.read_text('utf-8').replace('FS A40 Real Attack Keyposes and Hit Timing','FS A41 Weighted 12-Frame Sword Attack')
p.write_text(s,'utf-8')
print('A41_MANIFEST_INSTALLED',len(data['animation_profiles']))