extends RefCounted
class_name FSUnifiedSourceRegistry

# Unified original FS source authority from owner-private 505 RGSS2 scripts.
# This is metadata, NEVER an RGSS2 executor or gameplay parity seal.
const SHA:String="d398178135c5b41622b0e6da763d58af1fbf770c9d24a360a23508800015809a"
const PRIVATE_PATH:String="res://assets/source_authority/fs_unified_source_registry.json"
var loaded:bool=false
var sections:Array=[]
var method_graph:Dictionary={}
var asset_literals:Array=[]
var errors:Array[String]=[]

static func validate(payload:Dictionary)->Array[String]:
    var problems:Array[String]=[]
    if str(payload.get("schema",""))!="fs-unified-original-source-index-v1":
        problems.append("Source schema differs")
    if str(payload.get("source_scripts_rvdata_sha256",""))!=SHA:
        problems.append("Original Scripts.rvdata SHA differs")
    if int(payload.get("source_script_sections",0))!=505:
        problems.append("Source section count is not 505")
    var records:Variant=payload.get("sections")
    if not records is Array or records.size()!=505:
        problems.append("505 original section records missing")
    else:
        for i in range(505):
            if not records[i] is Dictionary or int(records[i].get("section",-1))!=i+1:
                problems.append("Original RGSS2 section order mismatch")
                break
            if str(records[i].get("source_sha256","")).length()!=64:
                problems.append("Original Ruby section fingerprint missing")
                break
    var data:Variant=payload.get("original_data_sha256")
    if not data is Dictionary or data.size()!=11:
        problems.append("Original 11 source data tables missing")
    else:
        for key in ["Actors","Classes","Skills","Items","Weapons","Armors",
                    "Enemies","States","Troops","System","Animations"]:
            if not data.has(key) or str(data[key]).length()!=64:
                problems.append("Original data table SHA absent: "+key)
    if not payload.get("method_candidates") is Dictionary:
        problems.append("Method candidate index absent")
    if not payload.get("static_resource_literals") is Array:
        problems.append("Source UI resource literals absent")
    return problems

func load_private_index(path:String=PRIVATE_PATH)->bool:
    loaded=false
    errors.clear()
    sections.clear()
    method_graph.clear()
    asset_literals.clear()
    if not FileAccess.file_exists(path):
        errors.append("Owner-only original RGSS2 source index not staged")
        return false
    var data:Variant=JSON.parse_string(FileAccess.get_file_as_string(path))
    if not data is Dictionary:
        errors.append("Private source index invalid")
        return false
    errors=validate(data)
    if not errors.is_empty():
        return false
    sections=data["sections"]
    method_graph=data["method_candidates"]
    asset_literals=data["static_resource_literals"]
    loaded=true
    return true

func evidence_for_method(klass:String,method:String)->Array:
    if not loaded:
        return []
    return method_graph.get(klass+"#"+method,[])

func section(index:int)->Dictionary:
    if not loaded or index<1 or index>505:
        return {}
    return sections[index-1]

func runtime_rgss_parity_passed()->bool:
    # Cannot be inferred from an archive or a lexical method index.
    return false
