extends SceneTree

# Source #231 enemy ATB ready -> AI decision -> ACT -> apply -> recharge,
# with #211 roulette, #406 replacement, and #374 delay interrupts.
const DB = preload("res://scripts/FSDatabase.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> bool:
    if not ok:
        push_error("FS enemy ATB queue FAIL: "+label)
        quit(1)
        return false
    return true

func _row(kind: int,basic: int,skill_id: int) -> Dictionary:
    return {"kind":kind,"basic":basic,"skill_id":skill_id,"rating":8,
        "condition_type":0,"condition_param1":0,"condition_param2":0}

func _actor(hp: int = 500,agi: int = 10) -> Dictionary:
    return {"id":1,"actor":true,"name":"Forest Hero","hp":hp,"maxhp":500,
        "agi":agi,"def":5,"atk":10,"spi":3,"mp":50,"maxmp":50,
        "equipment":[0,0,0,0,0],"two_swords_style":false,
        "odds":4,"states":[],"note":""}

func _enemy(id: int,kind: int,skill_id: int = 0) -> Dictionary:
    return {"id":id,"actor":false,"name":"Forest Monster",
        "hp":300,"maxhp":300,"mp":50,"maxmp":50,"atk":20,"def":5,
        "spi":8,"agi":20,"note":"","states":[],
        "actions":[_row(kind,0,skill_id)],"atb":0.0}

func _db() -> FSDatabase:
    var db = DB.new()
    db.tables = {
        "skills":[null,null,{
            "id":2,"name":"Enemy Lightning","scope":1,
            "occasion":0,"base_damage":30,"atk_f":0,"spi_f":0,
            "mp_cost":10,"note":"","plus_state_set":[],"minus_state_set":[],
            "damage_to_mp":false,"absorb_damage":false
        },{
            "id":3,"name":"Enemy Heal","scope":7,
            "occasion":0,"base_damage":-20,"atk_f":0,"spi_f":0,
            "mp_cost":10,"note":"","plus_state_set":[],"minus_state_set":[],
            "damage_to_mp":false,"absorb_damage":false
        }],
        "weapons":[null],"armors":[null]
    }
    return db

func _battle(db: FSDatabase,world: FSGameState,enemy: Dictionary) -> FSBattle:
    var b = BATTLE.new(db,world)
    b.party.append(_actor())
    b.enemies.append(enemy)
    b.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    b.action_queue.ai_rng.enable_test(12345)
    return b

func _run() -> void:
    var db = _db()
    var world = WORLD.new()
    var battle = _battle(db,world,_enemy(1,0))
    if not _check(battle.start(),"source-shaped enemy attack battle starts"): return
    var hero: Dictionary = battle.party[0]
    var enemy: Dictionary = battle.enemies[0]
    battle.advance_atb(89.0/60.0)
    if not _check(int(hero["hp"])==500 and
            battle.action_queue.enemy_pending.is_empty() and
            int(enemy["source_atb_count"])==990,
            "before source frame90, enemy has not chosen command"): return
    battle.advance_atb(1.0/60.0)
    if not _check(int(hero["hp"])==500 and
            battle.action_queue.enemy_pending.size()==1 and
            enemy["source_act_count"]==0,
            "source frame90 chooses AI and ACT starts without damage"): return
    battle.advance_atb(1.0/60.0)
    if not _check(int(hero["hp"])==430 and
            int(enemy["source_atb_count"])==200 and
            battle.action_queue.enemy_pending.is_empty() and
            battle.action_queue.completed.size()==1,
            "source frame91 auto-attacks once and resets enemy ATB20%"): return
    battle.advance_atb(1.0/60.0)
    if not _check(int(hero["hp"])==430,
            "enemy cannot execute twice from one ACT completion"): return

    var skill_battle = _battle(db,world,_enemy(2,1,2))
    skill_battle.start()
    var caster: Dictionary = skill_battle.enemies[0]
    var victim: Dictionary = skill_battle.party[0]
    skill_battle.advance_atb(90.0/60.0)
    if not _check(skill_battle.action_queue.enemy_pending.size()==1 and
            int(caster["mp"])==50 and int(victim["hp"])==500,
            "enemy skill selected but no MP and damage until ACT"): return
    skill_battle.advance_atb(9.0/60.0)
    if not _check(int(caster["source_act_count"])==900 and
            int(caster["mp"])==50 and int(victim["hp"])==500,
            "9 of 10 source ACT frames do not spend enemy MP"): return
    skill_battle.advance_atb(1.0/60.0)
    if not _check(int(caster["mp"])==40 and int(victim["hp"])==470 and
            int(caster["source_atb_count"])==0,
            "source ACT frame10 resolves enemy one-opponent skill and MP10"): return

    var interrupted = _battle(db,world,_enemy(1,1,2))
    interrupted.start()
    interrupted.advance_atb(90.0/60.0)
    interrupted.advance_atb(5.0/60.0)
    var caster2: Dictionary = interrupted.enemies[0]
    if not _check(interrupted.action_queue.enemy_pending.size()==1 and
            int(caster2["source_act_count"])==500,
            "enemy mid-charge holds exactly one pending skill"): return
    var moved: Dictionary = interrupted.apply_combo_atb_shift(caster2,-200)
    if not _check(moved.get("ok",false) and
            interrupted.action_queue.enemy_pending.is_empty() and
            bool(caster2["source_atb_count_up"]) and
            not bool(caster2["source_act_active"]),
            "ComboCore negative ATB interrupts and cancels enemy ACT immediately"): return
    interrupted.advance_atb(0.5)
    if not _check(int(caster2["mp"])==50 and
            int(interrupted.party[0]["hp"])==500 and
            interrupted.action_queue.completed.is_empty(),
            "interrupted enemy skill never spends MP or causes delayed damage"): return

    var no_ai = _battle(db,world,_enemy(3,0))
    no_ai.enemies[0]["actions"] = []
    no_ai.start()
    no_ai.advance_atb(2.0)
    if not _check(no_ai.action_queue.enemy_pending.is_empty() and
            no_ai.action_queue.enemy_refusals.size()==1 and
            int(no_ai.party[0]["hp"])==500,
            "no source actions => report refusal once, never invent an attack"): return
    no_ai.advance_atb(2.0)
    if not _check(no_ai.action_queue.enemy_refusals.size()==1,
            "blocked AI must not spam refusal each rendered frame"): return

    var order = BATTLE.new(db,world)
    order.party.append(_actor(500,1))
    order.enemies.append(_enemy(4,0))
    order.enemies.append(_enemy(5,0))
    order.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0,"enemy:1":0}
    order.start()
    order.advance_atb(90.0/60.0)
    if not _check(order.action_queue.enemy_pending.size()==1 and
            order.action_queue.enemy_pending.has("enemy:0"),
            "two enemies simultaneously ready: first enemy queued first"): return
    order.advance_atb(1.0/60.0)
    if not _check(order.action_queue.enemy_pending.size()==2,
            "next source frame queues other ready enemy without skipping"): return
    order.advance_atb(1.0/60.0)
    if not _check(order.action_queue.completed.size()==1 and
            int(order.party[0]["hp"])==430,
            "first enemy ACT resolved, second pending remains"): return
    order.advance_atb(1.0/60.0)
    if not _check(order.action_queue.completed.size()==2 and
            int(order.party[0]["hp"])==360,
            "second enemy resolves next frame and not duplicate"): return

    print("FS enemy source ATB/ACT auto attack/skill, enemy MP, interrupt and two-enemy order PASS")
    quit(0)
