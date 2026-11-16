extends SceneTree

# Actual Godot playable-loop integration: 2 tile maps, legacy VX source
# event codes 101/126/123/301/601/125/201/102, real FSBattle and
# FSScreen ACT selection, story branches, checkpoint integrity & restore.
# Explicit synthetic fixture, NOT original FS A35 artwork/postApply DB.
const SLICE=preload("res://scripts/story/FSPlayableSlice.gd")
const CODEC=preload("res://scripts/story/FSCheckpointCodec.gd")

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,why:String)->bool:
    if not ok:
        push_error("FS playable slice 532 Godot native FAIL: "+why)
        quit(1)
        return false
    return true

func _button(fragment:String,container:Node)->Button:
    for child in container.get_children():
        if child is Button and fragment in child.text:
            return child
    return null

func _run()->void:
    var slice=SLICE.new()
    root.add_child(slice)
    if not _check(slice.db!=null and not slice.db.boot_final_verified and
            slice.world.map_id==999 and slice.player==Vector2i(5,5) and
            slice.story.runner!=null and slice.bridge!=null,
            "new live scene uses actual FS GameState/VX interpreter/battle bridge not fake port"):return
    if not _check(slice.world.party_actor_ids==[1] and
            slice.db.record("troops",1).get("members",[]).size()==1,
            "source-shaped party and actual Troops table bound"):return

    var result:Dictionary=slice.interact_front()
    if not _check(bool(result.get("ok",false)) and
            slice.story.runner.waiting_kind=="message" and
            slice.dialogue._mode=="message" and
            slice.world.amount("item",1)==0,
            "chest VX 101 message waits before VX126 reward"):return
    if not _check(not bool(slice.save_checkpoint().get("ok",false)) and
            not bool(slice.load_checkpoint().get("ok",false)) and
            not slice.move_one_tile(Vector2i.RIGHT),
            "mid-event save/load and map motion blocked"):return
    slice.dialogue.advance_message()
    if not _check(slice.world.amount("item",1)==1 and
            slice.world.self_switch_on(999,1,"A") and
            not slice.story.runner.active,
            "chest event VX126 + selfswitch A committed exactly once"):return
    slice.interact_front()
    slice.dialogue.advance_message()
    if not _check(slice.world.amount("item",1)==1,
            "repeated chest cannot duplicate inventory"):return

    # Player physically walks to a fixed adjacent tile, cannot walk
    # through event 2 occupying (9,5).
    for i in range(3):
        slice.move_one_tile(Vector2i.RIGHT)
    if not _check(slice.player==Vector2i(8,5) and
            not slice.move_one_tile(Vector2i.RIGHT),
            "tile movement and sentinel collision"):return
    result=slice.interact_front()
    if not _check(bool(result.get("ok",false)) and
            slice.dialogue._mode=="message" and not slice.world.switch_on(10),
            "actual 101 sentinel scene before 301 battle"):return
    slice.dialogue.advance_message()
    if not _check(slice.battle!=null and slice.battle.active and
            slice.battle_overlay!=null and slice.battle_view!=null and
            slice.story.runner.waiting_kind=="battle" and
            slice.battle.enemies.size()==1,
            "VX301 creates real FSBattle and FSScreen native ACT GUI"):return
    if not _check(not bool(slice.save_checkpoint().get("ok",false)) and
            not slice.move_one_tile(Vector2i.DOWN),
            "cannot snapshot or move map mid live Battle301"):return
    var battle= slice.battle
    var native_ui=slice.battle_view
    native_ui._player_attack()
    if not _check("尚未就緒" in native_ui.log_label.text,
            "ACT cannot attack before ATB readiness"):return
    native_ui._process(2.0)
    if not _check(battle.ready_actors().has(0),
            "true Tankentai source ATB becomes ready"):return
    native_ui._player_attack()
    var enemy_button:Button=_button("測試木靈",native_ui.body)
    if not _check(enemy_button!=null and
            battle.source_atb_wait and
            "選擇敵方目標" in native_ui.title_label.text,
            "native BATTLE target-select opens and pauses ATB"):return
    enemy_button.pressed.emit()
    if not _check(battle.has_actor_pending_action(0) and
            int(battle.enemies[0]["hp"])==48 and
            not slice.world.switch_on(10),
            "source ACT command queued without premature damage/event reward"):return
    native_ui._process(1.0/60.0)
    if not _check(not battle.active and int(
            battle.enemies[0]["hp"])==0 and slice.world.switch_on(10) and
            slice.world.gold==50 and
            slice.story.runner.waiting_kind=="message" and
            slice.battles_completed==1,
            "native attack ACT kills enemy, real bridge resumes VX601, gold50 and victory message"):return
    await process_frame # Deferred removal of native battle UI
    if not _check(slice.battle_overlay==null and slice.battle==null and
            slice.dialogue._mode=="message",
            "after real battle story dialogue returns on map"):return
    slice.dialogue.advance_message()
    if not _check(not slice.story.runner.active and
            slice.world.gold==50 and slice.world.switch_on(10) and
            not slice.world.switch_on(11),
            "VX603 defeat branch skipped; one-time 601 reward persists"):return
    slice.interact_front()
    slice.dialogue.advance_message()
    if not _check(slice.world.gold==50,
            "revisit sentinel does not start repeat battle/award gold"):return

    # Walk around sentinel to map transfer marker.
    slice.move_one_tile(Vector2i.DOWN)
    for i in range(4):
        slice.move_one_tile(Vector2i.RIGHT)
    if not _check(slice.player==Vector2i(12,6) and
            not slice.move_one_tile(Vector2i.RIGHT) and
            slice.face==Vector2i.RIGHT,
            "blocking collision with map-999 portal marker"):return
    result=slice.interact_front()
    if not _check(bool(result.get("ok",false)) and
            slice.world.map_id==1000 and
            slice.player==Vector2i(3,6) and
            slice.story.runner.waiting_kind=="message",
            "VX201 transfer validates destination, updates SAME world before ACK"):return
    slice.dialogue.advance_message()
    for i in range(3):
        slice.move_one_tile(Vector2i.RIGHT)
    if not _check(slice.player==Vector2i(6,6) and
            not slice.move_one_tile(Vector2i.RIGHT),
            "ruins guardian blocks tile7,6"):return
    result=slice.interact_front()
    if not _check(bool(result.get("ok",false)) and
            slice.dialogue._mode=="message",
            "ruins guardian only accepts victory-flagged progress"):return
    slice.dialogue.advance_message()
    if not _check(slice.dialogue._mode=="choice" and
            slice.dialogue.choice_list.get_child_count()==2,
            "legacy VX102 choices rendered as clickable buttons"):return
    var choose:Button=slice.dialogue.choice_list.get_child(0)
    choose.pressed.emit()
    if not _check(slice.world.switch_on(20) and
            slice.world.self_switch_on(1000,2,"B") and
            slice.world.amount("item",1)==2 and
            slice.dialogue._mode=="message",
            "VX402 branch grants one herb and own selfswitch/quest switch"):return
    slice.dialogue.advance_message()
    if not _check(not slice.story.runner.active and
            slice.world.gold==50 and slice.world.amount("item",1)==2,
            "VX404 closes choice; no double reward from skipped branch"):return

    # Proper world save codec works in-memory only; no FileAccess writes.
    result=slice.save_checkpoint()
    if not _check(bool(result.get("ok",false)) and
            slice.checkpoint_json.length()>60 and
            str(result["sha256"]).length()==64,
            "checksum checkpoint JSON and memory-only UI save"):return
    var saved_map:int=slice.world.map_id
    var saved_pos:Vector2i=slice.player
    slice.world.gold=0
    slice.world.gain_item("item",1,-2)
    slice.world.set_switch(10,false)
    slice.move_one_tile(Vector2i.LEFT)
    result=slice.load_checkpoint()
    if not _check(bool(result.get("ok",false)) and
            slice.world.map_id==saved_map and
            slice.player==saved_pos and slice.world.gold==50 and
            slice.world.amount("item",1)==2 and
            slice.world.switch_on(10) and
            slice.world.self_switch_on(1000,2,"B"),
            "checkpoint restore result=%s actual=%s map=%d player=%s gold=%d item=%d sw10=%s selfB=%s" % [
                str(result),str(slice.checkpoint_json.left(230)),
                slice.world.map_id,str(slice.player),slice.world.gold,
                slice.world.amount("item",1),str(slice.world.switch_on(10)),
                str(slice.world.self_switch_on(1000,2,"B"))]):return
    var valid:String=slice.checkpoint_json
    var envelope:Dictionary=JSON.parse_string(valid)
    var original_inner:String=str(envelope["payload_json"])
    var tampered_inner:String=original_inner.replace(
        "\"gold\":50","\"gold\":99")
    if not _check(tampered_inner!=original_inner,
            "checksum test actually modifies the saved gold payload"):return
    envelope["payload_json"]=tampered_inner
    # Keep the ORIGINAL digest: valid data can never be silently
    # swapped merely by changing the nested JSON string.
    slice.checkpoint_json=JSON.stringify(envelope)
    if not _check(not bool(slice.load_checkpoint().get("ok",false)) and
            slice.world.gold==50,
            "tampered checksum never partially restores world"):return
    slice.checkpoint_json=valid
    var older:String=original_inner.replace(
        "fs_godot_story_checkpoint_v1","fs_godot_story_checkpoint_v0")
    envelope["payload_json"]=older
    envelope["sha256"]=older.sha256_text()
    var unsupported:Dictionary=CODEC.inspect(
        JSON.stringify(envelope))
    if not _check(not bool(unsupported.get("ok",false)) and
            slice.world.gold==50,
            "old checkpoint protocol/schemas cannot bypass integrity gate"):return
    if not _check(bool(slice.load_checkpoint().get("ok",false)),
            "valid restore remains available after failed import"):return
    print("FS P532 native Godot PLAYABLE 2 maps, VX101 chest, VX301 real ATB ACT boss kill, VX601 gold50, VX201 transfer, VX102 choices+quest, JSON SHA memory checkpoint PASS")
    quit(0)
