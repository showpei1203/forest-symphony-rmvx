extends RefCounted
class_name FSUIArtLibrary

# Private UI source images are not in GitHub. Do not silently treat
# generated/stand-in sprites as original art.
const ROOT:String="res://assets/ui/"
const MANIFEST:String=ROOT+"fs_ui_import_manifest.json"
const ARCHIVE_SHA:String="c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6"
var _entries:Dictionary={}
var _loaded:bool=false
var _textures:Dictionary={}

func _read_manifest()->void:
    if _loaded:
        return
    _loaded=true
    if not FileAccess.file_exists(MANIFEST):
        return
    var file:=FileAccess.open(MANIFEST,FileAccess.READ)
    if file==null:
        return
    var raw:Variant=JSON.parse_string(file.get_as_text())
    if not raw is Dictionary:
        return
    if str(raw.get("schema",""))!="fs-godot-private-ui-v1" or (
            str(raw.get("original_archive_sha256",""))!=ARCHIVE_SHA) or (
            int(raw.get("count",0))!=202):
        return
    var records:Variant=raw.get("files",null)
    if not records is Array or records.size()!=202:
        return
    for record in records:
        if not record is Dictionary:
            _entries.clear()
            return
        var p:String=str(record.get("path",""))
        if not (p.begins_with("menu/") or p.begins_with("system/") or (
                p.begins_with("windows/"))) or p.contains("..") or not p.ends_with(".png"):
            _entries.clear()
            return
        _entries[p]=record
    if _entries.size()!=202:
        _entries.clear()

func has_source()->bool:
    _read_manifest()
    return _entries.size()==202

func texture(category:String,file_name:String)->Texture2D:
    if category not in ["menu","system","windows"] or (
            file_name.contains("/") or file_name.contains("\\") or (
            not file_name.ends_with(".png"))):
        return null
    _read_manifest()
    var key:String=category+"/"+file_name
    if not _entries.has(key):
        return null
    if _textures.has(key):
        return _textures[key]
    var path:String=ROOT+key
    var record:Dictionary=_entries[key]
    if not FileAccess.file_exists(path) or (
            FileAccess.get_sha256(path)!=str(record.get("sha256",""))):
        return null
    if not ResourceLoader.exists(path):
        return null
    var loaded:Resource=load(path)
    if not loaded is Texture2D:
        return null
    var result:Texture2D=loaded
    if int(record.get("width",0))!=result.get_width() or (
            int(record.get("height",0))!=result.get_height()):
        return null
    _textures[key]=result
    return result

static func icon_region(icon_index:int,texture_size:Vector2i)->Rect2:
    # Original VX icon cells are 24x24, but never assume texture size.
    if icon_index<0 or texture_size.x<24 or texture_size.y<24:
        return Rect2()
    var columns:int=int(texture_size.x/24)
    if columns<1:
        return Rect2()
    var pos:Vector2i=Vector2i(icon_index%columns,icon_index/columns)*24
    if pos.y+24>texture_size.y:
        return Rect2()
    return Rect2(Vector2(pos),Vector2(24,24))

func icon(icon_index:int)->Texture2D:
    var atlas:Texture2D=texture("system","iconset.png")
    if atlas==null:
        return null
    var bounds:Rect2=icon_region(icon_index,Vector2i(atlas.get_width(),atlas.get_height()))
    if bounds.size==Vector2.ZERO:
        return null
    var tex:=AtlasTexture.new()
    tex.atlas=atlas
    tex.region=bounds
    tex.filter_clip=true
    return tex
