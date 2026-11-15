extends SceneTree

# Actual Godot 4.7.2 OpenGL/Xvfb screenshot of Ivy Skill147:
# SOURCE SYNTHETIC only, never the user's original game art/database.
# ATB command -> 9 charge frames -> tenth actual ACT and late source
# 50% stored-pain bonus, successful HP damage, MP18 and pain cleared.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func _fail(why:String)->void:
    push_error("FS Ivy147 OpenGL native QA FAIL: "+why)
    quit(1)

func _run()->void:
    var db=DB.new()
    var skills:Array=[]
    skills.resize(148)
    skills[147]={"id":147,"name":"復仇重擊｜來源限定",
        "scope":1,"occasion":1,"hit":95,"physical_attack":true,
        "base_damage":100,"atk_f":100,"spi_f":0,
        "has_critical":false,"variance":0,"ignore_defense":false,
        "mp_cost":18,
        "note":"<revenge_from_cover:50>\n<consume_stored_cover>",
        "element_set":[1],"plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false,
        "fs_smooth_source_verified":true,
        "fs_ivy_revenge_source_verified":true}
    db.tables={"skills":skills,"states":[null],
        "weapons":[null],"armors":[null],
        "enemies":[null,{"id":1,"name":"Training Target",
            "maxhp":10000,"maxmp":1000,"atk":50,"def":10,
            "spi":10,"agi":20,"hit":95,"eva":5,
            "has_critical":false,"note":"","actions":[]}]}
    var b=BATTLE.new(db)
    b.party.append({"id":5,"name":"Ivy (SYNTHETIC)","actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":10,"spi":20,"agi":20,
        "hit":95,"eva":5,"cri":10,"od":0,
        "skills":[147],"equipment":[],"states":[],
        "element_set":[1],"note":"",
        "fs_smooth_battler_verified":true,
        "fs_ivy_pain_notes_verified":true,
        "fs_ivy_effective_notes":[],
        "fs_ivy_stored_pain":0})
    if not b.add_enemy(1):
        _fail("actual DB Enemy1 spawn failed")
        return
    b.enemies[0]["fs_smooth_battler_verified"]=true
    b.enemies[0]["fs_smooth_element_neutral_verified"]=true
    b.accuracy.active=true
    b.skill_core.active=true
    b.ivy_revenge.active=true
    b.source_atb_rolls_for_test={"actor:0":0,"enemy:0":0}
    if not b.start():
        _fail("actual native Godot battle start refused")
        return
    var ivy:Dictionary=b.party[0]
    var target:Dictionary=b.enemies[0]
    ivy["fs_ivy_stored_pain"]=401
    ivy["source_at_active"]=true
    ivy["source_atb_count_up"]=false
    ivy["source_atb_count"]=1000
    b.accuracy.scripted_rolls=[0,99,99]
    if not b.queue_actor_action(0,"skill",0,147):
        _fail("Ivy ACT command rejected by real FSBattle")
        return
    b.advance_atb(9.0/60.0)
    if int(ivy["mp"])!=100 or int(
            ivy["fs_ivy_stored_pain"])!=401 or int(
            target["hp"])!=10000:
        _fail("Ivy147 source pain or MP consumed prematurely during ACT")
        return
    b.advance_atb(1.0/60.0)
    if b.action_queue.completed.size()!=1 or not bool(
            b.action_queue.completed[0]["success"]) or int(
            ivy["mp"])!=82 or int(ivy["fs_ivy_stored_pain"])!=0 or int(
            target["hp"])!=9616 or b.ivy_revenge.events.size()!=1:
        _fail("actual 147 Skill ACT HP384 MP18 stored401->0 mismatch")
        return
    var window:Window=root
    window.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND
    window.size=Vector2i(1280,720)
    var view=SCREEN.new()
    view.db=b.db
    view.battle=b
    view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_child(view)
    view.title_label.text="Forest Symphony / Ivy REVENGE · SYNTHETIC Native QA"
    view.log_label.text="ATB Skill147 ACT：原版蓄痛401 × 50% = +200；基礎平滑184；總傷害384"
    view._refresh_battle_status()
    for expected in ["技能：YEM RD→平滑防禦（來源限定）",
            "蓄痛：0","復仇重擊：快照 401／追加傷害 200／已消耗 401",
            "Ivy (SYNTHETIC) HP:1000/1000 MP:82/100",
            "Training Target HP:9616/10000"]:
        if not (expected in view.status_label.text):
            _fail("source Ivy147 HUD missing: "+expected)
            return
    await process_frame
    await process_frame
    await process_frame
    var font:Font=view.get_theme_default_font()
    if font==null or not font.has_char(0x5FA9) or not (
            font.has_char(0x4EC7)) or not font.has_char(0x91CD):
        _fail("Godot native Chinese REVENGE font not installed")
        return
    var path:String=OS.get_environment("FS_IVY_REVENGE_QA_SCREENSHOT_PATH")
    if path.is_empty():
        _fail("screenshot path missing")
        return
    var shot:Image=window.get_texture().get_image()
    if shot==null or shot.is_empty() or shot.get_width()<640:
        _fail("real Godot OpenGL framebuffer screenshot unavailable")
        return
    if shot.save_png(path)!=OK:
        _fail("cannot save Ivy147 native screenshot")
        return
    var read:FileAccess=FileAccess.open(path,FileAccess.READ)
    if read==null or read.get_length()<1000:
        _fail("native PNG empty/unreadable")
        return
    read.close()
    print("FS Godot4.7.2 Ivy147 OpenGL native screenshot PASS ",
        shot.get_width(),"x",shot.get_height(),
        " actual HP384, MP18, pain401->0, Chinese HUD")
    quit(0)
