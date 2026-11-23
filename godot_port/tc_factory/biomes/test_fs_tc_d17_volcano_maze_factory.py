"""Synthetic contract only; the real private D17 image requires separate QA."""
import tempfile
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops
from fs_tc_d17_volcano_maze_factory import generate, digest, POSITIONS
import fs_tc_d16_volcano_maze_factory as old

def expect_fail(f,msg):
    try:f()
    except (ValueError,FileNotFoundError) as exc:
        assert msg in str(exc),str(exc)
    else:raise AssertionError('Invalid case accepted '+msg)

def main():
    with tempfile.TemporaryDirectory(prefix='D17_synthetic_') as temp:
        root=Path(temp);g=root/'source_ground.png';p=root/'source_par.png'
        a=Image.new('RGB',(1474,1067),(68,49,62));draw=ImageDraw.Draw(a)
        draw.rectangle((500,500,880,830),fill=(200,78,33));a.save(g)
        b=Image.new('RGBA',(1474,1067),(0,0,0,0));draw=ImageDraw.Draw(b)
        for name,(x0,y0,x1,y1),_,_ in old.PROP_PLACEMENTS:
            draw.rectangle((x0+18,y0+16,min(x0+55,x1-1),min(y0+64,y1-1)),fill=(95,79,78,255))
        b.save(p)
        gh,ph=digest(g),digest(p)
        t=root/'output';qa=generate(g,p,t,gh,ph)
        with Image.open(g) as src, Image.open(t/'GROUND.png') as ground, Image.open(t/'PAR.png') as par, Image.open(t/'COMPOSITE_QA.png') as merged:
            assert ground.tobytes()==src.crop((90,70,1370,998)).tobytes()
            assert ImageChops.difference(Image.alpha_composite(ground.convert('RGBA'),par),merged).getbbox() is None
            assert par.getchannel('A').getextrema()==(0,255)
        assert qa['source_ground_cropped_without_scaling']
        assert qa['PAR_staged_1x_without_scaling']
        assert qa['ground_locked_before_par']
        assert not qa['mixed_master_reverse_extraction']
        assert qa['ground_mode']=='RGB' and qa['par_mode']=='RGBA'
        assert qa['native_world']==[1280,928]
        assert len(qa['par_object_groups'])==len(POSITIONS)==6
        assert qa['godot_4_7_2_private_native']=='NOT_RUN'
        assert qa['formal_art_pass']=='0_OF_12_HOLD'
        assert digest(g)==gh and digest(p)==ph
        expect_fail(lambda:generate(g,p,root/'bad','0'*64,ph),'SOURCE_SHA_LOCK_FAILURE')
        expect_fail(lambda:generate(g,p,root/'bad_par',gh,'0'*64),'SOURCE_SHA_LOCK_FAILURE')
        expect_fail(lambda:generate(g,p,t,gh,ph),'Output must be a NEW empty directory')
        expect_fail(lambda:generate(g,g,root/'same',gh,ph),'independent Ground-only')
        small=root/'wrong.png';Image.new('RGB',(1280,928),(1,2,3)).save(small)
        expect_fail(lambda:generate(small,p,root/'badsize',digest(small),ph),'opaque RGB 1474x1067')
    print('D17 PASS SYNTHETIC: independent Ground-first, source lock, native crop identity, 1x PAR, alpha, fail-closed, ART HOLD')
if __name__=='__main__':main()
