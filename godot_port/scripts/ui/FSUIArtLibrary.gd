extends RefCounted
class_name FSUIArtLibrary

# Private UI source images are not in GitHub. Do not silently treat
# generated/stand-in sprites as original art.
const ROOT:String="res://assets/ui/"
const MANIFEST:String=ROOT+"fs_ui_import_manifest.json"
const ARCHIVE_SHA:String="c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6"
# Independent hash authority from verified private original UI ZIP. A forged
# staging manifest alone must NOT authorize these critical original pixels.
const SOURCE_LOCKS:Dictionary={
    "system/MenuBack_a.png":"e7037dca065ebea01aaec70f8bd5c8b2cf722d4371066f0b2aa8eb59633a6f03",
    "system/MenuBack_status_a.png":"bc428e38cb195abbb86744b8bf7e3438bc235ce0944db3c1f3f77dbee6c55627",
    "system/MenuBack_skill.png":"217ba0bcc275801b65e48913db97b5035023b1f3a5ba06b34e7da153eb7408c8",
    "system/MenuBack_item.png":"d937c493466b70ae68f465c7a7c7a004fdf79e5243d60595cbe307ea13dc39d9",
    "system/MenuBack_equip.png":"4a67f566f900668b062cec52cf0ad6c1f14cd54906c5ea79f6e1a47689fd0cda",
    "system/MenuBack_party.png":"7abcb7103934c4300fac65141624b6d1c1c5954aadc784b99dd168f77bb202b4",
    "system/Btskin_main.png":"87671d016b03069558601d1e4d0351ead9762671cb964fbc33a6055ab15348f6",
    "system/GaugeHP.png":"dd93fd33175d3c38628cb18fef7deb08c5fc488c1499e99c7dd73d558df2666c",
    "system/GaugeMP.png":"ef5d6f21e23ef23943088fa248f366507908d64718b6b8aee384cc212796e5c4",
    "system/GaugeOD.png":"ad6678a254e28a0438d9dd104c73030027f614cda4a454b5490182da00e12914",
    "system/atb_bar.png":"fb2b3e1c55c798d924537c6dc830bd35a077d85a2a4c7642a1b7594ff711270a",
    "system/atb_bar_skin.png":"bb6cee3c130a992d5672a73d69d5c6738b138063b56358c930481033ec547c8d",
    "system/iconset.png":"8273bc643025f92496a7471cf080cd6a87d0a762fc04731c7f016e00f0c0bb2c",
    "menu/menu_喬伊.png":"25a4e7982341e93e9ba2ff3562c5d585b64f5eadb7f2d049d40c2397a1a33e32",
    "menu/menu_泰勒.png":"49ff0c9b922ef2365f5371c76bea59652bbc5a37cdb54858e2da16fcd470e2db",
    "menu/menu_米亞.png":"3adaf0a83fc091526382c78e7af32f5ac8191393a646854869829b0317fa3594",
    "menu/menu_艾卓.png":"93d8a97437502f3759813e9d7e0ae4a4b0e115ae02be04163c4661f74c86fc1e",
    "menu/menu_艾薇.png":"ff5c1d02a34a881c78b6bd3f0d5891721d255874c212dfd85dfb5e2ec19601bf",
    "menu/menu_薇娜.png":"4b8220abada5c06ab60cf2c0fa8d7a2d316d0018b928c98fee510a994baf6dda"
}
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
    if SOURCE_LOCKS.has(key) and str(record.get("sha256",""))!=str(SOURCE_LOCKS[key]):
        return null
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
