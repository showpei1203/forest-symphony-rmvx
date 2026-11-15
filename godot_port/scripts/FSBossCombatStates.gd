extends RefCounted
class_name FSBossCombatStates

# Bounded original RPG::State combat adapter, NOT generic 505-alias parity.
# Only post-Apply DB-verified state subsets (or explicitly synthetic tests)
# may be applied. Source: FS_MasterSetup STATES::DATA; ComboCore
# albert_apply_mana_shield (after Field404, before execute_damage);
# Tankentai Sprite_ATB.atb -> remove_states_auto at gauge READY.
# State128/129 have deterministic 100% expiry after 4/2 counters reach 0;
# any other timed/random or unknown effect fails closed.
const SUPPORTED: Array[int] = [77,122,123,124,125,126,127,128,129,
    140,141,142,143,150,151,152]
const TIMED: Dictionary = {128:4,129:2}
const STATS: Array[String] = ["atk","def","spi","agi"]
var active: bool = false
var errors: Array[String] = []
var transitions: Array[Dictionary] = []

func _fail(enemy: Dictionary,reason: String) -> bool:
    enemy["fs_boss_phase_effects_pending"] = true
    if not errors.has(reason):
        errors.append(reason)
    return false

static func _shield_data(note: String) -> Dictionary:
    var rx := RegEx.new()
    if rx.compile("(?i)<mana[_\\s]?shield\\s+([0-9]+)\\s*[: ,]\\s*([0-9]+)\\s*>") != OK:
        return {}
    var m: RegExMatch = rx.search(note)
    if m == null:
        return {}
    return {"capacity":int(m.get_string(1)),
        "rate":clampi(int(m.get_string(2)),0,100)}

static func _state(db: FSDatabase,id: int) -> Dictionary:
    if not SUPPORTED.has(id):
        return {}
    var state: Dictionary = db.record("states",id)
    if int(state.get("id",0)) != id:
        return {}
    # Only 128/129 may time out. Source #231 removes States on ATB READY;
    # the original Game_Battler#remove_states_auto decrements 4/2→0,
    # then removes with guaranteed auto_release_prob=100 next readiness.
    for required in ["atk_rate","def_rate","spi_rate","agi_rate",
            "hold_turn","auto_release_prob","restriction",
            "release_by_damage","slip_damage","state_set","note"]:
        if not state.has(required):
            return {}
    if TIMED.has(id):
        if int(state["hold_turn"]) != int(TIMED[id]) or int(
                state["auto_release_prob"]) != 100:
            return {}
    elif int(state["hold_turn"]) != 99 or int(
            state["auto_release_prob"]) != 0:
        return {}
    if int(state["restriction"]) != 0 or bool(
            state["release_by_damage"]) or bool(state["slip_damage"]):
        return {}
    if not bool(state.get("battle_only",false)) or bool(
            state.get("nonresistance",true)) or bool(
            state.get("offset_by_opposite",true)) or bool(
            state.get("reduce_hit_ratio",true)):
        return {}
    if not (state["state_set"] is Array) or not state["state_set"].is_empty():
        return {}
    for stat in STATS:
        var rate: int = int(state[stat+"_rate"])
        if rate <= 0 or rate > 500:
            return {}
    # The vetted Boss States only carry HUD metadata or one Mana Shield
    # tag. Do not quietly discard unknown source Note gameplay effects.
    var note: String = str(state["note"])
    var tags := RegEx.new()
    if tags.compile("<[^>]*>") != OK:
        return {}
    for match_result in tags.search_all(note):
        var tag: String = match_result.get_string()
        var header: String = tag.substr(1,tag.length()-2).strip_edges().to_lower()
        if header.begins_with("hud_"):
            continue
        if id == 77 and header.begins_with("mana_shield "):
            if not _shield_data(tag).is_empty():
                continue
        return {}
    if id == 77 and _shield_data(note).is_empty():
        return {}
    return state

static func _rates(db: FSDatabase,ids: Array) -> Dictionary:
    var rates: Dictionary = {}
    for stat in STATS:
        rates[stat] = 100.0
    for value in ids:
        var record: Dictionary = db.record("states",int(value))
        for stat in STATS:
            rates[stat] = float(rates[stat])*float(
                int(record.get(stat+"_rate",100)))/100.0
    return rates

func on_atb_ready(battle) -> int:
    # Native #231 Sprite_ATB.atb calls Game_Battler.remove_states_auto
    # precisely when a new ATB gauge reaches READY, before AI acts.
    # An ACT command or arbitrary 60fps frame must not age states.
    if not active or not battle.boss_runtime.active:
        return 0
    var removed: int = 0
    for enemy in battle.enemies:
        if not bool(enemy.get("source_just_atb_ready",false)):
            continue
        enemy.erase("source_just_atb_ready")
        var timers: Dictionary = enemy.get("fs_boss_state_turns",{}).duplicate()
        var owned: Array = enemy.get("fs_applied_boss_states",[]).duplicate()
        if owned.is_empty():
            continue
        var expired: Array[int] = []
        for value in owned:
            var id: int = int(value)
            if not TIMED.has(id):
                continue
            var key: String = str(id)
            if not timers.has(key):
                _fail(enemy,"Boss State%d ATB 期限計數遺失" % id)
                continue
            var left: int = int(timers[key])
            if left > 0:
                timers[key] = left-1
            else:
                # Only 100% expiry States are supported.
                expired.append(id)
        for id in expired:
            var planned: Array = enemy.get("fs_phase_state_intents",[]).duplicate()
            var current: Array = enemy.get("states",[]).duplicate()
            planned.erase(id)
            current.erase(id)
            owned.erase(id)
            timers.erase(str(id))
            enemy["fs_phase_state_intents"] = planned
            enemy["states"] = current
            removed += 1
            transitions.append({"enemy_id":int(enemy.get("id",0)),
                "state_id":id,"op":"auto_release_atb_ready",
                "stage":"bounded_live_state"})
        enemy["fs_applied_boss_states"] = owned
        enemy["fs_boss_state_turns"] = timers
        if not expired.is_empty():
            enemy["fs_boss_stat_rates"] = _rates(battle.db,owned)
    return removed

func sync(battle) -> int:
    if not active or not battle.boss_runtime.active:
        return 0
    var count: int = 0
    for enemy in battle.enemies:
        var planned: Array = enemy.get("fs_phase_state_intents",[])
        var previous: Array = enemy.get("fs_applied_boss_states",[])
        if planned.is_empty() and previous.is_empty():
            continue
        var confirmed: Array[int] = []
        var valid: bool = true
        for value in planned:
            var id: int = int(value)
            if confirmed.has(id):
                continue
            if _state(battle.db,id).is_empty():
                _fail(enemy,"Boss%d State%d 效果/期限/來源不完整" % [
                    int(enemy.get("id",0)),id])
                valid = false
                break
            confirmed.append(id)
        if not valid:
            continue
        var current: Array = enemy.get("states",[]).duplicate()
        for old in previous:
            current.erase(int(old))
        # Do not overwrite or silently absorb non-Boss states from other
        # script aliases: that would imply a false, full state implementation.
        if not current.is_empty():
            _fail(enemy,"Boss%d 存在未驗證的外部 RPG State" % int(
                enemy.get("id",0)))
            continue
        var was_shielded: bool = previous.has(77)
        var now_shielded: bool = confirmed.has(77)
        var timers: Dictionary = enemy.get("fs_boss_state_turns",{}).duplicate()
        for old in previous:
            if not confirmed.has(int(old)):
                timers.erase(str(int(old)))
        for id in confirmed:
            current.append(id)
            if TIMED.has(id) and not previous.has(id):
                timers[str(id)] = int(TIMED[id])
        enemy["states"] = current
        enemy["fs_applied_boss_states"] = confirmed
        enemy["fs_boss_stat_rates"] = _rates(battle.db,confirmed)
        enemy["fs_boss_state_turns"] = timers
        enemy["fs_boss_phase_effects_pending"] = false
        if not was_shielded and now_shielded:
            var data: Dictionary = _shield_data(str(
                battle.db.record("states",77).get("note","")))
            enemy["fs_boss_shield_remaining"] = int(data["capacity"])
            enemy["fs_boss_shield_rate"] = int(data["rate"])
        elif was_shielded and not now_shielded:
            enemy.erase("fs_boss_shield_remaining")
            enemy.erase("fs_boss_shield_rate")
        if previous != confirmed:
            count += 1
            transitions.append({"enemy_id":int(enemy.get("id",0)),
                "from":previous.duplicate(),"to":confirmed.duplicate(),
                "stage":"bounded_live_state"})
    return count

func stat(battler: Dictionary,name: String) -> int:
    var original: int = int(battler.get(name,0))
    if not active or not battler.has("fs_applied_boss_states"):
        return original
    var rates: Dictionary = battler.get("fs_boss_stat_rates",{})
    # VX original Game_Battler#atk/def/spi/agi clamps base to [1,999],
    # multiplies each state rate and Integer-truncates, then clamps again.
    var capped: int = clampi(original,1,999)
    return clampi(int(float(capped)*float(
        rates.get(name,100.0))/100.0),1,999)

func preview_hit(target: Dictionary,hp_damage: int) -> Dictionary:
    if bool(target.get("fs_boss_phase_effects_pending",false)):
        return {"ok":false,"reason":"Boss 的原始 State 效果尚未驗證"}
    var hp: int = hp_damage
    var mp: int = 0
    if active and hp_damage > 0 and target.get(
            "fs_applied_boss_states",[]).has(77):
        var remaining: int = maxi(0,int(target.get(
            "fs_boss_shield_remaining",0)))
        var rate: int = clampi(int(target.get(
            "fs_boss_shield_rate",0)),0,100)
        # ComboCore: int(hp_damage*rate/100.0), capped by both
        # remaining capacity and actual MP. Never invent absorption.
        mp = mini(mini(int(float(hp_damage)*float(rate)/100.0),
            remaining),maxi(0,int(target.get("mp",0))))
        hp -= mp
    return {"ok":true,"hp":hp,"mp":mp}

func commit_hit(target: Dictionary,hit: Dictionary) -> void:
    var hp: int = int(hit.get("hp",0))
    var mp: int = int(hit.get("mp",0))
    target["hp"] = maxi(0,int(target.get("hp",0))-hp)
    if mp > 0:
        target["mp"] = maxi(0,int(target.get("mp",0))-mp)
        var remaining: int = maxi(0,int(target.get(
            "fs_boss_shield_remaining",0))-mp)
        target["fs_boss_shield_remaining"] = remaining
        if remaining == 0:
            # ComboCore remove_state(77), then Boss #401 next update may
            # grant a new shield if the actual cores remain alive.
            var current: Array = target.get("states",[]).duplicate()
            current.erase(77)
            target["states"] = current
            var owned: Array = target.get("fs_applied_boss_states",[]).duplicate()
            owned.erase(77)
            target["fs_applied_boss_states"] = owned
            target["fs_boss_phase_effects_pending"] = true
