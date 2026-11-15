#!/usr/bin/env python3
"""A35 R7 reversible Godot real tree-trunk light-shadow study from A35 R6.

Inputs owner-only sealed R6 ZIP; modifies *only* an additive separate R7 scene
and new GDScript, with static source / nav / original GPU capture tests.
Never overwrites the R6 main scene or any private art PNGs.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path

BASE="scenes/a35_r6_conifer_hd2d_scene.tscn"
NEW="scenes/a35_r7_shadow_study_scene.tscn"
SCRIPT="scripts/a35_r7_shadow_study.gd"
GROUND="private_assets/ground_only.png"
GROUND_SHA="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
def sha(data):return hashlib.sha256(data).hexdigest()

SOURCE_TEST=r'''extends SceneTree
## Check original source and physical collision strictly unchanged by new shadow study.
const PREV := "res://scenes/a35_r6_conifer_hd2d_scene.tscn"
const NEXT := "res://scenes/a35_r7_shadow_study_scene.tscn"
const GROUND_SHA := "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    if FileAccess.get_sha256("res://private_assets/ground_only.png") != GROUND_SHA:
        push_error("A35 R7 original Ground changed");quit(40);return
    var a: Node2D=load(PREV).instantiate()
    var b: Node2D=load(NEXT).instantiate()
    root.add_child(a);root.add_child(b)
    await process_frame
    var owners1: Node2D = a.get_node("YSort")
    var owners2: Node2D = b.get_node("YSort")
    if owners1.get_child_count()!=owners2.get_child_count():
        push_error("R7 owner count changed");quit(41);return
    var shadow=b.get_node_or_null("ForestLightStudy")
    if shadow==null or shadow.caster_count!=175:
        push_error("R7 should install 175 true tree LightOccluder2D; got "+str(shadow));quit(42);return
    var tree_count:=0
    var owners:=0
    for item in owners1.get_children():
        if item is CharacterBody2D:continue
        var next=owners2.get_node_or_null(NodePath(str(item.name)))
        if next==null or next.position!=item.position:
            push_error("R7 object position changed "+str(item.name));quit(43);return
        if item.get("source_file")!=next.get("source_file") or item.get("source_sha256")!=next.get("source_sha256"):
            push_error("R7 PAR source changed "+str(item.name));quit(44);return
        var ca: CollisionShape2D=item.get_node("Body/Collision")
        var cb: CollisionShape2D=next.get_node("Body/Collision")
        if (ca.shape==null)!=(cb.shape==null) or ca.disabled!=cb.disabled:
            push_error("R7 collision presence changed");quit(45);return
        if ca.shape!=null and ca.shape.get_rect()!=cb.shape.get_rect():
            push_error("R7 collision shape changed");quit(46);return
        if item.get("source_semantic")=="tree":
            tree_count+=1
            if next.get_node_or_null("R7_TrunkLightOccluder")==null:
                push_error("R7 missing LightOccluder2D on "+str(item.name));quit(47);return
        owners+=1
    if owners!=187 or tree_count!=175:
        push_error("R7 owner/tree count mismatch");quit(48);return
    shadow.set_shadows_enabled(true)
    if not shadow.study_light.shadow_enabled:
        push_error("R7 PointLight2D shadow switch failed");quit(49);return
    shadow.set_shadows_enabled(false)
    if shadow.study_light.shadow_enabled:
        push_error("R7 shadow off switch failed");quit(50);return
    print("A35 R7 GODOT SOURCE PASS: 187 PAR unchanged, 175 real LightOccluder2D, Ground/collision immutable, toggle PASS")
    quit(0)
'''

CAPTURE=r'''extends SceneTree
## True Godot GPU SubViewport night scene, identical lamp on/off shadow property.
const SCENE := "res://scenes/a35_r7_shadow_study_scene.tscn"
const W := 1280
const H := 928
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var viewport:=SubViewport.new()
    viewport.size=Vector2i(W,H)
    viewport.disable_3d=true
    viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    for enabled in [false,true]:
        var world: Node2D=load(SCENE).instantiate()
        viewport.add_child(world)
        var actor: CharacterBody2D=world.get_node("YSort/Player")
        actor.get_node("Camera2D").enabled=false
        actor.visible=false
        var fx=world.get_node("HD2DAtmosphere")
        fx.animate=false
        fx.phase=2
        fx.raining=false
        fx._update_phase()
        var study=world.get_node("ForestLightStudy")
        study.set_shadows_enabled(enabled)
        study.set_study_enabled(true)
        for i in range(10):
            await process_frame
        await RenderingServer.frame_post_draw
        var image:Image=viewport.get_texture().get_image()
        if image==null or image.is_empty() or image.get_size()!=Vector2i(W,H):
            push_error("R7 native GPU frame empty");quit(51);return
        var file: String="res://qa_a35/A35_R7_%s_NATIVE.png" % ("SHADOW_ON" if enabled else "SHADOW_OFF")
        if image.save_png(file)!=OK:
            push_error("R7 GPU PNG write failure");quit(52);return
        print("A35 R7 ACTUAL GODOT GPU: "+file)
        world.queue_free()
        await process_frame
    print("A35 R7 real Godot 2D LightOccluder2D GPU shadow ON/OFF CAPTURE 2/2 PASS")
    quit(0)
'''

def build(base_zip,output,work,gdscript):
    work.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(base_zip) as z:
        if z.testzip() is not None:raise ValueError("R6 base CRC FAIL")
        files={p:z.read(p) for p in z.namelist()}
    if sha(files[GROUND])!=GROUND_SHA:raise ValueError("R6 Ground changed")
    previous=files[BASE]
    scene=previous.decode()
    script=gdscript.read_bytes()
    anchor='[ext_resource type="Script" path="res://scripts/a35_r3_hd2d_fx.gd" id="4_atmosphere"]'
    if scene.count(anchor)!=1:raise ValueError("R6 atmosphere external script changed")
    scene=scene.replace(anchor,anchor+'\n[ext_resource type="Script" path="res://'+SCRIPT+'" id="5_study"]')
    scene=scene.replace("load_steps=5","load_steps=6",1)
    scene=scene.replace("FS_A35_R6_ConiferDetailHD2D","FS_A35_R7_TreeShadowStudy",1)
    scene+='\n[node name="ForestLightStudy" type="Node2D" parent="."]\nscript = ExtResource("5_study")\n'
    files[NEW]=scene.encode()
    files[SCRIPT]=script
    files["tests/test_a35_r7_native.gd"]=SOURCE_TEST.encode()
    files["tests/capture_a35_r7_shadow_native.gd"]=CAPTURE.encode()
    nav=files["tests/test_a35_r6_navigation.gd"].decode().replace(
        "res://"+BASE,"res://"+NEW
    ).replace("A35 R6","A35 R7")
    files["tests/test_a35_r7_navigation.gd"]=nav.encode()
    if ("res://"+BASE).encode() not in files["project.godot"]:
        raise ValueError("Expected R6 project main scene missing")
    files["project.godot"]=files["project.godot"].replace(("res://"+BASE).encode(),("res://"+NEW).encode())
    files["docs/A35_R7_HANDOFF.md"]=(
        "# FS A35 R7 real Godot LightOccluder2D study\n"
        "- New separate, reversible R7 scene built from original sealed R6. R6 scene/187 original PAR/Ground untouched.\n"
        "- Installs 175 tree-trunk OccluderPolygon2D/LightOccluder2D nodes under existing trees, plus one test-only PointLight2D near forest edge x260/y785, shadow toggle O.\n"
        "- REAL GPU paired shadow-enabled and shadow-disabled night captures + 187 owner source/collision/navigability tests required before claiming native success.\n"
        "- Prototype shadow polygons cover tree trunks only, NOT tree full alpha canopy; no art acceptance or 3D depth claim.\n"
    ).encode()
    files["docs/A35_R7_FAILURE_LOG.md"]=(
        "# FS A35 R7 shadow study risks\n"
        "- Existing R3 scene's 4 lanterns are more than 160px away from tree roots; simply enabling their shadows produces no visible tree-cast shadow. R7 adds one independent forest-edge test lamp only to new study scene.\n"
        "- Real 2D trunk LightOccluder2D is a shadow geometry study, not realistic canopy-shadow or 3D volumetric light.\n"
        "- No source art or navigation structures modified; new nodes must not alter physical collision.\n"
    ).encode()
    source_report={
        "phase":"A35 R7 source only","previous_R6_SHA":sha(base_zip.read_bytes()),
        "original_R6_scene_SHA":sha(previous),"original_Ground_SHA":GROUND_SHA,
        "added":"175 real shadow caster nodes generated at Godot _ready and one study lamp",
        "native":"NOT_RUN","art":"HOLD"
    }
    files["qa_a35/A35_R7_SOURCE_QA.json"]=(json.dumps(source_report,indent=2)+"\n").encode()
    output.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(output,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for p,b in files.items():z.writestr(p,b)
    with zipfile.ZipFile(output) as z:
        if z.testzip() is not None or z.read(BASE)!=previous or sha(z.read(GROUND))!=GROUND_SHA:
            raise ValueError("R7 integrity failure")
    print(json.dumps({"output":str(output),"members":len(files),"bytes":output.stat().st_size,
         "sha256":sha(output.read_bytes()),"source":source_report},indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--base",required=True)
    p.add_argument("--output",required=True)
    p.add_argument("--work",required=True)
    p.add_argument("--script",required=True)
    a=p.parse_args()
    build(Path(a.base),Path(a.output),Path(a.work),Path(a.script))
