extends SceneTree

# Native Godot 4.7.2 OpenGL proof of actual Ivy145 source-only ACT,
# two applied State IDs, MP16, and source State85 actual Pain100%.
# User's real post-Apply VX DB and full Skill145 JP/ricarica are NOT
# used: SYNTHETIC SOURCE SHAPE, clearly labeled.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func _fail(reason:String)->void:
    push_error("FS Ivy145 native OpenGL capture FAIL: "+reason)
    quit(1)

func _actor()->Dictionary:
    return {"id":5,"name":"Ivy (SYNTHETIC)","actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":20,"spi":10,"agi":20,
        "hit":95,"eva":5,"cri":10,"od":0,
        "states":[],"skills":[145],
        "equipment":[0,0,0,0,0],"element_set":[],
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true,
        "fs_ivy_furnace_source_verified":true}

func _state(id:int)->Dictionary:
    var furnace:bool=id==85
    return {"id":id,"name":"痛苦熔爐" if furnace else "",
        "priority":290 if furnace else 5,
        "hold_turn":4 if furnace else 0,
        "auto_release_prob":100 if furnace else 0,
        "restriction":0,"release_by_damage":false,
        "battle_only":true,"atk_rate":100,"def_rate":100,
        "spi_rate":100,"agi_rate":100,
        "nonresistance":false,"offset_by_opposite":false,
        "reduce_hit_ratio":false,"slip_damage":false,
        "state_set":[],"note":"<store_cover_damage:150>\n<cover_store_cap_percent:300>\n<hud_priority:290>\n<hud_detail>" if furnace else ""}

func _run()->void:
    var db=DB.new()
    var states:Array=[]
    states.resize(101)
    states[85]=_state(85)
    states[100]=_state(100)
    var skills:Array=[]
    skills.resize(146)
    skills[145]={"id":145,"name":"痛苦熔爐（來源限定）",
        "scope":11,"occasion":1,"base_damage":0,"variance":0,
        "atk_f":0,"spi_f":0,"mp_cost":16,"hit":100,
        "physical_attack":false,"damage_to_mp":false,
        "absorb_damage":false,"ignore_defense":false,
        "element_set":[13,7],"plus_state_set":[85,100],
        "minus_state_set":[],"note":"",
        "fs_ivy_furnace_source_verified":true,
        "fs_furnace_fixture_only":true}
    db.tables={"skills":skills,"states":states,"weapons":[null],
        "armors":[null],"enemies":[null,{"id":1,"name":"Training Target",
        "maxhp":9000,"maxmp":100,"atk":50,"def":10,
        "spi":10,"agi":20,"hit":95,"eva":5,
        "has_critical":false,"note":"","actions":[]}]}
    var b=BATTLE.new(db)
    b.party.append(_actor())
    if not b.add_enemy(1):
        _fail("native source enemy missing")
        return
    var enemy:Dictionary=b.enemies[0]
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    enemy["fs_normal_element_neutral_verified"]=true
    enemy["level"]=1
    enemy["element_set"]=[]
    var src:Dictionary=b.ivy_pain_source.configure_fixture({
        "source":"ALBERT_CHARACTER_CORE_TAG_TEXT_v1",
        "actor_profile_tag_text":{"5":""}})
    if not bool(src.get("ok",false)):
        _fail("verified synthetic profile unavailable")
        return
    b.ivy_furnace.active=true
    b.ivy_pain.active=true
    b.normal_core.active=true
    b.accuracy.active=true
    b.source_atb_rolls_for_test={"actor:0":0,"enemy:0":0}
    if not b.start():
        _fail("real native Godot battle refused")
        return
    var ivy:Dictionary=b.party[0]
    ivy["source_at_active"]=true
    ivy["source_atb_count"]=1000
    ivy["source_atb_count_up"]=false
    if not b.queue_actor_action(0,"skill",0,145):
        _fail("source 145 native ACT self command refused")
        return
    b.advance_atb(10.0/60.0)
    if b.action_queue.completed.size()!=1 or not bool(
            b.action_queue.completed[0]["success"]) or int(
            ivy["mp"])!=84 or ivy["states"]!=[85,100] or int(
            ivy["fs_ivy_furnace_state_turns"]["85"])!=4:
        _fail("actual ACT source 145 state pair/MP16/timer4 mismatch")
        return
    # Actual source enemy attack demonstrates State85 effect, not a
    # synthesized UI-only "buff" value.
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]
    var hit:int=b.attack(enemy,ivy)
    if hit!=77 or int(ivy["hp"])!=923 or int(
            ivy["fs_ivy_stored_pain"])!=77:
        _fail("source State85 direct HP77 must create stored Pain77")
        return
    # 1st ATB-ready AFTER action: counter4 -> 3; keep both IDs.
    ivy["source_atb_count"]=999
    ivy["source_atb_count_up"]=true
    ivy["source_at_active"]=false
    b.advance_atb(1.0/60.0)
    if int(ivy["fs_ivy_furnace_state_turns"]["85"])!=3 or (
            ivy["states"]!=[85,100]):
        _fail("source first ATB READY state85 counter not3")
        return
    var window:Window=root
    window.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND
    window.size=Vector2i(1280,720)
    var view=SCREEN.new()
    view.db=b.db
    view.battle=b
    view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_child(view)
    view.title_label.text="Forest Symphony / Ivy 145 · SYNTHETIC Native QA"
    view.log_label.text="ACT 145：MP -16 → State85 + State100｜受傷77 → 蓄痛77｜第1次 ATB READY：4→3"
    view._refresh_battle_status()
    for label in ["Ivy (SYNTHETIC) HP:923/1000 MP:84/100",
            "痛苦熔爐：State85｜倒數 3",
            "State100：來源限定","蓄痛：77"]:
        if not (label in view.status_label.text):
            _fail("native Ivy Furnace CJK HUD missing: "+label)
            return
    await process_frame
    await process_frame
    await process_frame
    var font:Font=view.get_theme_default_font()
    if font==null or not font.has_char(0x75DB) or not font.has_char(0x7194):
        _fail("native Godot CJK Furnace glyphs missing")
        return
    var dest:String=OS.get_environment("FS_IVY_FURNACE_QA_SCREENSHOT_PATH")
    if dest.is_empty():
        _fail("required OpenGL screenshot path missing")
        return
    var png:Image=window.get_texture().get_image()
    if png==null or png.is_empty() or png.get_width()<640:
        _fail("Godot native OpenGL framebuffer unavailable")
        return
    if png.save_png(dest)!=OK:
        _fail("saving actual Furnace OpenGL PNG failed")
        return
    var file:FileAccess=FileAccess.open(dest,FileAccess.READ)
    if file==null or file.get_length()<1000:
        _fail("Furnace OpenGL PNG not readable or empty")
        return
    file.close()
    print("Godot4.7.2 native Ivy145 OPENGL PASS 1280x720, ACT10 MP84 states85+100, real HP923 Pain77, first READY state85 count3")
    quit(0)
