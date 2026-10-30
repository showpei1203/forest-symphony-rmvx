extends "res://render_stage7_cottage.gd"
# Stage8: Original CC0 oak with 9450 explicit leaf geometry from Innerscene.
# Shared world transform cloned twice; lower tree contact in native GROUND-layer4,
# upper trunk and full layered leaves in native transparent PAR-layer2.
var detailed_clip: Shader
var cached_mats: Dictionary={}
var detailed_nodes: Array[Node3D]=[]

func _clip_material(color:Color, lower:bool)->ShaderMaterial:
    var key:String=str(color.to_html(false))+"_"+str(lower)
    if cached_mats.has(key):
        return cached_mats[key] as ShaderMaterial
    if detailed_clip==null:
        detailed_clip=Shader.new()
        detailed_clip.code="""
shader_type spatial;
render_mode unshaded, cull_disabled;
uniform vec4 tint: source_color=vec4(1.);
uniform float cut_world_y=0.56;
uniform bool show_lower=false;
varying float world_y;
varying vec3 world_normal;
void vertex() {world_y=(MODEL_MATRIX*vec4(VERTEX,1.0)).y; world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment() {
 if (show_lower && world_y>=cut_world_y) discard;
 if (!show_lower && world_y<cut_world_y) discard;
 float light=dot(normalize(world_normal),normalize(vec3(-0.35,0.86,0.28)));
 float shade=light>0.58?1.14:(light>0.12?0.97:0.75);
 ALBEDO=clamp(tint.rgb*shade,vec3(0.0),vec3(1.0));
 ALPHA=1.0;
}
"""
    var sh:=ShaderMaterial.new()
    sh.shader=detailed_clip
    sh.set_shader_parameter("show_lower",lower)
    sh.set_shader_parameter("cut_world_y",0.56)
    sh.set_shader_parameter("tint",color)
    cached_mats[key]=sh
    return sh

func _material_tint(original:Material, palette:String)->Color:
    var name:String=original.resource_name.to_lower()
    if "bark" in name:
        return Color("#80604a") if palette!="original" else Color("#422a1b")
    var g:float=0.18
    if original is StandardMaterial3D:
        g=(original as StandardMaterial3D).albedo_color.g
    if palette=="original":
        # Retain original physical material authored green (dark reference variant).
        return Color("#154518") if g<0.20 else Color("#306c23") if g<0.30 else Color("#538b31")
    return Color("#476d3d") if g<0.20 else Color("#729b4f") if g<0.30 else Color("#92b65f")

func _set_native_clip(inst:Node3D, lower:bool,palette:String)->void:
    var count:int=0
    for it in inst.find_children("*","MeshInstance3D",true,false):
        var node:=it as MeshInstance3D
        var surf_num:int=node.mesh.get_surface_count() if node.mesh!=null else 0
        for i in range(surf_num):
            var m:Material=node.get_active_material(i)
            node.set_surface_override_material(i,_clip_material(_material_tint(m,palette),lower))
            count+=1
    print("STAGE8_OAK_MESHES ",count," lower=",lower)

func _tree(x:float,z:float,height:float,variant:int=0)->void:
    var option:String=OS.get_environment("FS_STAGE8_TREE")
    if option=="baseline" or (option=="left_only" and variant==0):
        super._tree(x,z,height,variant)
        return
    var palette:String=OS.get_environment("FS_STAGE8_PALETTE")
    var h:float=height*1.40
    var rot:float=0.18 if variant==0 else -0.35
    var p:=Vector3(x,0,z)
    var lower:Node3D=_import_model("oak_detailed_innerscene",p,h,4,rot)
    var upper:Node3D=_import_model("oak_detailed_innerscene",p,h,OBJECT_LAYER,rot)
    # Tree B keeps exactly the same root/contact, while narrowing canopy mesh in 3D.
    # The actor test retains the same 16px FRONT offset; never move the test actor.
    if variant==0:
        if lower!=null:
            lower.scale.x*=0.86
            lower.scale.z*=0.86
        if upper!=null:
            upper.scale.x*=0.86
            upper.scale.z*=0.86
    if lower!=null:
        _set_native_clip(lower,true,palette)
        detailed_nodes.append(lower)
    if upper!=null:
        _set_native_clip(upper,false,palette)
        detailed_nodes.append(upper)