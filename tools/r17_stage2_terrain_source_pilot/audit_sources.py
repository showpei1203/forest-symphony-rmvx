"""Offline R17 Stage2 source audit. Does not generate art or edit source PNGs.
Run: python audit_sources.py
Requires Pillow + numpy. All crop/zoom outputs are diagnostic evidence only.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import hashlib, json, numpy as np

ROOT = Path(__file__).resolve().parent
CASES = [
    ('P01', 'TERRAIN_SOURCE_RAW.png', [400,210,944,626],
     'fbe099596a9648bc13e2560190a5fff2aaefc333d7a0ed4ad81d35148edff3e4',
     '1VoRGhwvqwnNjEwyCGYyEC3oCzblnUprN'),
    ('P02', 'TERRAIN_SOURCE_P02_RAW.png', [496,290,1040,706],
     '13e040f293e6e132fd4e79c38cf763a661155be305efcbf2af2a5689af4625a6',
     '12ykf-WzFp56x1IZj_JPg05yshY_V6Ybs'),
]

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    (ROOT/'qa').mkdir(exist_ok=True)
    (ROOT/'reports').mkdir(exist_ok=True)
    records=[]
    board=Image.new('RGB',(1136,704),'#17201b')
    d=ImageDraw.Draw(board)
    font=ImageFont.load_default(size=18)
    small=ImageFont.load_default(size=15)
    d.text((16,12),'R17 STAGE 2 | TERRAIN SOURCE PILOT | REJECTED FOR PROMOTION',font=font,fill='white')
    d.text((16,38),'Actual source pixels; crops at 1:1. No art approval. No new engine render.',font=small,fill='#cbd4cd')
    for index,(pid,name,box,expected,fid) in enumerate(CASES):
        path=ROOT/'sources'/name
        actual=sha(path)
        assert actual==expected, f'SOURCE HASH CHANGED: {name}'
        im=Image.open(path); im.load()
        rgb=np.asarray(im.convert('RGB'))
        crop=im.crop(box).convert('RGB')
        assert crop.size==(544,416)
        assert crop.tobytes()==rgb[box[1]:box[3],box[0]:box[2]].tobytes()
        crop.save(ROOT/'qa'/f'{pid}_NATIVE_1X.png')
        x=16+index*560
        d.text((x,73),f'{pid}  {im.width}x{im.height} source',font=font,fill='white')
        board.paste(crop,(x,104))
        detail=crop.crop((256,192,304,240)).resize((144,144),Image.Resampling.NEAREST)
        board.paste(detail,(x,544))
        colors=int(len(np.unique(rgb.reshape(-1,3),axis=0)))
        d.text((x+160,552),'3x nearest detail (QA only)',font=small,fill='white')
        d.text((x+160,578),f'RGB colors: {colors:,}',font=small,fill='white')
        d.text((x+160,604),'Crop pixel equality: exact',font=small,fill='white')
        d.text((x+160,630),'ART: REJECTED / NOT RUNTIME',font=small,fill='#f3be9d')
        records.append({
            'id':pid,'path':str(path.relative_to(ROOT)),'sha256':actual,
            'size':list(im.size),'mode':im.mode,'unique_rgb':colors,
            'alpha_min_max':list(im.convert('RGBA').getchannel('A').getextrema()),
            'diagnostic_crop_xywh':[box[0],box[1],544,416],
            'crop_rgb_equal_source':True,'source_modified':False,
            'hypothetical_whole_source_fit':min(544/im.width,416/im.height),
            'whole_source_resize_applied':False,
            'drive_file_id':fid,'drive_parent_id':'1TUYoNuuEUiqqZ4vR0KPdu7RaGFt3Q1bH',
            'generation':'OpenAI built-in imagegen; fresh generation; prompt saved',
            'rights':'New AI-generated research source; no legacy image attached; not a legal license determination',
            'status':'SOURCE_ASSET_REJECTED_FOR_PROMOTION'
        })
    board.save(ROOT/'qa'/'R17_STAGE2_NATIVE_QA.png')
    report={
        'date_taipei':'2026-10-29','stage':'R17_STAGE2_TERRAIN_SOURCE_PILOT',
        'generation_calls_executed':2,'sources':records,
        'art':'FAIL_AGENT_PRECHECK','user_art':'HOLD_NOT_REVIEWED',
        'ground_geometry':'NOT_LOCKED','transparent_object_generation':'NOT_RUN',
        'B_C_new_scene_comparison':'NOT_RUN','A_pair_generation':'NOT_RUN',
        'mask':'HOLD_NO_NEW_OBJECTS','Godot_stage2':'NOT_RUN','VX_stage2':'NOT_RUN',
        'final_seal':False,
        'scope':'Native crops are QA examples, not final Ground or a compiled scene.',
        'background_execution':'Offline process completes without focus, mouse or keyboard events.',
        'measurement_limit':'Color count measures prompt adherence only, not universal art quality. Source dimensions alone do not invalidate a source asset. No conclusion about all image models or all source-first methods.'
    }
    (ROOT/'reports'/'SOURCE_AUDIT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (ROOT/'SOURCE_REGISTER.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'audit_completed':True,'source_hashes_match':True,'crop_rgb_equality':True,'art_pass':False,'final_seal':False}))

if __name__=='__main__': main()
