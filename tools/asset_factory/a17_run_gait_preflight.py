"""A17: style-safe RUN skeleton preflight; no provider calls or private assets.

A15 locally-valid 18-joint JSON can still be invalid as running motion:
a SW character needs alternating *leading* feet, not both feet translating
together.  This gate is a pilot-specific geometry check, NEVER ART approval.
"""
from __future__ import annotations

from math import hypot
from io import BytesIO

from PIL import Image

class PosePreflightError(ValueError):
    pass

def _joint_map(joints):
    if not isinstance(joints,list) or len(joints)!=18:
        raise PosePreflightError("need 18 real skeleton joints")
    d={j.get("label"):j for j in joints}
    if len(d)!=18:
        raise PosePreflightError("duplicate or missing labels")
    for j in joints:
        if not isinstance(j.get("x"),(int,float)) or not isinstance(j.get("y"),(int,float)):
            raise PosePreflightError("missing joint coordinates")
        if not 0<=j["x"]<=1 or not 0<=j["y"]<=1:
            raise PosePreflightError("joint outside original canvas")
    for key in ("LEFT LEG","RIGHT LEG","RIGHT ELBOW","RIGHT ARM"):
        if key not in d:
            raise PosePreflightError("missing "+key)
    return d

def _forward_diff(joints, *,width=48,height=48):
    """SW screen-forward is (-x,+y); compare LEFT vs RIGHT foot progress."""
    pts=_joint_map(joints)
    def project(label):
        v=pts[label]
        return -v["x"]*width+v["y"]*height
    return round(project("LEFT LEG")-project("RIGHT LEG"),2)

def audit_southwest_run(payload, f0_png_bytes: bytes | None = None):
    """Fail closed for this 48px southwest pilot, never pretend native art passed."""
    if payload.get("action")!="run" or payload.get("direction")!="south-west":
        raise PosePreflightError("pilot is applicable to SW RUN only")
    frames=payload.get("keypoints")
    if not isinstance(frames,list) or len(frames)!=3:
        raise PosePreflightError("requires three stored poses")
    ref=payload.get("first_frame_keypoints")
    if ref!=frames[0]:
        raise PosePreflightError("F0 skeleton and first target pose do not match")
    distances=[_forward_diff(x) for x in frames]
    lead_swap=distances[1]*distances[2]<0
    in_reference={}
    if f0_png_bytes is not None:
        im=Image.open(BytesIO(f0_png_bytes)).convert("RGBA")
        if im.size!=(48,48):
            raise PosePreflightError("expected exact 48x48 approved F0")
        visible=[(x,y) for y in range(48) for x in range(48) if im.getpixel((x,y))[3]>0]
        if not visible:
            raise PosePreflightError("reference has no visible pixels")
        for label in ("RIGHT ELBOW","RIGHT ARM"):
            j=_joint_map(ref)[label]
            x=j["x"]*48;y=j["y"]*48
            in_reference[label]=round(min(hypot(x-u,y-v) for u,v in visible),2)
    return {
        "schema":"fs-a17-run-gait-gate/v1",
        "view":"south-west",
        "lead_difference_px":distances,
        "opposite_leg_lead_present":lead_swap,
        "source_joint_nearest_alpha_px":in_reference,
        "status":("HOLD_SOURCE_NOT_PROVIDED" if f0_png_bytes is None else ("PASS_POSE_GEOMETRY_ONLY" if lead_swap and all(v<=1.5 for v in in_reference.values()) else "HOLD_POSE_GEOMETRY")),
        "new_art_generated":False,"provider_called":False,"native_vx_ran":False,
        "art_user_approved":False,
        "warning":"The foot-order test is specific to this SW RUN pilot; it does not prove natural motion or visual consistency."
    }
