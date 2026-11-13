@tool
extends EditorPlugin

const Dock = preload("res://addons/fs_event_studio/FSStoryEditorDock.gd")
var dock: Control

func _enter_tree() -> void:
    dock = Dock.new()
    add_control_to_bottom_panel(dock, "FS Events")

func _exit_tree() -> void:
    if dock != null:
        remove_control_from_bottom_panel(dock)
        dock.queue_free()
        dock = null
