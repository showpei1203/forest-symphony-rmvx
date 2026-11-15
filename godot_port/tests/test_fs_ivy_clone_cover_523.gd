extends SceneTree

# Source: ALBERT_IVY_CLONE v1.6.2 ~244544/245100/248105-248280
# Real Godot FSBattle.run HP/OD and Tankentai owner ACT; synthetic clone
# profile IDs are not claimed to be real original FS actor names.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,reason: String) -> bool:
    if not ok:
        push_error("FS Ivy Clone Cover 523 native FAIL: "+reason)
        quit(1)
        return false
    return true

func _actor(id:int,n:String,defense:int)->Dictionary:
    return {"id":id,"name":n,"actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":defense,"spi":10,"agi":20,
        "hit":95,"eva":5,"cri":10,"od":0,
        "element_set":[],"states":[],"skills":[],
        "equipment":[],"note":"",
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true}

func _battle() -> FSBattle:
    var db=DB.new()
    db.tables={"enemies":[null,{"id":1,"name":"Source enemy",
        "maxhp":3000,"maxmp":100,"atk":50,"def":10,
        "spi":10,"agi":20,"hit":95,"eva":5,
        "has_critical":false,"actions":[],"note":""}],
        "weapons":[null],"armors":[null],"states":[null]}
    var b=BATTLE.new(db)
    var original:Dictionary=_actor(1,"Low HP Friend",10)
    original["hp"]=499
    b.party.append(original)
    var ivy:Dictionary=_actor(5,"Main Ivy",20)
    ivy["max_od"]=1000
    ivy["fs_ivy_guard_source_verified"]=true
    b.party.append(ivy)
    var clone:Dictionary=_actor(103,"Verified Ivy Clone",20)
    clone["fs_clone_role"]="ivy"
    clone["fs_clone_role_source_verified"]=true
    b.party.append(clone)
    b.add_enemy(1)
    var enemy:Dictionary=b.enemies[0]
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    enemy["fs_normal_element_neutral_verified"]=true
    enemy["element_set"]=[]
    enemy["level"]=1
    b.accuracy.active=true
    b.normal_core.active=true
    b.ivy_cover.active=true
    b.source_atb_rolls_for_test={
        "actor:0":0,"actor:1":0,"actor:2":0,"enemy:0":0}
    return b

func _roll(b:FSBattle) -> void:
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0,
        0,99,99,0,0]

func _run() -> void:
    var b:FSBattle=_battle()
    if not _check(b.start(),"actual Godot battle starts"):return
    var target:Dictionary=b.party[0]
    var ivy:Dictionary=b.party[1]
    var clone:Dictionary=b.party[2]
    var enemy:Dictionary=b.enemies[0]
    _roll(b)
    var initial_od:int=int(ivy["od"])
    if not _check(initial_od==100 and not bool(
            clone.get("fs_ivy_clone_guard_used",false)),
            "source battle starts main Ivy OD +10%, clone unused"):return
    var before_target:int=int(target["hp"])
    var damage:int=b.attack(enemy,target)
    if not _check(damage==65 and int(target["hp"])==before_target and
            int(clone["hp"])==935 and bool(
            clone.get("fs_ivy_clone_guard_used",false)) and
            bool(clone.get("fs_ivy_clone_guarded",false)) and
            int(ivy["od"])==120 and
            str(b.ivy_cover.events[-1]["guard_type"])=="clone" and
            b.accuracy.scripted_rolls.is_empty(),
            "under50% clone first emergency takes independent DEF20 raw77 15%=65, main Ivy only teamOD2%"):return

    # A clone can cover just once until its OWN completed action.
    # The next enemy action hits the original low-HP actor, not clone.
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]
    before_target=int(target["hp"])
    var before_clone:int=int(clone["hp"])
    damage=b.attack(enemy,target)
    if not _check(damage==87 and int(target["hp"])==before_target-87 and
            int(clone["hp"])==before_clone and int(ivy["od"])==140 and
            b.ivy_cover.events.size()==1,
            "second action is NOT automatically guarded by used clone"):return

    clone["source_at_active"]=true
    clone["source_atb_count_up"]=false
    clone["source_atb_count"]=1000
    if not _check(b.queue_actor_action(2,"guard") and
            bool(clone["fs_ivy_clone_guard_used"]),
            "clone command does NOT reset emergency usage until ACT"):return
    b.advance_atb(1.0/60.0)
    if not _check(b.action_queue.completed.size()==1 and
            bool(b.action_queue.completed[0]["success"]) and
            not bool(clone["fs_ivy_clone_guard_used"]) and
            not bool(clone["fs_ivy_clone_guarded"]),
            "original tick_owner_action resets clone used ONLY on completed ACT"):return
    _roll(b)
    before_clone=int(clone["hp"])
    before_target=int(target["hp"])
    damage=b.attack(enemy,target)
    if not _check(damage==65 and int(clone["hp"])==before_clone-65 and
            int(target["hp"])==before_target and
            int(ivy["od"])==160 and
            b.ivy_cover.events.size()==2,
            "clone can emergency cover once more on next enemy serial"):return

    # Above EXACTLY half (500/1000) clone does NOT activate; strictly
    # below50% is source hp_rate_percent(target) < 50.
    target["hp"]=500
    clone["fs_ivy_clone_guard_used"]=false
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]
    before_clone=int(clone["hp"])
    damage=b.attack(enemy,target)
    if not _check(damage==87 and int(target["hp"])==413 and
            int(clone["hp"])==before_clone and
            int(ivy["od"])==180,
            "exact 50% target HP is NOT eligible for clone emergency"):return

    # Main Ivy guard has priority even if eligible clone exists and
    # target is low HP. Clone does not consume its once-per-action flag.
    target["hp"]=400
    ivy["fs_ivy_guard_charges"]=1
    ivy["fs_ivy_guard_actions_left"]=2
    ivy["fs_ivy_guard_reduce"]=25
    _roll(b)
    before_clone=int(clone["hp"])
    var ivy_before:int=int(ivy["hp"])
    damage=b.attack(enemy,target)
    if not _check(damage==58 and int(ivy["hp"])==ivy_before-58 and
            int(clone["hp"])==before_clone and not bool(
            clone["fs_ivy_clone_guard_used"]) and
            int(ivy["od"])==280 and
            str(b.ivy_cover.events[-1]["guard_type"])=="main",
            "main Ivy priority over unused clone, +6/+2/+2 OD"):return

    # Casting main Ivy cannot guard, and eligible clone falls through.
    ivy["fs_ivy_guard_charges"]=2
    ivy["fs_ivy_guard_actions_left"]=2
    ivy["casting"]=true
    _roll(b)
    before_clone=int(clone["hp"])
    damage=b.attack(enemy,target)
    if not _check(damage==65 and int(clone["hp"])==before_clone-65 and
            int(ivy["od"])==300 and
            str(b.ivy_cover.events[-1]["guard_type"])=="clone",
            "casting main Ivy falls back to source-verified clone"):return
    ivy["casting"]=false

    # A matching role string without original Profile/Note authority may
    # be a guessed clone. Refuse BEFORE consuming HIT/EVA RNG.
    clone["fs_ivy_clone_guard_used"]=false
    clone["fs_clone_role_source_verified"]=false
    ivy["fs_ivy_guard_charges"]=0
    ivy["fs_ivy_guard_actions_left"]=0
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]
    before_target=int(target["hp"])
    if not _check(not b.attack_preflight(enemy,target) and
            b.attack(enemy,target)==0 and
            int(target["hp"])==before_target and
            b.accuracy.scripted_rolls==[0,99,0,99,99,0,0],
            "unverified clone identity blocks before RNG or HP"):return

    print("FS Phase523 original Ivy clone Cover under50%, independent damage, 15pct, main-first, casting fallback, one-use ACT reset and source gate PASS")
    quit(0)
