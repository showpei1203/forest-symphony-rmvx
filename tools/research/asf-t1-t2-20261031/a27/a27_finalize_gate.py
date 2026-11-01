from pathlib import Path
import json,zipfile,hashlib
R=Path(r"E:\GameAssetToolLab_20261023\A27_PMD6_FS_CHIBI_ACTIONS_20261101")
p=R/"A27_CURRENT_QA.json"
d=json.loads(p.read_text(encoding="utf8"))
d["provider_quota_after_A27"]={"generations":1854.0,"total":2000.0,"source":"live /v2/balance readback"}
d["A27_usage"]={"actual":6,"from_balance":1860.0,"to_balance":1854.0,
"pmd_new_actions_gen":4,"fs_two_animation_gen":2,"note":"1 generation each, no re-post"}
d["art_gate_detail"]={
"PMD_idle_walk":"PASS from user A26, unchanged approved",
"PMD_attack":"NEW CANDIDATE: raw detached volcanic rocks filtered 51/47/63 pixels in middle frames",
"PMD_cast":"NEW CANDIDATE: compact magic gesture, no rejected geometry",
"PMD_hurt":"NEW CANDIDATE: raw detached black blobs filtered 22/38/38 pixels",
"PMD_death":"NEW CANDIDATE: visually collapses, final provider bbox width33 against native Faint cell width32, 1 clipped pixel; NATIVE_GEOMETRY_FAIL",
"FS_idle":"NEW ANIMATION CANDIDATE: 5 frames, head/body remains chibi, all bottom border clear",
"FS_attack":"NEW ANIMATION VISUAL FAIL: no sufficiently legible sword-swing action, mostly hair/cape/forearm shifts; don't propagate to SBS"}
d["next_step"]="Use approved FS art and provider skeleton/control key poses with visible short sword slash, no 1:3 proportion drift; fix Faint 1 pixel geometry with native lossless manner before formal XML; create eight-direction PMD actual body-consistent data."
p.write_text(json.dumps(d,ensure_ascii=False,indent=2),encoding="utf8")
handoff=R/"A27_CURRENT_HANDOFF.md"
text=handoff.read_text(encoding="utf8")
text+="""\n## Final Visual Gate and Quota Readback (same stage)
- New FS Idle native 40x40: 5 real frames, chibi ratio visually stable and no bottom-edge clipping, user review pending.
- New FS Attack native 40x40: TECHNICAL PASS but VISUAL FAIL. No discernible sword slash or satisfactory blade continuity; action mostly arm/hair/cape shifts. DO NOT import to formal Tankentai/SBS. Research skeleton/key-pose control rather than repeat same generic text animation.
- PMD Attack / Hurt generated detached rock fragments. A27 largest-8-neighbor-component filtering removes these in clean candidates, leaving true provider raw outputs intact. User visual gate pending.
- PMD Faint native frame width32 vs final generated bbox width33; 1 pixel would be clipped. FAIL CLOSED for pixel-perfect native Faint until repaired.
- A27 provider charges verified 4 PMD actions at 1 generation each + 2 FS actions at 1 each = 6; account 1860 -> 1854 of 2000. No retries.
- Preserve approved A25 volcanic PMD and A26 FS native 1:1 character and A26 PMD Idle/Walk as sealed visual baselines.
"""
handoff.write_text(text,encoding="utf8")
archive=R/"A27_PRIVATE_PMD6_FS2_AND_XML_GEOMETRY.zip"
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED) as z:
 for f in sorted(R.rglob("*")):
  if f.is_file() and f!=archive:z.write(f,f.relative_to(R))
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 print("ZIP_FILES",len(z.namelist()))
print("A27_ZIP_SHA",sha(archive),"A27_ZIP_BYTES",archive.stat().st_size)
print("STATUS",json.dumps(d["art_gate_detail"],ensure_ascii=False))
