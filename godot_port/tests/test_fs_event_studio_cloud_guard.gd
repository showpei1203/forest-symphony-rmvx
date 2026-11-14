extends SceneTree

# Safety guard must prevent unapproved local files, even if UI save is clicked.
const Data = preload("res://scripts/story/FSStoryData.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var original_ci: String = OS.get_environment("GITHUB_ACTIONS")
    var original_auth: String = OS.get_environment("FS_EVENT_AUTHORIZED_EPHEMERAL_WRITE")
    OS.set_environment("GITHUB_ACTIONS","false")
    OS.set_environment("FS_EVENT_AUTHORIZED_EPHEMERAL_WRITE","false")
    var record: Dictionary = Data.new_event(988,976)
    var file: String = Data.path_for(record)
    var result: Dictionary = Data.write_event(record)
    var safe: bool = not bool(result.get("ok",false)) and not FileAccess.file_exists(file) and not Data.cloud_write_allowed()
    OS.set_environment("GITHUB_ACTIONS",original_ci)
    OS.set_environment("FS_EVENT_AUTHORIZED_EPHEMERAL_WRITE",original_auth)
    if not safe:
        push_error("Cloud hard rule violation: event was saved without approved cloud workspace")
        quit(1)
        return
    print("FS Event Studio fail-closed local-write protection PASS")
    quit(0)
