"""A16 R4 one-shot PixelLab T1 sword-animation proof.
Prepare mode does not contact billable endpoints. Run mode requires explicit --run
and PIXELLAB_API_KEY environment variable. NEVER print or persist tokens.
Only one generation, four original PNG frames. No automatic retries.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import base64,hashlib,io,json,os,sys,time,argparse,urllib.request,urllib.error,zipfile
ROOT=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_R4_PIXELLAB_PROOF")
SOURCE=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A15_ART_REPAIR\FINAL_CANDIDATE\T1_forest_scout\frames\attack_02.png")
ROOT.mkdir(parents=True,exist_ok=True)
SHA=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
BASE=ROOT/"T1_A15_attack_02_SOURCE.png"
BASE.write_bytes(SOURCE.read_bytes())
img=Image.open(BASE).convert("RGBA")
assert img.size==(96,112),img.size
assert img.getextrema()[3][0]==0 and img.getextrema()[3][1]==255,"expected transparency"
assert all(v in (0,255) for v in img.getchannel("A").getdata()),"Unexpected semi-transparent pixels"
action=("The SAME brown-haired young forest scout in green cape and brown leather armor, "
"same pixel art viewpoint and proportions, performs ONE short sword attack: "
"raise the existing sword by bending the elbow and shoulder, swing the sword from "
"right to left across the body, then follow through. Keep the original hair, face, "
"clothing, hands, cape, feet and sword design. No redesign, no extra arms or "
"weapons, no camera rotation, no effects or background.")
assert len(action)<=500,len(action)
param={"endpoint":"https://api.pixellab.ai/v2/animate-with-text-v3",
"frame_count":4,"no_background":True,"seed":16031,"action":action,
"source_file":str(BASE),"source_sha256":SHA(BASE),"source_size":[96,112],
"pixel_budget":96*112*4,"cost_budget":"one 4-frame API call only; no automatic retries",
"visual_gate":["identity and clothing conserved","sword remains in one hand",
"meaningful shoulder-elbow-wrist changes","pixel-crisp native RGBA",
"believable 4-frame silhouette progression"],
"technical_gate":["four separate RGBA PNG at source 96x112","first frame identical",
"alpha transparency","no ghost objects or extra limbs"],
"max_candidates":3,"run_state":"NOT_RUN"}
(ROOT/"A16_R4_REQUEST_SPEC.json").write_text(json.dumps(param,indent=2,ensure_ascii=False),encoding="utf-8")
preview=Image.new("RGBA",img.size,(224,224,224,255));preview.alpha_composite(img)
preview.convert("RGB").resize((96*6,112*6),Image.Resampling.NEAREST).save(ROOT/"A16_R4_SOURCE_PREVIEW_6X.png")
def log_status(state,extra=None):
    data={"stage":"A16_R4","state":state,"source_sha256":SHA(BASE),
      "reference_png_verified":True,"frame_count":4,
      "official_FS_unchanged":True,"g7_art":"NOT_TESTED",
      "timestamp_local":time.strftime("%Y-%m-%d %H:%M:%S")}
    if extra:data.update(extra)
    (ROOT/"A16_R4_STATUS.json").write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding="utf-8")
def decode_png(obj):
    if isinstance(obj,str):data=obj
    else:data=obj.get("base64")
    if not data:raise ValueError("No base64 response in frame")
    if "," in data and data.startswith("data:"):data=data.split(",",1)[1]
    result=Image.open(io.BytesIO(base64.b64decode(data,validate=True)))
    return result.convert("RGBA")
def generate():
    token=os.environ.get("PIXELLAB_API_KEY") or os.environ.get("PIXELLAB_TOKEN")
    if not token:
        log_status("BLOCKED_NO_PIXEL_LAB_API_KEY",{"network_request_sent":False,"spent_credits":False})
        print("BLOCKED: PIXELLAB_API_KEY absent. No API generation attempted, no credits spent.")
        return
    payload={"first_frame":{"type":"base64","base64":base64.b64encode(BASE.read_bytes()).decode("ascii"),"format":"png"},
             "action":action,"frame_count":4,"no_background":True,"seed":16031}
    req=urllib.request.Request(param["endpoint"],
       data=json.dumps(payload).encode("utf-8"),headers={"Content-Type":"application/json","Authorization":"Bearer "+token},method="POST")
    log_status("SUBMITTING_SINGLE_API_REQUEST",{"network_request_sent":True})
    try:
        with urllib.request.urlopen(req,timeout=110) as response:
            body=response.read(12_000_000)
            obj=json.loads(body)
    except urllib.error.HTTPError as e:
        try: detail=e.read(2000).decode(errors="replace")
        except Exception: detail=""
        log_status("API_HTTP_ERROR",{"http_status":e.code,"server_response_sample":detail[:500]})
        print("API failed HTTP",e.code,"Response",detail[:300]);return
    except Exception as e:
        log_status("API_TRANSPORT_ERROR",{"error_type":type(e).__name__})
        print("API failed:",type(e).__name__);return
    raw=obj.get("images")
    if not raw:
        log_status("UNEXPECTED_API_RESPONSE",{"response_keys":list(obj.keys())[:10]})
        print("API response unexpected. No imagery accepted.")
        return
    try:frames=[decode_png(v) for v in raw]
    except Exception as e:
        log_status("INVALID_FRAME_DATA",{"error_type":type(e).__name__})
        print("FRAME FAIL",type(e).__name__);return
    if len(frames)!=4 or any(f.size!=(96,112) for f in frames):
        log_status("INVALID_FRAME_COUNT_OR_SIZE",{"received":len(frames),"sizes":[f.size for f in frames]})
        print("WRONG COUNT/SIZE",len(frames));return
    import numpy as np
    head=np.asarray(img);new0=np.asarray(frames[0])
    changes=int(np.any(head!=new0,axis=2).sum())
    for i,frame in enumerate(frames):frame.save(ROOT/f"T1_PIXELLAB_ATTACK_{i:02}.png")
    comparison=Image.new("RGBA",(96*4,112))
    for i,f in enumerate(frames):comparison.alpha_composite(f,(96*i,0))
    comparison.save(ROOT/"T1_PIXELLAB_ATTACK_SPRITESHEET_RAW.png")
    metrics={"first_frame_rgba_diff_pixels":changes,"alpha_transparent_ratio":
      [round(sum(1 for px in f.getchannel("A").getdata() if px<255)/ (96*112),4) for f in frames],
      "frame_to_frame_rgba_diffs":[int(np.any(np.asarray(frames[i-1])!=np.asarray(frames[i]),axis=2).sum()) for i in range(1,4)],
      "source_rgba_first_frame_identical":changes==0,
      "api_usage_summary":obj.get("usage") if isinstance(obj.get("usage"),dict) else None}
    (ROOT/"A16_R4_GENERATION_QA.json").write_text(json.dumps(metrics,indent=2,ensure_ascii=False),encoding="utf-8")
    log_status("GENERATED_NEEDS_VISUAL_REVIEW",{"generation_result":metrics,"g7_art":"PENDING HUMAN REVIEW"})
    print("PIXELLAB GENERATED 4 FRAMES. First frame diff",changes,"metrics",metrics["frame_to_frame_rgba_diffs"])
parser=argparse.ArgumentParser()
parser.add_argument("--run",action="store_true",help="Send a billable 4-frame request ONLY if an API key is present")
args=parser.parse_args()
if args.run: generate()
else:
    log_status("READY_BLOCKED_NO_API_TOKEN" if not (os.environ.get("PIXELLAB_API_KEY") or os.environ.get("PIXELLAB_TOKEN")) else "READY_API_KEY_PRESENT",
               {"network_request_sent":False,"spent_credits":False})
    print("PREPARED",BASE,"SHA",SHA(BASE),"token_is_available",bool(os.environ.get("PIXELLAB_API_KEY") or os.environ.get("PIXELLAB_TOKEN")))
