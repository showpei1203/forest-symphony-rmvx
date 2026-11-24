"""Synthetic contract test only. It never certifies private artwork or Godot runtime."""
import tempfile
from pathlib import Path
import numpy as np
from PIL import Image, ImageChops, ImageDraw
from fs_tc_d16_volcano_maze_factory import generate,sha,PROP_PLACEMENTS

def reject(fn, phrase):
    try:fn()
    except (ValueError,FileNotFoundError) as exc:
        assert phrase in str(exc),repr(exc)
    else:raise AssertionError('Expected fail closed: '+phrase)

def run():
    with tempfile.TemporaryDirectory(prefix='fs_tc_d16_synthetic_') as t:
        root=Path(t);gp=root/'ground.png';pp=root/'par.png'
        Image.new('RGB',(1280,928),(56,50,62)).save(gp)
        sample=Image.new('RGBA',(1474,1067),(0,0,0,0))
        d=ImageDraw.Draw(sample)
        for _,(x0,y0,x1,y1),_,_ in PROP_PLACEMENTS:
            # Synthetic filled shape in every authorized non-ground ROI.
            d.ellipse((x0+15,y0+10,min(x0+68,x1-1),min(y0+68,y1-1)),fill=(240,120,50,255))
        sample.save(pp)
        pre_g,pre_p=sha(gp),sha(pp)
        out=root/'fresh';qa=generate(gp,pp,out,pre_g,pre_p)
        assert Image.open(out/'GROUND.png').size==(1280,928)
        assert Image.open(out/'GROUND.png').mode=='RGB'
        assert Image.open(out/'PAR.png').size==(1280,928)
        assert Image.open(out/'PAR.png').mode=='RGBA'
        assert 0 < qa['alpha']['zero'] < 1280*928
        assert qa['no_mixed_master_reverse_extraction']
        assert qa['formal_ART_PASS']=='HOLD_0_OF_12'
        assert qa['private_art_Godot_4_7_2_native']=='NOT_RUN'
        assert len(qa['objects'])==6
        assert qa['source_D11_SHA256']==pre_g and qa['source_D15_independent_PAR_SHA256']==pre_p
        assert sha(gp)==pre_g and sha(pp)==pre_p,'Original inputs modified'
        with Image.open(out/'GROUND.png') as g, Image.open(out/'PAR.png') as p, Image.open(out/'COMPOSITE_QA.png') as c:
            assert ImageChops.difference(Image.alpha_composite(g.convert('RGBA'),p),c).getbbox() is None
        reject(lambda:generate(gp,pp,root/'bad_sha','0'*64,pre_p),'SHA mismatch')
        reject(lambda:generate(gp,pp,root/'bad_sha_par',pre_g,'0'*64),'SHA mismatch')
        reject(lambda:generate(gp,pp,root/'fresh',pre_g,pre_p),'Output folder must be empty')
        Image.new('RGB',(100,100),(0,0,0)).save(root/'wrong.png')
        reject(lambda:generate(root/'wrong.png',pp,root/'wrong_shape',sha(root/'wrong.png'),pre_p),'1280x928')
    print('D16 PASS: SYNTHETIC ground-before-PAR + 40x29 two layers + alpha + exact composite + source SHA + failure cases + ART HOLD')

if __name__=='__main__':run()
