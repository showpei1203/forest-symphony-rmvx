extends Node
class_name FSVXBattleBridge

# Connects VX event 301 (Process Battle) with the actual FS battle candidate.
# Converts battle outcome to the original event's 601/602/603 branches.
# Does NOT promise Tankentai/ATB/AI numerical parity.
signal combat_ready(combat: FSBattle, troop_id: int)
signal battle_bridge_failed(reason: String)

var _runner: FSVXEventInterpreter
var _database: FSDatabase
var _world: FSGameState
var _combat: FSBattle
var _allow_escape: bool = false
var _allow_lose: bool = false

func bind(event_runner: FSVXEventInterpreter, db: FSDatabase, state: FSGameState) -> void:
    if _runner != null and _runner.battle_requested.is_connected(_on_battle_event):
        _runner.battle_requested.disconnect(_on_battle_event)
    _runner = event_runner
    _database = db
    _world = state
    _runner.battle_requested.connect(_on_battle_event)

func _on_battle_event(troop_id: int, can_escape: bool, can_lose: bool) -> void:
    var troop: Dictionary = _database.record("troops", troop_id)
    if troop.is_empty():
        _fail("原始 Troop ID %d 不存在" % troop_id)
        return
    # Full battle event pages must be interpreted by the final battle engine.
    # Do not make them silently disappear in the migration.
    for page in troop.get("pages", []):
        if not page is Dictionary:
            continue
        for command in page.get("list", []):
            if command is Dictionary and int(command.get("code",0)) != 0:
                _fail("Troop %d 含尚未移植的戰鬥事件頁，已阻擋" % troop_id)
                return
    if _world.party_actor_ids.is_empty():
        _fail("缺少可戰鬥的原始隊伍")
        return
    var combat := FSBattle.new(_database, _world)
    for actor_id in _world.party_actor_ids:
        if not combat.add_actor(actor_id):
            _fail("原始 VX Actor%d 不存在或裝備來源不完整" % actor_id)
            return
        # Stock VX actor HP/MP survive each battle. Restore only those
        # verified fields, never a stale ATB/OD/State from prior combat.
        var live:Dictionary=combat.party[-1]
        var vitals:Dictionary=_world.get_actor_vitals(actor_id)
        if not vitals.is_empty():
            if not vitals.has("hp") or not vitals.has("mp") or int(
                    vitals["hp"])<0 or int(vitals["mp"])<0:
                _fail("Actor%d 存續 HP/MP 來源不合法" % actor_id)
                return
            live["hp"]=clampi(int(vitals["hp"]),0,
                int(live.get("maxhp",1)))
            live["mp"]=clampi(int(vitals["mp"]),0,
                int(live.get("maxmp",0)))
    for member in troop.get("members", []):
        if not member is Dictionary:
            continue
        if bool(member.get("hidden", false)):
            _fail("Troop %d 有初始隱藏敵人，現有戰鬥原型尚未支援" % troop_id)
            return
        if not combat.add_enemy(int(member.get("enemy_id",0))):
            _fail("敵人編號與 Enemies.rvdata 不一致")
            return
    if not combat.start():
        _fail("Troop %d 或隊伍沒有有效成員" % troop_id)
        return
    _combat = combat
    _allow_escape = can_escape
    _allow_lose = can_lose
    _combat.finished.connect(_on_combat_finished)
    combat_ready.emit(_combat, troop_id)

func _commit_actor_vitals()->void:
    if _combat==null or _world==null:
        return
    for actor in _combat.party:
        if not bool(actor.get("actor",false)):
            continue
        var actor_id:int=int(actor.get("id",0))
        if actor_id<1:
            continue
        _world.set_actor_vitals(actor_id,
            clampi(int(actor.get("hp",0)),0,maxi(1,int(
                actor.get("maxhp",1)))),
            clampi(int(actor.get("mp",0)),0,maxi(0,int(
                actor.get("maxmp",0)))))

func _on_combat_finished(victory: bool) -> void:
    if _runner == null or not _runner.active:
        return
    if not victory and not _allow_lose:
        _fail("戰鬥失敗；原始 VX 此設定應交由 Game Over 流程，尚未移植")
        return
    _commit_actor_vitals()
    _runner.resolve_battle(0 if victory else 2)

func request_escape() -> bool:
    if _combat == null or not _combat.active or not _allow_escape or _runner == null:
        return false
    # Actual escape probability / ATB timing remain FS parity work.
    # This method is for a battle layer that already verified an escape succeeded.
    _commit_actor_vitals()
    _combat.active = false
    _runner.resolve_battle(1)
    return true

func _fail(message: String) -> void:
    battle_bridge_failed.emit(message)
    if _runner != null:
        _runner.abort_current(message)
