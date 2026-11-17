#!/usr/bin/env python3
"""A56: regression checks for source-preserving occlusion compiler."""
import json
import tempfile
import unittest
from pathlib import Path
from PIL import Image, ImageDraw
from a56_real_body_occlusion import (
    rgba_atlas_frames, anchor_points, mask_region, leakage, mask_count,
    shield_geometry, visible_tip, alpha_edges, verify_registration,
    selftest as occlusion_selftest,
)

class A56ReadOnlyGeometryContract(unittest.TestCase):
    def test_positive_and_negative_wrist_visibility(self):
        occlusion_selftest()

    def test_empty_wrist_mask_rejected(self):
        blank=Image.new('RGBA',(64,64))
        shield, sm=shield_geometry((42,35))
        tip=visible_tip((42,35))
        out=Image.alpha_composite(Image.alpha_composite(blank,shield),tip)
        with self.assertRaisesRegex(AssertionError, 'Uncovered/empty'):
            verify_registration(blank,shield,tip,out,Image.new('L',(64,64)),sm,check_hidden=True)

    def test_unoccluded_hand_rejected(self):
        body=Image.new('RGBA',(64,64))
        ImageDraw.Draw(body).ellipse((35,35,39,39),fill=(180,170,150,255))
        shield=Image.new('RGBA',(64,64))
        tip=Image.new('RGBA',(64,64))
        part=mask_region(body.getchannel('A'),(37,37))
        self.assertGreater(mask_count(part),0)
        with self.assertRaisesRegex(AssertionError,'Uncovered'):
            verify_registration(body,shield,tip,body,part,shield.getchannel('A'),check_hidden=True)

    def test_registered_composite_mutation_rejected(self):
        body=Image.new('RGBA',(64,64))
        shield, sm=shield_geometry((37,37))
        blade=visible_tip((37,37))
        composite=Image.alpha_composite(Image.alpha_composite(body,shield),blade)
        composite.putpixel((0,0),(255,0,0,255))
        with self.assertRaisesRegex(AssertionError,'does not equal'):
            verify_registration(body,shield,blade,composite,Image.new('L',(64,64)),sm,check_hidden=False)

    def test_visible_tip_outside_shield(self):
        _,mask=shield_geometry((37,37))
        blade=visible_tip((37,37))
        self.assertGreater(leakage(blade.getchannel('A'),mask),8)

    def test_partial_wrist_mask_cannot_be_full_body(self):
        body=Image.new('RGBA',(64,64))
        ImageDraw.Draw(body).rectangle((20,16,48,50),fill=(100,100,100,255))
        part=mask_region(body.getchannel('A'),(47,38))
        self.assertGreater(mask_count(part),0)
        self.assertLess(mask_count(part),80)

    def test_boundary_clipping_detected(self):
        sample=Image.new('RGBA',(64,64))
        sample.putpixel((63,5),(20,20,20,255))
        self.assertEqual(alpha_edges(sample),1)

    def test_proxy_blade_has_no_edge_clip(self):
        self.assertEqual(alpha_edges(visible_tip((46,40))),0)

    def test_modified_source_sha_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            file=Path(td)/'not_real.png'
            Image.new('RGBA',(256,192)).save(file)
            with self.assertRaisesRegex(ValueError,'SHA mismatch'):
                rgba_atlas_frames(file)

    def test_hit_timing_cannot_change(self):
        with tempfile.TemporaryDirectory() as td:
            file=Path(td)/'anchors.json'
            file.write_text(json.dumps({'contact_frame':7,'contact_second':0.54,'pose_anchors':[]}),encoding='utf8')
            with self.assertRaisesRegex(ValueError,'contact timing'):
                anchor_points(file)

    def test_missing_anchor_frames_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            file=Path(td)/'anchors.json'
            file.write_text(json.dumps({'contact_frame':7,'contact_second':0.63,'pose_anchors':[]}),encoding='utf8')
            with self.assertRaisesRegex(ValueError,'twelve canonical'):
                anchor_points(file)

    def test_source_frame_unchanged_by_compositor(self):
        body=Image.new('RGBA',(64,64))
        before=body.tobytes()
        shield,_=shield_geometry((37,37))
        tip=visible_tip((37,37))
        Image.alpha_composite(Image.alpha_composite(body,shield),tip)
        self.assertEqual(body.tobytes(),before)

if __name__=='__main__':
    unittest.main(verbosity=2)
