"""FS A28 private exporter: A27 source-locked masks -> cropped RGSS2 PAR bitmaps.

Inputs are owner-only source ZIP bytes. Never commit its image outputs/fixture to
public GitHub. Kept as code in Draft PR; run in an isolated environment.
"""
from __future__ import annotations
import argparse
import hashlib
import io
import json
from pathlib import Path
import zipfile
import numpy as np
from PIL import Image

A27_ZIP_SHA = '4dcec477b9300270ab4f7a0045fdd15b0c6673316c639fd0628cc899b8c85618'
MASTER_SHA = '091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530'
ACTOR_SHA = 'a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba'

# The tuple data must match the RGSS2 Ruby adapter. (name, mask, xyxy, far, near)
SOURCES = [
    ('FS_A28_LEFT_TREE','A27_SOURCE_MASK_LEFT_TREE.png',(75,413,435,551),440,575),
    ('FS_A28_RIGHT_TREE','A27_SOURCE_MASK_RIGHT_TREE.png',(1039,645,1280,928),700,927),
    ('FS_A28_BRIDGE_RAIL','A27_SOURCE_MASK_BRIDGE_RAIL.png',(667,582,773,654),610,641),
]
CASES = [
    ('TREE_BEHIND',(208,509),(232,556)),
    ('TREE_FRONT',(208,549),(232,596)),
    ('BRIDGE_BEHIND',(711,574),(735,621)),
    ('BRIDGE_FRONT',(711,623),(735,670)),
]

def digest(data): return hashlib.sha256(data).hexdigest()
def decode(data): return np.asarray(Image.open(io.BytesIO(data)).convert('RGBA')).copy()
def rgba_png(arr):
    buf=io.BytesIO(); Image.fromarray(arr,'RGBA').save(buf,'PNG'); return buf.getvalue()


def execute(a27_zip:Path,out:Path):
    raw=a27_zip.read_bytes()
    if digest(raw)!=A27_ZIP_SHA: raise ValueError('A27 ZIP SHA verification failed')
    out.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(io.BytesIO(raw)) as z:
        if z.testzip() is not None: raise ValueError('A27 ZIP CRC failed')
        mb=z.read('Runtime_FullGround_UNCHANGED.png')
        actor_png=z.read('APPROVED_F0_EXACT_48_PRIVATE.png')
        if digest(mb)!=MASTER_SHA or digest(actor_png)!=ACTOR_SHA:
            raise ValueError('Source Master/F0 SHA mismatch')
        m=decode(mb); actor=decode(actor_png)
        if m.shape!=(928,1280,4) or actor.shape!=(48,48,4):
            raise ValueError('Wrong source image sizes')
        result={'schema':'FS_A28_SOURCE_LOCKED_CROPS','source_master_sha256':MASTER_SHA,
                'actor_sha256':ACTOR_SHA,'source_archive_sha256':A27_ZIP_SHA,'sources':[],
                'semantic_art':'HOLD','rgss2_game_exe':'NOT_RUN','formal_seal':'NO'}
        cropped={}
        combined=np.zeros((928,1280),bool)
        for name,maskname,(x0,y0,x1,y1),far,near in SOURCES:
            mask=np.asarray(Image.open(io.BytesIO(z.read(maskname))).convert('L'))==255
            if np.any(combined & mask):raise ValueError('Cross-owner mask overlap')
            combined |= mask
            ys,xs=np.where(mask)
            if (int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1))!=(x0,y0,x1,y1):
                raise ValueError(f'{name}: mask bounding box drift')
            cut=m[y0:y1,x0:x1].copy()
            cut[~mask[y0:y1,x0:x1]]=(0,0,0,0)
            # Match A27 mask source bytes at each original world coordinate.
            if not np.array_equal(cut[mask[y0:y1,x0:x1]],m[y0:y1,x0:x1][mask[y0:y1,x0:x1]]):
                raise ValueError('Source drift')
            cropped[name]=(cut,(x0,y0,x1,y1),far,near)
            path=out/(name+'.png')
            path.write_bytes(rgba_png(cut))
            result['sources'].append({'name':name,'source_mask':maskname,
                'world_rect_xyxy':[x0,y0,x1,y1], 'far_foot_y':far,'near_foot_y':near,
                'width':x1-x0,'height':y1-y0,'opaque_pixels':int(mask.sum()),
                'png_sha256':digest(path.read_bytes())})
        fixture={'schema':'FS_A28_PRIVATE_PIXEL_PARITY','cases':[]}
        measurements=[]
        for cname,(ax,ay),(fx,fy) in CASES:
            patches={}
            got=np.zeros((48,48,4),np.uint8)
            a_valid=actor[:,:,3]>0
            for name,(crop,(x0,y0,x1,y1),far,near) in cropped.items():
                patches[name]=[]
                for ly in range(48):
                    wy=ay+ly
                    if not y0<=wy<y1: continue
                    for lx in range(48):
                        wx=ax+lx
                        if not x0<=wx<x1:continue
                        rgba=crop[wy-y0,wx-x0]
                        if rgba[3]:
                            patches[name].append([wx-x0,wy-y0,*[int(t) for t in rgba]])
                        if not a_valid[ly,lx] or not rgba[3]:continue
                        den=max(1,y1-y0-1)
                        if fy*den < far*den + (near-far)*(wy-y0):
                            got[ly,lx]=rgba
            existing=decode(z.read(cname+'_A27_PAR.png'))[ay:ay+48,ax:ax+48]
            if not np.array_equal(got,existing):
                diff=np.any(got!=existing,axis=2).sum()
                raise ValueError(f'{cname}: {diff} pixels mismatch A27 source renderer')
            fixture['cases'].append({'case':cname,'top':[ax,ay],'foot':[fx,fy],
                                    'actor_alpha':[''.join('1' if a else '0' for a in row) for row in a_valid],
                                    'object_patches':patches,
                                    'expected_raw_sha256':digest(got.tobytes()),
                                    'expected_alpha_pixels':int((got[:,:,3]>0).sum())})
            measurements.append({'case':cname,'par_overlay_alpha':int((got[:,:,3]>0).sum()),'ruby_expected_sha256':digest(got.tobytes())})
        result['four_case_replay']=measurements
        result['source_same_xy_rgba_mismatch_pixels']=0
        (out/'A28_PRIVATE_PIXEL_PARITY_FIXTURE.json').write_text(json.dumps(fixture,ensure_ascii=False),encoding='utf-8')
        (out/'A28_MAP_EXPORT_QA.json').write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding='utf-8')
        (out/'A28_INSTALL_NOT_APPROVED.txt').write_text(
            'FS A28 RGSS2 source mask candidates for isolated VX testing only.\n'
            'Copy cropped PNG names into Graphics/Parallaxes ONLY AFTER obtaining authorization for isolated Game.exe test.\n'
            'Do not modify the sealed production game. The RGSS2 adapter is OFF by default and actual map ID is unknown.\n'
            'Avoid duplicate all-on global PAR for these objects. These masks inherit A27 ART HOLD.\n',encoding='utf-8')
    return result

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--a27',type=Path,required=True)
    parser.add_argument('--out',type=Path,required=True)
    a=parser.parse_args()
    print(json.dumps(execute(a.a27,a.out),ensure_ascii=False,indent=2))
