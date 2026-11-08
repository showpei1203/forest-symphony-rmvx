"""A14 48/64 F0 pose conditional converter QA: synthetic only, NO AI artwork."""
import unittest
from PIL import Image
import numpy as np
from tools.asset_factory.a14_f0_pose_provider_gate import (
    FSArtGateError,pad_to_provider_64,coordinates_from_source48,
    normalize_generated_frame,validate_three_frames,
)


def synthetic_actor():
    a = np.zeros((48,48,4),np.uint8)
    a[8:40,14:36,:] = (89,120,77,255)
    return Image.fromarray(a,"RGBA")


class A14PoseGateTest(unittest.TestCase):
    def test_48px_source_is_exact_in_center_of_64px(self):
        source=synthetic_actor()
        padded=pad_to_provider_64(source)
        self.assertEqual(padded.size,(64,64))
        self.assertTrue(np.array_equal(np.asarray(source),np.asarray(padded.crop((8,8,56,56)))))
        self.assertTrue(np.array_equal(np.asarray(source),np.asarray(normalize_generated_frame(padded))))

    def test_normalized_joint_fraction_has_actual_padding(self):
        self.assertEqual(coordinates_from_source48((0,0)),{"x":0.125,"y":0.125})
        self.assertEqual(coordinates_from_source48((24,24)),{"x":0.5,"y":0.5})
        with self.assertRaises(FSArtGateError):coordinates_from_source48((52,24))

    def test_wrong_infographic_size_and_clip_rejected(self):
        with self.assertRaises(FSArtGateError):
            normalize_generated_frame(Image.new("RGBA",(1536,1024)))
        clipped=Image.new("RGBA",(64,64))
        clipped.putpixel((2,2),(255,255,255,255))
        with self.assertRaises(FSArtGateError):normalize_generated_frame(clipped)

    def test_three_keyframes_are_not_three_identical_stills(self):
        f0=synthetic_actor()
        with self.assertRaises(FSArtGateError):validate_three_frames(f0,[f0,f0,f0])

    def test_changed_f0_first_frame_rejected(self):
        f0=synthetic_actor()
        changed=f0.copy()
        changed.putpixel((20,20),(1,1,1,255))
        with self.assertRaises(FSArtGateError):
            validate_three_frames(f0,[changed,f0,changed])

    def test_distinct_poses_pass_format_only_and_not_art(self):
        f0=synthetic_actor()
        p2=f0.copy();p3=f0.copy()
        p2.putpixel((17,38),(0,0,0,0))
        p3.putpixel((32,38),(0,0,0,0))
        result=validate_three_frames(f0,[f0,p2,p3])
        self.assertEqual(result["frame_geometry"],"PASS")
        self.assertEqual(result["native_game_exe"],"NOT_RUN")
        self.assertEqual(result["human_art_review"],"REQUIRED")
        self.assertEqual(result["formal_seal"],"NO")


if __name__=="__main__":
    unittest.main()
