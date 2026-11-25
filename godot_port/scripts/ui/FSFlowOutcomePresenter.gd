extends Node2D
# Opt-in ACTOR01 only. No art promotion, no combat mutations, no polling of result fields.
const ADAPTER = preload("res://scripts/animation/FSFlowBattlePresentation.gd")
var adapter: Node2D
var configured: bool = false
var bound_battle: FSBattle
var last_serial: int = 0
var played: int = 0
var last_action: String = ""
var _actor_slot: int = -1
var _actor: Dictionary = {}
var _anchor_provider: Callable
var _enemy_provider: Callable
var _battle_visible: Callable

func _ready() -> void:
    adapter = ADAPTER.new()
    adapter.scale = Vector2(-1,1) # Same fixed left-facing stage orientation as A52.
    add_child(adapter)
    adapter.visual_finished.connect(_finished)
    adapter.animation_player.playback_failed.connect(_failed)
    hide()

func configure_candidate(frames: SpriteFrames) -> bool:
    cancel()
    configured = adapter.configure(frames)
    return configured

func bind_battle(b: FSBattle, actor_anchor: Callable, enemy_anchor: Callable, visible_check: Callable) -> void:
    _anchor_provider = actor_anchor
    _enemy_provider = enemy_anchor
    _battle_visible = visible_check
    if bound_battle == b:
        return
    cancel()
    if bound_battle != null:
        if bound_battle.target_outcome_resolved.is_connected(_on_outcome):
            bound_battle.target_outcome_resolved.disconnect(_on_outcome)
        if bound_battle.finished.is_connected(_battle_finished):
            bound_battle.finished.disconnect(_battle_finished)
    bound_battle = b
    last_serial = 0
    if b != null:
        b.target_outcome_resolved.connect(_on_outcome)
        b.finished.connect(_battle_finished)

func _exit_tree() -> void:
    bind_battle(null,Callable(),Callable(),Callable())

func _actor01_slot() -> int:
    if bound_battle == null: return -1
    var found: int = -1
    for i in range(bound_battle.party.size()):
        if int(bound_battle.party[i].get("id",0)) == 1 and bool(bound_battle.party[i].get("actor",false)):
            if found != -1: return -1
            found = i
    return found

func _valid_context() -> bool:
    return configured and bound_battle != null and bound_battle.active and _battle_visible.is_valid() and bool(_battle_visible.call())

func _on_outcome(e: Dictionary) -> void:
    var serial: int = int(e.get("serial",0))
    if serial <= last_serial: return
    # Consume even if hidden, not configured, or irrelevant; do not replay on redraw.
    last_serial = serial
    if not _valid_context(): return
    var slot: int = _actor01_slot()
    if slot < 0: return
    var actor: Dictionary = bound_battle.party[slot]
    if int(actor.get("hp",0)) <= 0:
        cancel()
        return
    var source_is_actor: bool = e.get("source_side")=="party" and int(e.get("source_slot",-1))==slot and int(e.get("source_id",0))==1
    var target_is_actor: bool = e.get("recipient_side")=="party" and int(e.get("recipient_slot",-1))==slot and int(e.get("recipient_id",0))==1
    var result: String = str(e.get("result",""))
    if not result in ["hit","miss","evade"]: return
    var action: String = ""
    var toward: Vector2 = Vector2.ZERO
    if source_is_actor:
        if e.get("action")=="attack": action = "attack"
        elif e.get("action")=="skill": action = "cast"
    elif target_is_actor:
        if result=="evade" and e.get("source_side")=="enemy":
            if not _enemy_provider.is_valid(): return
            var enemy: Variant = _enemy_provider.call(int(e.get("source_slot",-1)))
            if not enemy is Vector2 or not enemy.is_finite(): return
            if not _place(slot,actor): return
            toward = adapter.to_local(enemy)
            if toward.length_squared() < 0.000001: return
            action = "dodge"
        elif result=="hit" and (int(e.get("hp_effect",0))>0 or int(e.get("shield_mp",0))>0):
            action = "damage"
    if action.is_empty(): return
    if not _place(slot,actor): return
    if adapter.start_action(action,toward):
        last_action = action
        played += 1
        show()

func _place(slot: int, actor: Dictionary) -> bool:
    if not _anchor_provider.is_valid(): return false
    var anchor: Variant = _anchor_provider.call()
    if not anchor is Vector2 or not anchor.is_finite(): return false
    global_position = anchor
    _actor_slot = slot
    _actor = actor
    return true

func tick_context() -> void:
    if not visible: return
    if not _valid_context() or _actor_slot != _actor01_slot() or _actor_slot < 0 or not is_same(bound_battle.party[_actor_slot],_actor) or int(_actor.get("hp",0))<=0:
        cancel()
        return
    if not _place(_actor_slot,_actor): cancel()

func cancel() -> void:
    if adapter != null: adapter.reset_presentation()
    hide()
    _actor_slot = -1
    _actor = {}

func _finished(_action: String) -> void:
    cancel() # Return exactly to the real slot; no synthetic idle art.

func _failed(_reason: String) -> void:
    cancel()

func _battle_finished(_victory: bool) -> void:
    cancel()
