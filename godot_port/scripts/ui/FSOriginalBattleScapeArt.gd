extends RefCounted
class_name FSOriginalBattleScapeArt

const PATH:String="res://assets/battle_scapes/"
const MANIFEST:String=PATH+"fs_battle_scapes_import_manifest.json"
const ARCHIVE_SHA:String="fc0e5f7a14dd239bdf7dd5db3a9041bcdf59616cfef71da903c2ad1657b0c76b"
const IMAGE_SHA:Dictionary={
 "new_back00.png":"79d95fb213115561e0be4b4c37f169fdd38480ad5815cf28e1f5798ab898ca4b",
 "temp1.png":"eb77c242d1b9400eff1b96634c089cb000dcd444806388767ecd444e53c7fc29",
 "ffog.png":"5b15d19fe41c5c81834877cd6fc3211bc3c2745dca531ea53161f70bc12ec1ac",
 "new_back01.png":"658fed494341756c95bc149a979454ac5fe8cfe5d37c6b1f8ecacb7c71797829",
 "new_back02.png":"97b076e5e9486c988b2d0389a5b1dd9cff686fa223bbe11a3c9ee7c633c942b5",
 "back02.jpg":"f0871682023053dc619f351eadb638540fbc6e9da301499021e41b814ec460f4",
 "back08.jpg":"4f83c9d4806509e34477fd9804ce55495fe871ec6a02b2056643a6043075d37c"}
var _read:bool=false
var _manifest:Dictionary={}
var _cache:Dictionary={}

func _load_manifest()->void:
    if _read:return
    _read=true
    if not FileAccess.file_exists(MANIFEST):return
    var data:Variant=JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
    if not data is Dictionary or str(data.get("schema",""))!=(
            "fs-godot-private-battle-scapes-v1") or (
            str(data.get("original_archive_sha256",""))!=ARCHIVE_SHA) or (
            int(data.get("source_section",0))!=264):
        return
    if data.get("missing_source_names",null)!=["Bridge","BlueSky"]:
        return
    var records:Variant=data.get("files",[])
    if not records is Array or records.size()!=7:return
    for item in records:
        if not item is Dictionary:return
        var n:String=str(item.get("name",""))
        if not IMAGE_SHA.has(n) or _manifest.has(n) or (
                str(item.get("sha256",""))!=IMAGE_SHA[n]):
            _manifest.clear()
            return
        _manifest[n]=item
    if _manifest.size()!=IMAGE_SHA.size():_manifest.clear()

func has_source()->bool:
    _load_manifest()
    return _manifest.size()==7

func texture_by_source_name(name:String)->Texture2D:
    if not name.is_valid_filename() or name in ["Bridge","BlueSky"]:
        return null
    var fn:String=""
    match name:
        "new_back00","temp1","ffog","new_back01","new_back02":
            fn=name+".png"
        "back02","back08":
            fn=name+".jpg"
        _:
            return null
    _load_manifest()
    if not _manifest.has(fn):return null
    if _cache.has(fn):return _cache[fn]
    var filename:String=PATH+fn
    if not FileAccess.file_exists(filename) or (
            FileAccess.get_sha256(filename)!=str(IMAGE_SHA[fn])) or (
            not ResourceLoader.exists(filename)):
        return null
    var tex:Resource=load(filename)
    if not tex is Texture2D:
        return null
    _cache[fn]=tex
    return tex
