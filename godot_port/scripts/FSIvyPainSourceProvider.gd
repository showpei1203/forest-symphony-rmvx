extends RefCounted
class_name FSIvyPainSourceProvider

# Source exact LAST-WINS CharacterMechanicCore ~236306-236354,
# overriding earlier ALBERT_COMBO_CORE.source_text:
# user.actor? => ALBERT_ACTOR_PROFILE.tag_text(actor.id)
# + all equipped WEAPON/ARMOR Notes + live State Notes; NOT RPG::Actor.note.
# No manual effective-note strings for a playable original FS.
# The only PRIVATE authority is SHA-bound to the post-FS_DB_AUTOSET
# 11-table runtime witness. Synthetic fixture entrypoint exists for CI.
var active: bool=false
var fixture_only: bool=false
var source_map: Dictionary={}
var errors: Array[String]=[]
var refresh_count: int=0

func _fail(why: String)->Dictionary:
    if not errors.has(why):
        errors.append(why)
    return {"ok":false,"reason":why}

func configure_fixture(mapping:Dictionary)->Dictionary:
    active=false
    fixture_only=false
    source_map.clear()
    if str(mapping.get("source",""))!="ALBERT_CHARACTER_CORE_TAG_TEXT_v1":
        return _fail("原版 CharacterCore 最終 Actor Profile 來源缺失")
    var rows:Variant=mapping.get("actor_profile_tag_text",null)
    if not (rows is Dictionary) or not (rows.get("5",null) is String):
        return _fail("艾薇 Actor5 的集中 Profile tag_text 來源缺失")
    source_map=mapping.duplicate(true)
    active=true
    fixture_only=true
    return {"ok":true}

func configure_private(db:FSDatabase,folder:String="res://data")->Dictionary:
    active=false
    fixture_only=false
    source_map.clear()
    if not db.boot_final_verified:
        return _fail("原版 post-Apply11表與 VX Runtime Witness 尚未驗證")
    var manifest_path:String=folder.path_join("fs_boot_final_authority.json")
    var profile_path:String=folder.path_join("fs_ivy_profile_tag_text.json")
    if not FileAccess.file_exists(manifest_path) or not FileAccess.file_exists(profile_path):
        return _fail("尚無私有 Actor Profile/tag_text 來源或啟動 manifest")
    var manifest:Variant=JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
    var snapshot:Variant=JSON.parse_string(FileAccess.get_file_as_string(profile_path))
    if not (manifest is Dictionary) or not (snapshot is Dictionary):
        return _fail("原版 Profile 私有來源/manifest JSON 不合法")
    var sha:String=str(manifest.get("fs_ivy_profile_sha256","")).to_lower()
    if sha.length()!=64 or sha!=FileAccess.get_sha256(profile_path).to_lower():
        return _fail("艾薇原版 Profile 來源 SHA256 未被 manifest 授權")
    if bool(snapshot.get("incomplete",true)) or bool(
            snapshot.get("not_post_apply",true)):
        return _fail("Actor Profile 靜態草稿不能冒充實際 post-Apply runtime")
    if str(snapshot.get("rgss2_script_sha256","")).to_lower()!=str(
            manifest.get("rgss2_scripts_sha256","")).to_lower():
        return _fail("原版 RGSS2 最終腳本 SHA 與 Profile 不一致")
    if str(snapshot.get("source",""))!="ALBERT_CHARACTER_CORE_TAG_TEXT_v1":
        return _fail("原版 Actor Profile 來源版本不符")
    if not (snapshot.get("actor_profile_tag_text",null) is Dictionary) or not (
            snapshot["actor_profile_tag_text"].get("5",null) is String):
        return _fail("艾薇 Actor5 final Profile.tag_text 不存在")
    source_map=snapshot.duplicate(true)
    active=true
    return {"ok":true,"sha256":sha}

func _state85_verified(state:Dictionary)->bool:
    # FS_MasterSetup STATES State85 ~285060: full state rates are100,
    # hold4, automatic release100, and note includes source mechanics.
    # An unknown patched note or timing is NOT an equivalent state.
    if int(state.get("id",0))!=85 or int(
            state.get("hold_turn",-1))!=4 or int(
            state.get("auto_release_prob",-1))!=100:
        return false
    for stat in ["atk","def","spi","agi"]:
        if int(state.get(stat+"_rate",-1))!=100:
            return false
    var note:String=str(state.get("note","")).to_lower()
    return note.contains("<store_cover_damage:150>") and note.contains(
        "<cover_store_cap_percent:300>") and note.contains(
        "<hud_priority:290>") and note.contains("<hud_detail>")

func build(db:FSDatabase,ivy:Dictionary)->Dictionary:
    if not active:
        return _fail("艾薇有效 Note Source Provider 尚未啟用")
    if not fixture_only and not db.boot_final_verified:
        return _fail("正式 Profile 必須先有 post-Apply11表與來源見證")
    if not bool(ivy.get("actor",false)) or int(ivy.get("id",0))!=5:
        return {"ok":true,"applicable":false}
    var profile:Variant=source_map.get(
        "actor_profile_tag_text",{}).get("5",null)
    if not (profile is String):
        return _fail("Actor5 Profile tag_text 無實際來源")
    var equipped:Variant=ivy.get("equipment",null)
    var states:Variant=ivy.get("states",null)
    if not (equipped is Array) or not (states is Array):
        return _fail("艾薇原版裝備欄/當前狀態集合不可驗證")
    var notes:Array=[profile]
    for slot in range(equipped.size()):
        var id:int=int(equipped[slot])
        if id<=0:
            continue
        var kind:String=db.equip_kind(ivy,slot)
        if kind not in ["weapons","armors"]:
            return _fail("Actor5 原版裝備欄位類別未知")
        var equip:Dictionary=db.record(kind,id)
        if equip.is_empty() or not (equip.get("note",null) is String):
            return _fail("艾薇裝備%d 缺少實際 post-Apply Note" % id)
        notes.append(equip["note"])
    var has_state85:bool=false
    for raw_id in states:
        var state_id:int=int(raw_id)
        if state_id<1:
            return _fail("原版艾薇 State ID 必須是正整數")
        var state:Dictionary=db.record("states",state_id)
        if state.is_empty() or not (state.get("note",null) is String):
            return _fail("艾薇 State%d 缺少 post-Apply source Note" % state_id)
        if state_id==85:
            if not _state85_verified(state):
                return _fail("原始 State85 效果/回合/來源 Note 與 FS_MasterSetup 不相符")
            has_state85=true
        notes.append(state["note"])
    return {"ok":true,"applicable":true,
        "notes":notes,"furnace_verified":has_state85,
        "origin":"synthetic" if fixture_only else "private_post_Apply"}

func refresh(db:FSDatabase,ivy:Dictionary)->Dictionary:
    var built:Dictionary=build(db,ivy)
    if not bool(built.get("ok",false)):
        ivy.erase("fs_ivy_effective_notes")
        ivy.erase("fs_ivy_pain_notes_verified")
        ivy.erase("fs_ivy_furnace_state_verified")
        return built
    if not bool(built.get("applicable",false)):
        return built
    ivy["fs_ivy_effective_notes"]=built["notes"].duplicate(true)
    ivy["fs_ivy_pain_notes_verified"]=true
    ivy["fs_ivy_furnace_state_verified"]=bool(built["furnace_verified"])
    refresh_count+=1
    return built
