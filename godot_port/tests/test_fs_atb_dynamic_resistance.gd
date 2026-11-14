extends SceneTree

# FS #377 Boss-only direct ComboCore ATB delay, NOT full Tankentai base ATB.
const RULE = preload("res://scripts/FSATBResistance.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, info: String) -> bool:
    if not ok:
        push_error("FS source #377 dynamic ATB resistance FAIL: "+info)
        quit(1)
        return false
    return true

func _run() -> void:
    var db = DB.new()
    db.tables = {"enemies":[null,{
        "id":1,"name":"Guarded Boss","maxhp":1000,"maxmp":100,
        "atk":10,"def":10,"spi":10,"agi":20,
        "note":"<atb_dynamic_resist>\n<atb_resist_start:1>\n" +
          "<atb_resist_max:3>\n<atb_resist_floor:10>\n<atb_resist_recover:1>"
    },{
        "id":2,"name":"Normal Enemy","maxhp":100,"maxmp":10,
        "atk":5,"def":5,"spi":5,"agi":5,"note":""
    }]}
    var battle = BATTLE.new(db)
    if not _check(battle.add_enemy(1) and battle.add_enemy(2),
            "enemy instance created from true source-shaped note"): return
    var boss: Dictionary = battle.enemies[0]
    var ordinary: Dictionary = battle.enemies[1]
    if not _check(boss["atb_resist_enabled"] and boss["atb_resist_level"]==1 and
            boss["atb_resist_max"]==3 and boss["atb_resist_floor"]==10,
            "source Note parsing and start level"): return
    if not _check(not ordinary["atb_resist_enabled"],
            "ordinary monsters do not gain Boss-only resistance"): return
    boss["atb"] = 0.80
    var result: Dictionary = battle.apply_combo_atb_shift(boss,-200)
    if not _check(result.get("ok",false) and result["before"]==800 and
            result["after"]==660 and result["effective_delta"]==-140 and
            boss["atb_resist_level"]==2,
            "level1 70% of theoretical -200, +1 resistance level"): return
    result = battle.apply_combo_atb_shift(boss,-450)
    if not _check(result["before"]==660 and result["after"]==458 and
            result["effective_delta"]==-202 and boss["atb_resist_level"]==3,
            "level2 45% -450 =202 (truncated), resistance max capped3"): return
    boss["atb"] = 0.11
    result = battle.apply_combo_atb_shift(boss,-1000)
    if not _check(result["after"]==100 and result["actual_reduction"]==10 and
            boss["atb_resist_level"]==3,"cannot cross 10% ATB floor"): return
    boss["atb"] = 0.105
    result = battle.apply_combo_atb_shift(boss,-800)
    if not _check(result["after"]==100 and result["actual_reduction"]==5,
            "tiny actual reduction below 1% threshold"): return
    if not _check(battle.enemy_valid_action_completed(boss)==1 and
            boss["atb_resist_level"]==2,
            "valid enemy action recovers exactly one resistance level"): return
    boss["atb"] = 0.9
    result = battle.apply_combo_atb_shift(
        boss,-200,{"aizhuo_overload_pierce_percent":50.0})
    if not _check(result["before"]==900 and result["after"]==755 and
            boss["atb_resist_level"]==3,
            "Aizhuo pierce recovers 50% resisted share: (45+55*0.5)=72.5%"): return
    var level_before: int = int(boss["atb_resist_level"])
    result = battle.apply_combo_atb_shift(boss,-100,{},4)
    if not _check(result["after"]==655 and not result["resistance_applied"] and
            boss["atb_resist_level"]==level_before,
            "State ATB change is NOT intercepted by ComboCore dynamic resistance"): return
    result = battle.apply_combo_atb_shift(boss,80)
    if not _check(result["after"]==735 and not result["resistance_applied"],
            "positive ATB shift is not resisted"): return
    ordinary["atb"] = 0.50
    result = battle.apply_combo_atb_shift(ordinary,-350)
    if not _check(result["after"]==150 and not result["resistance_applied"],
            "normal enemy shifts without Boss-only floor or resistance"): return
    if not _check(battle.enemy_valid_action_completed(ordinary)==0,
            "normal enemy never gets resistance stack"): return
    if not _check(not battle.apply_combo_atb_shift({},-200).get("ok",false),
            "invalid target rejected"): return
    # Source SMALL_GAIN is zero, even if the 1% actual reduction threshold met.
    boss["atb_resist_level"] = 0
    boss["atb"] = 0.75
    result = battle.apply_combo_atb_shift(boss,-150)
    if not _check(result["after"]==600 and boss["atb_resist_level"]==0,
            "theoretical <=15% produces SMALL_GAIN=0"): return
    print("FS #377 Boss ATB resistance/note/stack/floor/pierce/recover/State isolation PASS")
    quit(0)
