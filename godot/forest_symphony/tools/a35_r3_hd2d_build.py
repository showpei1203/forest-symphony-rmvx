#!/usr/bin/env python3
"""FS A35 R3 real-time HD-2D map FX, applied without altering owner-only Ground or PAR art.

Builds a reversible R3 Godot candidate from the A35 R2 private portable ZIP.
The GitHub tree contains only code, not owner-only PNGs. Requires Python stdlib.
"""
import argparse,hashlib,json,zipfile
from pathlib import Path

BASE_SCENE="scenes/a35_r2_new_species_scene.tscn"
CANDIDATE="scenes/a35_r3_hd2d_layered_scene.tscn"
FX="scripts/a35_r3_hd2d_fx.gd"
QA="tests/test_a35_r3_hd2d_real.gd"
CAPTURE="tests/capture_a35_r3_hd2d_native.gd"
GROUND="private_assets/ground_only.png"
EXPECTED_SHA="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"

QA_SOURCE=r'''extends SceneTree
const BASE := "res://scenes/a35_r2_new_species_scene.tscn"
const CAND := "res://scenes/a35_r3_hd2d_layered_scene.tscn"
const GROUND_SHA := "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    if FileAccess.get_sha256("res://private_assets/ground_only.png") != GROUND_SHA:
        push_error("A35 R3 Ground SHA changed")
        quit(30)
        return
    var base_scene: PackedScene = load(BASE)
    var candidate_scene: PackedScene = load(CAND)
    if base_scene == null or candidate_scene == null:
        push_error("A35 R3 missing scene")
        quit(31)
        return
    var a := base_scene.instantiate()
    var b := candidate_scene.instantiate()
    root.add_child(a)
    root.add_child(b)
    await process_frame
    if a.get_node("YSort").get_child_count() != b.get_node("YSort").get_child_count():
        push_error("A35 R3 object count changed")
        quit(32)
        return
    if b.get_node_or_null("HD2DAtmosphere") == null:
        push_error("A35 R3 atmosphere missing")
        quit(33)
        return
    var owners := 0
    for node in a.get_node("YSort").get_children():
        if node is CharacterBody2D:
            continue
        var match_node = b.get_node("YSort").get_node_or_null(node.name)
        if match_node == null or match_node.position != node.position:
            push_error("A35 R3 world positions changed: " + node.name)
            quit(34)
            return
        if node.get("source_file") != null:
            if match_node.get("source_file") != node.get("source_file"):
                push_error("A35 R3 PAR changed: " + node.name)
                quit(35)
                return
            owners += 1
    if owners != 187:
        push_error("A35 R3 owner count invalid " + str(owners))
        quit(36)
        return
    print("A35 R3 GODOT NATIVE PASS: 187 PAR positions/sources, immutable Ground, effect attached")
    quit(0)
'''

CAPTURE_SOURCE=r'''extends SceneTree
## Actual Godot GPU framebuffer. NOT a Pillow/software preview.
const SCENE := "res://scenes/a35_r3_hd2d_layered_scene.tscn"
const W := 1280
const H := 928
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var vp := SubViewport.new()
    vp.size = Vector2i(W,H)
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    vp.disable_3d = true
    root.add_child(vp)
    for phase in range(3):
        var world: Node2D = load(SCENE).instantiate()
        vp.add_child(world)
        var p: CharacterBody2D = world.get_node("YSort/Player")
        p.get_node("Camera2D").enabled = false
        p.visible = false
        for i in range(6):
            await process_frame
        var fx = world.get_node("HD2DAtmosphere")
        fx.animate = false
        fx.phase = phase
        fx._update_phase()
        for i in range(4):
            await process_frame
        await RenderingServer.frame_post_draw
        var im := vp.get_texture().get_image()
        if im == null or im.is_empty() or im.get_size() != Vector2i(W,H):
            push_error("A35 R3 GPU screenshot empty")
            quit(41)
            return
        var file := "res://qa_a35/A35_R3_HD2D_%s_NATIVE.png" % ["DAY","DUSK","NIGHT"][phase]
        if im.save_png(file) != OK:
            push_error("A35 R3 GPU screenshot save failed")
            quit(42)
            return
        print("A35 R3 ACTUAL GODOT GPU CAPTURE: " + file)
        world.queue_free()
        await process_frame
    print("A35 R3 Godot native three-phase capture PASS")
    quit(0)
'''

def sha(data):return hashlib.sha256(data).hexdigest()

def build(base:Path,output:Path,fx_path:Path):
    with zipfile.ZipFile(base) as zi:
        if zi.testzip() is not None:
            raise ValueError("R2 ZIP CRC failed")
        data={name:zi.read(name) for name in zi.namelist()}
    if sha(data[GROUND])!=EXPECTED_SHA:
        raise ValueError("Original Ground SHA mismatch, refusing write")
    for needed in (BASE_SCENE,"scripts/a35_r2_world.gd","data/a35_r2_new_species_manifest.json","project.godot"):
        if needed not in data:
            raise ValueError("Missing R2 source "+needed)
    base_scene=data[BASE_SCENE]
    original_manifest=json.loads(data["data/a35_r2_new_species_manifest.json"])
    if len(original_manifest["objects"])!=187:
        raise ValueError("Not A35 R2 / 187 owner baseline")
    fx_code=fx_path.read_bytes()
    if b"extends Node2D" not in fx_code or b"CanvasModulate" not in fx_code:
        raise ValueError("FX script missing Godot layer features")
    scene=base_scene.decode()
    anchor='[ext_resource type="Script" path="res://scripts/a32_player.gd" id="3_player"]'
    if scene.count(anchor)!=1:
        raise ValueError("R2 anchor changed")
    scene=scene.replace(anchor,anchor+'\n[ext_resource type="Script" path="res://'+FX+'" id="4_atmosphere"]')
    scene=scene.replace('load_steps=4','load_steps=5',1)
    scene=scene.replace('FS_A35_R2_EightNewTreeSpecies','FS_A35_R3_HD2D_Layered')
    scene+='\n[node name="HD2DAtmosphere" type="Node2D" parent="."]\nscript = ExtResource("4_atmosphere")\n'
    data[CANDIDATE]=scene.encode()
    data[FX]=fx_code
    data[QA]=QA_SOURCE.encode()
    data[CAPTURE]=CAPTURE_SOURCE.encode()
    data["project.godot"]=data["project.godot"].replace(('res://'+BASE_SCENE).encode(),('res://'+CANDIDATE).encode())
    assert data[BASE_SCENE]==base_scene
    assert sha(data[GROUND])==EXPECTED_SHA
    qa={
      "phase":"A35_R3_HD2D_R1",
      "source_zip_sha256":sha(base.read_bytes()),
      "ground_sha256":EXPECTED_SHA,
      "A35_R2_scene_sha256":sha(base_scene),
      "original_PAR_count":187,
      "original_tree_count":175,
      "candidate_scene":CANDIDATE,
      "added_layer":"world-space CanvasModulate + PointLight2D + god rays + deterministic motes/rain",
      "source_integrity":"PASS",
      "Godot_native":"NOT_RUN_AT_BUILD",
      "lighting_art":"HOLD",
      "caveats":["runtime PointLight2D shadow_enabled=false until occluders","not 3D depth or postprocess DOF","R2 tree ART HOLD remains"]
    }
    data["qa_a35/A35_R3_HD2D_SOURCE_QA.json"]=(json.dumps(qa,indent=2)+"\n").encode()
    data["docs/A35_R3_HD2D_HANDOFF.md"]=('''# Forest Symphony A35 R3 | HD-2D lighting candidate

- Base: A35 R2 private full ZIP. All 187 independent PAR, 175 trees, anchors, player and 32 R2 species replacements **unchanged**.
- Preserved: original R1/R2 scenes and Ground bytes/SHA. New scene is additive, independent and reversible.
- Added: runtime Godot CanvasModulate, four PointLight2D warm lantern glows, three polygon sunbeams, 42 light motes and optional 74 rain lines.
- Runtime controls: N day/dusk/night, V rain, L effects on/off, G original grid.
- TEST: tests/test_a35_r3_hd2d_real.gd; CAPTURE: tests/capture_a35_r3_hd2d_native.gd; always run editor import first.
- Source gate PASS. Native renderer, physics regression and user visual art must be tested separately. ART HOLD, FORMAL SEAL NO.
- Failure Log: original R2 green texture repetition still present; this R3 track deliberately tests light and ambience separately, not a replacement for A35 R3 organic foliage redesign.
- No private PNGs on GitHub. Portable ZIP belongs to owner-only Drive folder, not public repo.
''').encode()
    data["docs/A35_R3_HD2D_FAILURE_LOG.md"]=('''# Forest Symphony A35 R3 HD-2D | Failure and risk register

1. Atmospheric light may distract from R2 foliage tiling. Keep ART HOLD until foliage improves; disable effects with L for 1x art inspection.
2. CanvasModulate changes frame-wide RGB, so **do not** reuse R2 tree-only ROI delta contract for day/dusk/night images.
3. New procedural PointLight2D uses no occluder shadow polygons yet; do not claim physical shadow correctness.
4. Cold portable ZIP must run Godot editor import before native source / GPU tests.
5. Godot GPU PNG labels only permitted after actual renderer capture, not PIL composites.
6. Public source branch must not include private Ground/trees/house PNG files; archive stays private Drive.
''').encode()
    output.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(output,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as zo:
        for k,v in data.items():
            zo.writestr(k,v)
    with zipfile.ZipFile(output) as verify:
        if verify.testzip() is not None:
            raise ValueError("R3 CRC error")
        if verify.read(BASE_SCENE)!=base_scene or sha(verify.read(GROUND))!=EXPECTED_SHA:
            raise ValueError("Source preservation failure")
    result={"members":len(data),"bytes":output.stat().st_size,"sha256":sha(output.read_bytes()),"project_main":CANDIDATE,"qa":qa}
    print(json.dumps(result,indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--base",required=True)
    p.add_argument("--output",required=True)
    p.add_argument("--fx",required=True)
    a=p.parse_args()
    build(Path(a.base),Path(a.output),Path(a.fx))
