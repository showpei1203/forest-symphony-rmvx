#!/usr/bin/env python3
"""A35 R8 R3: reversible northeast-grove-only Godot lighting from sealed R8 R2.

All existing ground pixels, 187 PAR objects, 175 trunks/canopies and physics
unchanged. Code/docs on GitHub, original artwork in private Drive ZIP only.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
OLD="scenes/a35_r8_r2_light_balance_scene.tscn"
NEW="scenes/a35_r8_r3_grove_balance_scene.tscn"
SCRIPT="scripts/a35_r8_r3_grove_light.gd"
GROUND_SHA="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
def sha(b):return hashlib.sha256(b).hexdigest()

SOURCE=r'''extends SceneTree
const OLD := "res://scenes/a35_r8_r2_light_balance_scene.tscn"
const NEW := "res://scenes/a35_r8_r3_grove_balance_scene.tscn"
const GROUND_SHA := "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    if FileAccess.get_sha256("res://private_assets/ground_only.png") != GROUND_SHA:
        push_error("R8 R3 Ground drift");quit(30);return
    var base:Node2D=load(OLD).instantiate()
    var newer:Node2D=load(NEW).instantiate()
    root.add_child(base);root.add_child(newer)
    await process_frame
    var a:Node2D=base.get_node("YSort")
    var b:Node2D=newer.get_node("YSort")
    if a.get_child_count()!=b.get_child_count():
        push_error("R8 R3 owner count");quit(31);return
    var owners:=0
    var trees:=0
    for src in a.get_children():
        if src is CharacterBody2D:continue
        var dst=b.get_node_or_null(NodePath(str(src.name)))
        if dst==null or dst.position!=src.position or src.source_file!=dst.source_file or src.source_sha256!=dst.source_sha256:
            push_error("R8 R3 PAR mutated: "+str(src.name));quit(32);return
        var ca:CollisionShape2D=src.get_node("Body/Collision")
        var cb:CollisionShape2D=dst.get_node("Body/Collision")
        if (ca.shape==null)!=(cb.shape==null) or ca.disabled!=cb.disabled:
            push_error("R8 R3 collision presence changed");quit(33);return
        if ca.shape!=null and ca.shape.get_rect()!=cb.shape.get_rect():
            push_error("R8 R3 collision geometry changed");quit(34);return
        if src.source_semantic=="tree":
            trees+=1
            if dst.get_node_or_null("R7_TrunkLightOccluder")==null or dst.get_node_or_null("R8_CanopyLightOccluder")==null:
                push_error("R8 R3 lost physical occluder");quit(35);return
        owners+=1
    if owners!=187 or trees!=175:
        push_error("R8 R3 owner/tree mismatch");quit(36);return
    var ctrl=newer.get_node("ForestLightStudy")
    if ctrl.caster_count!=175 or ctrl.canopy_caster_count!=175 or ctrl.canopy_errors!=0:
        push_error("R8 R3 canopy count failure");quit(37);return
    ctrl.set_study_enabled(true)
    ctrl.set_shadows_enabled(true)
    ctrl.set_fill_fraction(0.24)
    ctrl.set_multi_light_enabled(true)
    if ctrl.secondary_key.position.distance_to(Vector2(805,90))>0.01:
        push_error("R8 R3 wrong grove light position");quit(38);return
    if absf(ctrl.secondary_key.energy+ctrl.secondary_fill.energy-0.29)>0.0002:
        push_error("R8 R3 wrong total grove energy");quit(39);return
    if ctrl.secondary_fill.shadow_enabled or not ctrl.secondary_key.shadow_enabled:
        push_error("R8 R3 fill/shadow properties");quit(40);return
    ctrl.set_multi_light_enabled(false)
    if ctrl.secondary_key.enabled or ctrl.secondary_fill.enabled or ctrl.secondary_key.energy!=0.0 or ctrl.secondary_fill.energy!=0.0:
        push_error("R8 R3 OFF light ghost regression");quit(41);return
    ctrl.set_grove_energy(0.0)
    ctrl.set_multi_light_enabled(true)
    if ctrl.secondary_key.enabled or ctrl.secondary_fill.enabled:
        push_error("R8 R3 zero energy should disable light");quit(42);return
    print("A35 R8 R3 GODOT NATIVE PASS: 187 PAR, 175 trunk+canopy occluders, Ground/collision immutable, relocated 805x90 grove lamp and zero-ghost toggle")
    quit(0)
'''

GPU=r'''extends SceneTree
## Four true Godot GPU frames with same ambient phase and camera, actor hidden.
const OLD := "res://scenes/a35_r8_r2_light_balance_scene.tscn"
const NEW := "res://scenes/a35_r8_r3_grove_balance_scene.tscn"
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var vp:=SubViewport.new()
    vp.size=Vector2i(1280,928)
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var cases:Array[Dictionary]=[
        {"scene":OLD, "label":"R2_FILL_ONLY", "multi":false},
        {"scene":NEW, "label":"R3_OFF_CONTROL", "multi":false},
        {"scene":NEW, "label":"R3_GROVE_ON", "multi":true},
        {"scene":OLD, "label":"R2_HOUSE_GLARE", "multi":true}
    ]
    for item in cases:
        var world:Node2D=load(item["scene"]).instantiate()
        vp.add_child(world)
        var player=world.get_node("YSort/Player")
        player.get_node("Camera2D").enabled=false
        player.visible=false
        var atmosphere=world.get_node("HD2DAtmosphere")
        atmosphere.animate=false
        atmosphere.phase=2
        atmosphere.raining=false
        atmosphere._update_phase()
        var study=world.get_node("ForestLightStudy")
        study.set_study_enabled(true)
        study.set_shadows_enabled(true)
        study.set_canopy_enabled(true)
        study.set_fill_fraction(0.24)
        study.set_multi_light_enabled(bool(item["multi"]))
        for i in range(18):
            await process_frame
        await RenderingServer.frame_post_draw
        var picture:Image=vp.get_texture().get_image()
        if picture==null or picture.is_empty() or picture.get_size()!=Vector2i(1280,928):
            push_error("A35 R8 R3 empty native capture");quit(51);return
        var file:String="res://qa_a35/A35_R8_R3_%s_NATIVE.png" % str(item["label"])
        if picture.save_png(file)!=OK:
            push_error("A35 R8 R3 native PNG write failed");quit(52);return
        print("A35 R8 R3 ACTUAL GODOT GPU ",file)
        world.queue_free()
        await process_frame
    print("A35 R8 R3 four original Godot GPU controls 4/4 PASS")
    quit(0)
'''

def build(base:Path,out:Path,script:Path,work:Path):
    work.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(base) as z:
        if z.testzip() is not None:raise ValueError("R8 R2 base CRC failed")
        f={p:z.read(p) for p in z.namelist()}
    if sha(f["private_assets/ground_only.png"])!=GROUND_SHA:
        raise ValueError("Original Ground changed")
    oldscene=f[OLD]
    text=oldscene.decode()
    old_ref='[ext_resource type="Script" path="res://scripts/a35_r8_r2_light_balance.gd" id="5_study"]'
    new_ref='[ext_resource type="Script" path="res://'+SCRIPT+'" id="5_study"]'
    if text.count(old_ref)!=1:raise ValueError("Expected R2 script ref missing")
    newscene=text.replace(old_ref,new_ref)
    newscene=newscene.replace("FS_A35_R8_R2_BalancedForestLights","FS_A35_R8_R3_GroveLighting",1)
    if newscene==text:raise ValueError("R3 scene not created")
    f[NEW]=newscene.encode()
    f[SCRIPT]=script.read_bytes()
    f["tests/test_a35_r8_r3_native.gd"]=SOURCE.encode()
    f["tests/capture_a35_r8_r3_native.gd"]=GPU.encode()
    nav=f["tests/test_a35_r8_r2_navigation.gd"].decode()
    if "res://"+OLD not in nav:raise ValueError("Source native nav R2 scene absent")
    nav=nav.replace("res://"+OLD,"res://"+NEW)
    nav=nav.replace("A35 R8 R2","A35 R8 R3")
    f["tests/test_a35_r8_r3_navigation.gd"]=nav.encode()
    original_main=f["project.godot"]
    f["project.godot"]=original_main.replace(("res://"+OLD).encode(),("res://"+NEW).encode())
    if original_main==f["project.godot"]:raise ValueError("project.godot main scene unchanged")
    f["tools/a35_r8_r3_build.py"]=Path(__file__).read_bytes()
    details={"phase":"A35 R8 R3 SOURCE","base_sha256":sha(base.read_bytes()),
             "original_R2_scene_sha256":sha(oldscene),"ground_sha256":GROUND_SHA,
             "candidate_scene":NEW,"light_position":[805,90],
             "secondary_energy":0.29,"texture_scale":2.20,
             "expected_owner_count":187,"trunk_canopy_count":175,
             "native":"NOT_RUN","art":"HOLD"}
    f["qa_a35/A35_R8_R3_SOURCE_QA.json"]=(json.dumps(details,indent=2)+"\n").encode()
    f["docs/A35_R8_R3_SOURCE_HANDOFF.md"]=(
       "# A35 R8 R3 | relocated northeast grove lighting\n"
       "- From sealed R8 R2, preserves all original PAR Ground/light-caster source bytes.\n"
       "- Secondary PointLight2D moves 1090,280 to 805,90, lowers total energy .66 to .29 and radius scale 3.4 to 2.2.\n"
       "- 4 original real Godot GPU comparisons and physical nav required before approval. 0-delta OFF control is mandatory.\n"
       "- Right cottage must not gain pixels from optional grove light. Forest must still show measurable light effect.\n"
       "- Original R8 R2 scene remains byte-identical; ART HOLD pending native rendering.\n"
    ).encode()
    f["docs/A35_R8_R3_FAILURE_LOG.md"]=(
       "# A35 R8 R3 source failure register\n"
       "- Original R8 R2 northeast light at 1090,280 made east cottage conspicuously bright. New candidate moves north/west, reduces power and radius.\n"
       "- MUST check complete OFF control at pixel accuracy because zero-energy PointLight2D still rendered ghost pixels in R2.\n"
       "- Unshadowed fill approximates translucency; not physical alpha transmission, soft shadow map or 3D DOF.\n"
    ).encode()
    with zipfile.ZipFile(out,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for p,b in f.items():z.writestr(p,b)
    with zipfile.ZipFile(out) as z:
        if z.testzip() is not None or z.read(OLD)!=oldscene or sha(z.read("private_assets/ground_only.png"))!=GROUND_SHA:
            raise ValueError("R8 R3 preservation/CRC failed")
    print(json.dumps({"path":str(out),"members":len(f),"bytes":out.stat().st_size,
                      "sha256":sha(out.read_bytes()),"source":details},indent=2))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    for key in ("base","output","script","work"):p.add_argument("--"+key,required=True)
    a=p.parse_args()
    build(Path(a.base),Path(a.output),Path(a.script),Path(a.work))
