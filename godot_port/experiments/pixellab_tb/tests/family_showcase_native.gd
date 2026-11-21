extends SceneTree
func _initialize()->void:call_deferred("verify")
func verify()->void:
    var scene=load("res://family_showcase.tscn")
    assert(scene!=null,"Missing family showcase")
    var node=scene.instantiate()
    root.add_child(node)
    await process_frame
    for t in ["res://assets/monsters/tb/PMD0001_STATIC_64.png","res://assets/monsters/tb/PMD0002_STATIC_64.png","res://assets/monsters/tb/PMD0003_STATIC_64.png","res://assets/monsters/tb/PMD0001_IDLE_3F_192x64.png","res://assets/monsters/tb/PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png"]:
        var tex=load(t) as Texture2D
        assert(tex!=null,"missing "+t)
    assert(node.attack!=null and node.idle!=null)
    var timeline=node.attack
    var hits=[]
    timeline.hit_requested.connect(func(f:int,_p:Vector2):hits.append(f))
    timeline.play_attack()
    timeline.advance_seconds(0.6)
    assert(hits.size()==1 and hits[0]==5,"Hit should occur exactly once")
    assert(timeline.frame_index==10 and not timeline.active)
    print("TB_FIRST_FAMILY_NATIVE_472_PASS 3 STAGES + IDLE 3F + V6 ATTACK 11F + HIT EXACT ONCE")
    quit(0)
