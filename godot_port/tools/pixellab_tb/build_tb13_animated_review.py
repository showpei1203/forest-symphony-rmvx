#!/usr/bin/env python3
"""R13 two original-pixel animated visual review grids; no resampling of source atlas files."""
import hashlib,os,shutil,json
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
root=Path(os.environ['TEMP'])/'fs_tb13_staging'
g=root/'godot'
manifest=json.loads((g/'TB13_MONSTER_FAMILY_MANIFEST.json').read_text(encoding='utf-8'))
private=Path('G:/')/'.shortcut-targets-by-id'/'10qOSm1id3o5oisfVQxhlC_4ncJaF0Yd3'/'FS_PIXELLAB_TB_MONSTER_20261121_PRIVATE'
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',22)
for fam in manifest['families']:
    frames=[]
    for k in range(8):
        panel=Image.new('RGB',(1320,760),(19,32,44)); draw=ImageDraw.Draw(panel)
        draw.text((22,14),f"FOREST SYMPHONY | R13 {fam['family_id']} | 3 STAGES x 2 ACTIONS",font=font,fill=(240,232,206))
        draw.text((22,46),"TRUE PIXELLAB FRAMES - STUN/T AUNT - SOURCE LOCKED - HUMAN ART REVIEW PENDING".replace("T AUNT","TAUNT"),font=font,fill=(172,201,190))
        for stagei,stage in enumerate(fam['stages']):
            x=80+stagei*423
            draw.text((x,90),f"STAGE {stagei+1} - {stage['name']}",font=font,fill=(245,212,153))
            for j,action in enumerate(('stun','taunt')):
                m=stage['motions'][action];c=m['cell'][0];cols=m['columns']
                sheet=Image.open(g/m['path']).convert('RGBA')
                tile=sheet.crop(((k%cols)*c,(k//cols)*c,(k%cols+1)*c,(k//cols+1)*c))
                sz=(min(270,c*2),)*2
                tile=tile.resize(sz,Image.Resampling.NEAREST)
                bg=Image.new('RGBA',sz,(32,56,68,255));bg.alpha_composite(tile)
                y=135+j*315
                panel.paste(bg.convert('RGB'),(x+42,y))
                draw.text((x,y+272),f"{action.upper()}  frame {k+1}/8",font=font,fill=(180,229,197))
        frames.append(panel)
    target=private/f"R13_{fam['kind'].upper()}_3STAGE_STUN_TAUNT_ANIMATED_REVIEW.gif"
    tmp=root/'reports'/target.name
    frames[0].save(tmp,save_all=True,append_images=frames[1:],duration=170,loop=0,disposal=2,optimize=False)
    assert tmp.is_file()
    shutil.copyfile(tmp,target)
    assert hashlib.sha256(tmp.read_bytes()).digest()==hashlib.sha256(target.read_bytes()).digest()
    print('R13_ANIMATED_REVIEW_SYNCED',target.name,target.stat().st_size,flush=True)
