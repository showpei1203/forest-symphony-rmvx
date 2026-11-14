extends Node2D
## FS A40: live ATTACK demo, hit marker from Godot AnimationPlayer method track.

@onready var run_actor: FSBattleActorAnimator = $RunActor
@onready var idle_actor: FSBattleActorAnimator = $IdleActor
var hud: Label
var footer: Label
var paused: bool = false
var hits: int = 0
var completed: int = 0
var last_hit_second: float = -1.0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    idle_actor.attack_hit.connect(_on_attack_hit)
    idle_actor.attack_finished.connect(_on_attack_finished)
    hud = Label.new()
    hud.position = Vector2(27,20)
    hud.add_theme_color_override("font_color",Color(0.95,0.96,0.91))
    add_child(hud)
    footer = Label.new()
    footer.position = Vector2(27,50)
    footer.text = "1 R1 | 2 Calm | 3 R2 | 4 Run8 | 5 Run10 | 6 Native Breathing | 7 ATTACK | Space Pause"
    footer.add_theme_color_override("font_color",Color(0.74,0.82,0.78))
    add_child(footer)
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0,0,1024,720),Color(0.08,0.115,0.15))
    draw_rect(Rect2(0,479,1024,241),Color(0.12,0.165,0.17))
    draw_line(Vector2(0,479),Vector2(1024,479),Color(0.25,0.36,0.30),3.0)
    for pos in [Vector2(326,487),Vector2(698,487)]:
        draw_arc(pos,99.0,0.0,TAU,64,Color(0.30,0.45,0.38),2.0)

func _on_attack_hit(_serial: int, hit_second: float) -> void:
    hits += 1
    last_hit_second = hit_second
    print("A40_ATTACK_HIT_EVENT="+str(hits)+" SOURCE_SECOND="+str(hit_second))

func _on_attack_finished(_serial: int) -> void:
    completed += 1
    print("A40_ATTACK_FINISHED="+str(completed))

func _process(_delta: float) -> void:
    if hud != null:
        hud.text = "FS A40 | RUN %s F%d | ACTOR %s F%d | HIT %d @ %.2fs | DONE %d | ART HOLD" % [str(run_actor.get_profile()),run_actor.get_frame_index(),str(idle_actor.get_profile()),idle_actor.get_frame_index(),hits,last_hit_second,completed]

func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_1: idle_actor.play_motion(&"idle",&"idle_raw")
        KEY_2: idle_actor.play_motion(&"idle",&"idle_calm")
        KEY_3: idle_actor.play_motion(&"idle",&"idle_r2")
        KEY_4: run_actor.play_motion(&"run",&"run_raw")
        KEY_5: run_actor.play_motion(&"run",&"run_tuned")
        KEY_6: idle_actor.play_motion(&"idle",&"idle_rig")
        KEY_7:
            if not paused:
                idle_actor.play_motion(&"attack",&"attack_slash")
        KEY_SPACE:
            paused = not paused
            if paused:
                run_actor.actor_sprite.pause()
                idle_actor.actor_sprite.pause()
                idle_actor.breath_rig.breath_player.pause()
                idle_actor.attack_clock.pause()
            else:
                run_actor.actor_sprite.play()
                if idle_actor.get_profile() == &"idle_rig":
                    idle_actor.breath_rig.breath_player.play()
                else:
                    idle_actor.actor_sprite.play()
                if idle_actor.get_motion() == &"attack":
                    idle_actor.attack_clock.play()
        KEY_EQUAL, KEY_KP_ADD:
            idle_actor.set_playback_multiplier(idle_actor.playback_multiplier+0.1)
            run_actor.set_playback_multiplier(run_actor.playback_multiplier+0.1)
        KEY_MINUS, KEY_KP_SUBTRACT:
            idle_actor.set_playback_multiplier(idle_actor.playback_multiplier-0.1)
            run_actor.set_playback_multiplier(run_actor.playback_multiplier-0.1)