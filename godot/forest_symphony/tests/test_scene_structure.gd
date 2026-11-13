extends SceneTree
## Fail-closed: the whole Godot PackedScene must instantiate, not only GDScript unit tests.
func _initialize() -> void:
    call_deferred("_check_scene")

func _check_scene() -> void:
    var packed: PackedScene = load("res://scenes/elf_forest_map.tscn")
    if packed == null:
        push_error("A29 FAIL: PackedScene cannot load")
        quit(1)
        return
    var state: SceneState = packed.get_state()
    print("A29 SCENE STATE nodes=", state.get_node_count())
    for i in range(state.get_node_count()):
        print("A29 NODE ",i," ",state.get_node_name(i)," type=",state.get_node_type(i)," parent=",state.get_node_path(i))
    var instance: Node = packed.instantiate()
    if instance == null:
        push_error("A29 FAIL: scene cannot instantiate")
        quit(1)
        return
    get_root().add_child(instance)
    var required := ["FullGround", "Occluders/LeftTree", "Occluders/RightTree", "Occluders/BridgeRail", "CollisionPaint", "Characters/Player", "Characters/Player/ActorVisual", "Characters/Player/ActorForeground", "Characters/Player/Camera2D"]
    for path in required:
        if instance.get_node_or_null(NodePath(path)) == null:
            push_error("A29 FAIL: missing required scene node " + path)
            quit(1)
            return
    print("A29 GODOT SCENE TREE PASS: ", required.size(), " nodes")
    quit(0)
