extends SceneTree

# Original #404 FieldWeather v1.3: global state, source, precedence,
# element/type modifiers, mixed-element rounding, positive damage only.
const DB = preload("res://scripts/FSDatabase.gd")
const WEATHER = preload("res://scripts/FSFieldWeather.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,label: String) -> bool:
    if not ok:
        push_error("FS #404 FieldWeather source contract FAIL: " + label)
        quit(1)
        return false
    return true

func _db() -> FSDatabase:
    var db = DB.new()
    var states: Array = []
    states.resize(159)
    states[153] = {"id":153,"note":
        "<field_weather>\n<field_priority:10>\n" +
        "<field_damage 13:+25>\n<field_damage 9:-25>\n" +
        "<field_target_type_damage 9,flying:-25>"}
    states[154] = {"id":154,"note":"<field_priority:5>\n<field_damage 13:+5>"}
    states[155] = {"id":155,"note":"<field_priority:20>\n<field_damage 13:+999>"}
    states[156] = {"id":156,"note":"<field_priority:20>\n<field_damage 13:-300>"}
    states[157] = {"id":157,"note":"<field_priority:10>\n<field_damage 13:+15>"}
    states[158] = {"id":158,"note":"<field_priority:10>\n<field_damage 13:-25>"}
    db.tables={"states":states}
    return db

func _run() -> void:
    var db = _db()
    var weather = WEATHER.new()
    weather.active = true
    var core: Dictionary = {"id":554,"hp":100,"hidden":false}
    var target: Dictionary = {
        "id":1,"hp":1000,"primary_element":"flying",
        "secondary_element":"","fs_element_types_verified":true
    }
    if not _check(weather.set_field(db,153,core) and
            weather.current_id==153 and weather.has_source,
            "source 153 becomes one global field"): return
    if not _check(WEATHER.weather_state(db.record("states",153)) and
            WEATHER.weather_state(db.record("states",154)) and
            WEATHER.priority(db.record("states",153))==10,
            "weather IDs 153..158 are valid even if no field_weather tag"): return
    if not _check(not weather.set_field(db,154,core) and
            weather.current_id==153,
            "#404 lower priority field cannot overwrite old higher priority"): return

    var hit: Dictionary = weather.preview_damage(db,target,[13],100,10)
    if not _check(hit.get("ok",false) and
            hit["rate"]==125 and hit["hp"]==125 and hit["mp"]==13,
            "element13 +25 scales positive HP and MP with Ruby rounding"): return
    hit = weather.preview_damage(db,target,[13],-80,-20)
    if not _check(hit["hp"]==-80 and hit["mp"]==-20,
            "healing and negative MP gain not affected by weather"): return
    hit = weather.preview_damage(db,target,[13],100,0,true)
    if not _check(hit["hp"]==100 and not hit["applied"],
            "source KGC rate_damage? bypasses FieldWeather"): return
    hit = weather.preview_damage(db,target,[9],100,0)
    if not _check(hit["delta"]==-50 and hit["hp"]==50,
            "element9 -25 plus flying target -25 => half damage"): return
    hit = weather.preview_damage(db,target,[13,9],100,0)
    if not _check(hit["delta"]==-13 and hit["hp"]==87,
            "mixed +25/-50 takes rounded average -12.5 => -13"): return
    hit = weather.preview_damage(db,target,[13,15],100,0)
    if not _check(hit["delta"]==25 and hit["hp"]==125,
            "all nonnegative elements choose source max modifier"): return
    hit = weather.preview_damage(db,target,[9,15],100,0)
    if not _check(hit["delta"]==-50 and hit["hp"]==50,
            "all nonpositive elements choose source min modifier"): return
    hit = weather.preview_damage(db,target,[],100,0)
    if not _check(hit["rate"]==100 and hit["hp"]==100,
            "empty element list returns source 100pct"): return
    if not _check(not weather.preview_damage(
            db,{"hp":100},[9],100,0).get("ok",false),
            "target-type weather without original type witness fails closed"): return
    if not _check(not weather.preview_damage(
            db,target,null,100,0).get("ok",false),
            "unverified positive damage element_set fails closed"): return

    if not _check(weather.set_field(db,155,core) and
            weather.current_id==155,"priority20 may replace priority10"): return
    hit = weather.preview_damage(db,target,[13],100,0)
    if not _check(hit["rate"]==175 and hit["hp"]==175,
            "large positive modifier clamps to source 175pct"): return
    if not _check(not weather.clear_field(db,false) and
            weather.current_id==155,
            "#404 priority>=20 prevents normal remove-field skill"): return
    if not _check(weather.set_field(db,156,core,true),"forced Boss weather override"): return
    hit = weather.preview_damage(db,target,[13],100,0)
    if not _check(hit["rate"]==25 and hit["hp"]==25,
            "large negative modifier clamps to source 25pct"): return
    if not _check(weather.clear_field(db,true) and weather.current_id==0,
            "forced field clear succeeds"): return
    if not _check(weather.set_field(db,153,core),"recreate field for source test"): return
    var other: Dictionary = {"id":555,"hp":100}
    if not _check(weather.set_field(db,153,other) and
            weather.current_source["id"]==555,
            "source #404 same field refreshes owner, never adds second field"): return
    other["hp"] = 0
    weather.update_source(db)
    if not _check(weather.current_id==0,
            "original current_source dead clears global field even if weather id stable"): return

    var troop: Array[Dictionary] = [
        {"id":555,"hp":100,"hidden":false},
        {"id":554,"hp":100,"hidden":false},
        {"id":556,"hp":100,"hidden":false}
    ]
    var altar: Dictionary = {"id":510,"hp":100}
    var context_skill: Dictionary = {"note":"<field_context_weather>"}
    if not _check(WEATHER.requested_field_id(altar,context_skill,troop)==153 and
            WEATHER.context_source(altar,153,troop)["id"]==554,
            "altar510 picks lowest living core554 even when troop order reversed"): return
    troop[1]["hp"] = 0
    if not _check(WEATHER.requested_field_id(altar,context_skill,troop)==154,
            "dead core554 ignored, next 555 selects Field154"): return
    var explicit: Dictionary = {
        "note":"<field effect: 156>\n<field_context_weather>"
    }
    if not _check(WEATHER.requested_field_id(altar,explicit,troop)==156,
            "explicit Field156 tag outranks contextual altar weather"): return

    if not _check(weather.apply_source_object(
            db,altar,{"note":"<field effect: 154>"},troop)["ok"] and
            weather.current_id==154,
            "verified skill object can request source weather with valid State"): return
    if not _check(weather.apply_source_object(
            db,altar,{"note":"<remove field effect>"},troop)["ok"] and
            weather.current_id==0,
            "remove field effect clears ordinary priority weather"): return
    print("FS #404 global weather, target/element scaling, priority, source and context tags PASS")
    quit(0)
