#!/usr/bin/env python3
"""A56 R2: compact, face-clearing shield overlay for real A53 Body.

Geometry is a NON-APPROVED proof-of-depth candidate, not new FS canon.
Source: A53 canonical Body + wrist manifest. Do not upload derived pixels to
public GitHub; owner-private Drive only. All source bytes are immutable.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from PIL import Image, ImageDraw

from a56_real_body_occlusion import (
    rgba_atlas_frames, anchor_points, mask_region, leakage, mask_count,
    alpha_edges, verify_registration, shield_geometry, visible_tip, sha256,
)

V2 = {'dx': 3, 'dy': 3, 'rx': 7, 'ry': 9}
HEAD_ROI = (20, 15, 46, 33)  # Witness region, NOT full head segmentation.


def shield_r2(wrist):
    cx, cy = wrist[0] + V2['dx'], wrist[1] + V2['dy']
    rx, ry = V2['rx'], V2['ry']
    box = [round(cx-rx), round(cy-ry), round(cx+rx), round(cy+ry)]
    img = Image.new('RGBA', (64, 64))
    d = ImageDraw.Draw(img)
    d.ellipse(box, fill=(89, 62, 39, 255), outline=(190, 162, 107, 255), width=2)
    for off in (-2, 1, 3):
        d.line((round(cx+off), round(cy-5), round(cx+off), round(cy+5)), fill=(106, 75, 47, 255), width=1)
    d.ellipse((round(cx-2),round(cy-2),round(cx+2),round(cy+2)),
              fill=(160,177,184,255),outline=(75,84,94,255),width=1)
    return img, img.getchannel('A')


def blade_r2(wrist):
    cx, cy = wrist[0] + V2['dx'], wrist[1] + V2['dy']
    end = round(cx - V2['rx'] + 1)
    y=round(cy + 1)
    img=Image.new('RGBA',(64,64))
    d=ImageDraw.Draw(img)
    d.polygon([(end-15,y), (end-8,y-3), (end,y), (end-8,y+3)],fill=(189,200,217,255))
    d.line((end-9,y,end-1,y),fill=(111,123,151,255),width=1)
    return img


def head_overlap_proxy(body, shield_mask):
    a=body.getchannel('A')
    x0,y0,x1,y1=HEAD_ROI
    return sum(a.getpixel((x,y))>=128 and shield_mask.getpixel((x,y))>=128
               for y in range(y0,y1) for x in range(x0,x1))


def compile_r2(body_path:Path,anchors_path:Path,output_dir:Path):
    raw=body_path.read_bytes()
    frames=rgba_atlas_frames(body_path)
    points=anchor_points(anchors_path)
    report=[]
    final=[]
    before_after=[]
    for f,(body,hand) in enumerate(zip(frames,points)):
        old_shield,_=shield_geometry(hand)
        old_blade=visible_tip(hand)
        old=Image.alpha_composite(Image.alpha_composite(body,old_shield),old_blade)
        shield,m=shield_r2(hand)
        tip=blade_r2(hand)
        new=Image.alpha_composite(Image.alpha_composite(body,shield),tip)
        wrist_mask=mask_region(body.getchannel('A'),hand)
        witness=verify_registration(body,shield,tip,new,wrist_mask,m,check_hidden=True)
        face=head_overlap_proxy(body,m)
        old_face=head_overlap_proxy(body,old_shield.getchannel('A'))
        if face>2:
            raise AssertionError(f'R2 F{f} face ROI overlap {face}>2 pixels')
        if leakage(tip.getchannel('A'),m)<8:
            raise AssertionError(f'R2 F{f} blade-tip not visible')
        if witness['uncovered_marked_wrist_px']:
            raise AssertionError(f'R2 F{f} wrist leak')
        witness.update({'frame':f, 'head_region_occlusion_proxy_px':face,
                        'old_head_region_occlusion_proxy_px':old_face,
                        'visible_tip_px':leakage(tip.getchannel('A'),m),
                        'clearance_status':'ENGINEERING_ONLY_ART_HOLD'})
        report.append(witness)
        final.append(new)
        compare=Image.new('RGBA',(192,64),(15,25,34,255))
        compare.alpha_composite(body,(0,0));compare.alpha_composite(old,(64,0));compare.alpha_composite(new,(128,0))
        before_after.append(compare)
    if body_path.read_bytes()!=raw:
        raise AssertionError('Canonical A53 Body mutated')
    output_dir.mkdir(parents=True,exist_ok=True)
    atlas=Image.new('RGBA',(256,192))
    for f,frame in enumerate(final):atlas.paste(frame,(f%4*64,f//4*64))
    atlas.save(output_dir/'A56_R2_REAL_A53_SOURCE_REGISTERED_12F.png')
    atlas.resize((1024,768),Image.Resampling.NEAREST).save(output_dir/'A56_R2_REAL_A53_ART_REVIEW_4X.png')
    before_after[0].save(output_dir/'A56_R2_OLD_V1_V2_NATIVE_1X.gif',save_all=True,
                         append_images=before_after[1:],duration=100,loop=0,disposal=2)
    info={'stage':'A56_R2_REAL_A53_COMPACT_SHIELD_ENGINEERING',
          'result':'PIXEL_GEOMETRY_PASS_ART_HOLD',
          'engine':'PIL SOURCE_REGISTRATION; NOT GODOT GPU',
          'canonical_source_sha256':sha256(body_path),
          'source_preserved':True,'frames':report,
          'max_head_region_overlap_proxy_px':max(x['head_region_occlusion_proxy_px'] for x in report),
          'v1_max_head_overlap_proxy_px':max(x['old_head_region_occlusion_proxy_px'] for x in report),
          'total_wrist_leak_px':sum(x['uncovered_marked_wrist_px'] for x in report),
          'head_region_not_semantic_mask':True,
          'complete_arm_occlusion':'NOT_RUN',
          'new_shield_visual':'PROCEDURAL PLACEHOLDER, NOT APPROVED',
          'art':'HOLD', 'godot_real_a53_gpu':'NOT_RUN'}
    (output_dir/'A56_R2_QA_REPORT.json').write_text(json.dumps(info,ensure_ascii=False,indent=2),encoding='utf8')
    return info


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--body',required=True,type=Path)
    p.add_argument('--anchors',required=True,type=Path)
    p.add_argument('--out',required=True,type=Path)
    args=p.parse_args()
    data=compile_r2(args.body,args.anchors,args.out)
    print(json.dumps({k:v for k,v in data.items() if k!='frames'},ensure_ascii=False,indent=2))

if __name__=='__main__':main()
