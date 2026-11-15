extends SceneTree

# Godot 4.7.2 NATIVE rendered QA witness for the P1 smooth attack/skill
# source-shaped subset. This is NOT a screenshot of original RMVX content.
# Must execute under Xvfb/OpenGL, not an ImageDraw mock or Python raster.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const SCREEN = preload("res://scripts/FSScreen.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("FS Godot synthetic combat native screenshot FAIL: "+reason)
    quit(1)

func _db() -> FSDatabase:
    var db = DB.new()
    db.tables = {
        "states":[null],
        "weapons":[null],
        "armors":[null],
        "skills":[null,{
            "id":1,"name":"Test Physical Wave","scope":1,
            "occasion":0,"hit":95,"physical_attack":false,
            "base_damage":100,"atk_f":100,"spi_f":0,
            "has_critical":false,"variance":0,
            "mp_cost":10,"ignore_defense":false,
            "plus_state_set":[],"minus_state_set":[],
            "element_set":[13],"note":"",
            "damage_to_mp":false,"absorb_damage":false,
            "fs_smooth_source_verified":true}],
        "enemies":[null,{
            "id":1,"name":"Synthetic Training Guard","maxhp":1000,
            "maxmp":100,"atk":20,"def":10,"spi":10,
            "agi":20,"hit":95,"eva":5,"has_critical":false,
            "note":"","actions":[]}]}
    return db

func _run() -> void:
    var b = BATTLE.new(_db())
    b.party.append({"id":1,"name":"Source-Test Hero","actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,"level":1,
        "atk":50,"def":10,"spi":20,"agi":20,"hit":95,"eva":5,
        "cri":10,"skills":[1],"element_set":[13],"states":[],
        "equipment":[0,0,0,0,0],"two_swords_style":false,
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true,
        "fs_smooth_battler_verified":true})
    if not b.add_enemy(1):
        _fail("synthetic opponent fixture missing")
        return
    var target: Dictionary = b.enemies[0]
    target["fs_normal_source_verified"] = true
    target["fs_normal_enemy_note_verified"] = true
    target["fs_normal_element_neutral_verified"] = true
    target["fs_smooth_battler_verified"] = true
    target["fs_smooth_element_neutral_verified"] = true
    # Real native screenshot showcases Fire attack against Grass enemy.
    # This is a synthetic source-shaped elemental witness, not a pasted
    # label or fabricated original game screenshot.
    target["fs_element_authority"] = {"verified":true,
        "primary":"grass","secondary":"",
        "ranks":{"13":3},
        "extra_notes_verified":true,"extra_notes":[]}
    b.element_rates.active = true
    b.accuracy.active = true
    b.normal_core.active = true
    b.skill_core.active = true
    b.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    if not b.start():
        _fail("synthetic battle start refused")
        return
    var hero: Dictionary = b.party[0]
    # Actual source-candidate battles resolve damage BEFORE screenshot;
    # these are not artificially authored display labels.
    b.accuracy.scripted_rolls = [0,99,0,99,99,0,1]
    var normal_quote: Dictionary = b.normal_core.quote(b,hero,target)
    var normal_hit: int = b.attack(hero,target)
    if normal_hit != 174:
        _fail("source Fire200 normal expected174 actual%d quote=%s last_event=%s failures=%s rolls=%s" % [
            normal_hit,str(normal_quote),str(b.normal_core.events),
            str(b.normal_core.failures),str(b.accuracy.draws)])
        return
    b.accuracy.scripted_rolls = [0,99,99]
    if not b.use_skill(hero,target,1) or int(target["hp"]) != 457:
        _fail("native source Fire200% skill did not resolve HP1000-174-369=457")
        return
    var window: Window = root
    window.size = Vector2i(1280,720)
    var view = SCREEN.new()
    view.db = b.db
    view.battle = b
    view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_child(view)
    view.title_label.text = "Forest Symphony / Godot P1 SYNTHETIC combat QA"
    view.log_label.text = "Synthetic QA only | Original post-Apply VX witness NOT loaded"
    view._refresh_battle_status()
    if not ("普攻：FS舊核心→平滑防禦（來源限定）" in view.status_label.text and
            "技能：YEM RD→平滑防禦（來源限定）" in view.status_label.text and
            "元素：FS Phase28 十八屬性＋雙屬性倍率（來源限定）" in view.status_label.text and
            "HP:457/1000" in view.status_label.text):
        _fail("real native BATTLE HUD lacks active source modes and resulting HP")
        return
    # Allow native Control theme/fonts/render frames to be drawn. A manual
    # text export or synthetic image made outside Godot is NOT accepted.
    await process_frame
    await process_frame
    await process_frame
    var selected_font: Font = view.get_theme_default_font()
    # A valid PNG with Chinese rendered as square tofu is NOT a QA pass.
    # U+666E (普), U+4E2D (中) and U+6587 (文) must be present in the
    # actual theme font selected by the engine.
    if selected_font == null or not selected_font.has_char(0x666E) or not (
            selected_font.has_char(0x4E2D)) or not (
            selected_font.has_char(0x6587)):
        _fail("OS Chinese fallback font missing: native HUD still shows tofu")
        return
    var output_path: String = OS.get_environment("FS_QA_SCREENSHOT_PATH")
    if output_path.is_empty():
        _fail("QA screenshot output path missing")
        return
    var captured: Image = window.get_texture().get_image()
    if captured == null or captured.is_empty():
        _fail("native Godot viewport image not available")
        return
    if captured.get_width() < 640 or captured.get_height() < 360:
        _fail("native rendered viewport is unexpectedly too small")
        return
    var saved: Error = captured.save_png(output_path)
    if saved != OK:
        _fail("Godot native PNG save failed: "+str(saved))
        return
    var check := FileAccess.open(output_path,FileAccess.READ)
    if check == null or check.get_length() < 1000:
        _fail("native PNG missing or suspiciously tiny")
        return
    check.close()
    print("Godot 4.7.2 native synthetic BATTLE screenshot PASS; ",
        captured.get_width(),"x",captured.get_height(),
        "; source cores alive; real Fire200% HP457; PNG emitted")
    quit(0)
