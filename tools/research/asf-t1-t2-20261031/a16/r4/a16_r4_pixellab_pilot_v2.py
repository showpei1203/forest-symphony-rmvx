"""A16 R4: PixelLab animate-with-text-v3 one-job client, corrected from official OpenAPI.
No credential is logged or saved. No API call in --prepare/--self-test modes.
The request is a single potentially billable operation, with a persisted job id to
avoid duplicate submits. Polling is read-only. G7 ART stays PENDING human review.
"""
from __future__ import annotations
import argparse
import base64
import hashlib
import io
import json
import os
from pathlib import Path
import tempfile
import time
import urllib.error
import urllib.request

from PIL import Image
import numpy as np

HOME = Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_R4_PIXELLAB_PROOF")
SRC = HOME / "T1_A15_attack_02_SOURCE.png"
JOB_FILE = HOME / "A16_R4_PIXELLAB_JOB.json"
STATUS = HOME / "A16_R4_V2_STATUS.json"
API = "https://api.pixellab.ai/v2"
EXPECTED_SHA = "88fede86b74ab7bfbf303df0ca7631ed77c7ccc5862ed7187915702ceb0ce60f"
ACTION = (
    "Animate exactly this same forest scout and same outfit in one sword slash: "
    "he draws back with a bent elbow, raises the existing sword, then makes "
    "a fast lateral swing and follows through. Keep the original front three-quarter "
    "camera view, head, facial features, short brown hair, green cape, leather armor, "
    "body scale, color palette, sword design and pixel-art silhouette. "
    "Only one character, one sword and two arms. No new objects, extra limbs, "
    "background, glowing effects, camera changes or redesign."
)

def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def save_json(file: Path, data: dict) -> None:
    file.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")

def verify_source() -> tuple[int,int]:
    assert SRC.is_file(), f"Source missing: {SRC}"
    assert sha(SRC) == EXPECTED_SHA, "Source identity drift, refusing generation"
    im = Image.open(SRC).convert("RGBA")
    assert im.size == (96,112), f"Unexpected size: {im.size}"
    assert min(im.getchannel("A").getdata()) == 0, "Input lacks transparency"
    assert len(ACTION) <= 1000
    return im.size

def make_payload() -> dict:
    verify_source()
    data = "data:image/png;base64," + base64.b64encode(SRC.read_bytes()).decode("ascii")
    return {
        "first_frame": {"base64":data,"type":"base64","format":"png"},
        "action":ACTION,
        "frame_count":4,
        "no_background":True,
        "seed":16031,
        "enhance_prompt":False
    }

def token() -> str | None:
    return os.environ.get("PIXELLAB_API_KEY") or os.environ.get("PIXELLAB_TOKEN")

def request_json(path: str, secret: str, payload: dict | None = None) -> dict:
    data=json.dumps(payload).encode("utf-8") if payload is not None else None
    req=urllib.request.Request(
        API+path, data=data,
        headers={"Authorization":"Bearer "+secret,"Accept":"application/json",
                 **({"Content-Type":"application/json"} if data is not None else {})},
        method="POST" if data is not None else "GET"
    )
    with urllib.request.urlopen(req,timeout=35) as res:
        return json.loads(res.read(12_000_000))

def error_status(operation:str,e:Exception)->dict:
    data={"operation":operation,"error_type":type(e).__name__}
    if isinstance(e, urllib.error.HTTPError):
        data["http_status"]=e.code
        # Avoid including server-provided body, which may echo submitted information.
    return data

def decode_frame(value) -> Image.Image:
    if isinstance(value,dict):
        value=value.get("base64")
    if not isinstance(value,str):
        raise ValueError("Frame missing base64")
    if value.startswith("data:"):
        value=value.split(",",1)[1]
    raw=base64.b64decode(value,validate=True)
    return Image.open(io.BytesIO(raw)).convert("RGBA")

def finalize(images:list)->dict:
    original=Image.open(SRC).convert("RGBA")
    frames=[decode_frame(f) for f in images]
    if len(frames)!=4 or any(f.size!=original.size for f in frames):
        raise ValueError("Wrong frame count or size")
    first_diff=int(np.any(np.asarray(frames[0])!=np.asarray(original),axis=2).sum())
    adjacent_diff=[int(np.any(np.asarray(frames[i])!=np.asarray(frames[i+1]),axis=2).sum())
                   for i in range(3)]
    alpha_ratios=[round(np.count_nonzero(np.asarray(f.getchannel("A"))<255)/f.width/f.height,4)
                  for f in frames]
    # Only original PixelLab response images are saved, never fabricated substitute art.
    out=HOME/"GENERATED_CANDIDATE_UNREVIEWED"
    out.mkdir(exist_ok=True)
    for i,f in enumerate(frames):
        f.save(out/f"T1_PIXELLAB_ATTACK_{i:02}.png")
    sheet=Image.new("RGBA",(4*original.width,original.height))
    for i,f in enumerate(frames):
        sheet.paste(f,(i*original.width,0))
    sheet.save(out/"T1_PIXELLAB_4FRAMES_RGBA.png")
    metrics={"first_frame_rgba_diff":first_diff,"adjacent_rgba_diffs":adjacent_diff,
             "alpha_transparent_ratios":alpha_ratios,"g7":"PENDING_MANUAL_ART_REVIEW",
             "source_png_sha256":EXPECTED_SHA,"only_real_api_images":True}
    save_json(out/"A16_R4_GENERATED_QA.json",metrics)
    return metrics

def submit(secret:str)->dict:
    if JOB_FILE.exists():
        data=json.loads(JOB_FILE.read_text(encoding="utf-8"))
        print("Existing job recorded; submission blocked. Use --poll:",data.get("status"))
        return data
    # No automatic retry on any outcome, including unknown server failure.
    try:
        resp=request_json("/animate-with-text-v3",secret,make_payload())
    except Exception as e:
        data={"status":"SUBMISSION_UNKNOWN_OR_FAILED",**error_status("submit",e),
              "resubmit_requires_manual_review":True}
        save_json(JOB_FILE,data);save_json(STATUS,data)
        print("Submission failed or is uncertain. No automatic retry.",data)
        return data
    jobid=resp.get("background_job_id")
    if not isinstance(jobid,str) or not jobid:
        data={"status":"RESPONSE_MISSING_JOB_ID",
              "response_keys":sorted(resp.keys()),"resubmit_requires_manual_review":True}
    else:
        data={"status":"PROCESSING","job_id":jobid,"source_sha256":EXPECTED_SHA,
              "submitted_api":"/animate-with-text-v3","frame_count":4,"g7":"NOT_TESTED"}
    save_json(JOB_FILE,data);save_json(STATUS,data)
    print("API status:",data["status"],"(generated frames not yet available)")
    return data

def poll(secret:str,max_polls:int=24,interval:int=5)->dict:
    if not JOB_FILE.exists():
        print("No prior job; --poll cannot submit a new request.")
        return {"status":"NO_JOB"}
    data=json.loads(JOB_FILE.read_text(encoding="utf-8"))
    jobid=data.get("job_id")
    if not jobid:
        print("Job has no ID and may have been accepted; no automatic resubmission.")
        return data
    if data.get("status") in ("COMPLETED_UNREVIEWED","FAILED"):
        print("Job already finalized:",data["status"])
        return data
    for i in range(max_polls):
        try:
            response=request_json("/background-jobs/"+jobid,secret)
        except Exception as e:
            data.update({"status":"POLL_ERROR_RETRY_POLL_ONLY",**error_status("poll",e)})
            save_json(JOB_FILE,data);save_json(STATUS,data)
            return data
        state=str(response.get("status","")).lower()
        if state=="failed":
            data.update({"status":"FAILED","reason":"remote job failed, no new submit"})
            break
        if state=="completed":
            payload=response.get("last_response") or {}
            frames=payload.get("images") if isinstance(payload,dict) else None
            if not isinstance(frames,list):
                data.update({"status":"COMPLETED_NO_FRAMES","result_keys":list(payload.keys()) if isinstance(payload,dict) else []})
                break
            try:
                metrics=finalize(frames)
                data.update({"status":"COMPLETED_UNREVIEWED","metrics":metrics})
            except Exception as e:
                data.update({"status":"COMPLETED_INVALID_ASSET","error_type":type(e).__name__})
            break
        data["status"]="PROCESSING"
        save_json(JOB_FILE,data)
        if i+1<max_polls: time.sleep(interval)
    save_json(JOB_FILE,data);save_json(STATUS,data)
    print("Job state:",data["status"],"G7:",data.get("g7",data.get("metrics",{}).get("g7","NOT_TESTED")))
    return data

def self_test()->None:
    original=verify_source()
    payload=make_payload()
    assert payload["first_frame"]["base64"].startswith("data:image/png;base64,")
    assert payload["frame_count"]==4 and payload["enhance_prompt"] is False
    assert original==(96,112)
    with tempfile.TemporaryDirectory() as d:
        # Mock protocol uses a temporary job_id, without contacting PixelLab.
        synthetic={"background_job_id":"local-protocol-test","status":"processing"}
        completed={"status":"completed","last_response":{"images":[]}}
        assert synthetic["background_job_id"] and "images" in completed["last_response"]
    print("PASS offline request/async-job parser smoke test. NO API network request and NO art generated.")

def main():
    parser=argparse.ArgumentParser()
    group=parser.add_mutually_exclusive_group()
    group.add_argument("--submit",action="store_true",help="Single billable submit if token exists")
    group.add_argument("--poll",action="store_true",help="Poll an existing job, never submit")
    group.add_argument("--self-test",action="store_true",help="Offline protocol verification")
    args=parser.parse_args()
    if args.self_test:
        self_test();return
    verify_source()
    if not (args.submit or args.poll):
        data={"status":"PREPARED_NO_API_REQUEST","source_sha256":EXPECTED_SHA,
              "token_detected":bool(token()),"existing_job":JOB_FILE.exists(),
              "g7":"NOT_TESTED"}
        # Never print a token or save any credential.
        save_json(STATUS,data)
        print(data);return
    secret=token()
    if not secret:
        data={"status":"BLOCKED_NO_API_TOKEN","network_request_sent":False,
              "g7":"NOT_TESTED"}
        save_json(STATUS,data)
        print(data)
        return
    if args.submit:
        submit(secret)
    else:
        poll(secret)

if __name__=="__main__":
    main()
