extends "res://render_scene.gd"
# Stage 2: artist-authored Kenney CC0 GLB geometry; source-first, same camera and masks.
var models_loaded := 0
var models_failed := 0
var source_rng := RandomNumberGenerator.new()

func _import_model(name: String, target_pos: Vector3, size_y: float, layer: int, rotation_y: float = 0.0) -> Node3D:
    var path := "res://assets/%s.glb" % name
    var res: Resource = load(path)
    if not (res is PackedScene):
        models_failed += 1
        push_warning("Model missing: " + path)
        return null
    var instance: Node3D = (res as PackedScene).instantiate() as Node3D
    if instance == null:
        models_failed += 1
        return null
    vp.add_child(instance)
    var min_y := 99999.0
    var max_y := -99999.0
    var has_mesh := false
    for n in instance.find_children("*", "MeshInstance3D", true, false):
        var mesh_node := n as MeshInstance3D
        mesh_node.layers = layer
        if mesh_node.mesh == null:
            continue
        var local := instance.global_transform.affine_inverse() * mesh_node.global_transform
        var aabb := mesh_node.get_aabb()
        for idx in range(8):
            var point: Vector3 = local * aabb.get_endpoint(idx)
            min_y = minf(min_y, point.y)
            max_y = maxf(max_y, point.y)
            has_mesh = true
        for surface in range(mesh_node.mesh.get_surface_count()):
            var orig: Material = mesh_node.get_active_material(surface)
            if orig is BaseMaterial3D:
                var duplicate := orig.duplicate() as BaseMaterial3D
                duplicate.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
                var material_name: String = orig.resource_name.to_lower()
                if name.begins_with("ft_") and "colormap" in material_name:
                    duplicate.albedo_texture = load("res://assets/Textures/colormap.png") as Texture2D
                if "leaf" in material_name or "grass" in material_name:
                    duplicate.albedo_color = Color("#79a85e") if "leaf" in material_name else Color("#83b566")
                elif "bark" in material_name or "wood" in material_name:
                    duplicate.albedo_color = Color("#87674f")
                elif "dirt" in material_name or "rock" in material_name:
                    duplicate.albedo_color = Color("#8b8578")
                elif "purple" in material_name:
                    duplicate.albedo_color = Color("#d8add6")
                elif "yellow" in material_name:
                    duplicate.albedo_color = Color("#f6d38c")
                elif "red" in material_name:
                    duplicate.albedo_color = Color("#dfa1a3")
                mesh_node.set_surface_override_material(surface, duplicate)
    if not has_mesh:
        instance.queue_free()
        models_failed += 1
        return null
    var k: float = size_y / maxf(0.001, max_y - min_y)
    instance.scale = Vector3.ONE * k
    instance.position = target_pos + Vector3(0.0, -min_y * k, 0.0)
    instance.rotation.y = rotation_y
    models_loaded += 1
    return instance

func _tree(x: float, z: float, height: float, variant: int = 0) -> void:
    # Same camera coordinate: terrain receives contact patch; full tree belongs to PAR.
    _sphere(Vector3(x, 0.018, z),height*0.25,Color("#729757"),TERRAIN_LAYER,Vector3(1.25,0.035,1.05))
    var name: String = "tree-oak" if variant == 0 else "tree-detailed"
    _import_model(name,Vector3(x,0,z),height*1.35,OBJECT_LAYER,0.18 if variant==0 else -0.35)

func _clump(x: float,z: float, species: Array, n: int, size: float, seed_value: int) -> void:
    var rd := RandomNumberGenerator.new()
    rd.seed = seed_value
    for j in range(n):
        var a: float = rd.randf()*TAU
        var r: float = sqrt(rd.randf())*size
        var px := x + cos(a)*r
        var pz := z + sin(a)*r
        var selected: String = species[j%species.size()]
        var height: float = rd.randf_range(0.22,0.40)
        var rot: float = rd.randf_range(-PI,PI)
        _import_model(selected, Vector3(px,0.035,pz),height,TERRAIN_LAYER,rot)

func _flora() -> void:
    # Deliberate groups and ecological zones, not uniform random scatter.
    _clump(-8.3,-4.3,["grass-large","grass-leafs","flower-purplea","flower-yellowb"],18,1.8,444)
    _clump(8.1,0.5,["grass-large","flower-purpleb","plant-bushsmall"],14,1.5,221)
    _clump(-0.1,-6.7,["grass-leafs","flower-yellowa","flower-redb"],14,1.1,1022)
    _clump(3.9,5.2,["grass","flower-purplea","flower-yellowa"],22,1.4,239)
    _clump(-8.7,6.1,["grass-large","flower-yellowb","plant-bushsmall"],14,1.3,656)
    _clump(8.2,-6.7,["plant-bushdetailed","grass","flower-purpleb"],12,1.6,645)
    for i in range(12):
        var xx: float = [-9.2,-8.1,-6.5,6.3,7.1,8.8][i%6]
        var zz: float = [-5.3,6.4,4.5,5.7,-7.5,-2.8][i%6] + (0.5 if i>=6 else 0.0)
        _import_model("plant-bush" if i%3 else "plant-bushlarge",Vector3(xx,0.0,zz),0.55 if i%3 else 0.72,TERRAIN_LAYER,i*0.45)
    for i in range(11):
        var xx: float = [-8.1,-7.6,-3.6,4.2,7.3,8.1,-5.5,5.9,8.4,-8.2,2.2][i]
        var zz: float = [5.3,4.4,-6.0,5.7,6.2,2.1,-7.7,-8.0,-4.9,3.5,6.2][i]
        var nm := "rock-smallb" if i % 2 else "rock-smallflata"
        _import_model(nm,Vector3(xx,0.02,zz),0.25,TERRAIN_LAYER,0.3*i)
    for i in range(4):
        var xz := Vector2(-6.9,2.1) if i%2==0 else Vector2(6.8,3.4)
        _import_model("mushroom-redgroup" if i%2==0 else "mushroom-tangroup",Vector3(xz.x+i*0.23,0.01,xz.y),0.28,TERRAIN_LAYER,0.42*i)

func _cottage(x: float, z: float, roof_color: Color) -> void:
    super._cottage(x,z,roof_color)
    # Wooden beams, stone foundation and shaped shutters, source-authored in 3D.
    for edge_x in [-1.36,1.36]:
        _box(Vector3(x+edge_x,1.1,z+1.38),Vector3(.14,2.2,.17),Color("#a77b53"),OBJECT_LAYER)
    for w_x in [-.93,.93]:
        _box(Vector3(x+w_x,1.52,z+1.47),Vector3(.55,.10,.08),Color("#edcb93"),OBJECT_LAYER)
        _box(Vector3(x+w_x,1.24,z+1.48),Vector3(.55,.12,.19),Color("#b58a63"),OBJECT_LAYER)
        _box(Vector3(x+w_x,1.58,z+1.49),Vector3(.075,.58,.06),Color("#e8e3bf"),OBJECT_LAYER)
    for i in range(6):
        var px: float = -1.25 + float(i)*0.50
        for roof_side in [-1,1]:
            var yy: float = 3.18 - absf(px)*0.39
            # Subtle slate course detail, not repetitive 32px tiles.
            for j in range(4):
                _box(Vector3(x+px,yy+0.02,z-1.08+j*0.66), Vector3(0.10,0.06,0.48),Color("#b4c69b") if (i+j)%3==0 else Color("#819f80"),OBJECT_LAYER)
    # Leaves and planters are co-authored objects; no independent PAR adjustment.
    for side in [-1,1]:
        _import_model("plant-bushdetailed", Vector3(x + side*1.65,0.0,z+1.65),0.52,TERRAIN_LAYER)
        _import_model("flower-purpleb" if side==1 else "flower-yellowb",Vector3(x+side*1.54,0,z+1.95),0.34,TERRAIN_LAYER)

func _render_all() -> void:
    # Base capture uses inherited _create_world() and calls overridden builders above.
    await super._render_all()

func _initialize() -> void:
    call_deferred("_render_all")