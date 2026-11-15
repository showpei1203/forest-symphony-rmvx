extends SceneTree

# Original RGSS2 ComboCore ~211201/211350 + source FS_BATTLE_V22
# passive_skill_note_text ~253525; Skill142 formal MasterSetup ~278835.
# Enemy HIT uses real Godot FSBattle normal skill/guard and stored pain.
# Source try_redirect gives +6% OD BEFORE guard's independent damage.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,reason:String)->bool:
    if not ok:
        push_error("FS Ivy OD defense 528 native FAIL: "+reason)
        quit(1)
        return false
    return true

func _ally(id:int,name:String,df:int)->Dictionary:
    var out:Dictionary={"id":id,"name":name,"actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":df,"spi":10,"agi":20,"hit":95,"eva":5,
        "cri":10,"od":0,"element_set":[],"states":[],
        "skills":[],"equipment":[],"note":"",
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true}
    if id==5:
        out["max_od"]=1000
        out["skills"]=[142]
        out["fs_ivy_guard_source_verified"]=true
        out["fs_ivy_od_source_verified"]=true
        out["fs_ivy_pain_notes_verified"]=true
        out["fs_ivy_effective_notes"]=[
            "<reduce_damage_if_od 10:90>"]
        out["fs_ivy_stored_pain"]=0
        out["fs_smooth_battler_verified"]=true
        out["fs_smooth_element_neutral_verified"]=true
    return out

func _battle()->FSBattle:
    var db=DB.new()
    var skills:Array=[]
    skills.resize(143)
    skills[142]={"id":142,"name":"怒意不熄",
        "scope":0,"occasion":3,"mp_cost":0,
        "note":"<mechanic_passive>\n<jp cost:900>\n<jp level:10>\n<jp skill:141>\n<reduce_damage_if_od 50:12>\n<reduce_damage_per_od_percent:0.08>\n<hide>"}
    skills[2]={"id":2,"name":"Synthetic source enemy skill",
        "scope":1,"occasion":1,"mp_cost":10,"hit":95,
        "base_damage":100,"atk_f":100,"spi_f":0,
        "has_critical":false,"variance":0,
        "physical_attack":false,"ignore_defense":false,
        "damage_to_mp":false,"absorb_damage":false,"note":"",
        "element_set":[1],"plus_state_set":[],"minus_state_set":[],
        "fs_smooth_source_verified":true}
    db.tables={"skills":skills,"weapons":[null],"armors":[null],
        "states":[null],"enemies":[null,{"id":1,"name":"Synthetic Enemy",
        "maxhp":9000,"maxmp":100,"atk":50,"def":10,
        "spi":10,"agi":20,"hit":95,"eva":5,
        "has_critical":false,"note":"","actions":[]}]}
    var b=BATTLE.new(db)
    b.party.append(_ally(1,"Teammate",10))
    b.party.append(_ally(5,"Ivy",20))
    if not b.add_enemy(1):
        push_error("source Enemy1 could not spawn")
    var enemy:Dictionary=b.enemies[0]
    enemy["element_set"]=[]
    enemy["level"]=1
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    enemy["fs_normal_element_neutral_verified"]=true
    enemy["fs_smooth_battler_verified"]=true
    b.accuracy.active=true
    b.normal_core.active=true
    b.ivy_cover.active=true
    b.ivy_pain.active=true
    b.ivy_od_defense.active=true
    b.source_atb_rolls_for_test={
        "actor:0":0,"actor:1":0,"enemy:0":0}
    return b

func _hit(b:FSBattle)->void:
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]

func _run()->void:
    var b:FSBattle=_battle()
    # A manually fabricated source flag must never enable real private
    # post-Apply 11-table production behavior. The negative activation
    # clears all presumed provenance before this synthetic QA opts in.
    if not _check(not b.enable_private_ivy_od_defense() and not (
            b.ivy_od_defense.active) and not bool(
            b.party[1].get("fs_ivy_od_source_verified",false)),
            "private 142 source needs genuine post-Apply authority"):return
    b.ivy_od_defense.active=true
    b.party[1]["fs_ivy_od_source_verified"]=true
    if not _check(b.start(),"native source battle started"):return
    var ivy:Dictionary=b.party[1]
    var friend:Dictionary=b.party[0]
    var enemy:Dictionary=b.enemies[0]
    # Actor Profile is deliberately ignored by ComboCore source,
    # even though Ivy Pain source DOES read it. Fake90% profile Note
    # must not change Skill142 when actual OD is below50.
    var direct:Array=[
        {"od":0,"hp":77,"stored":38},
        {"od":490,"hp":73,"stored":36},
        {"od":500,"hp":64,"stored":32},
        {"od":1000,"hp":61,"stored":30}]
    for e in direct:
        ivy["hp"]=1000
        ivy["od"]=int(e["od"])
        ivy["fs_ivy_stored_pain"]=0
        _hit(b)
        var original_rolls:Array=b.accuracy.scripted_rolls.duplicate()
        if not _check(b.attack_preflight(enemy,ivy) and (
                b.accuracy.scripted_rolls==original_rolls),
                "OD %s pure preflight draws no RNG" % str(e["od"])):return
        var damage:int=b.attack(enemy,ivy)
        if not _check(damage==int(e["hp"]) and int(
                ivy["hp"])==1000-int(e["hp"]) and int(
                ivy["fs_ivy_stored_pain"])==int(e["stored"]) and
                b.accuracy.scripted_rolls.is_empty(),
                "OD%d direct expected damage%d/pain%d got%d/%d" % [
                    int(e["od"]),int(e["hp"]),int(e["stored"]),damage,
                    int(ivy.get("fs_ivy_stored_pain",0))]):return
    # Exact threshold 49%: 3.92% mitigation, not 12% gated bonus.
    # OD50%: 12% + 4%=16%; OD100%: 12%+8%=20%.
    var over:Dictionary=b.ivy_od_defense.quote(b,ivy,100)
    if not _check(bool(over.get("ok",false)) and
            float(over["reduction"])==20.0,
            "original OD100 gives additive20% not a full guard block"):return

    # Real source allows multiple passive/equipment/State tags to add
    # and caps total mitigation at90%, but excludes ActorProfile.
    ivy["fs_ivy_effective_notes"]=[
        "<reduce_damage_if_od 10:90>",
        "<reduce_damage_per_od_percent:0.02>"]
    ivy["od"]=500
    over=b.ivy_od_defense.quote(b,ivy,77)
    if not _check(bool(over.get("ok",false)) and
            is_equal_approx(float(over["reduction"]),17.0) and int(
            over["hp"])==63,
            "equipment adds 1%, Profile fake90% ignored, Skill142 contributes16%"):return
    ivy["fs_ivy_effective_notes"].append(
        "<reduce_damage_if_od 1:100>")
    over=b.ivy_od_defense.quote(b,ivy,77)
    if not _check(bool(over.get("ok",false)) and
            float(over["reduction"])==90.0 and int(over["hp"])==7,
            "original source total conditional/equipment cap90%"):return
    ivy["fs_ivy_effective_notes"]=[
        "<reduce_damage_if_od 10:90>"]

    # Real Cover: source try_redirect first grants +6% MaxOD:
    # Ivy 490->550, learned142 sees OD55% (12+4.4=16.4%).
    # Recomputed source guard raw77->64, then Cover25%=48.
    # Afterwards enemy damage generates team+self +2%+2% OD;
    # resulting 490+60+20+20 =590.
    ivy["hp"]=1000
    ivy["od"]=490
    ivy["fs_ivy_stored_pain"]=0
    ivy["fs_ivy_guard_charges"]=2
    ivy["fs_ivy_guard_actions_left"]=3
    ivy["fs_ivy_guard_reduce"]=25
    _hit(b)
    b.accuracy.scripted_rolls+=[0,99,99,0,0]
    var friend_before:int=int(friend["hp"])
    var cover:int=b.attack(enemy,friend)
    print("P528_REAL_OD_COVER: ",{"damage":cover,"friend":friend["hp"],
        "ivy_hp":ivy["hp"],"od":ivy["od"],
        "pain":ivy["fs_ivy_stored_pain"],
        "charge":ivy["fs_ivy_guard_charges"],
        "events":b.ivy_od_defense.events,"errors":b.ivy_cover.errors,
        "last":b.ivy_cover.events[-1] if not b.ivy_cover.events.is_empty() else {}})
    if not _check(cover==48 and int(friend["hp"])==friend_before and
            int(ivy["hp"])==952 and int(ivy["od"])==590 and int(
            ivy["fs_ivy_stored_pain"])==48 and int(
            ivy["fs_ivy_guard_charges"])==1 and
            is_equal_approx(float(
            b.ivy_od_defense.events[-1]["rate"]),55.0) and
            int(b.ivy_od_defense.events[-1]["hp"])==64,
            "Ivy Cover +6% state: dealt=%d friend=%d/%d IvyHP=%d OD=%d stored=%d charge=%d events=%s source_errors=%s" % [
                cover,int(friend["hp"]),friend_before,int(ivy["hp"]),
                int(ivy["od"]),int(ivy["fs_ivy_stored_pain"]),
                int(ivy["fs_ivy_guard_charges"]),
                str(b.ivy_od_defense.events),str(b.ivy_cover.errors)]):return

    var screen=SCREEN.new()
    root.add_child(screen)
    screen.db=b.db
    screen.battle=b
    screen._refresh_battle_status()
    if not _check("怒意不熄：OD 59.0%" in screen.status_label.text and
            "傷害減免 16.72%" in screen.status_label.text,
            "real native Godot HUD uses updated OD590, not earlier pre-Cover 55%"):return

    # Enemy SKILL is subject to same source ComboCore OD mitigation:
    # source smooth171 vs Ivy DEF20, at OD50=>floor171*.84=143.
    ivy["hp"]=1000
    ivy["od"]=500
    ivy["fs_ivy_guard_charges"]=0
    ivy["fs_ivy_guard_actions_left"]=0
    b.skill_core.active=true
    b.accuracy.scripted_rolls=[0,99,99]
    var enemy_mp:int=int(enemy["mp"])
    if not _check(b.use_skill(enemy,ivy,2) and int(
            enemy["mp"])==enemy_mp-10 and int(
            ivy["hp"])==857 and int(
            b.ivy_od_defense.events[-1]["hp"])==143,
            "original OD50 threshold reduces real skill smooth171 to143 before Shield"):return

    # FS_BATTLE_V22 also recognizes OLD Ivy passive ID814 by name,
    # even without <mechanic_passive>. Never confuse legacy with absent
    # learned passive: it must apply the exact verified Note 50:12/0.08.
    var skill_table:Array=b.db.tables["skills"]
    skill_table.resize(815)
    var old_passive:Dictionary=skill_table[142].duplicate(true)
    old_passive["id"]=814
    old_passive["note"]=str(old_passive["note"]).replace(
        "<mechanic_passive>\\n","")
    skill_table[814]=old_passive
    ivy["skills"]=[814]
    ivy["od"]=500
    var old_quote:Dictionary=b.ivy_od_defense.quote(b,ivy,77)
    if not _check(bool(old_quote.get("ok",false)) and int(
            old_quote["hp"])==64 and is_equal_approx(float(
            old_quote["reduction"]),16.0),
            "legacy FS Skill814 name-matched passive applies correct OD50 16pct"):return
    ivy["fs_ivy_guard_charges"]=1
    ivy["fs_ivy_guard_actions_left"]=2
    ivy["fs_ivy_guard_reduce"]=20
    b.ivy_od_defense.active=false
    var blocked:Dictionary=b.ivy_cover.preview(
        b,enemy,friend,"attack")
    if not _check(not bool(blocked.get("ok",false)),
            "legacy Skill814 guard must NOT bypass disabled OD reduction"):return
    b.ivy_od_defense.active=true
    ivy["skills"]=[142]
    ivy["fs_ivy_guard_charges"]=0
    ivy["fs_ivy_guard_actions_left"]=0

    # Missing source Skill142 data/name/Note or provenance must fail
    # BEFORE the attack draws RNG or mutates HP, pain or OD.
    ivy["hp"]=1000
    ivy["od"]=500
    ivy["fs_ivy_od_source_verified"]=false
    _hit(b)
    var before_rolls:Array=b.accuracy.scripted_rolls.duplicate()
    if not _check(not b.attack_preflight(enemy,ivy) and
            b.attack(enemy,ivy)==0 and int(ivy["hp"])==1000 and
            b.accuracy.scripted_rolls==before_rolls,
            "unknown passive source cannot reduce HP or drain RNG"):return
    ivy["fs_ivy_od_source_verified"]=true
    b.db.tables["skills"][142]["note"]="<mechanic_passive>"
    if not _check(not b.attack_preflight(enemy,ivy) and
            b.accuracy.scripted_rolls==before_rolls,
            "unverified learned Skill142 Note blocks original source reduction"):return
    b.db.tables["skills"][142]["note"]=_battle().db.tables["skills"][142]["note"]
    b.db.tables["skills"][142]["name"]="Unrelated passive"
    if not _check(not b.attack_preflight(enemy,ivy) and
            b.accuracy.scripted_rolls==before_rolls,
            "Skill142 ID collision/old DB name refuses false passivity"):return

    print("FS P528 Godot native Ivy142 OD0/49/50/100 reduction, strongest Notes, 90cap, real Cover OD49->55, skill mitigation, source/RNG gating PASS")
    quit(0)
