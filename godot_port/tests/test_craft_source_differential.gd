extends SceneTree
# Real Godot adapter against original Ruby method outputs on identical synthetic states.
const RULE = preload("res://scripts/FSATBResistance.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const AI = preload("res://scripts/FSEnemyAIDecision.gd")
const RNG = preload("res://scripts/FSAIRandom.gd")
var failures: int = 0
func _initialize() -> void:
    call_deferred("_run")
func _check(ok: bool, detail: String) -> void:
    if not ok:
        failures += 1
        push_error("CRAFT_DIFF_FAIL "+detail)
func _run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size()!=1:
        quit(2)
        return
    var data = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
    if not data is Dictionary or data.get("cases",[]).size()!=31:
        quit(2)
        return
    var matched: int = 0
    var gaps: int = 0
    for row: Dictionary in data["cases"]:
        var b: Dictionary = {"atb":float(row["before"])/1000.0,
            "source_atb_count":int(row["before"]),"source_act_count":73,
            "source_act_active":true,"source_at_active":false,"source_atb_count_up":false,
            "actor":bool(row["actor"]),"atb_resist_enabled":bool(row["enabled"]),
            "atb_resist_level":int(row["level"]),"atb_resist_max":4,
            "atb_resist_floor":int(row["floor"]),"atb_resist_recover":1}
        var out: Dictionary = RULE.apply_direct_shift(b,int(row["delta"]),int(row["state"]),
            {"aizhuo_overload_pierce_percent":float(row["pierce"])})
        var actual: Array = [b["source_atb_count"],b["atb_resist_level"],b["source_act_count"],
            b["source_act_active"],b["source_at_active"],b["source_atb_count_up"]]
        # JSON numbers deserialize as floats in Godot. Normalize only exact
        # integer-valued counters; preserve booleans and reject fractions.
        var raw_expected: Array = row["expected"]
        for i in range(3):
            _check(float(raw_expected[i])==float(int(raw_expected[i])), "oracle counter not integral")
        var expected: Array = [int(raw_expected[0]),int(raw_expected[1]),int(raw_expected[2]),
            raw_expected[3],raw_expected[4],raw_expected[5]]
        var equal: bool = actual == expected and bool(out.get("ok",false))
        if bool(row["allow_negative"]):
            _check(int(expected[0]) == -90 and int(actual[0]) == 0 and actual.slice(1)==expected.slice(1),
                "negative State gap must be specifically observed")
            gaps += 1
            print("CRAFT_DIFF_GAP; Case="+str(row["id"])+"; Ruby="+JSON.stringify(expected)+"; Godot="+JSON.stringify(actual))
        else:
            _check(equal,str(row["id"])+" expected="+JSON.stringify(expected)+" actual="+JSON.stringify(actual))
            if equal:
                matched += 1
        var recovered: int = RULE.after_valid_enemy_action(b)
        _check(recovered==int(row["recovered"]) and int(b["atb_resist_level"])==int(row["level_after_recovery"]),
            str(row["id"])+" recovery")
    # Compare actual Godot AI selection, not only a copied predicate.
    var db = DB.new()
    var battle = BATTLE.new(db)
    battle.party.append({"id":1,"actor":true,"name":"Front","hp":400,
        "maxhp":500,"agi":20,"level":5,"odds":4,"states":[],"note":""})
    battle.enemies.append({"id":600,"actor":false,"name":"Healer","hp":100,
        "maxhp":200,"mp":100,"maxmp":100,"agi":10,"states":[],
        "note":"<enemy_attack_rate: 90>","actions":[]})
    var enemy: Dictionary = battle.enemies[0]
    var rng = RNG.new()
    var ai_checked: int = 0
    for row: Dictionary in data["urgent"]:
        db.tables = {"skills":[null,{"id":1,"name":"Probe","scope":int(row["scope"]),
            "mp_cost":10,"note":"","base_damage":int(row["damage"]),"atk_f":0,"spi_f":0,
            "plus_state_set":[],"minus_state_set":row["minus"],
            "damage_to_mp":false,"absorb_damage":false}]}
        enemy["actions"] = [{"kind":1,"basic":0,"skill_id":1,"rating":8,
            "condition_type":0,"condition_param1":0,"condition_param2":0}]
        rng.enable_test(47)
        var result: Dictionary = AI.choose(battle,0,rng)
        var id: String = str(row["id"])
        if id in ["damage","heal"]:
            var expected_kind: String = "skill" if bool(row["urgent"]) else "attack"
            _check(bool(result.get("ok",false)) and str(result.get("kind",""))==expected_kind,
                "AI "+id+" "+JSON.stringify(result))
            if bool(result.get("ok",false)) and str(result.get("kind",""))==expected_kind:
                ai_checked += 1
        else:
            _check(not bool(result.get("ok",false)), "AI unsupported "+id+" unexpectedly accepted")
            print("CRAFT_AI_SCOPE_HOLD; Case="+id+"; SourceUrgent="+str(row["urgent"])+"; Godot="+str(result.get("reason","")))
    print("CRAFT_FORCE_SOURCE_ONLY; OriginalDrainFixture="+JSON.stringify(data["force"])+"; GodotBehavior=NOT_TESTED")
    print("CRAFT_DIFF_SUMMARY; Matches="+str(matched)+"; StateGap="+str(gaps)+"; RecoveryCases=31; AIComparable="+str(ai_checked)+"; AIScopeHold=3; Failures="+str(failures))
    quit(0 if failures==0 and matched==30 and gaps==1 and ai_checked==2 else 1)
