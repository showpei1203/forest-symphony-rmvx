extends SceneTree

# The actual FSActionQueue connects Tankentai actor ready -> ACT -> action ->
# source recharge. All records are synthetic but shaped after source #230/231
# and FS SkillCost #411. No unpublished FS binaries are bundled in CI.
const DB = preload("res://scripts/FSDatabase.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("FS ATB action queue FAIL: " + detail)
        quit(1)
        return false
    return true

func _skill(id: int, note: String, cost: int = 10) -> Dictionary:
    return {
        "id":id,"name":"Skill %d" % id,"scope":1,"occasion":0,
        "mp_cost":cost,"note":note,"base_damage":10,"atk_f":0,"spi_f":0,
        "plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false,
        "ignore_defense":false
    }

func _run() -> void:
    var db = DB.new()
    db.tables = {
        "skills":[null,_skill(1,"<costo mp:25>"),
            _skill(2,"<costo hp:15>"),_skill(3,"")],
        "items":[null,{
            "id":1,"name":"Test Potion","scope":7,"occasion":0,
            "consumable":true,"note":"","hp_recovery":100,
            "hp_recovery_rate":0,"mp_recovery":0,"mp_recovery_rate":0,
            "base_damage":0,"atk_f":0,"spi_f":0,"variance":0,
            "element_set":[],"plus_state_set":[],"minus_state_set":[],
            "parameter_type":0,"parameter_points":0,"common_event_id":0
        }],
        "weapons":[null],"armors":[null]
    }
    var world = WORLD.new()
    world.gain_item("item",1,1)
    var battle = BATTLE.new(db,world)
    battle.party.append({
        "id":1,"actor":true,"name":"Actor01","skills":[1,2,3],
        "agi":20,"atk":20,"def":4,"spi":5,"hp":200,"maxhp":500,
        "mp":100,"maxmp":100,"guarding":false,
        "equipment":[0,0,0,0,0],"two_swords_style":false
    })
    battle.enemies.append({
        "id":1,"actor":false,"name":"Enemy","agi":10,"atk":10,
        "def":2,"spi":3,"hp":1000,"maxhp":1000,"mp":0,"maxmp":0
    })
    battle.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    if not _check(battle.start(),"can begin synthetic source-shaped battle"): return
    var actor: Dictionary = battle.party[0]
    var enemy: Dictionary = battle.enemies[0]

    if not _check(not battle.queue_actor_action(0,"attack",0) and
            battle.action_queue.pending.is_empty(),
            "no early attack at ATB 600/1000"): return
    battle.advance_atb(39.0/60.0)
    if not _check(not battle.ready_actors().has(0) and
            int(actor["source_atb_count"])==990,
            "source Actor01 unarmed ATB 600+39*10=990"): return
    battle.advance_atb(1.0/60.0)
    if not _check(battle.ready_actors()==[0],"actor ready on frame 40"): return

    var original_mp: int = int(actor["mp"])
    if not _check(not battle.queue_actor_action(0,"skill",0,2) and
            not battle.has_actor_pending_action(0) and int(actor["mp"])==original_mp,
            "unsupported HP payment rejected BEFORE ACT without MP"): return
    if not _check(battle.queue_actor_action(0,"skill",0,1),
            "supported Skill1 queues"): return
    if not _check(not battle.queue_actor_action(0,"skill",0,1) and
            battle.has_actor_pending_action(0),
            "cannot double-queue an actor's same ATB turn"): return
    if not _check(int(actor["mp"])==original_mp and int(enemy["hp"])==1000,
            "queued skill neither charges MP nor applies damage"): return
    battle.advance_atb(1.0/60.0)
    if not _check(int(actor["mp"])==original_mp-25 and
            int(enemy["hp"])==990 and not battle.has_actor_pending_action(0),
            "Skill1 ACT 1 frame: charge EXACT quote25 and deal effect once"): return
    if not _check(int(actor["source_atb_count"])==300 and
            battle.action_queue.completed.size()==1,
            "Skill1 source recharge30% and one completion receipt"): return
    battle.advance_atb(1.0/60.0)
    if not _check(int(actor["mp"])==original_mp-25 and int(enemy["hp"])==990,
            "next frame never replays the old completed command"): return

    battle.advance_atb(69.0/60.0)
    if not _check(battle.ready_actors().has(0),
            "actor charges from 310 to 1000 before item command"): return
    if not _check(battle.queue_actor_action(0,"item",0,1),
            "battle item requires ATB readiness and valid injured target"): return
    var hp_before_item: int = int(actor["hp"])
    battle.advance_atb(19.0/60.0)
    if not _check(int(actor["hp"])==hp_before_item and
            world.amount("item",1)==1 and battle.has_actor_pending_action(0),
            "Item1 source ACT20%: 19 frames do not consume item or heal"): return
    battle.advance_atb(1.0/60.0)
    if not _check(int(actor["hp"])==hp_before_item+100 and
            world.amount("item",1)==0 and not battle.has_actor_pending_action(0),
            "Item1 exact frame20 atomically heals and consumes once"): return

    battle.advance_atb(100.0/60.0)
    if not _check(battle.ready_actors().has(0),"item recharge0 then ATB full"): return
    if not _check(battle.queue_actor_action(0,"attack",0),
            "source physical attack queues after ATB"): return
    var hp_before_attack: int = int(enemy["hp"])
    battle.advance_atb(1.0/60.0)
    if not _check(int(enemy["hp"])<hp_before_attack and
            int(actor["source_atb_count"])==200,
            "physical attack ACT one frame then source recharge20%"): return
    var enemy_hp_after: int = int(enemy["hp"])
    battle.advance_atb(1.0/60.0)
    if not _check(int(enemy["hp"])==enemy_hp_after and
            battle.action_queue.completed.size()==3,
            "no duplicate attack execution or duplicate turn"): return

    battle.advance_atb(79.0/60.0)
    if not _check(battle.ready_actors().has(0) and
            battle.queue_actor_action(0,"guard"),
            "source guard queues only when ATB is ready"): return
    if not _check(not bool(actor["guarding"]),"guarding does not start at selection"): return
    battle.advance_atb(1.0/60.0)
    if not _check(bool(actor["guarding"]) and
            int(actor["source_atb_count"])==0 and
            battle.action_queue.completed.size()==4,
            "guarding only after ACT, source guard recharge0"): return

    # Real negative ComboCore #374 ATB shift interrupts ongoing ACT and
    # cancels the queued command; future gauge refills cannot execute it.
    battle.advance_atb(100.0/60.0)
    if not _check(battle.ready_actors().has(0) and
            battle.queue_actor_action(0,"skill",0,3),
            "regular skill ACT charge can begin"): return
    battle.advance_atb(5.0/60.0)
    var mp_before_interrupt: int = int(actor["mp"])
    var hp_before_interrupt: int = int(enemy["hp"])
    if not _check(battle.has_actor_pending_action(0) and
            int(actor["source_act_count"])==500,
            "five of ten ACT frames elapsed, no resource debit"): return
    var shifted: Dictionary = battle.apply_combo_atb_shift_to_actor(actor,-100)
    if not _check(bool(shifted.get("ok",false)) and
            not battle.has_actor_pending_action(0) and
            bool(actor["source_atb_count_up"]) and
            not bool(actor["source_act_active"]),
            "negative ComboCore shift cancels ACT and pending action instantly"): return
    battle.advance_atb(0.5)
    if not _check(int(actor["mp"])==mp_before_interrupt and
            int(enemy["hp"])==hp_before_interrupt and
            battle.action_queue.completed.size()==4,
            "interrupted skill never executes or charges MP later"): return

    # Revalidate target at EXECUTION, not just at selection.
    actor["source_at_active"] = true
    actor["source_atb_count_up"] = false
    actor["source_atb_count"] = 1000
    actor["atb"] = 1.0
    if not _check(battle.queue_actor_action(0,"skill",0,3),
            "target alive at selection allows queued skill"): return
    enemy["hp"] = 0
    var mp_before_invalid: int = int(actor["mp"])
    battle.advance_atb(10.0/60.0)
    if not _check(int(actor["mp"])==mp_before_invalid and
            not battle.has_actor_pending_action(0) and
            not bool(battle.action_queue.completed[-1]["success"]),
            "target death before ACT completion fails closed and spends no MP"): return

    print("FS source ATB queued commands, 20-frame item, single execution, late debit, cancel and invalid target PASS")
    quit(0)
