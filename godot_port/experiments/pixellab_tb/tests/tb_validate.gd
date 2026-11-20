extends SceneTree
## Run: godot --headless --path . --script res://tests/tb_validate.gd
const ROOT := "res://assets/monsters/tb/"
const STATIC := ["PMD0001_STATIC_64.png", "PMD0002_STATIC_64.png", "PMD0003_STATIC_64.png"]
const ATLASES := {
    "PMD0001_IDLE_3F_192x64.png": Vector2i(192,64),
    "PMD0001_ATTACK_8F_256x128.png": Vector2i(256,128),
}
func _initialize() -> void:
    var problems: Array[String] = []
    for f in STATIC:
        var t: Texture2D = load(ROOT + f)
        if t == null or t.get_size() != Vector2(64,64):
            problems.append("static bad: " + f)
    for f in ATLASES:
        var t: Texture2D = load(ROOT + f)
        if t == null or t.get_size() != Vector2(ATLASES[f]):
            problems.append("atlas bad: " + f)
    var meta := FileAccess.open(ROOT + "FAMILY_MANIFEST.json", FileAccess.READ)
    if meta == null:
        problems.append("manifest missing")
    else:
        var parsed: Variant = JSON.parse_string(meta.get_as_text())
        if not (parsed is Dictionary) or parsed.get("status","") != "CANDIDATE_NOT_ART_APPROVED":
            problems.append("manifest status mismatch")
    if problems.is_empty():
        print("T-B Godot imported resource geometry: PASS; visual ART remains HOLD")
        quit(0)
    else:
        for p in problems:
            push_error(p)
        quit(1)
