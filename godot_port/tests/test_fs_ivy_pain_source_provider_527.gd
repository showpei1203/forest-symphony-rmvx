extends SceneTree

# Original LAST-WINS ~236306 ALBERT_CHARACTER_CORE.source_text:
# Profile.tag_text(Actor5) + ALL equipped weapon/armor Notes + LIVE State
# Notes, never RPG::Actor.note. State85 data MasterSetup ~285060.
# Native Godot enemy-hit + Cover integration; production requires
# post-Apply 11 effective tables, runtime witness and private SHA.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,why:String)->bool:
    if not ok:
        push_error("FS Ivy pain source provider 527 native FAIL: "+why)
        quit(1)
        return false
    return true

func _actor(id:int,name:String,df:int)->Dictionary:
    return {"id":id,"name":name,"actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":df,"spi":10,"agi":20,
        "hit":95,"eva":5,"cri":10,"od":0,
        "element_set":[],"states":[],"skills":[],
        "equipment":[0,0,0,0,0],"note":"<store_direct_damage:999>",
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true}

func _state85()->Dictionary:
    return {"id":85,"name":"Pain Furnace (synthetic DB)",
        "hold_turn":4,"auto_release_prob":100,
        "atk_rate":100,"def_rate":100,"spi_rate":100,"agi_rate":100,
        "note":"<store_cover_damage:150>\n<cover_store_cap_percent:300>\n<hud_priority:290>\n<hud_detail>"}

func _battle()->FSBattle:
    var db=DB.new()
    var states:Array=[]
    states.resize(86)
    states[85]=_state85()
    db.tables={"states":states,
        "weapons":[null,{"id":1,"name":"Synthetic Sword",
            "note":"<store_direct_damage:120>"}],
        "armors":[null,{"id":1,"name":"Synthetic Cover Cape",
            "kind":0,
            "note":"<store_direct_damage:175>\n<cover_store_cap_percent:400>"}],
        "enemies":[null,{"id":1,"name":"Source Enemy",
            "maxhp":9000,"maxmp":100,"atk":50,"def":10,"spi":10,
            "agi":20,"hit":95,"eva":5,"has_critical":false,
            "actions":[],"note":""}]}
    var b=BATTLE.new(db)
    b.party.append(_actor(1,"Friend",10))
    var ivy:Dictionary=_actor(5,"Ivy",20)
    ivy["max_od"]=1000
    ivy["fs_ivy_guard_source_verified"]=true
    ivy["equipment"]=[1,1,0,0,0]
    b.party.append(ivy)
    b.add_enemy(1)
    var enemy:Dictionary=b.enemies[0]
    enemy["level"]=1
    enemy["element_set"]=[]
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    enemy["fs_normal_element_neutral_verified"]=true
    b.normal_core.active=true
    b.accuracy.active=true
    b.ivy_cover.active=true
    b.ivy_pain.active=true
    b.source_atb_rolls_for_test={
        "actor:0":0,"actor:1":0,"enemy:0":0}
    return b

func _hit(b:FSBattle)->void:
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]

func _guard_hit(b:FSBattle)->void:
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0,
        0,99,99,0,0]

func _run()->void:
    var b:FSBattle=_battle()
    if not _check(not b.enable_private_ivy_pain_notes() and not (
            b.ivy_pain_source.active) and not b.ivy_pain.active,
            "no real effective 11-table witness blocks private source activation"):return
    b.ivy_pain.active=true
    var mapping:Dictionary={"source":"ALBERT_CHARACTER_CORE_TAG_TEXT_v1",
        "actor_profile_tag_text":{"5":"<store_cover_damage:125>"}}
    if not _check(bool(b.ivy_pain_source.configure_fixture(
            mapping).get("ok",false)),
            "verified synthetic-only Profile.tag_text mapping accepted"):return
    if not _check(b.start(),"source Ivy actual Godot battle starts"):return
    var ally:Dictionary=b.party[0]
    var ivy:Dictionary=b.party[1]
    var enemy:Dictionary=b.enemies[0]
    _hit(b)
    var amount:int=b.attack(enemy,ivy)
    # Ivy DEF20 source damage77, weapon direct120 vs armor175 =>175%.
    # Actor.note 999 is NOT ALBERT_CHARACTER_CORE source.
    if not _check(amount==77 and int(ivy["hp"])==923 and int(
            ivy["fs_ivy_stored_pain"])==134 and int(
            b.ivy_pain.events[-1]["cap"])==4000 and not (
            str(ivy["fs_ivy_effective_notes"]).contains("999")),
            "actual direct HP77 * strongest equip175%=134, cap400%, ignored Actor.note999"):return

    # Equipment change updates source immediately even WITHOUT
    # editing any synthetic fs_ivy_effective_notes manually.
    ivy["equipment"]=[0,0,0,0,0]
    _hit(b)
    amount=b.attack(enemy,ivy)
    if not _check(amount==77 and int(ivy["fs_ivy_stored_pain"])==172 and
            int(b.ivy_pain.events[-1]["gain"])==38 and
            int(b.ivy_pain.events[-1]["cap"])==2000 and
            b.ivy_pain_source.refresh_count>=2,
            "unequip source notes; direct default50, cap200 immediately"):return

    # State85 is source runtime note, NOT an invented global buff.
    # Its tagged cap300 and Cover150 load from actual DB.record(85);
    # direct actual-loss rate becomes100% while State85 active.
    ivy["states"]=[85]
    _hit(b)
    amount=b.attack(enemy,ivy)
    if not _check(amount==77 and int(ivy["fs_ivy_stored_pain"])==249 and
            int(b.ivy_pain.events[-1]["gain"])==77 and
            int(b.ivy_pain.events[-1]["cap"])==3000 and
            bool(ivy["fs_ivy_furnace_state_verified"]) and
            ivy["fs_ivy_effective_notes"].size()==2,
            "live State85 verified data adds direct100%, Cover150%, cap300%"):return

    # Actual main Ivy guard HP58, State85 Cover150% -> store87.
    ivy["fs_ivy_guard_charges"]=2
    ivy["fs_ivy_guard_actions_left"]=3
    ivy["fs_ivy_guard_reduce"]=25
    _guard_hit(b)
    var previous_hp:int=int(ally["hp"])
    amount=b.attack(enemy,ally)
    if not _check(amount==58 and int(ally["hp"])==previous_hp and
            int(ivy["fs_ivy_stored_pain"])==336 and
            int(b.ivy_pain.events[-1]["gain"])==87 and
            bool(b.ivy_pain.events[-1]["cover"]),
            "Cover source refreshes actual guard State85 and stores 58*150%=87"):return

    # Source State record missing after a dynamic State mutation must
    # fail before HIT RNG and HP/OD/MP commit, wiping stale Notes.
    b.db.tables["states"][85]=null
    _hit(b)
    var hp_before:int=int(ivy["hp"])
    var od_before:int=int(ivy["od"])
    if not _check(not b.attack_preflight(enemy,ivy) and
            b.attack(enemy,ivy)==0 and int(ivy["hp"])==hp_before and
            int(ivy["od"])==od_before and
            b.accuracy.scripted_rolls.size()==7 and
            not ivy.has("fs_ivy_effective_notes") and not bool(
            ivy.get("fs_ivy_pain_notes_verified",false)),
            "missing State85 post-Apply record evicts stale notes before HIT"):return

    # Empty manually entered profile map cannot retain prior active
    # source snapshot once a fresh configuration fails.
    var broken:Dictionary={"source":"ALBERT_CHARACTER_CORE_TAG_TEXT_v1",
        "actor_profile_tag_text":{}}
    if not _check(not bool(b.ivy_pain_source.configure_fixture(
            broken).get("ok",false)) and not b.ivy_pain_source.active,
            "invalid replacement Profile.source map rejects stale active fixture"):return

    print("FS Phase527 real final Actor Profile source → weapon/armor → State85 dynamic pain, real direct/Cover HP and post-Apply gates PASS")
    quit(0)
