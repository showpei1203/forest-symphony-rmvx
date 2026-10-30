extends Node3D
## Reusable Forest Symphony 2.5D Cottage Prefab (procedural editable mesh source).
## The same child world coordinates own Ground layer 1 and PAR layer 2.
const GROUND := 1
const PAR := 2
@export var roof_base: Color = Color("#638c70")
@export var wall_color: Color = Color("#e8d4ae")
@export var wood_color: Color = Color("#8f6a4b")
@export var scale_factor: float = 1.0

func _mat(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    return m

func _add(mesh: Mesh, pos: Vector3, color: Color, layer: int, rotation: Vector3=Vector3.ZERO) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.mesh=mesh
    n.position=pos
    n.rotation=rotation
    n.material_override=_mat(color)
    n.layers=layer
    add_child(n)
    return n

func _box(pos: Vector3, size: Vector3, color: Color, layer: int=PAR, angle: Vector3=Vector3.ZERO) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    _add(mesh,pos,color,layer,angle)

func _sphere(pos: Vector3, radius: float,color: Color,layer: int=PAR,scl: Vector3=Vector3.ONE) -> void:
    var m:=SphereMesh.new()
    m.radius=radius
    m.height=radius*2.0
    m.radial_segments=8
    m.rings=4
    _add(m,pos,color,layer).scale=scl

func _cylinder(pos: Vector3, top_r:float, bot_r:float,h:float,color:Color, layer: int=PAR) -> void:
    var m:=CylinderMesh.new()
    m.top_radius=top_r
    m.bottom_radius=bot_r
    m.height=h
    m.radial_segments=10
    _add(m,pos,color,layer)

func _poly(verts: Array[Vector3],color:Color,layer:int=PAR) -> void:
    var am:=ArrayMesh.new()
    var arrays=[]
    arrays.resize(Mesh.ARRAY_MAX)
    var pts:=PackedVector3Array()
    # triangle fan works for triangle, quad, pentagon
    for i in range(1,verts.size()-1):
        pts.append(verts[0])
        pts.append(verts[i])
        pts.append(verts[i+1])
    arrays[Mesh.ARRAY_VERTEX]=pts
    am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
    _add(am,Vector3.ZERO,color,layer)

func _roof_y(x:float)->float:
    return 4.05-absf(x)*0.695

func _roof() -> void:
    var root_a:Color=roof_base
    var roof_dark:=Color("#456a58")
    var roof_light:=Color("#82a588")
    # All roof surface is native PAR. Ridge follows the Z direction.
    _poly([Vector3(-2.11,2.585,-1.95),Vector3(0.0,4.06,-1.95),Vector3(0.0,4.06,1.94),Vector3(-2.11,2.585,1.94)],root_a)
    _poly([Vector3(0.0,4.06,-1.95),Vector3(2.11,2.585,-1.95),Vector3(2.11,2.585,1.94),Vector3(0.0,4.06,1.94)],roof_dark)
    # Each roof tile is a 3D quad authored on the slope: no post-cropped PAR.
    for side in [-1,1]:
        for row in range(6):
            var r0:float=float(row)/6.0
            var r1:float=float(row+1)/6.0
            var dx0:float=0.08+r0*1.92
            var dx1:float=0.08+r1*1.92
            for col in range(10):
                var z0:float=-1.84+float(col)*0.369
                var z1:float=z0+0.348
                var stagger:float=0.035 if row%2==0 else 0.0
                z0+=stagger
                z1+=stagger
                var xa:float=side*dx0
                var xb:float=side*dx1
                var ya:=_roof_y(xa)+0.025
                var yb:=_roof_y(xb)+0.025
                var colr:Color=roof_base.lightened(0.17) if (row+col)%7==0 else roof_base.darkened(0.08 if (row*3+col)%5==0 else 0.0)
                _poly([Vector3(xa,ya,z0),Vector3(xb,yb,z0),Vector3(xb,yb,z1),Vector3(xa,ya,z1)],colr)
    _box(Vector3(0,4.078,0),Vector3(0.13,0.115,4.05),Color("#a7b495"))
    for side in [-1,1]:
        _box(Vector3(side*2.07,2.60,0),Vector3(0.13,0.11,4.1),Color("#587764"))
        # Front gable trim diagonals: beam angles match roof incline.
        _box(Vector3(side*1.07,3.34,1.97),Vector3(2.52,0.13,0.15),wood_color,PAR,Vector3(0,0,-side*0.61))

func _windows_and_door() -> void:
    # Front entrance faces +Z.
    _box(Vector3(0,1.00,1.59),Vector3(1.00,1.92,0.11),Color("#674b3c"))
    _box(Vector3(0,1.03,1.667),Vector3(0.81,1.79,0.075),Color("#90674a"))
    for i in [-1,0,1]:
        _box(Vector3(i*0.24,1.20,1.714),Vector3(0.055,1.36,0.025),Color("#ae8057"))
    _sphere(Vector3(0.29,1.07,1.76),0.067,Color("#f8d89a"),PAR,Vector3(1,1,0.5))
    # Two windows with proper timber sills and flower boxes.
    for side in [-1,1]:
        var xx:float=side*1.21
        _box(Vector3(xx,1.72,1.615),Vector3(.64,.73,.095),Color("#7d6550"))
        _box(Vector3(xx,1.72,1.682),Vector3(.52,.61,.07),Color("#9ec3b7"))
        _box(Vector3(xx,1.72,1.739),Vector3(.06,.64,.08),Color("#fff0cf"))
        _box(Vector3(xx,1.72,1.738),Vector3(.55,.05,.08),Color("#fff0cf"))
        _box(Vector3(xx,1.35,1.77),Vector3(.85,.14,.32),wood_color.darkened(0.15))
        for k in range(5):
            var dx:float=(float(k)-2.)*.13
            var yy:float=1.48+0.045*float(k%2)
            _sphere(Vector3(xx+dx,yy,1.90),0.075,Color("#d6a2be") if k%2==0 else Color("#f4df87"),PAR,Vector3(1,0.7,1))
        # Front posts and beam above
        _box(Vector3(side*1.79,1.36,1.64),Vector3(.18,2.68,.20),wood_color)
        _box(Vector3(side*1.51,2.51,1.65),Vector3(.11,0.46,.22),Color("#b8926c"),PAR,Vector3(0,0,side*0.52))
    _box(Vector3(0,2.67,1.65),Vector3(3.60,.16,.19),wood_color)

func _flower_planters() -> void:
    # Attached to shared prefab, Ground-owned foot contact and PAR-owned elevated boxes.
    var seed:=RandomNumberGenerator.new()
    seed.seed=773
    for side in [-1,1]:
        var cx:float=side*2.20
        _sphere(Vector3(cx,0.04,1.73),0.43,Color("#69834c"),GROUND,Vector3(1.3,0.05,0.8))
        _box(Vector3(cx,0.27,1.78),Vector3(.45,.46,.45),Color("#a48061"))
        for k in range(6):
            var ox:float=seed.randf_range(-.25,.25)
            var oz:float=seed.randf_range(-.23,.23)
            _sphere(Vector3(cx+ox,.62,1.8+oz),.14,Color("#799b61"))
            _sphere(Vector3(cx+ox,.73,1.8+oz),.078,Color("#d79db9") if k%2 else Color("#efcd81"))

func _front_porch() -> void:
    # Pebble landing belongs to Ground, actual raised structures PAR.
    _box(Vector3(0,0.06,2.10),Vector3(2.65,0.06,1.12),Color("#bca68a"),GROUND)
    for i in range(9):
        var x:float=float(i%3-1)*0.78
        var z:float=1.83+float(i/3)*0.37
        _box(Vector3(x,0.105,z),Vector3(.52,.045,.29),Color("#ddc5a0") if i%2==0 else Color("#c9b28f"),GROUND,Vector3(0,0.08*float(i%3-1),0))
    _box(Vector3(0,0.18,1.83),Vector3(1.16,0.13,.69),Color("#bb9d7d"),PAR)

func build() -> void:
    # Explicitly keep local origin = ground contact; all source pieces are editable in 3D.
    scale=Vector3.ONE*scale_factor
    # Ground native footprint, shadow hints, material painting around house
    # No rectangular Ground silhouette. Contact color stays within 3D wall footprint.
    for dx in [-1.67, 1.67]:
        for dz in [-1.45,1.45]:
            _sphere(Vector3(dx,0.009,dz),0.31,Color("#82a46c"),GROUND,Vector3(1.4,.025,1.10))
    _box(Vector3(0,0.058,0),Vector3(3.85,.11,3.30),Color("#a09275"),PAR)
    _box(Vector3(0,1.44,0),Vector3(3.48,2.76,3.00),wall_color)
    for side in [-1,1]:
        for z in [-1.47,1.47]:
            _box(Vector3(side*1.71,1.35,z),Vector3(.18,2.75,.22),wood_color)
    for y in [0.32,2.57]:
        _box(Vector3(0,y,1.54),Vector3(3.52,.13,.16),wood_color)
    # Triangular front and back gables are native geometry, not incomplete roof modules.
    _poly([Vector3(-1.78,2.62,1.55),Vector3(1.78,2.62,1.55),Vector3(0,3.97,1.55)],wall_color.darkened(0.07))
    _poly([Vector3(-1.78,2.62,-1.55),Vector3(0,3.97,-1.55),Vector3(1.78,2.62,-1.55)],wall_color.darkened(0.07))
    _roof()
    _windows_and_door()
    _front_porch()
    _flower_planters()
    # Chimney is deliberately coherent with the sloping roof, no detached tower.
    _box(Vector3(1.10,3.55,-0.75),Vector3(.52,1.70,.52),Color("#a28e82"))
    _box(Vector3(1.10,4.41,-.75),Vector3(.71,.17,.71),Color("#89756a"))
    _box(Vector3(1.10,4.54,-.75),Vector3(.51,.11,.51),Color("#5e5550"))