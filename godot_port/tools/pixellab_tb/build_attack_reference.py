#!/usr/bin/env python3
"""Read approved private PMD G9 original attacks, create Godot-friendly motion references.
This *does not* claim visual matching with the high-resolution PMD0001 concept.
No PixelLab API, no AI animation, no recoloring, no modifications to native assets.
All original licensed images stay on private Drive; ONLY CODE can be in public GitHub.
"""
from __future__ import annotations
import argparse, hashlib, io, json, math, zipfile, xml.etree.ElementTree as ET
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops

FRAME_W, FRAME_H = 64, 96  # native PNG tiles 64x72, padded in 64x96; NO resampling
COLS = 4
APPROVED_NATIVE = 'GODOT_0001/rock_0001/'
ORIGINAL_NATIVE = 'GODOT_0001/original_0001/'

def sha_bytes(b: bytes)->str: return hashlib.sha256(b).hexdigest()
def sha_file(p)->str: return sha_bytes(Path(p).read_bytes())

def native_source(z:zipfile.ZipFile, relpath: str):
    return z.read(APPROVED_NATIVE+relpath)

def write_gif(frames: list[Image.Image], durations: list[int], output: Path, *, scale: int=5, fps: float=30):
    ims=[]
    for f in frames:
        canvas=Image.new('RGBA',(FRAME_W*scale,FRAME_H*scale),(26,30,38,255))
        canvas.alpha_composite(f.resize((FRAME_W*scale,FRAME_H*scale),Image.Resampling.NEAREST))
        ims.append(canvas.convert('RGB'))
    ims[0].save(output,save_all=True,append_images=ims[1:],duration=[int(round(d*1000/fps)) for d in durations],loop=0,optimize=False)

def make_atlas(frames: list[Image.Image]):
    img=Image.new('RGBA',(COLS*FRAME_W,math.ceil(len(frames)/COLS)*FRAME_H))
    for i,f in enumerate(frames):
        img.alpha_composite(f,((i%COLS)*FRAME_W,(i//COLS)*FRAME_H))
    return img

def split_row(img:Image.Image,row:int,count:int,raw_height:int):
    out=[]
    for i in range(count):
        tile=img.crop((i*64,row*raw_height,(i+1)*64,(row+1)*raw_height))
        frame=Image.new('RGBA',(FRAME_W,FRAME_H))
        frame.alpha_composite(tile,(0,7))  # preserve original 1px resolution
        out.append(frame)
    return out

def failed_reconstruction_check(master:Image.Image, failed_sheet:Image.Image):
    # Reference implementation copied from historical failed deterministic algorithm:
    # this checks direct equivalence, not computer-vision similarity or artistic quality.
    from PIL import ImageDraw
    FOOT=59
    def rigid_pose(src,compress=1.,dy=0,dx=0,lean=0):
        b=src.getbbox();crop=src.crop(b)
        crop=crop.resize((crop.width,max(1,round(crop.height*compress))),Image.Resampling.NEAREST)
        x=b[0]+dx; y=FOOT-crop.height+dy
        if lean:
            warp=Image.new('RGBA',(crop.width+abs(lean),crop.height))
            for j in range(crop.height):
                row=crop.crop((0,j,crop.width,j+1))
                w=round(lean*(1-j/max(1,crop.height)))
                warp.alpha_composite(row,(max(0,w),j))
            crop=warp
        f=Image.new('RGBA',(64,64));f.alpha_composite(crop,(x,y));return f
    params=[(.94,0,0,0),(.86,0,0,0),(.98,-3,1,0),(1.0,-5,2,2),(.95,-3,1,3),(.92,-1,0,0),(.97,0,0,0),(1.,0,0,0)]
    results=[]
    for i,pr in enumerate(params):
        actual=failed_sheet.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64))
        estimated=rigid_pose(master,*pr)
        differ=ImageChops.difference(actual,estimated)
        mismatched=sum(1 for a in differ.getdata() if any(a))
        results.append({'frame':i,'pixels_not_explained_by_whole_body_transform':mismatched,
            'exact_whole_body_match':mismatched==0})
    return results

def contact(native:dict,failed:Image.Image, static:Image.Image,xml_metadata:dict):
    sx=3
    out=Image.new('RGB',(1068,780),(26,30,38));d=ImageDraw.Draw(out)
    d.text((15,8),'REJECTED OLD ATTACK: whole-body warp + disconnected fireball, 8 frames',fill=(255,180,156))
    for i in range(8):
        a=failed.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64))
        img=a.resize((64*sx,64*sx),Image.Resampling.NEAREST)
        x=15+i*128;y=32;img=img.resize((124,124),Image.Resampling.NEAREST)
        out.paste(img,(x,y),img)
        d.text((x+3,y+129),f'F{i}',fill=(255,190,168))
    for j,row in enumerate([1,2]):
        y=238+j*205
        d.text((15,y-17),f'GENUINE HISTORICAL G9 PMD0001 ATTACK, ROW={row}, 11 frames | Rush 2 / Hit 5 / Return 7',fill=(187,228,253))
        for i,f in enumerate(native[row]):
            im=f.resize((84,126),Image.Resampling.NEAREST)
            x=12+i*95
            out.paste(im,(x,y),im)
            mark='HIT' if i==5 else 'RUSH' if i==2 else 'RET' if i==7 else ''
            d.text((x+4,y+133),f'F{i:02d} {mark}',fill=(255,234,140) if mark else (210,217,229))
    d.text((15,676),'SOURCE-LOCKED ORIGINAL G9 ACTION IS A POSE/ANIMATION REFERENCE, NOT HIGH-RES CONCEPT ART PASS',fill=(242,197,145))
    im=static.resize((64,64),Image.Resampling.NEAREST)
    out.paste(im,(24,698),im)
    d.text((105,713),'Concept look and native pose art differ: must be retargeted without losing identity.',fill=(228,224,218))
    return out

def build(zip_path:Path,failed_sheet_path:Path,master_path:Path,out_dir:Path):
    out_dir.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(zip_path) as z:
        assert z.testzip() is None,'input zip CRC fail'
        native_png=native_source(z,'Attack-Anim.png')
        original_png=z.read(ORIGINAL_NATIVE+'Attack-Anim.png')
        native_xml=native_source(z,'AnimData.xml')
        offsets=native_source(z,'Attack-Offsets.png')
        shadow=native_source(z,'Attack-Shadow.png')
        tree=ET.fromstring(native_xml)
        elem=next(a for a in tree.findall('.//Anim') if a.findtext('Name')=='Attack')
        w=int(elem.findtext('FrameWidth'));h=int(elem.findtext('FrameHeight'))
        durations=[int(x.text) for x in elem.findall('./Durations/Duration')]
        events={name:int(elem.findtext(name)) for name in ('RushFrame','HitFrame','ReturnFrame')}
        src=Image.open(io.BytesIO(native_png)).convert('RGBA')
        assert (w,h)==(64,72),'unexpected native frame geometry'
        assert src.size==(w*len(durations),8*h),'native image atlas mismatch'
        native={}
        native_analysis={}
        for row in [1,2]:
            frames=split_row(src,row,len(durations),h)
            native[row]=frames
            fpath=out_dir/f'PMD0001_G9_NATIVE_ATTACK_ROW{row}_11F_256x288.png'
            make_atlas(frames).save(fpath)
            write_gif(frames,durations,out_dir/f'PMD0001_G9_NATIVE_ATTACK_ROW{row}_11F.gif')
            bboxes=[f.getbbox() for f in frames]
            frame_diffs=[sum(1 for x in ImageChops.difference(frames[i],frames[i-1]).getdata() if any(x)) for i in range(1,len(frames))]
            native_analysis[str(row)]={'bboxes':bboxes,'changed_pixel_count_consecutive':frame_diffs,
              'unique_frames':len({f.tobytes() for f in frames}),
              'all_uncropped':all(b and b[0]>0 and b[1]>0 and b[2]<64 and b[3]<96 for b in bboxes),
              'atlas_sha256':sha_file(fpath)}
    failed_sheet=Image.open(failed_sheet_path).convert('RGBA')
    master=Image.open(master_path).convert('RGBA')
    assert failed_sheet.size==(256,128) and master.size==(64,64)
    old=failed_reconstruction_check(master,failed_sheet)
    # Formal rejection is caused by origin route, independent of any technical geometry pass.
    assert all(x['exact_whole_body_match'] for x in old[:4]+old[6:]),'old failed source no longer matches stored production algorithm'
    contact(native,failed_sheet,master,events).save(out_dir/'PMD0001_ATTACK_FAILURE_ANALYSIS_CONTACT.png')
    metadata={'schema':'fs-tb-attack-rework-v2','status':'ORIGINAL_ATTACK_REJECTED__NATIVE_REFERENCE_AVAILABLE',
       'user_gate':'Attack ART FAIL','source':{'drive_id':'1QWdMHbu1VTQ85kaOEXSankeSsIY6FvOS',
       'zip_sha256':sha_file(zip_path),'archive_native_attack_sha256':sha_bytes(native_png),
       'native_xml_sha256':sha_bytes(native_xml),'offsets_sha256':sha_bytes(offsets),'shadow_sha256':sha_bytes(shadow),
       'original_green_attack_sha256':sha_bytes(original_png)},
       'xml_attack':{'native_frame_size':[w,h],'native_atlas_size':list(src.size),'frames':len(durations),
           'direction_rows':8,'durations_ticks':durations,'events':events},
       'old_attack':{'file':failed_sheet_path.name,'qa_status':'ART_FAIL',
           'reconstructed_from_whole_body_warp':old,
           'blockers':['NO_INDEPENDENT_LIMB_JOINTS','NO_CLEAR_PREP/IMPACT/RECOVERY_BODY_POSE','PROJECTILE_DISCONNECTED_FROM_MOUTH','RIGID_BODY_WARP_ROUTE_REJECTED']},
       'new_reference':{'reference_only':True,'not_concept_identity_approved':True,'not_PixelLab_new_generation':True,
           'native_rows':native_analysis,'fps_illustration':30,'note':'Native XML timings preserved as ticks; GIF fps is review convenience, not verified original gameplay timing'},
       'gates':{'native_source':'PASS','legacy_attack_motion_reference':'AVAILABLE','native_character_identity':'HOLD',
          'concept_look_mismatch':'BLOCKER','native_godot_4_7_2':'NOT_RUN','pixel_lab_this_turn':'NOT_RUN','final_attack_art':'FAIL'},
       'next_method':'Apply legacy 11 pose semantics as reference to approved concept using PixelLab estimate-skeleton + skeleton-v3 or text-v3 with deliberate pose checkpoints; do not re-use whole-body warp.'}
    (out_dir/'ATTACK_REWORK_MANIFEST.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'native_frame_count':len(durations),'old_rigid_exact':sum(x['exact_whole_body_match'] for x in old),
         'old_exact_frames':[x['frame'] for x in old if x['exact_whole_body_match']],
         'source_zip_sha256':metadata['source']['zip_sha256'],
         'native_pose_refs':native_analysis},ensure_ascii=False,indent=2))
    return metadata

if __name__=='__main__':
    ap=argparse.ArgumentParser()
    ap.add_argument('--source-zip',type=Path,required=True)
    ap.add_argument('--old-atlas',type=Path,required=True)
    ap.add_argument('--master',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    a=ap.parse_args()
    build(a.source_zip,a.old_atlas,a.master,a.out)
