extends SceneTree

# FS RGSS2 ~220475 make_obj_damage_value then Scene_Battle#execute_action_skill
# ~222005 snapshots BEFORE one action and consumes only after successful
# skill_effect (non-zero HP, not MISS/EVADE/SKIP). Phase46B2 ~369055.
# This is explicitly a SOURCE-SHAPED SYNTHETIC action; the full original
# Skill147 JP/charge/recharge/level Notes remain unported/fail-closed.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,why:String)->bool:
    if not ok:
        push_error("FS Ivy 147 revenge native 526 FAIL: "+why)
        quit(1)
        return false
    return true

func _skill(extra_note:String="",flag:bool=true)->Dictionary:
    return {"id":147,"name":"Ivy revenge synthetic source subset",
        "scope":1,"occasion":1,"hit":95,"physical_attack":true,
        "base_damage":100,"atk_f":100,"spi_f":0,
        "has_critical":false,"variance":0,"ignore_defense":false,
        "mp_cost":18,"note":"<revenge_from_cover:50>\n<consume_stored_cover>"+extra_note,
        "element_set":[1],"plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false,
        "fs_smooth_source_verified":true,
        "fs_ivy_revenge_source_verified":flag}

func _battle()->FSBattle:
    var db=DB.new()
    var skills:Array=[]
    skills.resize(148)
    skills[147]=_skill()
    db.tables={"skills":skills,"states":[null],
        "weapons":[null],"armors":[null],
        "enemies":[null,{"id":1,"name":"HP Test Source",
            "maxhp":10000,"maxmp":1000,"atk":50,"def":10,
            "spi":10,"agi":20,"hit":95,"eva":5,
            "has_critical":false,"note":"","actions":[]}]}
    var b=BATTLE.new(db)
    b.party.append({"id":5,"name":"Ivy","actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":10,"spi":20,"agi":20,
        "hit":95,"eva":5,"cri":10,"od":0,
        "skills":[147],"equipment":[],"states":[],
        "element_set":[1],"note":"",
        "fs_smooth_battler_verified":true,
        "fs_ivy_pain_notes_verified":true,
        "fs_ivy_effective_notes":[],
        "fs_ivy_stored_pain":0})
    b.add_enemy(1)
    b.enemies[0]["fs_smooth_battler_verified"]=true
    b.enemies[0]["fs_smooth_element_neutral_verified"]=true
    b.accuracy.active=true
    b.skill_core.active=true
    b.ivy_revenge.active=true
    b.source_atb_rolls_for_test={"actor:0":0,"enemy:0":0}
    return b

func _run()->void:
    var b:FSBattle=_battle()
    if not _check(b.start(),"real native battle starts"):return
    var hero:Dictionary=b.party[0]
    var enemy:Dictionary=b.enemies[0]
    hero["fs_ivy_stored_pain"]=401
    var before_hp:int=int(enemy["hp"])
    b.accuracy.scripted_rolls=[0,99,99]
    if not _check(b.skill_preflight(hero,enemy,147) and
            int(hero["fs_ivy_stored_pain"])==401 and
            int(hero["mp"])==100 and
            b.accuracy.scripted_rolls==[0,99,99],
            "source 147 quote pure: command does not pay MP/clear pain/RNG"):return
    var q:Dictionary=b.ivy_revenge.preview(hero,b.db.record("skills",147))
    if not _check(bool(q.get("ok",false)) and int(
            q["extra"])==200 and int(q["snapshot"])==401 and
            b.use_skill(hero,enemy,147) and int(
            enemy["hp"])==before_hp-384 and int(hero["mp"])==82 and
            int(hero["fs_ivy_stored_pain"])==0 and
            int(b.ivy_revenge.events[-1]["consumed"])==401 and
            int(b.ivy_revenge.events[-1]["extra"])==200,
            "Ivy147 old smooth184 + source action snapshot401/2 floor200, actual HP384 MP18 consume401"):return

    # Source on MISS still spends MP but never consumes old stored pain.
    hero["fs_ivy_stored_pain"]=201
    b.accuracy.scripted_rolls=[95]
    before_hp=int(enemy["hp"])
    if not _check(b.use_skill(hero,enemy,147) and
            int(hero["mp"])==64 and int(enemy["hp"])==before_hp and
            int(hero["fs_ivy_stored_pain"])==201 and
            not bool(b.ivy_revenge.events[-1]["success"]) and
            b.accuracy.scripted_rolls.is_empty(),
            "147 MISS costs MP18, no source revenge damage and no consume"):return

    # Existing source Note contains additional JP/charge/recharge/levels:
    # it is NEVER silently stripped even if its 50% revenge is correct.
    b.db.tables["skills"][147]["note"]=_skill(
        "\n<jp cost:5000>\n<charge: 4, 18%, 0>")["note"]
    b.accuracy.scripted_rolls=[0,99,99]
    before_hp=int(enemy["hp"])
    var before_mp:int=int(hero["mp"])
    if not _check(not b.skill_preflight(hero,enemy,147) and
            not b.use_skill(hero,enemy,147) and
            int(hero["mp"])==before_mp and
            int(hero["fs_ivy_stored_pain"])==201 and
            int(enemy["hp"])==before_hp and
            b.accuracy.scripted_rolls==[0,99,99],
            "real full Skill147 extra unported JP/charge cannot execute/clear"):return
    b.db.tables["skills"][147]=_skill()

    # Missing actual stored-pain effective Notes must block BEFORE RNG.
    hero["fs_ivy_pain_notes_verified"]=false
    if not _check(not b.skill_preflight(hero,enemy,147) and
            b.accuracy.scripted_rolls==[0,99,99] and
            int(hero["fs_ivy_stored_pain"])==201,
            "unknown source reservoir Note blocks before ACT/RNG"):return
    hero["fs_ivy_pain_notes_verified"]=true

    # Real actor COMMAND -> Tankentai charge -> completed ACT. The
    # stored reservoir must still be there during charge.
    var queued:FSBattle=_battle()
    if not _check(queued.start(),"queued native battle starts"):return
    var ivy:Dictionary=queued.party[0]
    var target:Dictionary=queued.enemies[0]
    ivy["fs_ivy_stored_pain"]=301
    ivy["source_at_active"]=true
    ivy["source_atb_count_up"]=false
    ivy["source_atb_count"]=1000
    queued.accuracy.scripted_rolls=[0,99,99]
    before_hp=int(target["hp"])
    if not _check(queued.queue_actor_action(0,"skill",0,147) and
            int(ivy["mp"])==100 and int(ivy["fs_ivy_stored_pain"])==301,
            "Skill147 command accepted without consuming reservoir"):return
    queued.advance_atb(9.0/60.0)
    if not _check(queued.has_actor_pending_action(0) and
            int(ivy["source_act_count"])==900 and
            int(ivy["mp"])==100 and int(ivy["fs_ivy_stored_pain"])==301,
            "nine ACT frames, Skill147 no MP/pain advance"):return
    queued.advance_atb(1.0/60.0)
    if not _check(queued.action_queue.completed.size()==1 and
            bool(queued.action_queue.completed[0]["success"]) and
            int(target["hp"])==before_hp-334 and
            int(ivy["mp"])==82 and
            int(ivy["fs_ivy_stored_pain"])==0 and
            not queued.has_actor_pending_action(0),
            "tenth ACT frame applies smooth184+trunc(301*.5)=334, MP18, clear ONCE"):return

    # Skipping due to no target after command leaves stored pain and MP.
    var abandoned:FSBattle=_battle()
    if not _check(abandoned.start(),"abandoned native battle starts"):return
    var actor:Dictionary=abandoned.party[0]
    actor["fs_ivy_stored_pain"]=200
    actor["source_at_active"]=true
    actor["source_atb_count_up"]=false
    actor["source_atb_count"]=1000
    abandoned.accuracy.scripted_rolls=[0,99,99]
    if not _check(abandoned.queue_actor_action(0,"skill",0,147),
            "valid queue to later-vanished target"):return
    abandoned.enemies[0]["hp"]=0
    abandoned.advance_atb(10.0/60.0)
    if not _check(int(actor["fs_ivy_stored_pain"])==200 and
            int(actor["mp"])==100 and
            abandoned.accuracy.scripted_rolls==[0,99,99],
            "target dies during charge => no revenge consume, MP or RNG"):return

    # Original actual Skill145 carries both States85/100 plus
    # unported JP/charge/recharge tags; do not pretend State85 alone
    # is a fully functional source Skill.
    var furnace:Array=abandoned.db.tables["skills"]
    furnace[145]={"id":145,"name":"Pain Furnace original shaped",
        "scope":11,"occasion":1,"base_damage":0,
        "atk_f":0,"spi_f":0,"mp_cost":16,"hit":100,
        "plus_state_set":[85,100],"minus_state_set":[],
        "note":"<jp cost:2800>\n<charge: 4, 10%, 0>\n<recharge:10%>"}
    actor["skills"].append(145)
    var old_mp:int=int(actor["mp"])
    if not _check(not abandoned.skill_preflight(actor,actor,145) and
            int(actor["mp"])==old_mp and int(
            actor["fs_ivy_stored_pain"])==200,
            "original Skill145 State85+100/JP charge remains fail closed"):return

    print("FS Phase526 Ivy147 source actual smooth+50pct snapshot, HIT consumes once, MISS/SKIP preserve, ATB10 frames and Skill145 full not fabricated PASS")
    quit(0)
