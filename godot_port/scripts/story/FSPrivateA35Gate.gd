extends RefCounted
class_name FSPrivateA35Gate

# Only verified, owner-only A35 R8 R3 village can be loaded.
# This is an actual source-art SCENE PREVIEW, not a post-Apply 11 DB,
# 505 RGSS alias witness or a completed event/battle integration.
const ROOT:String="res://a35_private/"
const MANIFEST:String=ROOT+"fs_private_a35_manifest.json"
const SCENE:String=ROOT+"scenes/a35_r8_r3_grove_balance_scene.tscn"
const GROUND:String=ROOT+"private_assets/ground_only.png"
const ARCHIVE_SHA:String="1c235f6155298a8f4bd54173e228ad4061ac8abced29d3d296136e0567983830"
const GROUND_SHA:String="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"

static func inspect()->Dictionary:
    if not FileAccess.file_exists(MANIFEST):
        return {"ok":false,"reason":"私人 A35 村莊尚未匯入，沒有正式素材"}
    var file:=FileAccess.open(MANIFEST,FileAccess.READ)
    if file==null:
        return {"ok":false,"reason":"私人地圖 manifest 無法讀取"}
    var parsed:Variant=JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        return {"ok":false,"reason":"私人地圖 manifest 格式無效"}
    var manifest:Dictionary=parsed
    if str(manifest.get("schema",""))!="fs-private-a35-village-stage/v1" or (
            str(manifest.get("map_id",""))!="FS_01_VILLAGE") or (
            str(manifest.get("art",""))!="HOLD") or (
            str(manifest.get("source_archive_sha256",""))!=ARCHIVE_SHA) or (
            str(manifest.get("ground_sha256",""))!=GROUND_SHA) or (
            str(manifest.get("scene",""))!=SCENE):
        return {"ok":false,"reason":"私人 A35 場景版本／來源驗證失敗"}
    if not FileAccess.file_exists(GROUND) or (
            FileAccess.get_sha256(GROUND)!=GROUND_SHA):
        return {"ok":false,"reason":"私人 Ground-only PNG 未找到或 SHA256 不符"}
    if not ResourceLoader.exists(SCENE):
        return {"ok":false,"reason":"A35 原生場景缺失或素材尚未匯入 Godot"}
    var scene:Resource=load(SCENE)
    if not scene is PackedScene:
        return {"ok":false,"reason":"A35 原生場景載入失敗"}
    return {"ok":true,"scene":scene,"map_id":"FS_01_VILLAGE","art":"HOLD"}
