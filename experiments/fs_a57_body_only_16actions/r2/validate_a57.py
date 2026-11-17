#!/usr/bin/env python3
"""A57 genuine Body-only action catalog and source geometry QA, no artwork rewriting."""
from __future__ import annotations
import argparse,hashlib,json
from pathlib import Path
from PIL import Image
EXPECTED='af2b94a424ab613fa5a8ff45125f0398da3a20432cdeaa744f87f9f1b1a9ac44'
REQUIRED={
'walking_down','walking_left','walking_right','walking_up','waiting','damage',
'critical_damaged','moving_to_close_attack','victory_pose','dodging','nothing','death',
'front_jump_close_attack','ranged_attack_i','close_ranged_attack','magi_skill_use'}
BANNED={'baked_sword','baked_shield','baked_weapon','baked_fx'}

def audit(path:Path)->dict:
    catalog=json.loads((path/'assets/action_catalog_16.json').read_text(encoding='utf-8'))
    body=(path/'assets/actor01_a53_body_12frames.png')
    anchors=json.loads((path/'assets/actor01_a53_hand_and_fist_anchors.json').read_text(encoding='utf-8'))
    sha=hashlib.sha256(body.read_bytes()).hexdigest()
    im=Image.open(body).convert('RGBA')
    errors=[]
    if sha!=EXPECTED:errors.append('body-source-SHA-mismatch')
    if im.size!=(256,192):errors.append('atlas-must-be-256x192')
    items=catalog.get('items',[])
    if len(items)!=16 or set(x['id'] for x in items)!=REQUIRED:errors.append('catalog-16-action-set-mismatch')
    if [x['row'] for x in items]!=list(range(1,17)):errors.append('row-order-mismatch')
    if any(x['equipment_art']!='EXTERNAL_RUNTIME_ONLY' or x['body_pose']!='NO_WEAPON_SHIELD_FX_BAKED' for x in items):errors.append('baked-equipment-allowed')
    if any(any(k in x for k in BANNED) for x in items):errors.append('baked-equipment-key')
    n=next((x for x in items if x['id']=='nothing'),None)
    if n is None or n['mode']!='EMPTY' or n['play_order']:errors.append('nothing-is-not-empty')
    run=next(x for x in items if x['id']=='moving_to_close_attack')
    if run['play_order'] != [0,1,0,2]:errors.append('run-wrong-leg-sequence')
    waiting=next(x for x in items if x['id']=='waiting')
    if waiting['play_order'] != [0,1,2,1] or waiting['source']!='A63_W3B':errors.append('waiting-wrong-horizontal-loop')
    attack=next(x for x in items if x['id']=='close_ranged_attack')
    if attack['play_order'] != list(range(12)) or attack['contact']['frame']!=7 or abs(attack['contact']['second']-0.63)>1e-8:errors.append('A53-contact-mismatch')
    if len(anchors.get('pose_anchors',[]))!=12 or anchors.get('weapon_graphic_baked') is not False:errors.append('A53-anchor-contract-fail')
    if anchors.get('contact_frame')!=7 or abs(anchors.get('contact_second',0)-0.63)>1e-8:errors.append('anchor-contact-mismatch')
    cand=next(x for x in items if x['id']=='waiting')
    waiting_atlas=path/'assets/actor01_a57_waiting_3pose.png'
    if not waiting_atlas.is_file() or hashlib.sha256(waiting_atlas.read_bytes()).hexdigest()!=cand.get('candidate_sha256'):
        errors.append('waiting-atlas-source-sha-mismatch')
    else:
        w=Image.open(waiting_atlas).convert('RGBA')
        if w.size!=(192,64):errors.append('waiting-atlas-size')
        else:
            f0=w.crop((0,0,64,64));f1=w.crop((64,0,128,64));f2=w.crop((128,0,192,64))
            if f0.tobytes()!=im.crop((0,0,64,64)).tobytes():errors.append('waiting-F0-not-original-body')
            for j,pose in enumerate([f0,f1,f2]):
                if any(pose.crop((0,40,64,64)).tobytes()!=f0.crop((0,40,64,64)).tobytes() for _ in [0]):errors.append('waiting-feet-pelvis-drift-F'+str(j))
    frame_details=[]
    for i in range(12):
        f=im.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64))
        a=f.getchannel('A');edge=sum(a.getpixel((x,y))>0 for x in range(64) for y in (0,63))+sum(a.getpixel((x,y))>0 for y in range(1,63) for x in (0,63))
        if edge:errors.append(f'edge-clip-F{i}')
        frame_details.append({'frame':i,'edge_opaque_pixels':edge,'alpha_nonzero':sum(px>0 for px in a.getdata())})
    return {'status':'PASS' if not errors else 'FAIL','errors':errors,'source_sha256':sha,'action_rows':len(items),'body_frames':frame_details,'actual_equipment_in_scene':False,'native_godot':'NOT_RUN_UNTIL_LOG_VERIFIED','art':'HOLD'}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--project',type=Path,default=Path(__file__).parent.parent);a=p.parse_args()
    report=audit(a.project);print(json.dumps(report,ensure_ascii=False,indent=2));raise SystemExit(0 if report['status']=='PASS' else 1)
