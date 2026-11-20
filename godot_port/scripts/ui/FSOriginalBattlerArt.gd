extends RefCounted
class_name FSOriginalBattlerArt

# Only actual source Graphics/Battlers/*.png, archived owner-only.
# Filename is taken from DB enemy.battler_name, NEVER guessed by ID.
const PATH:String="res://assets/battlers/"
const MANIFEST:String=PATH+"fs_battlers_import_manifest.json"
const ARCHIVE_SHA:String="4d2f629ea643187d2b96999798214c1fdf75a1ec969df1c29561bf7bfa1ee9e3"
const EXPECTED_COUNT:int=167
var _read:bool=false
var _manifest:Dictionary={}
var _textures:Dictionary={}

func _load_manifest()->void:
    if _read:
        return
    _read=true
    if not FileAccess.file_exists(MANIFEST):
        return
    var f:=FileAccess.open(MANIFEST,FileAccess.READ)
    if f==null:
        return
    var obj:Variant=JSON.parse_string(f.get_as_text())
    if not obj is Dictionary or str(obj.get("schema",""))!="fs-godot-private-battlers-v1":
        return
    if str(obj.get("original_archive_sha256",""))!=ARCHIVE_SHA or (
            int(obj.get("source_count",0))!=EXPECTED_COUNT):
        return
    var rows:Variant=obj.get("files")
    if not rows is Array or rows.size()!=EXPECTED_COUNT:
        return
    var provisional:Dictionary={}
    for rec in rows:
        if not rec is Dictionary:
            return
        var n:String=str(rec.get("name",""))
        if not _safe_name(n) or provisional.has(n):
            return
        provisional[n]=rec
    if provisional.size()==EXPECTED_COUNT:
        _manifest=provisional

static func _safe_name(name:String)->bool:
    if not name.ends_with(".png") or name.length()<5 or name.contains("/") or (
            name.contains("\\") or name.contains("..") or name.contains(":")):
        return false
    return true

func has_source()->bool:
    _load_manifest()
    return _manifest.size()==EXPECTED_COUNT

func texture_for_enemy(enemy:Dictionary)->Texture2D:
    if not enemy.has("battler_name") or int(enemy.get("battler_hue",0))!=0:
        # VX battler_hue recolouring not yet source-verified in Godot.
        return null
    var basename:String=str(enemy["battler_name"])
    if basename.is_empty() or not _safe_name(basename+".png"):
        return null
    _load_manifest()
    var key:String=basename+".png"
    if not _manifest.has(key):
        return null
    if _textures.has(key):
        return _textures[key]
    var path:String=PATH+key
    var rec:Dictionary=_manifest[key]
    if not FileAccess.file_exists(path) or (
            FileAccess.get_sha256(path)!=str(rec.get("sha256",""))):
        return null
    if not ResourceLoader.exists(path):
        return null
    var res:Resource=load(path)
    if not res is Texture2D:
        return null
    var texture:Texture2D=res
    if texture.get_width()!=int(rec.get("width",0)) or (
            texture.get_height()!=int(rec.get("height",0))):
        return null
    _textures[key]=texture
    return texture
