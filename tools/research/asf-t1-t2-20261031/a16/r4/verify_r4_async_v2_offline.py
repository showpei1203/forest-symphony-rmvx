"""No-network end-to-end smoke for R4 v2: mock one submit and completed job, discard fake frames.
Also validate request field names against LIVE official OpenAPI, no token required.
This test never uses billing and saves synthetic frames only in TemporaryDirectory.
"""
from pathlib import Path
import importlib.util, tempfile, io, base64, json, urllib.request, hashlib
from PIL import Image

base=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_R4_PIXELLAB_PROOF")
script=base/"a16_r4_pixellab_pilot_v2.py"
spec=importlib.util.spec_from_file_location("r4",script)
m=importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
payload=m.make_payload()
url="https://api.pixellab.ai/v2/openapi.json"
schemas=json.load(urllib.request.urlopen(url,timeout=15))["components"]["schemas"]
model=schemas["AnimateWithTextV3Request"]
allowed=set(model["properties"])
assert all(key in allowed for key in payload),("unsupported keys",set(payload)-allowed)
assert set(model["required"]).issubset(payload.keys())
assert payload["frame_count"]==4
assert payload["enhance_prompt"] is False # do not add prompt-enhancement charge
ref=schemas["Base64Image"]
assert set(ref["required"]).issubset(set(payload["first_frame"]))
print("LIVE OFFICIAL OPENAPI: PAYLOAD KEYS PASS",sorted(payload.keys()))
im=Image.open(m.SRC).convert("RGBA")
frames=[]
for i in range(4):
    f=im.copy()
    if i:
        f.putpixel((1,1),(20*i,0,0,255))
    bio=io.BytesIO();f.save(bio,format="PNG")
    frames.append({"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(bio.getvalue()).decode("ascii"),"format":"png"})
calls=[]
def fake_request(path,secret,payload=None):
    calls.append((path, bool(payload)))
    if path=="/animate-with-text-v3":
        assert payload["frame_count"]==4
        return {"background_job_id":"offline-test-id","status":"processing"}
    assert path=="/background-jobs/offline-test-id"
    return {"status":"completed","last_response":{"images":frames}}
m.request_json=fake_request
with tempfile.TemporaryDirectory() as tmp:
    m.HOME=Path(tmp)
    m.JOB_FILE=m.HOME/"job.json"
    m.STATUS=m.HOME/"status.json"
    s=m.submit("OFFLINE_FAKE_NEVER_TO_NETWORK")
    assert s["status"]=="PROCESSING"
    s2=m.poll("OFFLINE_FAKE_NEVER_TO_NETWORK",max_polls=1,interval=0)
    assert s2["status"]=="COMPLETED_UNREVIEWED",s2
    assert s2["metrics"]["first_frame_rgba_diff"]==0
    assert len(list((m.HOME/"GENERATED_CANDIDATE_UNREVIEWED").glob("T1_PIXELLAB_ATTACK_??.png")))==4
    assert calls==[("/animate-with-text-v3",True),("/background-jobs/offline-test-id",False)]
    # Idempotency: a second submit must not send another request
    m.submit("OFFLINE_FAKE_NEVER_TO_NETWORK")
    assert len(calls)==2
    print("MOCK ASYNC END-TO-END PASS: ONE SUBMISSION, ONE POLL, 4 RGBA frames, 0 repeat.")
print("TEMPORARY IMAGES DELETED. NO PIXELLAB API TOKEN. NO REAL ART GENERATED.")
