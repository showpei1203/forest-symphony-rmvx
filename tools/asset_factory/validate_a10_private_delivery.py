"""Cold QA for a private A10 dual-production bundle.

Source-of-truth input is an *existing local ZIP* which the owner first
downloads from restricted Drive. Run:
 python -m tools.asset_factory.validate_a10_private_delivery path/to/A10.zip

The public repository never downloads proprietary PNGs, asks for Google
secrets, triggers PixelLab, runs Game.exe, or declares user art approval.
"""
from __future__ import annotations

import argparse
from hashlib import sha256
from io import BytesIO
import json
from pathlib import Path
import zipfile

from PIL import Image
import numpy as np

SCENES = ("ELF_VILLAGE", "FOREST_BRIDGE")
PNG_NAMES = (
    "Authoring_GroundOnly.png",
    "Authoring_CompletePAR.png",
    "Runtime_FullGround.png",
    "Runtime_OcclusionPAR_CANDIDATE.png",
)


def audit_zip(path: str | Path) -> dict:
    path=Path(path)
    digest=sha256(path.read_bytes()).hexdigest()
    evidence={}
    canvases=[]
    with zipfile.ZipFile(path) as z:
        bad=z.testzip()
        if bad is not None:
            raise ValueError(f"CRC bad: {bad}")
        files=set(z.namelist())
        full_report=json.loads(z.read("A10_GATE_REPORT.json"))
        for scene in SCENES:
            prefix=scene+"/"
            inputs={}
            for fname in PNG_NAMES:
                asset=prefix+fname
                if asset not in files:
                    raise ValueError(f"missing: {asset}")
                inputs[fname]=Image.open(BytesIO(z.read(asset)))
                if inputs[fname].size!=(1280,928):
                    raise ValueError(f"invalid FS size: {asset}")
            g=inputs["Authoring_GroundOnly.png"].convert("RGBA")
            complete=inputs["Authoring_CompletePAR.png"].convert("RGBA")
            runtime=np.asarray(inputs["Runtime_FullGround.png"].convert("RGB"),dtype=np.int16)
            rgba=np.asarray(inputs["Runtime_OcclusionPAR_CANDIDATE.png"].convert("RGBA"))
            alpha=rgba[:,:,3]>0
            if not np.array_equal(rgba[:,:,:3][alpha],runtime[alpha]):
                raise ValueError(f"runtime PAR RGB differs from FullGround in {scene}")
            cmp=np.asarray(Image.alpha_composite(g,complete).convert("RGB"),dtype=np.int16)
            delta=np.abs(cmp-runtime)
            if int(delta.max())>1 or int(np.any(delta>1,axis=2).sum())!=0:
                raise ValueError(f"unexpected 8-bit compositing error: {scene}")
            source=json.loads(z.read(prefix+"SCENE_SOURCE_ROLE_AND_QA.json"))
            collision=json.loads(z.read(prefix+"Collision_29x40_CANDIDATE.json"))
            if source["forbidden_source_occlusion_pixels"]!=0:
                raise ValueError(f"ground/deck source leaked into PAR: {scene}")
            selected={x["id"] for x in source["semantic_foreground_objects"]}
            sources={x["object_id"]:x for x in source["source_objects"]}
            for oid in selected:
                o=sources.get(oid)
                if not o or o["role"]!="CONDITIONAL_FRONT":
                    raise ValueError(f"not a declared source foreground: {oid}")
                mpath=prefix+"OCCLUSION_SOURCE_MASKS/"+oid+".png"
                if mpath not in files:
                    raise ValueError(f"missing source-owned mask: {mpath}")
                mask=np.asarray(Image.open(BytesIO(z.read(mpath))).convert("L"))
                fname=o["source_path"].split("/")[-1]
                assetname="SOURCE_KIT/"+fname
                if assetname not in files:
                    raise ValueError(f"missing independent PNG: {fname}")
                independent=Image.open(BytesIO(z.read(assetname))).convert("RGBA")
                if o.get("mirror",False):
                    from PIL import ImageOps
                    independent=ImageOps.mirror(independent)
                src_alpha=np.asarray(independent.getchannel("A"))
                if mask.shape!=src_alpha.shape or np.any(mask>src_alpha):
                    raise ValueError(f"occlusion mask exceeds registered source alpha: {oid}")
            if collision["reachable_count"]<900:
                raise ValueError(f"candidate collision disconnected: {scene}")
            canvases.append(runtime)
            evidence[scene]={
                "placed_source_instances":source["source_independent_object_count"],
                "visible_source_instances":len(source["source_objects"]),
                "source_owned_occ_pixels":int(alpha.sum()),
                "no_forbidden_source_leak":True,
                "max_compositing_channel_delta":int(delta.max()),
                "candidate_reachable_tiles":collision["reachable_count"],
                "user_art":source["user_art"],
                "native_vx":source["native_vx"],
            }
        distinct=int(np.any(canvases[0]!=canvases[1],axis=2).sum())
        if distinct<100_000:
            raise ValueError("two scenes are not substantively distinct")
        for name in ("RUN","WAITING"):
            f="SPRITE_ACTOR01/"+name+"/"
            profile=json.loads(z.read(f+"ACTION_NATIVE_PROFILE.json"))
            if profile["native_stored_frames"]!=3 or profile["frame_geometry"]!=[48,48]:
                raise ValueError(f"Actor frame contract violated: {name}")
            for i in range(1,4):
                path=f+f"ACTOR01_{name}_{i}.png"
                if Image.open(BytesIO(z.read(path))).size!=(48,48):
                    raise ValueError(path)
        if full_report["art_user_pass"] or full_report["native_vx_pass"]:
            raise ValueError("candidate bundle falsely claims approved art/native")
        if full_report["pixel_lab_calls"]!=0:
            raise ValueError("budget record false; this A10 bundle uses no PixelLab")
    return {
        "zip_sha256":digest,"zip_crc":"PASS",
        "source_first_scene_static_QA":"PASS",
        "two_full_maps_distinct_pixel_positions":distinct,
        "scenes":evidence,
        "actor_actions_reused":["RUN","WAITING"],
        "pixel_lab_calls":0,
        "real_native_vx":"NOT_RUN",
        "user_art":"PENDING",
        "formal_seal":"NO",
    }


if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("private_zip")
    print(json.dumps(audit_zip(ap.parse_args().private_zip),indent=2))
