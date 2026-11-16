extends Control
class_name FSPlayableSlice

# PLAYABLE Godot vertical-slice host, using ALREADY-IMPLEMENTED:
# FSGameState + FSVXEventInterpreter 101/102/121/123/125/126/201/301
# + FSVXBattleBridge + actual FSBattle + FSScreen ACT battle UI.
# Two synthetic 32x32 test maps (not the user's A35 Ground/PAR), explicit
# "SYNTHETIC" labels. This is not a claim of complete original FS parity.
# Code/data persistent on GitHub; checkpoint is MEMORY-ONLY (no local files).
signal exit_requested()

const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const STORY=preload("res://scripts/story/FSStoryRuntime.gd")
const DIALOGUE=preload("res://scripts/story/FSDialoguePanel.gd")
const BRIDGE=preload("res://scripts/FSVXBattleBridge.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
const CODEC=preload("res://scripts/story/FSCheckpointCodec.gd")

const TILE:int=32
var db:FSDatabase
var world:FSGameState
var story:FSStoryRuntime
var dialogue:FSDialoguePanel
var bridge:FSVXBattleBridge
var battle:FSBattle
var battle_overlay:Control
var battle_view:Control
var player:Vector2i=Vector2i(5,5)
var face:Vector2i=Vector2i.LEFT
var status_label:Label
var instruction_label:Label
var checkpoint_json:String=""
var checkpoint_facing:Vector2i=Vector2i.LEFT
var last_error:String=""
var events_completed:int=0
var battles_completed:int=0

func _ready()->void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var face_font:=SystemFont.new()
    face_font.font_names=PackedStringArray([
        "Microsoft JhengHei","Noto Sans CJK TC","PingFang TC"])
    var palette:=Theme.new()
    palette.default_font=face_font
    palette.default_font_size=14
    theme=palette
    db=DATA.database()
    world=DATA.initial_state()
    player=Vector2i(world.map_x,world.map_y)
    story=STORY.new()
    story.name="StoryRuntime"
    add_child(story)
    story.runner.completed.connect(_on_event_completed)
    story.story_failed.connect(_on_story_failed)
    dialogue=DIALOGUE.new()
    dialogue.name="StoryDialogue"
    add_child(dialogue)
    dialogue.bind(story.runner)
    bridge=BRIDGE.new()
    bridge.name="VXBattleBridge"
    add_child(bridge)
    bridge.bind(story.runner,db,world)
    bridge.combat_ready.connect(_on_combat_ready)
    bridge.battle_bridge_failed.connect(_on_bridge_failed)
    story.runner.transfer_requested.connect(_on_transfer)
    _make_hud()
    _refresh_status()
    queue_redraw()

func _make_hud()->void:
    instruction_label=Label.new()
    instruction_label.name="SliceInstructions"
    instruction_label.position=Vector2(8,5)
    instruction_label.text="FS Godot 可玩流程｜合成地圖/角色，非原始素材"
    instruction_label.add_theme_color_override("font_color",Color(1,0.94,0.68))
    add_child(instruction_label)
    status_label=Label.new()
    status_label.name="SliceStatus"
    status_label.position=Vector2(8,26)
    status_label.add_theme_color_override("font_color",Color(0.93,0.97,0.94))
    add_child(status_label)
    var buttons:=HBoxContainer.new()
    buttons.name="SliceControls"
    buttons.position=Vector2(8,367)
    buttons.add_theme_constant_override("separation",6)
    add_child(buttons)
    for spec in [
        ["互動 E",Callable(self,"interact_front")],
        ["暫存 (記憶體)",Callable(self,"save_checkpoint")],
        ["讀取暫存",Callable(self,"load_checkpoint")],
        ["返回 FS 選單",Callable(self,"_request_exit")]]:
        var btn:=Button.new()
        btn.text=str(spec[0])
        btn.pressed.connect(spec[1])
        buttons.add_child(btn)

func _draw()->void:
    if world==null:
        return
    var map_id:int=world.map_id
    for y in range(2,DATA.HEIGHT):
        for x in range(DATA.WIDTH):
            var shade:Color=Color(0.105,0.21,0.155) if (
                map_id==DATA.MAP_FOREST) else Color(0.19,0.19,0.235)
            if (x+y)%2==0:
                shade=shade.lightened(0.065)
            draw_rect(Rect2(Vector2(x*TILE,y*TILE),Vector2(TILE,TILE)),shade)
            draw_rect(Rect2(Vector2(x*TILE,y*TILE),Vector2(TILE,TILE)),
                Color(0.38,0.5,0.36,0.13),false,1)
    var markers:Dictionary=DATA.map_markers(map_id)
    for spot in markers:
        var event_id:int=int(markers[spot])
        var p:Vector2=Vector2(spot*TILE)
        var shade:Color=Color(0.78,0.55,0.22)
        if event_id==2:
            shade=Color(0.37,0.67,0.94)
        if map_id==DATA.MAP_RUINS and event_id==2:
            shade=Color(0.83,0.6,0.86)
        draw_rect(Rect2(p+Vector2(6,5),Vector2(20,23)),shade)
        draw_rect(Rect2(p+Vector2(6,5),Vector2(20,23)),
            Color(1,0.97,0.82),false,2)
        if (map_id==DATA.MAP_FOREST and event_id==3) or (
                map_id==DATA.MAP_RUINS and event_id==1):
            draw_circle(p+Vector2(16,16),10,Color(0.22,0.84,0.92))
            draw_circle(p+Vector2(16,16),6,Color(0.07,0.17,0.22))
    draw_rect(Rect2(Vector2(player*TILE)+Vector2(8,7),
        Vector2(16,22)),Color(0.94,0.88,0.76))
    draw_circle(Vector2(player*TILE)+Vector2(16,8),
        7,Color(0.95,0.95,0.99))
    draw_circle(Vector2(player*TILE)+Vector2(16,16)+Vector2(face)*13,
        3,Color(1,0.92,0.35))

func _unhandled_key_input(event:InputEvent)->void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if _is_busy():
        return
    var direction:Vector2i=Vector2i.ZERO
    match event.keycode:
        KEY_UP,KEY_W:direction=Vector2i.UP
        KEY_DOWN,KEY_S:direction=Vector2i.DOWN
        KEY_LEFT,KEY_A:direction=Vector2i.LEFT
        KEY_RIGHT,KEY_D:direction=Vector2i.RIGHT
        KEY_E,KEY_ENTER,KEY_KP_ENTER:
            interact_front()
            get_viewport().set_input_as_handled()
            return
        _:
            return
    move_one_tile(direction)
    get_viewport().set_input_as_handled()

func _is_busy()->bool:
    return story!=null and story.runner!=null and (
        story.runner.active or battle_overlay!=null)

func move_one_tile(direction:Vector2i)->bool:
    if _is_busy() or direction==Vector2i.ZERO:
        return false
    face=direction
    var next:Vector2i=player+direction
    if next.x<0 or next.x>=DATA.WIDTH or next.y<2 or (
            next.y>=DATA.HEIGHT) or DATA.map_markers(
            world.map_id).has(next):
        queue_redraw()
        return false
    player=next
    world.map_x=player.x
    world.map_y=player.y
    _refresh_status()
    queue_redraw()
    return true

func interact_front()->Dictionary:
    if _is_busy():
        return {"ok":false,"reason":"目前劇情或戰鬥尚未結束"}
    var target:Vector2i=player+face
    var event_id:int=int(DATA.map_markers(world.map_id).get(target,0))
    if event_id<=0:
        last_error="前方沒有可互動物件"
        _refresh_status()
        return {"ok":false,"reason":last_error}
    var commands:Array=DATA.event(world.map_id,event_id,world)
    if commands.is_empty():
        last_error="事件資料不存在，未執行"
        _refresh_status()
        return {"ok":false,"reason":last_error}
    last_error=""
    return story.interact_legacy_vx(
        commands,world,world.map_id,event_id)

func _on_transfer(map_id:int,x:int,y:int,_direction:int)->void:
    # VX transfer is a PAUSED coroutine. Only ACK after a complete
    # destination validation. Never silently teleport to map0.
    var spot:Vector2i=Vector2i(x,y)
    if DATA.map_name(map_id).is_empty() or x<0 or (
            x>=DATA.WIDTH) or y<2 or y>=DATA.HEIGHT or (
            DATA.map_markers(map_id).has(spot)):
        story.runner.abort_current("VX 201 指向不存在或阻擋的目標地點")
        return
    world.map_id=map_id
    world.map_x=x
    world.map_y=y
    player=spot
    face=Vector2i.DOWN
    _refresh_status()
    queue_redraw()
    story.runner.acknowledge_transfer()

func _on_combat_ready(combat:FSBattle,_troop_id:int)->void:
    if battle_overlay!=null:
        story.runner.abort_current("重複的 VX Battle301，拒絕覆蓋")
        return
    battle=combat
    battle_overlay=Control.new()
    battle_overlay.name="LiveBattleOverlay"
    battle_overlay.set_anchors_and_offsets_preset(
        Control.PRESET_FULL_RECT)
    add_child(battle_overlay)
    battle_view=SCREEN.new()
    battle_view.name="LiveBattleUI"
    battle_view.db=db
    battle_view.world=world
    battle_view.battle=combat
    battle_view.set_anchors_and_offsets_preset(
        Control.PRESET_FULL_RECT)
    battle_overlay.add_child(battle_view)
    # Event bridge resolves 601/603. UI is removed AFTER that callback
    # returns so resulting message windows appear above the map.
    combat.finished.connect(_on_battle_finished)

func _on_battle_finished(_victory:bool)->void:
    battles_completed+=1
    call_deferred("_close_battle_overlay")

func _close_battle_overlay()->void:
    if battle_overlay==null:
        return
    battle_overlay.queue_free()
    battle_overlay=null
    battle_view=null
    battle=null
    _refresh_status()
    queue_redraw()

func _on_bridge_failed(reason:String)->void:
    last_error=reason
    call_deferred("_close_battle_overlay")
    _refresh_status()

func _on_event_completed()->void:
    events_completed+=1
    last_error=""
    _refresh_status()
    queue_redraw()

func _on_story_failed(reason:String)->void:
    last_error=reason
    _refresh_status()

func _refresh_status()->void:
    if status_label==null or world==null:
        return
    status_label.text="%s (%d,%d)｜藥草 ×%d｜金錢 %d｜木靈%s｜%s" % [
        DATA.map_name(world.map_id),player.x,player.y,
        world.amount("item",1),world.gold,
        "已擊退" if world.switch_on(10) else "未擊退",last_error]

func save_checkpoint()->Dictionary:
    if _is_busy():
        return {"ok":false,"reason":"事件／戰鬥中不可保存半完成狀態"}
    var encoded:Dictionary=CODEC.pack(world)
    if bool(encoded.get("ok",false)):
        checkpoint_json=str(encoded["json"])
        checkpoint_facing=face
        last_error="已暫存（記憶體，非永久雲端存檔）"
    else:
        last_error=str(encoded.get("reason","未知存檔錯誤"))
    _refresh_status()
    return encoded

func load_checkpoint()->Dictionary:
    if _is_busy():
        return {"ok":false,"reason":"事件／戰鬥中不可讀取"}
    var inspected:Dictionary=CODEC.inspect(checkpoint_json)
    if not bool(inspected.get("ok",false)):
        last_error=str(inspected.get("reason","無有效暫存"))
        _refresh_status()
        return inspected
    # State restore only after checksum, schema, destination and party
    # have been independently validated; failed loads are atomic.
    world.restore_save_dict(inspected["world"])
    player=Vector2i(world.map_x,world.map_y)
    face=checkpoint_facing
    last_error="暫存已讀取（僅本次執行有效）"
    _refresh_status()
    queue_redraw()
    return {"ok":true}

func _request_exit()->void:
    if _is_busy():
        last_error="先完成目前事件／戰鬥，再返回選單"
        _refresh_status()
        return
    exit_requested.emit()
