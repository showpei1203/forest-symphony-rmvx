extends SceneTree
# Real Godot adapter against original Ruby method outputs on identical synthetic states.
const RULE = preload("res://scripts/FSATBResistance.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const AI = preload("res://scripts/FSEnemyAIDecision.gd")
const RNG = preload("res://scripts/FSAIRandom.gd")
const ATB = preload("res://scripts/FSTankentaiATBCore.gd")
const STATE_AUTHORITY = preload("res://scripts/FSStateATBAuthority.gd")
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
    if not data is Dictionary or data.get("cases",[]).size()!=38:
        quit(2)
        return
    var matched: int = 0
    var shift_db = DB.new()
    var shift_battle = BATTLE.new(shift_db)
    for row: Dictionary in data["cases"]:
        var b: Dictionary = {"atb":float(row["before"])/1000.0,
            "source_atb_count":int(row["before"]),"source_act_count":73,
            "source_act_active":true,"source_at_active":false,"source_atb_count_up":false,
            "actor":bool(row["actor"]),"atb_resist_enabled":bool(row["enabled"]),
            "atb_resist_level":int(row["level"]),"atb_resist_max":4,
            "atb_resist_floor":int(row["floor"]),"atb_resist_recover":1}
        b["hp"] = 100
        shift_battle.party.clear()
        shift_battle.enemies.clear()
        shift_db.tables = {"states":[null,null,null,null,
            {"id":4,"atb_minus_damage":bool(row["allow_negative"])}]}
        var attacker: Dictionary = {"aizhuo_overload_pierce_percent":float(row["pierce"])}
        var out: Dictionary
        if bool(row["actor"]):
            shift_battle.party.append(b)
            out = shift_battle.apply_combo_atb_shift_to_actor(b,int(row["delta"]),attacker,int(row["state"]))
        else:
            shift_battle.enemies.append(b)
            out = shift_battle.apply_combo_atb_shift(b,int(row["delta"]),attacker,int(row["state"]))
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
        _check(equal,str(row["id"])+" expected="+JSON.stringify(expected)+" actual="+JSON.stringify(actual))
        if equal:
            matched += 1
        if str(row["id"]) in ["state_negative","actor_state_negative","zero_negative_plain","floor_blocked_negative"]:
            print("CRAFT_DIFF_FIXED_CASE; Case="+str(row["id"])+"; Ruby="+JSON.stringify(expected)+"; Godot="+JSON.stringify(actual))
        var recovered: int = RULE.after_valid_enemy_action(b)
        _check(recovered==int(row["recovered"]) and int(b["atb_resist_level"])==int(row["level_after_recovery"]),
            str(row["id"])+" recovery")
    # Additional guards on the actual battle adapter: no truthy string or
    # missing State record may silently grant negative debt.
    var guard_cases: int = 0
    for row: Dictionary in [{"id":4,"atb_minus_damage":"true"},{"id":4},{"id":9,"atb_minus_damage":true},{"id":4,"atb_minus_damage":false}]:
        var target: Dictionary = {"actor":false,"hp":100,"atb":0.05,
            "source_atb_count":50,"atb_resist_enabled":false}
        shift_battle.enemies.clear()
        shift_battle.party.clear()
        shift_battle.enemies.append(target)
        shift_db.tables = {"states":[null,null,null,null,row]}
        var guard_result: Dictionary = shift_battle.apply_combo_atb_shift(target,-140,{},4)
        _check(bool(guard_result.get("ok",false)) and int(target["source_atb_count"])==0,
            "invalid or false State authority must preserve zero floor")
        guard_cases += 1
    var debt: Dictionary = {"actor":true,"hp":100,"atb":-0.09,"source_atb_count":-90,
        "source_atb_count_up":true,"source_atb_gain_per_frame":10,"source_at_active":false,
        "source_act_active":false}
    var party: Array[Dictionary] = [debt]
    var enemies: Array[Dictionary] = []
    ATB.advance_frames(party,enemies,108)
    _check(int(debt["source_atb_count"])==990 and not bool(debt["source_at_active"]),
        "signed gauge needs 109 frames rather than 100")
    ATB.advance_frames(party,enemies,1)
    _check(int(debt["source_atb_count"])==1000 and bool(debt["source_at_active"]),
        "signed debt reaches READY on exact frame 109")
    print("CRAFT_DEBT_PROGRESS; Frames=109; SourceStart=-90; TypedGuards="+str(guard_cases))
    var note_matches: int = 0
    var pipeline_matches: int = 0
    _check(data.get("notes",[]).size()==12 and data.get("pipelines",[]).size()==8,
        "expanded original Note oracle complete")
    for row: Dictionary in data.get("notes",[]):
        var state: Dictionary = {"id":4,"note":str(row["note"])}
        var authority: Dictionary = STATE_AUTHORITY.resolve(state,4)
        var match_note: bool = bool(authority.get("ok",false)) and (
            bool(authority.get("damage_known",false))) and (
            int(authority.get("damage_percent",9999999))==int(row["damage"])) and (
            bool(authority.get("allows_negative",false))==bool(row["allows_negative"]))
        _check(match_note,"Note "+str(row["note"])+" "+JSON.stringify(authority))
        if match_note:
            note_matches += 1
    shift_battle.active = true
    shift_battle.source_atb_initialized = true
    for row: Dictionary in data.get("pipelines",[]):
        var b: Dictionary = {"actor":false,"hp":100,"atb":float(row["before"])/1000.0,
            "source_atb_count":int(row["before"]),"source_act_count":73,
            "source_act_active":true,"source_at_active":false,"source_atb_count_up":false,
            "atb_resist_enabled":true,"atb_resist_level":2,"atb_resist_max":4,
            "atb_resist_floor":10,"atb_resist_recover":1}
        shift_battle.party.clear()
        shift_battle.enemies.clear()
        shift_battle.enemies.append(b)
        shift_db.tables = {"states":[null,null,null,null,{"id":4,"note":str(row["note"])}]}
        var outcome: Dictionary = shift_battle.apply_source_state_atb_after_attach(b,4,float(row["bonus"]))
        var e: Array = row["expected"]
        var expected: Array = [int(e[0]),int(e[1]),int(e[2]),e[3],e[4],e[5]]
        var actual: Array = [b["source_atb_count"],b["atb_resist_level"],b["source_act_count"],
            b["source_act_active"],b["source_at_active"],b["source_atb_count_up"]]
        var match_pipeline: bool = bool(outcome.get("ok",false)) and actual==expected
        _check(match_pipeline,"State pipeline "+str(row["id"])+" expected="+JSON.stringify(expected)+" actual="+JSON.stringify(actual))
        if match_pipeline:
            pipeline_matches += 1
        print("CRAFT_STATE_PIPELINE; Case="+str(row["id"])+"; Ruby="+JSON.stringify(expected)+"; Godot="+JSON.stringify(actual))
    var precedence: Dictionary = STATE_AUTHORITY.resolve({"id":4,"note":"<ATB DAMAGE:-14><negative atb>",
        "atb_minus_damage":false,"atb_damage":-7},4)
    _check(bool(precedence.get("ok",false)) and not bool(precedence["allows_negative"]) and
        int(precedence["damage_percent"])==-7,"explicit typed method result wins")
    _check(not bool(STATE_AUTHORITY.resolve({"id":4,"note":"","atb_damage":1.5},4).get("ok",false)),
        "fractional method result rejected")
    _check(not bool(STATE_AUTHORITY.resolve({"id":4,"note":"<ATB DAMAGE:999999999999>"},4).get("ok",false)),
        "unbounded State note rejected")
    _check(not bool(shift_battle.apply_source_state_atb_after_attach({},4,0).get("ok",false)),
        "invalid target rejected before mutation")
    print("CRAFT_NOTE_PIPELINE_SUMMARY; Notes="+str(note_matches)+"; StatePipelines="+str(pipeline_matches)+"; AuthorityGuards=4")
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
    print("CRAFT_DIFF_SUMMARY; Matches="+str(matched)+"; StateGap=0; RecoveryCases=38; AIComparable="+str(ai_checked)+"; AIScopeHold=3; TypedGuards="+str(guard_cases)+"; Failures="+str(failures))
    quit(0 if failures==0 and matched==38 and guard_cases==4 and ai_checked==2 and note_matches==12 and pipeline_matches==8 else 1)
