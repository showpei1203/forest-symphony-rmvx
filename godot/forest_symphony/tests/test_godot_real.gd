extends SceneTree
## PRIVATE OWNER PACKAGE ONLY. Real A21 1280x928 art, F0 and three A28 PARs.
## Run: Godot --headless --path <package> --script res://tests/test_godot_real.gd
const Overlay = preload("res://scripts/fs_occlusion.gd")
const ActorPath := "res://private_assets/actor_f0.png"
const GroundPath := "res://private_assets/full_ground.png"
const GoldActorSHA := "a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba"
const GoldGroundSHA := "091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530"
var checks := 0

func check(condition: bool, label: String) -> void:
    checks += 1
    if not condition:
        push_error("A29 REAL TEST FAIL: " + label)
        quit(1)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    check(FileAccess.file_exists(ActorPath), "private F0 present")
    check(FileAccess.file_exists(GroundPath), "private Master present")
    check(FileAccess.get_sha256(ActorPath) == GoldActorSHA, "F0 source SHA")
    check(FileAccess.get_sha256(GroundPath) == GoldGroundSHA, "original Ground SHA")
    var scene: PackedScene = load("res://scenes/elf_forest_map.tscn")
    check(scene != null, "Godot scene import")
    var root_node := scene.instantiate()
    get_root().add_child(root_node)
    await process_frame
    var player = root_node.get_node("Characters/Player")
    check(player.original_actor != null, "real F0 loaded")
    check(player.owners.size() == 3, "three original cropped PAR owners")
    var cases := [
        [Vector2i(232, 556), 197],
        [Vector2i(232, 596), 0],
        [Vector2i(735, 621), 29],
        [Vector2i(735, 670), 0],
    ]
    for item in cases:
        player.position = Vector2(item[0].x, item[0].y)
        player.refresh_occlusion()
        var overlay: Image = player.dynamic_overlay.get_image()
        check(Overlay.opaque_count(overlay) == item[1], "real original-XY source-mask parity %s" % str(item[0]))
    print("A29 REAL GODOT SOURCE SHA + FOUR-FOOTPOINT PAR PASSED: %d checks (ART NOT YET APPROVED)" % checks)
    quit(0)
