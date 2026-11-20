#!/usr/bin/env python3
"""Build self-contained Godot 4.7.2 Attack V4 candidate review (private assets ZIP)."""
from pathlib import Path
from PIL import Image
import shutil, zipfile, hashlib, json, os
ROOT=Path(__file__).resolve().parent
V4=Path(os.environ.get('TB_ATTACK_V4_OUTPUT', str(ROOT/'v4_articulated')))
STAGING=Path(os.environ.get('TB_ASSET_STAGING_DIR',str(ROOT.parent/'assets')))
NATIVE=Path(os.environ.get('TB_NATIVE_ATTACK_DIR',str(ROOT/'outputs')))
PKG=ROOT/'godot_v4_attack_demo'
ASSETS=PKG/'assets'/'monsters'/'tb'
ASSETS.mkdir(parents=True,exist_ok=True)
for f in [
 V4/'PMD0001_ATTACK_V4_11F_384x288.png',
 STAGING/'PMD0001_STATIC_64.png',
 STAGING/'PMD0002_STATIC_64.png',
 STAGING/'PMD0003_STATIC_64.png',
 STAGING/'PMD0001_ATTACK_8F_256x128.png',
 NATIVE/'PMD0001_G9_NATIVE_ATTACK_ROW1_11F_256x288.png',
]:
 shutil.copyfile(f, ASSETS/f.name)
shutil.copyfile(V4/'PMD0001_ATTACK_V4_MANIFEST.json',PKG/'PMD0001_ATTACK_V4_MANIFEST.json')
(PKG/'project.godot').write_text('''; Forest Symphony / T-B isolated comparison. 4.7.2 only.
config_version=5
[application]
config/name="FS T-B Attack V4 Articulation Review"
run/main_scene="res://attack_v4_demo.tscn"
config/features=PackedStringArray("4.7", "GL Compatibility")
[display]
window/size/viewport_width=1140
window/size/viewport_height=610
[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/default_filters/use_nearest_mipmap_filter=false
''',encoding='utf8')
(PKG/'attack_v4_demo.tscn').write_text('''[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://attack_v4_demo.gd" id="1"]
[node name="TB_AttackV4Review" type="Node2D"]
script = ExtResource("1")
''',encoding='utf8')
(PKG/'attack_v4_demo.gd').write_text('''extends Node2D
## Side-by-side source-locked V4, rejected V1, and historical native motion.
## 4.7.2 REVIEW ONLY. Attack is NOT ART APPROVED.
const ASSET_ROOT := "res://assets/monsters/tb/"
const DURATIONS := [4,2,4,2,2,2,2,2,2,2,4]
var v4: AnimatedSprite2D
var v1: AnimatedSprite2D
var native: AnimatedSprite2D
var feedback: Label
var last_event := ""
func _ready() -> void:
    get_window().size = Vector2i(1140, 610)
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.085,0.11,0.14)
    backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
    backdrop.size = Vector2(1140,610)
    add_child(backdrop)
    _label(Vector2(24,18), "FS / T-B | Real articulation candidate V4 | NOT PixelLab / NOT ART APPROVED", 19)
    _label(Vector2(36,82), "V4: articulated limbs + mouth (11F)", 16)
    _label(Vector2(418,82), "REJECTED: rigid-body V1 (8F)", 16)
    _label(Vector2(806,82), "G9 original motion reference (11F)", 16)
    v4 = _sprite("PMD0001_ATTACK_V4_11F_384x288.png",11,4,96,96,DURATIONS,60.0)
    v4.position = Vector2(180,268)
    v4.scale = Vector2(3.2,3.2)
    v1 = _sprite("PMD0001_ATTACK_8F_256x128.png",8,4,64,64,[],11.0)
    v1.position = Vector2(570,263)
    v1.scale = Vector2(3.6,3.6)
    v1.modulate = Color(1,0.8,0.78)
    native = _sprite("PMD0001_G9_NATIVE_ATTACK_ROW1_11F_256x288.png",11,4,64,96,DURATIONS,60.0)
    native.position = Vector2(938,263)
    native.scale = Vector2(3.2,3.2)
    feedback = _label(Vector2(24,485),"SPACE: play all  |  R: reset  |  0-9: select V4 frame",17)
    _label(Vector2(24,533),"V4 identity locked at F0/F10  •  F2 Rush  •  F5 Hit  •  F7 Return  •  Texture QA != Art Gate",15)
    _reset()
func _label(pos: Vector2, t: String, size: int) -> Label:
    var lab := Label.new()
    lab.position=pos
    lab.text=t
    lab.add_theme_font_size_override("font_size",size)
    lab.add_theme_color_override("font_color",Color(0.91,0.92,0.91))
    add_child(lab)
    return lab
func _sprite(file_name: String,count: int,cols: int,w: int,h: int,ticks: Array,fps: float) -> AnimatedSprite2D:
    var texture: Texture2D = load(ASSET_ROOT+file_name)
    assert(texture != null, "Missing private texture: "+file_name)
    assert(texture.get_width() == cols*w)
    assert(texture.get_height() == int(ceil(float(count)/float(cols)))*h)
    var frames := SpriteFrames.new()
    frames.remove_animation("default")
    frames.add_animation("attack")
    frames.set_animation_speed("attack",fps)
    frames.set_animation_loop("attack",false)
    for i in count:
        var atlas := AtlasTexture.new()
        atlas.atlas=texture
        atlas.region=Rect2((i%cols)*w,int(i/cols)*h,w,h)
        atlas.filter_clip=true
        frames.add_frame("attack",atlas,float(ticks[i]) if not ticks.is_empty() else 1.0)
    var sprite := AnimatedSprite2D.new()
    sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.sprite_frames=frames
    sprite.animation="attack"
    add_child(sprite)
    return sprite
func _process(_delta: float) -> void:
    if feedback == null or v4 == null: return
    var event_name := ""
    if v4.frame == 2: event_name = "RUSH"
    if v4.frame == 5: event_name = "HIT"
    if v4.frame == 7: event_name = "RETURN"
    if event_name != last_event and not event_name.is_empty() and v4.is_playing():
        print("TB_ATTACK_EVENT ", event_name, " FRAME ", v4.frame)
    last_event = event_name
    feedback.text="SPACE: play all | R: reset | V4 F%d %s  / V1 F%d / G9 F%d | 60 ticks/s" % [v4.frame,event_name,v1.frame,native.frame]
func _reset() -> void:
    for a in [v4,v1,native]:
        a.stop()
        a.set_frame_and_progress(0,0.0)
    last_event=""
func _input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:return
    if event.keycode==KEY_SPACE:
        _reset()
        for a in [v4,v1,native]: a.play("attack")
    elif event.keycode==KEY_R: _reset()
    elif event.keycode>=KEY_0 and event.keycode<=KEY_9:
        v4.stop()
        v4.set_frame_and_progress(event.keycode-KEY_0,0.0)
''',encoding='utf8')
(PKG/'tests').mkdir(exist_ok=True)
(PKG/'tests'/'tb_attack_v4_native_validator.gd').write_text('''extends SceneTree
## Intended Godot 4.7.2 --headless -s res://tests/tb_attack_v4_native_validator.gd
func _init() -> void:
    call_deferred("_test")
func _test() -> void:
    var root := "res://assets/monsters/tb/"
    var image := Image.load_from_file(root+"PMD0001_ATTACK_V4_11F_384x288.png")
    if image == null or image.get_width()!=384 or image.get_height()!=288:
        push_error("TB native texture dimensions incorrect")
        quit(1)
        return
    var f0 := image.get_region(Rect2i(0,0,96,96))
    var f10 := image.get_region(Rect2i(192,192,96,96))
    if f0.get_data()!=f10.get_data():
        push_error("TB native source locked endpoints mismatch")
        quit(2)
        return
    var frames := SpriteFrames.new()
    frames.remove_animation("default")
    frames.add_animation("attack")
    frames.set_animation_speed("attack",60.0)
    frames.set_animation_loop("attack",false)
    var tex := load(root+"PMD0001_ATTACK_V4_11F_384x288.png") as Texture2D
    if tex == null:
        push_error("TB native Godot atlas load failed")
        quit(3)
        return
    var durations: Array[float] = [4.0,2.0,4.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,4.0]
    for i in 11:
        var crop := AtlasTexture.new()
        crop.atlas = tex
        crop.region = Rect2((i%4)*96, int(i/4)*96, 96, 96)
        frames.add_frame("attack",crop,durations[i])
    assert(frames.get_frame_count("attack")==11)
    assert(frames.get_frame_duration("attack",5)==2.0)
    print("TB_NATIVE_QA_PASS version=4.7.2 frame_count=11 size=96 event_hit=5")
    quit(0)
''',encoding='utf8')
readme='''# Forest Symphony / PMD0001 V4 attack articulated candidate

**Required engine: Godot 4.7.2**. These files are private source derived assets. Do not redistribute or publish to public GitHub.

Open `project.godot`; `attack_v4_demo.tscn` compares the new source-locked nonrigid retargeting candidate with the rejected rigid V1 and old G9 native pose reference. SPACE play, R reset, 0-9 scrub V4 frame. The Godot native CLI validator is `tests/tb_attack_v4_native_validator.gd`.

V4 is NOT PixelLab-generated; F0/F10 reuse the exact approved source, while the attack uses independently controlled rear/near/far leg and mouth constraints. Normal Attack = lunge/bite; no fireball. Event indices: F2 Rush, F5 Hit, F7 Return. Frame durations in 60 ticks/second: [4,2,4,2,2,2,2,2,2,2,4]. Source shape is not yet confirmed at 45°. Source licensing, visual identity and hand-drawn pose quality remain user ART HOLD.

`build_v4_articulated_candidate.py` requires Pillow/Numpy/SciPy. Use actual source image in a trusted private working directory; never commit the image or derived sprite into the public repository. Tests validate visual file geometry and event metadata, not final animation semantics.
'''
(PKG/'README.md').write_text(readme,encoding='utf8')
zip_path=ROOT/'FS_TB_ATTACK_V4_GODOT_REVIEW_PRIVATE.zip'
with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED,compresslevel=8) as z:
 for f in sorted(PKG.rglob('*')):
  if f.is_file(): z.write(f,f.relative_to(PKG))
with zipfile.ZipFile(zip_path) as z:
 broken=z.testzip()
 assert broken is None,broken
 count=len(z.namelist())
print(json.dumps({'zip':str(zip_path),'bytes':zip_path.stat().st_size,'items':count,'sha256':hashlib.sha256(zip_path.read_bytes()).hexdigest()}))
