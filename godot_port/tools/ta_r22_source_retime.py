#!/usr/bin/env python3
"""FS T-A R22: retime authentic A52 whole-body frames, never redraw belly.
This is a source-authentic attack-timing experiment, NOT true LPC paper doll or ART PASS.
"""
from __future__ import annotations
import hashlib, io, json, sys, zipfile
from pathlib import Path
from PIL import Image,ImageDraw

A52_SOURCE_SHA='a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f'
APPROVED_F0_SHA='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
# The last hold frame in each motion is the intact approved F0.
A_JAB=[0,1,2,1,2,2,3,4,5,6,9,0]
B_CROSS=[0,1,2,1,2,3,4,5,6,7,9,0]
FIST_COLORS={(216,173,126),(234,201,158),(198,125,97)}

def sha(b):return hashlib.sha256(b).hexdigest()
def tile(a,i):return a.crop((64*(i%4),64*(i//4),64*((i%4)+1),64*((i//4)+1)))
def skin_endpoint(frame):
    # Existing PixelLab skin pixels from right-hand extension in source frames.
    points=[(x,y) for y in range(31,46) for x in range(42,53)
        if frame.getpixel((x,y))[:3] in FIST_COLORS and frame.getpixel((x,y))[3]>0]
    return (max(x for x,y in points),round(sum(y for x,y in points)/len(points),2)) if points else None

def build(zpath,out):
    out.mkdir(exist_ok=True,parents=True)
    with zipfile.ZipFile(zpath) as z:
        raw=z.read('A52_REAL_MODEL_BODY_12FRAME_256x192.png')
        original=Image.open(io.BytesIO(raw)).convert('RGBA')
        assert sha(raw)==A52_SOURCE_SHA and original.size==(256,192)
        ref=z.read('source_provenance/A62_APPROVED_ACTOR01_F0_64.png')
        assert sha(ref)==APPROVED_F0_SHA
        assert tile(original,0).tobytes()==Image.open(io.BytesIO(ref)).convert('RGBA').tobytes()
        base=[tile(original,i) for i in range(12)]
    report={'label':'R22 source-based full-body boxing timing experiment, NOT new attack artwork',
      'input_sha256':A52_SOURCE_SHA,'approved_F0_sha256':APPROVED_F0_SHA,
      'source_frame_origin':'original authentic whole-body A52 paid PixelLab 12-frame model body',
      'all_body_pixels_from_original_provider_frames':True,'changed_torso_pixels_relative_to_source_frame':0,
      'complete_original_LPC_paperdoll_costume_layers':False,
      'new_PixelLab_job':'NOT_RUN','paid_cost':0,
      'contact_event_seconds':0.63,'hitstop_seconds':0.07,'target_frame':7,
      'variants':{},'new_art_approved':False,'original_FSBattle_integration':'NOT_RUN'}
    panel=Image.new('RGB',(256*5,192*5*3),'#1b1e25')
    for row,(key,order) in enumerate([('R21_ORIGINAL',list(range(12))),('R22A_JAB',A_JAB),('R22B_CROSS',B_CROSS)]):
        atlas=Image.new('RGBA',(256,192))
        for n,k in enumerate(order):atlas.alpha_composite(base[k],(64*(n%4),64*(n//4)))
        assert all(tile(atlas,i).tobytes()==base[order[i]].tobytes() for i in range(12))
        assert tile(atlas,0).tobytes()==tile(atlas,11).tobytes()==base[0].tobytes()
        assert all(not any(tile(atlas,i).getpixel((x,y))[3] for x in [0,63] for y in range(64)) for i in range(12))
        outpath=out/f'{key}_ATTACK_BODY_12x64.png';atlas.save(outpath)
        for layer in ('WEAPON','FX'):
            Image.new('RGBA',(256,192)).save(out/f'{key}_{layer}_ZERO.png')
        frames=[tile(atlas,i) for i in range(12)]
        f=[Image.new('RGBA',(64,64),'#1b1e25') for _ in range(12)]
        for i,s in enumerate(frames):f[i].alpha_composite(s)
        f[0].resize((64*6,64*6),Image.Resampling.NEAREST).save(out/f'{key}_F0_6X.png')
        f4=[x.resize((256,256),Image.Resampling.NEAREST).convert('RGB') for x in f]
        f4[0].save(out/f'{key}_ATTACK_4X.gif',save_all=True,append_images=f4[1:],duration=[100,90,90,75,70,65,60,110,85,100,85,100],loop=0,optimize=False)
        contact=skin_endpoint(frames[7]);
        report['variants'][key]={'source_order':order,'f7_original_frame':order[7],
           'distinct_full_body_poses':len(set(s.tobytes() for s in frames)),
           'contact_fist_skin_xy':contact,
           'contact_vs_original_skin_y_advance':(skin_endpoint(base[7])[1]-contact[1] if contact else None),
           'contact_full_body_rgba_delta_vs_R21':sum(a!=b for a,b in zip(frames[7].getdata(),base[7].getdata())),
           'source_atlas_png_sha256':sha(outpath.read_bytes()),
           'F0_F11_approved_source_RGBA_exact':True,'art_status':'ART_HOLD' if key!='R21_ORIGINAL' else 'ART_REJECTED_FOR_BOXING'}
        for idx,fr in enumerate(frames):
            pa=Image.new('RGB',(64,64),'#1b1e25');pa.paste(fr,mask=fr.getchannel('A'))
            panel.paste(pa.resize((320,320),Image.Resampling.NEAREST),((idx%4)*320,row*960+(idx//4)*320))
        if key=='R21_ORIGINAL':
            assert contact==(46,43)
    # Machine-check design decision: F7 has to move fist to upper chest vs old contact.
    assert report['variants']['R22A_JAB']['contact_fist_skin_xy']==(45,36.5)
    assert report['variants']['R22B_CROSS']['contact_fist_skin_xy']==(47,39)
    assert report['variants']['R22A_JAB']['contact_vs_original_skin_y_advance']>=6
    panel.save(out/'R22_R21_VS_A_JAB_VS_B_CROSS_5X.png')
    (out/'R22_SOURCE_RETIME_AND_ART_AUDIT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    return report
if __name__=='__main__':
    import argparse
    p=argparse.ArgumentParser();p.add_argument('--a52',type=Path,required=True);p.add_argument('--out',type=Path,required=True);args=p.parse_args()
    print(json.dumps(build(args.a52,args.out),ensure_ascii=False,indent=2))
