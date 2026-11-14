extends SceneTree

# Tests arbitrary 1/3/6/8/12 frame counts and 30/32 px legacy Kaduki cells.
# ImageTexture is memory-only: CI does NOT create licensed assets on the user PC.
const PROFILES = preload("res://scripts/animation/FSAnimationProfile.gd")
const PLAYER = preload("res://scripts/animation/FSAnimationSprite.gd")
const LEGACY = preload("res://scripts/FSActionSprite.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> bool:
    if not ok:
        push_error("FS variable-frame animation FAIL: " + label)
        quit(1)
        return false
    return true

func _tex(cols: int,rows: int,cell: int) -> Texture2D:
    var image: Image = Image.create_empty(cols*cell,rows*cell,false,Image.FORMAT_RGBA8)
    image.fill(Color(0.6,0.3,0.7,1))
    return ImageTexture.create_from_image(image)

func _frames(texture: Texture2D, count: int,ms: int = 50,clip_name: String = "") -> Array:
    var frames: Array = []
    for i in range(count):
        frames.append({"texture":texture,"duration_ms":ms,
            "grid":{"columns":count,"rows":1,"column":i,"row":0},
            "marker":"impact" if clip_name == "attack" and i == 3 else ""})
    return frames

func _run() -> void:
    var kaduki: Dictionary = PROFILES.legacy_kaduki("$actor01","res://assets/characters/",140)
    var clips: Dictionary = kaduki["clips"]
    if not _check(clips.size()==16,"16 source action rows"): return
    if not _check(clips["legacy_00"]["frames"].size()==3,"legacy 3 frame compatibility"): return
    if not _check(clips["legacy_15"]["frames"][2]["grid"]["row"]==3 and
            clips["legacy_15"]["frames"][2]["texture"].ends_with("$actor01_3.png"),
            "sheet 4 last row mapped source-exact"): return
    if not _check(PROFILES.validate(kaduki).is_empty(),"legacy candidate manifest valid"): return

    var player = PLAYER.new()
    root.add_child(player)
    var started: Array = []
    var entered: Array = []
    var finished: Array = []
    var markers: Array = []
    var failures: Array = []
    player.clip_started.connect(func(n: String) -> void: started.append(n))
    player.frame_entered.connect(func(n: String,i: int) -> void: entered.append([n,i]))
    player.clip_finished.connect(func(n: String) -> void: finished.append(n))
    player.marker_reached.connect(func(n: String,i: int,m: String) -> void: markers.append([n,i,m]))
    player.playback_failed.connect(func(reason: String) -> void: failures.append(reason))

    var animation_clips: Dictionary = {}
    for count in [1,3,6,8,12]:
        var name: String = "motion_%02d" % count
        animation_clips[name] = {"loop":true,"frames":_frames(_tex(count,1,8),count,50)}
    animation_clips["attack"] = {"loop":false,"frames":_frames(_tex(6,1,12),6,80,"attack")}
    animation_clips["tiny_legacy"] = {"loop":true,"frames":[
        {"texture":_tex(3,4,30),"duration_ms":140,
         "grid":{"columns":3,"rows":4,"column":1,"row":3}}]}
    animation_clips["big_cell"] = {"loop":true,"frames":[
        {"texture":_tex(3,4,32),"duration_ms":140,
         "grid":{"columns":3,"rows":4,"column":1,"row":3}}]}
    var profile: Dictionary = {"schema":"fs-animation-v1","clips":animation_clips}
    if not _check(PROFILES.validate(profile).is_empty(),"flexible manifest valid"): return
    if not _check(player.set_profile(profile),"runtime accepts manifest"): return

    for count in [1,3,6,8,12]:
        var name: String = "motion_%02d" % count
        if not _check(player.play_clip(name),"play clip "+name): return
        if not _check(player.current_frame_count()==count,"correct frame count "+name): return
        player.advance_ms(50.0*float(count))
        if not _check(player.playing and player.frame_index==0,"loops correctly "+name): return

    if not _check(player.play_clip("tiny_legacy"),"30px source sheet plays"): return
    if not _check(player.sprite.region_rect.size == Vector2(30,30),"30px source cell dimension preserved"): return
    if not _check(player.play_clip("big_cell"),"32px source sheet plays"): return
    if not _check(player.sprite.region_rect.size == Vector2(32,32),"32px source cell dimension preserved"): return

    if not _check(player.play_clip("attack"),"six-frame attack plays"): return
    player.advance_ms(6.0*80.0)
    if not _check(not player.playing and player.frame_index==5,"one-shot holds last frame"): return
    if not _check(finished==["attack"],"finished exactly once"): return
    if not _check(markers.size()==1 and markers[0]==["attack",3,"impact"],
            "impact marker emits once, not coupled to battle damage"): return

    var bad: Dictionary = {"schema":"fs-animation-v1","clips":{"walk":{
        "loop":true,"frames":[{"texture":_tex(2,1,8),"duration_ms":0}]}}}
    if not _check(not PROFILES.validate(bad).is_empty(),"reject zero time"): return
    var adapter = LEGACY.new()
    root.add_child(adapter)
    if not _check(adapter.load_actor("$actor01"),"legacy manifest initializes without copying PNG"): return
    if not _check(adapter.available_clips().size()==16,"old FSActionSprite interface persists"): return
    if not _check(not adapter.play_action(20),"reject invalid legacy action index"): return
    if not _check(adapter.load_flexible_profile(profile) and adapter.play_named_action("motion_08"),
            "legacy wrapper also plays new eight-frame clip"): return
    if not _check(started.size()>=8 and failures.is_empty(),
            "native renderer had no unexpected failures"): return
    print("FS animation variable 1/3/6/8/12 frames + 30/32px legacy + markers native PASS")
    quit(0)
