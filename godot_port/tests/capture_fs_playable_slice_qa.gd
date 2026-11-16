extends SceneTree

# Real Godot4.7.2 OpenGL / Xvfb 1088x832 NATIVE SCREENSHOTS:
# 1. live original VX301 event suspended while real FSScreen ACT
#    BATTLE target-selector is visible;
# 2. next map after victory VX601, transfer VX201, quest VX102,
#    checkpoint with validated memory-only JSON.
# This uses SYNTHETIC 32x32 tiles / source-shaped actor/enemy fixtures,
# NEVER represents the true A35 Ground/PAR or final post-Apply FS.
const SLICE=preload("res://scripts/story/FSPlayableSlice.gd")

func _initialize()->void:
    call_deferred("_run")

func _fail(reason:String)->void:
    push_error("FS playable OpenGL 533 native FAIL: "+reason)
    quit(1)

func _button(root_node:Node,text_fragment:String)->Button:
    for child in root_node.get_children():
        if child is Button and text_fragment in child.text:
            return child
    return null

func _capture(path:String,reason:String)->bool:
    if path.is_empty():
        _fail("missing path for "+reason)
        return false
    var img:Image=root.get_texture().get_image()
    if img==null or img.is_empty() or img.get_width()<544 or (
            img.get_height()<416):
        _fail("real native OpenGL frame absent: "+reason)
        return false
    if img.save_png(path)!=OK:
        _fail("cannot write artifact "+reason)
        return false
    var f:FileAccess=FileAccess.open(path,FileAccess.READ)
    if f==null or f.get_length()<2000:
        _fail("empty PNG "+reason)
        return false
    f.close()
    return true

func _run()->void:
    var window:Window=root
    window.size=Vector2i(1088,832)
    window.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
    var slice=SLICE.new()
    slice.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_child(slice)
    var font:Font=slice.get_theme_default_font()
    if font==null or not font.has_char(0x68EE) or not font.has_char(0x6230):
        _fail("no Chinese glyphs in real Godot fullscreen slice")
        return
    if not bool(slice.interact_front().get("ok",false)):
        _fail("first source VX101 chest not found")
        return
    slice.dialogue.advance_message()
    if slice.world.amount("item",1)!=1:
        _fail("native VX126 chest failed")
        return
    for i in range(3):
        slice.move_one_tile(Vector2i.RIGHT)
    if not bool(slice.interact_front().get("ok",false)):
        _fail("VX301 encounter event not reachable by tile walking")
        return
    slice.dialogue.advance_message()
    if slice.battle_view==null or not slice.battle.active:
        _fail("no real Godot Battle overlay from VX301")
        return
    slice.battle_view._process(2.0)
    slice.battle_view._player_attack()
    if not ("選擇敵方目標" in slice.battle_view.title_label.text):
        _fail("real native FS battle target panel did not open")
        return
    await process_frame
    await process_frame
    var battle_path:String=OS.get_environment(
        "FS_SLICE_BATTLE_QA_SCREENSHOT_PATH")
    if not _capture(battle_path,"battle target selector"):
        return
    var target:Button=_button(slice.battle_view.body,"測試木靈")
    if target==null:
        _fail("real FSScreen target button not reachable")
        return
    target.pressed.emit()
    slice.battle_view._process(1.0/60.0)
    if slice.world.gold!=50 or not slice.world.switch_on(10):
        _fail("native ACT battle must trigger VX601 victory before map")
        return
    await process_frame
    slice.dialogue.advance_message()
    if slice.story.runner.active:
        _fail("VX601 victory branch should complete")
        return
    slice.move_one_tile(Vector2i.DOWN)
    for i in range(4):
        slice.move_one_tile(Vector2i.RIGHT)
    if not bool(slice.interact_front().get("ok",false)) or (
            slice.world.map_id!=1000):
        _fail("VX201 real map transfer failed")
        return
    slice.dialogue.advance_message()
    for i in range(3):
        slice.move_one_tile(Vector2i.RIGHT)
    if not bool(slice.interact_front().get("ok",false)):
        _fail("new map guardian VX101 not accessible")
        return
    slice.dialogue.advance_message()
    if slice.dialogue._mode!="choice":
        _fail("source VX102 dialogue choice missing")
        return
    var choice:Button=slice.dialogue.choice_list.get_child(0)
    choice.pressed.emit()
    slice.dialogue.advance_message()
    if slice.world.gold!=50 or not slice.world.switch_on(20) or (
            slice.world.amount("item",1)!=2) or slice.story.runner.active:
        _fail("VX402 quest branch must give second herb exactly once")
        return
    if not bool(slice.save_checkpoint().get("ok",false)):
        _fail("real world JSON checkpoint unavailable after story")
        return
    slice._refresh_status()
    await process_frame
    await process_frame
    var map_path:String=OS.get_environment(
        "FS_SLICE_MAP_QA_SCREENSHOT_PATH")
    if not _capture(map_path,"ruins quest map"):
        return
    print("FS P533 real Godot OpenGL 1088x832 ACT BATTLE target screenshot + map1000 quest screenshot PASS, VX301/601/201/102 gold50 item2")
    quit(0)
