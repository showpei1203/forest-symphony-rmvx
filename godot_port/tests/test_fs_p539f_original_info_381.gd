extends SceneTree
# P539F source ORIGINAL #381 lines686..896 in source order, real #377
# ATBResistance, #376 Break State50, #77 ManaShield, source-gated extras.
# Read-only UI quote MUST NOT mutate combat state/ATB/HP.
const DB=preload("res://scripts/FSDatabase.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const INFO=preload("res://scripts/FSOriginalBattleInfo381.gd")
const HELP=preload("res://scripts/ui/FSBattleSourceTargetHelp462.gd")
const RESIST=preload("res://scripts/FSATBResistance.gd")

func _initialize()->void:
    call_deferred("_run")

func require(ok:bool,why:String)->bool:
    if not ok:
        push_error("P539F real #381 InfoRows source authority FAIL: "+why)
        quit(1)
        return false
    return true

func _run()->void:
    var db:FSDatabase=DATA.database()
    var state:Array=[]
    state.resize(78)
    state[50]={"id":50,"name":"破勢累積","icon_index":12,
        "note":"<target_priority:0>"}
    state[51]={"id":51,"name":"出血","icon_index":20,
        "note":"<target_priority:0>"}
    state[77]={"id":77,"name":"法術護盾","icon_index":17,
        "note":"<mana_shield 200:50><hud_detail_text:防護維持><target_priority:0>"}
    db.tables["states"]=state
    var enemy:Dictionary={
        "id":1,"name":"來源測試敵人","actor":false,
        "hp":300,"maxhp":300,"mp":60,
        "note":"<atb_dynamic_resist><atb_resist_start:1><break_threshold:5><break_resist:20><target_priority:3>",
        "states":[50,77],"state_stack":{50:2},
        "fs_boss_shield_remaining":120,
        "fs_break_recover_amount":2,
        "fs_state_resist_source_verified":true,
        "fs_state_resist_levels":{51:1},
        "fs_state_resist_rates":{51:66}}
    RESIST.setup(enemy)
    if not require(bool(enemy.get("atb_resist_enabled",false)) and (
            RESIST.rate(enemy)==70),
            "#377 original ATBResistance source provider must initialize first"):
        return
    var read_before:Dictionary=enemy.duplicate(true)
    var original:Dictionary=INFO.extra_info_rows(enemy,db)
    if not require(original["ok"] and original["rows"].size()==5,
            "#381 must include 5 verified source providers in exact precedence"):
        return
    var rows:Array=original["rows"]
    if not require(rows[0]["label"]=="法術護盾" and (
            rows[0]["value"]=="剩餘120") and (
            rows[1]["label"]=="ATB延遲抗性") and (
            rows[1]["value"]=="Lv1/4　承受70%　下限10%") and (
            rows[2]["label"]=="破勢") and (
            rows[2]["value"]=="進度2/5　抗性20%　行動後-2") and (
            rows[3]["label"]=="異常抗性") and (
            rows[3]["value"]=="出血66%") and (
            rows[4]["label"]=="目標優先") and (
            rows[4]["value"]=="3"),
            "#381 original Source ManaShield→ATB→Break→StateResist→Target priority"):
        return
    if not require(enemy==read_before,
            "original #381 HUD quote must never mutate live source combat Dictionary"):
        return
    var screen=HELP.new()
    root.add_child(screen)
    if not require(screen.install(db) and screen.select(enemy,true),
            "original target Help must install and select verified enemy"):
        return
    if not require(screen.info_lines.size()==5 and (
            screen.detail_lines.size()==6) and (
            screen.detail_lines[0]=="法術護盾　剩餘120") and (
            screen.detail_lines[1].begins_with("ATB延遲抗性　")) and (
            screen.detail_lines[5].contains("防護維持")),
            "original #381 detail window MUST draw InfoRows BEFORE State lines"):
        return
    # A real source provider changed during a target selection.
    enemy["fs_boss_shield_remaining"]=72
    enemy["atb_resist_level"]=3
    if not require(screen.refresh_live() and (
            screen.detail_lines[0]=="法術護盾　剩餘72") and (
            screen.detail_lines[1].contains("Lv3/4　承受25%")) and (
            not screen.refresh_live()),
            "#381 source selected target dynamic read-only refresh must track live provider"):
        return
    if not require(int(enemy["hp"])==300 and int(enemy["mp"])==60,
            "info panel must never change combat HP/MP/ATB"):
        return
    # A numeric field without source availability cannot be projected
    # into the UI as a verified real game value.
    var no_atb:Dictionary=enemy.duplicate(true)
    no_atb.erase("atb_resist_level")
    if not require(INFO.extra_info_rows(no_atb,db)["rows"].size()==4,
            "missing #377 level cannot print a guessed ATB resistance row"):
        return
    var wrong_shield:Dictionary=enemy.duplicate(true)
    wrong_shield["states"]=[50]
    if not require(INFO.extra_info_rows(wrong_shield,db)["rows"][0][
            "label"]=="ATB延遲抗性",
            "shield value with no active state77 must not fabricate a source shield"):
        return
    var bad:Dictionary=enemy.duplicate(true)
    bad["states"]=[50,999]
    if not require(not INFO.extra_info_rows(bad,db)["ok"],
            "unknown source State ID must fail closed"):
        return
    var ivy:Dictionary={"id":5,"actor":true,"name":"艾薇",
        "hp":450,"maxhp":450,"states":[],
        "fs_ivy_stored_pain":900}
    if not require(INFO.extra_info_rows(ivy,db)["rows"].is_empty(),
            "Ivy pain and original #381 stored COVER are different sources"):
        return
    ivy["fs_ivy_cover_store_source_verified"]=true
    ivy["fs_ivy_stored_cover_damage"]=62
    ivy["fs_ivy_cover_store_cap_percent"]=50.0
    if not require(INFO.extra_info_rows(ivy,db)["rows"][0]["value"]=="62 / 225",
            "only a VERIFIED original Ivy stored-cover provider may show Cover HUD"):
        return
    db.tables["skills"]=[null,{"id":1,"name":"協議斬"}]
    ivy["fs_robot_protocol_source_verified"]=true
    ivy["fs_robot_protocol_data"]=[1,4,[1,2]]
    ivy["fs_robot_protocol_count"]=5
    var ivy_rows:Dictionary=INFO.extra_info_rows(ivy,db)
    if not require(ivy_rows["rows"].size()==2 and (
            ivy_rows["rows"][0]["label"]=="蓄痛") and (
            ivy_rows["rows"][1]["label"]=="協議") and (
            ivy_rows["rows"][1]["value"]=="3次行動後　協議斬　條件2組"),
            "#381 source order IvyCover→Robot protocol and exact remaining-action formula"):
        return
    print("P539F original #381 all seven special InfoRow providers in strict source order, live ManaShield/ATB/Break/StateResist/TargetPriority, Ivy stored-COVER vs Pain, verified Robot Protocol, live TargetHelp source refresh, fail-close and non-mutating Godot472 PASS")
    quit(0)
