extends "res://render_stage10_geometry.gd"
# Stage11. Deliberately authored leaf-mass geometry, not palette-only or image sharpening.
# World-space foliage plates with scalloped outlines, dark undersides,
# coherent bough-to-clump structure and individual leaf tips. PAR only.
var stage11_triangles:int=0
var stage11_clusters:int=0
var stage11_boughs:int=0

func _tri(vertices:PackedVector3Array, colors:PackedColorArray, a:Vector3,b:Vector3,c:Vector3,ca:Color,cb:Color,cc:Color)->void:
    for v in [a,b,c]:
        vertices.append(v)
    colors.append(ca)
    colors.append(cb)
    colors.append(cc)
    stage11_triangles+=1

func _make_lobe(vertices:PackedVector3Array, colors:PackedColorArray, center:Vector3, rad:float, seed:int, base_color:Color, detailed:bool)->void:
    # Flat polygon silhouette with a shallow 3D dome, deliberately irregular edges.
    # Each mass has a darker underside and an upper highlight, with no spherical blobs.
    var n:int=16
    var center_top:=center+Vector3(0,.115,0)
    var center_shadow:=center+Vector3(.035,-.13,.045)
    var prev:=Vector3.ZERO
    var first:=Vector3.ZERO
    for j in range(n+1):
        var idx:int=j%n
        var theta:float=TAU*float(idx)/float(n)
        var notch:float=.88+0.12*sin(theta*3.0+float(seed)*1.3)+0.09*cos(theta*5.0+float(seed)*.8)
        if idx%5==0:
            notch*=.76
        var rr:float=rad*notch
        var edge:=center+Vector3(cos(theta)*rr,.022+0.025*sin(theta*4.0+seed),sin(theta)*rr*.78)
        if j==0:
            first=edge
        else:
            var e:Vector3=first if j==n else edge
            # Outer underside, visible as natural depth at crown edges.
            _tri(vertices,colors,center_shadow,prev+Vector3(0,-.040,0),e+Vector3(0,-.04,0),base_color.darkened(.38),base_color.darkened(.28),base_color.darkened(.23))
            # Upper foliage disk: different sectors have deliberate shadow/light.
            var facing:float=.5+.5*cos(theta-.8)
            var light:Color=base_color.lightened(.11) if facing>.58 else base_color.darkened(.10)
            _tri(vertices,colors,center_top,prev,e,base_color.lightened(.035),light,light.darkened(.035))
        prev=edge
    if detailed:
        # Each larger mass has 5 leaf fans tied to the same bough center, not random confetti.
        for k in range(5):
            var angle:float=TAU*float(k)/5.0+float(seed)*.17
            var direction:=Vector3(cos(angle),0,sin(angle)*.78)
            var tangent:=Vector3(-direction.z,0,direction.x)
            var mid:=center+direction*rad*.49+Vector3(0,.135,0)
            var base:=mid-direction*rad*.22
            var tip:=mid+direction*rad*.44+Vector3(0,.013,0)
            var left:=mid+tangent*rad*.15
            var right:=mid-tangent*rad*.15
            _tri(vertices,colors,base,left,tip,base_color.darkened(.05),base_color.lightened(.20),base_color.lightened(.10))
            _tri(vertices,colors,base,tip,right,base_color.darkened(.08),base_color.lightened(.09),base_color.darkened(.14))

func _make_branch(vertices:PackedVector3Array,colors:PackedColorArray, start:Vector3,end:Vector3,shade:Color)->void:
    # Small tapered bark strut; entirely higher than 32x32 Ground contact cut.
    var width:float=.030
    var offset:=Vector3(width,0,width*.3)
    _tri(vertices,colors,start-offset,start+offset,end+offset*.24,shade.darkened(.20),shade,shade.lightened(.07))
    _tri(vertices,colors,start-offset,end+offset*.24,end-offset*.24,shade.darkened(.23),shade.lightened(.04),shade.darkened(.07))
    stage11_boughs+=1

func _add_layered_canopy(x:float,z:float,variant:int,mode:String)->void:
    var root:=Node3D.new()
    root.name="FS_STAGE11_AUTHORED_3D_CANOPY_"+mode
    root.position=Vector3(x,0,z)
    if variant==0:
        root.scale=Vector3(.86,1,.86)
    vp.add_child(root)
    var verts:=PackedVector3Array()
    var cols:=PackedColorArray()
    var bark:=Color("#755840")
    var green=[
        Color("#4e703e"),Color("#5f8546"),Color("#719551"),
        Color("#83a563"),Color("#91ad66"),Color("#638450")
    ]
    # Deliberate radial composition in 3 tiers: four broad lower, five middle,
    # three smaller highlights, central crown; maintain negative spaces.
    var broad:bool=mode=="broad"
    var rings=[
        {"count":4,"radius":.56,"y":2.05,"leaf_radius":.46 if broad else .34},
        {"count":5,"radius":.43,"y":2.49,"leaf_radius":.42 if broad else .32},
        {"count":3,"radius":.27,"y":2.89,"leaf_radius":.30 if broad else .27}
    ]
    var id:int=0
    for ri in range(rings.size()):
        var ring:Dictionary=rings[ri]
        var count:int=ring["count"]
        for j in range(count):
            # Third candidate removes selected entire masses to expose interior boughs.
            if mode=="pruned" and ((ri==0 and j==2) or (ri==1 and j==1) or (ri==2 and j==0)):
                continue
            var theta:float=TAU*(float(j)+.22*float(ri))/float(count)+float(variant)*.23
            var radius:float=ring["radius"]*(1.+.09*sin(float(j)*2.8+ri))
            var center:=Vector3(cos(theta)*radius,ring["y"]+0.09*sin(theta*3.0+variant),sin(theta)*radius*.79)
            # More volume toward back; keep front trunk walk corridor.
            if center.z>.45 and center.y<2.30:
                center.z=.39
            var color:Color=green[(j+2*ri+variant)%green.size()]
            _make_branch(verts,cols,Vector3(0,1.68,0),center,color.darkened(.44))
            _make_lobe(verts,cols,center,ring["leaf_radius"],id,color,true)
            stage11_clusters+=1
            id+=1
    _make_lobe(verts,cols,Vector3(0,3.08,0),.32 if broad else .29,42,green[3],true)
    stage11_clusters+=1
    var arrays:Array=[]
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX]=verts
    arrays[Mesh.ARRAY_COLOR]=cols
    var mesh:=ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
    var instance:=MeshInstance3D.new()
    instance.name="FS11_EDITABLE_CROWN_PLATES"
    instance.mesh=mesh
    instance.layers=OBJECT_LAYER
    instance.material_override=_mat(Color.WHITE)
    root.add_child(instance)
    print("STAGE11_REAL_GEOMETRY mode=",mode," triangles=",stage11_triangles," clusters=",stage11_clusters," branches=",stage11_boughs)

func _tree(x:float,z:float,height:float,variant:int=0)->void:
    super._tree(x,z,height,variant)
    var mode:String=OS.get_environment("FS_STAGE11_MODE")
    if mode=="baseline":
        return
    _add_layered_canopy(x,z,variant,mode)