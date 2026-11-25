extends RefCounted
class_name FSTroopForcePages

# Opt-in static subset of #21 Game_Troop.conditions_met?/setup_battle_event.
# Only span=0 (once per battle), HP / switch conditions and one typed
# basic/skill command 339. Unknown conditions/opcodes do not become no-ops.
var enabled: bool = false
var pages: Array[Dictionary] = []
var fired: Dictionary = {}
var blocked_reason: String = ""
var pending_page: int = -1
var pending_receipt_start: int = 0

static func _integer(v: Variant,low: int,high: int) -> bool:
    return typeof(v) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(v)) and (
        float(v)>=low and float(v)<=high and float(v)==float(int(v)))

func configure(raw: Array) -> bool:
    if enabled:
        return false # Never silently reset once-per-battle flags.
    var parsed: Array[Dictionary] = []
    for value in raw:
        if not value is Dictionary:
            return false
        var p: Dictionary = value
        if not _integer(p.get("span",null),0,0) or not p.get("condition",null) is Dictionary or not p.get("list",null) is Array:
            return false
        var c: Dictionary = p["condition"]
        for key in ["turn_ending","turn_valid","enemy_valid","actor_valid","switch_valid"]:
            if typeof(c.get(key,null))!=TYPE_BOOL:
                return false
        if c["turn_ending"] or c["turn_valid"] or c["actor_valid"] or (
                not c["enemy_valid"] and not c["switch_valid"]):
            return false
        if c["enemy_valid"] and (not _integer(c.get("enemy_index",null),0,9999) or not _integer(c.get("enemy_hp",null),0,100)):
            return false
        if c["switch_valid"] and not _integer(c.get("switch_id",null),1,1000000):
            return false
        var commands: Array = p["list"]
        if commands.size()!=2:
            return false
        if not commands[0] is Dictionary or not commands[1] is Dictionary:
            return false
        if not _integer(commands[0].get("code",null),339,339) or not _integer(commands[1].get("code",null),0,0):
            return false
        for command in commands:
            if not _integer(command.get("indent",null),0,0):
                return false
        if not commands[0].get("parameters",null) is Array:
            return false
        var params: Array = commands[0]["parameters"]
        if params.size()!=5 or not _integer(params[0],0,1) or (
                not _integer(params[1],0,9999)) or not _integer(params[2],0,1) or (
                not _integer(params[4],0,9999)):
            return false
        if int(params[2])==0 and not _integer(params[3],0,1):
            return false
        if int(params[2])==1 and not _integer(params[3],1,999999):
            return false
        if not commands[1].get("parameters",null) is Array or not commands[1]["parameters"].is_empty():
            return false
        parsed.append({"condition":c.duplicate(true),"params":params.duplicate()})
    pages=parsed
    enabled=true
    return true

func _eligible(battle,c: Dictionary) -> bool:
    if c["enemy_valid"]:
        var i: int = int(c["enemy_index"])
        if i>=battle.enemies.size():
            return false
        var enemy: Dictionary = battle.enemies[i]
        if int(enemy.get("maxhp",0))<=0:
            return false
        if float(enemy.get("hp",0))*100.0/float(enemy["maxhp"])>float(c["enemy_hp"]):
            return false
    if c["switch_valid"]:
        if battle.world==null or not battle.world.switch_on(int(c["switch_id"])):
            return false
    return true

func tick(battle) -> int:
    if not enabled or pending_page>=0 or not battle.active or not battle.force_actions.enabled or (
            not blocked_reason.is_empty()) or battle.force_actions.busy or (
            not battle.force_actions.troop_slot.is_empty()) or (
            not battle.force_actions.ready.is_empty()) or not battle.force_actions.staged.is_empty():
        return 0
    for i in range(pages.size()):
        if fired.has(i) or not _eligible(battle,pages[i]["condition"]):
            continue
        if not battle.queue_source_vx339(pages[i]["params"]):
            blocked_reason="Unverified or unavailable forced action on page %d" % i
            return -1
        pending_page=i
        battle.force_actions.troop_slot["page_ticket"]=i
        pending_receipt_start=battle.force_actions.completed.size()
        return 1
    return 0

# This candidate serializes page 339 until the actual synchronous forced
# action is acknowledged. A missing/rejected receipt is visible HOLD,
# rather than silently consuming the page. Not full VX interpreter timing.
func settle(battle) -> int:
    if pending_page<0:
        return 0
    var q = battle.force_actions
    if q.busy:
        return 0
    for i in range(pending_receipt_start,q.completed.size()):
        var receipt: Dictionary=q.completed[i]
        if int(receipt.get("page_ticket",-1))!=pending_page:
            continue
        var page_index: int=pending_page
        pending_page=-1
        if not bool(receipt.get("success",false)):
            blocked_reason="Force action did not settle successfully on page %d: %s" % [
                page_index,str(receipt.get("reason",""))]
            return -1
        fired[page_index]=true
        return 1
    if not q.troop_slot.is_empty() or not q.ready.is_empty() or not q.staged.is_empty():
        return 0
    blocked_reason="Missing force action settlement on page %d" % pending_page
    pending_page=-1
    return -1
