extends Node2D
## Source-locked Leaf Bat R8 attack presentation for FS ACT battle.
## PRESENTER ONLY. FSBattle/FSActionQueue owns ALL HP, MP, target, and damage.
## No inferred enemy-ID mapping: the combat battler must explicitly carry
## {"fs_monster_visual_id": "TB02_LEAF_BAT"} from a separately verified mapping.
signal visual_attack_started(action_key: String)
signal visual_hit_cue(action_key: String, world_mouth: Vector2)
signal visual_attack_finished(action_key: String)
signal source_refused(reason: String)

const TIMELINE = preload("res://experiments/pixellab_tb/tb_attack_timeline_parametric.gd")
const BITE_PATH := "res://assets/monsters/tb02/TB02_BAT_ATTACK_BITE_R8_FINAL_11F_PAD128.png"
const IDLE_PATH := "res://assets/monsters/tb02/TB02_BAT_IDLE_8F.png"
const BITE_SHA256 := "b258678a7a4b59251b13126ed905c47afd9b9dffd0a618fbb64f584ad9ceeee7"
const IDLE_SHA256 := "5153e58ccf29dee9d924937fb185169f45e2d0f748a36373cc2f53d4eb72e0a2"
const MONSTER_VISUAL_ID := "TB02_LEAF_BAT"
const FRAME_SIZE := Vector2i(128, 128)
const IDLE_FRAME_SIZE := Vector2i(96, 96)
const IDLE_FRAMES := 8

# Tests with SYNTHETIC textures may override art source checking explicitly.
# Do not enable this flag in real gameplay or in a private-real-asset gate.
var allow_synthetic_qa_art: bool = false
var battle: Variant = null
var enemy_index: int = -1
var _completed_cursor: int = 0
var _queued_actions: Array[String] = []
var _active_key: String = ""
var _ever_seen: Dictionary = {}
var _is_ready: bool = false
var _idle: AnimatedSprite2D
var _attack: Node2D

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _is_ready = _install_art()

func _install_art() -> bool:
    for entry in [{"path": BITE_PATH, "sha": BITE_SHA256},
            {"path": IDLE_PATH, "sha": IDLE_SHA256}]:
        var path: String = str(entry["path"])
        if not FileAccess.file_exists(path):
            source_refused.emit("source PNG absent: " + path)
            return false
        if not allow_synthetic_qa_art and FileAccess.get_sha256(path) != entry["sha"]:
            source_refused.emit("source SHA mismatch: " + path)
            return false
    var idle_tex: Texture2D = load(IDLE_PATH)
    var attack_tex: Texture2D = load(BITE_PATH)
    if idle_tex == null or attack_tex == null:
        source_refused.emit("texture import unavailable")
        return false
    if idle_tex.get_size() != Vector2(384, 192) or (
            attack_tex.get_size() != Vector2(512, 384)):
        source_refused.emit("atlas grid dimensions mismatch")
        return false
    var sf: SpriteFrames = SpriteFrames.new()
    sf.remove_animation("default")
    sf.add_animation("idle")
    sf.set_animation_speed("idle", 8.0)
    sf.set_animation_loop("idle", true)
    for idx in IDLE_FRAMES:
        var frame: AtlasTexture = AtlasTexture.new()
        frame.atlas = idle_tex
        frame.region = Rect2((idx % 4) * IDLE_FRAME_SIZE.x,
                int(idx / 4) * IDLE_FRAME_SIZE.y,
                IDLE_FRAME_SIZE.x, IDLE_FRAME_SIZE.y)
        frame.filter_clip = true
        sf.add_frame("idle", frame)
    _idle = AnimatedSprite2D.new()
    _idle.name = "TB02LeafBatIdle"
    _idle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _idle.sprite_frames = sf
    add_child(_idle)
    _idle.play("idle")
    _attack = TIMELINE.new()
    _attack.name = "TB02R8MouthBiteAttack"
    _attack.texture_path = BITE_PATH
    _attack.cell_size = FRAME_SIZE
    _attack.bite_contact = Vector2(14, 0)
    _attack.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    add_child(_attack)
    if _attack.sprite == null:
        source_refused.emit("attack timeline could not build")
        return false
    _attack.visible = false
    _attack.hit_requested.connect(_on_visual_hit)
    _attack.attack_completed.connect(_on_visual_complete)
    return true

func bind_battle(value: Variant, index: int) -> bool:
    # Rebinding must never leave an earlier battle receipt stream attached.
    unbind_battle()
    # An explicitly tagged authoritative monster is mandatory. Never infer
    # TB02 from display names, guessed VX enemy IDs, or troop positions.
    if not _is_ready or value == null:
        return false
    if index < 0 or index >= value.enemies.size():
        return false
    if str(value.enemies[index].get("fs_monster_visual_id", "")) != MONSTER_VISUAL_ID:
        return false
    battle = value
    enemy_index = index
    _completed_cursor = value.action_queue.completed.size()
    _queued_actions.clear()
    _ever_seen.clear()
    _active_key = ""
    _attack.cancel_attack()
    _attack.visible = false
    _idle.visible = true
    _idle.play("idle")
    return true

func unbind_battle() -> void:
    battle = null
    enemy_index = -1
    _completed_cursor = 0
    _queued_actions.clear()
    _ever_seen.clear()
    _active_key = ""
    if _attack != null:
        _attack.cancel_attack()
        _attack.visible = false
    if _idle != null:
        _idle.visible = true
        _idle.play("idle")

func _process(_delta: float) -> void:
    read_completed_actions()

func read_completed_actions() -> void:
    if battle == null or enemy_index < 0:
        return
    var completions: Array = battle.action_queue.completed
    # Handles an explicitly recycled action log without replaying the old
    # log when the same visual stage was opened again.
    if completions.size() < _completed_cursor:
        _completed_cursor = 0
        _ever_seen.clear()
    for idx in range(_completed_cursor, completions.size()):
        var item: Dictionary = completions[idx]
        if str(item.get("side", "")) != "enemy" or (
                int(item.get("enemy_index", -1)) != enemy_index) or (
                str(item.get("kind", "")) != "attack") or (
                not bool(item.get("success", false))):
            continue
        var key: String = "enemy:%d:%d" % [enemy_index,
                int(item.get("serial", -1))]
        if not _ever_seen.has(key):
            _ever_seen[key] = true
            _queued_actions.append(key)
    _completed_cursor = completions.size()
    _start_next_if_idle()

func _start_next_if_idle() -> void:
    if _active_key != "" or _queued_actions.is_empty() or _attack == null:
        return
    _active_key = _queued_actions.pop_front()
    _idle.visible = false
    _attack.visible = true
    if not _attack.play_attack():
        source_refused.emit("visual timeline refused attack: " + _active_key)
        _attack.visible = false
        _idle.visible = true
        _active_key = ""
        return
    visual_attack_started.emit(_active_key)

func _on_visual_hit(frame_idx: int, local_contact: Vector2) -> void:
    if frame_idx != 5 or _active_key == "":
        return
    # VFX ONLY. HP/MP/RNG/ACT have ALREADY been committed by FSBattle.
    # No call to battle.attack(), queue.resolve_ready(), or use_skill().
    visual_hit_cue.emit(_active_key,
            _attack.to_global(local_contact))

func _on_visual_complete() -> void:
    if _active_key == "":
        return
    var finished_key: String = _active_key
    _active_key = ""
    _attack.visible = false
    _idle.visible = true
    _idle.play("idle")
    visual_attack_finished.emit(finished_key)
    _start_next_if_idle()
