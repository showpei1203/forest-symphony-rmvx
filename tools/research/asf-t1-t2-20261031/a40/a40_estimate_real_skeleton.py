"""A40 true PixelLab skeleton-estimation on A34 45deg chibi source.
No production animation or manual fake pixels. Read back keypoint coordinates.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import sys,json,base64,hashlib
B=Path(r"E:\GameAssetToolLab_20261023");R=B/"A40_CRITICAL_DAMAGE_SKELETON_CONTROL_20261101";R.mkdir(exist_ok=True)
src=B/"A34_FS_BATTLE45_F0_CORRECTION_20261101"/"A34_REAL_BATTLE_45_REFERENCE_MASTER_00.png"
sys.path.insert(0,str(B/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
assert src.exists() and Image.open(src).size==(40,40)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def wr(p,v):p.write_text(json.dumps(v,indent=2,ensure_ascii=False),encoding="utf8")
lock=R/"ESTIMATE_SKELETON_SUBMISSION_LOCK.json"
if lock.exists():print("ESTIMATION_PREVIOUSLY_ATTEMPTED_NO_REPEAT");sys.exit(0)
start=balance(key())
payload={"image":{"type":"base64","base64":"data:image/png;base64,"+base64.b64encode(src.read_bytes()).decode(),"format":"png"}}
log={"stage":"A40","task":"PixelLab /estimate-skeleton, 18 joints from genuine FS battle sprite","source":str(src),"sha256":sha(src),"status":"LOCK_BEFORE_API","balance_before":start}
wr(lock,log)
status,response=api(key(),"/estimate-skeleton",payload)
log.update({"http":status,"response_status":response.get("status"),"response_keys":list(response)})
if status not in (200,201,202):
 log.update({"status":"API_REJECTED_NO_RETRY","error":str(response)[:600]});wr(lock,log);print("REJECT",status,str(response)[:550],flush=True);sys.exit(0)
points=response.get("keypoints")
if not isinstance(points,list):
 log.update({"status":"NO_KEYPOINTS","response":str(response)[:900]});wr(lock,log);print("NO_KEYPOINTS",str(response)[:700],flush=True);sys.exit(0)
wr(R/"A40_ESTIMATED_NATIVE_BATTLE_SKELETON.json",{"source":str(src),"points":points})
after=balance(key())
log.update({"status":"KEYPOINTS_RECEIVED","count":len(points),"usage":response.get("usage"),"balance_after":after})
wr(lock,log)
print("SKELETON_ESTIMATED",len(points),"BAL",after.get("generations"),"USAGE",log["usage"],flush=True)
print("KEYPOINTS",json.dumps(points,ensure_ascii=False),flush=True)
