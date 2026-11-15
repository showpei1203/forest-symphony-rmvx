extends RefCounted
class_name FSBossLawCycle

# Original RGSS2 AntagonistCore (effective script #401 vicinity): law State
# sequence comes from the Enemy Note, NOT hard-coded for all bosses.
# This models ordered ID INTENTS only. RPG::State hit/guard/element effects,
# Game_Battler alias side effects, and original action resolution remain
# unavailable until the gated post-Apply source DB and engine parity exist.
var failures: Array[String] = []
var events: Array[Dictionary] = []

static func _capture(note: String,pattern: String) -> String:
    var rx := RegEx.new()
    if rx.compile(pattern) != OK:
        return ""
    var found: RegExMatch = rx.search(note)
    return found.get_string(1) if found != null else ""

static func configuration(enemy: Dictionary) -> Dictionary:
    var note: String = str(enemy.get("note",""))
    var list_text: String = _capture(note,
        "(?i)<law_cycle_states\\s*:\\s*([0-9,\\s]+)\\s*>")
    if list_text.is_empty():
        return {"tagged":false,"ok":false,"states":[]}
    var ids: Array[int] = []
    # Exact AntagonistCore parser uses raw.scan(/\\d+/), so repeated
    # commas/whitespace are ignored and duplicate IDs deduplicated.
    var numeric := RegEx.new()
    if numeric.compile("\\d+") != OK:
        return {"tagged":true,"ok":false,"states":[]}
    for match_result in numeric.search_all(list_text):
        var id: int = int(match_result.get_string())
        if id > 0 and not ids.has(id):
            ids.append(id)
    if ids.is_empty():
        return {"tagged":true,"ok":false,"states":[]}
    # Current authority <law_cycle_interval:N>, historical alias actions:N.
    # The native source defaults to 1 action, never to an invented 3.
    var interval_text: String = _capture(note,
        "(?i)<law_cycle_interval\\s*:\\s*([0-9]+)\\s*>")
    if interval_text.is_empty():
        interval_text = _capture(note,
            "(?i)<law_cycle_actions\\s*:\\s*([0-9]+)\\s*>")
    var condition_text: String = _capture(note,
        "(?i)<law_cycle_if_state\\s*:\\s*([0-9]+)\\s*>")
    return {"tagged":true,"ok":true,"states":ids,
        "interval":maxi(1,int(interval_text)) if not interval_text.is_empty() else 1,
        "condition":int(condition_text) if not condition_text.is_empty() else 0}

func _fail(enemy: Dictionary,reason: String) -> bool:
    enemy["fs_law_cycle_authority_pending"] = true
    enemy["fs_boss_phase_effects_pending"] = true
    if not failures.has(reason):
        failures.append(reason)
    return false

func reset(enemy: Dictionary) -> void:
    enemy["fs_law_active"] = false
    enemy["fs_law_index"] = 0
    enemy["fs_law_action_count"] = 0
    enemy["fs_law_cycle_authority_pending"] = false

func initialize(enemy: Dictionary,phase,db: FSDatabase) -> bool:
    var cfg: Dictionary = configuration(enemy)
    var enemy_id: int = int(enemy.get("id",0))
    if not bool(cfg.get("ok",false)):
        return _fail(enemy,"Enemy%d 缺少有效 law_cycle_states 原始 Note" % enemy_id)
    if int(cfg["condition"]) > 0 and not phase._ids(enemy).has(int(cfg["condition"])):
        return false
    # Atomic source-record validation: never clear the old cycle first.
    for state_id in cfg["states"]:
        if db.record("states",int(state_id)).is_empty():
            return _fail(enemy,"Enemy%d law State%d 缺少原始資料" % [
                enemy_id,int(state_id)])
    if not phase._attempt_atomic(enemy,enemy_id,cfg["states"],
            [int(cfg["states"][0])],db):
        return _fail(enemy,"Enemy%d law 初始化拒絕不完整狀態" % enemy_id)
    enemy["fs_law_active"] = true
    enemy["fs_law_index"] = 0
    enemy["fs_law_action_count"] = 0
    enemy["fs_law_cycle_authority_pending"] = false
    events.append({"op":"law_start","enemy_id":enemy_id,
        "state_id":int(cfg["states"][0]),"stage":"intent_only"})
    return true

func after_valid_action(enemy: Dictionary,phase,db: FSDatabase) -> bool:
    var cfg: Dictionary = configuration(enemy)
    if not bool(cfg.get("tagged",false)):
        return false
    if not bool(cfg.get("ok",false)):
        return _fail(enemy,"Enemy law Note 設定無效")
    var ids: Array[int] = cfg["states"]
    if int(cfg["condition"]) > 0 and not phase._ids(enemy).has(int(cfg["condition"])):
        # Original albert_ant_after_completed_action disables an active
        # law when law_cycle_if_state has disappeared.
        if bool(enemy.get("fs_law_active",false)):
            if not phase._attempt_atomic(enemy,int(enemy.get("id",0)),
                    ids,[],db):
                return false
            reset(enemy)
        return false
    if not bool(enemy.get("fs_law_active",false)):
        # Original first completed action initializes and RETURNS; it
        # does not count as the first rotation action.
        return initialize(enemy,phase,db)
    var idx: int = int(enemy.get("fs_law_index",0))
    if idx < 0 or idx >= ids.size() or not phase._ids(enemy).has(int(ids[idx])):
        return _fail(enemy,"Enemy law 輪替索引與已知狀態不同步")
    var count: int = int(enemy.get("fs_law_action_count",0))+1
    if count < int(cfg["interval"]):
        enemy["fs_law_action_count"] = count
        return false
    var next_idx: int = (idx+1)%ids.size()
    var current: int = int(ids[idx])
    var upcoming: int = int(ids[next_idx])
    if not phase._attempt_atomic(enemy,int(enemy.get("id",0)),
            [current],[upcoming],db):
        return _fail(enemy,"Enemy law 目標狀態缺少原版資料")
    enemy["fs_law_index"] = next_idx
    enemy["fs_law_action_count"] = 0
    events.append({"op":"law_rotate","enemy_id":int(enemy.get("id",0)),
        "from":current,"to":upcoming,"stage":"intent_only"})
    return true
