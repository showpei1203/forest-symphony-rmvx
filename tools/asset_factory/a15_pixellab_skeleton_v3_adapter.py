"""A15 official PixelLab v2 Skeleton v3 adapter (no secrets, no remote API calls).

Verified against PixelLab live OpenAPI on 2026-11-08:
POST /v2/animate-with-skeleton-v3; 18 SkeletonLabel enums, reference
first_frame separate from 3-15 returned keypoints. 48px direct input:
the route specifies <=256px reference and frames output at source size,
unlike older editor fixed-size workflows. Live rendering still NOT RUN.
Private source PNG, inline base64 requests and provider outputs must NOT be
committed to public GitHub.
"""
import base64
import hashlib
from io import BytesIO
from PIL import Image

F0_SHA="a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba"
OFFICIAL_LABELS=(
    "NOSE","NECK","RIGHT SHOULDER","RIGHT ELBOW","RIGHT ARM",
    "LEFT SHOULDER","LEFT ELBOW","LEFT ARM","RIGHT HIP","RIGHT KNEE","RIGHT LEG",
    "LEFT HIP","LEFT KNEE","LEFT LEG","RIGHT EYE","LEFT EYE","RIGHT EAR","LEFT EAR"
)
INTERNAL_TO_API={
    "NOSE":"NOSE","NECK":"NECK","RIGHT_SHOULDER":"RIGHT SHOULDER",
    "RIGHT_ELBOW":"RIGHT ELBOW","RIGHT_WRIST":"RIGHT ARM",
    "LEFT_SHOULDER":"LEFT SHOULDER","LEFT_ELBOW":"LEFT ELBOW","LEFT_WRIST":"LEFT ARM",
    "RIGHT_HIP":"RIGHT HIP","RIGHT_KNEE":"RIGHT KNEE","RIGHT_ANKLE":"RIGHT LEG",
    "LEFT_HIP":"LEFT HIP","LEFT_KNEE":"LEFT KNEE","LEFT_ANKLE":"LEFT LEG",
    "RIGHT_EYE":"RIGHT EYE","LEFT_EYE":"LEFT EYE","RIGHT_EAR":"RIGHT EAR","LEFT_EAR":"LEFT EAR"
}
DIRECTIONS={"north","north-east","east","south-east","south","south-west","west","north-west"}
VIEWS={"low top-down","high top-down","side"}

class V3ContractError(ValueError):pass

def native48_pose(canonical_pose):
    """A14 normalized 64px padded x/y -> original untouched 48px XY and API labels."""
    if set(canonical_pose)!=set(INTERNAL_TO_API):raise V3ContractError("must supply all 18 distinct internal joint keys")
    out=[]
    for orig,api_name in INTERNAL_TO_API.items():
        x=(float(canonical_pose[orig]["x"])*64-8)/48
        y=(float(canonical_pose[orig]["y"])*64-8)/48
        if not(0<=x<=1 and 0<=y<=1):raise V3ContractError("joint outside original 48px canvas")
        out.append({"label":api_name,"x":round(x,6),"y":round(y,6)})
    if {x["label"] for x in out}!=set(OFFICIAL_LABELS):raise V3ContractError("official label mapping failed")
    return out

def build_v3_request(source_png, canonical_frames, *, action, description,
                     direction="south-west", view="low top-down", expected_sha=F0_SHA):
    if hashlib.sha256(source_png).hexdigest()!=expected_sha:
        raise V3ContractError("F0 source SHA did not match expected approved input")
    if Image.open(BytesIO(source_png)).size!=(48,48):raise V3ContractError("input must be 48px FS Actor01 F0")
    if action not in ("RUN","WAITING") or direction not in DIRECTIONS or view not in VIEWS:
        raise V3ContractError("invalid action/view/direction")
    if len(canonical_frames)!=3:raise V3ContractError("Actor pilot requires three stored poses")
    poses=[native48_pose(x) for x in canonical_frames]
    if poses[1]==poses[2]:raise V3ContractError("duplicate motion poses")
    return {
        "description":description, "action":action.lower(),"direction":direction,
        "view":view,"template_id":"mannequin","no_background":True,
        "first_frame":{"type":"base64","format":"png","base64":base64.b64encode(source_png).decode("ascii")},
        "first_frame_keypoints":poses[0],"keypoints":poses,
    }

def validate_provider_frames(frames, *, reference_image):
    """Format gate only; source identity and native runtime require human/engine."""
    if len(frames)!=3:raise V3ContractError("expected exactly three generated frames")
    if any(im.size!=(48,48) for im in frames):raise V3ContractError("bad 48px output size / infographic")
    if any(frames[i].convert("RGBA").tobytes()==frames[j].convert("RGBA").tobytes()
           for i,j in ((0,1),(1,2),(0,2))):raise V3ContractError("duplicate animation frames")
    for im in frames:
        pixels=list(im.convert("RGBA").get_flattened_data())
        opaque=sum(1 for p in pixels if p[3]>0)
        if not 150 <= opaque <= 1350:raise V3ContractError("bad silhouette or opaque background")
    return {"geometry":"PASS","original_f0_stays_immutable":True,
            "generated_first_pose_may_differ_from_f0":True,
            "art_review":"REQUIRED","native_game_exe":"NOT_RUN","formal_seal":"NO"}
