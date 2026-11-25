extends SceneTree
# Synthetic fixtures created by Python, never original runtime evidence.
const DB=preload("res://scripts/FSDatabase.gd")
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    var args:=OS.get_cmdline_user_args()
    if args.is_empty():
        push_error("Missing synthetic fixture root")
        quit(2)
        return
    var root:String=args[0]
    var idx:Variant=JSON.parse_string(FileAccess.get_file_as_string(root.path_join("index.json")))
    if not idx is Array:
        quit(2)
        return
    var mismatches:int=0
    for c in idx:
        var db=DB.new()
        var accepted:bool=db.load_all(root.path_join(str(c["name"])))
        var expected:bool=c["expected"]
        print("EGM_GODOT ",c["name"]," ","ACCEPT" if accepted else "REJECT"," expected=","ACCEPT" if expected else "REJECT")
        var reason_ok:bool=true
        if bool(c.get("hash_before_parse",false)):
            var saw_hash:bool=false
            for line in db.errors:
                if line.contains("SHA256 不符合 manifest"):
                    saw_hash=true
                if line.contains("JSON 無法解碼"):
                    reason_ok=false
            reason_ok=reason_ok and saw_hash
        if accepted!=expected or not reason_ok:
            mismatches+=1
            print("EGM_GODOT_DETAIL ",str(db.errors))
    print("EGM_GODOT_DISAGREEMENTS ",mismatches)
    quit(1 if args.has("--enforce") and mismatches>0 else 0)
