extends FSBattleOriginalEnemyStage
# Explicitly opt-in synthetic fixture adapter for the actual FS enemy stage.
# Never map a production monster by guessed database id or art filename.
const BODY=preload("res://scripts/animation/FSShjSharedFixtureSprite.gd")
const HUD=preload("res://scripts/ui/FSBattleSourceStateHUD381.gd")
var approved_frames: SpriteFrames
var fixture_battle: FSBattle
var fixture_body: AnimatedSprite2D
var fixture_slot: int = 0
var last_serial: int = 0
var played_outcomes: int = 0
var source_foot: Vector2 = Vector2.ZERO

func configure_fixture(frames: SpriteFrames, b: FSBattle) -> bool:
    if b==null or b.db==null or b.db.boot_final_verified or not b.active or not b.has_signal(&"target_outcome_resolved"):
        return false
    if b.enemies.size()!=1 or int(b.enemies[0].get("id",0))!=1:
        return false
    if frames==null or not frames.has_animation(&"idle"):
        return false
    approved_frames=frames
    _unbind_fixture()
    fixture_battle=b
    last_serial=0
    b.connect(&"target_outcome_resolved",_on_fixture_outcome)
    b.finished.connect(_on_fixture_finished)
    return bind_real(b)==1

func bind_real(battle: FSBattle) -> int:
    if battle==null or battle!=fixture_battle or approved_frames==null or not battle.active:
        return super.bind_real(battle)
    if battle.db==null or battle.db.boot_final_verified or battle.enemies.size()!=1 or int(battle.enemies[0].get("id",0))!=1:
        clear_enemies()
        return 0
    # Existing FS stage owns the layout, name and HUD anchor rect. Reuse it.
    var idle:Texture2D=approved_frames.get_frame_texture(&"idle",0)
    var count:int=rebuild(battle.enemies,func(_enemy:Dictionary)->Texture2D: return idle)
    if count!=1:
        return 0
    var image:TextureRect=enemy_views[0]["image"]
    var caption:Label=enemy_views[0]["caption"]
    caption.hide()
    var body:=BODY.new()
    body.name="SHJFireSharedBody"
    image.add_child(body)
    if not body.configure(approved_frames):
        body.queue_free()
        clear_enemies()
        return 0
    fixture_body=body
    image.texture=null # no stretched duplicate art; the Control remains the HUD anchor
    image.resized.connect(_place_fixture_body)
    _place_fixture_body()
    return count

func _place_fixture_body() -> void:
    if not is_instance_valid(fixture_body):
        return
    var image:=fixture_body.get_parent() as Control
    if image==null:
        return
    source_foot=HUD.enemy_anchor_from_rect(image.get_global_rect())
    fixture_body.position=Vector2(image.size.x*0.5,image.size.y)

func clear_enemies() -> void:
    fixture_body=null
    super.clear_enemies()

func _on_fixture_outcome(event: Dictionary) -> void:
    var serial:int=int(event.get("serial",0))
    if serial<=last_serial:
        return
    last_serial=serial
    if fixture_battle==null or not fixture_battle.active or not is_instance_valid(fixture_body) or not visible:
        return
    if fixture_battle.enemies.size()!=1 or int(fixture_battle.enemies[0].get("id",0))!=1 or int(fixture_battle.enemies[0].get("hp",0))<=0:
        return
    var result:String=str(event.get("result",""))
    if not result in ["hit","miss","evade"]:
        return
    var action:StringName=&""
    if event.get("source_side")=="enemy" and int(event.get("source_slot",-1))==fixture_slot and int(event.get("source_id",0))==1 and event.get("action")=="attack":
        action=&"Attack"
    if action!=&"" and fixture_body.start_motion(action):
        played_outcomes+=1

func _on_fixture_finished(_victory: bool) -> void:
    if is_instance_valid(fixture_body):
        fixture_body.stop()
        fixture_body.hide()

func _unbind_fixture() -> void:
    if fixture_battle!=null and is_instance_valid(fixture_battle):
        if fixture_battle.has_signal(&"target_outcome_resolved") and fixture_battle.is_connected(&"target_outcome_resolved",_on_fixture_outcome):
            fixture_battle.disconnect(&"target_outcome_resolved",_on_fixture_outcome)
        if fixture_battle.finished.is_connected(_on_fixture_finished):
            fixture_battle.finished.disconnect(_on_fixture_finished)
    fixture_battle=null

func _exit_tree() -> void:
    _unbind_fixture()
