#!/usr/bin/env python3
"""FS A35 R8 R2: additive, full Godot multi-light/fill study from sealed R8.

No original Ground/PAR sprites or historical scenes overwritten. Source has
real Godot native tests, reversible light study and GPU four-frame capture.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
OLD="scenes/a35_r8_canopy_shadow_scene.tscn"
NEW="scenes/a35_r8_r2_light_balance_scene.tscn"
SCRIPT="scripts/a35_r8_r2_light_balance.gd"
GROUND="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
def sha(x):return hashlib.sha256(x).hexdigest()

NATIVE=r'''extends SceneTree
const OLD := "res://scenes/a35_r8_canopy_shadow_scene.tscn"
const NEW := "res://scenes/a35_r8_r2_light_balance_scene.tscn"
const GROUND_SHA := "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
    if FileAccess.get_sha256("res://private_assets/ground_only.png") != GROUND_SHA:
        push_error("R8 R2 Ground hash mismatch");quit(31);return
    var base: Node2D=load(OLD).instantiate()
    var candidate: Node2D=load(NEW).instantiate()
    root.add_child(base);root.add_child(candidate)
    await process_frame
    var old_layer: Node2D=base.get_node("YSort")
    var new_layer: Node2D=candidate.get_node("YSort")
    if old_layer.get_child_count()!=new_layer.get_child_count():
        push_error("R8 R2 owner count drift");quit(32);return
    var changed:=0
    var owners:=0
    var tree_count:=0
    for src in old_layer.get_children():
        if src is CharacterBody2D:continue
        var dst=new_layer.get_node_or_null(NodePath(str(src.name)))
        if dst==null or dst.position!=src.position or dst.source_file!=src.source_file or dst.source_sha256!=src.source_sha256:
            push_error("R8 R2 original PAR moved or mutated "+str(src.name));quit(33);return
        var ca:CollisionShape2D=src.get_node("Body/Collision")
        var cb:CollisionShape2D=dst.get_node("Body/Collision")
        if (ca.shape==null)!=(cb.shape==null) or ca.disabled!=cb.disabled:
            push_error("R8 R2 collision presence changed");quit(34);return
        if ca.shape!=null and ca.shape.get_rect()!=cb.shape.get_rect():
            push_error("R8 R2 shape geometry changed");quit(35);return
        if src.source_semantic=="tree":
            if dst.get_node_or_null("R7_TrunkLightOccluder")==null or dst.get_node_or_null("R8_CanopyLightOccluder")==null:
                push_error("R8 R2 lost existing tree LightOccluder2D");quit(36);return
            tree_count+=1
        owners+=1
    if owners!=187 or tree_count!=175:
        push_error("R8 R2 tree/owner count changed");quit(37);return
    var layer=candidate.get_node("ForestLightStudy")
    if layer.caster_count!=175 or layer.canopy_caster_count!=175 or layer.canopy_errors!=0:
        push_error("R8 R2 expected 175 trunk and 175 canopy blockers");quit(38);return
    if layer.study_light==null or layer.fill_light==null or layer.secondary_key==null or layer.secondary_fill==null:
        push_error("R8 R2 real Godot PointLight2D objects missing");quit(39);return
    layer.set_study_enabled(true)
    layer.set_shadows_enabled(true)
    layer.set_canopy_enabled(true)
    layer.set_fill_fraction(0.24)
    layer.set_multi_light_enabled(true)
    if not layer.study_light.shadow_enabled or layer.fill_light.shadow_enabled or not layer.secondary_key.shadow_enabled or layer.secondary_fill.shadow_enabled:
        push_error("R8 R2 fill/dual shadow properties incorrect");quit(40);return
    if not (layer.study_light.energy>0.0 and layer.fill_light.energy>0.0 and layer.secondary_key.energy>0.0 and layer.secondary_fill.energy>0.0):
        push_error("R8 R2 both real fill and key lights must illuminate scene");quit(41);return
    layer.set_multi_light_enabled(false)
    if layer.secondary_key.energy!=0.0 or layer.secondary_fill.energy!=0.0:
        push_error("R8 R2 multi-source OFF regression");quit(42);return
    layer.set_fill_fraction(0.0)
    if layer.fill_light.energy!=0.0 or absf(layer.study_light.energy-0.98)>0.0001:
        push_error("R8 R2 zero-fill must equal original R8 key energy");quit(43);return
    layer.set_study_enabled(false)
    if layer.fill_light.energy!=0.0 or layer.study_light.energy!=0.0:
        push_error("R8 R2 study OFF should disable key and fill");quit(44);return
    print("A35 R8 R2 GODOT NATIVE PASS: 187 original PAR, 175 trunks/175 canopies, dual shadowed key lights + independent no-shadow fill, original Ground/collision immutable")
    quit(0)
'''

GPU=r'''extends SceneTree
const BASE := "res://scenes/a35_r8_canopy_shadow_scene.tscn"
const NEW := "res://scenes/a35_r8_r2_light_balance_scene.tscn"
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
    var vp:=SubViewport.new()
    vp.size=Vector2i(1280,928)
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var cases: Array[Dictionary]=[
      {"scene":BASE,"label":"R8_HARD_BASELINE","fill":0.0,"multi":false},
      {"scene":NEW,"label":"R2_ZERO_FILL","fill":0.0,"multi":false},
      {"scene":NEW,"label":"R2_CANOPY_FILL","fill":0.24,"multi":false},
      {"scene":NEW,"label":"R2_TWO_LIGHTS","fill":0.24,"multi":true}
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
        if study.has_method("set_fill_fraction"):
            study.set_fill_fraction(float(item["fill"]))
            study.set_multi_light_enabled(bool(item["multi"]))
        for i in range(18):await process_frame
        await RenderingServer.frame_post_draw
        var picture:Image=vp.get_texture().get_image()
        if picture==null or picture.is_empty() or picture.get_size()!=Vector2i(1280,928):
            push_error("A35 R8 R2 native GPU empty");quit(51);return
        var file:String="res://qa_a35/A35_R8_R2_%s_NATIVE.png" % str(item["label"])
        if picture.save_png(file)!=OK:
            push_error("A35 R8 R2 native PNG save failed");quit(52);return
        print("A35 R8 R2 REAL GODOT GPU ",file," fill=",item["fill"]," second_light=",item["multi"])
        world.queue_free()
        await process_frame
    print("A35 R8 R2 four real Godot source/fill/two-light GPU captures 4/4 PASS")
    quit(0)
'''

def build(base:Path,out:Path,script:Path,work:Path):
    work.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(base) as z:
        if z.testzip():raise ValueError("Original R8 ZIP CRC failed")
        files={k:z.read(k) for k in z.namelist()}
    if sha(files["private_assets/ground_only.png"])!=GROUND:
        raise ValueError("Ground SHA mismatch")
    orig=files[OLD]
    text=orig.decode()
    old_ref='[ext_resource type="Script" path="res://scripts/a35_r8_canopy_shadow.gd" id="5_study"]'
    new_ref='[ext_resource type="Script" path="res://'+SCRIPT+'" id="5_study"]'
    if text.count(old_ref)!=1:raise ValueError("Existing R8 scene script binding unexpected")
    new_scene=text.replace(old_ref,new_ref).replace("FS_A35_R8_PixelCanopyShadows","FS_A35_R8_R2_BalancedForestLights",1)
    if new_scene==text:raise ValueError("Candidate scene not produced")
    files[NEW]=new_scene.encode()
    files[SCRIPT]=script.read_bytes()
    files["tests/test_a35_r8_r2_native.gd"]=NATIVE.encode()
    files["tests/capture_a35_r8_r2_native.gd"]=GPU.encode()
    nav=files["tests/test_a35_r8_navigation.gd"].decode()
    nav=nav.replace("res://"+OLD,"res://"+NEW).replace("A35 R8 ","A35 R8 R2 ")
    files["tests/test_a35_r8_r2_navigation.gd"]=nav.encode()
    files["project.godot"]=files["project.godot"].replace(("res://"+OLD).encode(),("res://"+NEW).encode())
    if ("res://"+NEW).encode() not in files["project.godot"]:
        raise ValueError("R8 R2 main scene not changed")
    files["tools/a35_r8_r2_build.py"]=Path(__file__).read_bytes()
    data={"phase":"A35 R8 R2 preliminary source",
        "immutable_R8_scene_sha256":sha(orig),
        "immutable_original_Ground_sha256":GROUND,
        "base_sha256":sha(base.read_bytes()),
        "added_real_lights":"primary shadowed+unshadowed fill; optional secondary grove shadowed+fill",
        "aesthetic":"HOLD","native":"NOT_RUN"}
    files["qa_a35/A35_R8_R2_SOURCE_QA.json"]=(json.dumps(data,ensure_ascii=False,indent=2)+"\n").encode()
    files["docs/A35_R8_R2_SOURCE_HANDOFF.md"]=(
        "# FS A35 R8 R2 | 2D canopy fill and secondary test light\n"
        "- Reversible candidate based on official R8, no old R8 scene or original Ground/175 canopy/187 PAR changes.\n"
        "- Primary light energy split between a shadowed key and nonshadowed same-position fill, total .98; fill 0..0.42. This only APPROXIMATES leaf transmission; no true partial alpha shadows.\n"
        "- Secondary separate key/fill at (1090,280) tests independent tree-region illumination. Runtime keys F/M; retains old P/O; A/B 4 real Godot GPU frames + native source/navigation required.\n"
        "- ART HOLD until original GPU A/B visual and shadow darkness benchmark.\n"
    ).encode()
    files["docs/A35_R8_R2_FAILURE_LOG.md"]=(
        "# A35 R8 R2 source risks\n"
        "- Solid OccluderPolygon2D cannot transmit fractional light. R2 adds unshadowed fill light, not claims of physical semi-transparent canopy shadows.\n"
        "- Secondary point light is a temporary forestry art test, not permanent village light installation.\n"
        "- Do not claim passed native tests until Godot import/source/navigation/GPU and pixel QA actually executed.\n"
    ).encode()
    out.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(out,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for k,b in files.items():z.writestr(k,b)
    with zipfile.ZipFile(out) as z:
        if z.testzip():raise ValueError("R8 R2 source CRC fail")
        if z.read(OLD)!=orig or sha(z.read("private_assets/ground_only.png"))!=GROUND:
            raise ValueError("Existing R8 scene or Ground modified")
    print(json.dumps({"file":str(out),"bytes":out.stat().st_size,"members":len(files),
        "sha256":sha(out.read_bytes()),"source_qa":data},ensure_ascii=False,indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--base",required=True)
    p.add_argument("--output",required=True)
    p.add_argument("--script",required=True)
    p.add_argument("--work",required=True)
    a=p.parse_args();build(Path(a.base),Path(a.output),Path(a.script),Path(a.work))
