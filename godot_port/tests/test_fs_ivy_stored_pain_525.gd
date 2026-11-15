extends SceneTree

# Source ALBERT_MECHANIC_EXPANSION v1.1 actual stored pain:
# All_Scripts_Export.txt ~219640,220012-220252 + Phase46A/B2 test.
# Integration confirms actual HP loss, not provisional damage, and
# source effective Notes/state override required for any activation.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok:bool,why:String)->bool:
    if not ok:
        push_error("FS Ivy stored-pain 525 native FAIL: "+why)
        quit(1)
        return false
    return true

func _actor(id:int,name:String,df:int)->Dictionary:
    return {"id":id,"name":name,"actor":true,"hp":1000,
        "maxhp":1000,"mp":100,"maxmp":100,"atk":50,"def":df,
        "spi":10,"agi":20,"hit":95,"eva":5,"cri":10,"od":0,
        "element_set":[],"states":[],"skills":[],"equipment":[],
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true}

func _battle()->FSBattle:
    var db=DB.new()
    db.tables={"enemies":[null,{"id":1,"name":"Enemy",
        "maxhp":9000,"maxmp":100,"atk":50,"def":10,"spi":10,
        "agi":20,"hit":95,"eva":5,"has_critical":false,
        "actions":[],"note":""}],"weapons":[null],
        "armors":[null],"states":[null]}
    var b=BATTLE.new(db)
    b.party.append(_actor(1,"Friend",10))
    var ivy:Dictionary=_actor(5,"Ivy",20)
    ivy["max_od"]=1000
    ivy["fs_ivy_guard_source_verified"]=true
    ivy["fs_ivy_pain_notes_verified"]=true
    ivy["fs_ivy_effective_notes"]=[]
    b.party.append(ivy)
    b.add_enemy(1)
    var enemy:Dictionary=b.enemies[0]
    enemy["level"]=1
    enemy["element_set"]=[]
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    enemy["fs_normal_element_neutral_verified"]=true
    b.accuracy.active=true
    b.normal_core.active=true
    b.ivy_cover.active=true
    b.ivy_pain.active=true
    b.source_atb_rolls_for_test={"actor:0":0,"actor:1":0,"enemy:0":0}
    return b

func _hit(b:FSBattle)->void:
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]

func _covered_hit(b:FSBattle)->void:
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0,
        0,99,99,0,0]

func _run()->void:
    var b:FSBattle=_battle()
    if not _check(b.start(),"real battle starts"):return
    var ally:Dictionary=b.party[0]
    var ivy:Dictionary=b.party[1]
    var enemy:Dictionary=b.enemies[0]
    _hit(b)
    var dealt:int=b.attack(enemy,ivy)
    if not _check(dealt==77 and int(ivy["hp"])==923 and
            int(ivy["fs_ivy_stored_pain"])==38 and
            int(ivy["od"])==140 and
            bool(b.ivy_pain.events[-1]["cover"])==false,
            "actual direct HP77 * source direct50% =38 stored, Ivy OD+2/+2"):return

    # Source <ig:2,3,25> is already parsed/covered by 522. The
    # guarded actor HP is unchanged, Ivy actual 58 HP loss stored100%.
    ivy["fs_ivy_guard_charges"]=2
    ivy["fs_ivy_guard_actions_left"]=3
    ivy["fs_ivy_guard_reduce"]=25
    _covered_hit(b)
    dealt=b.attack(enemy,ally)
    if not _check(dealt==58 and int(ally["hp"])==1000 and
            int(ivy["hp"])==865 and
            int(ivy["fs_ivy_stored_pain"])==96 and
            int(ivy["od"])==240 and
            bool(b.ivy_pain.events[-1]["cover"]),
            "Cover actual HP58 stores100%, adds prior direct38 =>96"):return

    # Source strongest Note override wins; original State85 and
    # Equipment/Profile/Actor effective Notes must be prevalidated.
    ivy["fs_ivy_effective_notes"]=[
        "<store_cover_damage:150>\n<cover_store_cap_percent:300>"]
    var quote:Dictionary=b.ivy_pain.quote(b,enemy,ivy,{"hp":20},true)
    if not _check(bool(quote.get("ok",false)) and int(
            quote["gain"])==30 and int(quote["cap"])==3000,
            "source strongest Cover Note150% of20=30, cap300% MaxHP"):return
    var pending:Dictionary=b.ivy_pain.quote(b,enemy,ivy,{"hp":30},false)
    if not _check(bool(pending.get("ok",false)) and int(
            pending["gain"])==15 and int(pending["cap"])==3000,
            "no direct Note: direct damage default50% unaffected by cover Note"):return
    ivy["states"]=[85]
    ivy["fs_ivy_furnace_state_verified"]=true
    quote=b.ivy_pain.quote(b,enemy,ivy,{"hp":30},false)
    if not _check(bool(quote.get("ok",false)) and int(quote["gain"])==30,
            "Source State85 Pain Furnace direct actual loss30 stores100%"):return
    ivy["fs_ivy_effective_notes"].append("<store_direct_damage:175>")
    quote=b.ivy_pain.quote(b,enemy,ivy,{"hp":20},false)
    if not _check(bool(quote.get("ok",false)) and int(quote["gain"])==35,
            "stronger direct override175% beats Furnace State85 default100%"):return
    ivy["states"]=[]
    ivy["fs_ivy_stored_pain"]=2990
    quote=b.ivy_pain.quote(b,enemy,ivy,{"hp":100},true)
    if not _check(int(quote.get("new",-1))==3000 and int(
            quote.get("gain",-1))==10,
            "source damage stored-value cap300% MaxHP inclusive"):return
    ivy["fs_ivy_effective_notes"].append("<cover_store_cap_percent:400>")
    quote=b.ivy_pain.quote(b,enemy,ivy,{"hp":100},true)
    if not _check(int(quote.get("new",-1))==3140 and int(
            quote.get("cap",-1))==4000,
            "highest source cap400 from Skill146 overrides cap300"):return

    # The real source wrapper stores actual damage BEFORE process_party_OD.
    # Unverified effective Notes must block early, preserving HP, OD,
    # stored pain and battle HIT/EVA scripted rolls.
    ivy["fs_ivy_pain_notes_verified"]=false
    ivy["fs_ivy_guard_charges"]=0
    ivy["fs_ivy_guard_actions_left"]=0
    _hit(b)
    var before_hp:int=int(ivy["hp"])
    var before_od:int=int(ivy["od"])
    var before_store:int=int(ivy["fs_ivy_stored_pain"])
    if not _check(not b.attack_preflight(enemy,ivy) and
            b.attack(enemy,ivy)==0 and int(ivy["hp"])==before_hp and
            int(ivy["od"])==before_od and
            int(ivy["fs_ivy_stored_pain"])==before_store and
            b.accuracy.scripted_rolls.size()==7,
            "missing source Notes blocks actual HIT before RNG/HP/OD/Pain"):return

    # Combined Fatal Cover + stored pain must store safe HP-1 actual
    # damage, never planned lethal HP58. Original Phase46B2 checks 49.
    var f:FSBattle=_battle()
    var fskills:Array=[]
    fskills.resize(147)
    fskills[146]={"id":146,"scope":0,"name":"Fatal Passive",
        "note":"<mechanic_passive>\n<cover_store_cap_percent:400>"}
    f.db.tables["skills"]=fskills
    if not _check(f.start(),"fatal+stored source battle starts"):return
    var fi:Dictionary=f.party[1]
    fi["skills"]=[146]
    fi["fs_ivy_fatal_source_verified"]=true
    fi["fs_ivy_effective_notes"]=["<cover_store_cap_percent:400>"]
    fi["hp"]=50
    fi["od"]=500
    fi["fs_ivy_guard_charges"]=2
    fi["fs_ivy_guard_actions_left"]=3
    fi["fs_ivy_guard_reduce"]=25
    _covered_hit(f)
    dealt=f.attack(f.enemies[0],f.party[0])
    if not _check(dealt==49 and int(fi["hp"])==1 and
            int(fi["od"])==300 and int(fi["fs_ivy_stored_pain"])==49 and
            int(f.ivy_pain.events[-1]["actual_loss"])==49 and
            bool(f.ivy_cover.events[-1]["fatal_save"]),
            "fatal Cover HP1, OD300 paid, stored-pain ACTUAL49 not proposed58"):return

    print("FS Phase525 Ivy real guarded/direct HP loss, Furnace85, source strongest Notes, cap200/300/400, fatal49 and fail-close PASS")
    quit(0)
