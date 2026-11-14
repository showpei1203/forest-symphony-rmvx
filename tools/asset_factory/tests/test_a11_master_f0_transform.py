"""Small deterministic A11 tests for real A11 translation invariants.

Synthetic pixels are NOT new source artwork. Private actual source PNG evidence
remains in owner's Drive and must be cold-verified separately.
"""
import unittest
import numpy as np
from PIL import Image
from tools.asset_factory.a11_master_f0_transform import (
    A11GateError, source_runtime_par, check_overlay_rgb,
    strict_original_master_rgb, integer_f0_waiting, verify_f0_palette_identity
)


class A11SourcePreservationTests(unittest.TestCase):
    def setUp(self):
        a = np.zeros((64,64,3), np.uint8)
        a[:,:,:] = (41,100,173)
        a[12:40,16:35] = (213,135,24)
        self.master = Image.fromarray(a, "RGB")
        m = np.zeros((64,64), np.uint8);m[15:31,18:29] = 255
        self.semantic = Image.fromarray(m,"L")

    def test_same_xy_runtime_pixel_identity(self):
        par,result=source_runtime_par(self.master,self.semantic)
        self.assertEqual(result.par_alpha_pixels,16*11)
        self.assertEqual(result.same_xy_rgb_mismatches,0)
        self.assertEqual(check_overlay_rgb(self.master,par),0)

    def test_detects_one_pixel_redraw_shift(self):
        par,_=source_runtime_par(self.master,self.semantic)
        buf=np.asarray(par).copy()
        buf[20,22,:3] = (0,0,0)
        shifted=Image.fromarray(buf,"RGBA")
        self.assertEqual(check_overlay_rgb(self.master,shifted),1)
        self.assertFalse(strict_original_master_rgb(b"unaltered Master",b"changed Master"))

    def test_rejects_ground_semantics_and_wrong_canvas(self):
        forbidden=np.zeros((64,64),np.uint8);forbidden[19:28,21:32]=255
        with self.assertRaises(A11GateError):
            source_runtime_par(self.master,self.semantic,Image.fromarray(forbidden,"L"))
        with self.assertRaises(A11GateError):
            source_runtime_par(self.master,self.semantic.resize((32,32)))

    def test_actor_new_pose_colors_strict_and_motion_not_approved(self):
        data=np.zeros((48,48,4),np.uint8)
        data[7:41,13:36] = (110,150,65,255)
        data[30:42,18:35] = (42,70,60,255)
        f0=Image.fromarray(data,"RGBA")
        poses=integer_f0_waiting(f0)
        verdict=verify_f0_palette_identity(f0,poses)
        self.assertEqual(len(poses),3)
        self.assertTrue(verdict["f0_palette_preserved"])
        self.assertEqual(verdict["metrics"][0]["changed_pixel_positions"],0)
        self.assertGreater(verdict["metrics"][1]["changed_pixel_positions"],0)
        self.assertFalse(verdict["art_user_approved"])


if __name__=="__main__":
    unittest.main()
