@tool
extends Marker2D
class_name FSStoryEventMarker

# Drop FSStoryEventMarker.tscn onto a Godot 2D map and select event_file in the Inspector.
# Map/player controllers call interact() on the marker when an interaction occurs.
# The marker shows a 32 px outline in the editor, not during actual gameplay.

const DATA = preload("res://scripts/story/FSStoryData.gd")

@export_file("*.json") var event_file: String = ""
@export var tile_size: Vector2i = Vector2i(32,32):
    set(value):
        tile_size = Vector2i(maxi(1,value.x),maxi(1,value.y))
        queue_redraw()
@export var editor_marker_visible: bool = true:
    set(value):
        editor_marker_visible = value
        queue_redraw()

func _draw() -> void:
    if not Engine.is_editor_hint() or not editor_marker_visible:
        return
    var half: Vector2 = Vector2(tile_size) / 2.0
    draw_rect(Rect2(-half,Vector2(tile_size)),Color(0.3,0.8,1.0,0.75),false,2.0)
    draw_circle(Vector2.ZERO,3.0,Color(0.3,0.8,1.0,0.9))

func interact(world: FSGameState, story: FSStoryRuntime, requested_trigger: String = "action") -> Dictionary:
    if event_file.is_empty():
        return {"ok":false,"error":"此地圖標記尚未指定事件 JSON"}
    var event: Dictionary = DATA.read_event(event_file)
    if event.is_empty():
        return {"ok":false,"error":"事件檔不存在或格式驗證失敗：" + event_file}
    return story.interact(event,world,requested_trigger)
