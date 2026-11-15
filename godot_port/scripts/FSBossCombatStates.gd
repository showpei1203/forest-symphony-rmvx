extends RefCounted
class_name FSBossCombatStates

# Bounded original RPG::State combat adapter, NOT generic 505-alias parity.
# Only post-Apply DB-verified state subsets (or explicitly synthetic tests)
# may be applied. Unsourced Notes, turn-expiring States 128/129, and unknown
# battler states fail closed. Source: FS_MasterSetup STATES::DATA; ComboCore
# albert_apply_mana_shield (HP damage after Field404, before execute_damage).
const SUPPORTED: Array[int] = [77,122,123,124,125,126,127,
    140,141,142,143,150,151,152]
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
    # Every supported source State is permanent until an explicit removal.
    # 128/129 are intentionally excluded: hold_turn4/2, auto_release100.
    for required in ["atk_rate","def_rate","spi_rate","agi_rate",
            "hold_turn","auto_release_prob","restriction",
            "release_by_damage","slip_damage","state_set","note"]:
        if not state.has(required):
            return {}
    if int(state["hold_turn"]) != 99 or int(
            state["auto_release_prob"]) != 0 or int(
            state["restriction"]) != 0 or bool(
            state["release_by_damage"]) or bool(state["slip_damage"]):
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
        var rates: Dictionary = {}
        for stat in STATS:
            rates[stat] = 100.0
        for id in confirmed:
            var record: Dictionary = battle.db.record("states",id)
            current.append(id)
            for stat in STATS:
                rates[stat] = float(rates[stat])*float(
                    int(record[stat+"_rate"]))/100.0
        enemy["states"] = current
        enemy["fs_applied_boss_states"] = confirmed
        enemy["fs_boss_stat_rates"] = rates
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
    # Ruby positive-stat truncation; state rate product retained as float.
    return maxi(1,int(float(original)*float(rates.get(name,100.0))/100.0))

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
