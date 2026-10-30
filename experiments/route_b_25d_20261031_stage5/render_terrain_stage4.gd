extends "res://render_stage2.gd"
# Stage4: one authored terrain material + native editable 3D cottage.
# Ground terrain is a first-class source layer; PAR never cut from master.
var cottage_model: Node3D
func _create_world() -> void:
    rng.seed = 125471
    var plane := PlaneMesh.new()
    plane.size=Vector2(18,18)
    plane.subdivide_width=1
    plane.subdivide_depth=1
    var ground:=MeshInstance3D.new()
    ground.mesh=plane
    ground.position=Vector3(0,-0.09,0)
    ground.layers=TERRAIN_LAYER
    var terrain_mat:=StandardMaterial3D.new()
    terrain_mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
    terrain_mat.albedo_texture=load("res://assets/terrain_stage5.png") as Texture2D
    terrain_mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
    ground.material_override=terrain_mat
    vp.add_child(ground)
    # House is loaded from native 214-node editable prefab, not rebuilt from an image.
    cottage_model=(load("res://FS_Elf_Cottage.tscn") as PackedScene).instantiate() as Node3D
    cottage_model.position=Vector3(0,0,-.35)
    vp.add_child(cottage_model)
    # Native flora and 3D trees; their contacts remain editable source objects.
    for i in range(8):
        var x:float=[-3.15,3.15,-3.43,3.32,-2.85,2.74,4.28,-4.08][i]
        var z:float=[-.05,-.12,1.18,1.0,-1.75,-1.7,3.6,3.35][i]
        var n:String=["plant-bushdetailed","flower-purpleb","flower-yellowa","plant-bush","flower-purplea","plant-bushdetailed","grass-large","grass-large"][i]
        _import_model(n,Vector3(x,0.015,z),0.42 if i%2 else 0.65,TERRAIN_LAYER,0.3*i)
    _tree(-4.35,-2.98,2.05,1)
    _tree(4.51,-3.12,1.62,0)
    _lantern(-2.75,2.12)
    _lantern(2.74,2.12)
    for side in [-1,1]:
        _box(Vector3(side*3.5,0.39,1.50),Vector3(.14,.72,.14),Color("#96775a"),OBJECT_LAYER)
        _box(Vector3(side*4.10,0.39,1.50),Vector3(.14,.72,.14),Color("#96775a"),OBJECT_LAYER)
        _box(Vector3(side*3.8,0.58,1.5),Vector3(1.10,.12,.11),Color("#bb9871"),OBJECT_LAYER)
        _box(Vector3(side*3.8,0.31,1.5),Vector3(1.10,.11,.11),Color("#bb9871"),OBJECT_LAYER)

func _render_all() -> void:
    await super._render_all()
func _initialize() -> void:
    call_deferred("_render_all")