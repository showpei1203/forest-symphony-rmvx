from pathlib import Path
import zipfile,hashlib,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\T1T2_NEW_PIPELINE")
engine=json.loads((root/"R2_GODOT_NATIVE_EVIDENCE.json").read_text(encoding="utf8"))
pixels=json.loads((root/"R2_NATIVE_PIXEL_PARITY_QA.json").read_text(encoding="utf8"))
neg=json.loads((root/"R2_NEGATIVE_FAILCLOSED_QA.json").read_text(encoding="utf8"))
assert engine["t1_count"]==6 and engine["t2_count"]==5 and len(engine["captures"])==2
assert pixels["all_pixel_exact"] and pixels["pairs"]==22
assert neg["PASS_FAILCLOSED"]
a={}
for case,expected in (("T1_hero",(6,24)),("T2_monster",(5,20))):
    p=root/case/"r2"
    man=json.loads((p/"clips.json").read_text())
    exp=json.loads((p/"engine_all"/"engine-export.json").read_text())
    assert len(man["clips"])==expected[0] and len(man["frames"])==expected[1]
    assert (p/"compiled_strict"/"animation-clips.json").exists()
    assert (p/"engine_all"/"godot").is_dir()
    a[case]={"actions":expected[0],"frames":expected[1],"compiled":"ASF STRICT 0 WARNINGS","export":"all: Aseprite+Godot SpriteFrames+Sprite3D"}
test={"status":"R2_POSTPROCESS_ASF_NATIVE_GODOT_PASS_MASTER_TO_VIDEO_BLOCKED",
      "source_original":"AI previously painted multi-frame informational poster; extracted existing frames; quantization=32 colors per action; no independent master image-to-video",
      "strict_qa":a,"godot":{"engine":engine["engine"],"clips":11,"frames_compared":pixels["pairs"],"pixel_exact":pixels["all_pixel_exact"],"clips_timeline_changes":11},
      "negative_test":{"T1_missing_attack_02":neg["PASS_FAILCLOSED"],"published_on_missing_input":neg["published"]},
      "failures":["G1_IMAGEGEN_STANDALONE_MASTER_FAIL_OUTPUT_POSTER","G3_AI_VIDEO_ROUTE_NOT_CONFIGURED","G7_T1_ATTACK_NOT_SWORD_SWING","G7_T1_JUMP_NOT_OBVIOUSLY_AIRBORNE"],
      "scope":{"ASF_codegen_motion":False,"FS_style_human_acceptance":False,"VX_import_on_these_candidates":False,"source_sealed_unchanged":True}}
(root/"R2_FORMAL_QA.json").write_text(json.dumps(test,ensure_ascii=False,indent=2),encoding="utf8")
notes="""# ASF R2 / T1-T2 runtime handoff 2026-10-31
SUCCESS: 11 clips, 44 source AI-painted frames (32-colour per action), ASF build_animation_clips.py --strict (T1=6/24, T2=5/20) zero warnings. ASF export_engine.py target all: Aseprite, Godot SpriteFrames, Sprite3D, 1 atlas per case. Godot 4.7.2 real GPU OpenGL Radeon RX6700XT ran 11 clips, 2 captures, 22 pixel sample comparisons against the matching source frame: zero RGB difference in all 22. 11/11 clip ROIs changed across snapshots. Fail closed negative missing attack_02: CLI exit=1/no output.
IMPORTANT FIX: Earlier palette16 transfer decoder incorrectly cut flattened panorama rows; discarded. R2 per-action palette32 transfer splits each original frame BEFORE concatenation; 44 decoded images compared by SHA256(RGBA bytes) to the locally quantized source. All 44 PASS.
STILL BLOCKED: image_gen repeatedly generated composite infographic rather than standalone transparent sprite master; no genuine one-master-to-I2V action-generation route (ASF forge_doctor 2026-10-31 video:none). Existing 44 frames are AI-painted poses extracted from the earlier poster, so passing tool's frame compiler is NOT AI-action-generation success. T1 sword-attack and jump visual standards FAIL; T2 needs human FS style approval. Actual VX import of these new characters NOT RUN.
REMOTE LOCAL PRIVATE BUNDLE: see R2_ASF_WINDOWS_PRIVATE_PACKAGE_20261031.zip; includes original derivative frames, actual ASF engine output and screenshots. Do not push private art to public GitHub. Prior sealed FS/R17/Tankentai/LPC untouched.
NEXT: fix single Master generation and genuine image-to-video. First T1 idle from one identity master, then walk/attack/hurt; T2. Keep G1-G7 separate. Continue handoff.
"""
(root/"CURRENT_HANDOFF_R2.md").write_text(notes,encoding="utf8")
items=[]
for case in ("T1_hero","T2_monster"):
    for f in (root/case/"r2").rglob("*"):
        if f.is_file() and ".godot" not in f.parts:
            items.append((f,f.relative_to(root).as_posix()))
for name in ("R2_GODOT_NATIVE_EVIDENCE.json","R2_NATIVE_GODOT_A.png","R2_NATIVE_GODOT_B.png","R2_NATIVE_PIXEL_PARITY_QA.json","R2_NEGATIVE_FAILCLOSED_QA.json","R2_FORMAL_QA.json","CURRENT_HANDOFF_R2.md","decode_full_r2.py","make_manifests.py","verify_r2_pixels.py","capture_r2_godot.gd","negative_test_r2.py","project.godot"):
    items.append((root/name,name))
zpath=root/"R2_ASF_WINDOWS_PRIVATE_PACKAGE_20261031.zip"
with zipfile.ZipFile(zpath,"w",zipfile.ZIP_DEFLATED,compresslevel=7) as z:
    for f,rel in items:z.write(f,rel)
with zipfile.ZipFile(zpath) as z:
    assert z.testzip() is None
inv={"path":str(zpath),"bytes":zpath.stat().st_size,"count":len(items),"sha256":hashlib.sha256(zpath.read_bytes()).hexdigest(),"zip_crc":"PASS","visibility":"PRIVATE_WINDOWS_LOCAL_NOT_GITHUB"}
(root/"R2_REMOTE_PACKAGE_INVENTORY.json").write_text(json.dumps(inv,indent=2),encoding="utf8")
print(json.dumps(inv,indent=2))