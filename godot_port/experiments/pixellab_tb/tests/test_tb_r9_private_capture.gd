# Private R8 real-picture capture of 544x416 battle-looking PRESENTATION FIXTURE.
# The real original FS BattleScape/camera remains pending source authority.
extends SceneTree
const PRESENTER = preload("res://experiments/pixellab_tb/FS_TBMonsterBattlePresentation.gd")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
    var viewport:=SubViewport.new()
    viewport.size=Vector2i(544,416)
    viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var base:=Node2D.new()
    viewport.add_child(base)
    var bg:=ColorRect.new()
    bg.color=Color("202633")
    bg.size=Vector2(544,416)
    base.add_child(bg)
    var ground:=Polygon2D.new()
    ground.polygon=PackedVector2Array([Vector2(0,260),Vector2(544,242),Vector2(544,416),Vector2(0,416)])
    ground.color=Color("333f44")
    base.add_child(ground)
    var edge:=Line2D.new()
    edge.points=PackedVector2Array([Vector2(0,260),Vector2(544,242)])
    edge.default_color=Color("668474")
    edge.width=2.0
    base.add_child(edge)
    var monster:=PRESENTER.new()
    monster.position=Vector2(331,228)
    monster.scale=Vector2.ONE*1.7
    base.add_child(monster)
    await process_frame
    if not monster._is_ready:
        push_error("R9 real private PNG source hash/atlas failed");quit(1);return
    var caption:=Label.new()
    caption.text="FS TB02 R8 (owner approved) / Godot 4.7.2 / Original 544x416"
    caption.position=Vector2(12,11)
    caption.add_theme_font_size_override("font_size",14)
    base.add_child(caption)
    var notice:=Label.new()
    notice.text="Presentation fixture only; actual FS BattleScape source still gated"
    notice.position=Vector2(12,36)
    notice.add_theme_font_size_override("font_size",10)
    base.add_child(notice)
    var result:=Label.new()
    result.position=Vector2(15,368)
    result.text="F5 mouth contact VFX only  |  no duplicate HP / MP / ATB"
    result.add_theme_font_size_override("font_size",11)
    base.add_child(result)
    monster._idle.visible=false
    monster._attack.visible=true
    monster._attack.sprite.set_frame_and_progress(5,0.0)
    for i in range(6): await process_frame
    await RenderingServer.frame_post_draw
    var result_image:=viewport.get_texture().get_image()
    if result_image==null or result_image.get_size()!=Vector2i(544,416):
        push_error("Private capture dimensions failed");quit(1);return
    var save_path:="res://out/TB_R9_GODOT_472_PRIVATE_BITE_F5_544x416.png"
    if result_image.save_png(save_path)!=OK:
        push_error("Private render save failed");quit(1);return
    print("TB_R9_472_NATIVE_PRIVATE_544x416_CAPTURE_PASS "+save_path)
    quit(0)
