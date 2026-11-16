extends RefCounted
class_name FSCheckpointCodec

# Versioned, data-only Forest Symphony checkpoint transport. No FileAccess:
# authoring/runtime data are not written to the user's development PC.
# The playable slice keeps a checkpoint in memory. Later a connected
# private Drive/cloud-save layer may persist EXACTLY this JSON string.
# No eval(), resource deserialization or script execution from JSON.
const VERSION:int=1
const KIND:String="fs_godot_story_checkpoint_v1"
const MAX_JSON_BYTES:int=262144

static func _fail(reason:String)->Dictionary:
    return {"ok":false,"reason":reason}

static func pack(world:FSGameState)->Dictionary:
    if world==null:
        return _fail("沒有可保存的 FSGameState")
    var payload:Dictionary={"type":KIND,"version":VERSION,
        "world":world.as_save_dict()}
    var canonical:String=JSON.stringify(payload)
    if canonical.to_utf8_buffer().size()>MAX_JSON_BYTES:
        return _fail("劇情檢查點超出安全尺寸")
    # Digest the exact encoded payload bytes, not JSON.stringify of a
    # re-parsed Dictionary: Godot may parse integer JSON numbers as float,
    # so reconstructing canonical JSON after parsing can change 50→50.0.
    var envelope:Dictionary={"payload_json":canonical,
        "sha256":canonical.sha256_text()}
    return {"ok":true,"json":JSON.stringify(envelope),
        "sha256":str(envelope["sha256"])}

static func inspect(json_text:String)->Dictionary:
    if json_text.is_empty() or json_text.to_utf8_buffer().size()>MAX_JSON_BYTES:
        return _fail("檢查點內容為空或超過限制")
    var raw:Variant=JSON.parse_string(json_text)
    if not (raw is Dictionary):
        return _fail("檢查點不是 JSON 物件")
    var payload_json:Variant=raw.get("payload_json",null)
    var sha:Variant=raw.get("sha256",null)
    if not (payload_json is String) or not (sha is String):
        return _fail("缺少檢查點資料或 SHA256")
    if str(payload_json).to_utf8_buffer().size()>MAX_JSON_BYTES:
        return _fail("檢查點內層資料超出安全尺寸")
    if str(sha).length()!=64 or str(sha)!=str(
            payload_json).sha256_text():
        return _fail("檢查點內容不一致或遭到修改")
    var payload:Variant=JSON.parse_string(str(payload_json))
    if not (payload is Dictionary):
        return _fail("已驗證 SHA 的檢查點不是有效 JSON 物件")
    if payload.get("type",null)!=KIND or int(
            payload.get("version",0))!=VERSION:
        return _fail("存檔格式／版本不相容")
    var values:Variant=payload.get("world",null)
    if not (values is Dictionary):
        return _fail("缺少劇情世界資料")
    for name in ["switches","variables","self_switches","inventory"]:
        if not (values.get(name,null) is Dictionary):
            return _fail("缺少合法的世界狀態欄位 "+name)
    if not (values.get("party_actor_ids",null) is Array):
        return _fail("存檔沒有合法隊伍")
    var map_id:int=int(values.get("map_id",-1))
    var x:int=int(values.get("map_x",-1))
    var y:int=int(values.get("map_y",-1))
    if FSPlayableSliceData.map_name(map_id).is_empty() or (
            x<0 or x>=FSPlayableSliceData.WIDTH) or (
            y<2 or y>=FSPlayableSliceData.HEIGHT):
        return _fail("存檔指向尚未支援的地圖／座標")
    if values["party_actor_ids"].is_empty():
        return _fail("存檔缺少有效戰鬥隊伍")
    for actor_id in values["party_actor_ids"]:
        if int(actor_id)!=1:
            return _fail("合成測試場不允許載入未知的正式 FS 角色")
    for key in values["switches"]:
        if not str(key).is_valid_int() or int(key)<1 or not (
                values["switches"][key] is bool):
            return _fail("原始 VX switch 型別或 ID 不合法")
    for key in values["variables"]:
        if not str(key).is_valid_int() or int(key)<1 or not (
                values["variables"][key] is float or (
                values["variables"][key] is int)):
            return _fail("原始 VX variable 型別或 ID 不合法")
    for key in values["inventory"]:
        var prefix:String=str(key).split(":")[0]
        if prefix not in ["item","weapon","armor"] or (
                not str(key).contains(":")) or not (
                str(key).split(":").size()==2) or not (
                str(key).split(":")[1].is_valid_int()) or int(
                values["inventory"][key])<0 or int(
                values["inventory"][key])>99:
            return _fail("背包物品／ID／數量不合法")
    if int(values.get("gold",-1))<0:
        return _fail("金錢不能為負數")
    # Stage restore into an isolated object. The caller MUST apply this
    # result only when no event/ACT is running.
    var staged:=FSGameState.new()
    staged.restore_save_dict(values)
    return {"ok":true,"world":staged.as_save_dict(),
        "sha256":sha}
