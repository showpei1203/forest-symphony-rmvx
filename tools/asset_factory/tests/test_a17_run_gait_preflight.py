"""A17 pilot-only tests. No private art/keys, no provider call."""
import io
import unittest
from PIL import Image
from tools.asset_factory.a17_run_gait_preflight import audit_southwest_run, PosePreflightError

LABELS=("NOSE","NECK","RIGHT SHOULDER","RIGHT ELBOW","RIGHT ARM",
        "LEFT SHOULDER","LEFT ELBOW","LEFT ARM","RIGHT HIP","RIGHT KNEE","RIGHT LEG",
        "LEFT HIP","LEFT KNEE","LEFT LEG","RIGHT EYE","LEFT EYE","RIGHT EAR","LEFT EAR")

def pose(left_x,right_x):
    labels=[{"label":k,"x":0.5,"y":0.5} for k in LABELS]
    d={z["label"]:z for z in labels}
    d["LEFT LEG"].update(x=left_x/48,y=40/48)
    d["RIGHT LEG"].update(x=right_x/48,y=40/48)
    return labels

def payload(swap=False):
    a=pose(20,32)
    b=pose(17,30)
    c=pose(34,17) if swap else pose(19,34)
    return {"action":"run","direction":"south-west",
            "first_frame_keypoints":a,"keypoints":[a,b,c]}

def opaque_f0():
    im=Image.new("RGBA",(48,48),(55,90,30,255))
    f=io.BytesIO()
    im.save(f,format="PNG")
    return f.getvalue()

class A17RunGaitGateTests(unittest.TestCase):
    def test_naive_same_foot_leads_two_strides_must_hold(self):
        result=audit_southwest_run(payload(False),opaque_f0())
        self.assertEqual(result["status"],"HOLD_POSE_GEOMETRY")
        self.assertFalse(result["opposite_leg_lead_present"])

    def test_opposite_feet_geometric_pass_is_not_art_pass(self):
        result=audit_southwest_run(payload(True),opaque_f0())
        self.assertEqual(result["status"],"PASS_POSE_GEOMETRY_ONLY")
        self.assertFalse(result["art_user_approved"])
        self.assertFalse(result["new_art_generated"])

    def test_no_approved_F0_bytes_is_hold(self):
        r=audit_southwest_run(payload(True))
        self.assertEqual(r["status"],"HOLD_SOURCE_NOT_PROVIDED")

    def test_invalid_duplicate_joint_fails_closed(self):
        p=payload(True)
        p["keypoints"][1][0]["label"]="RIGHT EYE"
        with self.assertRaises(PosePreflightError):
            audit_southwest_run(p,opaque_f0())

    def test_original_ref_mismatch_fails_closed(self):
        p=payload(True);p["first_frame_keypoints"]=pose(10,38)
        with self.assertRaises(PosePreflightError):
            audit_southwest_run(p,opaque_f0())

if __name__=="__main__": unittest.main()
