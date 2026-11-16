"""FS A27 synthetic positive/negative cases. NO private FS pixels here."""
import hashlib
import unittest

import numpy as np
from PIL import Image, ImageDraw

from tools.asset_factory.a27_semantic_depth_occlusion import (
    A27Error, DepthOwner, png_bytes, render_actor_case,
)


class TestA27SemanticDepth(unittest.TestCase):
    def setUp(self):
        src = Image.new('RGBA',(64,64),(90,130,60,255))
        src.putpixel((25,26),(220,60,50,255))
        self.master = png_bytes(src)
        self.sha = hashlib.sha256(self.master).hexdigest()
        self.actor = png_bytes(Image.new('RGBA',(10,10),(255,255,255,255)))
        mask = Image.new('L',(64,64),0)
        ImageDraw.Draw(mask).rectangle((20,18,29,29),fill=255)
        self.m = png_bytes(mask)
        self.obj = self.owner()

    def owner(self, **overrides):
        kwargs=dict(object_id='tree1',semantic='tree_canopy',mask_png=self.m,
                    mask_sha256=hashlib.sha256(self.m).hexdigest(),
                    x_min=20,x_max=30,far_foot_y=15,near_foot_y=40,
                    source_label='synthetic_source_mask')
        kwargs.update(overrides)
        return DepthOwner(**kwargs)

    def run_case(self, **overrides):
        kw=dict(master_png=self.master,master_sha256=self.sha,actor_png=self.actor,
                actor_top_left=(22,21),actor_foot=(25,29),objects=[self.obj])
        kw.update(overrides)
        return render_actor_case(**kw)

    def test_same_master_bytes_and_same_xy_source_rgba(self):
        full,par,preview,qa=self.run_case()
        self.assertEqual(full,self.master)
        self.assertEqual(qa['source_same_xy_rgba_mismatch_pixels'],0)
        self.assertEqual(qa['native_vx'],'NOT_RUN')
        arr=np.asarray(Image.open(__import__('io').BytesIO(par)))
        m=arr[:,:,3]>0
        self.assertTrue(np.any(m))
        src=np.asarray(Image.open(__import__('io').BytesIO(self.master)))
        np.testing.assert_array_equal(arr[m],src[m])
        self.assertTrue(preview.startswith(b'\x89PNG'))

    def test_depth_partial_occlusion_less_than_static_mask(self):
        _,_,_,q=self.run_case()
        self.assertGreater(q['occlusion_pixels'],0)
        self.assertLess(q['occlusion_pixels'],q['owners'][0]['actor_overlap_pixels'])

    def test_actor_in_front_zero_mask(self):
        _,par,_,q=self.run_case(actor_foot=(25,30),objects=[self.owner(far_foot_y=0,near_foot_y=20)])
        self.assertEqual(q['occlusion_pixels'],0)
        self.assertIsNone(Image.open(__import__('io').BytesIO(par)).getchannel('A').getbbox())

    def test_reject_bad_source_sha(self):
        with self.assertRaises(A27Error): self.run_case(master_sha256='0'*64)

    def test_reject_bad_mask_sha(self):
        with self.assertRaises(A27Error): self.run_case(objects=[self.owner(mask_sha256='0'*64)])

    def test_reject_forbidden_semantic_even_with_valid_pixels(self):
        with self.assertRaises(A27Error): self.run_case(objects=[self.owner(semantic='bridge_deck')])

    def test_roof_semantic_valid_in_synthetic(self):
        _,_,_,q=self.run_case(objects=[self.owner(semantic='roof_front_eave')])
        self.assertGreater(q['occlusion_pixels'],0)

    def test_reject_ownership_overlap(self):
        with self.assertRaises(A27Error):
            self.run_case(objects=[self.obj,self.owner(object_id='tree2')])

    def test_reject_duplicate_owner_id(self):
        with self.assertRaises(A27Error): self.run_case(objects=[self.obj,self.obj])

    def test_reject_fractional_mask(self):
        m=Image.new('L',(64,64),0); m.putpixel((25,25),128)
        b=png_bytes(m)
        with self.assertRaises(A27Error):
            self.run_case(objects=[self.owner(mask_png=b,mask_sha256=hashlib.sha256(b).hexdigest())])

    def test_reject_x_ownership_leaking_outside_span(self):
        with self.assertRaises(A27Error): self.run_case(objects=[self.owner(x_min=24,x_max=29)])

    def test_reject_invalid_depth_order(self):
        with self.assertRaises(A27Error): self.run_case(objects=[self.owner(far_foot_y=55,near_foot_y=50)])

    def test_reject_negative_ground_region(self):
        with self.assertRaises(A27Error): self.run_case(negative_mask_png=self.m)

    def test_reject_outside_actor(self):
        with self.assertRaises(A27Error): self.run_case(actor_top_left=(60,60),actor_foot=(62,62))

    def test_reject_actor_foot_not_on_sprite(self):
        with self.assertRaises(A27Error): self.run_case(actor_foot=(50,50))

    def test_reject_empty_actor(self):
        b=png_bytes(Image.new('RGBA',(10,10),(0,0,0,0)))
        with self.assertRaises(A27Error): self.run_case(actor_png=b)

    def test_reject_same_rgb_wrong_owner_no_inference(self):
        # The renderer requires an explicit provenance mask; identical RGB is not an owner.
        with self.assertRaises(A27Error): self.run_case(objects=[])

    def test_single_object_par_is_only_actor_silhouette(self):
        _,par,_,q=self.run_case()
        ar=np.asarray(Image.open(__import__('io').BytesIO(par)).getchannel('A'))>0
        silhouette=np.zeros((64,64),dtype=bool); silhouette[21:31,22:32]=True
        self.assertFalse(np.any(ar & ~silhouette))
        self.assertEqual(q['occlusion_pixels'],int(ar.sum()))

if __name__=='__main__': unittest.main()
