extends Control
class_name FSStorySandbox

# Art-free, source-safe 544x416 interactive event demonstration.
# This is a functional testing scene, not an original FS map/ground/PAR reproduction.
const STATE = preload("res://scripts/FSGameState.gd")
const STORY = preload("res://scripts/story/FSStoryRuntime.gd")
const MARKER = preload("res://scripts/story/FSStoryEventMarker.gd")
const DIALOGUE = preload("res://scripts/story/FSDialoguePanel.gd")

const TILE: int = 32
const MAP_SIZE: Vector2i = Vector2i(17,13)
const CHEST: Vector2i = Vector2i(4,6)
const NPC: Vector2i = Vector2i(8,6)

var world: FSGameState
var story: FSStoryRuntime
var dialogue: FSDialoguePanel
var markers: Dictionary = {}
var player: Vector2i = Vector2i(4,5)
var face: Vector2i = Vector2i(0,1)
var instructions: Label
var status_label: Label
var last_error: String = ""

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    world = STATE.new()
    world.map_id = 999
    world.map_x = player.x
    world.map_y = player.y
    story = STORY.new()
    add_child(story)
    story.story_failed.connect(_on_story_error)
    story.runner.completed.connect(_on_story_complete)
    dialogue = DIALOGUE.new()
    dialogue.name = "StoryDialogue"
    add_child(dialogue)
    dialogue.bind(story.runner)
    _add_marker(CHEST,"res://story/events/map_999_event_001.json")
    _add_marker(NPC,"res://story/events/map_999_event_002.json")
    _make_hud()
    _update_status()
    queue_redraw()

func _make_hud() -> void:
    instructions = Label.new()
    instructions.text = "FS 劇情測試場：方向鍵／WASD 移動，E／Enter 與前方互動"
    instructions.position = Vector2(8,8)
    instructions.add_theme_color_override("font_color",Color(0.95,0.95,0.92))
    add_child(instructions)
    status_label = Label.new()
    status_label.position = Vector2(8,28)
    status_label.add_theme_color_override("font_color",Color(0.95,0.98,0.83))
    add_child(status_label)
    var interact_button := Button.new()
    interact_button.text = "調查"
    interact_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
    interact_button.offset_left = -92
    interact_button.offset_right = -8
    interact_button.offset_top = -48
    interact_button.offset_bottom = -8
    interact_button.pressed.connect(interact_front)
    add_child(interact_button)

func _add_marker(tile: Vector2i, file: String) -> void:
    var marker: FSStoryEventMarker = MARKER.new()
    marker.event_file = file
    marker.position = Vector2(tile * TILE) + Vector2(16,16)
    marker.name = "Event_%d_%d" % [tile.x,tile.y]
    markers[tile] = marker
    add_child(marker)

func _draw() -> void:
    for x in MAP_SIZE.x:
        for y in MAP_SIZE.y:
            var color: Color = Color(0.11,0.19,0.19) if (x+y)%2 == 0 else Color(0.12,0.205,0.21)
            draw_rect(Rect2(x*TILE,y*TILE,TILE,TILE),color)
            draw_rect(Rect2(x*TILE,y*TILE,TILE,TILE),Color(0.3,0.42,0.43,0.14),false,1)
    draw_rect(Rect2(CHEST*TILE+Vector2i(3,5),Vector2i(26,22)),Color(0.64,0.39,0.12))
    draw_rect(Rect2(CHEST*TILE+Vector2i(3,5),Vector2i(26,22)),Color(0.94,0.77,0.35),false,2)
    draw_rect(Rect2(NPC*TILE+Vector2i(8,4),Vector2i(16,24)),Color(0.43,0.61,0.95))
    draw_circle(Vector2(NPC*TILE)+Vector2(16,8),7,Color(0.94,0.78,0.59))
    draw_rect(Rect2(player*TILE+Vector2i(7,6),Vector2i(18,24)),Color(0.92,0.85,0.8))
    draw_circle(Vector2(player*TILE)+Vector2(16,8),7,Color(0.82,0.91,0.99))
    var look: Vector2 = Vector2(player*TILE) + Vector2(16,16) + Vector2(face)*14
    draw_circle(look,3,Color(1.0,0.96,0.6))

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if story.runner.active:
        return # Let dialogue UI receive confirm / cancel without moving.
    var direction: Vector2i = Vector2i.ZERO
    match event.keycode:
        KEY_UP,KEY_W: direction = Vector2i(0,-1)
        KEY_DOWN,KEY_S: direction = Vector2i(0,1)
        KEY_LEFT,KEY_A: direction = Vector2i(-1,0)
        KEY_RIGHT,KEY_D: direction = Vector2i(1,0)
        KEY_E,KEY_ENTER,KEY_KP_ENTER:
            interact_front()
            get_viewport().set_input_as_handled()
            return
        _:
            return
    move_one_tile(direction)
    get_viewport().set_input_as_handled()

func move_one_tile(direction: Vector2i) -> void:
    if story.runner.active or direction == Vector2i.ZERO:
        return
    face = direction
    var next: Vector2i = player + direction
    if next.x < 0 or next.y < 1 or next.x >= MAP_SIZE.x or next.y >= MAP_SIZE.y:
        queue_redraw()
        return
    # Stationary event markers occupy their tiles; interact from an adjacent tile.
    if markers.has(next):
        queue_redraw()
        return
    player = next
    world.map_x = player.x
    world.map_y = player.y
    _update_status()
    queue_redraw()

func interact_front() -> Dictionary:
    if story.runner.active:
        return {"ok":false,"error":"劇情進行中"}
    var target: Vector2i = player + face
    if not markers.has(target):
        last_error = "前方沒有可調查的事件"
        _update_status()
        return {"ok":false,"error":last_error}
    var marker: FSStoryEventMarker = markers[target]
    var outcome: Dictionary = marker.interact(world,story)
    if not bool(outcome.get("ok",false)):
        last_error = str(outcome.get("error","無法啟動事件"))
        _update_status()
    return outcome

func _on_story_complete() -> void:
    last_error = ""
    _update_status()
    queue_redraw()

func _on_story_error(reason: String) -> void:
    last_error = reason
    _update_status()

func _update_status() -> void:
    status_label.text = "位置 (%d,%d) | 物品#1 ×%d | 金錢 %d | %s" % [
        player.x,player.y,world.amount("item",1),world.gold,last_error]
