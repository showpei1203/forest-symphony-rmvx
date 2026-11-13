extends SceneTree

# Playable synthetic map: one-step chest, tile walking and choice NPC with no repeat reward.
const Sandbox = preload("res://scripts/story/FSStorySandbox.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("FS story sandbox FAIL: " + reason)
        quit(1)
        return false
    return true

func _run() -> void:
    var scene = Sandbox.new()
    root.add_child(scene)
    if not _check(scene.markers.size()==2,"two interactive event markers"): return
    var result: Dictionary = scene.interact_front()
    if not _check(result.get("ok",false) and result.get("page_index",-1)==0,"chest interaction"): return
    if not _check(scene.dialogue._mode=="message","chest message shows"): return
    scene.dialogue.advance_message()
    if not _check(scene.world.amount("item",1)==1,"chest reward granted"): return
    scene.dialogue.advance_message()
    result = scene.interact_front()
    if not _check(result.get("page_index",-1)==1,"chest second visit selects empty page"): return
    scene.dialogue.advance_message()
    if not _check(scene.world.amount("item",1)==1,"no repeat chest reward"): return
    for _i in 4:
        scene.move_one_tile(Vector2i(1,0))
    if not _check(scene.player==Vector2i(8,5),"tile movement to NPC"): return
    scene.move_one_tile(Vector2i(0,1)) # Impassable event tile, should rotate only.
    if not _check(scene.player==Vector2i(8,5) and scene.face==Vector2i(0,1),"event collision without walking into NPC"): return
    result = scene.interact_front()
    if not _check(result.get("ok",false) and result.get("page_index",-1)==0,"NPC interaction"): return
    scene.dialogue.advance_message()
    if not _check(scene.dialogue._mode=="choice","NPC offers choices"): return
    var accept: Button = scene.dialogue.choice_list.get_child(0)
    accept.pressed.emit()
    if not _check(scene.dialogue._mode=="message","NPC acceptance text shows"): return
    scene.dialogue.advance_message()
    if not _check(scene.world.gold==50 and scene.world.switch_on(5),"NPC accept sets quest switch and gold"): return
    result = scene.interact_front()
    if not _check(result.get("page_index",-1)==1,"NPC returns completed quest page"): return
    scene.dialogue.advance_message()
    if not _check(scene.world.gold==50 and not scene.story.runner.active,"no repeated NPC reward"): return
    print("FS sandbox walkable map/interactive chest/NPC quest rewards PASS")
    quit(0)
