extends FSPlayableSlice
# Private integration fixture. Exact approved source resource is injected;
# the normal FS scene, real database and production bindings are unchanged.
const BODY=preload("res://scripts/animation/FSShjSharedFixtureSprite.gd")
const STAGE=preload("res://scripts/ui/FSShjSharedFixtureEnemyStage.gd")
var approved_frames: SpriteFrames
var map_body: AnimatedSprite2D
var pmd_stage: FSBattleOriginalEnemyStage
var installed: bool = false

func _ready() -> void:
    super._ready()
    if approved_frames==null or db.boot_final_verified:
        return
    var body:=BODY.new()
    body.name="SHJFireMapEventPreview"
    # Same existing synthetic event 2, same collision and VX301 script.
    body.position=Vector2(9*TILE+16,5*TILE+28)
    add_child(body)
    if not body.configure(approved_frames):
        body.queue_free()
        return
    map_body=body
    installed=true
    _sync_map_visibility()

func _process(_delta:float) -> void:
    _sync_map_visibility()

func _sync_map_visibility() -> void:
    if is_instance_valid(map_body):
        map_body.visible=world!=null and world.map_id==DATA.MAP_FOREST and not world.switch_on(10) and battle_overlay==null

func _on_combat_ready(combat:FSBattle,troop_id:int) -> void:
    super._on_combat_ready(combat,troop_id)
    _sync_map_visibility()
    # Only the explicitly declared synthetic forest encounter; no real DB id binding.
    if not installed or troop_id!=1 or world.map_id!=DATA.MAP_FOREST or battle_view==null or combat.db.boot_final_verified:
        return
    # Fail closed on branches that lack the settled presentation signal.
    if not combat.has_signal(&"target_outcome_resolved"):
        return
    if battle_view.configure_shj_fixture_candidate(approved_frames):
        pmd_stage=battle_view.enemy_stage
