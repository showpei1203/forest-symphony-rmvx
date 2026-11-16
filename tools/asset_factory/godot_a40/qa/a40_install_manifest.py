from pathlib import Path
import json
root=Path(__file__).resolve().parent.parent
file=root/'assets'/'actor01_animation_manifest.json'
manifest=json.loads(file.read_text(encoding='utf-8'))
profile={
'motion':'attack',
'sprite_sheet':'res://assets/actor01_attack_lunge_8frames.png',
'grid':{'frame_width':64,'frame_height':64,'columns':4,'rows':2,'frame_count':8},
'fps':10.0,'durations':[1,1,1,1,1,1,1,1],
'loop':False,
'hit_event_second':0.44,
'art_gate':'HOLD: original-pixel front-arm jab, needs visual acceptance',
'provenance':'A62 exact source; non-generative editable 8-keypose reconstruction'
}
assert 'attack_slash' not in manifest['animation_profiles'] or manifest['animation_profiles']['attack_slash']==profile
manifest['animation_profiles']['attack_slash']=profile
manifest['default_profiles']['attack']='attack_slash'
manifest['unsupported_motions']=[s for s in manifest['unsupported_motions'] if s!='attack']
file.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('A40_MANIFEST_INSTALLED',manifest['default_profiles'],len(manifest['animation_profiles']))