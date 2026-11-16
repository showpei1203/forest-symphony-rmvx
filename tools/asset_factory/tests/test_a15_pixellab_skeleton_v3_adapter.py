"""A15 public synthetic regression: no private art, no external PixelLab calls."""
import hashlib
from io import BytesIO
import unittest
from PIL import Image
from tools.asset_factory.a15_pixellab_skeleton_v3_adapter import (
    V3ContractError,native48_pose,build_v3_request,validate_provider_frames,OFFICIAL_LABELS
)

class V3AdapterTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        img=Image.new("RGBA",(48,48))
        for y in range(8,42):
            for x in range(15,34):img.putpixel((x,y),(180,185,197,255))
        b=BytesIO();img.save(b,format="PNG")
        cls.f0=b.getvalue();cls.sha=hashlib.sha256(cls.f0).hexdigest()
        orig={
            "NOSE":(24,14),"NECK":(24,19),"RIGHT_SHOULDER":(27,21),"RIGHT_ELBOW":(30,25),
            "RIGHT_WRIST":(31,30),"LEFT_SHOULDER":(21,21),"LEFT_ELBOW":(18,25),"LEFT_WRIST":(17,30),
            "RIGHT_HIP":(26,30),"RIGHT_KNEE":(27,35),"RIGHT_ANKLE":(29,39),
            "LEFT_HIP":(22,30),"LEFT_KNEE":(21,35),"LEFT_ANKLE":(20,39),
            "RIGHT_EYE":(26,15),"LEFT_EYE":(22,15),"RIGHT_EAR":(30,16),"LEFT_EAR":(18,16)
        }
        cls.base={k:{"x":(x+8)/64,"y":(y+8)/64} for k,(x,y) in orig.items()}
        second={k:dict(v) for k,v in cls.base.items()}
        third={k:dict(v) for k,v in cls.base.items()}
        second["LEFT_ANKLE"]["x"]+=2/64
        third["RIGHT_ANKLE"]["x"]-=2/64
        cls.frames=[cls.base,second,third]

    def test_18_live_labels_and_native_pose_math(self):
        pose=native48_pose(self.base)
        self.assertEqual({x["label"] for x in pose},set(OFFICIAL_LABELS))
        self.assertEqual(next(x["x"] for x in pose if x["label"]=="NOSE"),0.5)
        self.assertTrue(any(x["label"]=="LEFT ARM" for x in pose))
        self.assertFalse(any("WRIST" in x["label"] for x in pose))

    def test_source_is_true_48_not_padded_64(self):
        p=build_v3_request(self.f0,self.frames,action="RUN",
              description="white-haired adventurer",expected_sha=self.sha)
        from base64 import b64decode
        self.assertEqual(Image.open(BytesIO(b64decode(p["first_frame"]["base64"]))).size,(48,48))
        self.assertEqual(p["first_frame_keypoints"],p["keypoints"][0])
        self.assertEqual(len(p["keypoints"]),3)

    def test_wrong_source_f0_is_blocked(self):
        with self.assertRaises(V3ContractError):
            build_v3_request(self.f0,self.frames,action="RUN",description="adventurer")

    def test_missing_joint_is_blocked(self):
        x=dict(self.base);del x["NECK"]
        with self.assertRaises(V3ContractError):native48_pose(x)

    def test_offcanvas_joint_is_blocked(self):
        x={k:dict(v) for k,v in self.base.items()};x["NOSE"]["x"]=1.8
        with self.assertRaises(V3ContractError):native48_pose(x)

    def test_wrong_provider_infographic_size_is_rejected(self):
        with self.assertRaises(V3ContractError):
            validate_provider_frames([Image.new("RGBA",(1536,1024))]*3,reference_image=Image.new("RGBA",(48,48)))

    def test_generated_first_pose_does_not_need_byte_equality_to_f0(self):
        a=Image.new("RGBA",(48,48))
        for y in range(8,42):
            for x in range(15,34):a.putpixel((x,y),(180,185,197,255))
        b=a.copy();c=a.copy();b.putpixel((18,30),(0,0,0,0));c.putpixel((29,35),(0,0,0,0))
        result=validate_provider_frames([a,b,c],reference_image=Image.new("RGBA",(48,48)))
        self.assertTrue(result["generated_first_pose_may_differ_from_f0"])
        self.assertEqual(result["art_review"],"REQUIRED")

if __name__=="__main__":
    unittest.main()
