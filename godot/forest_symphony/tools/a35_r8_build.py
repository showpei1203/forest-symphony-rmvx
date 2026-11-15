#!/usr/bin/env python3
"""Forest Symphony A35 R8: additive original-pixel canopy shadow Godot scene.

R7 is sealed. R8 only substitutes study-script and scene resource path in a new
.ts cn file, plus PNG-derived silhouette JSON. Never writes original sprites.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path
GROUND="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
OLD="scenes/a35_r7_shadow_study_scene.tscn"
NEW="scenes/a35_r8_canopy_shadow_scene.tscn"
OLD_SCRIPT="scripts/a35_r7_shadow_study.gd"
NEW_SCRIPT="scripts/a35_r8_canopy_shadow.gd"
PROFILES="data/a35_r8_canopy_profiles.json"
def sha(b):return hashlib.sha256(b).hexdigest()

NATIVE_TEST=r'''extends SceneTree
## Native Godot source: unchanged 187 objects, 175 trunk and 175 canopy real nodes.
const OLD := "res://scenes/a35_r7_shadow_study_scene.tscn"
const NEW := "res://scenes/a35_r8_canopy_shadow_scene.tscn"
const GROUND := "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    if FileAccess.get_sha256("res://private_assets/ground_only.png") != GROUND:
        push_error("R8 Ground SHA changed");quit(31);return
    var a: Node2D = load(OLD).instantiate()
    var b: Node2D = load(NEW).instantiate()
    root.add_child(a)
    root.add_child(b)
    await process_frame
    var study = b.get_node("ForestLightStudy")
    if study.caster_count != 175 or study.canopy_caster_count != 175 or study.canopy_errors != 0:
        push_error("R8 expected 175 trunks + 175 canopy masks, errors=" + str(study.canopy_errors));quit(32);return
    if study.canopy_profile_count < 12:
        push_error("R8 authored source profile diversity too low");quit(33);return
    var owners1: Node2D=a.get_node("YSort")
    var owners2: Node2D=b.get_node("YSort")
    if owners1.get_child_count()!=owners2.get_child_count():
        push_error("R8 PAR owner count changed");quit(34);return
    var checked:=0
    var trees:=0
    var vertices:=0
    for left in owners1.get_children():
        if left is CharacterBody2D:continue
        var right=owners2.get_node_or_null(NodePath(str(left.name)))
        if right==null or left.position!=right.position:
            push_error("R8 object moved " + str(left.name));quit(35);return
        if left.source_file!=right.source_file or left.source_sha256!=right.source_sha256:
            push_error("R8 PAR source SHA changed " + str(left.name));quit(36);return
        var la: CollisionShape2D=left.get_node("Body/Collision")
        var lb: CollisionShape2D=right.get_node("Body/Collision")
        if (la.shape==null)!=(lb.shape==null) or la.disabled!=lb.disabled:
            push_error("R8 original collision null/disabled mismatch");quit(37);return
        if la.shape!=null and la.shape.get_rect()!=lb.shape.get_rect():
            push_error("R8 original collision geometry changed");quit(38);return
        if left.source_semantic=="tree":
            var mask: LightOccluder2D=right.get_node_or_null("R8_CanopyLightOccluder")
            if mask==null or mask.occluder==null or mask.occluder.polygon.size()<8:
                push_error("R8 missing original sprite canopy outline " + str(left.name));quit(39);return
            vertices+=mask.occluder.polygon.size()
            trees+=1
        checked+=1
    if checked!=187 or trees!=175:
        push_error("R8 old forest count regression");quit(40);return
    study.set_shadows_enabled(true)
    study.set_canopy_enabled(true)
    if not study.study_light.shadow_enabled or study.canopy_nodes[0].occluder_light_mask!=1:
        push_error("R8 canopy ON failed");quit(41);return
    study.set_canopy_enabled(false)
    if study.canopy_nodes[0].occluder_light_mask!=0:
        push_error("R8 canopy OFF failed");quit(42);return
    print("A35 R8 GODOT NATIVE PASS: 187 unchanged PAR, 175 trunk + 175 source-mask canopy LightOccluder2D; canopy vertices=",vertices,
          " profiles=",study.canopy_profile_count," setup_us=",study.canopy_setup_usec)
    quit(0)
'''

GPU_TEST=r'''extends SceneTree
## Original Godot GPU real canopy-shadow OFF/ON. No software rendering.
const SCENE := "res://scenes/a35_r8_canopy_shadow_scene.tscn"
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var vp:=SubViewport.new()
    vp.size=Vector2i(1280,928)
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    for canopy_enabled in [false,true]:
        var world: Node2D=load(SCENE).instantiate()
        vp.add_child(world)
        var player:CharacterBody2D=world.get_node("YSort/Player")
        player.get_node("Camera2D").enabled=false
        player.visible=false
        var fx=world.get_node("HD2DAtmosphere")
        fx.animate=false
        fx.phase=2
        fx.raining=false
        fx._update_phase()
        var layer=world.get_node("ForestLightStudy")
        layer.set_shadows_enabled(true)
        layer.set_study_enabled(true)
        layer.set_canopy_enabled(canopy_enabled)
        var start=Time.get_ticks_usec()
        for i in range(18):
            await process_frame
        await RenderingServer.frame_post_draw
        var elapsed=Time.get_ticks_usec()-start
        var original:Image=vp.get_texture().get_image()
        if original==null or original.is_empty() or original.get_size()!=Vector2i(1280,928):
            push_error("R8 GPU no actual framebuffer");quit(51);return
        var file:String="res://qa_a35/A35_R8_CANOPY_SHADOW_%s_NATIVE.png" % ("ON" if canopy_enabled else "OFF")
        if original.save_png(file)!=OK:
            push_error("R8 native GPU save failed");quit(52);return
        print("A35 R8 GODOT REAL GPU ",file," canopy_enabled=",canopy_enabled,
              " frames=18 average_wall_frame_ms=",float(elapsed)/18000.0)
        world.queue_free()
        await process_frame
    print("A35 R8 REAL GODOT CANOPY GPU 2/2 PASS")
    quit(0)
'''

def build(base:Path,destination:Path,profiles:Path,script:Path,work:Path):
    work.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(base) as z:
        if z.testzip():raise ValueError("Sealed R7 CRC fail")
        files={n:z.read(n) for n in z.namelist()}
    if sha(files["private_assets/ground_only.png"])!=GROUND:
        raise ValueError("Ground content modified")
    current=json.loads(profiles.read_bytes())
    if current["tree_instances"]!=175 or current["original_ground_sha256"]!=GROUND:
        raise ValueError("Wrong profile source")
    if current["source_zip_sha256"]!=sha(base.read_bytes()):
        raise ValueError("Canopy profiles from different R7 source")
    original=files[OLD]
    root_scene=original.decode()
    before='[ext_resource type="Script" path="res://'+OLD_SCRIPT+'" id="5_study"]'
    after='[ext_resource type="Script" path="res://'+NEW_SCRIPT+'" id="5_study"]'
    if root_scene.count(before)!=1:
        raise ValueError("R7 scene original shadow script reference unexpected")
    new_scene=root_scene.replace(before,after).replace("FS_A35_R7_TreeShadowStudy","FS_A35_R8_PixelCanopyShadows",1)
    if new_scene==root_scene:raise ValueError("R8 no scene change")
    files[NEW]=new_scene.encode()
    files[NEW_SCRIPT]=script.read_bytes()
    files[PROFILES]=profiles.read_bytes()
    files["tests/test_a35_r8_native.gd"]=NATIVE_TEST.encode()
    files["tests/capture_a35_r8_canopy_native.gd"]=GPU_TEST.encode()
    files["tests/test_a35_r8_navigation.gd"]=files["tests/test_a35_r7_navigation.gd"].decode().replace(
        "res://"+OLD,"res://"+NEW).replace("A35 R7","A35 R8").encode()
    origin=("res://"+OLD).encode()
    if origin not in files["project.godot"]:
        raise ValueError("R7 project main scene incorrect")
    files["project.godot"]=files["project.godot"].replace(origin,("res://"+NEW).encode())
    files["docs/A35_R8_SOURCE_HANDOFF.md"]=(
        "# Forest Symphony A35 R8 | source alpha canopy shadow geometry\n"
        "- R8 is an additive source-derived separate scene. Original R7 and all R2-R6 scenes, 187 PAR, 175 tree sprites, original Ground and physics are untouched.\n"
        "- 175 canopy light occluders from actual private source-pixel alpha masks, with independently toggled R7 175 trunk occluders and PCF5 light filtering.\n"
        "- Asset polygons are monotonic Y contours, each max 48 points, one cached geometry per unique sprite source. Source profile PNG content SHA and tree IDs recorded.\n"
        "- Native Godot import, source/nav/GPU and shadow-difference QA not yet run at this build stage; do not claim visual or GPU pass.\n"
        "- ART HOLD: is still a 2D shadow study; foliage polygons simplified, no real 3D DOF or soft-shade art seal.\n"
    ).encode()
    files["docs/A35_R8_FAILURE_LOG.md"]=(
        "# A35 R8 Failure Log\n"
        "- R7 trunk-only geometry was too simple to represent actual canopy shading. R8 extracts tree-specific silhouette polygons from original PNG alpha, with no 8px fill tiles or rectangles.\n"
        "- Potential self-occlusion/overly dark canopy risk: R8 should only enable canopy shadows for study lamp, not permanent production lights, and must visually compare identical lighting on/off at 1x.\n"
        "- Source-level scene generation does not mean Godot native PASS. Run actual original screenshots, physics and GPU image differences and report failures honestly.\n"
    ).encode()
    files["tools/a35_r8_canopy_extract.py"]=(work/"a35_r8_canopy_extract.py").read_bytes()
    files["tools/a35_r8_build.py"]=Path(__file__).read_bytes()
    qa={"phase":"A35_R8_CANOPY_SOURCE","R7_source_zip_sha256":sha(base.read_bytes()),
        "R7_scene_sha256":sha(original),"Ground_sha256":GROUND,
        "trees":175,"unique_profiles":current["source_profiles"],
        "total_canopy_vertices":current["total_polygon_vertices"],
        "new_scene":NEW,"native":"NOT_RUN","art":"HOLD"}
    files["qa_a35/A35_R8_SOURCE_QA.json"]=(json.dumps(qa,indent=2)+"\n").encode()
    destination.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(destination,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for path,data in files.items():z.writestr(path,data)
    with zipfile.ZipFile(destination) as z:
        if z.testzip():raise ValueError("R8 output CRC failure")
        if z.read(OLD)!=original or sha(z.read("private_assets/ground_only.png"))!=GROUND:
            raise ValueError("R7 scene or Ground modified")
    print(json.dumps({"path":str(destination),"members":len(files),"bytes":destination.stat().st_size,
                      "sha256":sha(destination.read_bytes()),"qa":qa},indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--base",required=True)
    p.add_argument("--output",required=True)
    p.add_argument("--profiles",required=True)
    p.add_argument("--script",required=True)
    p.add_argument("--work",required=True)
    a=p.parse_args()
    build(Path(a.base),Path(a.output),Path(a.profiles),Path(a.script),Path(a.work))
