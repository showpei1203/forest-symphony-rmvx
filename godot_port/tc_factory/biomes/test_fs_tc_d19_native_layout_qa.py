"""D19 synthetic QA; NEVER substitutes for private D18 art or Godot 4.7.2."""
import tempfile
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
import fs_tc_d19_native_layout_qa as mod
from fs_tc_d18_complete_par_components import sha256


def must_reject(callback, phrase):
    try:
        callback()
    except (ValueError, AssertionError) as error:
        assert phrase in str(error), str(error)
    else:
        raise AssertionError(f"Invalid D19 input wrongly passed {phrase}")


def main():
    original_ground_sha=mod.GROUND_LOCK
    original_source_sha=mod.PAR_SOURCE_LOCK
    original_pixel_count=mod.EXPECTED_VISIBLE_SOURCE_PIXELS
    original_pos=mod.D19_POSITIONS.copy()
    with tempfile.TemporaryDirectory(prefix='tc_d19_test_') as temp:
        path=Path(temp)
        g=path/'GROUND_SYNTH_RGB.png'
        s=path/'PAR_SYNTH_RGBA.png'
        Image.new('RGB',(1280,928),(68,57,67)).save(g)
        par=Image.new('RGBA',(1474,1067),(0,0,0,0))
        draw=ImageDraw.Draw(par)
        # Rectangles are intentionally separate alpha islands with >3k pixels.
        regions=[(20,20,319,269),(750,250,999,419),(20,580,219,729),
                 (850,680,1049,829),(350,840,489,949),(450,500,589,589)]
        for i,rect in enumerate(regions):
            draw.rectangle(rect,fill=(40+25*i,56+20*i,72+10*i,255))
        par.save(s)
        mod.GROUND_LOCK=sha256(g)
        mod.PAR_SOURCE_LOCK=sha256(s)
        mod.EXPECTED_VISIBLE_SOURCE_PIXELS=sum(
            (x1-x0+1)*(y1-y0+1) for x0,y0,x1,y1 in regions)
        # Positions for synthetic shapes are safe and disjoint; retain bridge anchor.
        mod.D19_POSITIONS={
           'A_FORGE_MARKET':(4,4),'B_WHOLE_BRIDGE':(554,334),
           'C_SOUTH_WORKSHOP':(4,566),'D_SOUTH_FOUNDRY':(644,570),
           'E_FULL_LAMP':(400,760),'F_FULL_BANNER':(300,500)
        }
        out=path/'good'
        q=mod.build(g,s,out)
        assert q['static_qa']=='PASS' and q['human_ART_gate']=='HOLD'
        assert q['polygon_trim_pixels']==0
        assert q['source_all_six_significant_alpha_pixels_preserved']==mod.EXPECTED_VISIBLE_SOURCE_PIXELS
        assert q['new_D19_overlap_pixels']==0
        assert not any(q['new_D19_4px_highalpha_border'].values())
        assert q['world_coordinate_lock_bridge']==(554,334)
        assert q['Godot_4_7_2_actual_private_art_native']=='NOT_RUN'
        assert q['formal_ART_PASS']=='0/12'
        assert Image.open(out/'PAR_ALL_NON_GROUND_1280x928.png').size==(1280,928)
        assert Image.open(out/'D19_GRID_FAMILY_QA_ONLY.png').size==(1280,928)
        assert sha256(g)==mod.GROUND_LOCK and sha256(s)==mod.PAR_SOURCE_LOCK
        # Fail-closed source provenance.
        mod.GROUND_LOCK='f'*64
        must_reject(lambda:mod.build(g,s,path/'bad_sha'), 'SHA mismatch')
        mod.GROUND_LOCK=sha256(g)
        # Bridge cannot be moved by this D19 safe-edge-only patch.
        mod.D19_POSITIONS['B_WHOLE_BRIDGE']=(556,334)
        must_reject(lambda:mod.build(g,s,path/'bridge_moved'), 'Bridge world anchor')
        mod.D19_POSITIONS['B_WHOLE_BRIDGE']=(554,334)
        # A missing family should be rejected.
        mod.D19_POSITIONS.pop('F_FULL_BANNER')
        must_reject(lambda:mod.build(g,s,path/'missing_family'), 'Six complete source families')
        # No source images were replaced or scaled.
        assert Image.open(g).mode=='RGB' and Image.open(s).mode=='RGBA'
    mod.GROUND_LOCK=original_ground_sha
    mod.PAR_SOURCE_LOCK=original_source_sha
    mod.EXPECTED_VISIBLE_SOURCE_PIXELS=original_pixel_count
    mod.D19_POSITIONS=original_pos
    print('D19 PASS: Ground/PAR SHA, six 1x whole islands, bridge locked, border clean, source unchanged, native/ART HOLD')

if __name__=='__main__':main()
