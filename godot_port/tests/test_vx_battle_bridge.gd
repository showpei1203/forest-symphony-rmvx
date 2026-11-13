extends SceneTree

# Synthetic event-to-battle-to-story-branch integration test.
# This is not numerical parity against the real FS database.
const D = preload("res://scripts/FSDatabase.gd")
const S = preload("res://scripts/FSGameState.gd")
const E = preload("res://scripts/FSVXEventInterpreter.gd")
const B = preload("res://scripts/FSVXBattleBridge.gd")

func _cmd(code: int, indent: int, params: Array = []) -> Dictionary:
    return {"code":code,"indent":indent,"parameters":params}

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var params: Array = []
    params.resize(600)
    params.fill(0)
    for i in range(100):
        params[i*6] = 120
        params[i*6+1] = 30
        params[i*6+2] = 20
        params[i*6+3] = 7
        params[i*6+4] = 10
        params[i*6+5] = 8
    var db = D.new()
    db.tables = {
        "actors":[null, {"id":1,"name":"測試主角","initial_level":5,"class_id":1,
            "parameters":{"xsize":6,"ysize":100,"data_int16":params}}],
        "enemies":[null, {"id":1,"name":"假想敵","maxhp":12,"maxmp":5,
            "atk":2,"def":2,"spi":2,"agi":2}],
        "weapons":[null],
        "armors":[null],
        "troops":[null, null, {"id":2,"members":[{"enemy_id":1,"hidden":false}],"pages":[]}]
    }
    var state = S.new()
    state.party_actor_ids.append(1)
    state.gain_item("item",5,2)
    var interpreter = E.new()
    root.add_child(interpreter)
    interpreter.setup(state)
    var bridge = B.new()
    root.add_child(bridge)
    bridge.bind(interpreter,db,state)
    var combats: Array = []
    bridge.combat_ready.connect(func(combat,tid) -> void: combats.append([combat,tid]))
    interpreter.start_event([
        _cmd(301,0,[0,2,true,true]),
        _cmd(601,0),
        _cmd(121,1,[10,10,0]),
        _cmd(602,0),
        _cmd(121,1,[11,11,0]),
        _cmd(603,0),
        _cmd(121,1,[12,12,0]),
        _cmd(604,0),
        _cmd(0,0)
    ],1,1)
    if combats.size() != 1 or not interpreter.waiting:
        push_error("VX 301 did not start a valid troop")
        quit(1)
        return
    var combat = combats[0][0]
    if combat.inventory.get("item:5",0) != 2:
        push_error("Story inventory not shared with BATTLE")
        quit(1)
        return
    combat.attack(combat.party[0],combat.enemies[0])
    if not state.switch_on(10) or state.switch_on(11) or state.switch_on(12):
        push_error("VX 601 victory branch not correctly selected")
        quit(1)
        return
    print("FS VX event -> BATTLE -> story branch smoke PASS (synthetic records)")
    quit(0)
