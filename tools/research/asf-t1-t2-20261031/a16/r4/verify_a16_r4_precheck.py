from pathlib import Path
import hashlib, zipfile, json
d=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\A16_R4_PIXELLAB_PROOF")
names=["T1_A15_attack_02_SOURCE.png","A16_R4_SOURCE_PREVIEW_6X.png","A16_R4_REQUEST_SPEC.json","A16_R4_STATUS.json","a16_r4_pixellab_pilot.py","RUN_ONE_SHOT_SECURE.ps1","A16_R4_HANDOFF.md"]
assert all((d/n).exists() for n in names)
s=json.loads((d/"A16_R4_STATUS.json").read_text(encoding="utf-8"))
assert s["state"]=="BLOCKED_NO_PIXEL_LAB_API_KEY" and not s["network_request_sent"] and not s["spent_credits"]
assert len(list(d.glob("T1_PIXELLAB_ATTACK_??.png")))==0
p=d/"A16_R4_PRIVATE_PRECHECK.zip"
with zipfile.ZipFile(p,"w",zipfile.ZIP_DEFLATED) as z:
 for n in names:z.write(d/n,n)
with zipfile.ZipFile(p) as z:bad=z.testzip();total=len(z.namelist())
assert bad is None
print("ZIP",p,"FILES",total,"SIZE",p.stat().st_size,"CRC_PASS",bad is None,"SHA256",hashlib.sha256(p.read_bytes()).hexdigest())
print("STATUS",s["state"],"T1_SOURCE_SHA256",hashlib.sha256((d/"T1_A15_attack_02_SOURCE.png").read_bytes()).hexdigest())
