extends "res://render_stage2.gd"
# Route B Stage3: Kenney Fantasy Town 2.0 + Nature Kit source meshes.
# A shared coordinate system authored once; Ground/PAR native rendered masks.
func _cottage(x: float, z: float, roof_color: Color) -> void:
    # Ground native: house footprint, path landing and original contact planting.
    _box(Vector3(x,0.015,z),Vector3(3.05,0.025,2.72),Color("#86ab66"),TERRAIN_LAYER)
    _box(Vector3(x,0.065,z+1.75),Vector3(0.94,0.05,1.05),Color("#d4b992"),TERRAIN_LAYER)
    # Native wall body from code, detailed wooden trim and imported Kenney parts.
    _box(Vector3(x,1.08,z),Vector3(2.85,2.13,2.55),Color("#eed5b2"),OBJECT_LAYER)
    for side in [-1,1]:
        _box(Vector3(x+side*1.32,1.14,z+1.29),Vector3(.16,2.15,.15),Color("#987353"),OBJECT_LAYER)
        _box(Vector3(x+side*.95,1.47,z+1.355),Vector3(.47,.55,.065),Color("#a8cbbb"),OBJECT_LAYER)
        _box(Vector3(x+side*.95,1.47,z+1.4),Vector3(.055,.58,.08),Color("#f0e4c8"),OBJECT_LAYER)
        _box(Vector3(x+side*.95,1.19,z+1.45),Vector3(.65,.12,.16),Color("#b58663"),OBJECT_LAYER)
        _import_model("ft_wall-wood-window-shutters",Vector3(x+side*.95,1.26,z+1.48),0.58,OBJECT_LAYER,0.0)
    _box(Vector3(x,0.86,z+1.32),Vector3(.72,1.55,.11),Color("#866149"),OBJECT_LAYER)
    _import_model("ft_wall-wood-door",Vector3(x,0.10,z+1.44),1.6,OBJECT_LAYER,0.0)
    # Main roof geometry sourced from Kenney fantasy kit.
    var pick: String = "ft_roof-high-window" if x<0 else "ft_roof-window"
    var roof := _import_model(pick,Vector3(x,2.03,z),1.52,OBJECT_LAYER,0.0)
    if roof != null:
        roof.scale *= Vector3(1.12,1,1.12)
    for side in [-1,1]:
        _import_model("ft_pillar-wood",Vector3(x+side*1.38,0.0,z+1.42),1.95,OBJECT_LAYER)
        _import_model("flower-purpleb" if side==1 else "flower-yellowb",Vector3(x+side*1.72,0.04,z+1.83),0.48,TERRAIN_LAYER)
        _import_model("plant-bushdetailed",Vector3(x+side*1.64,0,z+1.66),0.50,TERRAIN_LAYER)
    _box(Vector3(x,2.09,z+1.33),Vector3(2.82,.13,.17),Color("#95724b"),OBJECT_LAYER)

func _tree(x: float,z: float,height: float,variant: int=0) -> void:
    _sphere(Vector3(x,0.015,z),height*.26,Color("#82a76a"),TERRAIN_LAYER,Vector3(1.25,.035,1))
    _import_model("ft_tree-high-round" if variant==0 else "tree-detailed",Vector3(x,0,z),height*1.40,OBJECT_LAYER,0.25 if variant==0 else -0.5)