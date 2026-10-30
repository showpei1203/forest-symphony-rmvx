extends "res://render_stage9_crown.gd"
## Stage10 native geometry A/B. Leaves and branch clusters are newly authored 3D meshes.
## Ground tree-foot GLB and transparent PAR geometry are NOT post-processed.
var geom_leaf_tris:int=0
var geom_clusters:int=0

func _mat(color:Color) -> StandardMaterial3D:
    var m:=StandardMaterial3D.new()
    m.albedo_color=color
    m.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
    m.cull_mode=BaseMaterial3D.CULL_DISABLED
    m.vertex_color_use_as_albedo=true
    return m

func _petal(pts:PackedVector3Array,colors:PackedColorArray,anchor:Vector3,rotation:float,radius:float,shade:Color,variant:int)->void:
    # A pointed leaf silhouette made of 4 triangles, varying tip and secondary tooth.
    var dir:=Vector3(cos(rotation),0.0,sin(rotation))
    var perp:=Vector3(-dir.z,0,dir.x)
    var tip:=anchor+dir*radius*1.28+Vector3(0.0,0.025,0)
    var base:=anchor-dir*radius*.30
    var left:=anchor+perp*radius*.48+dir*radius*.25
    var right:=anchor-perp*radius*.48+dir*radius*.25
    var middle:=anchor+dir*radius*.34+Vector3(0.0,.055,0.0)
    var c0:=shade.darkened(.11)
    var c1:=shade.lightened(.07)
    for tri in [[base,left,middle],[left,tip,middle],[tip,right,middle],[right,base,middle]]:
        for v in tri:
            pts.append(v)
            colors.append(c1 if v==tip or v==left else c0)
        geom_leaf_tris+=1

func _create_spread(x:float,z:float,height:float,variant:int,style:String)->void:
    var rnd:=RandomNumberGenerator.new()
    rnd.seed=18031+variant*13071
    var origin:=Node3D.new()
    origin.name="STAGE10_AUTHORED_CANOPY_"+style
    origin.position=Vector3(x,0,z)
    if variant==0:
        origin.scale=Vector3(.86,1,.86)
    vp.add_child(origin)
    var palette=[
        Color("#567b46"),Color("#668b4a"),Color("#81a65a"),
        Color("#78934f"),Color("#9cb570"),Color("#435f3b")
    ]
    if style=="lobes":
        # A deliberate negative control: coarse connected ellipsoid leaf masses.
        for branch in range(13):
            var a:float=(float(branch)+rnd.randf_range(-.15,.15))/13.0*TAU
            var rad:float=rnd.randf_range(.45,.90)
            var cy:float=rnd.randf_range(1.68,2.52)
            var mesh:=SphereMesh.new()
            mesh.radius=rnd.randf_range(.27,.42)
            mesh.height=mesh.radius*2
            mesh.radial_segments=9
            mesh.rings=5
            var n:=MeshInstance3D.new()
            n.mesh=mesh
            n.layers=OBJECT_LAYER
            n.material_override=_mat(palette[branch%palette.size()])
            n.position=Vector3(cos(a)*rad,cy,sin(a)*rad)
            n.scale=Vector3(rnd.randf_range(.8,1.4),rnd.randf_range(.45,.80),rnd.randf_range(.82,1.15))
            origin.add_child(n)
            geom_clusters+=1
        return
    # B sprays and C woven each have editable 3D geometry, not an image treatment.
    # C intentionally consolidates into leaf clumps attached to boughs, to avoid confetti.
    var woven:bool=style=="woven"
    var points:=PackedVector3Array()
    var colors:=PackedColorArray()
    var branch_count:int=10 if woven else 12
    for branch in range(branch_count):
        var angle_jitter:float=rnd.randf_range(-.15,.15) if woven else rnd.randf_range(-.21,.21)
        var main_angle:float=(float(branch)+angle_jitter)/float(branch_count)*TAU
        var branch_r:float=rnd.randf_range(.30,.74) if woven else rnd.randf_range(.46,.98)
        var yy:float=rnd.randf_range(1.97,2.65) if woven else rnd.randf_range(1.94,2.75)
        var center:=Vector3(cos(main_angle)*branch_r,yy,sin(main_angle)*branch_r)
        var count:int=rnd.randi_range(5,9) if woven else rnd.randi_range(6,10)
        for k in range(count):
            var local_angle:float=main_angle+rnd.randf_range(-1.25,1.25)
            var spread_r:float=rnd.randf_range(.03,.15) if woven else rnd.randf_range(.035,.32)
            var pos:=center+Vector3(cos(local_angle)*spread_r,rnd.randf_range(-.17,.15),sin(local_angle)*spread_r)
            # No lower canopy added at the front-facing trunk crossing. Protect 32px front actor.
            if pos.z>0.42 and pos.y<2.20 and absf(pos.x)<.48:
                continue
            var leaves:int=rnd.randi_range(4,6) if woven else rnd.randi_range(3,6)
            var base_palette:int=rnd.randi_range(0,palette.size()-2)
            if woven:
                # Native polygon rosette under each fan; makes a visible connected leaf clump.
                var radius:float=rnd.randf_range(.14,.23)
                var undercolor:Color=palette[base_palette].darkened(.14)
                for sector in range(7):
                    var a1:float=TAU*float(sector)/7.0
                    var a2:float=TAU*float(sector+1)/7.0
                    var wobble:float=.88+0.15*sin(float(sector)*2.4+float(branch))
                    var p1:=pos+Vector3(cos(a1)*radius*wobble,-.04,sin(a1)*radius*wobble)
                    var p2:=pos+Vector3(cos(a2)*radius,-.04,sin(a2)*radius)
                    for pt in [pos+Vector3(0,-.045,0),p1,p2]:
                        points.append(pt)
                        colors.append(undercolor)
                    geom_leaf_tris+=1
            for leaf in range(leaves):
                var theta:float=TAU*float(leaf)/float(leaves)+rnd.randf_range(-.24,.24)
                var offset:=Vector3(cos(theta)*rnd.randf_range(.018,.11),rnd.randf_range(-.045,.055),sin(theta)*rnd.randf_range(.018,.11))
                var size:float=rnd.randf_range(.12,.19) if woven else rnd.randf_range(.115,.225)
                var shade:Color=palette[base_palette] if leaf%3!=0 else palette[base_palette+1]
                _petal(points,colors,pos+offset,theta,size,shade,variant)
                geom_clusters+=1
    var arrays=[]
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX]=points
    arrays[Mesh.ARRAY_COLOR]=colors
    var source:=ArrayMesh.new()
    source.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
    var foliage:=MeshInstance3D.new()
    foliage.name="NEW_NATIVE_3D_LEAF_POLYGONS"
    foliage.mesh=source
    foliage.layers=OBJECT_LAYER
    foliage.material_override=_mat(Color.WHITE)
    origin.add_child(foliage)
    print("STAGE10_GEOMETRY_LEAF_TRIANGLES=",geom_leaf_tris," LEAF_CLUSTERS=",geom_clusters," VIEW=",style)

func _tree(x:float,z:float,height:float,variant:int=0)->void:
    # Ground/PAR from inherited detailed oak; new 3D geometry only appended to PAR.
    super._tree(x,z,height,variant)
    var style:String=OS.get_environment("FS_STAGE10_GEOMETRY")
    if style=="baseline":
        return
    _create_spread(x,z,height,variant,style)