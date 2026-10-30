extends "res://render_stage2.gd"
var examples := [
"ft_roof-high","ft_roof-high-gable","ft_roof-gable","ft_roof-window",
"ft_roof-high-left","ft_roof-high-right","ft_roof-high-window","ft_roof-high-gable-top",
"ft_wall-wood-door","ft_wall-wood-window-shutters","ft_wall-wood-window-small","ft_wall-wood-corner",
"ft_wall-wood-block","ft_overhang","ft_tree-high-round","ft_tree-crooked"]
func _create_world() -> void:
    _box(Vector3(0,-.25,0),Vector3(30,.5,30),Color("#c2c7a3"),TERRAIN_LAYER)
    for i in range(examples.size()):
        var xx: float = float(i%4)*4.4-6.6
        var zz: float = float(i/4)*4.4-6.6
        _box(Vector3(xx,0.00,zz),Vector3(3.9,.05,3.9),Color("#d1c2aa") if (i%2==0) else Color("#bed2af"),TERRAIN_LAYER)
        var n:=_import_model(examples[i],Vector3(xx,.03,zz),2.35,OBJECT_LAYER,0.4)
        print("GALLERY",i,examples[i],n!=null)