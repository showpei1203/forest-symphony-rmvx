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
    "menu/menu_薇娜.png":"4b8220abada5c06ab60cf2c0fa8d7a2d316d0018b928c98fee510a994baf6dda",
    "menu/Battle01.png":"4f12bbe245e73648c302f532c4013be3ca37cafb5bf367224a33360ce4f3aea3",
    "menu/Battle01a.png":"82b68c569455d62c8a338f5e44d93b0bc2c0bfd3458c2571a9f2b0d360f7a370",
    "menu/Battle02.png":"f4c47422edc12446c92a317b2cce30db0b418fc74f89303c296cc4da0fc09bc8",
    "menu/Battle02a.png":"f01b2b0f6d67dc487a617ff7208d4b82d842aca91999b0ee6439ab611593123e",
    "menu/Battle03.png":"a4f2f04ad78e1e0a56d3399c4c7a06acde946237785509ac679ea7c969a020b8",
    "menu/Battle03a.png":"dbc55a5c19744a6a80b4b6c5f0343eae4df6cedb429ea26e13c4ed9b3f029a17",
    "menu/Battle04.png":"6ee5fdfaf36d0d3db92402b3ea0cceb5653d439d4f46ded99d88475f55adef97",
    "menu/Battle04a.png":"22a38b8190795eb80956b23ff24c6aa6a2f829dc282625e842c689c21029c619",
    "menu/Battle05.png":"1b2b2475e0792a25f4f51f76e3b828b87b90cb5e181fc3422e42af3058e5de2d",
    "menu/Battle05a.png":"452b02babff7740d82a7706d7c14eb25bc9f72daff8988d4e8b3730407d8d720",
    "system/MenuBack_b.png":"5b9db441132cada7d06e71ef643a453efcb72b3cda63ddfa4bfc9a552eb2332a",
    "menu/Menu01.png":"d7190866f8a0652f4a7665ea91bee314062731b952398f2cce9c7530a4ecfc8c",
    "menu/Menu02.png":"254f6bceaf378f436241fcdfed3bab02b36bee0123aec8298a3df5fb468eaa48",
    "menu/Menu03.png":"e5744b3c316b4efe9d711df2505224ef4095b85d5d712d26c4a32b91cf67a8ac",
    "menu/Menu04.png":"27747ce76ab02bbbf4ce23afec017923d5eadf448fed1350a07fbcd1b4f53651",
    "menu/Menu05.png":"bc840be3d2ee1a2086e468febdf6460644f28143068d8bd2c4012bc377b51f25",
    "menu/Menu06.png":"9670ec4c8b4f639a3afcb07149fffe3d6750fcfbb1c2ae429e550a55ca1ad552",
    "menu/Menu07.png":"a3749bc763864a9198881dba1474d61e31e54968cd1b537d157633e94ad49b0e",
    "menu/Menu08.png":"fd4f1b4155cfe85824a1a5906d24bd1c5999548e62b35df7dc8775ee125f98b9",
    "menu/Status01.png":"04521d4a23e35636dffad8b7afc5d2e0ba86c5ca69db04a6125840e02c8c4958",
    "menu/Status02.png":"40c33e7d5585b615b96607d2087642cc8f05ab307d0c087d70029ee5784bd5b7",
    "menu/Skill01.png":"48802ad4316d31fe58851a0a6129adc72e9f0e2e77aedb0ea13f78c0ad7201ae",
    "menu/Skill02.png":"2653b7a871de0165d2e67d3a26beb72e824db044a23625a005303035ab18a8f1",
    "menu/Skill03.png":"411e80aabfd62090dcdddd283350b37ea2a62d13177145258ce0bb2aab13a8c5",
    "menu/Item01.png":"a266209d5e2ab32a76479bc6bfbcec1f70f4ce80c3d7ce7f0f8aacf8dbb0f71a",
    "menu/Item02.png":"8441e0c279f9605ed80200693733733c10dcfef7159d385a0eabb5bfd912b1e5",
    "menu/Item03.png":"8122cb76708f1572d756788e7cf55830c346282b48d46ca7fce4707bd7c2a01e",
    "menu/Equip01.png":"813ea58c200f3ad9679a05e644059ba0fa60d3e854e3a7039a0965f6f889bbb4",
    "menu/Equip02.png":"b5bd67dc0a6a3d8f1a7becfdaa611a0abff8379c20146959a08279efe1b6a20d"
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
