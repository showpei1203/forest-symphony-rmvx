"""A18 Actor01 RUN anti-stretch/anti-phase preflight (no API calls or private art).

This module validates *skeletal pose candidates*, never provider PNG quality, ART,
or RPG Maker VX. The single Actor01 patch is deliberately guarded by F0 SHA
and expected A17 joint coordinates; it must not be reused on other rigs.
"""
from __future__ import annotations

from copy import deepcopy
from io import BytesIO
import hashlib
import math

from PIL import Image

from tools.asset_factory.a15_pixellab_skeleton_v3_adapter import F0_SHA, OFFICIAL_LABELS
from tools.asset_factory.a17_run_gait_preflight import audit_southwest_run

class A18PoseError(ValueError):
    pass

SEGMENTS = tuple(
    (f"{side} {a}", f"{side} {b}")
    for side in ("LEFT", "RIGHT")
    for a, b in (("HIP", "KNEE"), ("KNEE", "LEG"),
                 ("SHOULDER", "ELBOW"), ("ELBOW", "ARM"))
)
# Authoring-time pose index order. Only 3 distinct provider frames are requested.
FS_RUN_PLAYBACK = (0, 1, 0, 2, 0)

def _positions(frame):
    if not isinstance(frame, list) or len(frame) != 18:
        raise A18PoseError("exactly 18 joints required")
    found = {}
    for joint in frame:
        if not isinstance(joint, dict):
            raise A18PoseError("joint must be a dict")
        label = joint.get("label")
        if label in found or label not in OFFICIAL_LABELS:
            raise A18PoseError("duplicate or unknown joint")
        coords = (joint.get("x"), joint.get("y"))
        if any(isinstance(v, bool) or not isinstance(v, (int, float))
               or not math.isfinite(v) or not 0 <= v <= 1 for v in coords):
            raise A18PoseError("nonfinite or off-canvas coordinate")
        found[label] = (float(coords[0]) * 48, float(coords[1]) * 48)
    if set(found) != set(OFFICIAL_LABELS):
        raise A18PoseError("missing official joint label")
    return found

def _forward(p, label):
    x, y = p[label]
    return -x + y  # specific 48px SW-screen direction, not a generic rig rule

def _hip_relative_lead(p):
    return ((_forward(p, "LEFT LEG") - _forward(p, "LEFT HIP"))
          - (_forward(p, "RIGHT LEG") - _forward(p, "RIGHT HIP")))

def _shoulder_relative_arm_lead(p):
    return ((_forward(p, "LEFT ARM") - _forward(p, "LEFT SHOULDER"))
          - (_forward(p, "RIGHT ARM") - _forward(p, "RIGHT SHOULDER")))

def audit_actor01_run(payload, approved_f0_png=None, *, min_segment_ratio=0.60,
                      max_segment_ratio=1.40):
    """Fail closed, with an explicit source gate. Does not call PixelLab."""
    if not isinstance(payload, dict) or payload.get("action") != "run" or payload.get("direction") != "south-west":
        raise A18PoseError("Actor01 southwest RUN pilot only")
    frames = payload.get("keypoints")
    if not isinstance(frames, list) or len(frames) != 3:
        raise A18PoseError("must have three distinct keypoint poses")
    points = [_positions(f) for f in frames]
    if payload.get("first_frame_keypoints") != frames[0]:
        raise A18PoseError("reference pose mismatch")
    lengths = []
    for pose in points:
        d = {}
        for a, b in SEGMENTS:
            d[a + " -> " + b] = math.dist(pose[a], pose[b])
        lengths.append(d)
    ratio_report = {}
    for i in (1, 2):
        ratios = {}
        for name, base_length in lengths[0].items():
            if base_length < 0.25:
                raise A18PoseError("degenerate F0 segment")
            ratios[name] = lengths[i][name] / base_length
        ratio_report[str(i)] = {k: round(v, 4) for k, v in ratios.items()}
    leads = [round(_hip_relative_lead(p), 3) for p in points]
    arms = [round(_shoulder_relative_arm_lead(p), 3) for p in points]
    alternates = leads[1] >= 5 and leads[2] <= -5
    counter_swings = arms[1] <= -3 and arms[2] >= 3
    stable_segments = all(min_segment_ratio <= value <= max_segment_ratio
                          for row in ratio_report.values() for value in row.values())
    source_ok = False
    if approved_f0_png is not None:
        if hashlib.sha256(approved_f0_png).hexdigest() != F0_SHA:
            raise A18PoseError("source F0 SHA mismatch")
        try:
            img = Image.open(BytesIO(approved_f0_png))
            if img.size != (48, 48):
                raise A18PoseError("wrong F0 dimensions")
        except (OSError, ValueError) as ex:
            raise A18PoseError("invalid F0 image") from ex
        old = audit_southwest_run(payload, approved_f0_png)
        source_ok = old["status"] == "PASS_POSE_GEOMETRY_ONLY"
    geometry = alternates and counter_swings and stable_segments
    return {
        "schema": "fs-a18-actor01-run-rig-preflight/v1",
        "stored_frames": 3,
        "playback_indices": list(FS_RUN_PLAYBACK),
        "hip_relative_foot_lead_px": leads,
        "shoulder_relative_arm_lead_px": arms,
        "segment_ratios_against_f0": ratio_report,
        "alternating_legs": alternates,
        "opposing_arms": counter_swings,
        "segment_lengths_reasonable": stable_segments,
        "pose_geometry_pass": geometry,
        "source_sha_verified": source_ok,
        "status": ("HOLD_SOURCE_NOT_PROVIDED" if approved_f0_png is None
                   else "PASS_POSE_GEOMETRY_ONLY" if geometry and source_ok
                   else "HOLD_POSE_GEOMETRY"),
        "pixel_lab_calls": 0, "new_sprite_frames": 0,
        "art_pass": False, "native_vx_pass": False,
        "warning": "Geometry screen only. Perspective/foot depth/1x ART/real provider output still require review."
    }

# Actor01-only guarded delta applied to A17 private payload in RAM.
# No first_frame images, secrets, or complete private JSON are stored here.
EXPECTED_A17 = {
    1: {"LEFT ELBOW": (17, 34), "LEFT ARM": (16, 38)},
    2: {"LEFT KNEE": (28, 37), "LEFT LEG": (33, 39),
        "RIGHT KNEE": (21, 38), "RIGHT LEG": (17, 41),
        "RIGHT ELBOW": (34, 34), "RIGHT ARM": (36, 38)}
}
A18_DELTA = {
    1: {"LEFT ELBOW": (17, 33), "LEFT ARM": (19, 36)},
    2: {"LEFT KNEE": (24, 38), "LEFT LEG": (28, 39),
        "RIGHT KNEE": (26, 38), "RIGHT LEG": (23, 41),
        "RIGHT ELBOW": (33, 32), "RIGHT ARM": (34, 36)}
}

def prepare_actor01_a18_candidate(a17_private_payload):
    """Patch a verified A17 input in memory, reject other versions/characters."""
    obj = deepcopy(a17_private_payload)
    if not isinstance(obj, dict) or not isinstance(obj.get("first_frame"), dict):
        raise A18PoseError("missing real original F0")
    try:
        import base64
        raw = base64.b64decode(obj["first_frame"]["base64"], validate=True)
    except (KeyError, TypeError, ValueError) as ex:
        raise A18PoseError("bad original F0 base64") from ex
    if hashlib.sha256(raw).hexdigest() != F0_SHA:
        raise A18PoseError("not approved Actor01 F0")
    if obj.get("action") != "run" or obj.get("direction") != "south-west":
        raise A18PoseError("not A17 southwest RUN")
    before = obj.get("keypoints")
    if not isinstance(before, list) or len(before) != 3:
        raise A18PoseError("not three source poses")
    for index, expected in EXPECTED_A17.items():
        p = _positions(before[index])
        for label, coord in expected.items():
            if math.dist(p[label], coord) > 0.03:
                raise A18PoseError("A17 joint version mismatch: " + label)
    for index, updates in A18_DELTA.items():
        joints = {j["label"]: j for j in obj["keypoints"][index]}
        for label, (x, y) in updates.items():
            joints[label]["x"] = round(x / 48, 6)
            joints[label]["y"] = round(y / 48, 6)
    result = audit_actor01_run(obj, raw)
    if result["status"] != "PASS_POSE_GEOMETRY_ONLY":
        raise A18PoseError("candidate failed A18 anatomy gate")
    return obj, result
