extends SceneTree

# Real Godot 4.7.2 OpenGL Ivy Cover QA viewport. Synthetic data only.
# Actor#5 source <ig:2,2,20> self-skill ACT -> enemy attack ->
# original-target HIT but Ivy own defense reroll and OD/charge transfer.
# No private VX post-Apply tables and no fabricated game sprite art.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const SCREEN = preload("res://scripts/FSScreen.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(msg: String) -> void:
    push_error("Godot Ivy Cover OpenGL screenshot FAIL: "+msg)
    quit(1)

func _actor(id: int,name: String,defense: int) -> Dictionary:
    var result: Dictionary={"id":id,"name":name,"actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "level":1,"atk":50,"def":defense,"spi":10,"agi":20,
        "hit":95,"eva":5,"cri":10,"od":0,
        "skills":[],"states":[],"equipment":[],"element_set":[],
        "note":"","fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true}
    if id==5:
        result["max_od"]=1000
        result["fs_ivy_guard_source_verified"]=true
        result["skills"]=[141]
    return result

func _run() -> void:
    var db=DB.new()
    var source_skills: Array=[]
    source_skills.resize(142)
    source_skills[141]={"id":141,"name":"荊棘護陣｜驗證子集合",
        "scope":11,"base_damage":0,"atk_f":0,"spi_f":0,
        "hit":100,"physical_attack":false,"variance":0,
        "mp_cost":8,"plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false,
        "element_set":[],"note":"<ig:2,2,20>",
        "fs_ivy_guard_tag_verified":true}
    db.tables={"enemies":[null,{
        "id":1,"name":"Synthetic Source Enemy",
        "maxhp":9000,"maxmp":200,"atk":50,"def":10,
        "spi":10,"agi":20,"hit":95,"eva":5,
        "has_critical":false,"actions":[],"note":""}],
        "weapons":[null],"armors":[null],"states":[null],
        "skills":source_skills}
    var b=BATTLE.new(db)
    b.party.append(_actor(1,"Protected Ally",10))
    b.party.append(_actor(5,"Ivy Main",20))
    if not b.add_enemy(1):
        _fail("enemy source record cannot create battler")
        return
    var enemy: Dictionary=b.enemies[0]
    enemy["level"]=1
    enemy["element_set"]=[]
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    enemy["fs_normal_element_neutral_verified"]=true
    b.accuracy.active=true
    b.normal_core.active=true
    b.ivy_cover.active=true
    b.source_atb_rolls_for_test={"actor:0":0,"actor:1":0,"enemy:0":0}
    if not b.start():
        _fail("native source-cover battle start refused")
        return
    var ivy: Dictionary=b.party[1]
    var protected: Dictionary=b.party[0]
    ivy["source_at_active"]=true
    ivy["source_atb_count_up"]=false
    ivy["source_atb_count"]=1000
    if not b.queue_actor_action(1,"skill",1,141):
        _fail("native Ivy Skill141 self-guard command refused")
        return
    b.advance_atb(9.0/60.0)
    if int(ivy["mp"])!=100 or int(ivy["fs_ivy_guard_charges"])!=0:
        _fail("Ivy shield illegally paid/activated before ACT charge")
        return
    b.advance_atb(1.0/60.0)
    if int(ivy["mp"])!=92 or int(ivy["fs_ivy_guard_charges"])!=2:
        _fail("Ivy ACT did not activate guard with MP8 once")
        return
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0,
        0,99,99,0,0]
    if b.attack(enemy,protected)!=62 or int(protected["hp"])!=1000 or (
            int(ivy["hp"])!=938 or int(ivy["od"])!=200 or int(
            ivy["fs_ivy_guard_charges"])!=1):
        _fail("actual source-Cover damage HP/OD/charge mismatch")
        return
    var window: Window=root
    window.size=Vector2i(1280,720)
    var view=SCREEN.new()
    view.db=b.db
    view.battle=b
    view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_child(view)
    view.title_label.text="Forest Symphony / Ivy COVER · SYNTHETIC Godot QA"
    view.log_label.text="Source Actor5 Skill141 ACT / Enemy HIT / Ivy redirected damage62, OD200"
    view._refresh_battle_status()
    if not ("護衛：Ivy Actor05" in view.status_label.text and
            "艾薇護衛:1 次" in view.status_label.text and
            "Ivy Main HP:938/1000" in view.status_label.text and
            "Protected Ally HP:1000/1000" in view.status_label.text and
            "MP:92/100 OD:200" in view.status_label.text):
        _fail("native Cover UI did not reflect actual model charge/OD/HP")
        return
    await process_frame
    await process_frame
    await process_frame
    var selected_font: Font=view.get_theme_default_font()
    if selected_font==null or not selected_font.has_char(0x827E) or not (
            selected_font.has_char(0x8587)) or not (
            selected_font.has_char(0x8B77)):
        _fail("real Godot selected SystemFont missing Chinese Ivy/Cover glyphs")
        return
    var dest: String=OS.get_environment("FS_IVY_QA_SCREENSHOT_PATH")
    if dest.is_empty():
        _fail("native screenshot destination not configured")
        return
    var png: Image=window.get_texture().get_image()
    if png==null or png.is_empty() or png.get_width()<640:
        _fail("native Godot rendered viewport image unavailable")
        return
    if png.save_png(dest)!=OK:
        _fail("native Godot Ivy Cover PNG save error")
        return
    var check:=FileAccess.open(dest,FileAccess.READ)
    if check==null or check.get_length()<1000:
        _fail("Godot OpenGL screenshot missing or tiny")
        return
    check.close()
    print("Godot 4.7.2 Ivy source Cover native OpenGL PNG PASS: ",
        png.get_width(),"x",png.get_height(),
        " original ally1000 Ivy938 MP92 OD200 charges1")
    quit(0)
