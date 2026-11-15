extends SceneTree

# Source FS_BATTLE_V22 ~253525/253787 LAST-WINS appends mechanic
# passive Skill142/146 Notes AFTER CharacterCore Profile/Equip/States.
# This enables genuine Skill146 pain cap400%, and must NOT cause
# ComboCore passive142 OD16% to be read twice. Native real battle,
# source-shaped private fixture only (NOT boot-final full FS).
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,reason:String)->bool:
    if not ok:
        push_error("FS passive last-wins Notes 531 native FAIL: "+reason)
        quit(1)
        return false
    return true

func _state85()->Dictionary:
    return {"id":85,"name":"痛苦熔爐",
        "hold_turn":4,"auto_release_prob":100,
        "restriction":0,"reduce_hit_ratio":false,
        "atk_rate":100,"def_rate":100,"spi_rate":100,"agi_rate":100,
        "note":"<store_cover_damage:150>\n<cover_store_cap_percent:300>\n<hud_priority:290>\n<hud_detail>"}

func _battle()->FSBattle:
    var db=DB.new()
    var skills:Array=[]
    skills.resize(815)
    skills[142]={"id":142,"name":"怒意不熄","scope":0,
        "note":"<mechanic_passive>\n<jp cost:900>\n<jp level:10>\n<jp skill:141>\n<reduce_damage_if_od 50:12>\n<reduce_damage_per_od_percent:0.08>\n<hide>"}
    skills[146]={"id":146,"name":"替身承擔","scope":0,
        "note":"<mechanic_passive>\n<jp cost:4500>\n<jp level:34>\n<jp skill:145>\n<cover_store_cap_percent:400>\n<hide>"}
    skills[814]={"id":814,"name":"怒意不熄","scope":0,
        "note":"<reduce_damage_if_od 50:12>\n<reduce_damage_per_od_percent:0.08>"}
    var states:Array=[]
    states.resize(86)
    states[85]=_state85()
    db.tables={"skills":skills,"states":states,
        "weapons":[null],"armors":[null],
        "enemies":[null,{"id":1,"name":"Native Source Enemy",
            "maxhp":9000,"maxmp":100,"atk":50,"def":10,"spi":10,
            "agi":20,"hit":95,"eva":5,"has_critical":false,
            "actions":[],"note":""}]}
    var b=BATTLE.new(db)
    b.party.append({"id":5,"name":"Ivy","actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":20,"spi":10,"agi":20,
        "hit":95,"eva":5,"cri":10,
        "max_od":1000,"od":0,"states":[85],
        "skills":[142,146],"equipment":[0,0,0,0,0],
        "element_set":[],"note":"<reduce_damage_if_od 50:95>",
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true,
        "fs_ivy_od_source_verified":true})
    b.add_enemy(1)
    var enemy:Dictionary=b.enemies[0]
    enemy["level"]=1
    enemy["element_set"]=[]
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    enemy["fs_normal_element_neutral_verified"]=true
    var mapped:Dictionary=b.ivy_pain_source.configure_fixture({
        "source":"ALBERT_CHARACTER_CORE_TAG_TEXT_v1",
        "actor_profile_tag_text":{"5":"<reduce_damage_if_od 50:95>"}})
    if not bool(mapped.get("ok",false)):
        push_error("Actor5 synthetic authority cannot configure")
    b.normal_core.active=true
    b.accuracy.active=true
    b.ivy_pain.active=true
    b.ivy_od_defense.active=true
    b.source_atb_rolls_for_test={"actor:0":0,"enemy:0":0}
    return b

func _roll(b:FSBattle)->void:
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]

func _run()->void:
    var b:FSBattle=_battle()
    if not _check(b.start(),"real native FS Battle starts"):return
    var ivy:Dictionary=b.party[0]
    var foe:Dictionary=b.enemies[0]
    ivy["od"]=500
    _roll(b)
    var original_rolls:Array=b.accuracy.scripted_rolls.duplicate()
    if not _check(b.attack_preflight(foe,ivy) and
            b.accuracy.scripted_rolls==original_rolls and
            bool(ivy["fs_ivy_effective_notes_have_passives"]) and
            ivy["fs_ivy_effective_notes"].size()==4,
            "last-wins active source combines profile + State85 + both learned passives"):return
    var defensive:Dictionary=b.ivy_od_defense.quote(b,ivy,100)
    if not _check(bool(defensive.get("ok",false)) and int(
            defensive["hp"])==84 and is_equal_approx(float(
            defensive["reduction"]),16.0),
            "source142 OD50 has only16% reduction, not doubled32% or profile95%"):return
    var hit:int=b.attack(foe,ivy)
    if not _check(hit==64 and int(ivy["hp"])==936 and int(
            ivy["fs_ivy_stored_pain"])==64 and int(
            b.ivy_pain.events[-1]["cap"])==4000 and
            int(b.ivy_pain.events[-1]["gain"])==64,
            "native actual HP64 from source passive142, Pain64 from State85, cap400% from146"):return

    # Actor learning/unlearning a passive between ACTs immediately changes
    # the final CharacterCore source. No stale 400% cap should remain.
    ivy["skills"]=[142]
    ivy["od"]=500
    _roll(b)
    hit=b.attack(foe,ivy)
    if not _check(hit==64 and int(
            b.ivy_pain.events[-1]["cap"])==3000 and
            ivy["fs_ivy_effective_notes"].size()==3 and
            int(ivy["fs_ivy_stored_pain"])==128,
            "removing Skill146 restores State85 cap300%, keeps OD16%"):return

    # Legacy Skill814 recognized by ID+NAME without mechanic_passive,
    # exactly matching FS_BATTLE_V22.PASSIVE_NAMES.
    ivy["skills"]=[814,146]
    ivy["od"]=500
    _roll(b)
    hit=b.attack(foe,ivy)
    if not _check(hit==64 and int(
            b.ivy_pain.events[-1]["cap"])==4000 and
            int(ivy["fs_ivy_stored_pain"])==192 and
            bool(ivy["fs_ivy_effective_notes_have_passives"]),
            "legacy814 name-only OD16%, Skill146 cap400% both live"):return

    # Stage expiry via removing State85. Direct pain returns from
    # 100% to50%, while learned Skill146 still preserves cap400%.
    ivy["states"]=[]
    ivy["od"]=500
    _roll(b)
    hit=b.attack(foe,ivy)
    if not _check(hit==64 and int(ivy[
            "fs_ivy_stored_pain"])==224 and int(
            b.ivy_pain.events[-1]["gain"])==32 and int(
            b.ivy_pain.events[-1]["cap"])==4000 and
            not bool(ivy["fs_ivy_furnace_state_verified"]),
            "after State85 removal direct HP64 stores50%=32; Skill146 cap400 survives"):return

    # Runtime skill Note mutated after provider proof: no stale OD
    # reduction may be silently applied or MP/HIT/RNG committed.
    ivy["skills"]=[142]
    b.db.tables["skills"][142]["note"]="<mechanic_passive>"
    ivy["od"]=500
    _roll(b)
    var before_hp:int=int(ivy["hp"])
    var before_pain:int=int(ivy["fs_ivy_stored_pain"])
    if not _check(not b.attack_preflight(foe,ivy) and
            b.attack(foe,ivy)==0 and int(ivy["hp"])==before_hp and
            int(ivy["fs_ivy_stored_pain"])==before_pain and
            b.accuracy.scripted_rolls.size()==7,
            "missing final passive142 reduction tags fails closed before HIT/HP/Pain"):return

    b.db.tables["skills"][142]=null
    if not _check(not b.attack_preflight(foe,ivy) and
            not bool(ivy.get("fs_ivy_pain_notes_verified",false)) and
            not ivy.has("fs_ivy_effective_notes") and
            not ivy.has("fs_ivy_effective_notes_have_passives") and
            b.accuracy.scripted_rolls.size()==7,
            "missing learned Skill142 DB record invalidates cached CharacterCore Notes"):return

    print("FS P531 native last-wins Skill146 Pain cap400, State85 cap300, OD142 16% nonduplicated, legacy814, dynamic learning and strict RNG-safe source fail-close PASS")
    quit(0)
