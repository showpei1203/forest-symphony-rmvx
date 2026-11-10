"""Synthetic A21 regression tests; separate from real private A11 art witness."""
import hashlib
import unittest
from PIL import Image, ImageDraw
from tools.asset_factory.a21_runtime_occlusion import (
    Layer, OcclusionError, build, load_png, overlay_actor, png_bytes,
)

class TestA21RuntimeOcclusion(unittest.TestCase):
    def setUp(self):
        master=Image.new('RGBA',(64,64),(32,100,40,255))
        master.putpixel((20,20),(230,30,30,255))
        self.master=png_bytes(master)
        self.sha=hashlib.sha256(self.master).hexdigest()
        mask=Image.new('L',(64,64),0)
        ImageDraw.Draw(mask).rectangle((16,16,32,24),fill=255)
        self.mask=png_bytes(mask)
        self.layer=Layer('tree1','tree_canopy',self.mask,hashlib.sha256(self.mask).hexdigest(),35,10,40)

    def test_exact_same_xy(self):
        ground,par,q=build(self.master,self.sha,[self.layer])
        self.assertEqual(ground,self.master)
        self.assertEqual(q['source_same_xy_rgb_mismatch_pixels'],0)
        self.assertEqual(load_png(par,'PAR').getpixel((20,20)),(230,30,30,255))
        self.assertEqual(load_png(par,'PAR').getpixel((0,0))[3],0)

    def test_footpoint_switch(self):
        _,_,q=build(self.master,self.sha,[self.layer],actor_foot=(20,25))
        self.assertEqual(q['selected_owner_ids'],['tree1'])
        _,front,q=build(self.master,self.sha,[self.layer],actor_foot=(20,45))
        self.assertEqual(q['selected_owner_ids'],[])
        self.assertIsNone(load_png(front,'front').getchannel('A').getbbox())
        _,_,q=build(self.master,self.sha,[self.layer],actor_foot=(41,25))
        self.assertEqual(q['selected_owner_ids'],[])

    def test_ground_semantic_rejected(self):
        v=Layer('bad','bridge_deck',self.mask,self.layer.mask_sha256,30,10,40)
        with self.assertRaises(OcclusionError):
            build(self.master,self.sha,[v])

    def test_master_sha_lock(self):
        with self.assertRaises(OcclusionError):
            build(self.master,'0'*64,[self.layer])

    def test_mask_sha_lock(self):
        v=Layer('bad','tree_canopy',self.mask,'0'*64,30,10,40)
        with self.assertRaises(OcclusionError):
            build(self.master,self.sha,[v])

    def test_deck_negative_zone(self):
        with self.assertRaises(OcclusionError):
            build(self.master,self.sha,[self.layer],negative_mask_png=self.mask)

    def test_no_double_owner(self):
        v=Layer('tree2','tree_canopy',self.mask,self.layer.mask_sha256,30,10,40)
        with self.assertRaises(OcclusionError):
            build(self.master,self.sha,[self.layer,v])
        # Overlap must be caught even if first owner is switched off by footpoint.
        with self.assertRaises(OcclusionError):
            build(self.master,self.sha,[self.layer,v],actor_foot=(20,45))

    def test_partial_alpha_rejected(self):
        m=Image.new('L',(64,64),0)
        m.putpixel((20,20),128)
        b=png_bytes(m)
        v=Layer('bad','tree_canopy',b,hashlib.sha256(b).hexdigest(),30,10,40)
        with self.assertRaises(OcclusionError):
            build(self.master,self.sha,[v])

    def test_empty_mask_rejected(self):
        b=png_bytes(Image.new('L',(64,64),0))
        v=Layer('bad','tree_canopy',b,hashlib.sha256(b).hexdigest(),30,10,40)
        with self.assertRaises(OcclusionError):
            build(self.master,self.sha,[v])

    def test_preview_layer_order(self):
        _,par,_=build(self.master,self.sha,[self.layer])
        actor=png_bytes(Image.new('RGBA',(16,16),(255,255,255,255)))
        preview=overlay_actor(self.master,par,actor,(16,16))
        self.assertEqual(load_png(preview,'preview').getpixel((20,20)),(230,30,30,255))

    def test_invalid_actor_position(self):
        with self.assertRaises(OcclusionError):
            build(self.master,self.sha,[self.layer],actor_foot=('20',25))

if __name__ == '__main__':
    unittest.main()
