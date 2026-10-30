extends SceneTree
# FS Route B, source-first 2.5D geometry, single camera, native Ground/PAR masks.
# Independent 3D objects, no completed-image reverse segmentation.
const W := 544
const H := 416
const TERRAIN_LAYER := 1
const OBJECT_LAYER := 2
var vp: SubViewport
var camera: Camera3D
var rng := RandomNumberGenerator.new()

func _initialize() -> void:
    call_deferred("_render_all")

func _material(c: Color, rough: float = 1.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = c
    m.roughness = rough
    m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    return m

func _mesh(mesh: Mesh, pos: Vector3, color: Color, layer: int, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.rotation = rot
    node.material_override = _material(color)
    node.layers = layer
    vp.add_child(node)
    return node

func _box(pos: Vector3, sz: Vector3, color: Color, layer: int, rot: Vector3 = Vector3.ZERO) -> void:
    var m := BoxMesh.new()
    m.size = sz
    _mesh(m, pos, color, layer, rot)

func _sphere(pos: Vector3, radius: float, color: Color, layer: int, scale: Vector3 = Vector3.ONE) -> void:
    var m := SphereMesh.new()
    m.radius = radius
    m.height = radius * 2.0
    m.radial_segments = 7
    m.rings = 4
    var node := _mesh(m, pos, color, layer)
    node.scale = scale

func _cylinder(pos: Vector3, top: float, bottom: float, height: float, color: Color, layer: int) -> void:
    var m := CylinderMesh.new()
    m.top_radius = top
    m.bottom_radius = bottom
    m.height = height
    m.radial_segments = 7
    _mesh(m, pos, color, layer)

func _path(points: Array, width: float, color: Color) -> void:
    for i in range(points.size() - 1):
        var a: Vector2 = points[i]
        var b: Vector2 = points[i + 1]
        var mid: Vector2 = (a + b) * 0.5
        var diff: Vector2 = b - a
        var angle: float = atan2(diff.x, diff.y)
        _box(Vector3(mid.x, 0.03, mid.y), Vector3(width, 0.045, diff.length()+0.18), color, TERRAIN_LAYER, Vector3(0.0, angle, 0.0))
        # Wide path made of slight color variations and individually placed stepping stones.
        for j in range(maxi(1, int(diff.length() * 2.5))):
            var t: float = float(j + 0.5) / float(maxi(1, int(diff.length() * 2.5)))
            var p: Vector2 = a.lerp(b, t)
            var lateral: Vector2 = Vector2(diff.y, -diff.x).normalized()
            var off: float = rng.randf_range(-width * 0.34, width * 0.34)
            var stone_sz := Vector3(rng.randf_range(0.24,0.43),0.045,rng.randf_range(0.20,0.35))
            var stone_col := Color("#cfb999") if j % 3 != 0 else Color("#dec7a5")
            _box(Vector3(p.x+lateral.x*off, 0.079, p.y+lateral.y*off), stone_sz, stone_col, TERRAIN_LAYER, Vector3(0, rng.randf_range(-0.4,0.4), 0))

func _tree(x: float, z: float, height: float, variant: int = 0) -> void:
    _sphere(Vector3(x,0.042,z), height*0.35, Color("#557b47"), TERRAIN_LAYER, Vector3(1.35,0.06,0.9))
    _cylinder(Vector3(x,height*0.36,z), 0.18*height, 0.27*height, height*0.72, Color("#806047"), OBJECT_LAYER)
    _sphere(Vector3(x,height*0.95,z),height*0.63, Color("#6baf61") if variant==0 else Color("#8fc670"), OBJECT_LAYER, Vector3(1.10,0.72,1.0))
    _sphere(Vector3(x-height*0.35,height*0.88,z+height*0.13),height*0.45,Color("#8ac875"), OBJECT_LAYER,Vector3(1.0,0.76,1.0))
    _sphere(Vector3(x+height*0.38,height*0.91,z-height*0.12),height*0.42,Color("#a4d18a"), OBJECT_LAYER,Vector3(1.0,0.75,1.0))
    _sphere(Vector3(x,height*1.25,z),height*0.42,Color("#aad987"),OBJECT_LAYER,Vector3(0.9,0.72,0.9))
    for k in range(5):
        var a: float = float(k) / 5.0 * TAU
        _sphere(Vector3(x+cos(a)*height*0.57, height*0.93,z+sin(a)*height*0.56),0.08, Color("#f6b8ce"),OBJECT_LAYER)

func _cottage(x: float, z: float, roof_color: Color) -> void:
    # Footprints and shadow are owned by Ground and share coordinates with walls.
    _box(Vector3(x,0.05,z+0.12), Vector3(3.35,0.045,3.2),Color("#6c8b58"),TERRAIN_LAYER)
    _box(Vector3(x,0.085,z+1.65), Vector3(1.2,0.04,1.55),Color("#d6c69f"),TERRAIN_LAYER)
    _box(Vector3(x,1.18,z),Vector3(2.83,2.25,2.6), Color("#f2ddba"),OBJECT_LAYER)
    _box(Vector3(x,2.28,z+0.0),Vector3(2.95,0.20,2.68),Color("#b8966f"),OBJECT_LAYER)
    _box(Vector3(x-0.73,2.85,z),Vector3(1.81,0.17,3.05),roof_color,OBJECT_LAYER,Vector3(0,0,0.43))
    _box(Vector3(x+0.73,2.85,z),Vector3(1.81,0.17,3.05),roof_color,OBJECT_LAYER,Vector3(0,0,-0.43))
    _box(Vector3(x,3.23,z),Vector3(0.13,0.13,3.10),Color("#6b8360"),OBJECT_LAYER)
    # Door faces front (positive z) and is distinctly readable.
    _box(Vector3(x,0.86,z+1.335),Vector3(0.73,1.55,0.095),Color("#805b43"),OBJECT_LAYER)
    _sphere(Vector3(x+0.23,0.85,z+1.405),0.055,Color("#f6dc83"),OBJECT_LAYER)
    for sx in [-0.93,0.93]:
        _box(Vector3(x+sx,1.52,z+1.35),Vector3(0.47,0.54,0.10),Color("#78bdb6"),OBJECT_LAYER)
        _box(Vector3(x+sx,1.52,z+1.42),Vector3(0.06,0.58,0.11),Color("#e8e1bc"),OBJECT_LAYER)
    _cylinder(Vector3(x+1.0,3.0,z-0.5),0.21,0.24,0.8,Color("#d7ad84"),OBJECT_LAYER)
    for i in range(9):
        var ox: float = rng.randf_range(-2.2,2.2)
        var oz: float = rng.randf_range(1.75,2.4)
        _sphere(Vector3(x+ox,0.17,z+oz),rng.randf_range(.10,.19),Color("#d3a5c9") if i%2==0 else Color("#f0c56c"),TERRAIN_LAYER,Vector3(1,0.6,1))

func _fence(start: Vector2, end: Vector2, count: int) -> void:
    var d: Vector2 = (end-start).normalized()
    var length: float = start.distance_to(end)
    for i in range(count+1):
        var pt: Vector2 = start.lerp(end,float(i)/float(count))
        _box(Vector3(pt.x,0.44,pt.y),Vector3(0.13,0.85,0.13),Color("#a0805e"),OBJECT_LAYER)
        _sphere(Vector3(pt.x,0.9,pt.y),0.11,Color("#c1a27a"),OBJECT_LAYER)
    var mid: Vector2 = (start+end)/2
    _box(Vector3(mid.x,.62,mid.y),Vector3(length,.11,.10),Color("#b39371"),OBJECT_LAYER,Vector3(0,-atan2(d.y,d.x),0))
    _box(Vector3(mid.x,.31,mid.y),Vector3(length,.11,.10),Color("#b39371"),OBJECT_LAYER,Vector3(0,-atan2(d.y,d.x),0))

func _lantern(x: float,z: float) -> void:
    _sphere(Vector3(x,0.08,z),0.31,Color("#567747"),TERRAIN_LAYER,Vector3(1,0.14,1))
    _cylinder(Vector3(x,0.9,z),0.085,0.12,1.8,Color("#735a48"),OBJECT_LAYER)
    _sphere(Vector3(x,1.94,z),0.22,Color("#ffdd8e"),OBJECT_LAYER,Vector3(.85,1.2,.85))
    _cylinder(Vector3(x,2.18,z),0.20,0.25,0.20,Color("#547b63"),OBJECT_LAYER)

func _flora() -> void:
    for i in range(420):
        var x: float = rng.randf_range(-10.0,10.0)
        var z: float = rng.randf_range(-9.0,9.0)
        # No random dots across the walking trail / central doors.
        if absf(x) < 0.9 and z > -4 and z < 5:
            continue
        var sz: float = rng.randf_range(0.035,0.09)
        _sphere(Vector3(x,.045,z),sz,Color("#79af62") if i%3==0 else Color("#b0d17d"), TERRAIN_LAYER,Vector3(1,0.30,1.5))
    for i in range(90):
        var x: float = rng.randf_range(-9.0,9.0)
        var z: float = rng.randf_range(-8.0,8.0)
        if absf(x)<1.4 and z>-4 and z<4:
            continue
        _sphere(Vector3(x,0.08,z),0.075,Color("#f8d4b1") if i%2==0 else Color("#e7a1bb"),TERRAIN_LAYER,Vector3(0.8,0.22,0.8))
    for i in range(38):
        var x: float = rng.randf_range(-9.0,9.0)
        var z: float = rng.randf_range(-8.0,8.0)
        _sphere(Vector3(x,0.10,z),rng.randf_range(.08,.18),Color("#988c79"),TERRAIN_LAYER,Vector3(1,0.32,0.8))

func _create_world() -> void:
    rng.seed = 13072026
    _box(Vector3(0,-0.15,0),Vector3(45,0.3,45),Color("#95c66f"),TERRAIN_LAYER)
    # Co-authored ground: path, habitat patches, roots, cottages' footprint.
    for i in range(25):
        var x: float = rng.randf_range(-10,10)
        var z: float = rng.randf_range(-9,9)
        _sphere(Vector3(x,-0.001,z),rng.randf_range(.7,1.55),Color("#8cbf69") if i%2==0 else Color("#a5d07e"),TERRAIN_LAYER,Vector3(1,0.01,0.8))
    _path([Vector2(-2.2,8),Vector2(-1.55,3.5),Vector2(-1.0,0),Vector2(0.75,-2.1),Vector2(5.9,-7)],2.1,Color("#c5ad8b"))
    _path([Vector2(-7.0,-1.7),Vector2(-3.6,-1.25),Vector2(-1.0,0.0)],1.65,Color("#c1ac8a"))
    _flora()
    _cottage(-5.2,-2.3,Color("#649f87"))
    _cottage(4.95,-3.65,Color("#628d72"))
    _tree(2.6,1.05,2.8,0)
    _tree(-6.4,3.3,2.15,1)
    _tree(6.5,4.0,2.25,1)
    _tree(-1.0,-6.9,1.65,0)
    _fence(Vector2(-7.35,0.3),Vector2(-4.5,0.3),5)
    _fence(Vector2(4.0,-0.45),Vector2(7.0,-0.45),5)
    _lantern(-2.4,-0.55)
    _lantern(2.65,-2.8)
    _box(Vector3(-3.6,0.85,2.6),Vector3(.15,1.6,.15),Color("#78583e"),OBJECT_LAYER)
    _box(Vector3(-3.6,1.45,2.6),Vector3(1.2,.38,.15),Color("#b9976f"),OBJECT_LAYER)

func _capture(name: String, mask: int, transparent: bool) -> Image:
    camera.cull_mask = mask
    vp.transparent_bg = transparent
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    for i in range(4):
        await RenderingServer.frame_post_draw
    var img: Image = vp.get_texture().get_image()
    if name != "PAR":
        img.convert(Image.FORMAT_RGB8)
    var path: String = "res://out/" + name + ".png"
    var err: Error = img.save_png(path)
    print("CAPTURE ",name," ",img.get_width(),"x",img.get_height()," ",err," alpha0=",img.get_pixel(0,0).a)
    return img

func _render_all() -> void:
    vp = SubViewport.new()
    vp.size = Vector2i(W,H)
    vp.own_world_3d = true
    vp.transparent_bg = false
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_CLEAR_COLOR
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color("#fff5e8")
    e.ambient_light_energy = 0.65
    env.environment = e
    vp.add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-65,-34,0)
    sun.light_energy = 1.15
    sun.shadow_enabled = false
    vp.add_child(sun)
    camera = Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 14.2
    camera.position = Vector3(0,22,17)
    camera.current = true
    vp.add_child(camera)
    camera.look_at(Vector3(0,0.5,0),Vector3.UP)
    _create_world()
    await process_frame
    await _capture("GROUND",TERRAIN_LAYER,false)
    await _capture("PAR",OBJECT_LAYER,true)
    await _capture("SCENE_FULL",TERRAIN_LAYER|OBJECT_LAYER,false)
    print("FS_ROUTE_B_RENDER_FINISHED")
    quit(0)