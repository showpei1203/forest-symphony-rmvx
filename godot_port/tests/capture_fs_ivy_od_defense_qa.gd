extends SceneTree

# Godot4.7.2 ACTUAL OpenGL rendered battle screenshot:
# source Skill142 innate OD shield and Ivy main Cover => +6% MaxOD
# before source guarded damage, threshold49%->55%; enemy HP damage
# independent actual guard; SYNTHETIC SOURCE SHAPE, not private VX DB.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func _fail(why:String)->void:
    push_error("Godot Ivy142 OpenGL QA FAIL: "+why)
    quit(1)

func _actor(id:int,name:String,df:int)->Dictionary:
    var out:Dictionary={"id":id,"name":name,"actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":df,"spi":10,"agi":20,
        "hit":95,"eva":5,"cri":10,"od":0,
        "element_set":[],"states":[],"skills":[],
        "equipment":[],"note":"",
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true}
    if id==5:
        out["skills"]=[142]
        out["max_od"]=1000
        out["fs_ivy_guard_source_verified"]=true
        out["fs_ivy_od_source_verified"]=true
        out["fs_ivy_pain_notes_verified"]=true
        out["fs_ivy_effective_notes"]=[""]
        out["fs_ivy_stored_pain"]=0
    return out

func _run()->void:
    var db=DB.new()
    var skills:Array=[]
    skills.resize(143)
    skills[142]={"id":142,"name":"怒意不熄","scope":0,
        "note":"<mechanic_passive>\n<jp cost:900>\n<jp level:10>\n<jp skill:141>\n<reduce_damage_if_od 50:12>\n<reduce_damage_per_od_percent:0.08>\n<hide>"}
    db.tables={"skills":skills,"weapons":[null],"armors":[null],
        "states":[null],"enemies":[null,{"id":1,"name":"Source Enemy",
        "maxhp":9000,"maxmp":100,"atk":50,"def":10,
        "spi":10,"agi":20,"hit":95,"eva":5,
        "has_critical":false,"actions":[],"note":""}]}
    var b=BATTLE.new(db)
    b.party.append(_actor(1,"Protected Ally",10))
    b.party.append(_actor(5,"Ivy Main",20))
    if not b.add_enemy(1):
        _fail("native enemy DB spawn failed")
        return
    var enemy:Dictionary=b.enemies[0]
    enemy["level"]=1
    enemy["element_set"]=[]
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    enemy["fs_normal_element_neutral_verified"]=true
    b.normal_core.active=true
    b.accuracy.active=true
    b.ivy_cover.active=true
    b.ivy_pain.active=true
    b.ivy_od_defense.active=true
    b.source_atb_rolls_for_test={
        "actor:0":0,"actor:1":0,"enemy:0":0}
    if not b.start():
        _fail("native source battle start rejected")
        return
    var ivy:Dictionary=b.party[1]
    var ally:Dictionary=b.party[0]
    ivy["od"]=490
    ivy["fs_ivy_guard_charges"]=2
    ivy["fs_ivy_guard_actions_left"]=3
    ivy["fs_ivy_guard_reduce"]=25
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0,
        0,99,99,0,0]
    var loss:int=b.attack(enemy,ally)
    if loss!=48 or int(ivy["hp"])!=952 or int(
            ally["hp"])!=1000 or int(ivy["od"])!=590 or int(
            ivy["fs_ivy_stored_pain"])!=48 or int(
            ivy["fs_ivy_guard_charges"])!=1 or (
            b.ivy_od_defense.events.is_empty()) or not (
            is_equal_approx(float(
            b.ivy_od_defense.events[-1]["rate"]),55.0)):
        _fail("real source 49% OD +6% -> 55%, Cover48, pain48, OD590 mismatch")
        return
    var window:Window=root
    window.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND
    window.size=Vector2i(1280,720)
    var view=SCREEN.new()
    view.db=b.db
    view.battle=b
    view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_child(view)
    view.title_label.text="Forest Symphony / Ivy 142 · SYNTHETIC Native QA"
    view.log_label.text="被動142：49% OD → 護衛 +6% → 55% ｜減傷16.4% → Cover48 HP｜蓄痛48"
    view._refresh_battle_status()
    for expected in ["怒意不熄：OD 59.0%",
            "傷害減免 16.72%","艾薇護衛：1 次",
            "蓄痛：48","Ivy Main HP:952/1000",
            "Protected Ally HP:1000/1000"]:
        if not (expected in view.status_label.text):
            _fail("CJK HUD did not reflect actual source: "+expected)
            return
    await process_frame
    await process_frame
    await process_frame
    var font:Font=view.get_theme_default_font()
    if font==null or not font.has_char(0x6012) or not font.has_char(0x610F):
        _fail("native Godot Source CJK glyphs not available")
        return
    var dest:String=OS.get_environment("FS_IVY_OD_QA_SCREENSHOT_PATH")
    if dest.is_empty():
        _fail("native OD screenshot path missing")
        return
    var img:Image=window.get_texture().get_image()
    if img==null or img.is_empty() or img.get_width()<640:
        _fail("native Godot OpenGL framebuffer not rendered")
        return
    if img.save_png(dest)!=OK:
        _fail("saving actual source OD screenshot failed")
        return
    var check:FileAccess=FileAccess.open(dest,FileAccess.READ)
    if check==null or check.get_length()<1000:
        _fail("Godot source OD screenshot invalid/empty")
        return
    check.close()
    print("Godot4.7.2 native Ivy142 OD Cover OpenGL QA PASS 1280x720 OD490->550 before damage, final590, HP952 pain48 source16.4pct")
    quit(0)
