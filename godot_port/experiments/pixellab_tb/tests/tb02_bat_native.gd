extends SceneTree
func _initialize()->void:call_deferred("test")
func test()->void:
    var dat=JSON.parse_string(FileAccess.get_file_as_string("res://TB02_LEAF_BAT_MANIFEST.json")) as Dictionary
    assert(dat["stages"].size()==3 and dat["idle"]["frames"]==8 and dat["attack"]["frames"]==11)
    var scene=load("res://tb02_bat_showcase.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    assert(scene.stage_nodes.size()==3 and scene.idle!=null and scene.attack!=null)
    assert(scene.idle.sprite_frames.get_frame_count("idle")==8)
    assert(scene.attack.cell_size==Vector2i(128,128))
    assert(scene.attack.sprite.sprite_frames.get_frame_count("attack")==11)
    assert(scene.attack.sprite.sprite_frames.get_frame_texture("attack",5).get_size()==Vector2(128,128))
    var hits=[]
    scene.attack.hit_requested.connect(func(i:int,_p:Vector2):hits.append(i))
    scene.attack.play_attack()
    scene.attack.advance_seconds(0.6)
    assert(hits.size()==1 and hits[0]==5)
    assert(not scene.attack.active)
    print("TB_SECOND_BAT_NATIVE_472_PASS 3STAGE 8IDLE 11ATTACK HIT_EXACT_ONCE")
    quit(0)
