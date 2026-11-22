extends SceneTree
# Only run in an owner-private checkout with the 505-source registry staged.
# Never refer to public CI synthetic fixtures as private source integration.
const REG=preload("res://scripts/source/FSUnifiedSourceRegistry.gd")
func _initialize()->void:
    call_deferred("_run")
func _fail(msg:String)->void:
    push_error("REAL FS 505 original-source proof failed: "+msg)
    quit(1)
func _run()->void:
    var r=REG.new()
    if not r.load_private_index():
        _fail("original complete 505 index unavailable: "+str(r.errors))
        return
    if not r.loaded or r.sections.size()!=505:
        _fail("not a real 505 source index")
        return
    for section in [69,70,89,193,196,231,232,264,268,269,375,381,462,481]:
        var info:Dictionary=r.section(section)
        if info.is_empty() or int(info.get("source_bytes",0))<=0:
            _fail("whole-source script missing or empty: "+str(section))
            return
    var methods:Dictionary={
        "Scene_Battle":["start","update_actor_command_selection"],
        "Window_BattleStatus":["initialize","refresh"],
        "Scene_Menu":["create_command_window"],
        "Game_Map":["battle_scapes"],
        "Spriteset_Battle":["create_battleback"]}
    for klass in methods:
        for method in methods[klass]:
            if r.evidence_for_method(klass,method).is_empty():
                _fail("global source candidate missing: "+klass+"#"+method)
                return
    if r.runtime_rgss_parity_passed():
        _fail("index must never claim RGSS2 code executed as Godot")
        return
    print("FS P539 PRIVATE SOURCE: original Scripts.rvdata 505/505 + 11 Data, UI/BATTLE/ATB/BattleScape/Menu 14 source sections and core methods WHOLE INDEX PASS; Ruby runtime parity NOT CLAIMED")
    quit(0)
