"""A30: estimate the 18-bone skeleton on the ACTUAL unarmed 45 visual candidate, compare with original actor01 3-frame walk source."""
from pathlib import Path
from PIL import Image
import sys,json,base64,hashlib
BASE=Path(r"E:\GameAssetToolLab_20261023")
R=BASE/"A30_FS_SOURCE_MOTION_RIG_LOOP_20261101"
SRC=BASE/"A29_FS45_UNARMED_PIXELLAB_LOOP_20261101"/"A29_SELECTED_SE_VISUAL_45_UNARMED_40.png"
assert SRC.exists() and Image.open(SRC).size==(40,40)
sys.path.insert(0,str(BASE/"A23_PMD_ACTOR_PIXELLAB_SOURCEFIRST"))
from a23_one_paid_spritesheet_trial import api,key,balance
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
LOCK=R/"A30_SOURCE_BONE_ESTIMATE_LOG.json"
if LOCK.exists():
 print("ALREADY_LOCKED_NO_REPEAT");sys.exit(0)
before=balance(key())
LOCK.write_text(json.dumps({"status":"PREPOST","source_sha":sha(SRC),"before":before},indent=2),encoding="utf8")
body={"image":{"type":"base64","base64":base64.b64encode(SRC.read_bytes()).decode(),"format":"png"}}
status,data=api(key(),"/estimate-skeleton",body)
log={"http":status,"source_sha":sha(SRC),"before":before}
if status!=200:
 log.update({"status":"REJECTED","brief":str(data)[:400]})
else:
 kp=data.get("keypoints")
 if isinstance(kp,list) and len(kp)>=15:
  (R/"A30_ACTUAL_UNARMED_18_BONES.json").write_text(json.dumps(kp,ensure_ascii=False,indent=2),encoding="utf8")
  log.update({"status":"18_JOINTS_OK","bones":len(kp),"after":balance(key())})
  print("BONES",[(i["label"],round(i["x"],3),round(i["y"],3)) for i in kp])
 else:log.update({"status":"UNEXPECTED","keys":list(data)})
LOCK.write_text(json.dumps(log,ensure_ascii=False,indent=2),encoding="utf8")
print("RESULT",log["status"],"BALANCE",log.get("after",{}).get("generations"),flush=True)
