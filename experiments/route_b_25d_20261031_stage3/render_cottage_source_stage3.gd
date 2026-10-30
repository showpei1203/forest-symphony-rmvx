extends "res://render_stage2.gd"
## Stage3: single unified high-detail cottage with 3D-native Ground & PAR.
var cottage_model: Node3D

func _create_world() -> void:
    rng.seed=125471
    _box(Vector3(0,-.20,0),Vector3(27,.40,27),Color("#97bd79"),TERRAIN_LAYER)
    # Ground is formed from the same 3D world, never sliced from a flattened master.
    for i in range(19):
        var a:float=float(i)*2.39996
        var r:float=sqrt(float(i)/19.0)*6.6
        var x:float=cos(a)*r
        var z:float=sin(a)*r
        if absf(x)<3.1 and absf(z)<2.9:
            continue
        _sphere(Vector3(x,.008,z),rng.randf_range(.27,.68),Color("#94b879") if i%2 else Color("#9fc386"),TERRAIN_LAYER,Vector3(1.45,.007,1.15))
    # Meandering stone approach leads directly to the cottage door.
    _path([Vector2(-.85,5.5),Vector2(-.28,3.2),Vector2(0,1.8)],1.12,Color("#baa582"))
    cottage_model=(load("res://cottage_prefab.gd") as GDScript).new()
    cottage_model.position=Vector3(0,0,-.35)
    cottage_model.scale_factor=1.0
    vp.add_child(cottage_model)
    cottage_model.build()
    # Source GLB garden elements still have editable original art and shared model transforms.
    for i in range(6):
        var x:float=[-3.15,3.15,-3.43,3.32,-2.85,2.74][i]
        var z:float=[-.05,-.12,1.18,1.0,-1.75,-1.7][i]
        var n:String=["plant-bushdetailed","flower-purpleb","flower-yellowa","plant-bush","flower-purplea","plant-bushdetailed"][i]
        _import_model(n,Vector3(x,0.015,z),0.42 if i%2 else 0.65,TERRAIN_LAYER,0.3*i)
    for i in range(6):
        var x:float=[-4.75,4.68,-4.2,4.41,-5.0,4.92][i]
        var z:float=[-2.2,-1.5,.9,1.55,3.25,3.0][i]
        _import_model("flower-purplea" if i%2 else "grass-large",Vector3(x,0.02,z),0.43,TERRAIN_LAYER,0.41*i)
    # Only one established tree near the house, so silhouette remains legible.
    _tree(-4.35,-2.7,2.05,1)
    _tree(4.35,-2.65,1.85,0)
    # Lighting props and short rails around one coherent building.
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