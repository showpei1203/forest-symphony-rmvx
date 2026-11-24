extends SceneTree
# P538F: structural witness counts and SHA alone CANNOT make invalid
# source-cross-referenced VX tables playable. All tables synthetic and in
# memory; these are negative controls, NOT original post-Apply evidence.
const DB=preload("res://scripts/FSDatabase.gd")

func _initialize()->void:
    call_deferred("_run")

func check(value:bool,where:String)->bool:
    if value:
        return true
    push_error("P538F boot-final source integrity native FAIL: "+where)
    quit(1)
    return false

func fixture()->Dictionary:
    var params:Array=[]
    for i in range(100):
        params.append_array([120,50,25,8,7,12])
    var d:Dictionary={}
    for name in DB.NAMES:
        if name=="system":
            d[name]={"party_members":[1]}
        else:
            d[name]=[null,{"id":1}]
    d["actors"][1]={"id":1,"name":"fixture","class_id":1,
        "parameters":{"xsize":6,"ysize":100,"zsize":1,
            "data_int16":params}}
    d["classes"][1]={"id":1,
        "learnings":[{"skill_id":1,"level":1}]}
    d["skills"][1]={"id":1,"name":"fixture skill"}
    d["enemies"][1]={"id":1,"name":"fixture enemy"}
    d["troops"][1]={"id":1,
        "members":[{"enemy_id":1,"hidden":false}]}
    return d

func rejects(source:Dictionary,expected:String,description:String)->bool:
    var output:PackedStringArray=DB.validate_runtime_table_integrity(source)
    var found:bool=false
    for line in output:
        if line.contains(expected):
            found=true
    return check(found,description+" must fail closed, got "+str(output))

func _run()->void:
    var valid:Dictionary=fixture()
    if not check(DB.validate_runtime_table_integrity(valid).is_empty(),
            "source-shaped 11-table synthetic valid baseline"):
        return
    var counts:Dictionary={}
    for key in DB.NAMES:
        if key!="system":
            counts[key]=1
    var witness:Dictionary={
        "stage":"post_FS_DB_AUTOSET.apply_all",
        "engine":"RPG Maker VX RGSS2",
        "table_counts":counts,"party_actor_ids":[1]
    }
    if not check(DB.validate_runtime_witness(witness).is_empty() and
            DB.validate_witness_against_tables(witness,valid).is_empty(),
            "old counts+party source witness is intentionally insufficient"):
        return
    var test:Dictionary=valid.duplicate(true)
    test["actors"][1]["class_id"]=999
    if not check(DB.validate_witness_against_tables(witness,test).is_empty(),
            "negative control: counts still match after actor class corruption"):
        return
    if not rejects(test,"來源職業不存在","actor class FK"):return
    test=valid.duplicate(true)
    test["actors"][1]["parameters"]["data_int16"].pop_back()
    if not rejects(test,"長度不符","parameter array size"):return
    test=valid.duplicate(true)
    test["actors"][1]["parameters"]["data_int16"][0]=40000
    if not rejects(test,"非法 int16","parameter signed range"):return
    test=valid.duplicate(true)
    test["actors"][1]["parameters"]["xsize"]=5
    if not rejects(test,"維度不合法","parameter six dimension"):return
    test=valid.duplicate(true)
    test["system"]["party_members"]=[2]
    if not rejects(test,"不存在 Actor","runtime initial party FK"):return
    test=valid.duplicate(true)
    test["system"]["party_members"]=[1,1]
    if not rejects(test,"重複 Actor","runtime initial party uniqueness"):return
    test=valid.duplicate(true)
    test["troops"][1]["members"]=[{"enemy_id":99}]
    if not rejects(test,"不存在 Enemy","troop source enemy FK"):return
    test=valid.duplicate(true)
    test["classes"][1]["learnings"]=[{"skill_id":999}]
    if not rejects(test,"不存在 Skill","source learnt-skill FK"):return
    test=valid.duplicate(true)
    test["items"][1]["id"]=2
    if not rejects(test,"索引不一致","record id equals VX table index"):return
    test=valid.duplicate(true)
    test["states"][0]={"id":0}
    if not rejects(test,"第 0 筆必須是 null","VX null ID-zero sentinel"):return
    test=valid.duplicate(true)
    test["armors"]={"id":1}
    if not rejects(test,"資料表不是陣列","invalid source table shape"):return
    test=valid.duplicate(true)
    test["system"]={}
    if not rejects(test,"原始出場隊伍不存在","missing System start roster"):return

    # No fixture can manufacture a true VX post-Apply runtime witness.
    # boot_final_verified remains false in ordinary in-memory DBs.
    var local_db=DB.new()
    local_db.tables=valid
    if not check(not local_db.boot_final_verified,
            "structural synthetic fixture must never authorize gameplay"):
        return
    print("P538F Godot4.7.2 11-table semantic integrity: valid 1 + 12 negative controls PASS; post-Apply VX runtime capture and 505 effective alias STILL HOLD")
    quit(0)
