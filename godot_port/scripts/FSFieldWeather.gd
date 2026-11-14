extends RefCounted
class_name FSFieldWeather

# Forest Symphony #404 Field Weather Authority v1.3, bounded source
# implementation (lines 55-231 + 248-324). MasterSetup #440 constants.
#
# This is a SINGLE GLOBAL battle field. Do not duplicate Field153..158 into
# actors' or enemies' states arrays. Actual source RPG::State definitions
# must come from verified post-FS_DB_AUTOSET.apply_all data.
#
# Native synthetic tests may explicitly set active=true with source-shaped
# records. Ordinary runtime only enables this after FSDatabase gate passes.
# This does not certify last-wins 505-RGSS2 damage/element alias parity.
const WEATHER_IDS: Array[int] = [153,154,155,156,157,158]
const CONTEXT_WEATHER: Dictionary = {554:153,555:154,556:155}
const MIN_RATE: int = 25
const MAX_RATE: int = 175

var active: bool = false
var current_id: int = 0
var current_source: Dictionary = {}
var has_source: bool = false
var events: Array[Dictionary] = []
var errors: Array[String] = []

static func _rx(pattern: String) -> RegEx:
    var re := RegEx.new()
    if re.compile(pattern) != OK:
        push_error("Invalid FSFieldWeather source Note pattern")
    return re

static func _tag(note: String,pattern: String) -> bool:
    return _rx(pattern).search(note) != null

static func weather_state(state: Dictionary) -> bool:
    if state.is_empty():
        return false
    return int(state.get("id",0)) in WEATHER_IDS or _tag(
        str(state.get("note","")),"(?i)<\\s*field_weather\\s*>")

static func parse_state(state: Dictionary) -> Dictionary:
    # Exact #404 field_data line parser. Only the first matching branch
    # on each Note line is applied (priority, element, OR target-type).
    var result: Dictionary = {"priority":0,"damage":{},"target":[]}
    var priority_rx := _rx("(?i)<field_priority\\s*:\\s*([0-9]+)\\s*>")
    var damage_rx := _rx("(?i)<field_damage\\s+([0-9]+)\\s*:\\s*([+-]?[0-9]+)\\s*>")
    var target_rx := _rx("(?i)<field_target_type_damage\\s+([0-9]+)\\s*,\\s*([a-z_]+)\\s*:\\s*([+-]?[0-9]+)\\s*>")
    for line in str(state.get("note","")).split("\n"):
        var match_result: RegExMatch = priority_rx.search(line)
        if match_result != null:
            result["priority"] = int(match_result.get_string(1))
            continue
        match_result = damage_rx.search(line)
        if match_result != null:
            result["damage"][int(match_result.get_string(1))] = int(
                match_result.get_string(2))
            continue
        match_result = target_rx.search(line)
        if match_result != null:
            result["target"].append([
                int(match_result.get_string(1)),
                match_result.get_string(2).to_lower(),
                int(match_result.get_string(3))
            ])
    return result

static func priority(state: Dictionary) -> int:
    return int(parse_state(state)["priority"])

static func explicit_field_id(obj: Dictionary) -> int:
    var m: RegExMatch = _rx("(?i)<field[ _]effect\\s*:\\s*([0-9]+)\\s*>").search(
        str(obj.get("note","")))
    return int(m.get_string(1)) if m != null else 0

static func removes_field(obj: Dictionary) -> bool:
    return _tag(str(obj.get("note","")),"(?i)<remove[ _]field[ _]effect\\s*>")

static func context_weather_id(user: Dictionary,enemies: Array[Dictionary]) -> int:
    var id: int = int(user.get("id",0))
    if CONTEXT_WEATHER.has(id):
        return int(CONTEXT_WEATHER[id])
    if id != 510:
        return 0
    # Source #404 sorts core IDs: first living 554/555/556 wins.
    var ids: Array = CONTEXT_WEATHER.keys()
    ids.sort()
    for core_id in ids:
        for enemy in enemies:
            if int(enemy.get("id",0)) == int(core_id) and (
                    int(enemy.get("hp",0)) > 0) and not bool(
                    enemy.get("hidden",false)):
                return int(CONTEXT_WEATHER[core_id])
    return 0

static func requested_field_id(user: Dictionary,obj: Dictionary,
        enemies: Array[Dictionary]) -> int:
    var explicit: int = explicit_field_id(obj)
    if explicit > 0:
        return explicit
    if _tag(str(obj.get("note","")),"(?i)<field_context_weather\\s*>"):
        return context_weather_id(user,enemies)
    return 0

static func context_source(user: Dictionary,field_id: int,
        enemies: Array[Dictionary]) -> Dictionary:
    if int(user.get("id",0)) != 510:
        return user
    var ids: Array = CONTEXT_WEATHER.keys()
    ids.sort()
    for id in ids:
        if int(CONTEXT_WEATHER[id]) != field_id:
            continue
        for enemy in enemies:
            if int(enemy.get("id",0)) == int(id) and int(
                    enemy.get("hp",0)) > 0 and not bool(enemy.get("hidden",false)):
                return enemy
    return user

func _error(msg: String) -> bool:
    if not errors.has(msg):
        errors.append(msg)
    return false

func set_field(db: FSDatabase,id: int,source: Dictionary = {},
        force: bool = false) -> bool:
    if not active:
        return _error("原 VX 全域天氣權威未啟用")
    var state: Dictionary = db.record("states",id)
    if state.is_empty() or not weather_state(state):
        return _error("缺少或無法驗證原始天氣 State%d" % id)
    if current_id == id:
        # Source #404: refresh source for same field iff provided.
        if not source.is_empty():
            current_source = source
            has_source = true
        return true
    if not force and current_id > 0:
        var old: Dictionary = db.record("states",current_id)
        if old.is_empty():
            return _error("現有天氣 State%d 資料遺失" % current_id)
        if priority(old) > priority(state):
            return false
    current_id = id
    current_source = source
    has_source = not source.is_empty()
    events.append({"op":"set","field_id":id,"force":force,
        "source_id":int(source.get("id",0))})
    return true

func clear_field(db: FSDatabase,force: bool = false) -> bool:
    if not active:
        return _error("原 VX 全域天氣權威未啟用")
    if not force and current_id > 0:
        var state: Dictionary = db.record("states",current_id)
        if state.is_empty():
            return _error("目前天氣 State 資料已遺失")
        if priority(state) >= 20:
            return false
    if current_id == 0:
        return true
    events.append({"op":"clear","field_id":current_id,"force":force})
    current_id = 0
    current_source = {}
    has_source = false
    return true

func update_source(db: FSDatabase) -> void:
    if not active or not has_source:
        return
    # Source #404 source_alive?: only hidden or dead cancels a weather
    # source. Do not require membership in enemy roster for skills.
    if int(current_source.get("hp",1)) <= 0 or bool(
            current_source.get("hidden",false)):
        clear_field(db,true)

func field_state(db: FSDatabase) -> Dictionary:
    return db.record("states",current_id) if current_id > 0 else {}

func preview_damage(db: FSDatabase,target: Dictionary,
        elements: Variant,hp_damage: int,mp_damage: int,
        rate_damage: bool = false) -> Dictionary:
    # Source #404: percentage/rate-damage bypasses weather completely.
    if not active or current_id <= 0 or rate_damage:
        return {"ok":true,"hp":hp_damage,"mp":mp_damage,
            "rate":100,"delta":0,"applied":false}
    var state: Dictionary = field_state(db)
    if state.is_empty() or not weather_state(state):
        return {"ok":false,"reason":"目前全域天氣來源 State 尚未核對"}
    if not elements is Array:
        return {"ok":false,"reason":"傷害來源 element_set 尚未取得原版有效陣列"}
    var data: Dictionary = parse_state(state)
    var types: Array[String] = []
    if not data["target"].is_empty():
        # #404 reads @primary_element/@secondary_element. Source-shaped
        # explicit witness is required if the global field depends on it.
        if not bool(target.get("fs_element_types_verified",false)):
            return {"ok":false,
                "reason":"目標 primary/secondary_element 型態未具原 VX 證據"}
        for property in ["primary_element","secondary_element"]:
            if target.has(property) and str(target[property]) != "":
                var name: String = str(target[property]).to_lower()
                if not types.has(name):
                    types.append(name)
    var deltas: Array[int] = []
    for id_value in elements:
        if id_value == null:
            continue
        var id: int = int(id_value)
        var delta: int = int(data["damage"].get(id,0))
        for spec in data["target"]:
            if int(spec[0]) == id and types.has(str(spec[1])):
                delta += int(spec[2])
        deltas.append(delta)
    var combined: int = 0
    if not deltas.is_empty():
        var all_nonneg: bool = deltas.all(func(x: int) -> bool: return x >= 0)
        var all_nonpos: bool = deltas.all(func(x: int) -> bool: return x <= 0)
        if all_nonneg:
            combined = deltas.max()
        elif all_nonpos:
            combined = deltas.min()
        else:
            var sum: int = 0
            for n in deltas:
                sum += n
            combined = roundi(float(sum)/float(deltas.size()))
    var rate: int = clampi(100+combined,MIN_RATE,MAX_RATE)
    # Source #404 multiplies positive HP and MP damages; negative heals
    # and zero are unchanged. Ruby Float#round is half-away-from-zero.
    var hp: int = roundi(float(hp_damage)*float(rate)/100.0) if hp_damage>0 else hp_damage
    var mp: int = roundi(float(mp_damage)*float(rate)/100.0) if mp_damage>0 else mp_damage
    return {"ok":true,"hp":hp,"mp":mp,"delta":combined,
        "rate":rate,"applied":true,"field_id":current_id}

func apply_source_object(db: FSDatabase,user: Dictionary,obj: Dictionary,
        enemies: Array[Dictionary]) -> Dictionary:
    # Source #404 effect hooks run AFTER actual skill/item resolves.
    # This method only handles field setting/clearing. Effects and payment
    # belong to the calling verified action; never use it to bypass that gate.
    if not active:
        return {"ok":false,"reason":"全域天氣未啟用"}
    if removes_field(obj):
        return {"ok":clear_field(db,false),"kind":"clear"}
    var id: int = requested_field_id(user,obj,enemies)
    if id <= 0:
        return {"ok":true,"kind":"none"}
    var source: Dictionary = context_source(user,id,enemies)
    return {"ok":set_field(db,id,source,false),"kind":"set","field_id":id}
