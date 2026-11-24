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
        if accepted!=expected:
            mismatches+=1
            print("EGM_GODOT_DETAIL ",str(db.errors))
    print("EGM_GODOT_DISAGREEMENTS ",mismatches)
    quit(1 if args.has("--enforce") and mismatches>0 else 0)
