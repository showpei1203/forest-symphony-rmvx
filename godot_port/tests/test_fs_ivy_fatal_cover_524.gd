extends SceneTree

# Original source ~244532,246106-246156 and TEST Phase46B2 ~369420:
# Ivy Actor#5 passive Skill146, Cover HP>=Ivy HP, one per battle,
# OD300 paid before HP1 rescue, BEFORE +2% team/self post-damage.
# Synthetic data does not supply the user's private post-Apply tables.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,message:String)->bool:
    if not ok:
        push_error("FS Ivy fatal Cover 524 Godot FAIL: "+message)
        quit(1)
        return false
    return true

func _actor(id:int,n:String,defense:int)->Dictionary:
    return {"id":id,"name":n,"actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":defense,"spi":10,"agi":20,
        "hit":95,"eva":5,"cri":10,"od":0,
        "states":[],"skills":[],"equipment":[],"element_set":[],
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true}

func _battle()->FSBattle:
    var db=DB.new()
    var skills:Array=[]
    skills.resize(147)
    skills[146]={"id":146,"scope":0,"name":"Fatal Cover Passive",
        "note":"<mechanic_passive>\n<cover_store_cap_percent:400>"}
    db.tables={"skills":skills,"states":[null],"weapons":[null],
        "armors":[null],"enemies":[null,{"id":1,"name":"Enemy",
        "maxhp":3000,"maxmp":100,"atk":50,"def":10,
        "spi":10,"agi":20,"hit":95,"eva":5,"actions":[],
        "note":"","has_critical":false}]}
    var b=BATTLE.new(db)
    b.party.append(_actor(1,"Protected",10))
    var ivy:Dictionary=_actor(5,"Ivy",20)
    ivy["max_od"]=1000
    ivy["skills"]=[146]
    ivy["fs_ivy_guard_source_verified"]=true
    ivy["fs_ivy_fatal_source_verified"]=true
    b.party.append(ivy)
    if not b.add_enemy(1):
        push_error("fatal test requires real enemy constructor")
    var enemy:Dictionary=b.enemies[0]
    enemy["level"]=1
    enemy["element_set"]=[]
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    enemy["fs_normal_element_neutral_verified"]=true
    b.normal_core.active=true
    b.accuracy.active=true
    b.ivy_cover.active=true
    b.source_atb_rolls_for_test={"actor:0":0,"actor:1":0,"enemy:0":0}
    return b

func _guard(ivy:Dictionary)->void:
    ivy["fs_ivy_guard_charges"]=2
    ivy["fs_ivy_guard_actions_left"]=3
    ivy["fs_ivy_guard_reduce"]=25

func _hit(b:FSBattle)->void:
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0,
        0,99,99,0,0]

func _run()->void:
    var b:FSBattle=_battle()
    if not _check(b.start(),"battle starts"):return
    var ally:Dictionary=b.party[0]
    var ivy:Dictionary=b.party[1]
    var enemy:Dictionary=b.enemies[0]
    _guard(ivy)
    ivy["hp"]=50
    ivy["od"]=500
    _hit(b)
    if not _check(b.attack_preflight(enemy,ally) and
            b.accuracy.scripted_rolls.size()==12,
            "Skill146 verified original passive quote pure before RNG"):return
    var dealt:int=b.attack(enemy,ally)
    # Normal independent guard damage77, reduction25% =>58 lethal50.
    # Source Ivy +60 OD BEFORE execute_damage, then OD-300,
    # actual HP loss49, then +20 team +20 self.
    if not _check(dealt==49 and int(ally["hp"])==1000 and
            int(ivy["hp"])==1 and int(ivy["od"])==300 and
            bool(ivy["fs_ivy_fatal_used"]) and int(
            ivy["fs_ivy_guard_charges"])==1 and
            bool(b.ivy_cover.events[-1]["fatal_save"]) and
            b.accuracy.scripted_rolls.is_empty(),
            "fatal Ivy Cover actual HP1 OD500+60-300+40=300, one charge only"):return

    # Same battle: passive rescue used, even if Ivy is healed and has
    # ample OD, next lethal Cover must truly defeat Ivy (never save twice).
    ivy["hp"]=50
    ivy["od"]=500
    _hit(b)
    dealt=b.attack(enemy,ally)
    if not _check(dealt==58 and int(ivy["hp"])==0 and
            int(ivy["od"])==560 and bool(ivy["fs_ivy_fatal_used"]) and
            not bool(b.ivy_cover.events[-1]["fatal_save"]) and
            int(ally["hp"])==1000,
            "fatal cover once per battle only, second hit kills guard"):return

    # Costs are applied in this order: active Cover +6% FIRST and
    # 300 OD in fatal wrapper, not 300 BEFORE +6. OD250+60 qualifies.
    var b2:FSBattle=_battle()
    if not _check(b2.start(),"second battle starts"):return
    var ivy2:Dictionary=b2.party[1]
    _guard(ivy2)
    ivy2["hp"]=50
    ivy2["od"]=250
    _hit(b2)
    dealt=b2.attack(b2.enemies[0],b2.party[0])
    if not _check(dealt==49 and int(ivy2["hp"])==1 and int(
            ivy2["od"])==50 and bool(ivy2["fs_ivy_fatal_used"]),
            "OD250+60-300+40=50 source order permits last-second save"):return

    # Insufficient OD even AFTER the active Cover bonus does not cheat
    # a save. Skill146 remains learned but no OD300 available.
    var b3:FSBattle=_battle()
    if not _check(b3.start(),"third battle starts"):return
    var ivy3:Dictionary=b3.party[1]
    _guard(ivy3)
    ivy3["hp"]=50
    ivy3["od"]=200
    _hit(b3)
    dealt=b3.attack(b3.enemies[0],b3.party[0])
    if not _check(dealt==58 and int(ivy3["hp"])==0 and int(
            ivy3["od"])==260 and not bool(
            ivy3["fs_ivy_fatal_used"]),
            "OD200+60 insufficient, Ivy takes lethal58"):return

    # If Skill146 source is unproven, the expensive original Cover
    # transaction cannot even consume hit/critical RNG.
    var b4:FSBattle=_battle()
    if not _check(b4.start(),"fourth battle starts"):return
    var ivy4:Dictionary=b4.party[1]
    _guard(ivy4)
    ivy4["hp"]=50
    ivy4["od"]=500
    ivy4["fs_ivy_fatal_source_verified"]=false
    _hit(b4)
    if not _check(not b4.attack_preflight(b4.enemies[0],b4.party[0]) and
            b4.attack(b4.enemies[0],b4.party[0])==0 and
            int(ivy4["hp"])==50 and int(ivy4["od"])==500 and
            b4.accuracy.scripted_rolls.size()==12,
            "missing source Skill146 refuses before RNG/HP/OD"):return
    ivy4["fs_ivy_fatal_source_verified"]=true
    b4.db.tables["skills"][146]["note"]="<fake_passive>"
    if not _check(not b4.attack_preflight(b4.enemies[0],b4.party[0]) and
            b4.accuracy.scripted_rolls.size()==12,
            "unverified post-Apply Skill146 Note refuses rather than invoking fatal code"):return

    print("FS Phase524 Ivy fatal source Skill146 actual HP1 OD300 once/battle, +6% sequencing, insufficient OD and source fail-close PASS")
    quit(0)
