"""A18 synthetic regression tests. Never include private F0 PNG or credentials."""
import copy
import math
import unittest

from tools.asset_factory.a15_pixellab_skeleton_v3_adapter import OFFICIAL_LABELS
from tools.asset_factory.a18_run_anatomy_preflight import (
    A18PoseError, FS_RUN_PLAYBACK, audit_actor01_run,
)

def _frame(updates):
    base = {
        "LEFT SHOULDER": (15, 20), "LEFT ELBOW": (13, 24), "LEFT ARM": (12, 27),
        "RIGHT SHOULDER": (29, 20), "RIGHT ELBOW": (31, 24), "RIGHT ARM": (31, 28),
        "LEFT HIP": (18, 26), "LEFT KNEE": (17, 30), "LEFT LEG": (16, 33),
        "RIGHT HIP": (27, 26), "RIGHT KNEE": (29, 30), "RIGHT LEG": (30, 33),
    }
    base.update(updates)
    return [
        {"label": name, "x": x / 48, "y": y / 48}
        for name in OFFICIAL_LABELS
        for x, y in (base.get(name, (24, 20)),)
    ]

def synthetic_run():
    neutral = _frame({})
    left = _frame({
        "LEFT KNEE": (16, 30), "LEFT LEG": (14, 33),
        "RIGHT KNEE": (29, 30), "RIGHT LEG": (31, 32),
        "LEFT ELBOW": (13, 23), "LEFT ARM": (16, 25),
        "RIGHT ELBOW": (30, 23), "RIGHT ARM": (27, 26),
    })
    right = _frame({
        "LEFT KNEE": (20, 30), "LEFT LEG": (23, 32),
        "RIGHT KNEE": (26, 30), "RIGHT LEG": (24, 33),
        "LEFT ELBOW": (12, 24), "LEFT ARM": (10, 27),
        "RIGHT ELBOW": (31, 23), "RIGHT ARM": (32, 27),
    })
    return {"action": "run", "direction": "south-west",
            "keypoints": [neutral, left, right], "first_frame_keypoints": neutral}

def _set_joint(frame, label, **updates):
    next(j for j in frame if j["label"] == label).update(**updates)

class A18RunPreflightTests(unittest.TestCase):
    def test_counterphase_and_bone_lengths_are_checked_but_source_holds(self):
        r = audit_actor01_run(synthetic_run())
        self.assertTrue(r["pose_geometry_pass"])
        self.assertTrue(r["alternating_legs"])
        self.assertTrue(r["opposing_arms"])
        self.assertTrue(r["segment_lengths_reasonable"])
        self.assertEqual(r["status"], "HOLD_SOURCE_NOT_PROVIDED")
        self.assertEqual(r["playback_indices"], [0, 1, 0, 2, 0])
        self.assertFalse(r["art_pass"])

    def test_foot_swaps_but_stretched_bone_does_not_pass(self):
        p = synthetic_run()
        _set_joint(p["keypoints"][2], "RIGHT KNEE", x=10 / 48)
        r = audit_actor01_run(p)
        self.assertTrue(r["alternating_legs"])
        self.assertFalse(r["segment_lengths_reasonable"])
        self.assertFalse(r["pose_geometry_pass"])

    def test_swapped_feet_without_counter_arm_motion_does_not_pass(self):
        p = synthetic_run()
        _set_joint(p["keypoints"][1], "LEFT ARM", x=10 / 48, y=27 / 48)
        r = audit_actor01_run(p)
        self.assertTrue(r["alternating_legs"])
        self.assertFalse(r["opposing_arms"])
        self.assertFalse(r["pose_geometry_pass"])

    def test_nan_rejected_not_silently_accepted(self):
        p = synthetic_run()
        _set_joint(p["keypoints"][1], "LEFT LEG", x=math.nan)
        with self.assertRaises(A18PoseError):
            audit_actor01_run(p)

    def test_boolean_coordinate_rejected(self):
        p = synthetic_run()
        _set_joint(p["keypoints"][1], "LEFT LEG", x=True)
        with self.assertRaises(A18PoseError):
            audit_actor01_run(p)

    def test_wrong_reference_pose_rejected(self):
        p = synthetic_run()
        p["first_frame_keypoints"] = copy.deepcopy(p["keypoints"][1])
        with self.assertRaises(A18PoseError):
            audit_actor01_run(p)

    def test_wrong_frame_count_rejected(self):
        p = synthetic_run()
        p["keypoints"].append(copy.deepcopy(p["keypoints"][0]))
        with self.assertRaises(A18PoseError):
            audit_actor01_run(p)

if __name__ == "__main__":
    unittest.main()
