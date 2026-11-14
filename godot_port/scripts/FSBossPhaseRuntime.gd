extends RefCounted
class_name FSBossPhaseRuntime

# Source: #401 Runtime Boss Provider, lines 415-489; data #440
# MasterSetup15. Original #404 Field Weather says weather IDs 153..158
# are GLOBAL FIELD EFFECTS, not per-battler States.
#
# IMPORTANT: This is an authoritative SOURCE-INTENT / PHASE-ID TRACKER.
# It does NOT call RPG::State add_state/remove_state, nor apply associated
# hit rate/defense, law-cycle (140..143), weather elemental damage,
# protection 77, awakening 128 or exposure 129 effects.
# Pending states are stored in fs_phase_state_intents, deliberately separate
# from battler.states. AI and actual attack costs must not mistake them
# for implemented gameplay state effects.

const PHASE_WEATHER: Dictionary = {548: [122,125,153,156], 549: [123,126,154,157], 550: [124,127,155,158]}
const LAW_STATES: Array[int] = [140,141,142,143]
const PHASE_STATES: Array[int] = [150,151,152]
const BOSS_PHASE_HP: int = 524
const SHIELD_BOSSES: Array[int] = [530,531]

var transitions: Array[Dictionary] = []
var failures: Array[String] = []
var weather_request: Dictionary = {}
var source_update_ticks: int = 0

static func _alive(enemies: Array[Dictionary],enemy_id: int) -> Dictionary:
    return FSBossSummonRuntime._member(enemies,enemy_id,true)

static func _ids(enemy: Dictionary) -> Array[int]:
    var res: Array[int] = []
    for v in enemy.get("fs_phase_state_intents",[]):
        var id: int = int(v)
        if not res.has(id):
            res.append(id)
    return res

static func _has(ids: Array[int],id: int) -> bool:
    return ids.has(id)

func _error(note: String) -> void:
    if not failures.has(note):
        failures.append(note)

func _write(enemy: Dictionary,boss_id: int,id: int,operation: String,
        db: FSDatabase) -> bool:
    var ids: Array[int] = _ids(enemy)
    if operation == "add":
        if ids.has(id):
            return true
        # State definitions come from the gated post-Apply DB. Don't even
        # publish a successful intent for an unknown original State.
        if db.record("states",id).is_empty():
            _error("Boss%d State%d 缺少啟動後原始資料" % [boss_id,id])
            return false
        ids.append(id)
    else:
        if not ids.has(id):
            return true
        ids.erase(id)
    enemy["fs_phase_state_intents"] = ids
    enemy["fs_boss_phase_effects_pending"] = true
    transitions.append({"boss_id":boss_id,"state_id":id,
        "op":operation,"stage":"intent_only"})
    return true

func _attempt_atomic(enemy: Dictionary,boss_id: int,
        removals: Array,additions: Array,db: FSDatabase) -> bool:
    # Source #401 uses real Game_Battler.add_state which invokes
    # multiple aliases. We only record consistent planned changes.
    # Validate EVERY new State before changing a single planned ID.
    for v in additions:
        var id: int = int(v)
        if not _ids(enemy).has(id) and db.record("states",id).is_empty():
            _error("Boss%d 狀態轉換缺少 State%d，整批意圖已拒絕" % [boss_id,id])
            return false
    for value in removals:
        if not _write(enemy,boss_id,int(value),"remove",db):
            return false
    for value in additions:
        if not _write(enemy,boss_id,int(value),"add",db):
            return false
    return true

func _phase524(battle) -> void:
    var boss: Dictionary = _alive(battle.enemies,BOSS_PHASE_HP)
    if boss.is_empty():
        return
    # Validate source HP before ANY phase mutation. An invalid battler must
    # never gain a seemingly legitimate initial State150 intent.
    var hp: int = int(boss.get("hp",0))
    var maxhp: int = int(boss.get("maxhp",0))
    if maxhp <= 0 or hp < 0 or hp > maxhp:
        _error("Boss524 HP/maxhp 非法，階段意圖暫停")
        return
    var states: Array[int] = _ids(boss)
    if not (states.has(150) or states.has(151) or states.has(152)):
        if not _attempt_atomic(boss,524,[],[150],battle.db):
            return
    if hp*100 <= maxhp*35:
        # Exact source removes 150/151 and all law states 140..143, then
        # adds 152 if absent. If source had 152 already from earlier
        # low-HP phase, heal does NOT automatically remove it.
        var removal: Array[int] = [150,151,140,141,142,143]
        if _attempt_atomic(boss,524,removal,[152],battle.db):
            boss["fs_law_cycle_authority_pending"] = false
    elif hp*100 <= maxhp*70:
        if _attempt_atomic(boss,524,[150],[151],battle.db):
            var law_running: bool = false
            for id in LAW_STATES:
                law_running = law_running or _ids(boss).has(id)
            if law_running:
                # A law is already represented: do not keep a stale
                # initialization request from a previous tick.
                boss["fs_law_cycle_authority_pending"] = false
            else:
                # Source expects albert_ant_initialize_law_cycle iff
                # respond_to? and no law state. The method's alias-chain
                # remains missing. No fake Law140 is inserted.
                boss["fs_law_cycle_authority_pending"] = true
                boss["fs_boss_phase_effects_pending"] = true
    # At HP >70 source makes no removal of previous phases.

func _weather(battle) -> void:
    # Source #401 visits 548,549,550 in insertion order, forcing field
    # each time; final living Boss in that order wins this update.
    # Source #404 stores weather in $game_temp.field_effect and source.
    # We only record the final INTENDED request, never apply damage.
    var pending: Dictionary = {}
    for boss_id in PHASE_WEATHER.keys():
        var boss: Dictionary = _alive(battle.enemies,int(boss_id))
        if boss.is_empty():
            continue
        var maxhp: int = int(boss.get("maxhp",0))
        if maxhp <= 0:
            _error("Boss%d maxhp 不合法" % int(boss_id))
            continue
        var specs: Array = PHASE_WEATHER[boss_id]
        var late: bool = int(boss.get("hp",0))*100 <= maxhp*55
        var phase_state: int = int(specs[1] if late else specs[0])
        var weather_id: int = int(specs[3] if late else specs[2])
        if battle.db.record("states",phase_state).is_empty() or (
                battle.db.record("states",weather_id).is_empty()):
            _error("Boss%d 天氣 State%d／Field%d 未匯入，拒絕假天氣" % [
                int(boss_id),phase_state,weather_id])
            continue
        if late:
            if not _attempt_atomic(boss,int(boss_id),
                    [int(specs[0])],[phase_state],battle.db):
                continue
        else:
            var current: Array[int] = _ids(boss)
            if not current.has(int(specs[0])) and not current.has(int(specs[1])):
                if not _attempt_atomic(boss,int(boss_id),[],[phase_state],battle.db):
                    continue
        pending = {"field_id":weather_id,"source_boss_id":int(boss_id),
            "force":true,"stage":"intent_only"}
        boss["fs_boss_weather_effects_pending"] = true
        boss["fs_boss_phase_effects_pending"] = true
    if not pending.is_empty():
        if weather_request != pending:
            weather_request = pending
            transitions.append({"op":"request_field","field_id":int(pending["field_id"]),
                "boss_id":int(pending["source_boss_id"]),"stage":"intent_only"})
    elif not weather_request.is_empty():
        # Source #404 clears when current field source is dead/hidden;
        # it does not clear merely because all phase Bosses are absent.
        var old_source: Dictionary = _alive(battle.enemies,
            int(weather_request.get("source_boss_id",-1)))
        if old_source.is_empty():
            weather_request = {}
            transitions.append({"op":"request_clear_field","stage":"intent_only"})

func _core_alive(battle,ids: Array) -> bool:
    for id in ids:
        if not _alive(battle.enemies,int(id)).is_empty():
            return true
    return false

func _shield(battle,summon_flags: Dictionary) -> void:
    # #401 Phase state shield77/awakening128 for Boss530/531,
    # followed by exposure129 for all CORE_GROUPS after a triggered start
    # or threshold wave and once no associated core remains alive.
    for boss_id in SHIELD_BOSSES:
        var boss: Dictionary = _alive(battle.enemies,boss_id)
        if boss.is_empty():
            continue
        var group: Array = FSBossSummonRuntime.CORE_GROUPS.get(boss_id,[])
        if _core_alive(battle,group):
            _attempt_atomic(boss,boss_id,[],[77],battle.db)
        else:
            _attempt_atomic(boss,boss_id,[77],[],battle.db)
        if int(boss.get("hp",0))*100 <= int(boss.get("maxhp",1))*45:
            _attempt_atomic(boss,boss_id,[],[128],battle.db)
    # Source iterates CORE_GROUPS in its original Ruby insertion order.
    for boss_id in FSBossSummonRuntime.CORE_GROUPS.keys():
        var boss: Dictionary = _alive(battle.enemies,int(boss_id))
        if boss.is_empty():
            continue
        var key: String = "exposed:%d" % int(boss_id)
        if summon_flags.has(key):
            continue
        if not summon_flags.has("start:%d" % int(boss_id)) and not (
                summon_flags.has("threshold:%d" % int(boss_id))):
            continue
        if _core_alive(battle,FSBossSummonRuntime.CORE_GROUPS[boss_id]):
            continue
        if _attempt_atomic(boss,int(boss_id),[],[129],battle.db):
            summon_flags[key] = true

func tick(battle,summon_flags: Dictionary) -> int:
    if not battle.active:
        return 0
    var before: int = transitions.size()
    source_update_ticks += 1
    _phase524(battle)
    _weather(battle)
    _shield(battle,summon_flags)
    return transitions.size()-before
