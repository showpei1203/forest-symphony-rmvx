extends SceneTree
const REG=preload("res://scripts/source/FSUnifiedSourceRegistry.gd")
func _initialize()->void:
    call_deferred("_run")
func fail(why:String)->void:
    push_error("P539 source integration fail: "+why)
    quit(1)
func _run()->void:
    var reg=REG.new()
    if reg.load_private_index() or reg.loaded:
        fail("public GitHub CI should not include original 505 private source")
        return
    var sections:Array=[]
    for i in range(505):
        sections.append({"section":i+1,"source_sha256":"a".repeat(64)})
    var data:Dictionary={}
    for n in ["Actors","Classes","Skills","Items","Weapons","Armors",
              "Enemies","States","Troops","System","Animations"]:
        data[n]="b".repeat(64)
    var mock:Dictionary={"schema":"fs-unified-original-source-index-v1",
        "source_scripts_rvdata_sha256":REG.SHA,
        "source_script_sections":505,"sections":sections,
        "original_data_sha256":data,"method_candidates":{},
        "static_resource_literals":[]}
    if not REG.validate(mock).is_empty():
        fail("complete synthetic 505 source format rejected")
        return
    mock["sections"][90]["section"]=97
    if REG.validate(mock).is_empty():
        fail("corrupt original load order falsely accepted")
        return
    print("P539 native unified full-original source index 505 sections, 11 DB format, refuse altered order PASS; original RGSS2 NOT executed")
    quit(0)
