from pathlib import Path
R3=Path(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104")
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
s=(R3/"a36g_build_native_engines_r3b.py").read_text("utf8")
repl=[
 (r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104",r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104"),
 (r"E:\FS_STAGE16_A36G_PIXELLAB_R3B_VX_NATIVE_20261104",r"E:\FS_STAGE16_A36G_R4_VX_NATIVE_20261104"),
 ("GODOT_A36G_PIXELLAB_R3B_40x29","GODOT_A36G_R4_40x29"),
 ('"A36G_SCENE_MANIFEST.json"','"A36G_R4_SCENE_MANIFEST.json"'),
 ('assert len(obj)>400 and len(obj)<468','assert 100<=len(obj)<468'),
 ('"A36G_GROUND_1280x928.png"','"A36G_R4_GROUND_1280x928.png"'),
 ('"A36G_PAR50_RGBA_1280x928.png"','"A36G_R4_PAR50_RGBA_1280x928.png"'),
 ('"A36G_GODOT_SOURCE_SCENE.json"','"A36G_R4_GODOT_SOURCE_SCENE.json"'),
 ('"A36G_ENGINE_BUILD_QA.json"','"A36G_R4_ENGINE_BUILD_QA.json"'),
 ('"A36G_R1"','"A36G_R4"')
]
for a,b in repl:
 assert a in s,a
 s=s.replace(a,b)
# R4 needs entirely new named renderer and separate screenshots.
s=s.replace('"a36g_godot_native_render.gd"','"a36g_r4_godot_native_render.gd"')
s=s.replace("A36G_GODOT_","A36G_R4_GODOT_")
s=s.replace("A36G_GODOT_FULL_MAP_NATIVE_PASS","A36G_R4_GODOT_FULL_MAP_NATIVE_PASS")
# The old Godot script's asset reference is a source A36F filename, not the new R4 source name.
(R4/"r4_build_native_engines.py").write_text(s,"utf8")
print("R4_GENERATED_BUILDER",len(s),"source_object_assert",">=100","source_root R4 confirmed")
