#!/usr/bin/env python3
"""FS T-A R27: OFFLINE-only head-keypoint plan audit, NOT a PixelLab API client.

Input: R26 PRIVATE provider job receipt JSON (18 original COCO-like labels + 4 poses).
Output: sanitized QA counts and planned deltas only, never source image or full skeleton.
Exact R26 private receipt remains unchanged. No network, no model invocation, no pixels.
"""
from __future__ import annotations
import argparse
import copy
import json
from pathlib import Path

LABELS = {"NOSE", "NECK", "RIGHT SHOULDER", "RIGHT ELBOW", "RIGHT ARM",
          "LEFT SHOULDER", "LEFT ELBOW", "LEFT ARM", "RIGHT HIP", "RIGHT KNEE",
          "RIGHT LEG", "LEFT HIP", "LEFT KNEE", "LEFT LEG", "RIGHT EYE",
          "LEFT EYE", "RIGHT EAR", "LEFT EAR"}
FACE = ("NOSE", "LEFT EYE", "RIGHT EYE", "LEFT EAR", "RIGHT EAR")
# A new future candidate model, NOT a change to already generated R26 sprites.
PLANS = {"F03": (-1, 1, "focus / slight downward turn"),
         "F05": (0, -1, "lift gaze into acceleration"),
         "F07": (1, 0, "turn with swing toward impact"),
         "F09": (0, 1, "settle after follow-through")}
EXPECTED_SOURCE = "70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e"

def indexed(points):
    assert isinstance(points, list) and len(points) == 18, "exact 18 joints required"
    d = {p["label"]: p for p in points}
    assert len(d) == 18 and set(d) == LABELS, "duplicate or missing joints"
    for p in points:
        for key in ("x", "y"):
            v = p[key]
            assert isinstance(v, (int, float)) and not isinstance(v, bool) and 0 <= v <= 1
    return d

def amend_pose(frame, dx, dy):
    p = copy.deepcopy(frame)
    before = indexed(frame)
    after = indexed(p)
    for label in FACE:
        for key, step in (("x", dx), ("y", dy)):
            after[label][key] = before[label][key] + step / 64.0
    # Neck anchor follows the face with half the offset, retaining existing torso shift.
    after["NECK"]["x"] = before["NECK"]["x"] + dx / 128.0
    after["NECK"]["y"] = before["NECK"]["y"] + dy / 128.0
    indexed(p)
    for label in LABELS - set(FACE) - {"NECK"}:
        assert after[label] == before[label], "body joint unexpectedly altered: " + label
    for label in FACE:
        assert abs(64 * (after[label]["x"] - before[label]["x"]) - dx) < 1e-8
        assert abs(64 * (after[label]["y"] - before[label]["y"]) - dy) < 1e-8
    # This preserves relative head landmark positions: no face morphing is implied.
    for label in FACE:
        assert abs((after[label]["x"] - after["NOSE"]["x"]) -
                   (before[label]["x"] - before["NOSE"]["x"])) < 1e-8
        assert abs((after[label]["y"] - after["NOSE"]["y"]) -
                   (before[label]["y"] - before["NOSE"]["y"])) < 1e-8
    return p

def compute(receipt):
    assert receipt["exact_original_sha"] == EXPECTED_SOURCE, "wrong original A62 identity"
    assert receipt["provider"] == "PixelLab" and receipt["model"] == "animate-with-skeleton-v3"
    rest = receipt["skeleton_start"]
    start = indexed(rest)
    poses = receipt["skeleton_four_pose_frames"]
    assert len(poses) == len(PLANS)
    current_face_unchanged = True
    plan_entries = []
    for (name, (dx, dy, note)), original in zip(PLANS.items(), poses):
        o = indexed(original)
        if any(o[label] != start[label] for label in FACE):
            current_face_unchanged = False
        copy_of_original = copy.deepcopy(original)
        p = amend_pose(original, dx, dy)
        assert original == copy_of_original, "input receipt pose mutated"
        v = indexed(p)
        assert any(v[label] != o[label] for label in FACE)
        plan_entries.append({"frame": name, "relative_face_dx_px": dx,
                             "relative_face_dy_px": dy, "note": note,
                             "changed_joint_labels": sorted([label for label in LABELS if v[label] != o[label]]),
                             "unchanged_other_body_joint_count": 12,
                             "face_geometry_unchanged": True,
                             "source_frame_was_not_modified": True})
    return {"stage": "HEAD_MODEL_SPEC_ONLY_NOT_RENDERED",
            "generation_spend": 0, "provider_call": "NOT_RUN",
            "approved_original_source_sha256": EXPECTED_SOURCE,
            "initial_18_joint_labels_verified": True,
            "existing_R26_all_five_face_landmarks_frozen": current_face_unchanged,
            "F00_identity_unchanged": True,
            "new_pose_count": len(plan_entries), "keyframes": plan_entries,
            "new_character_art": "NOT_GENERATED",
            "face_expression_pixels": "NOT_EDITED",
            "owner_art_gate": "NOT_RUN_RESEARCH_ONLY",
            "rest_api_v3_payload_validation": "NOT_RUN_DO_NOT_POST"}

def selftest():
    labels = sorted(LABELS)
    base = [{"label": n, "x": 0.5, "y": 0.5} for n in labels]
    fake = {"exact_original_sha": EXPECTED_SOURCE, "provider": "PixelLab",
            "model": "animate-with-skeleton-v3", "skeleton_start": base,
            "skeleton_four_pose_frames": [copy.deepcopy(base) for _ in range(4)]}
    q = compute(fake)
    assert q["existing_R26_all_five_face_landmarks_frozen"]
    assert q["F00_identity_unchanged"] and q["new_pose_count"] == 4
    assert all(e["unchanged_other_body_joint_count"] == 12 for e in q["keyframes"])
    bad = copy.deepcopy(fake); bad["skeleton_start"].pop()
    try: compute(bad)
    except AssertionError: pass
    else: raise AssertionError("missing original joint not rejected")
    bad2 = copy.deepcopy(fake);bad2["exact_original_sha"] = "bad"
    try: compute(bad2)
    except AssertionError: pass
    else: raise AssertionError("wrong source not rejected")
    return {"result":"PASS", "complete_18_joint_guard":"PASS",
            "bad_source_guard":"REJECTED", "missing_joint_guard":"REJECTED",
            "no_network_calls": True, "art_pixels_changed": 0,
            "note":"synthetic fixture tests, not original R26 sprites or PixelLab generation"}

if __name__ == "__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--selftest",action="store_true")
    ap.add_argument("--receipt",type=Path)
    ap.add_argument("--out",type=Path)
    args=ap.parse_args()
    if args.selftest:
        x=selftest()
    else:
        if args.receipt is None: ap.error("--receipt required")
        x=compute(json.loads(args.receipt.read_text(encoding="utf8")))
    if args.out:
        args.out.parent.mkdir(parents=True,exist_ok=True)
        args.out.write_text(json.dumps(x,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
    print(json.dumps(x,ensure_ascii=False,indent=2))
