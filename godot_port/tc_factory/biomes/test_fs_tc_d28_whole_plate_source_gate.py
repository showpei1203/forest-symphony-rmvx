#!/usr/bin/env python3
import sys
import tempfile
import unittest
from pathlib import Path
from PIL import Image

sys.path.insert(0,str(Path(__file__).parent))
from fs_tc_d28_whole_plate_source_gate import inspect_par, CANVAS, qa_only_whole_canvas_preview, sha256

class OnePassWholePlateGateTests(unittest.TestCase):
    def test_exact_canvas_rgba_shape_is_technically_eligible_but_not_art_pass(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t)/'single.png';im=Image.new('RGBA',CANVAS,(0,0,0,0));
            for x in range(900,920):
                for y in range(500,520):im.putpixel((x,y),(110,65,45,255))
            im.save(p);r=inspect_par(p)
            self.assertEqual(r['exact_native_canvas_gate'],'PASS')
            self.assertFalse(r['approved_production_par'])
            self.assertEqual(r['human_visual_art_gate'],'HOLD')
    def test_large_source_fails_even_if_entire_image_is_transparent_at_edges(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t)/'large.png';im=Image.new('RGBA',(1474,1067),(0,0,0,0));im.putpixel((400,400),(255,100,1,255));im.save(p)
            r=inspect_par(p)
            self.assertIn('SOURCE_NOT_EXACT_NATIVE_CANVAS',r['errors'])
            self.assertEqual(r['visible_outside_native_canvas'],0)
    def test_source_with_actual_pixels_outside_frame_fails_without_cropping(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t)/'over.png';im=Image.new('RGBA',(1474,1067),(0,0,0,0));im.putpixel((1421,300),(255,100,1,255));im.save(p)
            r=inspect_par(p)
            self.assertIn('VISIBLE_PIXELS_OUTSIDE_NATIVE_CANVAS',r['errors'])
            self.assertEqual(r['visible_outside_native_canvas'],1)
    def test_rgb_fake_alpha_fails(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t)/'rgb.png';Image.new('RGB',CANVAS,'white').save(p)
            r=inspect_par(p)
            self.assertIn('SOURCE_NOT_TRUE_RGBA_MODE',r['errors'])
            self.assertIn('SOURCE_NO_TRUE_TRANSPARENT_PIXELS',r['errors'])
    def test_whole_canvas_preview_cannot_modify_original_source(self):
        with tempfile.TemporaryDirectory() as t:
            d=Path(t);g=d/'ground.png';s=d/'source.png';o=d/'QA_ONLY.png'
            Image.new('RGB',CANVAS,'brown').save(g)
            im=Image.new('RGBA',(1474,1067),(0,0,0,0));im.putpixel((1300,100),(255,200,0,255));im.save(s)
            before=sha256(s)
            qa_only_whole_canvas_preview(g,s,o)
            self.assertEqual(sha256(s),before)
            with Image.open(o) as qa_image:
                self.assertEqual(qa_image.size,CANVAS)
            self.assertTrue(o.exists())

if __name__=='__main__':unittest.main(verbosity=2)
