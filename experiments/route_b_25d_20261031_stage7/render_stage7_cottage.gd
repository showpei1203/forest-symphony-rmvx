extends "res://render_tree_stage5.gd"
# FS Stage7: original CC0 detailed cottage imported into same Ground-first native 2.5D world.
# HOUSE model selected by FS_STAGE7_HOUSE environment variable.
const OPTIONS=["medieval_timber_small","medieval_thatch_cottage","witch_cottage"]
var active_house: Node3D

func _place_authored_house(name: String) -> void:
    var res:Resource=load("res://assets/"+name+"_std.glb")
    if not res is PackedScene:
        push_error("FAILED TO IMPORT GLB "+name)
        return
    var obj:Node3D=(res as PackedScene).instantiate() as Node3D
    if obj == null:
        push_error("NO NODE3D "+name)
        return
    obj.name="Stage7_"+name
    vp.add_child(obj)
    # Find original glTF bounds in parent-local coordinates; avoid guesswork scaling.
    var minv:=Vector3(INF,INF,INF)
    var maxv:=Vector3(-INF,-INF,-INF)
    var count:=0
    var material_num:=0
    for mesh_instance in obj.find_children("*","MeshInstance3D",true,false):
        var n:=mesh_instance as MeshInstance3D
        n.layers=OBJECT_LAYER
        if n.mesh==null:continue
        var relative:Transform3D=obj.global_transform.affine_inverse()*n.global_transform
        var box=n.get_aabb()
        for k in range(8):
            var v:Vector3=relative*box.get_endpoint(k)
            minv=minv.min(v)
            maxv=maxv.max(v)
        for surface in range(n.mesh.get_surface_count()):
            var source_mat:Material=n.get_active_material(surface)
            if source_mat is StandardMaterial3D:
                var mat:=source_mat.duplicate() as StandardMaterial3D
                var lighting:String=OS.get_environment("FS_STAGE7_LIGHTING")
                mat.shading_mode=BaseMaterial3D.SHADING_MODE_PER_PIXEL if lighting=="lit" else BaseMaterial3D.SHADING_MODE_UNSHADED
                if OS.get_environment("FS_STAGE7_DETAIL")=="thatch" and "thatch" in source_mat.resource_name.to_lower():
                    mat.albedo_texture=load("res://assets/roof_thatch_stage7.png") as Texture2D
                    mat.albedo_color=Color.WHITE
                    mat.uv1_triplanar=true
                    mat.uv1_world_triplanar=true
                    mat.uv1_scale=Vector3(.85,.85,.85)
                    mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
                if OS.get_environment("FS_STAGE7_DETAIL")=="shader" and "thatch" in source_mat.resource_name.to_lower():
                    var roof_shader:=Shader.new()
                    roof_shader.code="""
shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D roof_tex: source_color, filter_nearest, repeat_enable;
varying vec3 roof_xyz;
void vertex(){ roof_xyz = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment(){
    vec2 sample_uv=vec2(roof_xyz.x,roof_xyz.z)*0.19;
    ALBEDO=texture(roof_tex,sample_uv).rgb;
    ROUGHNESS=1.0;
}
"""
                    var roof_mat:=ShaderMaterial.new()
                    roof_mat.shader=roof_shader
                    roof_mat.set_shader_parameter("roof_tex",load("res://assets/roof_thatch_stage7.png"))
                    n.set_surface_override_material(surface,roof_mat)
                else:
                    n.set_surface_override_material(surface,mat)
                material_num+=1
        count+=1
    if count==0:
        push_error("EMPTY IMPORTED HOUSE "+name)
        return
    var natural_height:float=maxv.y-minv.y
    var target_height:float=4.25 if name!="witch_cottage" else 3.75
    var scale_value:float=target_height/maxf(.01,natural_height)
    obj.scale=Vector3.ONE*scale_value
    obj.position=Vector3(0,-minv.y*scale_value,-.35)
    active_house=obj
    print("ART_ASSET ",name," ORIGINAL_BOUNDS ",minv," ",maxv," HOUSE_SCALE ",scale_value," MESHES ",count," MATERIALS ",material_num)
    # Contact hints stay independently editable in Ground, not copied from PAR.
    # Terrain texture and original Ground shadow own the house contact; no synthetic rectangular grass footprint.
    # Native walkable stones from the house door to old path
    # Do not duplicate the old 2D master.
    for row in range(4):
        _box(Vector3(0,0.055,2.03+float(row)*.36),Vector3(1.12,0.03,.27),Color("#cdb797") if row%2==0 else Color("#b4a587"),TERRAIN_LAYER)

func _create_world()->void:
    super._create_world()
    if cottage_model!=null:
        cottage_model.queue_free()
    var selected:String=OS.get_environment("FS_STAGE7_HOUSE")
    if not selected in OPTIONS:
        selected="witch_cottage"
    _place_authored_house(selected)

func _initialize()->void:
    call_deferred("_render_all")