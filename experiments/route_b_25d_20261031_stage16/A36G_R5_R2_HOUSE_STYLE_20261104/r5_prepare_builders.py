from pathlib import Path
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
R5=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
s=(R4/"r4_r3_build_native_engines.py").read_text("utf8")
rs=[
 (r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104",r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104"),
 (r"E:\FS_STAGE16_A36G_R4_R3_VX_NATIVE_20261104",r"E:\FS_STAGE16_A36G_R5_VX_NATIVE_20261104"),
 ("GODOT_A36G_R4_R3_40x29","GODOT_A36G_R5_40x29"),
 ("A36G_R4_SCENE_MANIFEST.json","A36G_R5_SCENE_MANIFEST.json"),
 ("A36G_R4_GROUND_1280x928.png","A36G_R5_GROUND_1280x928.png"),
 ("A36G_R4_PAR50_RGBA_1280x928.png","A36G_R5_PAR50_RGBA_1280x928.png"),
 ("A36G_R4_GODOT_SOURCE_SCENE.json","A36G_R5_GODOT_SOURCE_SCENE.json"),
 ("A36G_R4_GODOT_","A36G_R5_GODOT_"),
 ("a36g_r4_r3_godot_native_render.gd","a36g_r5_godot_native_render.gd"),
 ("A36G_R4_R3_ENGINE_BUILD_QA.json","A36G_R5_ENGINE_BUILD_QA.json")
]
for a,b in rs:
 assert a in s,a
 s=s.replace(a,b)
s=s.replace('"A36G_R4"','"A36G_R5"')
(R5/"r5_build_native_engines.py").write_text(s,"utf8")
r=(R4/"r4_r3_capture_native.py").read_text("utf8")
cap=[
 (r"E:\FS_STAGE16_A36G_R4_R3_VX_NATIVE_20261104",r"E:\FS_STAGE16_A36G_R5_VX_NATIVE_20261104"),
 (r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104\R4_R3_VX_CAPTURES",r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104\R5_VX_CAPTURES")
]
for a,b in cap:
 assert a in r,a
 r=r.replace(a,b)
(R5/"R5_VX_CAPTURES").mkdir(exist_ok=True)
(R5/"r5_capture_native.py").write_text(r,"utf8")
# Copy independent native cold builder without modifying its verified implementation.
cold=(R4/"r4_r3_native_cold_verify.py").read_text("utf8")
repl=[
 (r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104",r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104"),
 (r"E:\FS_STAGE16_A36G_R4_R3_VX_NATIVE_20261104",r"E:\FS_STAGE16_A36G_R5_VX_NATIVE_20261104"),
 (r"E:\FS_STAGE16_A36G_R4_R3_VX_COLD_20261104",r"E:\FS_STAGE16_A36G_R5_VX_COLD_20261104"),
 ("A36G_R4_R3_NATIVE_INDEPENDENT_COLD_544x416.png","A36G_R5_NATIVE_INDEPENDENT_COLD_544x416.png"),
 ("A36G_R4_R3_NATIVE_VX_COLD_REBUILD_QA.json","A36G_R5_NATIVE_VX_COLD_REBUILD_QA.json"),
 ('"stage":"A36G_R4_R3"','"stage":"A36G_R5"')]
for a,b in repl:
 assert a in cold,a
 cold=cold.replace(a,b)
(R5/"r5_cold_verify.py").write_text(cold,"utf8")
print("R5_REBUILD_CAPTURE_COLD_SCRIPTS_PREPARED")
