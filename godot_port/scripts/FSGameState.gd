@tool
extends RefCounted
class_name FSGameState

# Shared data used by the MENU, BATTLE and event interpreter.
# VX object IDs are preserved as integers, with 0 / false / empty defaults.
signal switch_changed(id: int, value: bool)
signal variable_changed(id: int, value: int)
signal inventory_changed(kind: String, id: int, count: int)

var switches: Dictionary = {}
var variables: Dictionary = {}
var self_switches: Dictionary = {}
var inventory: Dictionary = {} # item:1 / weapon:2 / armor:3
# Source VX Game_Actor HP/MP persist between battles, unlike ATB, guard,
# OD and battle-only State. No other battler-state parity is claimed.
var actor_vitals: Dictionary = {} # "actor_id" => {"hp":X,"mp":Y}
var gold: int = 0
var party_actor_ids: Array[int] = []
var map_id: int = 0
var map_x: int = 0
var map_y: int = 0

func switch_on(id: int) -> bool:
    return bool(switches.get(id, false))

func set_switch(id: int, enabled: bool) -> void:
    if id < 1:
        return
    switches[id] = enabled
    switch_changed.emit(id, enabled)

func variable(id: int) -> int:
    return int(variables.get(id, 0))

func set_variable(id: int, value: int) -> void:
    if id < 1:
        return
    var bounded: int = clampi(value, -99999999, 99999999)
    variables[id] = bounded
    variable_changed.emit(id, bounded)

func self_switch_on(source_map: int, event_id: int, letter: String) -> bool:
    return bool(self_switches.get("%d:%d:%s" % [source_map, event_id, letter], false))

func set_self_switch(source_map: int, event_id: int, letter: String, enabled: bool) -> void:
    if source_map < 1 or event_id < 1:
        return
    self_switches["%d:%d:%s" % [source_map, event_id, letter]] = enabled

func amount(kind: String, id: int) -> int:
    return int(inventory.get("%s:%d" % [kind,id], 0))

func gain_item(kind: String, id: int, delta: int) -> void:
    if id < 1 or not (kind in ["item", "weapon", "armor"]):
        return
    var key: String = "%s:%d" % [kind,id]
    inventory[key] = clampi(amount(kind,id) + delta, 0, 99)
    inventory_changed.emit(kind,id,int(inventory[key]))

func set_actor_vitals(actor_id:int,hp:int,mp:int)->void:
    if actor_id<1 or hp<0 or mp<0:
        return
    actor_vitals[str(actor_id)]={"hp":hp,"mp":mp}

func get_actor_vitals(actor_id:int)->Dictionary:
    var row:Variant=actor_vitals.get(str(actor_id),null)
    return row.duplicate(true) if row is Dictionary else {}

func as_save_dict() -> Dictionary:
    return {
        "switches":switches.duplicate(true),
        "variables":variables.duplicate(true),
        "self_switches":self_switches.duplicate(true),
        "inventory":inventory.duplicate(true),
        "gold":gold,"party_actor_ids":party_actor_ids.duplicate(),
        "actor_vitals":actor_vitals.duplicate(true),
        "map_id":map_id,"map_x":map_x,"map_y":map_y
    }

func restore_save_dict(data: Dictionary) -> void:
    # Numeric JSON dictionary keys become strings; accessors handle both.
    switches = {}
    for key in data.get("switches", {}):
        switches[int(key)] = bool(data["switches"][key])
    variables = {}
    for key in data.get("variables", {}):
        variables[int(key)] = int(data["variables"][key])
    self_switches = data.get("self_switches", {}).duplicate(true)
    inventory = data.get("inventory", {}).duplicate(true)
    # Older story files may omit vitals. This is a bounded HP/MP-only
    # restore, not arbitrary State/skill/equipment deserialization.
    actor_vitals = data.get("actor_vitals",{}).duplicate(true)
    gold = int(data.get("gold", 0))
    party_actor_ids.clear()
    for actor_id in data.get("party_actor_ids", []):
        party_actor_ids.append(int(actor_id))
    map_id = int(data.get("map_id", 0))
    map_x = int(data.get("map_x", 0))
    map_y = int(data.get("map_y", 0))
